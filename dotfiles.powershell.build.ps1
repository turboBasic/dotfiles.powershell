<#
        .SYNOPSIS
	Build script for Invoke-Build (https://github.com/nightroman/Invoke-Build)

        .DESCRIPTION
	Builds project and properly deploys its artifacts

#>



# Build script parameters are standard parameters
	Param(
        [Switch]
        $NoTestDiff
    )
#

# Script-level initialization

    # Ensure script works in the most strict mode
    Set-StrictMode -version Latest

    $script:Settings =     & .\dotfiles.powershell.settings.ps1
    $script:toolsDir =     Join-Path -path $buildRoot -childPath $Settings.toolsDir
    $script:moduleName =   $Settings.ModuleName
    $script:artifactsDir = Join-Path -path $buildRoot -childPath $Settings.artifactsDir
#


# Synopsis: Inject all Public and Private functions to the profile
    task InjectFunctions {
        Get-ChildItem (Join-Path -path $buildRoot -childPath $moduleName\Public) -File -Recurse -Filter *.ps1 -errorAction SilentlyContinue |
            ForEach-Object {
                Add-Content -path $artifactsDir\profile.ps1 -value ( , "`n`n`n" + (Get-Content $_.FullName) )
            }
    }

# Synopsis: Creates artifacts directory and copies profile templates there
    task CopyArtifacts  {

        $Null = mkdir $artifactsDir -errorAction SilentlyContinue
        $Null = mkdir $artifactsDir\allUsers -errorAction SilentlyContinue

        Copy-Item $buildRoot\$moduleName\profile.ps1 $artifactsDir
        Copy-Item $buildRoot\$moduleName\Microsoft.Powershell_profile.ps1 $artifactsDir
        Copy-Item $buildRoot\$moduleName\Microsoft.PowershellISE_profile.ps1 $artifactsDir

        Copy-Item $buildRoot\$moduleName\profile.allUsers.ps1 $artifactsDir\allUsers
        Copy-Item $buildRoot\$moduleName\Microsoft.Powershell_profile.allUsers.ps1 $artifactsDir\allUsers
        Copy-Item $buildRoot\$moduleName\Microsoft.PowershellISE_profile.allUsers.ps1 $artifactsDir\allUsers
        Get-Item $artifactsDir\allUsers\*.ps1 |
            ForEach-Object {
                Rename-Item -path $_ -newName ($_.Name -replace '.allUsers')
            }

    }


# Synopsis: Build the project
    task Build      CopyArtifacts, InjectFunctions
#


# Synopsis: Convert markdown files to HTML using pandoc ( <http://johnmacfarlane.net/pandoc/> )
	task Markdown {

		function Convert-Markdown( $Name ) {
			& $toolsDir\pandoc.exe --standalone --from=gfm "--output=$Name.html" "--metadata=pagetitle=$Name" "$Name.md"
		}

		exec { Convert-Markdown README }
		exec { Convert-Markdown Release-Notes }

	}
#


# Synopsis: Remove generated and temp files
	task Clean {
		Get-Item z, Tests\z, Tests\z.*, $toolsDir, $artifactsDir, README.html, Release-Notes.html, dotfiles.powershell.*.nupkg -errorAction SilentlyContinue |
                Remove-Item -force -recurse
	}
#


# Synopsis: Warn about not empty git status if .git exists
	task GitStatus -If (Test-Path .git) {
		$status = ( exec { git status -s } ) -join ', '
		if ($status) {
			Write-Warning "Git status: $status"
		}
	}
#


# Synopsis: Build the PowerShell help file using Helps tool ( <https://github.com/nightroman/Helps> )
	# To get the tool execute the following from the project's root:
	#     Invoke-Expression -command "&{ $( Invoke-WebRequest -uri https://github.com/nightroman/PowerShelf/raw/master/Save-NuGetTool.ps1 ) } Helps"
	# or even shorter:
	#     iex "&{ $( iwr https://github.com/nightroman/PowerShelf/raw/master/Save-NuGetTool.ps1 ) } Helps"
	task Help {
		. $toolsDir\Helps\Helps.ps1
		. .\$moduleName\profile\Public\Invoke-DefaultProfile.ps1
		Convert-Helps dotfilesPowershell-Help.ps1 .\$moduleName\dotfilesPowershell-Help.xml
	}
#


# Synopsis: Set $Version variable
	task Version {

		# get the version from Release-Notes
		# finds headers beginning with "v1.2.3" pattern
		$script:Version = . {
			switch -regex -file Release-Notes.md
			{
				'(?x) \#\# \s+ v( \d+ \. \d+ \. \d+ )'  {
					return $Matches[1]
				}
			}
		}

		"Version: $Version" | Write-Verbose
		assert $Version

	}
#


# Synopsis: Make the module folder
	task Module     Version, Markdown, Help, {

		# mirror the module folder in temporary directory "z"
			Remove-Item [z] -force -recurse
			$dir = "$buildRoot\z\dotfiles.powershell"
			exec { $null = robocopy.exe dotfiles.powershell $dir /mir } 1

		# copy files
			Copy-Item -destination $dir README.html,
				LICENSE,
				Release-Notes.html

		# make manifest
			Set-Content -path $dir\dotfiles.powershell.psd1 -value "
				@{
					ModuleVersion =        '$Version'
					ModuleToProcess =      'dotfiles.powershell.psm1'
					GUID =                 '6083db24-2b5e-4895-818d-cad778bbe76b'

					Author =               'Andriy Melnyk'
					CompanyName =          'Cargonautica'
					Copyright =            '(c) 2017 Andriy Melnyk'

					Description =          'dotfiles (profile & custom modules) for Powershell'

					PowerShellVersion =    '3.0'
					AliasesToExport =      ''

					PrivateData = @{
						PSData = @{
							Tags =         'profile', 'dotfiles'
							ProjectUri =   'https://github.com/turboBasic/dotfiles.powershell'
							LicenseUri =   'https://github.com/turboBasic/dotfiles.powershell/blob/master/LICENSE'
							IconUri =      'https://gist.githubusercontent.com/turboBasic/9dfd228781a46c7b7076ec56bc40d5ab/raw/03942052ba28c4dc483efcd0ebf4bfc6809ed0d0/hexagram3D.png'
							ReleaseNotes = 'https://github.com/turboBasic/dotfiles.powershell/blob/master/Release-Notes.md'
						}
					}
				}"

	}
#


# Synopsis: Make the NuGet package
	task NuGet      Module, {

		# rename the folder as per Nuget convention
			Rename-Item z\dotfiles.powershell tools

		# summary and description of a package
			$text = '

				dotfiles.powershell is set of Cmdlets for management of Powershell profile and ready-to-use enhancements which are injected into the profile

			' -replace '^\s+' -replace '\s+$'

		# manifest
			Set-Content -path z\Package.nuspec -value "<?xml version='1.0'?>
				<package xmlns='http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd'>
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
						<tags>Powershell profile dotfiles</tags>
						<releaseNotes>https://github.com/turboBasic/dotfiles.powershell/blob/master/Release-Notes.md</releaseNotes>
						<developmentDependency>true</developmentDependency>
					</metadata>
				</package>"

		# package
			exec { NuGet.exe pack z\Package.nuspec -noDefaultExcludes -noPackageAnalysis }

	}
#


# Synopsis: Push with a version tag
	task PushRelease    Version, {

		$changes = exec { git status --short }
		assert (-not $changes) "Please, commit changes"

		exec { git push }
		exec { git tag -a "v$Version" -m "v$Version" }
		exec { git push origin "v$Version" }

	}
#


# Synopsis: Push NuGet package
	task PushNuGet     NuGet, {
			exec { NuGet.exe push "dotfiles.powershell.$Version.nupkg" -source nuget.org }
		},
		Clean
#


<# Synopsis: Test and check expected output
	#
	# Requires Assert-SameFile.ps1  ( https://github.com/nightroman/PowerShelf/blob/master/Assert-SameFile.ps1 )
	# Download all PowerShelf tools:
	#       iex "&{ $( iwr https://github.com/nightroman/PowerShelf/raw/master/Save-NuGetTool.ps1 ) } PowerShelf"; mkdir .\.buildTools; Move-Item .\PowerShelf .\.buildTools\
	# or just Assert-SameFile.ps1:
	#       New-Item -path .\.buildTools\PowerShelf\Assert-SameFile.ps1 -itemType File -value (iwr https://raw.githubusercontent.com/nightroman/PowerShelf/master/Assert-SameFile.ps1) -force
	task Test3 {

		# invoke tests, get output and result
			$output = Invoke-Build . Tests\.build.ps1 -result Result -summary | Out-String -width 200
			if ($noTestDiff) {
				return
			}

		# process and save the output
			$resultPath = "$buildRoot\Invoke-Build-Test.log"
			$samplePath = "$HOME\data\Invoke-Build-Test.$($psVersionTable.psVersion.Major).log"
			$output = $output -replace '\d\d:\d\d:\d\d(?:\.\d+)?( )? *', '00:00:00.0000000$1'
			[System.IO.File]::WriteAllText( $resultPath, $output, [System.Text.Encoding]::UTF8 )

		# compare outputs
			& $toolsDir\PowerShelf\Assert-SameFile.ps1 $samplePath $resultPath $env:MERGE
			Remove-Item $resultPath
	}
#>


<# Synopsis: Test with PowerShell v6
	task Test6      -If $ENV:powershell6 {
		$diff = if ($noTestDiff) { '-noTestDiff' }
		exec { & $ENV:powershell6 -noProfile -command Invoke-Build Test3 $diff }
	}
#>


<# Synopsis: Test v3 and v6
	task Test       Test3, Test6
#>


# Synopsis: Build and clean
    #task .          Test, Clean, Build
    task .          Clean, Build
#

# Synopsis: Deploy to user profile dir
    task Deploy     {
        Invoke-PSDeploy -tags CurrentUser -force
        sudo Invoke-PSDeploy -tags AllUsers -force
    }
