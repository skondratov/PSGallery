# Web Deploy: Powershell script to set up delegated deployments with Web Deploy
# Copyright (C) Microsoft Corp. 2010
#
# Requirements: IIS 7, Windows Server 2008 (or higher)
#
# elevatedUsername/elevatedPassword: Credentials of a user that has write access to applicationHost.config. Used for createApp, appPoolNetFx, appPoolPipeline delegation rules.
# adminUsername/adminPassword: Credentials of a user that is in the Administrators security group on this server. Used for recycleApp delegation rule.



param(
    $elevatedUsername,

    $elevatedPassword,

    $adminUsername,

    $adminPassword,

    [switch]$ignorePasswordResetErrors
)

# ==================================

Import-LocalizedData -BindingVariable Resources -FileName Resources.psd1

 #constants
 $SCRIPTERROR = 0
 $logfile = ".\HostingLog-$(get-date -format MMddyyHHmmss).log"
 $WARNING = 1
 $INFO = 2

# ================ METHODS =======================

# this function does logging
function write-log([int]$type, [string]$info){

    $message = $info -f $args
    $logMessage = get-date -format HH:mm:ss

    Switch($type){
        $SCRIPTERROR{
            $logMessage = $logMessage + "`t" + $Resources.Error + "`t" +  $message
            write-host -foregroundcolor white -backgroundcolor red $logMessage
        }
        $WARNING{
            $logMessage = $logMessage + "`t" + $Resources.Warning + "`t" +  $message
            write-host -foregroundcolor black -backgroundcolor yellow $logMessage
        }
        default{
            $logMessage = $logMessage + "`t" + $Resources.Info + "`t" +  $message
            write-host -foregroundcolor black -backgroundcolor green  $logMessage
        }
    }

    $logMessage >> $logfile
}

# returns false if OS is not server SKU
 function NotServerOS
 {
    $sku = $((gwmi win32_operatingsystem).OperatingSystemSKU)
    $server_skus = @(7,8,9,10,12,13,14,15,17,18,19,20,21,22,23,24,25)

    return ($server_skus -notcontains $sku)
 }

 function CheckHandlerInstalled
 {
    trap [Exception]
    {
        return $false
    }
    $serverManager = (New-Object Microsoft.Web.Administration.ServerManager)
    $serverManager.GetAdministrationConfiguration().GetSection("system.webServer/management/delegation").GetCollection()
    return $true
 }

 # gives a user permissions to a file on disk
 function GrantPermissionsOnDisk($username, $path, $type, $options)
 {
    trap [Exception]{
        write-log $SCRIPTERROR $Resources.NotGrantedPermissions $type $username $path
    }

    $acl = (Get-Item $path).GetAccessControl("Access")
    $accessrule = New-Object system.security.AccessControl.FileSystemAccessRule($username, $type, $options, "None", "Allow")
    $acl.AddAccessRule($accessrule)
    set-acl -aclobject $acl $path
    $message =
    write-log $INFO $Resources.GrantedPermissions $type $username $path
}

 function GetOrCreateUser($username)
 {
    if(-not (CheckLocalUserExists($username) -eq $true))
    {
        $comp = [adsi] "WinNT://$env:computername,computer"
        $user = $comp.Create("User", $username)
        write-log $INFO $Resources.CreatedUser $username
    }
    else
    {
        $user = [adsi] "WinNT://$env:computername/$username, user"
    }
    return $user
 }

 function GetAdminGroupName()
 {
    $securityIdentifier = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $adminName = $securityIdentifier.Translate([System.Type]::GetType("System.Security.Principal.NTAccount")).ToString()
    $array = $adminName -split "\\"
    if($array.Count -eq 2)
    {
        return $array[1]
    }

    return "Administrators"
 }

 function CreateLocalUser($username, $password, $isAdmin)
 {
    $user = GetOrCreateUser($username)
    $user.SetPassword($password)
    $user.SetInfo()

    if($isAdmin)
    {
        $adminGroupName = GetAdminGroupName
        if(-not((CheckIfUserIsAdmin $adminGroupName $username) -eq $true))
        {
            $group = [ADSI]"WinNT://$env:computername/$adminGroupName,group"
            $group.add("WinNT://$env:computername/$username")
            write-log $INFO $Resources.AddedUserAsAdmin $username
        }
        else
        {
            write-log $INFO $Resources.IsAdmin $username
        }
    }

    return $true
 }

 function CheckLocalUserExists($username)
 {
    $objComputer = [ADSI]("WinNT://$env:computername")
    $colUsers = ($objComputer.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "User"} | Select-Object -expand Name)

    $blnFound = $colUsers -contains $username

    if ($blnFound){
        return $true
    }
    else{
        return $false
    }
 }

 function CheckIfUserIsAdmin($adminGroupName, $username)
 {
    $computer = [ADSI]("WinNT://$env:computername,computer")
    $group = $computer.psbase.children.find($adminGroupName)

    $colMembers = $group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name",'GetProperty',$null,$_,$null)}

    $bIsMember = $colMembers -contains $username
    if($bIsMember)
    {
        return $true
    }
    else
    {
        return $false
    }
 }

 function GenerateStrongPassword()
 {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Web") > $null
    return [System.Web.Security.Membership]::GeneratePassword(12,4)
 }

 function Initialize
 {
    trap [Exception]
    {
        write-log $SCRIPTERROR $Resources.CheckIIS7Installed
        break
    }

    [System.Reflection.Assembly]::LoadFrom( ${env:windir} + "\system32\inetsrv\Microsoft.Web.Administration.dll" ) > $null
 }

 # gets path of applicationHost.config
 function GetApplicationHostConfigPath
 {
    return (${env:windir} + "\system32\inetsrv\config\applicationHost.config")
 }
 
