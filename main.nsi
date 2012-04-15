!include MUI2.nsh

# Define global variables here
Var progName	# this must be initialised in .onInit()
Var sysReqMsg
Var javaHome
Var javaVer
Var javaVerStr
Var javaInstallationMsg
Var startMenuFolder

Name $progName
OutFile "WebSYNCClient-2_1_0.exe"

#XPStyle on

# Define constants here
!define GET_JAVA_URL "http://www.java.sun.com/"
!define MIN_JRE_VER 16
!define MIN_JRE_VER_STR "1.6"

# General installer settings
InstallDir "$PROGRAMFILES\WebSYNCClient\"

# Define general page settings (not MUI specific)
BrandingText "$progName Setup"

# Define general page settings (MUI specific)
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "J:\NSIS\test\test2\websync.bmp"
!define MUI_ABORTWARNING

# Define settings for the welcome page
!define MUI_WELCOMEPAGE_TITLE "$progName Setup"
!define MUI_WELCOMEPAGE_TEXT "This setup program will now install WebSYNC on your computer."

# Define settings for the licence page
!define MUI_LICENSEPAGE_TEXT_TOP "Please review the licence agreement carefully, detailed below:"
!define MUI_LICENSEPAGE_TEXT_BOTTOM "You must accept the licence agreement in order to install WebSYNC."
!define MUI_LICENSEPAGE_RADIOBUTTONS

# Define settings for the start menu page
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\$progName" 
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

# Define settings for the finish page
!define MUI_FINISHPAGE_TITLE "WebSYNC Setup Complete!"
!define MUI_FINISHPAGE_TEXT "$progName has been installed on your computer successfully!"
!define MUI_FINISHPAGE_BUTTON "Finish"
#!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View setup instructions online (strongly recommended)"
!define MUI_FINISHPAGE_SHOWREADME "http://www.knowledge.net.nz/websync/setup.php"
#!define MUI_FINISHPAGE_RUN '$javaHome\bin\javaw.exe -Dnz.dataview.websyncclientgui.sysconf_file="$INSTDIR\config\system.properties" -jar "$INSTDIR\gui\WebSYNCClientGUI.jar"'
!define MUI_FINISHPAGE_RUN_TEXT "Run WebSYNC"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_LINK "KnowledgeNET Home"
!define MUI_FINISHPAGE_LINK_LOCATION "http://www.knowledge.net.nz/"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

# Define settings for the uninstaller confirm page
!define MUI_UNCONFIRMPAGE_TEXT "WebSYNC Uninstallation"

# Define pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE licence.txt
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU "Application" $startMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

# Define languages
!insertmacro MUI_LANGUAGE "English"

# Check for Java version and location.  Stores result message
# in $javaInstallationMsg and pushes 1 into the stack if JRE version is correct.
Function locateJVM    
    Push $0
    Push $1
    
    ReadRegStr $javaVerStr HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" CurrentVersion
	StrCpy $javaVer $javaVerStr
    StrCmp "" "$javaVer" JavaNotPresent CheckJavaVer
 
    JavaNotPresent:
        StrCpy $javaInstallationMsg "Java Runtime Environment is not installed on your computer. You need version ${MIN_JRE_VER_STR} or later to run WebSYNC."
#        Goto Done
 
    CheckJavaVer:
        ReadRegStr $0 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$javaVer" JavaHome
        GetFullPathName /SHORT $javaHome "$0"
        StrCpy $0 $javaVer 1 0
        StrCpy $1 $javaVer 1 2
        StrCpy $javaVer "$0$1"
        IntCmp ${MIN_JRE_VER} $javaVer FoundCorrectJavaVer FoundCorrectJavaVer JavaVerNotCorrect
        
    FoundCorrectJavaVer:
        IfFileExists "$javaHome\bin\javaw.exe" 0 JavaNotPresent
		StrCpy $R0 1
        Goto Done
        
    JavaVerNotCorrect:
        StrCpy $javaInstallationMsg "The version of Java Runtime Environment installed on your computer is $javaVerStr. Version ${MIN_JRE_VER_STR} or newer is required to run WebSYNC."
        
    Done:
        Pop $1
        Pop $0
		Push $R0
FunctionEnd

# Check system requirements.  Will abort if reqs not met.
Function checkSysReq
	Push $0
	
	# Check if we are administrator
    userInfo::getAccountType
    pop $0
    strCmp $0 "Admin" ifAdmin ifAdminFailed
	
	ifAdminFailed:
		StrCpy $sysReqMsg "You must be logged in with Administrator privileges to install WebSYNC"
		Goto ifFailed
	
	ifAdmin:
		# Check if we have JRE 1.6 or later installed
		Call locateJVM
		Pop $0
		IntCmp $0 1 ifOk ifJREFailed ifJREFailed
	
	ifJREFailed:
		StrCpy $sysReqMsg $javaInstallationMsg
		Goto ifFailed
		
	ifOk:
		;MessageBox MB_OK|MB_ICONINFORMATION "System requirements met"
		Goto done
	
	ifFailed:
		MessageBox MB_OK|MB_ICONSTOP "Failed to meet system requirements ($sysReqMsg), exiting Setup"
		Abort
		
	done:
		Pop $0
