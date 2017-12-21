# Customize these properties and tasks
    Param(
        $ArtifactsDir =         '.artifacts',
        $ModuleName =           'dotfiles.powershell',
        $ModulePath =           './dotfiles.powershell',
        $toolsDir =             '.buildTools',
        $BuildNumber =          $ENV:BUILD_NUMBER,
        $PercentCompliance =    '60'
    )


# Static settings -- no reason to include these in the param block
    $Settings = @{
        SMBRepoName =           'CargonauticaRepo'
        SMBRepoPath =           '\\dns323\psGallery'

        Author =                'Andriy Melnyk'
        Owners =                'Andriy Melnyk'
        LicenseUrl =            'https://github.com/turboBasic/dotfiles.powershell/LICENSE'
        ProjectUrl =            'https://github.com/turboBasic/dotfiles.powershell'
        PackageDescription =    'dotfiles for Powershell'
        Repository =            'https://github.com/turboBasic/dotfiles.powershell.git'
        Tags =                  'profile,dotfiles'

        # TODO: fix any redudant naming
        GitRepo =       'turboBasic/dotfiles.powershell'
        CIUrl =         ''
    }



# Merge Parameters and static settings into Result
    $Settings += @{
        ArtifactsDir        = $ArtifactsDir
        ModuleName          = $ModuleName
        ModulePath          = $ModulePath
        toolsDir            = $toolsDir
        BuildNumber         = $BuildNumber
        PercentCompliance   = $PercentCompliance
    }


    $Settings
