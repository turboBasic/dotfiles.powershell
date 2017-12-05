<#
        .Synopsis
Build script for Invoke-Build (https://github.com/nightroman/Invoke-Build)
    
        .Description
Builds project and properly deploys its artifacts

#>



# Build script parameters are standard parameters
Param(
	[Switch]$NoTestDiff
)



# Ensure script works in the most strict mode
Set-StrictMode -Version Latest


# Synopsis: Build the project.
task Build {
    "Inside 'Build' task" | Write-Verbose
    
    $True
}

# Synopsis: Convert markdown files to HTML.
# <http://johnmacfarlane.net/pandoc/>
task Markdown {
	function Convert-Markdown($Name) {pandoc.exe --standalone --from=gfm "--output=$Name.htm" "--metadata=pagetitle=$Name" "$Name.md"}
	exec { Convert-Markdown README }
	exec { Convert-Markdown Release-Notes }
}

# Synopsis: Remove generated and temp files
task Clean {
    "Inside 'Clean' task" | Write-Verbose
    
    Get-Item z, Tests\z, Tests\z.*, README.htm, Release-Notes.htm, dotfiles.powershell.*.nupkg -errorAction 0 |
	Remove-Item -force -recurse
}

# Synopsis: Warn about not empty git status if .git exists
task GitStatus -If (Test-Path .git) {
	$status = exec { git status -s }
	if ($status) {
		Write-Warning "Git status: $($status -join ', ')"
	}
}

# Synopsis: Build the PowerShell help file (<https://github.com/nightroman/Helps>)
# To get the tool execute the following from the project's root:  Invoke-Expression "& {$((New-Object Net.WebClient).DownloadString('https://github.com/nightroman/PowerShelf/raw/master/Save-NuGetTool.ps1'))} Helps"
task Help {
    if (-not (Test-Path .\Helps\Helps.ps1)) {
        Invoke-Expression "& {$((New-Object Net.WebClient).DownloadString('https://github.com/nightroman/PowerShelf/raw/master/Save-NuGetTool.ps1'))} Helps"
    }
	. .\Helps\Helps.ps1
	Convert-Helps dotfilesPowershell-Help.ps1 dotfilesPowershell-Help.xml
}

# Synopsis: Set $script:Version
task Version {

	# get the version from Release-Notes
	($script:Version = .{ 
        switch -Regex -File Release-Notes.md 
        {
            '##\s+v(\d+\.\d+\.\d+)'  { 
                return $Matches[1] 
            }
        } 
    })
    
	assert $Version
    
}

# Synopsis: Make the module folder
task Module     Version, Markdown, Help, {
	# mirror the module folder
	Remove-Item [z] -force -recurse
	$dir = "$BuildRoot\z\dotfiles.powershell"
	exec {$null = robocopy.exe dotfiles.powershell $dir /mir} 1

	# copy files
	Copy-Item -destination $dir `
        dotfilesPowershell-Help.xml,
        README.htm,
        LICENSE.txt,
        Release-Notes.htm

	# make manifest
	Set-Content "$dir\dotfiles.powershell.psd1" @"
@{
	ModuleVersion = '$Version'
	ModuleToProcess = 'dotfiles.powershell.psm1'
	GUID = '6083db24-2b5e-4895-818d-cad778bbe76b'
	Author = 'Andriy Melnyk'
	CompanyName = 'Cargonautica'
	Copyright = '(c) 2017 Andriy Melnyk'
	Description = 'dotfiles (profile & custom modules) for Powershell'
	PowerShellVersion = '3.0'
	AliasesToExport = '' #'Invoke-Build', 'Build-Checkpoint', 'Build-Parallel'
	PrivateData = @{
		PSData = @{
			Tags = 'Profile', 'dotfiles'
			ProjectUri = 'https://github.com/turboBasic/dotfiles.powershell'
			LicenseUri = 'https://github.com/turboBasic/dotfiles.powershell/blob/master/LICENSE'
			IconUri = 'https://gist.githubusercontent.com/turboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png'
			ReleaseNotes = 'https://github.com/turboBasic/dotfiles.powershell/blob/master/Release-Notes.md'
		}
	}
}
"@
}

# Synopsis: Make the NuGet package
task NuGet      Module, {
	# rename the folder
	Rename-Item z\dotfiles.powershell tools

	# summary and description
	$text = @'
dotfiles.powershell is set of Cmdlets for management of Powershell profile and ready-to-use enhancements which are injected into the profile
'@

	# manifest
	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>dotfiles.powershell</id>
		<version>$Version</version>
		<authors>Andriy Melnyk</authors>
		<owners>Andriy Melnyk</owners>
		<projectUrl>https://github.com/turboBasic/dotfiles.powershell</projectUrl>
		<iconUrl>https://gist.githubusercontent.com/turboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png</iconUrl>
		<licenseUrl>https://github.com/turboBasic/dotfiles.powershell/blob/master/LICENSE</licenseUrl>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<summary>$text</summary>
		<description>$text</description>
		<tags>PowerShell profile dotfiles</tags>
		<releaseNotes>https://github.com/turboBasic/dotfiles.powershell/blob/master/Release-Notes.md</releaseNotes>
		<developmentDependency>true</developmentDependency>
	</metadata>
</package>
"@

	# package
	exec { NuGet pack z\Package.nuspec -noDefaultExcludes -noPackageAnalysis }
}

# Synopsis: Push with a version tag
task PushRelease    Version, {
	$changes = exec { git status --short }
	assert (!$changes) "Please, commit changes."

	exec { git push }
	exec { git tag -a "v$Version" -m "v$Version" }
	exec { git push origin "v$Version" }
}

# Synopsis: Push NuGet package
task PushNuGet      NuGet, {
	exec { NuGet push "dotfiles.powershell.$Version.nupkg" -source nuget.org }
},
Clean


# Synopsis: Test and check expected output
# Requires PowerShelf/Assert-SameFile.ps1
task Test3 {
	# invoke tests, get output and result
	$output = Invoke-Build . Tests\.build.ps1 -Result result -Summary | Out-String -Width:200
	if ($NoTestDiff) {return}

	# process and save the output
	$resultPath = "$BuildRoot\Invoke-Build-Test.log"
	$samplePath = "$HOME\data\Invoke-Build-Test.$($PSVersionTable.PSVersion.Major).log"
	$output = $output -replace '\d\d:\d\d:\d\d(?:\.\d+)?( )? *', '00:00:00.0000000$1'
	[System.IO.File]::WriteAllText($resultPath, $output, [System.Text.Encoding]::UTF8)

	# compare outputs
	Assert-SameFile $samplePath $resultPath $env:MERGE
	Remove-Item $resultPath
}

# Synopsis: Test with PowerShell v6
task Test6 -If $env:powershell6 {
	$diff = if ($NoTestDiff) {'-NoTestDiff'}
	exec {& $env:powershell6 -NoProfile -Command Invoke-Build Test3 $diff}
}

# Synopsis: Test v3 and v6
task Test Test3, Test6



# Synopsis: Build and clean
task . Test, Clean