FunctionEnd

# Make sure system meets requirements before starting.
Function .onInit
	StrCpy $progName "Dataview WebSYNC"
	Call checkSysReq
FunctionEnd 

Function un.onInit
	StrCpy $progName "Dataview WebSYNC"
FunctionEnd
 
 # ====================================================
 # Safe uninstall script components follow.
 # See: http://nsis.sourceforge.net/Uninstall_only_installed_files
 # ==================================================== 
 
!define UninstLog "uninstall.log"
Var UninstLog
 
; Uninstall log file missing.
LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"
 
; AddItem macro
!macro AddItem Path
 FileWrite $UninstLog "${Path}$\r$\n"
!macroend
!define AddItem "!insertmacro AddItem"
 
; File macro
!macro File FilePath FileName
 IfFileExists "$OUTDIR\${FileName}" +2
  FileWrite $UninstLog "$OUTDIR\${FileName}$\r$\n"
 File "${FilePath}${FileName}"
!macroend
!define File "!insertmacro File"
 
; CreateDirectory macro
!macro CreateDirectory Path
 CreateDirectory "${Path}"
 FileWrite $UninstLog "${Path}$\r$\n"
!macroend
!define CreateDirectory "!insertmacro CreateDirectory"
 
; SetOutPath macro
!macro SetOutPath Path
 SetOutPath "${Path}"
 FileWrite $UninstLog "${Path}$\r$\n"
!macroend
!define SetOutPath "!insertmacro SetOutPath"
 
; WriteUninstaller macro
!macro WriteUninstaller Path
 WriteUninstaller "${Path}"
 FileWrite $UninstLog "${Path}$\r$\n"
!macroend
!define WriteUninstaller "!insertmacro WriteUninstaller"
 
Section -openlogfile
 CreateDirectory "$INSTDIR"
 IfFileExists "$INSTDIR\${UninstLog}" +3
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" w
 Goto +4
  SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" a
  FileSeek $UninstLog 0 END
SectionEnd 
 
 # ====================================================
 # end safe uninstall script components
 # ====================================================

 # Default section.
Section

	AddSize 500
	
	DetailPrint "Initialising installation directory..."
	${SetOutPath} $INSTDIR
	
	${CreateDirectory} "$INSTDIR\logs"
#Allow all users access to write to the logs folder. S-1-5-32-545 is the SID for "All Users"
	AccessControl::GrantOnFile "$INSTDIR\logs" "(S-1-5-32-545)" "GenericRead + GenericWrite + DeleteChild"
	Pop $R0
  ${If} $R0 == error
    Pop $R0
    DetailPrint `AccessControl error: $R0`
  ${EndIf}
  
	${File} "" "Configure.class"
	${File} "" "shortcut.ico"
	#${File} "" "start.bat"
	#${File} "" "stop.bat"
	
	# Create uninstaller
	DetailPrint "Creating uninstaller..."
	${WriteUninstaller} "$INSTDIR\Uninstall.exe"

SectionEnd

# Install the service.
Section "WebSYNCService"

	AddSize 2376
	
	DetailPrint "Copying service binaries..."
	SetOutPath $INSTDIR
	
	# Would be nice if this worked, but it doesn't
	#${File} "service_container\" "*"
	
	# We gotsta do them all manually
	${SetOutPath} "$INSTDIR\service"
	${File} "service_container\service\" "WebSYNCClient.jar"
	${File} "service_container\service\" "all.policy"
	${SetOutPath} "$INSTDIR\config"
	${File} "service_container\config\" "logger.properties"
	${File} "service_container\config\" "system.properties"
	SetOverwrite off
	${File} "service_container\config\" "websyncclient.properties"
	SetOverwrite on
	${SetOutPath} "$INSTDIR\service\lib"
	${FILE} "service_container\service\lib\" "activation.jar"
	${FILE} "service_container\service\lib\" "axis.jar"
	${FILE} "service_container\service\lib\" "commons-discovery-0.2.jar"
	${FILE} "service_container\service\lib\" "commons-logging-1.0.4.jar"
	${FILE} "service_container\service\lib\" "commons-io-1.4.jar"
	${FILE} "service_container\service\lib\" "jaxrpc.jar"
	${FILE} "service_container\service\lib\" "log4j-1.2.15.jar"
	${FILE} "service_container\service\lib\" "mail.jar"
	${FILE} "service_container\service\lib\" "mailapi.jar"
	${FILE} "service_container\service\lib\" "pop3.jar"
	${FILE} "service_container\service\lib\" "saaj.jar"
	${FILE} "service_container\service\lib\" "smtp.jar"
	${FILE} "service_container\service\lib\" "wrapper.jar"
	${FILE} "service_container\service\lib\" "wsdl4j-1.5.1.jar"
	${SetOutPath} "$INSTDIR\logs"
	${FILE} "" "main.log"
	${SetOutPath} "$INSTDIR\Control"
