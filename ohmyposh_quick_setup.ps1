# Script to install oh-my-posh along with PSReadLine and Terminal-Icons extensions.
# Configures Windows Terminal app to use Jetbrains Mono Nerdfont with dracula theme by default.
# Make sure to run as Administrator
# Run with: Set-ExecutionPolicy Bypass -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://github.com/Ari-Weinberg/ohmyposh_quick_setup/raw/main/ohmyposh_quick_setup.ps1'))
Write-Host "-------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Oh-My-Posh windows install script, with extra goodies" -ForegroundColor Cyan
Write-Host "By A.Weinberg" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Cyan
Write-Host '"Unable to detect font" warning can be ignored' -ForegroundColor Cyan
Write-Host "-------------------------------------------------------------------" -ForegroundColor Cyan

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[-] This script requires administrative privileges. Please run the script as an administrator." -ForegroundColor Red
    Exit
}

Write-Host "[+] Installing oh-my-posh via Winget" -ForegroundColor Cyan
# Install oh-my-posh with winget
# https://ohmyposh.dev/
winget install JanDeDobbeleer.OhMyPosh -s winget

Write-Host "[+] Downloading Jetbrains Mono font" -ForegroundColor Cyan
# Download Jetbrains Mono font. Uses Nerdfont version 2.3.3, as some icons got removed in later versions
Invoke-WebRequest -URI 'https://github.com/Ari-Weinberg/ohmyposh_quick_setup/raw/main/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf' -OutFile 'c:\windows\temp\jetbrains_mono.ttf'

# Define and import function to install font.
. {
    function Install-Font {
        param (
            [Parameter(Mandatory = $true)]
            [string]$FontFilePath
        )

        # Get the font name from the file path.
        $FontName = [System.IO.Path]::GetFileNameWithoutExtension($FontFilePath)

        # Check if the font is already installed
        $fontKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontRegistry = Get-ItemProperty -Path $fontKeyPath
        if ($fontRegistry -and $fontRegistry."$FontName (TrueType)" -eq $FontFilePath) {
            Write-Host "Font '$FontName' is already installed." -ForegroundColor Cyan
            return
        }

        # Install the font.
        Write-Host "[+] Installing font '$FontName'" -ForegroundColor Cyan

        # Copy the font file to the Windows fonts folder.
        $fontsFolderPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Fonts'), "$FontName.ttf")
        Copy-Item -Path $FontFilePath -Destination $fontsFolderPath -Force

        # Add the font to the registry.
        $fontNameKey = "$FontName (TrueType)"
        Set-ItemProperty -Path $fontKeyPath -Name $fontNameKey -Value $fontsFolderPath

        Write-Host "[+] Font '$FontName' has been installed." -ForegroundColor Cyan
    }
}

Write-Host "[+] Installing Jetbrains Mono font" -ForegroundColor Cyan
Install-Font -FontFilePath "c:\windows\temp\jetbrains_mono.ttf"

Write-Host "[+] Updating Terminal settings" -ForegroundColor Cyan
# Import terminal settings JSON file.
$jsonContent = Get-Content -Path "C:\Users\$Env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Raw | ConvertFrom-Json

# Update the "defaults" section.
$jsonContent.profiles.defaults = @{
    font        = @{
        face = "JetBrainsMono NFM"
    }
    colorScheme = "Dracula"
}

# Create the new "Dracula" scheme array.
$DraculaScheme = @{
    name                = "Dracula"
    cursorColor         = "#F8F8F2"
    selectionBackground = "#44475A"
    background          = "#282A36"
    foreground          = "#F8F8F2"
    black               = "#21222C"
    blue                = "#BD93F9"
    cyan                = "#8BE9FD"
    green               = "#50FA7B"
    purple              = "#FF79C6"
    red                 = "#FF5555"
    white               = "#F8F8F2"
    yellow              = "#F1FA8C"
    brightBlack         = "#6272A4"
    brightBlue          = "#D6ACFF"
    brightCyan          = "#A4FFFF"
    brightGreen         = "#69FF94"
    brightPurple        = "#FF92DF"
    brightRed           = "#FF6E6E"
    brightWhite         = "#FFFFFF"
    brightYellow        = "#FFFFA5"
}

$schemesArray = @($DraculaScheme)

# Add the "schemes" array to the existing content.
$jsonContent.schemes += $schemesArray

# Write the new JSON back to the settings file.
$jsonString = $jsonContent | ConvertTo-Json -Depth 10
$jsonString | Set-Content -Path "C:\Users\$Env:UserName\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

Write-Host "[+] Installing extensions" -ForegroundColor Cyan
# Install history and icons.
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Scope CurrentUser -Repository PSGallery -Force


Write-Host "[+] Adding imports to Powershell profile" -ForegroundColor Cyan
# Add config to Powershell profile.
if (-not (Test-Path -Path $PROFILE -PathType Leaf)) {
    $null = New-Item -Path $PROFILE -ItemType File 
}

Add-Content -Path $PROFILE -Value 'oh-my-posh init pwsh --config $env:POSH_THEMES_PATH\night-owl.omp.json | Invoke-Expression'
Add-Content -Path $PROFILE -Value 'Import-Module -Name Terminal-Icons'
Add-Content -Path $PROFILE -Value 'Set-PSReadLineOption -PredictionSource History'
Add-Content -Path $PROFILE -Value 'Set-PSReadLineOption -PredictionViewStyle ListView'
Add-Content -Path $PROFILE -Value 'Set-PSReadLineOption -EditMode Windows'

Write-Host "[+] All Done! Reopen your terminal app for all changes to take effect" -ForegroundColor Cyan