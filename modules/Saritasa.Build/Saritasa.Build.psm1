﻿function Install-NugetCli
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Destination
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $nugetExePath = "$Destination\nuget.exe"
    
    if (!(Test-Path $nugetExePath))
    {
        Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $nugetExePath
    }
}

function Invoke-NugetRestore
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to solution. All NuGet packages from included projects will be restored.')]
        [string] $SolutionPath
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Install-NugetCli -Destination $PSScriptRoot
    $nugetExePath = "$PSScriptRoot\nuget.exe"

    &$nugetExePath 'restore' $SolutionPath
    if ($LASTEXITCODE)
    {
        throw 'Nuget restore failed.'
    }
}

function Invoke-SolutionBuild
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to solution.')]
        [string] $SolutionPath,
        [Parameter(HelpMessage = 'Build configuration (Release, Debug, etc.)')]
        [string] $Configuration
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    Invoke-ProjectBuild $SolutionPath $Configuration
}

function Invoke-ProjectBuild
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to project.')]
        [string] $ProjectPath,
        [Parameter(HelpMessage = 'Build configuration (Release, Debug, etc.)')]
        [string] $Configuration,
        [string] $Target = 'Build',
        [string[]] $BuildParams
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    msbuild.exe $ProjectPath '/m' "/t:$Target" "/p:Configuration=$Configuration" '/verbosity:normal' $BuildParams
    if ($LASTEXITCODE)
    {
        throw 'Build failed.'
    }
}

<#
.SYNOPSIS
Update version numbers of AssemblyInfo.cs and AssemblyInfo.vb.

.NOTES
Based on SetVersion script.
http://www.luisrocha.net/2009/11/setting-assembly-version-with-windows.html
Copyright (c) 2009 Luis Rocha
#>
function Update-AssemblyInfoFile
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Version string in major.minor.build.revision format.')]
        [string] $Version
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
    $assemblyVersion = 'AssemblyVersion("' + $Version + '")';
    $fileVersion = 'AssemblyFileVersion("' + $Version + '")';
    
    Get-ChildItem -r -Include AssemblyInfo.cs, AssemblyInfo.vb | ForEach-Object `
        {
            $filename = $_.Directory.ToString() + '\' + $_.Name
        
            # If you are using a source control that requires to check-out files before 
            # modifying them, make sure to check-out the file here.
            # For example, TFS will require the following command:
            # tf checkout $filename
        
            if ($PSCmdlet.ShouldProcess($filename))
            {
                (Get-Content $filename) | ForEach-Object `
                    {
                        ForEach-Object { $_ -replace $assemblyVersionPattern, $assemblyVersion } |
                        ForEach-Object { $_ -replace $fileVersionPattern, $fileVersion }
                    } | Set-Content $filename -Encoding UTF8
                    
                Write-Information $filename, ' -> ', $Version
            }
        }
}

function Copy-DotnetConfig
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to App.config.template or Web.config.template file.')]
        [string] $TemplateFilename
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $configFilename = $TemplateFilename -replace '\.template', ''
    if (!(Test-Path $configFilename))
    {
        Copy-Item $TemplateFilename $configFilename
    }
}

<#
.SYNOPSIS
Run Entity Framework migrations.

.NOTES
In essential this command tries to find migrate.exe in packages and run it against specified
configuration file.
#>
function Invoke-EFMigrate
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to assembly file with migrations.')]
        [string] $MigrationAssembly,
        [Parameter(HelpMessage = 'Path to assembly .config file. If not specified default or parent Web.config will be used.')]
        [string] $ConfigFilename
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    # Format and validate params
    if (!$ConfigFilename)
    {
        $ConfigFilename = $MigrationAssembly + '.config'
        if (!(Test-Path $ConfigFilename))
        {
            $ConfigFilename = Join-Path (Split-Path $MigrationAssembly) '..\Web.config'
        }
    }
    if (!(Test-Path $ConfigFilename))
    {
        throw "$ConfigFilename does not exist."
    }
    if (!(Test-Path $MigrationAssembly))
    {
        throw "$MigrationAssembly does not exist."
    }

    # Find migrate.exe
    $packagesDirectory = Get-ChildItem 'packages' -Recurse -Depth 3 | 
        Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if (!$packagesDirectory)
    {
        throw 'Cannot find packages directory.'
    }
    Write-Information "Found $packagesDirectory.FullName"
    $migrateExeDirectory = Get-ChildItem $packagesDirectory.FullName 'EntityFramework.*' |
        Sort-Object { $_.Name } | Select-Object -Last 1
    if (!$migrateExeDirectory)
    {
        throw 'Cannot find entity framework package.'
    }
    $migrateExe = Join-Path $migrateExeDirectory.FullName '.\tools\migrate.exe'
    Write-Information "Found $migrateExeDirectory.FullName"

    # Run migrate
    $workingDirectory = Get-Location
    $args = @(
        [System.IO.Path]::GetFileName($MigrationAssembly)
        '/startUpDirectory:"{0}"' -f (Join-Path $workingDirectory (Split-Path $MigrationAssembly))
        '/startUpConfigurationFile:"{0}"' -f (Join-Path $workingDirectory $ConfigFilename)
    );
    &"$migrateExe" $args
    if ($LASTEXITCODE)
    {
        throw "Migration failed."
    }
}

<#
.SYNOPSIS
Replaces placeholders $(UserName) with values from hashtable.
.EXAMPLE
Update-VariablesInFile -Path Config.xml @{UserName='sa'}
#>
function Update-VariablesInFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [Parameter(Mandatory = $true)]
        [hashtable] $Variables
    )

    Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $content = Get-Content $Path

    foreach ($key in $Variables.Keys)
    {
        $escapedValue = $Variables[$key] -replace '\$', '$$$$'
        $content = $content -ireplace"\`$\($key\)", $escapedValue
    }

    $content | Set-Content $Path
}