#Allow all users access to write to the control folder. S-1-5-32-545 is the SID for "All Users"
	AccessControl::GrantOnFile "$INSTDIR\Control" "(S-1-5-32-545)" "GenericRead + GenericWrite + DeleteChild"
	Pop $R0
  ${If} $R0 == error
    Pop $R0
    DetailPrint `AccessControl error: $R0`
  ${EndIf}
#Allow all users access to write to the config folder. S-1-5-32-545 is the SID for "All Users"
	AccessControl::GrantOnFile "$INSTDIR\config" "(S-1-5-32-545)" "GenericRead + GenericWrite + DeleteChild"
	Pop $R0
  ${If} $R0 == error
    Pop $R0
    DetailPrint `AccessControl error: $R0`
  ${EndIf}
  
SectionEnd

# Install the GUI.
Section "WebSYNCGUI"
	Push $0

	AddSize 1117
	
	DetailPrint "Copying GUI binaries..."
	SetOutPath $INSTDIR
	
	# Would be nice if this worked, but it doesn't
	#${File} "gui_container\" "*"
	
	# We gotsta do them all manually
	${SetOutPath} "$INSTDIR\gui"
	${File} "gui_container\gui\" "WebSYNCClientGUI.jar"
	${SetOutPath} "$INSTDIR\gui\lib"
	${File} "gui_container\gui\lib\" "appframework-1.0.3.jar"
	${File} "gui_container\gui\lib\" "swing-layout-1.0.4.jar"
	${File} "gui_container\gui\lib\" "swing-worker-1.1.jar"
	${File} "gui_container\gui\lib\" "wsci.jar"
	${File} "gui_container\gui\lib\" "commons-lang-2.5.jar"
	${File} "gui_container\gui\lib\" "commons-logging-1.0.4.jar"
	${File} "gui_container\gui\lib\" "commons-io-1.4.jar"
	${File} "gui_container\gui\lib\" "log4j-1.2.15.jar"
	${File} "gui_container\gui\lib\" "wsci.jar"
	${File} "gui_container\gui\lib\" "mail.jar"
	
	Pop $0
SectionEnd

# Install the Java Service Wrapper.
Section "Wrapper"
	Push $0

	AddSize 100
	
	DetailPrint "Copying wrapper binaries..."
	SetOutPath $INSTDIR
	
	# Would be nice if this worked, but it doesn't
	#${File} "wrapper_container\" "*"
	
	# We gotsta do them all manually
	${SetOutPath} "$INSTDIR\bin"
	${File} "wrapper_container\bin\" "InstallWebSYNCClient-NT.bat"
	${File} "wrapper_container\bin\" "UninstallWebSYNCClient-NT.bat"
	${File} "wrapper_container\bin\" "WebSYNCClient.bat"
	${File} "wrapper_container\bin\" "wrapper.exe"
	SetOutPath "$INSTDIR\config"
	${File} "wrapper_container\config\" "wrapper.conf"
	${SetOutPath} "$INSTDIR\lib"
	${File} "wrapper_container\lib\" "wrapper.dll"
	${File} "wrapper_container\lib\" "wrapper.jar"
	
	# Install as a service and start it
	#DetailPrint "Installing wrapper as a service..."
	#ExecWait '"$INSTDIR\bin\InstallWebSYNCClient-NT.bat"'

	#ExecShell "" "NET" "START WebSYNCClient"
	#Sleep 5000
	
	Pop $0	
SectionEnd

# Install the Windows NTEventLogger.
Section "EventLogger"

	AddSize 13
	
	DetailPrint "Copying NTEventLogger binary..."
	SetOutPath $SYSDIR
	${File} "" "NTEventLogAppender.dll"
# Some servers can't find it there, so put it locally as well...
	SetOutPath "$INSTDIR\lib"
	${File} "" "NTEventLogAppender.dll"
	
SectionEnd

