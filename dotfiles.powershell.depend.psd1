@{
    psDeploy = 'latest'
    
    #psScriptAnalyzer = @{ 
    #    DependencyType = 'psGalleryModule' 
    #    Version =        'latest'
    #}
    
    #BuildHelpers = @{ 
    #    DependencyType = 'psGalleryModule' 
    #    Version =        'latest'
    #}
    
    Pester = @{ 
        DependencyType =     'psGalleryModule'
        Parameters = @{
            psDependAction = 'Install'
        }
        SkipPublisherCheck = $true
    } 
    
    buildToolsDir = @{
        DependencyType = 'Command'
        Source =         'if (-not (Test-Path .buildTools -pathType Container)) { 
                            New-Item -itemType Directory -name .buildTools
                          }'
    }
    
    'nightroman/PowerShelf' = @{
        #DependencyType = 'GitHub'
        #Version =        'master'
        DependsOn =       'buildToolsDir'
        Parameters = @{
            ExtractPath = 'Assert-SameFile.ps1', 
                          'Save-NuGetTool.ps1'
        }
        Target =          '.\.buildTools\PowerShelf\'
    }
    
    Helps = @{
        DependencyType = 'Command'
        DependsOn =      'nightroman/PowerShelf'
        Source =         'if (-not (Test-Path .buildTools\Helps\Helps.ps1)) {
                            cd .buildTools
                            .\PowerShelf\Save-NuGetTool.ps1 Helps
                            cd ..
                          }'  
    }
    
    PandocZip = @{
        DependencyType = 'FileDownload'
        DependsOn =      'buildToolsDir'
        Source =         'https://github.com/jgm/pandoc/releases/download/2.0.5/pandoc-2.0.5-windows.zip'
        Target =         '.\.buildTools\'
    }
    
    Pandoc = @{
        DependencyType = 'Command'
        DependsOn =      'PandocZip'
        Source =         'if (-not (Test-Path .buildTools\pandoc.exe)) {
                            cd .buildTools  
                            7z e pandoc-2.0.5-windows.zip *\pandoc.exe
                            cd ..
                          }'
    }
}