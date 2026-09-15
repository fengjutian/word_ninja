# Register wordflow:// custom URL protocol
# Run as Administrator with: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$exe = (Get-Process -Id $pid).MainModule.FileName
$exePath = (Get-Item $exe).Directory.Parent.Parent.Parent.Parent.FullName + "\build\windows\x64\runner\Debug\desktop_app.exe"

# Use current directory as fallback
if (-not (Test-Path $exePath)) {
    $exePath = Join-Path (Get-Location) "apps\desktop_app\build\windows\x64\runner\Debug\desktop_app.exe"
}

Write-Host "Registering protocol for: $exePath"

New-Item -Path "HKCU:\Software\Classes\wordflow" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\wordflow" -Name "(Default)" -Value "URL:WordFlow Protocol"
Set-ItemProperty -Path "HKCU:\Software\Classes\wordflow" -Name "URL Protocol" -Value ""

New-Item -Path "HKCU:\Software\Classes\wordflow\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\wordflow\shell\open\command" -Name "(Default)" -Value "`"$exePath`" `"%1`""

Write-Host "Done! Test: start wordflow://vocabulary/add?word=hello" -ForegroundColor Green