# Finalise the install.
Section "Finalise"
	Push $0

	AddSize 50
	
	# Store installation folder into registry
	WriteRegStr HKCU "Software\$progName" "" $INSTDIR

	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application

	# Create shortcuts
	DetailPrint "Creating shortcuts..."
	${CreateDirectory} "$SMPROGRAMS\$startMenuFolder"
	#FileOpen $0 "$INSTDIR\monitor.bat" "w"
	#FileWrite $0 '$javaHome\bin\javaw.exe -Dnz.dataview.websyncclientgui.sysconf_file="$INSTDIR\config\system.properties" -jar "$INSTDIR\gui\WebSYNCClientGUI.jar"'
	#FileClose $0
	#${AddItem} "$INSTDIR\monitor.bat"
	CreateShortCut "$SMPROGRAMS\$startMenuFolder\WebSYNC Console.lnk" "$javaHome\bin\javaw.exe" '-Dnz.dataview.websyncclientgui.sysconf_file="$INSTDIR\config\system.properties" -jar "$INSTDIR\gui\WebSYNCClientGUI.jar"' "$INSTDIR\shortcut.ico" "" "" "" "Use this to monitor, view, and manage your WebSYNC service"
	${AddItem} "$SMPROGRAMS\$startMenuFolder\WebSYNC Console.lnk" 
	CreateShortCut "$SMPROGRAMS\$startMenuFolder\Start WebSYNC Service (run as administrator).lnk" "NET" "START WebSYNCClient" "$INSTDIR\shortcut.ico" "" "" "" "This will start your WebSYNC service in the background"
	${AddItem} "$SMPROGRAMS\$startMenuFolder\Start WebSYNC Service (run as administrator).lnk"
	CreateShortCut "$SMPROGRAMS\$startMenuFolder\Stop WebSYNC Service (run as administrator).lnk" "NET" "STOP WebSYNCClient" "$INSTDIR\shortcut.ico" "" "" "" "This will stop your WebSYNC service"
	${AddItem} "$SMPROGRAMS\$startMenuFolder\Stop WebSYNC Service (run as administrator).lnk"
	CreateShortCut "$SMPROGRAMS\$startMenuFolder\Uninstall WebSYNC.lnk" "$INSTDIR\Uninstall.exe"
	${AddItem} "$SMPROGRAMS\$startMenuFolder\Uninstall WebSYNC.lnk"
	${AddItem} "$SMPROGRAMS\$startMenuFolder"
	
	# Run the Configure program
	ExecShell "" "$javaHome\bin\java.exe" '-classpath "$INSTDIR" Configure "$INSTDIR"'
	Sleep 2000
	
	# Install as a service and start it
	DetailPrint "Installing wrapper as a service..."
	ExecWait '"$INSTDIR\bin\InstallWebSYNCClient-NT.bat"'

	# Don't start - it hasn't been configured, and will fail miserably
	#ExecShell "" "NET" "START WebSYNCClient"
	#Sleep 5000

	!insertmacro MUI_STARTMENU_WRITE_END
	
	Pop $0	
SectionEnd

 # ====================================================
 # Safe uninstall script components follow.
 # See: http://nsis.sourceforge.net/Uninstall_only_installed_files
 # ==================================================== 

Section -closelogfile
 FileClose $UninstLog
 SetFileAttributes "$INSTDIR\${UninstLog}" READONLY|SYSTEM|HIDDEN
SectionEnd
 
Section Uninstall
 
 ; Can't uninstall if uninstall log is missing!
 IfFileExists "$INSTDIR\${UninstLog}" +3
  MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
   Abort
 
 Push $R0
 Push $R1
 Push $R2
 Push $0
 
 # Stop and uninstall the service
 ExecShell "" "NET" "STOP WebSYNCClient"
 Sleep 6000
 
 ExecWait '"$INSTDIR\bin\UninstallWebSYNCClient-NT.bat"'
 Sleep 5000
 
 SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
 FileOpen $UninstLog "$INSTDIR\${UninstLog}" r
 StrCpy $R1 0
 
 GetLineCount:
  ClearErrors
   FileRead $UninstLog $R0
   IntOp $R1 $R1 + 1
   IfErrors 0 GetLineCount
 
 LoopRead:
  FileSeek $UninstLog 0 SET
  StrCpy $R2 0
  FindLine:
   FileRead $UninstLog $R0
   IntOp $R2 $R2 + 1
   StrCmp $R1 $R2 0 FindLine
 
   StrCpy $R0 $R0 -2
   IfFileExists "$R0\*.*" 0 +3
    RMDir $R0  #is dir
   Goto +3
   IfFileExists $R0 0 +2
    Delete $R0 #is file
 
  IntOp $R1 $R1 - 1
  StrCmp $R1 0 LoopDone
  Goto LoopRead
 LoopDone:
 FileClose $UninstLog
 Delete "$INSTDIR\${UninstLog}"
 RMDir "$INSTDIR"
 
 DeleteRegKey HKCU "Software\$progName"
 
 Pop $0
 Pop $R2
 Pop $R1
 Pop $R0
SectionEnd

 # ====================================================
 # end safe uninstall script components
 # ====================================================
