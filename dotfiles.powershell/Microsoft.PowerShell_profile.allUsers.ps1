#Requires -Version 5

# Profile name              Location
# ------------              --------
# AllUsersConsoleHost       $psHome\Microsoft.PowerShell_profile.ps1




# Initialization code

    # Keep track of all profile scripts launched by Powershell during session initialization
    $global:profiles += , $psCommandPath








#region Cleanup

#endregion
