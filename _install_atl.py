import subprocess, sys  
result = subprocess.run([  
    r\"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe\",  
    \"modify\",  
    \"--installPath\", r\"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\",  
    \"--add\", \"Microsoft.VisualStudio.Component.VC.ATL\",  
    \"--quiet\", \"--norestart\"  
], capture_output=True, text=True, timeout=300)  
print(f\"STDOUT: {result.stdout}\")  
print(f\"STDERR: {result.stderr}\")  
print(f\"CODE: {result.returncode}\") 
