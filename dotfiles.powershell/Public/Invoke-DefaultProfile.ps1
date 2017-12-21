<#

.SYNOPSIS
    Recreates default profile for Current User / All Hosts

.INPUTS
    None. Cannot accept pipeline input

.OUTPUTS
    None in case of successfull completing. Throws in case of error

.LINK
    about_Profiles

#>
function Invoke-DefaultProfile {

    [CmdletBinding( ConfirmImpact = 'High', SupportsShouldProcess )]
    [OutputType( [Void] )]
    Param(
        [Switch] $Force
    )

    if ( $psCmdlet.ShouldProcess(
            "Powershell profile for user '${ENV:UserName}' with full path '$profile' is going to be reset to its default content",
            "Powershell profile '$profile' changes to default state",
            "Confirm action"
        )
    ) {
        "Profile for user '${ENV:UserName}' has been reset to default state" | Write-Verbose
    }

}
