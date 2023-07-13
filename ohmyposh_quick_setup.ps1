Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))

Invoke-WebRequest -URI 'https://github.com/Ari-Weinberg/ohmyposh_quick_setup/raw/main/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf' -OutFile 'c:\windows\temp\jetbrains_mono.ttf'
