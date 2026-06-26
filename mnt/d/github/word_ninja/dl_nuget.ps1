$outPath = "$env:TEMP\nuget.exe"
Write-Host "Downloading nuget.exe to $outPath ..."
Invoke-WebRequest -Uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $outPath -UseBasicParsing
Write-Host "Done: $outPath"
