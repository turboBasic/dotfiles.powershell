#Requires -version 3


# Synopsis: user profile tasks which should not affect Global namespace
function Main {

    # @TODO( Turn some Environment Variables On/Off using Hashtable or Array
    # $env.Blacklist = @( 'nodePath', 'nvm_Home' )

    try { 
      $null = Get-Command pshazz -errorAction Stop
      pshazz init 'mao' 
    } 
    catch { }
    
    #region constants
    #endregion

}




function Bootstrap {

    $global:__profileHistory += $psCommandPath

}




#region Execution

    # this will effectively unwrap Bootstrap() and Main() and execute them in Global scope
    . ${FUNCTION:Bootstrap}    
    . ${FUNCTION:Main}                                                              

#endregion




#region Cleanup

    Remove-Item FUNCTION:\Bootstrap, FUNCTION:\Main

#endregion