
# Saritasa.AppDeploy

## Invoke-DesktopProjectDeployment

### Syntax
Invoke-DesktopProjectDeployment \[-Session\] &lt;PSSession&gt; \[-BinPath\] &lt;string&gt; \[-DestinationPath\] &lt;string&gt; \[\[-BeforeDeploy\] &lt;scriptblock&gt;\] \[\[-AfterDeploy\] &lt;scriptblock&gt;\] \[\[-OverwriteMode\] &lt;AppDeployOverwriteMode&gt;\] \[&lt;CommonParameters&gt;\]

### Parameters

<table class="table table-striped table-bordered table-condensed visible-on">
	<thead>
		<tr>
			<th>Name</th>
			<th class="visible-lg visible-md">Alias</th>
			<th>Description</th>
			<th class="visible-lg visible-md">Required?</th>
			<th class="visible-lg">Pipeline Input</th>
			<th class="visible-lg">Default Value</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><nobr>AfterDeploy</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>BeforeDeploy</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>BinPath</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>DestinationPath</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>OverwriteMode</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>Session</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>

## Invoke-ServiceProjectDeployment

### Synopsis


### Syntax
Invoke-ServiceProjectDeployment \[-Session\] &lt;PSSession&gt; \[-ServiceName\] &lt;String&gt; \[-ProjectName\] &lt;String&gt; \[-BinPath\] &lt;String&gt; \[-DestinationPath\] &lt;String&gt; \[\[-ServiceCredential\] &lt;PSCredential&gt;\] \[&lt;CommonParameters&gt;\]

### Parameters

<table class="table table-striped table-bordered table-condensed visible-on">
	<thead>
		<tr>
			<th>Name</th>
			<th class="visible-lg visible-md">Alias</th>
			<th>Description</th>
			<th class="visible-lg visible-md">Required?</th>
			<th class="visible-lg">Pipeline Input</th>
			<th class="visible-lg">Default Value</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><nobr>Session</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>ServiceName</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>ProjectName</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>BinPath</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>DestinationPath</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>ServiceCredential</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>

### Note
User should have 'Log on as a service right \(https://technet.microsoft.com/en-us/library/cc739424\(v=ws.10\).aspx\).
Local user name example: .\\administrator

Service user accounts: LocalService, NetworkService, LocalSystem
https://msdn.microsoft.com/en-us/library/windows/desktop/ms686005\(v=vs.85\).aspx

Credentials for built-in service user accounts:
New-Object System.Management.Automation.PSCredential\('NT AUTHORITY\\LocalService', \(New-Object System.Security.SecureString\)\)
New-Object System.Management.Automation.PSCredential\('NT AUTHORITY\\NetworkService', \(New-Object System.Security.SecureString\)\)
New-Object System.Management.Automation.PSCredential\('.\\LocalSystem', \(New-Object System.Security.SecureString\)\)

