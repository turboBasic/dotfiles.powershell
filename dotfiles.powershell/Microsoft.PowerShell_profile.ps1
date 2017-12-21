#Requires -Version 5

# Profile name              Location
# ------------              --------
# CurrentUserConsoleHost    $Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1




# Initialization code

    # Keep track of all profile scripts launched by Powershell during session initialization
        $global:profiles += , $psCommandPath

    # psHazz
        try {
            $null = Get-Command psHazz -errorAction Stop
            pshazz init 'mao'
        }
        catch { }

    # Powershell window title
    $host.UI.RawUI.WindowTitle += "   |   $($host.Name)"





#region Cleanup

#endregion