function GetValidWebDeployInstallPath()
{
    foreach($number in 3..1)
    {
        $keyPath = "HKLM:\Software\Microsoft\IIS Extensions\MSDeploy\" + $number
        if(Test-Path($keypath))
        {
            return $keypath
        }
    }
    return $null
}

function IsWebDeployInstalled()
 {
    $webDeployKeyPath = GetValidWebDeployInstallpath

    if($webDeployKeyPath)
    {
        $value = (get-item($webDeployKeyPath)).GetValue("Install")
        if($value -eq 1)
        {
            return $true
        }
    }
    return $false
 }

 function CheckRuleExistsAndUpdateRunAs($serverManager, $path, $providers, $identityType, $userName, $password)
 {
    for($i=0;$i-lt $delegationRulesCollection.Count;$i++)
    {
        $providerValue = $delegationRulesCollection[$i].Attributes["providers"].Value
        $pathValue = $delegationRulesCollection[$i].Attributes["path"].Value
        $enabled = $delegationRulesCollection[$i].Attributes["enabled"].Value

        if( $providerValue -eq $providers -AND
            $pathValue -eq $path)
        {
            if($identityType -eq "SpecificUser")
            {
                $runAsElement = $delegationRulesCollection[$i].ChildElements["runAs"];
                $runAsElement.Attributes["userName"].Value = $userName
                $runAsElement.Attributes["password"].Value = $password
                $serverManager.CommitChanges()
                write-log $INFO $Resources.UpdatedRunAsForSpecificUser $providers $username
            }

            if($enabled -eq $false)
            {
                $delegationRulesCollection[$i].Attributes["enabled"].Value = $true
                $serverManager.CommitChanges()
            }
            return $true
        }
    }
    return $false
 }

function CheckSharedConfigNotInUse()
{
    $serverManager = (New-Object Microsoft.Web.Administration.ServerManager)
    $section = $serverManager.GetRedirectionConfiguration().GetSection("configurationRedirection")
    $enabled = [bool]$section["enabled"]
    if ($enabled -eq $true)
    {
        return $false
    }
    return $true
}

 function CreateDelegationRule($providers, $path, $pathType, $identityType, $userName, $password, $enabled)
 {
    $serverManager = (New-Object Microsoft.Web.Administration.ServerManager)
    $delegationRulesCollection = $serverManager.GetAdministrationConfiguration().GetSection("system.webServer/management/delegation").GetCollection()
    if(CheckRuleExistsAndUpdateRunAs $serverManager $path $providers $identityType $userName $password )
    {
        write-log $INFO $Resources.RuleNotCreated $providers
        return
    }

    $newRule = $delegationRulesCollection.CreateElement("rule")
    $newRule.Attributes["providers"].Value = $providers
    $newRule.Attributes["actions"].Value = "*"
    $newRule.Attributes["path"].Value = $path
    $newRule.Attributes["pathType"].Value = $pathType
    $newRule.Attributes["enabled"].Value = $enabled

    $runAs = $newRule.GetChildElement("runAs")

    if($identityType -eq "SpecificUser")
    {
        $runAs.Attributes["identityType"].Value = "SpecificUser"
        $runAs.Attributes["userName"].Value = $userName
        $runAs.Attributes["password"].Value = $password
    }
    else
    {
        $runAs.Attributes["identityType"].Value = "CurrentUser"
    }

    $permissions = $newRule.GetCollection("permissions")
    $user = $permissions.CreateElement("user")
    $user.Attributes["name"].Value = "*"
    $user.Attributes["accessType"].Value = "Allow"
    $user.Attributes["isRole"].Value = "False"
    $permissions.Add($user) | out-null

    $delegationRulesCollection.Add($newRule) | out-null
    $serverManager.CommitChanges()

    write-log $INFO $Resources.CreatedRule $providers
 }

 function CheckUserViaLogon($username, $password)
 {

 $signature = @'
    [DllImport("advapi32.dll")]
    public static extern int LogonUser(
        string lpszUserName,
        string lpszDomain,
        string lpszPassword,
        int dwLogonType,
        int dwLogonProvider,
        ref IntPtr phToken);
'@

    $type = Add-Type -MemberDefinition $signature  -Name Win32Utils -Namespace LogOnUser  -PassThru

    [IntPtr]$token = [IntPtr]::Zero

    $value = $type::LogOnUser($username, $env:computername, $password, 2, 0, [ref] $token)

    if($value -eq 0)
    {
        return $false
    }

    return $true
 }

 function CheckUsernamePasswordCombination($user, $password)
 {
    if($user -AND !$password)
    {
        if(CheckLocalUserExists($user) -eq $true)
        {
            if(!$ignorePasswordResetErrors)
            {
                write-log $SCRIPTERROR $Resources.NoPasswordForGivenUser $user
                return $false
            }
            else
            {
                write-Log $INFO $Resources.PasswordWillBeReset $user
                return $true
            }
        }
    }

    if(($user) -AND ($password))
    {
        if(CheckLocalUserExists($user) -eq $true)
        {
            if(CheckUserViaLogon $user $password)
            {
                return $true
            }
            else
            {
                write-Log $SCRIPTERROR $Resources.FailedToValidateUserWithSpecifiedPassword $user
                return $false
            }
        }
    }

    return $true
 }

