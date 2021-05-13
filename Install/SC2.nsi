; The name of the installer
Name "SuperCopier 2"

Icon "..\pictures\progicon32.ico"

; The file to write
OutFile "SuperCopier2xxx.exe"

; The default installation directory
InstallDir $PROGRAMFILES\SuperCopier2

XPStyle on

BrandingText "-= SFX TEAM =-"

;--------------------------------

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

; First is default
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\French.nlf"

; A LangString for the section name
LangString Sec1Name ${LANG_ENGLISH} "SuperCopier 2 (required)"
LangString Sec1Name ${LANG_FRENCH} "SuperCopier 2 (requis)"
LangString Sec2Name ${LANG_ENGLISH} "Start menu shortcuts"
LangString Sec2Name ${LANG_FRENCH} "Raccourcis dans le menu d�marrer"
LangString Sec3Name ${LANG_ENGLISH} "Start when windows starts"
LangString Sec3Name ${LANG_FRENCH} "D�marrer quand windows d�marre"
LangString Sec4Name ${LANG_ENGLISH} "Run when install finishes"
LangString Sec4Name ${LANG_FRENCH} "D�marrer � la fin de l'installation"
LangString Sec5Name ${LANG_ENGLISH} "Open ReadMe when install finishes"
LangString Sec5Name ${LANG_FRENCH} "Ouvrir le ReadMe � la fin de l'installation"

LangString UninstSC1 ${LANG_ENGLISH} "You must uninstall SuperCopier 1 before installing SuperCopier 2, would you like to uninstall it?"
LangString UninstSC1 ${LANG_FRENCH} "Vous devez d�sinstaller SuperCopier 1 avant d'installer SuperCopier 2, voulez-vous le d�sinstaller?"
LangString UninstSC1Confirm ${LANG_ENGLISH} "Do you want to force SuperCopier 2 install ? (not recommended !)"
LangString UninstSC1Confirm ${LANG_FRENCH} "Voulez-vous forcer l'installation de SuperCopier 2 ? (non recommand� !)"

LangString MenuAccess ${LANG_ENGLISH} "Menu access"
LangString MenuAccess ${LANG_FRENCH} "Acc�der au menu"
LangString UninstSC2 ${LANG_ENGLISH} "Uninstall SuperCopier2"
LangString UninstSC2 ${LANG_FRENCH} "D�sinstaller SuperCopier2"
LangString ReadMe ${LANG_ENGLISH} "ReadMe"
LangString ReadMe ${LANG_FRENCH} "LisezMoi"

Section $(Sec1Name)

  SectionIn RO

  ; d�sinstallation SC1
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "DisplayName"
  StrCmp $0 "SuperCopier"  0 SC1NotInstalled
    MessageBox MB_YESNO $(UninstSC1) IDYES UninstSC1
      MessageBox MB_YESNO $(UninstSC1Confirm) IDYES SC1NotInstalled
      Quit
    UninstSC1:
      ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "UninstallString"
      Exec $0
  SC1NotInstalled:

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Put file there
  File ..\compil\SuperCopier2.exe
  File ..\compil\SC2Config.exe
  File ..\compil\SC2Hook.dll
  File ..\compil\ReadMe.txt

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier2" "DisplayName" "SuperCopier2"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier2" "UninstallString" '"$INSTDIR\SC2Uninst.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier2" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier2" "NoRepair" 1
  WriteUninstaller "SC2Uninst.exe"

SectionEnd ; end the section

Section $(Sec2Name)
  Delete "$SMPROGRAMS\SuperCopier\*.*"

  CreateDirectory "$SMPROGRAMS\SuperCopier2"

  CreateShortCut "$SMPROGRAMS\SuperCopier2\SuperCopier2.lnk" "$INSTDIR\SuperCopier2.exe" "" "$INSTDIR\SuperCopier2.exe" 0

  CreateShortCut "$SMPROGRAMS\SuperCopier2\$(MenuAccess).lnk" "$INSTDIR\SC2Config.exe" "" "$INSTDIR\SC2Config.exe" 0

  CreateShortCut "$SMPROGRAMS\SuperCopier2\$(ReadMe).lnk" "$INSTDIR\readme.txt" "" "$INSTDIR\readme.txt" 0
  CreateShortCut "$SMPROGRAMS\SuperCopier2\$(UninstSC2).lnk" "$INSTDIR\SC2Uninst.exe" "" "$INSTDIR\SC2Uninst.exe" 0
SectionEnd ; end the section

Section $(Sec3Name)
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "SuperCopier2.exe" "$INSTDIR\SuperCopier2.exe"
SectionEnd ; end the section

Section $(Sec4Name)
  StrCpy $9 "exec"
SectionEnd ; end the section

Section $(Sec5Name)
  StrCpy $8 "readme"
SectionEnd ; end the section

Section "Uninstall"

  FindWindow $R0 "" "SuperCopier2 MainForm"
  IntCmp $R0 0 NotLaunched2
  SendMessage $R0 16 0 0  ; WM_CLOSE

  CloseLoop:
    Sleep 200
    FindWindow $R0 "" "SuperCopier2 MainForm"
    IntCmp $R0 0 NotLaunched2
    DetailPrint "Waiting SC2 Close..."
    GoTo CloseLoop

  NotLaunched2:


  ; Remove registry keys
  DeleteRegKey HKCU "Software\SFX TEAM\SuperCopier2"
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "SuperCopier2.exe"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier2"

  ; Remove files and uninstaller
  Delete $INSTDIR\SuperCopier2.exe
  Delete $INSTDIR\SC2Config.exe
  Delete $INSTDIR\SC2Hook.dll
  Delete $INSTDIR\readme.txt
  Delete $INSTDIR\SC2Uninst.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\SuperCopier2\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\SuperCopier2"
  RMDir "$INSTDIR"

SectionEnd

Function .onInit

	;Language selection dialog

	Push ""
	Push ${LANG_ENGLISH}
	Push English
	Push ${LANG_FRENCH}
	Push Fran�ais
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain

  IfSilent NoLang

	LangDLL::LangDialog "Installer Language" "Please select the language of the installer"

 	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort

	NoLang:
	
  ; fermeture de supercopier 1 & 2

  FindWindow $R0 "" "SCHiddenFormStarted"
  IntCmp $R0 0 NotLaunched1
  SendMessage $R0 16 0 0  ; WM_CLOSE
  NotLaunched1:

  FindWindow $R0 "" "SuperCopier2 MainForm"
  IntCmp $R0 0 NotLaunched2
  SendMessage $R0 16 0 0  ; WM_CLOSE
  NotLaunched2:


FunctionEnd

Function .onInstSuccess
  ; lancement

  IfSilent NoLaunch

  StrCmp $9 "exec" Good NoGood
  Good:
      Exec $INSTDIR\SuperCopier2.exe
  NoGood:

  StrCmp $8 "readme" Good2 NoGood2
  Good2:
    ExecShell open $INSTDIR\readme.txt
  NoGood2:

  NoLaunch:

FunctionEnd
