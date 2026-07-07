# Register wordninja:// custom URL protocol for Word Ninja desktop app
# Run as Administrator

$exePath = "D:\github\word_ninja\word_ninja\apps\desktop_app\build\windows\x64\runner\Debug\desktop_app.exe"

# Register protocol
New-Item -Path "HKCU:\Software\Classes\wordninja" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\wordninja" -Name "(Default)" -Value "URL:Word Ninja Protocol"
Set-ItemProperty -Path "HKCU:\Software\Classes\wordninja" -Name "URL Protocol" -Value ""

# Command to execute
New-Item -Path "HKCU:\Software\Classes\wordninja\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\wordninja\shell\open\command" -Name "(Default)" -Value "`"$exePath`" `"%1`""

Write-Host "Protocol wordninja:// registered!" -ForegroundColor Green
Write-Host "Test: wordninja://vocabulary/add?word=hello" -ForegroundColor Cyan
