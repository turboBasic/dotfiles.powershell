<#
    .SYNOPSIS
        Check for nuget exe. If it doesn't exist, create full path to parent, and download it
#>

[CmdletBinding()]
Param(
    [String]
    $NugetPath = "$ENV:APPDATA\nuget.exe"
)



# Exit if nuget.exe is reachable
    if ($c = Get-Command nuget.exe -errorAction SilentlyContinue)
    {
        "Found Nuget at [$($c.Path)]" | Write-Verbose
        return
    }

# Don't have it, download it
    $Parent = Split-Path $NugetPath -parent
    if (-not (Test-Path $NugetPath))
    {
        if (-not (Test-Path $Parent))
        {
            "Creating parent paths to [$NugetPath]'s parent: [$Parent]" | Write-Verbose
            mkdir $Parent -force
        }
        "Downloading nuget to [$NugetPath]" | Write-Verbose
        Invoke-WebRequest -uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -outFile $NugetPath
    }

# Add to path
    if ( ($ENV:Path -split ';') -notContains $Parent )
    {
        $ENV:Path = $ENV:Path, $Parent -join ';'
    }
