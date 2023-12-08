# Portmaster Offline Installer

[Portmaster](https://github.com/safing/portmaster) offline install, build your own (unsigned) installer.

All credits goes to [Safing](https://safing.io/).

All downloads are from official [Safing](https://safing.io/) website.

Version : **1.0.13**

NSIS is included so you don't have to install it.

## Howto

Clone/Download this repository

Run **PortmasterOfflineBuilder.ps1** with powershell, it will :

- Download **portmaster-start** and run it.
- **portmaster-start** will manage all the required downloads and integrity checks
- Run **makensis.exe** in order to build the installer using **portmaster-installer.nsi** script
- **portmaster-installer-offline.exe** will be created in the same directory (~300mb)
- Clean all downloaded stuff

![Logo](screenshot.png)
