Unicode true

!define PRODUCT_VERSION "1.0.13.0"
!define VERSION "1.0.13.0"

VIProductVersion "${PRODUCT_VERSION}"
VIFileVersion "${VERSION}"

VIAddVersionKey "ProductName" "Portmaster"
VIAddVersionKey "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey "FileDescription" "Portmaster Application Firewall"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "CompanyName" "Safing ICS Technologies GmbH"
VIAddVersionKey "LegalCopyright" "Safing ICS Technologies GmbH"

!define MUI_ICON "portmaster.ico"
!define MUI_UNICON "portmaster.ico"
!define MUI_HEADERIMAGE

!include MUI2.nsh
!include nsDialogs.nsh
!include LogicLib.nsh
!include WinVer.nsh
!include x64.nsh
!include shortcut-properties.nsh

Name "Portmaster"

OutFile "portmaster-installer-offline.exe"
SetCompressor /SOLID lzma
!define ProgrammFolderLink "$Programfiles64\Safing\Portmaster.lnk"
!define Parent_ProgrammFolderLink "$Programfiles64\Safing"
!define ExeName "portmaster-start.exe"
!define LogoName "portmaster.ico"
!define SnoreToastExe "SnoreToast.exe"

!define MUI_ABORTWARNING
!define MUI_LANGDLL_ALLLANGUAGES

Var InstDir_parent

;;
; Pages
;;
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!include languages.nsh

Function .onInit
	ReadEnvStr $0 PROGRAMDATA
	StrCpy $InstDir "$0\Safing\Portmaster"
	StrCpy $InstDir_parent "$0\Safing"
	SetRebootFlag true
FunctionEnd

Section "Install"
	SetOutPath $INSTDIR

	SetShellVarContext all

	IfFileExists "$Programfiles64\Safing\Portmaster" 0 noAncientUpdate
		DetailPrint "Removing old Portmaster Files"

		RMDIR /R "$SMPROGRAMS\Portmaster"
		Delete "$SMSTARTUP\Portmaster Notifier.lnk"
		RMDir /R /REBOOTOK "$Programfiles64\Safing\Portmaster"
noAncientUpdate:

	IfFileExists "$INSTDIR\${ExeName}" 0 dontUpdate
		DetailPrint "Removing old Portmaster Files"
		Delete "$INSTDIR\${ExeName}.bak"
		Rename "$INSTDIR\${ExeName}" "$INSTDIR\${ExeName}.bak"
		Delete /REBOOTOK "$INSTDIR\${ExeName}.bak"
dontUpdate:
	File "${ExeName}"

	File "${LogoName}"
	File "portmaster-uninstaller.exe"

	CreateDirectory "${Parent_ProgrammFolderLink}"
	CreateShortcut "${ProgrammFolderLink}" "$InstDir"

	SetShellVarContext all
	CreateDirectory "$SMPROGRAMS\Portmaster"
	CreateShortcut "$SMPROGRAMS\Portmaster\Portmaster.lnk" "$INSTDIR\${ExeName}" "app --data=$InstDir" "$INSTDIR\portmaster.ico"
	CreateShortcut "$SMPROGRAMS\Portmaster\Portmaster Notifier.lnk" "$INSTDIR\${ExeName}" "notifier --data=$InstDir" "$INSTDIR\portmaster.ico"
	CreateShortcut "$SMSTARTUP\Portmaster Notifier.lnk" "$INSTDIR\${ExeName}" "notifier --data=$InstDir" "$INSTDIR\portmaster.ico"

	!insertmacro ShortcutSetToastProperties "$SMPROGRAMS\Portmaster\Portmaster.lnk" "{7F00FB48-65D5-4BA8-A35B-F194DA7E1A51}" "io.safing.portmaster"
	pop $0
	${If} $0 <> 0
		MessageBox MB_ICONEXCLAMATION "Shortcut-Attributes to enable Toast Messages could not be set"
		SetErrors
		Abort
	${EndIf}
	DetailPrint "Sucessfully added Shortcut-Attributes for Toast Messages. Return Code: $0 (0: S_OK)"

	WriteRegStr HKLM "SOFTWARE\Classes\CLSID\{7F00FB48-65D5-4BA8-A35B-F194DA7E1A51}\LocalServer32" "" '"$INSTDIR\${ExeName}" notifier-snoretoast'

; prepare directory structure
	nsExec::ExecToStack '$INSTDIR\${ExeName} clean-structure --data=$InstDir'
	pop $0
	pop $1
	DetailPrint "Prepared the installation directory."

; Copy Portmaster directory
DetailPrint "Copying Portmaster directory..."
SetOutPath "$INSTDIR"
SetOverwrite on
File /r ".\Portmaster\*.*"
DetailPrint "Successfully copied Portmaster."

; register Service
	nsExec::ExecToStack '$INSTDIR\${ExeName} install core-service --data=$InstDir'
	pop $0
	pop $1
	DetailPrint $1
	${If} $0 <> 0
		MessageBox MB_ICONEXCLAMATION "Windows Service registration failed. Please contact our support at support@safing.io."
		SetErrors
		Abort
	${EndIf}
	DetailPrint "Successfully registered Portmaster as a Windows Service."

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"DisplayName" "Portmaster"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"UninstallString" "$\"$INSTDIR\portmaster-uninstaller.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"DisplayIcon" "$\"$INSTDIR\portmaster.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"Publisher" "Safing ICS Technologies GmbH"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"HelpLink" "https://safing.io"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"NoRepair" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Portmaster" \
		"NoModify" 1

SectionEnd
