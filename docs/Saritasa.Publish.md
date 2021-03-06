
# Saritasa.Publish

## Invoke-DatabaseProjectPublish

### Syntax
Invoke-DatabaseProjectPublish \[-ProjectPath\] &lt;string&gt; \[\[-Configuration\] &lt;string&gt;\] \[\[-Target\] &lt;string&gt;\] \[-ProfilePath\] &lt;string&gt; \[&lt;CommonParameters&gt;\]

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
			<td><nobr>Configuration</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td>Build configuration \(Release, Debug, etc.\)</td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>ProfilePath</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td>Path to xml profile file.</td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>ProjectPath</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td>Path to sql server database project.</td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>Target</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td>Build target \(Deploy, Publish, etc.\)</td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>

## Invoke-FullPublish

### Syntax
Invoke-FullPublish \[-ProjectFilename\] &lt;string&gt; \[-PublishDir\] &lt;string&gt; \[\[-InstallUrl\] &lt;string&gt;\] \[\[-Version\] &lt;string&gt;\] \[\[-BuildParams\] &lt;string\[\]&gt;\] \[&lt;CommonParameters&gt;\]

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
			<td><nobr>BuildParams</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>InstallUrl</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>ProjectFilename</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>PublishDir</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>Version</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>

## Invoke-ProjectBuildAndPublish

### Synopsis


### Syntax
Invoke-ProjectBuildAndPublish \[-ProjectFilename\] &lt;String&gt; \[-PublishDir\] &lt;String&gt; \[\[-InstallUrl\] &lt;String&gt;\] \[\[-BuildParams\] &lt;String\[\]&gt;\] \[&lt;CommonParameters&gt;\]

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
			<td><nobr>ProjectFilename</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>PublishDir</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>InstallUrl</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>BuildParams</nobr></td>
			<td class="visible-lg visible-md"></td>
			<td></td>
			<td class="visible-lg visible-md">false</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>

## Set-ApplicationVersion

### Syntax
Set-ApplicationVersion \[-Filename\] &lt;string&gt; \[-Version\] &lt;string&gt; \[&lt;CommonParameters&gt;\]

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
			<td><nobr>Filename</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
		<tr>
			<td><nobr>Version</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>

## Update-ApplicationRevision

### Syntax
Update-ApplicationRevision \[-Filename\] &lt;string&gt; \[&lt;CommonParameters&gt;\]

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
			<td><nobr>Filename</nobr></td>
			<td class="visible-lg visible-md">None</td>
			<td></td>
			<td class="visible-lg visible-md">true</td>
			<td class="visible-lg">false</td>
			<td class="visible-lg"></td>
		</tr>
	</tbody>
</table>
