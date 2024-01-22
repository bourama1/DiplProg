# Start WinAudit.exe and wait for it to exit
Start-Process -FilePath ".\WinAudit.exe" -ArgumentList "/r=gsoPxuTUeERNtnzDaIbMpmidcSArCOHG", "/f=audit.html", "/T=datetime" -Wait

# Compare
python .\compare.py
