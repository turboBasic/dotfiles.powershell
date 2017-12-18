# script for Invoke-PSDeploy ( https://github.com/RamblingCookieMonster/PSDeploy )
#
# Name                   Definition                                                             Expanded path
# ----                   ----------                                                             -------------
# AllUsersAllHosts       $PsHome\Profile.ps1                                                    C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
# AllUsersCurrentHost    $PsHome\Microsoft.PowerShell_profile.ps1                               C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
#                        $PsHome\Microsoft.PowerShellISE_profile.ps1                            C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShellISE_profile.ps1
#
# CurrentUserAllHosts    $Home\Documents\WindowsPowerShell\profile.ps1                          C:\Users\me\Documents\WindowsPowerShell\profile.ps1
# CurrentUserCurrentHost $Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1     C:\Users\me\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
#                        $Home\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1  C:\Users\me\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1


Deploy Profiles {
    By Filesystem {
        FromSource  dotfiles.powershell\profile
        To          $Home\Documents\WindowsPowerShell\profile
        WithOptions @{
            Mirror = $True
        }
    }

    By Filesystem Files {
        FromSource  dotfiles.powershell\profile.ps1, dotfiles.powershell\Microsoft.PowerShell_profile.ps1, dotfiles.powershell\dotfilesPowershell-Help.xml
        To          $Home\Documents\WindowsPowerShell
    }
}