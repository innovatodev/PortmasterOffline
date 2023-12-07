$StartURI = "https://updates.safing.io/latest/windows_amd64/start/portmaster-start.exe"
$StartPATH = "$PSScriptRoot\portmaster-start.exe"
$PortmasterDIR = "$PSScriptRoot\Portmaster"
$NSI = "$PSScriptRoot\portmaster-installer.nsi"
$MAKENSIS = "$PSScriptRoot\nsis-3.05\Bin\makensis.exe"
$InstallerOffline = "$PSScriptRoot\portmaster-installer-offline.exe"
function Invoke-EnsureDirectory($Path) {
    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force -Confirm:$false
    }
    New-Item $Path -ItemType Directory
}
function Invoke-DownloadFile($Uri, $Path) {
    if (Test-Path $Path) {
        Remove-Item $Path -Force -Confirm:$false
    }
    Invoke-WebRequest -Uri $Uri -OutFile $Path
}
Invoke-EnsureDirectory $PortmasterDIR
Write-Host "Downloading portmaster-start"
Invoke-DownloadFile $StartURI $StartPATH
Write-Host "Downloading required offline portmaster stuff using portmaster-start"
Start-Process $StartPATH -ArgumentList "clean-structure --data=$PortmasterDIR" -NoNewWindow -Wait
Start-Process $StartPATH -ArgumentList "update --data=$PortmasterDIR" -NoNewWindow -Wait
if (Test-Path $InstallerOffline) {
    Write-Host "Deleting $InstallerOffline"
    Remove-Item $InstallerOffline -Force -Confirm:$false
}
Write-Host "Starting MakeNSIS"
Start-Process $MAKENSIS -ArgumentList "$NSI" -NoNewWindow -Wait
Remove-Item $PortmasterDIR, $StartPATH -Recurse -Force -Confirm:$false
Write-Host "Your installer is ready."
