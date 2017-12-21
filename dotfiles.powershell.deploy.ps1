# script for Invoke-PSDeploy ( https://github.com/RamblingCookieMonster/PSDeploy )
#
# Name                   Definition                                                             Expanded path
# ----                   ----------                                                             -------------
# AllUsersAllHosts       $PsHome\profile.ps1                                                    C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
# AllUsersCurrentHost    $PsHome\Microsoft.PowerShell_profile.ps1                               C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
#                        $PsHome\Microsoft.PowerShellISE_profile.ps1                            C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShellISE_profile.ps1
#
# CurrentUserAllHosts    $Home\Documents\WindowsPowerShell\profile.ps1                          C:\Users\me\Documents\WindowsPowerShell\profile.ps1
# CurrentUserCurrentHost $Home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1     C:\Users\me\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
#                        $Home\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1  C:\Users\me\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1


$script:Settings =     & .\dotfiles.powershell.settings.ps1
$script:artifactsDir = $Settings.artifactsDir

Deploy Profiles {
    By Filesystem {
        FromSource  $artifactsDir\profile.ps1,
                    $artifactsDir\Microsoft.PowerShell_profile.ps1,
                    $artifactsDir\Microsoft.PowerShellISE_profile.ps1
        To          ${Home}\Documents\WindowsPowerShell
        Tagged      CurrentUser
    }

    By Filesystem AllUsers {
        FromSource  $artifactsDir\allUsers\profile.ps1,
                    $artifactsDir\allUsers\Microsoft.PowerShell_profile.ps1,
                    $artifactsDir\allUsers\Microsoft.PowerShellISE_profile.ps1
        To          ${psHome}
        Tagged      AllUsers
    }
}
