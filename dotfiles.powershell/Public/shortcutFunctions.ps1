# Install Chocolatey package with auto-confirmation
function cinsty {
    choco install -y @args
}

function clists {
    choco list --id-starts-with @args
}


