Set-ExecutionPolicy Bypass -Force
# Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

winget install JanDeDobbeleer.OhMyPosh -s winget

Invoke-WebRequest -URI 'https://github.com/Ari-Weinberg/ohmyposh_quick_setup/raw/main/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf' -OutFile 'c:\windows\temp\jetbrains_mono.ttf'

. {
    function Install-Font {
        param (
            [Parameter(Mandatory = $true)]
            [string]$FontFilePath
        )

        # Get the font name from the file path
        $FontName = [System.IO.Path]::GetFileNameWithoutExtension($FontFilePath)

        # Check if the font is already installed
        $fontKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontRegistry = Get-ItemProperty -Path $fontKeyPath
        if ($fontRegistry -and $fontRegistry."$FontName (TrueType)" -eq $FontFilePath) {
            Write-Host "Font '$FontName' is already installed."
            return
        }

        # Install the font
        Write-Host "Installing font '$FontName'..."

        # Copy the font file to the Windows fonts folder
        $fontsFolderPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Fonts'), "$FontName.ttf")
        Copy-Item -Path $FontFilePath -Destination $fontsFolderPath -Force

        # Add the font to the registry
        $fontNameKey = "$FontName (TrueType)"
        Set-ItemProperty -Path $fontKeyPath -Name $fontNameKey -Value $fontsFolderPath

        Write-Host "Font '$FontName' has been installed."
    }
}

Install-Font -FontFilePath "c:\windows\temp\jetbrains_mono.ttf"

if (-not (Test-Path -Path $PROFILE -PathType Leaf)) {
    New-Item -Path $PROFILE -ItemType File
}

$jsonContent = Get-Content -Path "C:\Users\$Env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Raw | ConvertFrom-Json

# Update the "defaults" section
$jsonContent.profiles.defaults = @{
    font = @{
        face = "JetBrainsMono NFM"
    }
}

$jsonString = $jsonContent | ConvertTo-Json -Depth 10
$jsonString | Set-Content -Path "C:\Users\$Env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