#================= Main Script =================

 if(NotServerOS)
 {
    write-log $SCRIPTERROR $Resources.NotServerOS
    #break [AZ] 4/29/2016 Fix for Windows Server 2012 R2
 }

 Initialize
 if(CheckSharedConfigNotInUse)
 {
     if(IsWebDeployInstalled)
     {
        if(CheckHandlerInstalled)
        {
            if((CheckUsernamePasswordCombination $elevatedUsername $elevatedPassword) -AND
                (CheckUsernamePasswordCombination $adminUsername $adminPassword))
            {

                if(!$elevatedUsername)
                {
                    $elevatedUsername = "WDeployConfigWriter"
                }

                if(!$adminUsername)
                {
                    $adminUsername = "WDeployAdmin"
                }

                if(!$elevatedPassword)
                {
                    $elevatedPassword = GenerateStrongPassword
                }

                if(!$adminPassword)
                {
                    $adminPassword = GenerateStrongPassword
                }

                # create local user which has write access to applicationHost.config and administration.config
                if(CreateLocalUser $elevatedUsername $elevatedPassword $false)
                {
                    # create local admin user which can recycle application pools
                    if(CreateLocalUser $adminUsername $adminPassword $true)
                    {
                        $applicationHostConfigPath = GetApplicationHostConfigPath
                        GrantPermissionsOnDisk $elevatedUsername $applicationHostConfigPath "ReadAndExecute,Write" "None"
                        
                        CreateDelegationRule "contentPath, iisApp" "{userScope}" "PathPrefix" "CurrentUser" "" "" "true"
                        CreateDelegationRule "dbFullSql" "Data Source=" "ConnectionString" "CurrentUser" "" "" "true"
                        CreateDelegationRule "dbDacFx" "Data Source=" "ConnectionString" "CurrentUser" "" "" "true"
                        CreateDelegationRule "dbMySql" "Server=" "ConnectionString" "CurrentUser" "" "" "true"
                        CreateDelegationRule "createApp" "{userScope}" "PathPrefix" "SpecificUser" $elevatedUsername $elevatedPassword "true"
                        CreateDelegationRule "setAcl" "{userScope}" "PathPrefix" "CurrentUser" "" "" "true"
                        CreateDelegationRule "recycleApp" "{userScope}" "PathPrefix" "SpecificUser" $adminUsername $adminPassword "true"
                        CreateDelegationRule "appPoolPipeline,appPoolNetFx" "{userScope}" "PathPrefix" "SpecificUser" $elevatedUsername $elevatedPassword "true"
                        CreateDelegationRule "backupSettings" "{userScope}" "PathPrefix" "SpecificUser" $elevatedUsername $elevatedPassword "true"
                        CreateDelegationRule "backupManager" "{userScope}" "PathPrefix" "CurrentUser" "" "" "true"
                    }
                    else
                    {
                        break
                    }
                }
                else
                {
                    break
                }
            }
            else
            {
                break
            }
        }
        else
        {
            write-log $SCRIPTERROR $Resources.HandlerNotInstalledQ
            break
        }
     }
     else
     {
        write-log $SCRIPTERROR $Resources.WDeployNotInstalled
     }
 }
 else
 {
    write-log $SCRIPTERROR $Resources.SharedConfigInUse
 }
