# Register wordninja:// custom URL protocol
# Run as Administrator with: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$exe = (Get-Process -Id $pid).MainModule.FileName
$exePath = (Get-Item $exe).Directory.Parent.Parent.Parent.Parent.FullName + "\build\windows\x64\runner\Debug\desktop_app.exe"

# Use current directory as fallback
if (-not (Test-Path $exePath)) {
    $exePath = Join-Path (Get-Location) "apps\desktop_app\build\windows\x64\runner\Debug\desktop_app.exe"
}

Write-Host "Registering protocol for: $exePath"

New-Item -Path "HKCU:\Software\Classes\wordninja" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\wordninja" -Name "(Default)" -Value "URL:Word Ninja Protocol"
Set-ItemProperty -Path "HKCU:\Software\Classes\wordninja" -Name "URL Protocol" -Value ""

New-Item -Path "HKCU:\Software\Classes\wordninja\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\wordninja\shell\open\command" -Name "(Default)" -Value "`"$exePath`" `"%1`""

Write-Host "Done! Test: start wordninja://vocabulary/add?word=hello" -ForegroundColor Green
