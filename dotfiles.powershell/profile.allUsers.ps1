#Requires -Version 5

# Profile name              Location
# ------------              --------
# AllUsersAllHosts          $psHome\profile.ps1




# Initialization code

    # Keep track of all profile scripts launched by Powershell during session initialization
        $global:profiles += , $psCommandPath


    # Initialize error messages
        $global:__errors = Data {
            ConvertFrom-StringData -stringData @'
                importFile = Failed to import file {0}: {1}
'@
        }
        # Import-LocalizedData -bindingVariable '__errors'


    # Powershell window title
        $host.UI.RawUI.WindowTitle += "   |   $( $psVersionTable.psVersion.ToString() )"

    # @TODO( Turn some Environment Variables On/Off using Hashtable or Array
    # $env.Blacklist = @( 'nodePath', 'nvm_Home' )




#region Cleanup

#endregion

