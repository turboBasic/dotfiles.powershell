#Requires -version 3



# Synopsis: user profile tasks which should not affect Global namespace
function Main {

    # @TODO( Turn some Environment Variables On/Off using Hashtable or Array
    # $env.Blacklist = @( 'nodePath', 'nvm_Home' )

    $versionString = $psVersionTable.psVersion.ToString()
    $host.UI.RawUI.WindowTitle += "   |   $versionString"
    Write-Host ($__messages.welcome -f $profile)

    # Clean up variables  
    Remove-Variable -name versionString

}


# Synopsis: Initialization code for Powershell profile. Encapsulated in function for sweet syntax, 
# in fact we will dot source function's body into Global scope
function Bootstrap {

    # Keep track of all profile scripts launched by Powershell during session initialization
      $global:__profileHistory = , $psCommandPath


    # Initialize error messages
      $global:__errors = Data {
          #culture="en-US"
          
          ConvertFrom-StringData -stringData @'
              importFile = Failed to import file {0}: {1}
'@
      }
      Import-LocalizedData -bindingVariable '__errors' -baseDirectory $psScriptRoot\profile


    # Dot source public and private function definition files
      $Public  = @( Get-ChildItem -path $psScriptRoot\profile\Public\*.ps1  -errorAction SilentlyContinue )
      $Private = @( Get-ChildItem -path $psScriptRoot\profile\Private\*.ps1 -errorAction SilentlyContinue )

      foreach ($import in @($Public + $Private))
      {
          Try   { . $import.FullName } 
          Catch { $__errors.importFile -f $import.FullName, $_ | Write-Error }
      }

    # Clean up variables  
      Remove-Variable -name import, Public, Private

}




#region Execution

  # this will effectively unwrap Bootstrap() and Main() and execute them in Global scope
  . ${FUNCTION:Bootstrap}    
  . ${FUNCTION:Main}                                                            

#endregion




#region Cleanup

  Remove-Item FUNCTION:\Bootstrap, FUNCTION:\Main

#endregion