	/*
		Preliminaries:
		
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
	*/
	#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
	#SingleInstance,Force
	;#Persistent
	;#Warn All, Off
	;#Warn  ; Enable warnings to assist with detecting common errors.
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	DetectHiddenWindows, Off ; needs to be off so we don't close invisible windows by accident, and only restrict ourselves to the visible ones
	;SetKeyDelay -1
	SetBatchLines -1
	SetTitleMatchMode, 2
	; ntfy:=Notify()
	;;_____________________________________________________________________________________
	;{#[General Information for file management]
	SplitPath, A_ScriptName,,,, A_ScriptNameNoExt
	VNpublic=1.5.0.4
	VN=VNpublic
	VNdev=1.5.0.4                                                                    
	LE=10.11.2021 13:19:42                                                       
	AU=Gewerd Strauss
	;}______________________________________________________________________________________
	;{#[]
	Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,110 			;; Set custom Script icon
	global bIsDevPC:=(A_ComputerName="DESKTOP-FH4RU5C"?1:0) + 0 	;; overwrite this line to true if you want to be able to break out of locking yourself out.
																	;; that is the only actually functional addition this flag yields, aside from a few coded-in debug infos about some arrays.
	
	global bLockOutAdmin:=true + 0									;; global override for disabling locked guis being actually locked if used on the developer's PC. Semi-hardcoded because the 
																	;; second check refers to the computername, and it is unlikely you'll have the same. Obviously, if you are up to changing this 
																	;; value also nothing stops you from changing the respective hard-coded comparison. 
	
	global bIsExitWOSaving:=false 									;; necessary for 
	
	if ((!bIsDevPC && !Winactive("Visual Studio Code")) || (bIsDevPC && bLockOutAdmin && !Winactive("Visual Studio Code")))
		Menu, Tray, NoStandard
	;}______________________________________________________________________________________
	;{#[Autorun Section] - variable-setup
	/*
		For the love of god, don't edit anything in this section.
	*/
	if WinActive("Visual Studio Code")	; if run in vscode, deactivate notify-messages to avoid crashing the program.
		global bRunNotify:=!vsdb:=1
	else
		global bRunNotify:=!vsdb:=0
	;; If you are debugging this script and the notify-messages keep crashing the debugger when they are still visible and the debugger runs into a breakpoint, activate the following line:
	;bRunNotify:=!vsdb:=true
	bEnableAdvancedSettings:=false + 0 ; start with advanced settings being locked
	global testFlag:=dbFlag:=false + 0
	bLastSessionSettingsNoStringsInArrays:=false + 0
	bIsLocked:=false + 0
	bRestoreLastSession:=false + 0
	bGuiHasBeenResized:=false + 0
	bShowDebugPanelINMenuBar:=false + 0
	if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
		CodeTimer()
	IniSettingsFilePath:=A_ScriptDir . "\DistractLess_Storage\INI-Files\DistractLessSettings.Ini"
	if !Instr(FileExist(A_ScriptDir "\DistractLess_Storage"),"D") ; check if folder structure exists
		FileCreateDir, % A_ScriptDir "\DistractLess_Storage"
	if !Instr(FileExist(A_ScriptDir "\DistractLess_Storage\INI-Files"),"D") ; check if folder structure exists
		FileCreateDir, % A_ScriptDir "\DistractLess_Storage\INI-Files"
		DefSettings=
	(
	[General Settings]
;General Settings General Settings for DistractLess
RefreshTime=200
;RefreshTime Set time in milliseconds until the current window is matched against the set whitelist and/or blacklist. Lower values mean more immediate closing of blocked windows, higher values reduce the frequency of checks.
;RefreshTime Type: Integer 
;RefreshTime Default: 200
LockingBehaviour=Time-protected
;LockingBehaviour set wether or not to lock until
;LockingBehaviour - time has passed
;LockingBehaviour - or until the correct password is inputted
;LockingBehaviour Type: DropDown Password-protected|Time-protected||
;LockingBehaviour Default: Time-protected
LockingDefaultOffsetHours=3
;LockingDefaultOffsetHours Set the number of hours used when calculating the default unlocking time when locking the program for a set time.
;LockingDefaultOffsetHours Value in hours.
;LockingDefaultOffsetHours Type: Integer 
;LockingDefaultOffsetHours Default: 3
bAlwaysAskPW=0
;bAlwaysAskPW When checked, the gui is always locked (equivalent to left-clicking the padlock-icon on the main GUI window), and a password is checked.
;bAlwaysAskPW Type: Checkbox 
;bAlwaysAskPW Default: 0
;bAlwaysAskPW CheckboxName: Do you want to always lock the GUI?
OnExitBehaviour=Restart with specific bundle
;OnExitBehaviour Decide what to do when the script is manually closed by any means, except for shutting down, logging off or restarting the PC.
;OnExitBehaviour Changes in this setting only take effect after restarting the program once.
;OnExitBehaviour Restart with current bundle:
;OnExitBehaviour the currently active and stored Blacklists and Whitelists, as well as the currently active Filter-mode and Trumping-rule are stored and reloaded when script is closed. This prevents the script from being closed by hand.
;OnExitBehaviour Empty Restart:
;OnExitBehaviour Program is restarted without reloading the current session.
;OnExitBehaviour Nothing:
;OnExitBehaviour Script exits normally, without restarting at all.
;OnExitBehaviour Restart with specific bundle:
;OnExitBehaviour Restart with a specific bundle by default. Bundle must be specified under "sDefaultBundle",
;OnExitBehaviour Type: DropDown Nothing||Restart with current bundle|Empty Restart|Restart with specific bundle
;OnExitBehaviour Default: Restart with specific bundle
sDefaultBundle=
;sDefaultBundle Only takes effect if OnExitBehaviour is set to "Restart with specific bundle". Select a bundle to be always loaded on startup. Note that this setting also applies to indirect restarts - and hence this bundle will be loaded even if another one was active before the user attempted to close the program.
;sDefaultBundle Type: File 
EnableDiagnosticMode=0
;EnableDiagnosticMode Enable Diagnostics-mode for the Closing-function. This results in: CLOSING WINDOWS: more information about matching criteria being displayed, instead of closing the window/tab outright.
;EnableDiagnosticMode DoubleClick the fifth part of the statusbar of the main gui to enable and disable diagnostic mode quickly.
;EnableDiagnosticMode Type: Checkbox 
;EnableDiagnosticMode Default: 0
;EnableDiagnosticMode CheckboxName: Do you want to enable diagnostics mode?
bAllowWhiteOnly=0
;bAllowWhiteOnly Allows the script to run only allowing white-listed windows.
;bAllowWhiteOnly Note that this is _very_ restrictive, and if not done with great care, will close just about everything you have.
;bAllowWhiteOnly Make sure you prepare and test your whitelist in this mode using by enabling the diagnostics mode before employing it.
;bAllowWhiteOnly Type: Checkbox 
;bAllowWhiteOnly Default: 0
;bAllowWhiteOnly CheckboxName: Do you want to allow white-list-only mode?
bEnableBlockingBanner=0
;bEnableBlockingBanner If checked, the closing function will briefly flash a notification when temporarily disabling all keyboard and mouse input. Another message is sent when keyboard and mouse inputs are restored.
;bEnableBlockingBanner If not checked, the kbm will be silently blocked and unblocked.
;bEnableBlockingBanner Type: Checkbox 
;bEnableBlockingBanner Default: 0
;bEnableBlockingBanner CheckboxName: Do you want to enable the banner informing you that the keyboard/mouse is locked?
BrowserClasses=MozillaWindowClass,Chrome_WidgetWin_1,Chrome_WidgetWin_2,OpWindow,IEFrame
;BrowserClasses Comma-separated list of ahk_classes which are considered to represent web browsers for the sake of closing only the active tab via Ctrl-W, as opposed to Alt+F4.
;BrowserClasses The ahk_exe of the browser needs to be added to BrowserExes as well for DistractLess to identify the browser correctly. This is necessary as there are _way_ too many programs built on chrome's framework, but we don't want those to count as browsers.
;BrowserClasses (Looking at you, Spotify)
;BrowserClasses Type: Text 
;BrowserClasses Default: MozillaWindowClass,Chrome_WidgetWin_1,Chrome_WidgetWin_2,OpWindow,IEFrame
BrowserExes=firefox.exe,chrome.exe,iexplore.exe,opera.exe
;BrowserExes Comma-separated list of ahk_exes which are considered to represent web browsers for the sake of closing only the active tab via Ctrl-W, as opposed to Alt+F4.
;BrowserExes The ahk_class of the browser needs to be added to BrowserClasses as well for DistractLess to identify the browser correctly. This is necessary as there are _way_ too many programs built on chrome's framework, but we don't want those to count as browsers.
;BrowserExes (Looking at you, Spotify)
;BrowserExes Type: Text 
;BrowserExes Default: firefox.exe,chrome.exe,iexplore.exe,opera.exe,msedge.exe 
BrowserNewTabs=-1
;BrowserNewTabs Comma-separated list of new-tab names for each browser you are using
;BrowserNewTabs Because this is different depending on language, and it is more or less impossible for me to provide a full-coverage list here now, this must be manually created by the user.
;BrowserNewTabs To do so, please replace the "-1" by the names of the new tab in your respective browser(s).
;BrowserNewTabs Type: Text 
bLVDelete_RequireConfirmation=0
;bLVDelete_RequireConfirmation If  checked, any action removing items from a listview requires specific confirmation.
;bLVDelete_RequireConfirmation If unchecked, this double-check is skipped. Items can still be restored as usual.
;bLVDelete_RequireConfirmation Type: Checkbox 
;bLVDelete_RequireConfirmation Default: 0
;bLVDelete_RequireConfirmation CheckboxName: Do you want an extra dialogue to confirm when removing items from listviews?
bStartup=0
;bStartup Create shortcut (lnk) in the startup folder for DistractLess to start automatically
;bStartup 0=No
;bStartup 1=Yes
;bStartup Type: Checkbox 
;bStartup Default: 0
;bStartup CheckboxName: Do you want to add this script to start at system bootup?
sLocationUserBackup=DistractLess_Storage\UserBackups
;sLocationUserBackup Set time in milliseconds until the current window is matched against the set whitelist and/or blacklist. Lower values mean more immediate closing of blocked windows, higher values reduce the frequency of checks.
;sLocationUserBackup Choose the folder to store custom lists in via the "Save LV's"-button.
;sLocationUserBackup Type: Folder 
;sLocationUserBackup Default: DistractLess_Storage\UserBackups
sFontSize_Text=7
;sFontSize_Text Set font-size for the following controls:
;sFontSize_Text * Text
;sFontSize_Text * Edit-fields
;sFontSize_Text * Sliders
;sFontSize_Text Type: DropDown 7||8|9|10|11|12
;sFontSize_Text Default: 7
;sFontSize_Text CheckboxName: Do you want to allow locking of the entire gui?
sFontType_Text=Times New Roman
;sFontType_Text Set Font for all texts, excluding the listviews.
;sFontType_Text Type: DropDown Arial|Calibri|Cambria|Consolas|Comic Sans MS|Corbel|Courier|Courier New|Georgia|Lucidia Console|Lucidia Sans|MS Sans Serif|Segoe UI||Times New Roman|Tahoma|Verdana|System
;sFontType_Text Default: Times New Roman
sFontSize_ListView=7
;sFontSize_ListView Set font-size for the following controls:
;sFontSize_ListView * ListViews
;sFontSize_ListView Type: DropDown 5|6|7||8|9|
;sFontSize_ListView Default: 7
sFontType_Listview=Segoe UI
;sFontType_Listview Set Font for all listviews
;sFontType_Listview Type: DropDown Arial|Calibri|Cambria|Consolas|Comic Sans MS|Corbel|Courier|Courier New|Georgia|Lucidia Console|Lucidia Sans|MS Sans Serif|Segoe UI||Times New Roman|Tahoma|Verdana|System
;sFontType_Listview Default: Segoe UI
bWarningOnFileLoadSettingChanges=1
;bWarningOnFileLoadSettingChanges Decide wether or not you want to be warned whenever the loading of a stores set of conditions changes the active Filtermode or the active trumping rules. Recommended to be kept on for inexperienced users who are not yet fully aware of the intricacies of how conditions work together.
;bWarningOnFileLoadSettingChanges Type: Checkbox
;bWarningOnFileLoadSettingChanges Default: 1
;bWarningOnFileLoadSettingChanges CheckboxName: Do you want to be warned if Filtermode/trumpingrules changed when loading new conditions?
bShowOnProgramStart=1
;bShowOnProgramStart Decide wether or not to show the GUI when the program has finished its start-routine. Does not affect silent restarts if closed prematurely (cf. OnExitBehaviour)
;bShowOnProgramStart This has no effect if no set of conditions is loaded. I.e. if "OnExitBehaviour" is set to "Empty", the GUI will never be shown.
;bShowOnProgramStart Type: Checkbox 
;bShowOnProgramStart Default: 1
;bShowOnProgramStart CheckboxName: Do you want to show the GUI after the program has finished its start-routine?
[Invisible Settings]
;Invisible Settings Type: Text
;Invisible Settings Hidden:
bAllowLocking=1
;bAllowLocking Allows the gui to be locked from further access until the time specified in has passed, or the password is entered correctly (depending on the mode)
;bAllowLocking Note that if this setting is deactivated, the GUI cannot be locked anymore.
;bAllowLocking Type: Checkbox 
;bAllowLocking Default: 1
;bAllowLocking CheckboxName: Do you want to allow locking of the entire gui?
;bAllowLocking
bEditDirectStringIn_f_EditArrayElement=0
;bEditDirectStringIn_f_EditArrayElement If checked, the entries are displayed as the strings they are saved as, and not chopped up. In that way, more finely tuned edits can be made (such as moving a condition from being program-only to website-only, or moving it to the other list)
;bEditDirectStringIn_f_EditArrayElement Type: Checkbox
;bEditDirectStringIn_f_EditArrayElement Default: 0
;bEditDirectStringIn_f_EditArrayElement CheckboxName: Do you want to edit the raw information string when editing an entry?
NoFilterClasses=TaskManagerWindow,#32770,AutoHotkeyGui,MultitaskingViewFrame,
;NoFilterClasses Comma-separated list of ahk_classes which are not filtered, ever. Mostly hard-coded precautions to protect important programs/windows
;NoFilterClasses Type: Text 
;NoFilterClasses Default: TaskManagerWindow,#32770,AutoHotkeyGui,MultitaskingViewFrame,
NoFilterExes=Code.exe,Taskmgr.exe,Autohotkey.exe
;NoFilterExes Comma-separated list of ahk_exes which are not filtered, ever. Mostly hard-coded precautions to protect important programs/windows
;NoFilterExes Type: Text 
;NoFilterExes Default: Code.exe,Taskmgr.exe,Autohotkey.exe
NoFilterTitles=DistractLess_1,DistractLess_2,DistractLess_3,DistractLess_4,DistractLess Settings,IniFileCreator,DistracLess_2
;NoFilterTitles Comma-separated list of window Titles which are not filtered, ever. Mostly hard-coded precautions to protect this program and its vital submenus.
;NoFilterTitles Type: Text 
;NoFilterTitles Default: DistractLess_1,DistractLess_2,DistractLess_3,DistractLess_4,DistractLess_5,DistractLess Settings,IniFileCreator,DistracLess_2
sUnlockPassword=-1
;sUnlockPassword Password chosen by the user to unlock the gui again, if LockingBehaviour is set to "Password-protected"
;sUnlockPassword Type: Text
)
	if FileExist("errorlog.txt") ; make sure the errorlog doesn't grow exponentially on someones system. Realistically, as it is a plain text file, and only the newest errors should be tracked anyways, resetting at 30  
	{
		FileGetSize, vErrorlogSize,errorlog.txt, M
		if vErrorlogSize>30
			FileDelete, errorlog.txt
	}
	if !FileExist(IniSettingsFilePath)
	{
		; m("figure out how to write a continuation section to file successfully")
		f_ThrowError("Main Code Body","Settings file does not exist, initiating from default settings. ", A_ScriptNameNoExt . "_"0, Exception("",-1).Line)
		FileAppend, %DefSettings%, %A_ScriptDir%\DistractLess_Storage\INI-Files\DistractLessSettings.ini
	}
	else ;; fix faulty lines that can be created when the IniSettingsEditor fucks up the descriptions suddenly. Hotfix that is used at startup to ensure that at least the starting descriptions are correct.
	{
		FixedDescriptionFile:=f_FixInfoTextLinesInIniFile(DefSettings,IniSettingsFilePath)
		str:=""
		for k,v in FixedDescriptionFile[1]
		{
			if v!=""
				str.=v "`n"
		}
		FixedIniFile:=FileOpen(IniSettingsFilePath,"w")
		FixedIniFile.write(str)
		FixedIniFile.close() ; all part of precaution to prevent faulty setting descriptions being saved between restarts. This is a hotfix that has, as far as I can tell, resolved the issue for my instance of IniSettingsEditor, because necessary edits might have added some, for me unfixable bugs. I just don't understand the source-code to the level of detail necessary to resolve it. This section resolves that issue with a once/run rewrite of the settings-file.
	}
	NotifyTrayClick(DllCall("GetDoubleClickTime")) ; Handle double left click on tray events and prevent them to open the script history
	OnMessage(0x404, "f_TrayIconSingleClickCallBack")
	gosub, lLoadSettingsFromIniFile
	if (IniOBj["General Settings"].BrowserNewTabs=-1) ; initialising for first time, notify user to edit this.
	{
		m("First initialisation.`n`nPlease choose the setting 'BrowserNewTabs' in the upcoming  settings-window and follow the instructions.")
		Clipboard:="Mozilla Firefox,Neuer Tab - Google Chrome,Neue Registerkarte - Internet Explorer,Neuer Tab" ; laziness on my end, as I often need to rewrite my settings-file when testing, and don't want to search out all titles again.
		gosub, lLaunchWindowSpy
		DL_IniSettingsEditor("DistractLess",IniSettingsFilePath,0,0,0)
		gosub, lLoadSettingsFromIniFile
		if (IniOBj["General Settings"].BrowserNewTabs=-1) ; user has not changed this setting so far, don't start the programn
		{
			f_ThrowError("Main Code Body","Setting 'BrowserNewTabs' was not changed as assumed. Please edit this as explained in the  settings menu first. Otherwhise, this program cannot start working.`nExiting Program now.'", A_ScriptNameNoExt . "_"1, Exception("",-1).Line)
			ExitApp
		}
	}
	if !(IniObj["General Settings"].sLocationUserBackup="")
	{
		if !Instr(FileExist(IniObj["General Settings"].sLocationUserBackup),"D") ; check if folder exists
		{	; folder and file doesn't exist -> create
			; create file
			FileCreateDir, % IniObj["General Settings"].sLocationUserBackup
			; SetWorkingDir, UserBackups
		}
	}
	if (IniObj["Invisible Settings"].sUnlockPassword=-1) || (!IniObj["Invisible Settings"].sUnlockPassword)
	{
		InputBox, setPWstr  , Setup DistractLess, Please set password to be used when unlocking the GUI.`nNote that this cannot be changed within the program in a simple way afterwards.`nFor more information on how to change the password afterwards please check the documentation on GitHub.
		IniObj["Invisible Settings"].sUnlockPassword:=setPWstr
		
		DL_TF_ReplaceInLines("!D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\DistractLess_Storage\INI-Files\DistractLessSettings.ini",1,"","sUnlockPassword=-1","sUnlockPassword="setPWstr)
		;fWriteIni(IniObj,A_ScriptDir . "\DistractLess_Storage\INI-Files\DistractLessSettings")
		ttip("Line:" Exception("",-1).Line)
	}
	if (IniObj["General Settings"].OnExitBehaviour="Restart with current bundle")
		OnExit("f_RestartWithLastBundle")
	else if (IniObj["General Settings"].OnExitBehaviour="Empty Restart")
		OnExit("f_RestartEmpty")
	else if (IniObj["General Settings"].OnExitBehaviour="Restart with specific bundle")
		OnExit("f_RestartWithSpecificBundle")

	 OnError("LogError")
	cause := error

	;; as the bundle "CurrentSettings" is contains either the settings of last session (cf. f_RestartWithLasetBundle), or the contents of the file specified under sDefaultBundle (cf. f_RestartWithSpecificBundle 
	if (IniObj["General Settings"].OnExitBehaviour!="Nothing") && (IniObj["General Settings"].OnExitBehaviour!="Empty Restart")
	{
		if (IniObj["General Settings"].OnExitBehaviour="Restart with specific bundle") && (IniObj["General Settings"].sDefaultBundle!="") ; take the simpler version because the use is _starting_, not _restarting_. In this case, we don't assume to lock the gui anymore because it is the first startup of the day - due to the safety restarts in place, as soon as this program _is_ running, the safety-restart functions take responsibility to start with specifics. 
		{
			LastSessionSettings:=fReadINI(A_ScriptDir "\" IniObj["General Settings"].sDefaultBundle)
			
		}
		if FileExist(A_ScriptDir "\DistractLess_Storage\CurrentSettings.ini")  ;; only generated when OnExitBehaviour==Restart with current bundle, _or_ we have tried to end the program while it is running. As the file only exists in restart-scenarios or if we choose to "restart with last bundle", we have to check this _after_ we load the possible settings. 
		{
			LastSessionSettings:=fReadIni(A_ScriptDir . "\DistractLess_Storage\CurrentSettings.ini")
		}
		for k,v in LastSessionSettings[5]
			LastSessionSettings[5][k]:=StrSplit(v,A_Space ";").1
		bRestoreLastSession:=true
		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin)
			m("Rstored LastSessionSettings")
		FileDelete, %A_ScriptDir%\DistractLess_Storage\CurrentSettings.ini
		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin)
			m(LastSessionSettings[5])
	}
	f_CreateTrayMenu(IniObj)
	gui, font, %FONT_LV1% , %FONT_LV2%
	guicontrol, font, vLV1
	guicontrol, font, vLV2
	guicontrol, font, vLV3
	guicontrol, font, vLV4
	gui, font, %FONT_Text1% , %FONT_Text2%
	GUI, FONT

	gosub, lPrepareArrays

	sLastWindowTitle:="" ; init old window title
	vLastSliderPos_Slider_FilterMode:=2


	gosub, lGuiCreate_1
	; gosub, lGuiCreate_2 ; function gui
	gosub, lGuiCreate_3
	gosub, lGuiCreate_4
	if bRestoreLastSession
		gosub, lRestoreLastSession
	if bRestartLocked
	{
		bIsLocked:=true
		DefaultTime:=LastSessionSettings[5].5
		gosub, lLockProgram
	}
	Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime
	gosub, lUpdateStatusOnStatusBar
	if IniObj["General Settings"].bShowOnProgramStart ; && (!bRestoreLastSession)
	{
		hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
		if !bLastSessionSettingsNoStringsInArrays 
			gui, 1: show, w%vGUIWidth% h%vGUIHeight%, DistractLess_1
		Else
			if !vsdb
				Notify().AddWindow("Finished initialising.",{Title:"DistractLess",TitleColor:"0xFFFFFF",Time:1300,Color:"0xFFFFFF",Background:"0x000000",TitleSize:10,Size:10,ShowDelay:0,Radius:15, Flash:1000,FlashColor:0x5555})
			Else
				ttip("DistractLess:`nFinished initialising.",,2600)
	}
	else if !bRestoreLastSession and !vsdbdddd
		Notify().AddWindow("Finished initialising.",{Title:"DistractLess",TitleColor:"0xFFFFFF",Time:1300,Color:"0xFFFFFF",Background:"0x000000",TitleSize:10,Size:10,ShowDelay:0,Radius:15, Flash:1000,FlashColor:0x5555})
	if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
		m("bRestoreLastSession: " bRestoreLastSession,"vsdb: " vsdb , "I need to embed another setting into LastSessionSettings[5] to figure out in which case to display the startup notification, and in which we don't want to display it.","The logic is the following: because right now the current settings are always stored → there is always gonna be a lastSessionrestored now. " )

	SetWorkingDir, %A_ScriptDir%
	if ((StartTimer) and bIsDevPC and !bLockOutAdmin) 
		CodeTimer()
	return

	;}______________________________________________________________________________________
	;{#[Hotkeys Section]


	!-:: ;; global || open Gui 
	Gui1_ShowLogic:
	{
		Settimer, lEnforceRules, Off
		if bMainGuiDestroyed
		{
			gosub, lGUICreate_1
			bMainGuiDestroyed:=false
		}

		if !Winactive("DistractLess_1") 	;; if gui is closed → open
		{
			if (IniObj["General Settings"].LockingBehaviour="Password-protected")
			{
				if bIsLocked || IniObj["General Settings"].bAlwaysAskPW
					gosub, lGUIShow_4 ; if locked, show unlocking screen instead
				Else
					gosub, lGUIShow_1
			}
			else if (IniObj["General Settings"].LockingBehaviour="Time-protected")
			{
				if bIsLocked 				;; we have locked till time is up, so display time 
				{
					if (A_Now>=DefaultTime)
					{
						gosub, lLockProgram
						gosub, lGuiShow_1
					}
					else if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					{
						bIsLocked:=true
						gosub, lLockProgram
						gosub, lGuiShow_1
						WinWaitNotActive, DistractLess_1
						bIsLocked:=true
					}
					else
					{ 
						DisplayUnlockedTime:=DefaultTime
						if !vsdb
							Notify().AddWindow("DistractLess is locked till " Substr(DisplayUnlockedTime,9,2) ":" Substr(DisplayUnlockedTime,11,2) ":" Substr(DisplayUnlockedTime,13,2),{Title:"",TitleColor:"0xFFFFFF",Time:1300,Color:"0xFFFFFF",Background:"0x000000",TitleSize:10,Size:10,ShowDelay:0,Radius:15, Flash:1000,FlashColor:0x5555})
						Else
							ttip("DistractLess is locked till " Substr(DisplayUnlockedTime,9,2) ":" Substr(DisplayUnlockedTime,11,2) ":" Substr(DisplayUnlockedTime,13,2),1,1300)
					}
					return
				}
				if bIsLocked || IniObj["General Settings"].bAlwaysAskPW
				{
					gosub, lGUIShow_4 		;; if locked, show unlocking screen instead
					WinWaitNotActive, DistractLess_4
				}
				Else
				{
					gosub, lGUIShow_1
					WinWaitNotActive, DistractLess_1
				}
			}
			Else
				f_ThrowError("Main Code Body","Setting 'LockingBehaviour', found in the settings under the same name under 'General Settings' contains a non-valid value. Please try and reset the setting via the settings-editor.`nIf that does not work, delete the ini-file located at`n" A_ScriptDir "\DistractLess_Storage\INI-Files\DistractLessSettings.ini`nand restart the program.",A_ScriptNameNoExt . "_"2,Exception("",-1).Line)
				
		}
		Else								;; if gui is open → close
		{
			gosub, lGuiHide_1
			Settimer, lEnforceRules, Off
			gosub, lClearAdditionFields
		}
		hk(0,0)
	}
	Return
	

	#IfWinActive DistractLess_1
	Sc029:: 									;; Gui1 || toggle Program On/Off
	; if bIsLocked ; block the user trying to disable the program when it is locked, can't believe this has still been active.
	; 	return
	GuiControlGet,CurrentState,, bIsProgramOn
	CurrentState:=CurrentState+0
	CurrentState:=!CurrentState
	GuiControl,,bIsProgramOn, %CurrentState%
	;GuiControl, Focus, 
	gosub, lCallBack_EnableProgram
	return
	!-:: 										;; Gui1 || open Gui
	gosub, Gui1_ShowLogic
	return
	Esc:: 										;; Gui1 ||  close Gui1
 	gosub, lGuiHide_1
	Settimer, lEnforceRules, Off
	gosub, lClearAdditionFields
	return
	+1:: 										;; Gui1 || focus on WhiteActive Listview
	GuiControl, focus, vLV1
	return
	+2:: 										;; Gui1 || focus on WhiteStorage Listview
	GuiControl, focus, vLV2
	return
	+3:: 										;; Gui1 || focus on BlackActive Listview
	GuiControl, focus, vLV3
	return
	+4:: 										;; Gui1 || focus on BlackActive Listview
	GuiControl, focus, vLV4
	return
	^L::										;; Gui1 || open locking prompt
	if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
		ttip("line 451:`nbefore going into 'lLockProgram'-routine")
	if IniObj["Invisible Settings"].bAllowLocking
		gosub, lLockProgram
	return
	!T:: guicontrol, focus, bTrumping 			;; Gui1 || focus on Trumping DDL
	!F:: guicontrol, focus, vActiveFilterMode 	;; Gui1 || focus on Filtermode DDL
	^T:: gosub, lHotkey_ToggleTestmode 			;; Gui1 || enter/exit Testmode
	^O:: gosub, lOpenNormalSettings				;; Gui1 || open Settings
	^+O:: gosub, lOpenHiddenSettings			;; Gui1 || open Hidden Settings ← not sure if I want this to be a hotkey-able thing
	#If (bDistractLess_3IsVisible) || WinActive("DistractLess_3")
	Esc:: ;; Gui3 || close Gui3
	{
		Gui, 3: hide
		SetTimer, UpdateCriteriaPickerURL,off
		global bDistractLess_3IsVisible:=false
		ttip(,99)
		ttip("")
		gosub, lGUIShow_1
	}
	return
	^LButton:: ;; Gui3 ||  select current Window's information to be added to either blacklist or whitelist
	{
		gui, 3: Submit
		SetTimer, UpdateCriteriaPickerURL,off
		global bDistractLess_3IsVisible:=false
		ttip(,99)
		ttip("")
		gosub, lGUIShow_1
		if Instr(sCurrentWindowTitle_CriteriaPicker_New, "||")
			sCurrentWindowTitle_CriteriaPicker_New:=StrSplit(sCurrentWindowTitle_CriteriaPicker_New," || ").1
		guicontrol,,sCriteria_Substring, %sCurrentWindowTitle_CriteriaPicker_New%
		loop, 4 ;; for unknown reasons, sometimes controls don't get properly disabled/enabled/hidden/shown, even though the code is run according to the debugger. Simplest pseudo-fix is to just repeat this for a few times.
		{
			if (HasVal(BrowserClasses,sCurrentWindowClass_CriteriaPicker_New))  && (HasVal(BrowserExes,sCurrentWindowExe_CriteriaPicker))
			{
				guicontrol,,URLToCheckAgainst,%CurrentBrowserURL_CriteriaPicker%
				guicontrol,,URLToCheckAgainst,%CurrentBrowserURL_CriteriaPicker%
				guicontrol, enable, URLToCheckAgainst
				guicontrol, enable, TextURLAddition
				guicontrol, show, URLToCheckAgainst
				guicontrol, show, TextURLAddition
				guicontrol, ChooseString, TypeSelected, Website
			}
			else
			{
				guicontrol, disable, URLToCheckAgainst
				guicontrol, disable, TextURLAddition
				guicontrol, hide,URLToCheckAgainst
				guicontrol, hide, TextURLAddition
				guicontrol, ChooseString, TypeSelected, Program
			}
			guicontrol, enable, Button_AddSubsttringToActiveWhiteList
			guicontrol, enable, Button_AddSubsttringToActiveBlackList
		}
		SetTimer, lEnforceRules,On
	}
	return

	#IfWinActive DistractLess_3
	!e:: ;; Gui3 || close Gui3
	GC3Escape()
	gosub, lGUIShow_1
	return

	#IfWinActive, DistractLess_5
	Tab::SendInput,{Right} 	;; Gui5 || go to next digit of time edit
	+Tab::SendInput,{Left} 	;; Gui5 || go to previous digit of time edit
	^Enter::GC5_Submit() 	;; Gui5 || submit time

	#IfWinActive, DistracLess_2
	^Enter::GC2_Submit()  	;; Gui4 || submit changes
	
	
	#IF
	;}______________________________________________________________________________________
	;{#[Label Section]
	lRestoreLastSession:
	{
		gui, 1: default
		bRestoringLastSession:=true
		Count:=0
		if (LastSessionSettings[1].MaxIndex()!="")
			Count:=Count+ LastSessionSettings[1].MaxIndex()
		if (LastSessionSettings[2].MaxIndex()!="")
			Count:=Count+ LastSessionSettings[2].MaxIndex()
		if (LastSessionSettings[3].MaxIndex()!="")
			Count:=Count+ LastSessionSettings[3].MaxIndex()
		if (LastSessionSettings[4].MaxIndex()!="")
			Count:=Count+ LastSessionSettings[4].MaxIndex()

		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
			m("Count after checking all data arrays: " Count)
		if (!Count)
			bLastSessionSettingsNoStringsInArrays:=(Count?1:0) ; figure out if any data is present → if possible, and we are not in a silent restart, display message.
		if (LastSessionSettings[5].MaxIndex()!="")
		{
			Count:=Count+ LastSessionSettings[5].MaxIndex()
			bRestartLocked:=(LastSessionSettings[5].MaxIndex()=5?1:0)
		}
		ActiveArrays:=[[],[]]
		StoredArrays:=[[],[]]
		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
			m(LastSessionSettings[1].MaxIndex(),LastSessionSettings[2].MaxIndex(),LastSessionSettings[3].MaxIndex(),LastSessionSettings[4].MaxIndex())
		if (LastSessionSettings[1].MaxIndex()!="")
		{
			gui, listview, SysListView321
			f_UpdateLV(LastSessionSettings[1])
			ActiveArrays[1]:=LastSessionSettings[1].clone()
		}
		if (LastSessionSettings[2].MaxIndex()!="")
		{
			gui, listview, SysListView323
			f_UpdateLV(LastSessionSettings[2])
			ActiveArrays[2]:=LastSessionSettings[2].clone()
		}
		if (LastSessionSettings[3].MaxIndex()!="")
		{
			gui, listview, SysListView322
			f_UpdateLV(LastSessionSettings[3])
			StoredArrays[1]:=LastSessionSettings[3].clone()
		}
		if (LastSessionSettings[4].MaxIndex()!="")
		{
			gui, listview, SysListView324
			f_UpdateLV(LastSessionSettings[4])
			StoredArrays[2]:=LastSessionSettings[4].clone()
		}
		if (LastSessionSettings[1].MaxIndex()="") && (LastSessionSettings[2].MaxIndex()="") ;; we are initialising with empty arrays →
			ActiveArrays:=[[],[]]
		if (LastSessionSettings[3].MaxIndex()="") && (LastSessionSettings[4].MaxIndex()="") ;; we are initialising with empty arrays →
			StoredArrays:=[[],[]]
		if (LastSessionSettings[5].MaxIndex()!="")
		{
			vActiveFilterMode:=LastActiveFilterMode:=LastSessionSettings[5].1
			bTrumping:=LastTrumping:=LastSessionSettings[5].2
			bCheckURLsInBrowsers:=LastCheckURLsInBrowsers:=LastSessionSettings[5].3
			LastIsProgramOn:=LastSessionSettings[5].4
			guicontrol,ChooseString,vActiveFilterMode, %LastActiveFilterMode%
			guicontrol,ChooseString, bTrumping, %LastTrumping%
			guicontrol,ChooseString, bCheckURLsInBrowsers, %LastCheckURLsInBrowsers%
			guicontrol,, bIsProgramOn, %LastIsProgramOn% 
			bIsProgramOn:=bIsProgramOn + 0
		}
		; if !bRestoreLastSession
		
		
		
		gosub, lCallBack_DDL_FilterMode
		
		gosub, lCallBack_EnableProgram
		if IniObj["General Settings"].bShowOnProgramStart && (!bRestoreLastSession)
		{
			hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
			gui, 1: show, w%vGUIWidth% h%vGUIHeight%, DistractLess_1
		}
		; else
		; {
		; 	if !vsdb
		; 		Notify().AddWindow("Finished initialising.",{Title:"DistractLess",TitleColor:"0xFFFFFF",Time:1300,Color:"0xFFFFFF",Background:"0x000000",TitleSize:10,Size:10,ShowDelay:0,Radius:15, Flash:1000,FlashColor:0x5555})
		; 	Else
		; 		ttip("Finished initialising")
		; }
		bRestoringLastSession:=false
	}
	return
	lLoadSettingsFromIniFile: ; load all settings for the behaviour of this program. Invoked on setting-changes via the IniFileEditor, and auto-updates these settings.
	{
		global IniObj:=fReadIni(A_ScriptDir . "\DistractLess_Storage\INI-Files\DistractLessSettings.ini")
		global dbflag:=IniObj["General Settings"].EnableDiagnosticMode
 		
		f_ToggleStartup(IniOBj["General Settings"].bStartup)
		BrowserClasses:=StrSplit(IniObj["General Settings"].BrowserClasses, ",")
		BrowserExes:=StrSplit(IniObj["General Settings"].BrowserExes, ",")
		BrowserNewTabs:=StrSplit(IniObj["General Settings"].BrowserNewTabs, ",")
		NoFilterClasses:=StrSplit(IniObj["Invisible Settings"].NoFilterClasses, ",")
		NoFilterExes:=StrSplit(IniObj["Invisible Settings"].NoFilterExes, ",")
		NoFilterTitles:=StrSplit(IniObj["Invisible Settings"].NoFilterTitles, ",")
		FONT_Text:= % "s" . IniObj["General Settings"].sFontSize_Text " cWhite," . IniObj["General Settings"].sFontType_Text
		FONT_LV:= % "s" . IniObj["General Settings"].sFontSize_ListView " cWhite," . IniObj["General Settings"].sFontType_ListView
		FONT_LV1:=StrSplit(FONT_LV,",").1
		FONT_LV2:=StrSplit(FONT_LV,",").2
		FONT_Text1:=StrSplit(FONT_Text,",").1
		FONT_Text2:=StrSplit(FONT_Text,",").2
		fontb:="Segoe UI"
		gosub, lUpdateStatusOnStatusBar
	}
	Return

	lPrepareArrays:
	{
		aWhiteStor:=[]
		aBlackStor:=[]
		aWhiteAct:=[]
		aBlackAct:=[]
		ActiveArrays:=[[],[]]
		;ActiveArrays:=fCreateActiveArraysFromActiveWindows()
		; ActiveWhiteBackup:=[1]
		; ActiveBlackBackup:=[1]
		StoredWhiteBackUp:=0
		StoredBlacKBackup:=0
		StoredArrays:=[[],[]]
		aWhiteControls_ToDisable:=["vLV1","vLV2","btn1","btn2","btn3","btn4","btn5","btn6","btn7","Text_ActiveWhiteList","Text_StoredWhiteList"] ;,"Text_SelectTrumpingRule","bTrumping"]
		aBlackControls_ToDisable:=["vLV3","vLV4","btn8","btn9","btn10","btn11","btn12","btn13","btn14","Text_ActiveBlackList","Text_StoredBlackList"] ;,"Text_SelectTrumpingRule","bTrumping"]
		aAllControlsGui1_VisibleDefault:=["TextEnterSubstringCriteriaToAdd", "sCriteria_Substring", "TextSelectType", "TypeSelected",  "Button_AddSubsttringToActiveWhiteList", "Button_AddSubsttringToActiveBlackList", "Button_AddFromExistingWindows", "Button_SaveSelectedListViews", "Button_RestoreFromSave", "TextHorizontalLine", "TextSelectFilterMode", "vActiveFilterMode", "Text_SelectTrumpingRule", "bTrumping","bCheckURLsInBrowsers","Text_CheckURLsInBrowsers"]
		aAllControlsGui1:=["TextEnterSubstringCriteriaToAdd", "sCriteria_Substring", "TextSelectType", "TypeSelected", "bFetchBrowserURL", "TextURLAddition", "URLToCheckAgainst", "Button_AddSubsttringToActiveWhiteList", "Button_AddSubsttringToActiveBlackList", "Button_AddFromExistingWindows", "Button_SaveSelectedListViews", "Button_RestoreFromSave", "TextHorizontalLine", "TextSelectFilterMode", "vActiveFilterMode", "Text_SelectTrumpingRule", "bTrumping","bCheckURLsInBrowsers","Text_CheckURLsInBrowsers"] 
		aAllControlsGui1_VisibleDefault_2_plusWhite:=aAllControlsGui1_VisibleDefault.Clone()
		aAllControlsGui1_VisibleDefault_2_plusBlack:=aAllControlsGui1_VisibleDefault.Clone()
		for k,v in aWhiteControls_ToDisable
		{
			aAllControlsGui1.push(v)
			aAllControlsGui1_VisibleDefault.push(v)
			aAllControlsGui1_VisibleDefault_2_plusWhite.push(v)
		}
		for k,v in aBlackControls_ToDisable
		{
			aAllControlsGui1.push(v)
			aAllControlsGui1_VisibleDefault.push(v)
			aAllControlsGui1_VisibleDefault_2_plusBlack.push(v)
		}
	}
	return

	lEnforceRules:
	{
		if !bIsProgramOn ; don't continue if program is turned off.
			return
		bCloseThis:=bWhiteContainsThisTitle:=bBlackContainsThisTitle:=bCurrentIsBrowser:=bMatchAnyName:=false ; reset flags for each call. 
		sCurrentURL:=""
		sCurrTitle:=""
		WinGetActiveTitle, sCurrTitle
		WinGetClass, sCurrClass, A
		WinGet, sCurrExe, ProcessName,A
		if HasVal(BrowserNewTabs,sCurrTitle)
			return
		if HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe) ; don't get url if we are not in a browser
		{
			sCurrentURL:=""
			sCurrentURL:=fgetUrl(WinActive("A"))
			if Instr(sCurrTitle, " || "sCurrentURL) ;; fallback safety for the authors own convenience, as the browser tab names all contain the url as well due to a browser plugin. This ensures my testing works on "normal" tab-names.
				sCurrTitle:=StrSplit(sCurrTitle," || ").1
		}
		
		; prelim exception handling, safety returns
		if dbFlag ; debug behaviour
			ttip(A_ThisLabel sCurrTitle,4)
		if bDistractLess_3IsVisible
			return
		; NoFilterTitles NoFilterExes NoFilterClasses ← make sure these are never closed, as a precaution.
		If HasVal(NoFilterClasses,sCurrClass) ; don't filter these windows, ever.
			return
		if HasVal(NoFilterExes,sCurrExe) 
			return
		if HasVal(NoFilterTitles,sCurrTitle)
			return
		if ((ActiveArrays[1].Count()=0) && (ActiveArrays[2].Count()=0)) ; if both arrays are empty, do nothing
			return	
		if WinActive("- Visual Studio Code") ; never close the editor. Change this if you are editing/reviewing in something else than VSC. 
			return
		
		if (sCurrTitle!="")
		{
			; if (sCurrTitle==sLastWindowTitle)
			; 	return
			bLastWindowWasClosed:=false
			sLastWindowTitle:=sCurrTitle
			switch vActiveFilterMode 	
			{
				case "White": ;if (vActiveFilterMode="White") ; whitelist only
				{
					for k,v in ACtiveArrays[1]
					{
						RegExMatch(v, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",s)
						bWhiteContainsThisTitle:=true ;; start with the assumption that it is allowed to stay open.
						if (stype="w") ; website
						{
							if dbFlag ; debug behaviour
								ttip(A_thisLabel sCurrClass "`n" sCurrExe)
						}
						if (sName==".*") 
						{
							if (stype="w") and Instr(sCurrentURL,sURL)
								bMatchAnyName:=true
							else if (stype="p")
								bMatchAnyName:=true
						}
						else 
							bMatchAnyName:=false
						if Instr(sCurrTitle,sName) || (bMatchAnyName)
						{
							MatchedTitleEntry:=sName
							bWhiteContainsThisTitle:=true ; we have verified the window → If program, do not close it, exit the forloop and wait till window changes || if website, check the url still. if that matches, don't close, if it doesn't close.
							if HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)
								if (stype="w") ; website
									if !Instr(sCurrentURL,sURL) and (sURL!=".*") ; while the title matches, the url specified doesn't → still not a whitelisted page → close || if sURL=".*", it matches every url, so it will not be closed in that case, because we have already established that the title matches.
										bWhiteContainsThisTitle:=false
							if bWhiteContainsThisTitle
								return ; we have a match in whitelist -> donÄt close the current window, and no need to continue the search.
						}
						Else
						{
							MatchedTitleEntry:=sName
							bWhiteContainsThisTitle:=false ; we are not matching the title, hence we don't have to continue to search, and just close it now.
						}
						if !bWhiteContainsThisTitle
							bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,MatchedTitleEntry,WinActive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sURL,vActiveFilterMode,bWhiteTrumpedThisTitle)
					}
				}
				case "Both": 	;else if (vActiveFilterMode="Both") ; both
				{
					if (bTrumping="White > Black") ; white trumps black
						bBlackTrumpedThisTitle:=!bWhiteTrumpedThisTitle:=true
					else if (bTrumping="Black > White") ; black trumps white
						bWhiteTrumpedThisTitle:=!bBlackTrumpedThisTitle:=true	
					
					if bWhiteTrumpedThisTitle
					{
						; If bWhiteTrumps: behaviour:
										; iff whiteonly: don't close ← not even needs to be checked
						; iff white and black: don't close → we only need to check the cases that are able to close anyways.  
						; → as a result, as soon as white=true, we don't close. Hence, we can check if white contains the current title, and close everything that does not contain an entry in white
						; iff blackonly: DO close 
						
						for k,v in ActiveArrays[2]
						{
							bWhiteContainsThisTitle:=true
							bMatchAnyName:=false
							RegExMatch(v, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",s)
							if (sName==".*") 
							{
								if (stype="w") and Instr(sCurrentURL,sURL)
									bMatchAnyName:=true
								else if (stype="p")
									bMatchAnyName:=true
							}
							if Instr(sCurrTitle,sName) || (bMatchAnyName) ; blacklist matches: check if whitelist does NOT match
							{
								; current window is matching black now

								MatchedTitleEntry:=sName
								bMatchAnyName:=false
								; 1. Check if we need to compare urls
								if (sType="w") and (HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)) ; we want to check a website, and the current window is a browser
								{
									; we-are-in-a-website-blacktitlematched-loop
									if ((sURL!="") and Instr(sCurrentURL, sURL)) || (sURL=".*") ; the url is not blank, hence check if it is correct
									{
										;; state:
										;; black title: match
										;; black URL: match
										;; check if White title matches
										for s,w in ActiveArrays[1]
										{
												bMatchAnyName:=false
											RegExMatch(w, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",t)
											if (tname==".*")
											{
												if (ttype="w") and Instr(sCurrentURL,tURL)
													bMatchAnyName:=true
											}
											if (Instr(sCurrTitle,tname) && (ttype="w")) || (bMatchAnyName && (ttype="w"))
											{
												;; state:
												;; black title: match
												;; black URL: match
												;; white title: match
												;; white type: website
												;; either the title matches a website, or anything matches on a website
												;; it either matches::
												;; white title + white type==website
												;; any title + white type==website 
												;; Hence don't close anything in these conditionals. But because this also allows the website to exist, 
												;; we don't ever need to check the other conditions either, because this hit explicitly allows it to exist
												

												;; if we want to match an entire website, we actually must have a url match. In this case, if it matches, it is not closed
												if bMatchAnyName and Instr(sCurrentURL,tURL) 
													return
												else
												{
													;; a specific title is matching website type and title, so make sure we check the url
													if (tURL="")
													{
														;; URL is not given for this whitelisted title → assume a global match, and return out of the check
														return
													}
													else
													{
														;; we have a URL to check. 
														;; if the URL matches, the titlematch is considered allowed, and the tab is not closed, 
														;; because "AN" entry has matched on whitelist
														;; if it doesn't match, this whitelist-entry is not considered to be for this website, 
														;; so it is not applied. because it is not applied, go on with the next elemt of the whitelist
														;; This is okay because we are iterating through the entire whitelist if we are finding an allowed
														;; blacklist match to check all possible whitelist entries to possible get out of closing the window.
														if Instr(sCurrentURL,tURL) or (tURL=".*")
															return
													}
												}
											}
											else if (!Instr(sCurrTitle,tname) && (ttype="w")) 
											{
												;; state:
												;; black title: match
												;; black URL: match
												;; white title: no match
												;; hence check the next conditional, and if no more conditions trap the loop, go to closing
											}
											else if (Instr(sCurrTitle,tname) && !(ttype="w")) 
											{
												;; state:
												;; black title: match
												;; black URL: match
												;; white title: match
												;; white type: no match 
												;; hence this entry is not meant for usage in browsers
											}
											;; if we get to here, we have a match that is:
											;; matching a black Title
											;; along a 
										}
										

										;; none of the previous checks set this website window to _not_ close, so it is closed now
										bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,sname,Winactive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sUrl,vActiveFilterMode,bWhiteTrumpedThisTitle)
									}
								}
								else if (sType="p") and !(HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)) ; we don't want to check a website, and the current window is not a browser
								{
									;; we-are-in-a-program-match-black-titlematched-loop
									;; state:
									;; black title: match
									;; check if white title matches.
									;; if no element matches, close the window
									;; if one matches, return out of the label
									for s,w in ActiveArrays[1]
									{
										bMatchAnyName:=false
										RegExMatch(w, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",t)
										if (tname==".*")
										{
											if (ttype="p")
												bMatchAnyName:=true
										}
										if (Instr(sCurrTitle,tname) && (ttype="p")) || (bMatchAnyName && (ttype="p")) ;; only check entries related to programs, because we are currently in a program.
										{
											;; one of the following is true:
											;; - a program-name in whitelist matches the program
											;; - any program-name matches the program
											;; as a result, whitelist has a match, and the program is not closed
											return
										}
										if (!Instr(sCurrTitle,tname) && (ttype="p")) 
										{
											;; - no program-name in whitelist matches the program
											;; as a result, whitelist has no match, and the program is closed if no other condition overrules before the array has been fully looked through
										}
										
									
									}
									;; none of the previous checks set this window to _not_ close, so it is closed now
										bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,sname,Winactive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sUrl,vActiveFilterMode,bWhiteTrumpedThisTitle)
								}

							}
						}
					}
					else if bBlackTrumpedThisTitle
					{
						; if bBlackTrumps: behaviour:
									; iff whiteonly: don't close → never happens because we only check cases where black _IS_ matching already
						; iff white and black: DO close
						; if blackonly: DO close
						; as a result, anything matching in blacklist is always closed, because it outtrumps white
						for k,v in ActiveArrays[2]
						{
							RegExMatch(v, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",s)
							if (sName==".*") 
							{
								if (stype="w") and Instr(sCurrentURL,sURL) and (HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)) 
									bMatchAnyName:=true
								if (stype="w") and !Instr(sCurrentURL,sURL) and (HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)) ;; even though this should never happen, but in case the black any title matches a webside, but we don't have  a url to match, we don't accidentally start closing everything. 
									Continue ;; we must continue here and not return because there might be other conditions that are true which have not yet been checked
								else if (stype="p")
									Continue ;; precaution, but it shouldn't ever happen anyways.
							}
							if Instr(sCurrTitle,sName) || ((bMatchAnyName) && (sType!="p")) ; blacklist matches: 
							{
								;; in this case, either
								;; the current title matches
								;; if it is a browser, and the url matches, close the window
								;; if it is a browser, and the url doesn't match, go to next entry
								;; if it is a program, close it
								;; because black is trumping white here, any match that is considered correct will be closed.
								if (sType="w") and (HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)) ; we want to check a website, and the current window is a browser
								{
									if (sURL!="") and (Instr(sCurrentURL,sURL) || (sURL=".*" && sName!=".*")) ;; allow both normal matches of the url and matching _any url_, but only if we are not also simultaneously matching _any_ name
										bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,MatchedTitleEntry,WinActive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sURL,vActiveFilterMode,bWhiteTrumpedThisTitle)
								}
								else if (sType="p") and !(HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)) ; we don't want to check a website, and the current window is not a browser
								{
									bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,MatchedTitleEntry,WinActive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sURL,vActiveFilterMode,bWhiteTrumpedThisTitle)
								}
							}
						}
					}
				}
				case "Black":	;else if (vActiveFilterMode="Black") ; blacklist only
				{
					;; BLACK ONLY WORKS AS EXPECTED NOW.
					;; finish and fix whiteonly now, and finish the reddit thread on mixed first
					
					for k,v in ACtiveArrays[2] ; now check the blacklist
					{
						bBlackContainsThisTitle:=false
						str:="list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)"
						RegExMatch(v,str,s)
						if HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe) ; don't get url if we are not in a browser
							if (stype="w") ; website
							{
								if dbFlag ; debug behaviour
									ttip(A_Thislabel sCurrClass "`n" sCurrExe) ; sURL
								
							}
						if (sName==".*") 
							bMatchAnyName:=true
						if Instr(sCurrTitle,sName) || ((bMatchAnyName) && (sType!="p"))
						{
							if HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe) ; don't get url if we are not in a browser
							{
								if (stype="w") && if (sURL!="") ; we have a url to check for the website - otherwhise, assume all websites need to be matched
								{
									if Instr(sCurrentURL,sURL) || (sURL==".*") ; the selected black url and the current url match → close this browser tab
									{
										MatchedTitleEntry:=sName
										bBlackContainsThisTitle:=true
										bWhiteContainsThisTitle:=-1
									}
								}
								else	; we are not matching a specific website with the current criteria, so all websites with sName are matched.
								{
									MatchedTitleEntry:=sName
									bBlackContainsThisTitle:=true
									bWhiteContainsThisTitle:=-1
								}
							}
							else	; we are not in a browser → skip website-entries
							{
								if (stype="w") ; we are not in a browser, so close the
									Continue
								MatchedTitleEntry:=sName
								bBlackContainsThisTitle:=true
								bWhiteContainsThisTitle:=-1
							}
						}
						; else if (Instr(sCurrTitle,))
						Else
						{
							bBlackContainsThisTitle:=false
							continue ; we are not matching the title, hence we don't have to continue this iteration
						}
						if bBlackContainsThisTitle and (bWhiteContainsThisTitle==-1)
						{
							if (MatchedTitleEntry=".*") ; we are matching everything, so we _must_ match the url as well
							{
								if Instr(sCurrentURL,sURL) || (sURL=".*")
									bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,MatchedTitleEntry,WinActive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sURL,vActiveFilterMode,bWhiteTrumpedThisTitle)
							}
							else
								bLastWindowWasClosed:=f_CloseCurrentWindow(sCurrTitle,sCurrClass,sCurrExe,sCurrentURL,stype,MatchedTitleEntry,WinActive("A"),BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sURL,vActiveFilterMode,bWhiteTrumpedThisTitle)
						}
					}
				}
			}
		}
		Else ; current window has not changed title, and the previous one has passed, hence we don't do anything this time
			Return
		if dbFlag ; debug behaviour
			ttip(A_ThisLabel "`nLastWinClosed:" bLastWindowWasClosed "`nMatched Title Entry:" MatchedTitleEntry "`nBlack contains:" bBlackContainsThisTitle "´nWhite Contains:" bWhiteContainsThisTitle,4)
	}
	return
	
	lGuiHide_1:
	{
		gui, 1: hide
		bGui1IsVisible:=false
		menu, tray, rename, Hide Gui, Show Gui
	}
	return
	lEnableEnforceRules:
	Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer if gui is hidden again. Because this gui is always the last gui to be visible whenever you close any submenu, it is also the last one to be active when "closing" the GUI altogether - Hence if it is hidden, reenable. 
	; Main-Gui
	return
	lDisableEnforceRules:
	Settimer, lEnforceRules,Off
	return
	lGUIShow_1:
	{
 		Settimer, lEnforceRules, Off
		vLastCreationScreenHeight:=vGuiHeight
		vLastCreationScreenWidth:=vGuiWidth
		
		hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
		if (vGUIWidth="") || (vGuiHeight="") || ((vLastCreationScreenHeight!=(vGuiHeightOriginal-vGuiHeight_Reduction)) || (vLastCreationScreenWidth!=(A_ScreenWidth - 20)))
			gosub, lGuiCreate_1
		if !bGui1IsVisible
		{
			gui, 1: show, w%vGUIWidth% h%vGUIHeight%, DistractLess_1
			menu, tray, rename,Show Gui,Hide Gui
			bGui1IsVisible:=true
		}
		else
		{
			bGui1IsVisible:=false
			gosub, lGuiHide_1
			Settimer, lEnforceRules, Off
		}
		gui, 2: hide
		gui, 3: hide
		gui, 4: hide
		gui, 5: hide
		guicontrol, focus, sCriteria_Substring
		gosub, lUpdateStatusOnStatusBar
	}
	;Settimer, lCheckifGui1IsVisible, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer if program is switched on again. ;; Feels like 
	return

	lCheckifGui1IsVisible:
	if !Winactive("DistractLess_1")
	{
		Settimer, lCheckifGui1IsVisible, Off
		Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime
		ttip("not visible, renenable checker routine")
	}
	Else
		ttip("visible")
	Return

	lGuiCreate_1:
	{
		bMainGuiDestroyed:=false
		gui, 1: destroy
		gui,1: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border  ;+Resize +MinSize1000x
		gui, 1: default
		gui, +hwndMainGUI
		if vsdb
			gui, -AlwaysOnTop
		gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
		gui_control_options2 :=  cForeground . " -E0x200"
		Gui, Margin, 16, 16
		
		; Gui,  -SysMenu -ToolWindow -caption +Border
		cBackground := "c" . "1d1f21"
		cCurrentLine := "c" . "282a2e"
		cSelection := "c" . "373b41"
		cForeground := "c" . "c5c8c6"
		cComment := "c" . "969896"
		cRed := "c" . "cc6666"
		cOrange := "c" . "de935f"
		cYellow := "c" . "f0c674"
		cGreen := "c" . "b5bd68"
		cAqua := "c" . "8abeb7"
		cBlue := "c" . "81a2be"
		cPurple := "c" . "b294bb"
		Gui, Color, 1d1f21, 373b41, 
		Gui, Font, s7 cWhite, Segoe UI 
		; gui, add, text,xm ym, DistractLess v.%VN% - by %AU% 
		;Gui, add, Edit, %gui_control_options% -VScroll 
		gui, font, s9 cWhite, Segoe UI
		vLastCreationScreenHeight:=vGuiHeight
		vLastCreationScreenWidth:=vGuiWidth
		if (!vGUIWidth and !vGuiHeight) || (vGUIWidth!=(A_ScreenWidth-20)) || (vGuiHeight!=(A_ScreenHeight)) ; assign outer gui dimensions either if they don't exist or if the resolution of the active screen has changed - f.e. when undocking or docking to a higher resolution display. The lGuiCreate_1-subroutine is also invoked in total if the resolution changes, but this is the necessary inner check to reassign dimensions.
		{ 
			vGUIWidth:=A_ScreenWidth - 20  ;-910
			vGUIHeight:=A_ScreenHeight 
		}
		vGuiHeight_Reduction:=60 
		vGuiHeightControl:=A_ScreenHeight-vGuiHeight_Reduction
		
		if (vGUIHeight>vGuiHeightControl)
		{

			vGuiHeightOriginal:=vGuiHeight
			vGUIHeight:=vGUIHeight-vGuiHeight_Reduction
		}
		
		if vGUIWidth<1000
			f_ThrowError(A_ThisFunc,"Screen Width is smaller than 1000 pixels. As a result, the gui cannot be properly shown.`nIf this error is shown after opening the IniSettingsCreator, ignore it and open the gui again.",A_ScriptNameNoExt . "_"3, Exception("",-1).Line)
		
		
		vGUITabWidth:=vGUIWidth-30
		vGUITabHeight:=vGUIHeight-40
		
		vGroupBoxHeight:=vGUITabHeight-(2*20)
		vOuterGroupBoxWidth:=(vGUIWidth/2)-2*200 ; Finetune this value to scale in x direction to ratio of screen used for each section
		; 
		if (vOuterGroupBoxWidth<226) ;; don't allow too small groupbox widths, otherwhise buttons glitch outside their groupboxes
			vOuterGroupBoxWidth:=240
		
		vLV_Width:=vOuterGroupBoxWidth-2*15
		;vLV_Heigth	:= (vGroupBoxHeight - Buttons+Text "stored/active lists" - margin top/bottom) / number of LVs
		vLV_Heigth:=((vGroupBoxHeight-88-32)-40)/2
		vGUITab_HorizontalLine_Length:=vGUITabWidth
		
		; Calculate positions of Right side LV's, relative to the anchors at xp/yp
		xMax_TabWidth:= 16 + vGUITabWidth
		; Positioning:=[vGUIWidth,vGUIHeight,vGUITabWidth,vGUITabHeight,vOuterGroupBoxWidth,vGroupBoxHeight,vLV_Width,vLV_Heigth]
		OffsetFromRightEdge:=vOuterGroupBoxWidth+10
		vGroupBoxHeight2:=vGroupBoxHeight-1
		
		vRightCorner_WhiteListGroupBox:= 16 + 10 + vOuterGroupBoxWidth ; This marks the end of whitelist-groupbox
		vLeftCorner_BlackListGroupBox:= vGUIWidth - 24  - vOuterGroupBoxWidth ; This marks the beginning of the right-sided blacklist-groupbox
		
		vDistanceWhiteListToBlackList:=vLeftCorner_BlackListGroupBox-vRightCorner_WhiteListGroupBox
		; vWidthCentralGroupBox:= vDistanceWhiteListToBlackList - xMarginToWhiteListGroupBox - xMarginToBlackListGroupBox
		vWidthCentralGroupBox:=vDistanceWhiteListToBlackList - 2*16 
		vWidthCentralGroupBox_Editfields:=vWidthCentralGroupBox-(2*145)
		
		vCentralGroupBoxTLCx:=vRightCorner_WhiteListGroupBox + 16
		vYPositionCentralText:=(vWidthCentralGroupBox/2)+145
		vMiddleOfCentralGroupBox_EditFields:= 145 + (vWidthCentralGroupBox_Editfields/2)
		
		vCentralGroupBoxButtonWidth:=150
		vPositionCenteredButtonLeft:=vMiddleOfCentralGroupBox_EditFields - vCentralGroupBoxButtonWidth-30
		vPositionCenteredButtonRight:=vMiddleOfCentralGroupBox_EditFields +30
		
		vCentralGroupSliderWidth:=150
		vPositionCenteredSlider:=vMiddleOfCentralGroupBox_EditFields - (vCentralGroupSliderWidth/2)
		vPositionCenteredSliderText:=vPositionCenteredSlider+30
		
		; Gui, Add, Text,x25, Version: %VN%	Author: %AU% 
		Gui, Add, Text,x25 y0 w0 h0,  AnchorTab3
		gui, add, checkbox, xp+50 yp+20 vbIsProgramOn glCallBack_EnableProgram Checked, Enable DistractLess?
		; gui, add, Text, yp xp+200, DistractLess %VN% - finish centering this string
		; Gui, Add, Text,x25 y0 w0 h0,  AnchorTab3
		gui, add, tab3, xm yp-3 w%vGUITabWidth% h%vGUITabHeight%, Main
		gui, tab, Main
		;{ WhiteList
		gui, add, text, ym xm w0 h0,AnchorWhiteList ; get an anchor to control the position of following controls
		gui, add, groupbox, xm+10 yp+23 w%vOuterGroupBoxWidth% h%vGroupBoxHeight% w%vOuterGroupBoxWidth% ; screw pixel-perfect alignments. yp+23 seems to do it, but idgaf why. Scales properly with all tested random injected guiheights
		Gui, Font, s7 cWhite, Verdana
		gui, add, text, xm+25 yp+12 vText_ActiveWhiteList, Active Whitelist
		gui, add, ListView, xm+25 yp+25  +Report +NoSortHdr h%vLV_Heigth% w%vLV_Width% vvLV1 glLV_WhiteActive_EditSelected, Type|Name|URL
		f_UpdateLV(ActiveArrays[1]) ; SysListView321
		
		gui, add, button, vbtn1 glSaveWhiteActiveToStorage, ↓ Save
		gui, add, button, yp+35 xp vbtn2 glLoadWhiteStorageToActive, ↑ Load
		gui, add, button, yp-35 xp+50 vbtn3 glRemoveWhiteActiveFromActive w115, x Remove from active
		gui, add, button, yp+35 xp vbtn4 glRemoveWhiteStorageFromStorage w115, x Remove from stored
		gui, add, button, yp-35 xp+123 w103 vbtn5 glRestoreWhiteActiveFromBackup, Reverse last action
		gui, add, button, yp+35 xp w103 vbtn6 glRestoreWhiteStorageFromBackup, Reverse last action
		gui, add, button, yp-17.5 xp+123 w103 vbtn7 glRemoveWhiteAll, x Clear All
		gui, add, text, xp-296 yp+42.5 vText_StoredWhiteList, Stored WhiteList
		gui, add, ListView, xm+25 yp+25 +Report +NoSortHdr r23 h%vLV_Heigth% w%vLV_Width% vvLV2 glLV_WhiteStorage_EditSelected , Type|Name|URL  
		f_UpdateLV(StoredArrays[1]) ; SysListView322
		;}
		
		; A_DefaultGui
		;{ Blacklist
		xStartRightThird:=xMax_TabWidth-25
		Gui, Font, s7 cWhite, Verdana
		gui, add, text,ym+14 xm cRed x%xMax_TabWidth% vHiD w20 h20, AnchorBlackList ; create anchor text for the right side
		
		gui, add, groupbox, xp-%OffsetFromRightEdge% yp+010 w%vOuterGroupBoxWidth% h%vGroupBoxHeight2%  Section
		gui, add, text, yp+21 xp+15 yp+12 vText_ActiveBlackList, Active Blacklist ;-550
		gui, add, ListView, yp+25 xp+vOuterGroupBoxWidth +Report +NoSortHdr r23 h%vLV_Heigth% w%vLV_Width% vvLV3 glLV_BlackActive_EditSelected, Type|Name|URL ; replace the xp-1550 by xp-OffSetTopLeftCornerFromTopRightCornerOfTab3
		f_UpdateLV(ActiveArrays[2]) ; SysListView323
		gui, add, button, vbtn8 glSaveBlackActiveToStorage, ↓ Save
		gui, add, button, yp+35 xp vbtn9 glLoadBlackStorageToActive, ↑ Load
		gui, add, button, yp-35 xp+50 vbtn10 glRemoveBlackActiveFromActive w115, x Remove from active
		gui, add, button, yp+35 xp vbtn11 glRemoveBlackStorageFromStorage w115, x Remove from stored
		gui, add, button, yp-35 xp+123 w103 vbtn12 glRestoreBlackActiveFromBackup, Reverse last action
		gui, add, button, yp+35 xp w103 vbtn13 glRestoreBlackStorageFromBackup, Reverse last action
		gui, add, button, yp-17.5 xp+123 w103 vbtn14 glRemoveBlackAll, x Clear All
		gui, add, text, xp-296 yp+42.5 vText_StoredBlackList, Stored BlackList
		gui, add, ListView, xp yp+25 +Report +NoSortHdr r23 h%vLV_Heigth% w%vLV_Width% vvLV4 glLV_BlackStorage_EditSelected, Type|Name|URL
		f_UpdateLV(StoredArrays[2]) ; SysListView324

		
		gui, add, GroupBox, x%vCentralGroupBoxTLCx% ym+24 Section  w%vWidthCentralGroupBox% h%vGroupBoxHeight2%
		gui, add, text, ys+20 xs+145 w190 vTextEnterSubstringCriteriaToAdd,Enter substring &criteria to add
		gui, add, edit, yp+20 xs+145 w%vWidthCentralGroupBox_Editfields% glCallBack_EnableAssortmentButtons %gui_control_options2% -VScroll vsCriteria_Substring
		 
		if (0>1)
		{
			gui, add, text, yp+33 xs+145 vTextSelectType, Select T&ype:
			gui, add, DropDownList, yp+20 xs+145 vTypeSelected  glCallBack_EnableAssortmentButtons, Website|Program
			; gui, add, Checkbox, yp+3 xp+120 vbFetchBrowserURL glCallBack_EnableAssortmentButtons, &Check URL's
			gui, add, text, yp+30 xs+145 vTextURLAddition, Add &URL:
			gui, add, edit, yp-3 xp+50 w165 %gui_control_options2% glCallBack_EnableAssortmentButtons -VScroll vURLToCheckAgainst
			; gui, add, text, yp+30 xs+145, Add URL to check against:
			gui, add, button, yp+30 xs+%vPositionCenteredButtonLeft% w150 h20 vButton_AddSubsttringToActiveWhiteList glAddSubstringToActiveWhiteList, Add criteria to &WhiteList
			gui, add, button, yp xs+%vPositionCenteredButtonRight% w150 h20 vButton_AddSubsttringToActiveBlackList glAddSubstringToActiveBlackList, Add criteria to &BlackList
			gui, add, button, yp-55 xs+%vPositionCenteredButtonRight% w150 h20  vButton_AddFromExistingWindows glGUIShow_3, Add from &existing windows
			gui, add, button, yp+27 xs+%vPositionCenteredButtonRight% w60 h21  vButton_SaveSelectedListViews glSaveLVs, &Save LV's
			gui, add, button, yp xp+90 w60 h21 vButton_RestoreFromSave glLoadFileIntoArrays, &Load File
			;gui, add, button, yp+50 xs+%vPositionCenteredButtonRight% w150 %gui_control_options% h20 vButton_AddFromExistingWindows glGUIShow_3, Add from existing windows
		}
		else ;; new, more compact version 
		{
			; GuiControlGet, 	
			vWidthURLEDitField:=vWidthCentralGroupBox_Editfields-90
			gui, add, text, yp+33 xs+145 vTextSelectType, Select T&ype:
			gui, add, DropDownList, w80 yp+20 xs+145 vTypeSelected  glCallBack_EnableAssortmentButtons, Website|Program
			gui, add, text, yp-20 xp+90 vTextURLAddition, Add &URL:
			gui, add, edit, yp+20 xp w%vWidthURLEDitField% %gui_control_options2% glCallBack_EnableAssortmentButtons -VScroll vURLToCheckAgainst
			gui, add, button, yp+30 xs+%vPositionCenteredButtonLeft% w150 h20 vButton_AddSubsttringToActiveWhiteList glAddSubstringToActiveWhiteList, Add criteria to &WhiteList
			gui, add, button, yp xs+%vPositionCenteredButtonRight% w150 h20 vButton_AddSubsttringToActiveBlackList glAddSubstringToActiveBlackList, Add criteria to &BlackList
			gui, add, button, yp+30 xs+%vPositionCenteredButtonRight% w150 h20  vButton_AddFromExistingWindows glGUIShow_3, Add from &existing windows
			vPositionLeftButtonBelow_AddToWhiteList:=vPositionCenteredButtonLeft+31
			vPositionRightButtonBelow_AddToWhiteList:=vPositionLeftButtonBelow_AddToWhiteList-40
			gui, add, button, yp xp-%vPositionLeftButtonBelow_AddToWhiteList% w60 h21  vButton_SaveSelectedListViews glSaveLVs, &Save LV's
			gui, add, button, yp xp+90 w60 h21 vButton_RestoreFromSave glLoadFileIntoArrays, &Load File
			; gui, add, edit, yp xp+5 w165 %gui_control_options2% -VScroll vURLToCheckAgainst2
		}
		gui, add, text, yp+90 xs  vTextHorizontalLine w%vWidthCentralGroupBox% 0x10  ;Horizontal Line > Etched Gray
		gui, add, text, yp+30 xs+%vPositionCenteredSliderText% vTextSelectFilterMode, Select &Filter Mode
		if IniObj["GeneralSettings"].bAllowWhiteOnly
			gui, add, DropDownList, yp+15 xs+%vPositionCenteredSlider% w%vCentralGroupSliderWidth%  glCallBack_DDL_FilterMode vvActiveFilterMode, White|Both||Black
		Else
			gui, add, DropDownList, yp+15 xs+%vPositionCenteredSlider% w%vCentralGroupSliderWidth%  glCallBack_DDL_FilterMode vvActiveFilterMode, Both||Black
		
		gui, add, text, yp+30 xs+%vPositionCenteredSliderText% vText_SelectTrumpingRule, Select &Trumping Rule
		gui, add, DropDownList, yp+15 xs+%vPositionCenteredSlider% w%vCentralGroupSliderWidth% glCallBack_DDL_Trumping vbTrumping, White > Black||Black > White
		
		
		GuiControl, disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, disable, Button_AddSubsttringToActiveBlackList
		GuiControl, disable,bFetchBrowserURL
		GuiControl, hide, bFetchBrowserURL
		guicontrol, disable, TextURLAddition
		guicontrol, hide, TextURLAddition
		guicontrol, disable, URLToCheckAgainst
		guicontrol, hide, URLToCheckAgainst
		FONT_LV1:=StrSplit(FONT_LV,",").1
		FONT_LV2:=StrSplit(FONT_LV,",").2
		fontb:="Segoe UI"
		gui, font, %FONT_LV1% , %FONT_LV2%
		guicontrol, font, vLV1
		guicontrol, font, vLV2
		guicontrol, font, vLV3
		guicontrol, font, vLV4
		GUI, FONT
		; gui, add, text, x%vLeftCorner_BlackListGroupBox% y200,"hi"
		
		;; Middle gui groupbox: Active windows (top)
		/*
			Edit-field - enter criteria here
			2 buttons - add to whitelist - add to blacklist :: self-explanatory
			Fetch criteria from current window - IfGuiActive: F2: activate tagger - IfTaggerActive - F2: Catch current window information (plus url if browser)
			3-way switch - slider with range 1-3 - white only - both - black only :: use only either criteria and deactivate the other
			
			Trumping - w>b || w<b :: decide which criteria trumps the other if both are matching
			
			3-way switch - slider with range 1-3 - Programs only - both - websites only :: decide if you want to only supervise either programs or websites
			
			checkbox - check URL's :: if checking websites, make checks more consistent by only checking if the url is equal. ← figure out how to do partial string comparisons properly here
		*/
		
		XPositionTitleString:=vPositionCenteredSliderText+vOuterGroupBoxWidth
		gui, add, text,x%vPositionCenteredSliderText% ym, DistractLess v.%VN% - by %AU% 
		gui, tab
		gui, add, statusbar, -Theme vStatusBarMainWindow BackGround373b41 glCallBack_StatusBarMainWindow
		; Gui, Font, s9 cWhite, Segoe UI 
		
		if ((bShowDebugPanelINMenuBar) && bIsDevPC) 
			SB_SetParts(23,120,100,175,95,70,80,170)
		Else
			SB_SetParts(23,120,100,175,95,70,80)
		SB_SetIcon("C:\WINDOWS\system32\shell32.dll",48,1)
		SB_SetText("DistractLess v." VNpublic,2)
		SB_SetText(" by " AU,3)
		SB_SetText("Report a bug",6)
		SB_SetText("Documentation",7)
		; gui, add, text, xm+4 y200 w%vGUITab_HorizontalLine_Length% 0x10  ;Horizontal Line > Etched Gray ; the +4 shift is done to at least make the spacing equal on both sides, as the line can't seem to draw into the right tab-border, _but_ can start on the left tab border - strangely enough
		GuiControl, Focus, sCriteria_Substring
		gui 1: submit, NoHide ; this is the very first submit encountered, and ensures that 
		
		; HideFocusBorder(vActiveFilterMode) 
		HideFocusBorder(MainGUI)
		;gosub, lCallBack_DDL_FilterMode
		; DllCall("SetWinEventHook","UInt",0x8005,"UInt",0x8005,"Ptr",0,"Ptr",RegisterCallback("f_CheckFocusChange","F"),"UInt",DllCall("GetCurrentProcessId"),"UInt",0,"UInt",0)
	}
	return


	lClearAdditionFields:
	{ ; clear out edit fields when closing the window.
		gui, 1: default
		guicontrol, 1:, sCriteria_Substring, 
		guicontrol, 1:, URLToCheckAgainst, 
		GuiControl, 1: disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, 1: disable, Button_AddSubsttringToActiveBlackList
		gosub, lCallBack_EnableProgram
		GuiControl, 1: disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, 1: disable, Button_AddSubsttringToActiveBlackList
	}
	return

	lClearURLField:
	{ ; clear out edit fields when closing the window.
		gui, 1: default
		guicontrol, 1:, URLToCheckAgainst,
		GuiControl, 1: disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, 1: disable, Button_AddSubsttringToActiveBlackList
		gosub, lCallBack_EnableProgram
		GuiControl, 1: disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, 1: disable, Button_AddSubsttringToActiveBlackList
	}
	return

	lClearCriteriaSubString:
	{ ; clear out edit fields when closing the window.
		gui, 1: default
		guicontrol, 1:, sCriteria_Substring, 
		GuiControl, 1: disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, 1: disable, Button_AddSubsttringToActiveBlackList
		gosub, lCallBack_EnableProgram
		GuiControl, 1: disable, Button_AddSubsttringToActiveWhiteList
		GuiControl, 1: disable, Button_AddSubsttringToActiveBlackList
	}
	return
	
	lGUIShow_3:
	{ 	; "Add from existing windows"-GUI
		gosub, lGuiHide_1
		gosub, lClearAdditionFields
		Settimer, lEnforceRules, Off
		gui, 2: hide
		TLCx:=A_ScreenWidth-300
		TLCy:=A_ScreenHeight-200
		hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
		gui, 3: show, AutoSize x%TLCx% y%TLCy% h200 h200, DistractLess_3
		global bDistractLess_3IsVisible:=true
		gui, 4: hide
		gui, 5: hide
		if HasVal(BrowserClasses,sCurrClass) && HasVal(BrowserExes,sCurrExe)
			guicontrol, show, CurrentBrowserURL_CriteriaPicker
		Else
			guicontrol, hide, CurrentBrowserURL_CriteriaPicker
		Click,
		SetTimer, UpdateCriteriaPickerURL,200
	}
	return
	lGuiCreate_3: ; Submenu to choose from current windows
	{
		
		; if vsdb
		; 	gui, -AlwaysOnTop
		gui, 3: destroy
		gui,1: hide
		gui, 2: hide
		gui, 4: hide
		gui, 5: hide
		gui, 3: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +LabelGC3
		gui, +hwndChooseFromRunningWindows
		gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
		gui_control_options2 :=  cForeground . " -E0x200"
		Gui, Margin, 3, 3
		; Gui,  -SysMenu -ToolWindow -caption +Border
		cBackground := "c" . "1d1f21"
		cCurrentLine := "c" . "282a2e"
		cSelection := "c" . "373b41"
		cForeground := "c" . "c5c8c6"
		cComment := "c" . "969896"
		cRed := "c" . "cc6666"
		cOrange := "c" . "de935f"
		cYellow := "c" . "f0c674"
		cGreen := "c" . "b5bd68"
		cAqua := "c" . "8abeb7"
		cBlue := "c" . "81a2be"
		cPurple := "c" . "b294bb"
		Gui, Color, 1d1f21, 373b41, 
		Gui, Font, s9 cWhite, Segoe UI 
		gui, add, text,, Current Window Title and URL
		Gui, Font, s9 cWhite, Segoe UI 
		gui, add, edit, w200 %gui_control_options%  -VScroll vCurrentWindowTitle_CriteriaPicker
		gui, add, edit, w200 %gui_control_options%  -VScroll vCurrentBrowserURL_CriteriaPicker
		gui, add, text,, Press Ctrl + Left Mouse Button to select`n the current window's info and add it.
	}
	return
	UpdateCriteriaPickerURL:
	{
		SetTimer, lEnforceRules,Off
		gui, 3: default
		WinGetActiveTitle, sCurrentWindowTitle_CriteriaPicker_New
		WinGetClass, sCurrentWindowClass_CriteriaPicker_New,A
		WinGet, sCurrentWindowExe_CriteriaPicker, ProcessName,A
		CurrentBrowserURL_CriteriaPicker:=sCurrentBrowserURLCriteriaPicker_New:=""
		if (HasVal(BrowserClasses,sCurrentWindowClass_CriteriaPicker_New))  && (HasVal(BrowserExes,sCurrentWindowExe_CriteriaPicker))
		{
			GuiControl, enable, CurrentBrowserURL_CriteriaPicker
			guicontrol, show, CurrentBrowserURL_CriteriaPicker
			sCurrentBrowserURLCriteriaPicker_New:=fGetURL(WinExist("A"))
			GuiControl,, CurrentWindowTitle_CriteriaPicker,%sCurrentWindowTitle_CriteriaPicker_New%
			GuiControl,, CurrentBrowserURL_CriteriaPicker,%sCurrentBrowserURLCriteriaPicker_New%
		}
		Else
		{
			GuiControl, disable, %CurrentBrowserURL_CriteriaPicker%
			GuiControl, disable, %vCurrentBrowserURL_CriteriaPicker%
			GuiControl, disable, CurrentBrowserURL_CriteriaPicker
			GuiControl, disable, vCurrentBrowserURL_CriteriaPicker
			guicontrol, hide, CurrentBrowserURL_CriteriaPicker
			GuiControl,, CurrentWindowTitle_CriteriaPicker,%sCurrentWindowTitle_CriteriaPicker_New%
		}
	}
	return

	GC3Escape()
	{
		; gui, 3
		Gui, 3: hide
		Settimer, lEnforceRules, Off
		SetTimer, UpdateCriteriaPickerURL,off
		; gui, 1: default
		; gui, 1: show
		ttip(,99)
		ttip("")
		global GuiAction:="Escaped"
	}
		
		

	; Locking GUI
	lGUIShow_4:
	{
		Settimer, lEnforceRules, Off
		; gosub, lGuiHide_1
		gui, 1: hide
		bGui1IsVisible:=false
		;menu, tray, rename, Hide Gui, Show Gui
		gosub, lClearAdditionFields
		gui, 2: hide
		gui, 3: hide
		gui, 5: hide
		sEnteredPassword:=""
		gosub, lGuiCreate_4
		hk(0,0)
		gui, 4: show,,DistractLess_4
	}
	return
	lGuiCreate_4:
	{
		sEnteredPassword:=""
		gui, 4: destroy
		gui, 4: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border  +LabelGC4
		gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
		Gui, Margin, 16, 16
		Gui, Color, 1d1f21, 373b41, 
		Gui, Font, s11 cWhite, Segoe UI 
		gui, add, text,xm ym, Enter Password to unlock again:
		Gui, add, Edit, %gui_control_options% -VScroll Password* vsEnteredPassword glCheckEnteredPasswordString
		Gui, Font, s7 cWhite, Verdana
	}
	return
	GC4Submit()
	{
		gui, 4: submit, NoHide
	}
	GC4Escape()
	{
		gui, 4: hide
	}
	return

	
	; Lock till Time
	lGuiShow_5:
	{
		global GuiAction5:=""
		gosub, lGuiCreate_5
		hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
		Gui,5: Show, AutoSize, DistractLess_5
		WinWaitNotActive, DistractLess_5
		if (A_Now>=DefaultTime) and (GuiAction5="Submitted")
			f_ThrowError("Time-Locking subroutine lGuiShow_5","Designated Time lies in the past. This will happen automatically if the time set rolls over into the new day i.e. If it is 22:00, and you want to lock the program for three hours, you would lock it until 01:00 in the morning. In this case, the program breaks. Then, the current time is taken, which will obviously have passed in a second - and as a result the program effectively won't lock.`n`nAlternatively, this can obviously happen if you chose a time in the past.`n`nTo circumvent this issue, don't lock over midnight. Instead, lock until midnight and relock again afterwards.", A_ScriptNameNoExt . "_"4,Exception("",-1).Line)
	}
	return
	lGuiCreate_5:
	{
		gui, 5: destroy
		gui, 5: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border  +LabelGC5 +LastFound
		gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
		Gui, Margin, 16, 16
		Gui, Color, 1d1f21, 373b41, 
		Gui, Font, s11 cWhite, Segoe UI 
		gui, add, text,xm ym, Set unlocking time:
		TimeInSetNumberOfHours:=A_Hour+IniObj["General Settings"].LockingDefaultOffsetHours

		if (TimeInSetNumberOfHours>=24)
			Gui, Add, DateTime, vDefaultTime %gui_control_options% 1 Choose%A_YYYY%%A_Mon%%A_DD%235959, HH:mm:ss ; fallback if time rolls over.
		else
			if (TimeInSetNumberOfHours>=0) && (TimeInSetNumberOfHours<=9) ;; if time is single-digits, prepend a zero
				Gui, Add, DateTime, vDefaultTime %gui_control_options% 1 Choose%A_YYYY%%A_Mon%%A_DD%0%TimeInSetNumberOfHours%0000, HH:mm:ss ; HH = hours with leading zero; 24-hour format (00– 23)
			else
				Gui, Add, DateTime, vDefaultTime %gui_control_options% 1 Choose%A_YYYY%%A_Mon%%A_DD%%TimeInSetNumberOfHours%0000, HH:mm:ss ; HH = hours with leading  
		Gui, Font, s7 cWhite, Verdana
	}
	return
	GC5Escape()
	{
		global GuiAction5:="Escaped"
		gui, 5: destroy
	}
	return
	GC5_Submit()
	{
		global GuiAction5:="Submitted"
		gui, 5: submit
		gui, 5: destroy
	}
	return


	lSaveLVs:
	{
		gosub, lGuiHide_1
		Settimer, lEnforceRules, Off
		gui, 2: hide
		gui, 3: hide
		gui, 4: hide
		Arr:=f_CreateStoredArrays()
		if (Arr[1].length()=0) && (Arr[2].length()=0) && (Arr[3].length()=0) && (Arr[4].length()=0) 
			return	
		PreLoadingUserBackupWorkingDir:=A_WorkingDir
		SetWorkingDir, %A_ScriptDir%
		
		if !Instr(FileExist(IniObj["General Settings"].sLocationUserBackup),"D") ; check if folder exists
		{	; folder and file doesn't exist -> create
			; create folder
			FileCreateDir, % IniObj["General Settings"].sLocationUserBackup
		}
		FileSelectFile, SavedFilePath, S24, % IniObj["General Settings"].sLocationUserBackup
		if (SavedFilePath="")
			return	
		if (st_count(SavedFilePath,".ini")>0)
		{
			SavedFilePath:=st_removeDuplicates(SavedFilePath,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
			if (st_count(SavedFilePath,".ini")>0)  
				SavedFilePath:=SubStr(SavedFilePath,1,StrLen(SavedFilePath)-4) ; and remove the last instance

		}
		if !testFlag
			fWriteINI(Arr,SavedFilePath)
		Else
			m("No settings could be saved from the current setting, because the program was running in testsimulation-mode. Please exit this mode first before saving any settings.")
		SetWorkingDir, %OrigWorkingDIr%
	}
	return

	lCheckEnteredPasswordString:
	{
		gui, 4: submit, nohide
		if dbFlag ; debug behaviour
			ttip(sEnteredPassword)
		if ((sEnteredPassword=="db.unlock") && bIsDevPC)|| (sEnteredPassword==IniObj["Invisible Settings"].sUnlockPassword) ; solved pw. replace with user-defined, or obscure pw later. maybe randomly-generated.
		{
			gui, 4: hide
			sEnteredPassword:=""
			bIsLocked:=false
			bIsBeingUnlocked:=true
			gosub, lLockProgram
			bIsLocked:=false
			bIsBeingUnlocked:=false
			; f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,1,1)
			; f_EnableDisableGuiElements([bIsProgramOn],1,1)
			gosub, lUpdateStatusOnStatusBar
			gosub, lGUIShow_1
		}
		Else if (sEnteredPassword=="debug.true")
			global dbFlag:=true
		Else if (sEnteredPassword=="debug.false")
			global dbFlag:=false
	}
	Return


	lLoadFileIntoArrays:
	{
		gui, 1: default
		gosub, lGuiHide_1
		Settimer, lEnforceRules, Off
		if !Instr(FileExist(IniObj["General Settings"].sLocationUserBackup),"D") ; check if folder exists
		{	; folder and file doesn't exist -> create
			; create file
			FileCreateDir,% IniObj["General Settings"].sLocationUserBackup
			f_ThrowError("Main Code Body","The Folder specified under 'sLocationUserBackup' in settings does not exist in and no backups could be found therefore. The folder is now created. Please save a set of lists/settings via the 'Load LV's'-button into this folder first before trying to read load them.",A_ScriptNameNoExt . "_"5,Exception("",-1).Line)
			; SetWorkingDir, UserBackups
		}
		FileSelectFile, vSelectedFile,1, % IniObj["General Settings"]["sLocationUserBackup"] ,Select File
		if (vSelectedFile="")
			gui, 1: show, w%vGUIWidth% h%vGUIHeight%, DistractLess_1
		LoadedFile:=fReadINI(vSelectedFile)
		gosub, lLoadFromFile
	}
	return

	lLoadFromFile:
	{
		bRestoringLastSession:=true
		Count:=0
		if (LoadedFile[1].MaxIndex()!="")
			Count:=Count+ LoadedFile[1].MaxIndex()
		if (LoadedFile[2].MaxIndex()!="")
			Count:=Count+ LoadedFile[2].MaxIndex()
		if (LoadedFile[3].MaxIndex()!="")
			Count:=Count+ LoadedFile[3].MaxIndex()
		if (LoadedFile[4].MaxIndex()!="")
			Count:=Count+ LoadedFile[4].MaxIndex()
		if (LoadedFile[5].MaxIndex()!="")
			Count:=Count+ LoadedFile[5].MaxIndex()
		;ttip("Count: " Count)
		if Count
		{
			StoredArrays:=[[],[]]
			ActiveArrays:=[[],[]]
			gui, 1: default
			; gui, 1: show, w%vGUIWidth% h%vGUIHeight%, DistractLess_1
			if (LoadedFile[1].MaxIndex()!="")
			{
				gui, listview, SysListView321
				f_UpdateLV(LoadedFile[1])
				ActiveArrays[1]:=LoadedFile[1]
			}
			if (LoadedFile[2].MaxIndex()!="")
			{
				gui, listview, SysListView323
				f_UpdateLV(LoadedFile[2])
				ActiveArrays[2]:=LoadedFile[2]
			}
			if (LoadedFile[3].MaxIndex()!="")
			{
				gui, listview, SysListView322
				f_UpdateLV(LoadedFile[3])
				StoredArrays[1]:=LoadedFile[3]
			}
			if (LoadedFile[4].MaxIndex()!="")
			{
				gui, listview, SysListView324
				f_UpdateLV(LoadedFile[4])
				StoredArrays[2]:=LoadedFile[4]
			}
		}
		if (LoadedFile[5].MaxIndex()!="")
		{
			GuiControlGet,CurrentActiveFilterMode,,vActiveFilterMode
			GuiControlGet,CurrentTrumpingRule,,bTrumping
			
			LastActiveFilterMode:=Trim(strsplit(LoadedFile[5].1,";").1)
			LastTrumping:=Trim(strsplit(LoadedFile[5].2,";").1)
			LastCheckURLsInBrowsers:=Trim(strsplit(LoadedFile[5].3,";").1)
			LastIsProgramOn:=Trim(strsplit(LoadedFile[5].4,";").1)
			bTestThis:=true
			if (CurrentActiveFilterMode!=LastActiveFilterMode) ; Filter mode of loaded file is unequal to the currently active filter mode → issue warning
			{
				if (IniObj["General Settings"].bWarningOnFileLoadSettingChanges || bTestThis)
					m("The active filtermode has changed when loading the file. Please doublecheck if the chosen settings are appropriate to prevent the unwanted closing of programs and websites.`n`nTo remove these warnings when switching criteria files, change the setting 'bWarningOnFileLoadSettingChanges' in the settings.")
				; GuiControl, Choosestring, 
			}
			if (CurrentTrumpingRule!=LastTrumping) ; Filter mode of loaded file is unequal to the currently active filter mode → issue warning
			{
				if (IniObj["General Settings"].bWarningOnFileLoadSettingChanges || bTestThis)
					m("The active trumping-Rule has changed when loading the file. Please doublecheck if the chosen settings are appropriate to prevent the unwanted closing of programs and websites.`n`nTo remove these warnings when switching criteria files, change the setting 'bWarningOnFileLoadSettingChanges' in the settings.")
			}
		}
		hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
		gui, 1: show, w%vGUIWidth% h%vGUIHeight%, DistractLess_1
		guicontrol,ChooseString,vActiveFilterMode, %LastActiveFilterMode%
		guicontrol,ChooseString, bTrumping, %LastTrumping%
		vActiveFilterMode:=LastActiveFilterMode
		bTrumping:=LastTrumping
		bCheckURLsInBrowsers:=LastCheckURLsInBrowsers
		bIsProgramOn:=bIsProgramOn + 0
		; guicontrol,, bIsProgramOn, %LastIsProgramOn% 
		; gosub, lCallBack_DDL_FilterMode
		
		; gosub, lCallBack_EnableProgram
		; bRestoringLastSession:=false
	}
	return


	lUpdateStatusOnStatusBar:
	{
		gui, 1: default
		strProgramStatus:="Program is " (bIsProgramOn?"active":"disabled" ) " and "(bIsLocked?"locked":"not locked")
		SB_SetText(strProgramStatus,4)
		sDiagnosticsOn:="Mode: Diagnostics"
		sDiagnosticsOff:="Mode: Normal"
		if dbFlag
			SB_SetText(sDiagnosticsOn,5)
		Else
			SB_SetText(sDiagnosticsOff,5)
		
		if bIsDevPC and bShowDebugPanelINMenuBar
		{
			sTestSimOn:="DoubleClick to exit testsimulation"
			sTestSimOff:="DoubleClick to enter testsimulation"
			if testFlag 
				SB_SetText(sTestSimOn,8)
			Else
				SB_SetText(sTestSimOff,8)
		}
		if (A_EventInfo=8) && (A_ThisFunc!="f_EditArrayElement") && (bManageTestSimTrue)
			if (A_EventInfo=8)
				if (A_ThisFunc!="f_EditArrayElement")
					if (bManageTestSimTrue) ;; welp, this tracks straight through from editing an entry. weird bug. This is a hotfix, because I have not found the actual reason.
						gosub, lManageTestSimulation
	}
 	return

	lHotkey_ToggleTestmode:
	if dbflag
	{
		SoundBeep, 150, 150
		sleep, 300
		SoundBeep, 150, 150
		sleep, 300
		; SoundBeep, 150, 150
		; sleep, 300
		dbFlag:=False
	}
	Else
	{
		SoundBeep, 1750, 150
		sleep, 300
		SoundBeep, 1750, 150
		sleep, 300
		; SoundBeep, 1750, 150
		; sleep, 300
		dbFlag:=True
	}
	gosub, lUpdateStatusOnStatusBar
	Return
	lCallBack_EnableProgram:
	{
		gui, 1: default
		gui, 1: submit, nohide
		if !bIsProgramOn ; disable controls
		{
			f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,0,1)
			if (TypeSelected="Website")
				f_EnableDisableGuiElements(["bFetchBrowserURL","URLToCheckAgainst","TextURLAddition"],0,1)
			if !bRestoringLastSession
				f_EnableDisableGuiElements(aAllControlsGui1,0,1)
			; f_EnableDisableGuiElements(aBlackControls_ToDisable,0,1)
			; f_EnableDisableGuiElements(aWhiteControls_ToDisable,0,1)
			f_EnableDisableGuiElements([bIsProgramOn],1,1)
			SetTimer, lEnforceRules,Off
		}
		Else ; enable them again
		{
			Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer if program is switched on again.
			gosub, lUpdateStatusOnStatusBar
			if bIsLocked
				return
			if !bRestoringLastSession ; normal 
			{
				if bIsBeingUnlocked
				{
					if (vActiveFilterMode="Black")
						f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault_2_plusBlack,1,1)
					else if (vActiveFilterMode="White")
						f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault_2_plusWhite,1,1)
					Else
						f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,1,1)
				}
				Else
				{
					if (vActiveFilterMode="Black")
						f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault_2_plusBlack,1,1)
					else if (vActiveFilterMode="White")
						f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault_2_plusWhite,1,1)
					Else
						f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,1,1)
				}
			}
			Else
			{
				if (vActiveFilterMode="Black")
					f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault_2_plusBlack,1,1)
				else if (vActiveFilterMode="White")
					f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault_2_plusWhite,1,1)
				Else
					f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,1,1)
			}
			if (TypeSelected="Website")
				f_EnableDisableGuiElements(["bFetchBrowserURL","URLToCheckAgainst","TextURLAddition"],1,1)
			f_EnableDisableGuiElements([bIsProgramOn],1,1)
			return
		}
		gosub, lUpdateStatusOnStatusBar
	}
	return

	lCallBack_StatusBarMainWindow:
	{
		gui, 1: default
		if IniObj["Invisible Settings"].bAllowLocking	; check if locking is even allowed.
		{
			if ((A_GuiEvent="DoubleClick") && (A_EventInfo=1)) ; icon clicked: show lock gui/unlock
				gosub, lLockProgram
		}
		
		if ((A_GuiEvent="DoubleClick") && (A_EventInfo=3)) ; double left Click: Toggle advanced settings availability
		{
			if bEnableAdvancedSettings
			{
				bEnableAdvancedSettings:=False
				loop, 3
				{
					SoundBeep, 350, 
					sleep, 200
				}
			}
			Else
			{
				bEnableAdvancedSettings:=true
				loop, 3
				{
					SoundBeep, 750, 
					sleep, 200
				}
			} 
		}
		else if (((A_GuiEvent="DoubleClick") && (A_EventInfo=2))) ; double left click: Edit normal settings
			gosub, lOpenNormalSettings
		else if (((A_GuiEvent="R") && (A_EventInfo=2)) && bEnableAdvancedSettings) ; double right click: Edit hidden settings
		{
			gosub, lGuiHide_1
			gosub, lClearAdditionFields
			Settimer, lEnforceRules, off
			if DL_IniSettingsEditor("DistractLess",IniSettingsFilePath,0,0,1)
				gosub, lLoadSettingsFromIniFile
			Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer once we've closed the window
		}
		else if ((((A_GuiEvent="R") && (A_EventInfo=3)) && bEnableAdvancedSettings) || bEnterFromTrayMenu) ; double right click: Create Settings
		{
			bEnterFromTrayMenu:=false
			; gosub, lOpenIniFileCreator 
			gui, 1: destroy
			gui, 99: destroy
			gui, color
			gui, font
			gui, 99: new
			lChooseFile:=false
			FedFile:= IniSettingsFilePath
			bMainGuiDestroyed:=true
			Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
			;gosub, lIniFileCreator
			m("DistractLess-Version located at A_ScriptDir\Lib\IniFileCreator_v8.ahk")
			#Include %A_ScriptDir%\Library\IniFileCreator_v8.ahk ; can't continue on this cuz of restricted file access
			;#Include %A_MyDocuments%\AutoHotkey\Lib\IniFileCreator_v8.ahk
			WinWaitNotActive, IniFileCreator 8
			gosub, lGuiCreate_1
			Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer once we've closed the window
		}
		else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=5))
		{
			if dbflag
			{
				SoundBeep, 150, 150
				sleep, 300
				SoundBeep, 150, 150
				sleep, 300
				; SoundBeep, 150, 150
				; sleep, 300
				dbFlag:=False
			}
			Else
			{
				SoundBeep, 1750, 150
				sleep, 300
				SoundBeep, 1750, 150
				sleep, 300
				; SoundBeep, 1750, 150
				; sleep, 300
				dbFlag:=True
			}
			gosub, lUpdateStatusOnStatusBar
		}
		else  if ((A_GuiEvent="DoubleClick") && (A_EventInfo=6)) ; double left Click: Toggle advanced settings availability
		{
			gui, 1: hide
			run, https://github.com/Gewerd-Strauss/DistractLess/issues/new
		}
		else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=7))
		{
			gui, 1: hide
			run, %A_ScriptDir%\Readme.html
		}
		else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=8))
		{
			testFlag:=!testFlag
			bManageTestSimTrue:=True
			gosub, lUpdateStatusOnStatusBar
			bManageTestSimTrue:=false
		}
	}

	return
	lCallBack_EnableAssortmentButtons:
	{
		gui, 1: default
		gui, 1: submit, nohide
		if (TypeSelected) and (sCriteria_Substring)
		{
			if (TypeSelected="Website") && (URLToCheckAgainst!="") ;and (bFetchBrowserURL!="")
			{ ;URLToCheckAgainst
				GuiControl, enable, Button_AddSubsttringToActiveWhiteList
				GuiControl, enable, Button_AddSubsttringToActiveBlackList
				}
			else if (TypeSelected="Website") && (URLToCheckAgainst="")
			{
				GuiControl, disable, Button_AddSubsttringToActiveWhiteList
				GuiControl, disable, Button_AddSubsttringToActiveBlackList	
			}
			Else if (TypeSelected="Program")
			{
				GuiControl, enable, Button_AddSubsttringToActiveWhiteList
				GuiControl, enable, Button_AddSubsttringToActiveBlackList
			}
		}
		Else
		{
			GuiControl, disable, Button_AddSubsttringToActiveWhiteList
			GuiControl, disable, Button_AddSubsttringToActiveBlackList
		}
		if (TypeSelected="Website")
		{
			guicontrol, enable, bFetchBrowserURL
			guicontrol, show, bFetchBrowserURL
			guicontrol, enable, TextURLAddition
			guicontrol, show, TextURLAddition
			guicontrol, enable, URLToCheckAgainst
			guicontrol, show, URLToCheckAgainst
		}
		Else
		{
			guicontrol, disable, bFetchBrowserURL
			guicontrol, hide, bFetchBrowserURL
			guicontrol, disable, TextURLAddition
			guicontrol, hide, TextURLAddition
			guicontrol, disable, URLToCheckAgainst
			guicontrol, hide, URLToCheckAgainst
		}
	}
	return
	lCallBack_DDL_FilterMode:
	{ ; controls which filter mode is active, and by extend to which LV's the user has access currently.
		gui, 1: default
		gui 1: submit, NoHide
		HideFocusBorder(MainGUI)
		vLastSliderPos_Slider_FilterMode:=vActiveFilterMode
		if (vActiveFilterMode="White") ; Whitelist only
		{
			f_EnableDisableGuiElements(aBlackControls_ToDisable,0,1)
			f_EnableDisableGuiElements(aWhiteControls_ToDisable,1,1)
		}
		else if (vActiveFilterMode="Both") ; Both
		{
			f_EnableDisableGuiElements(aBlackControls_ToDisable,1,1)
			f_EnableDisableGuiElements(aWhiteControls_ToDisable,1,1)
		}
		else if (vActiveFilterMode="Black") ; Blacklist only
		{
			f_EnableDisableGuiElements(aWhiteControls_ToDisable,0,1)
			f_EnableDisableGuiElements(aBlackControls_ToDisable,1,1)
		}
		gosub, lCallBack_EnableAssortmentButtons
	}
	return
	lCallBack_DDL_CheckURLInBrowsers:
	{
		gui, 1: default
		gui 1: submit, NoHide
		HideFocusBorder(MainGUI)
	}
	return
	lCallBack_DDL_Trumping:
	{
		gui, 1: default
		gui 1: submit, NoHide
		HideFocusBorder(MainGUI)
	}
	return
	lLockProgram:
	{ ; 
		; if bIsLocked ; locked → disable everything
		if !bIsProgramOn
			return
		if bIsLocked ; this is invoked when UNLOCKING
		{
			if bRestartLocked and (A_Now<LastSessionSettings[5].5)
			{
				{ ; locking now → hide controls
					f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,0,1,1)
					if (TypeSelected="Website")
						f_EnableDisableGuiElements(["bFetchBrowserURL","URLToCheckAgainst","TextURLAddition"],0,1)
					bIsLocked:=true
				}
				gosub, lUpdateStatusOnStatusBar
				bRestartLocked:=false
				gui,1: hide
				return	
			}

			if (IniObj["General Settings"].LockingBehaviour=="Password-protected")
			{
				gosub, lGUIShow_4
				WinWaitClose, DistractLess_4
				bIsLocked:=false
				gosub, lCallBack_EnableProgram
				bIsBeingUnlocked:=true
			}
			else if (IniObj["General Settings"].LockingBehaviour="Time-protected")
			{
				if (A_Now >=DefaultTime) || ((GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin))
				{
					bIsLocked:=false
					gosub, lCallBack_EnableProgram
				}
				else
					ttip("keep locked")
				return
			}
		}
		Else ; this is invoked when LOCKING
		{
			if (IniObj["General Settings"].LockingBehaviour="Password-protected")
			{
				if bIsBeingUnlocked
				{
					gosub, lCallBack_EnableProgram
					bIsBeingUnlocked:=false
				}
				Else
				{ ; locking now → hide controls
					f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,0,1,1)
					if (TypeSelected="Website")
						f_EnableDisableGuiElements(["bFetchBrowserURL","URLToCheckAgainst","TextURLAddition"],0,1)
					bIsLocked:=true
				}
			}
			else if (IniObj["General Settings"].LockingBehaviour="Time-protected")
			{
				if bIsBeingUnlocked
				{
					gosub, lCallBack_EnableProgram
					bIsBeingUnlocked:=false
				}
				Else
				{ ; locking now → hide controls
					gosub, lGuiHide_1
					gosub, lGuiCreate_5
					gosub, lGUIShow_5
					WinWaitClose, DistractLess_5
					if (GuiAction5="Escaped")
					{
						gosub, lGuiSHow_1
						return
					}
					f_EnableDisableGuiElements(aAllControlsGui1_VisibleDefault,0,1,1)
					if (TypeSelected="Website")
						f_EnableDisableGuiElements(["bFetchBrowserURL","URLToCheckAgainst","TextURLAddition"],0,1)
					bIsLocked:=true
					Settimer, lEnforceRules, Off
				}
			}
		}
		gosub, lUpdateStatusOnStatusBar
	}
	return
	lIniFileCreator:
	bEnterFromTrayMenu:=true
	gosub, lCallBack_StatusBarMainWindow ; I am getting headaches. If I include the same section of code here, the IniFileCreator won't ever open - but routing through the same label works just fine. No clue why.
	return
	
	lOpenNormalSettings:
	gosub, lGuiHide_1
	gosub, lClearAdditionFields
	Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
	if DL_IniSettingsEditor("DistractLess",IniSettingsFilePath,0,0,0) ; settings have changed
		gosub, lLoadSettingsFromIniFile
	; Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer if program is switched on again.
	return
	lOpenHiddenSettings:
	gosub, lGuiHide_1
	gosub, lClearAdditionFields
	Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
	if DL_IniSettingsEditor("DistractLess",IniSettingsFilePath,0,0,1) ; settings have changed
		gosub, lLoadSettingsFromIniFile
	; Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer if program is switched on again.
	return



	
	lManageTestSimulation:
	{ 
		if testFlag
		{
			bActiveSetIsOriginal:=false
			TestSimStorage:=[ActiveArrays,StoredArrays]
			TestArrays:=f_ReadBackTestArraysFromFile(1)
			ActiveArrays:=TestArrays[1]
			StoredArrays:=TestArrays[2]
			; ActiveArrays:=StoredArrays:=[[],[]] ; insert test simulation 
			gui, listview, SysListView321
			f_UpdateLV(ActiveArrays[1])
			gui, listview, SysListView323
			f_UpdateLV(ActiveArrays[2])
			gui, listview, SysListView322
			f_UpdateLV(StoredArrays[1])
			gui, listview, SysListView324
			f_UpdateLV(StoredArrays[2])
		}
		else
		{
			bActiveSetIsOriginal:=true
			gui, listview, SysListView321
			f_UpdateLV(TestSimStorage[1][1])
			gui, listview, SysListView323
			f_UpdateLV(TestSimStorage[1][2])
			gui, listview, SysListView322
			f_UpdateLV(TestSimStorage[2][1])
			gui, listview, SysListView324
			f_UpdateLV(TestSimStorage[2][2])
			ActiveArrays:=TestSimStorage[1]
			StoredArrays:=TestSimStorage[2]
			TestSimStorage:=[]
		}
	}
	return

	lLV_WhiteActive_EditSelected:
	{
		gui, 1: default
		gui, listview, SysListView321
		ActiveWhiteBackup:=ActiveArrays[1].clone()
		sEditedString:=f_EditArrayElement(ActiveArrays[1][A_EventInfo])
		if (GuiAction="Escaped") ; If Escaped → nothing has been edited once the menu was up → just go back to guishow
			gosub, lGUIShow_1
		else if (GuiAction="Submitted") ; if Submitted → either stuff has been changed, or not. Check format of sEditedString to see more
		{
			if sEditedString ; whatever is stored in sEditedString is now either the original value or a changed value
			{ ; LastGuiEvent_f_EditArrayElement
				ActiveWhiteBackup:=ActiveArrays[1].clone()
				ActiveArrays[1][A_EventInfo]:=sEditedString
				gui, 1: default
				gui, listview, SysListView321
				f_UpdateLV(ActiveArrays[1])
				gosub, lGUIShow_1
			}
			Else  ; array has not been edited, so don't update anything?
				if (LastGuiEvent_f_EditArrayElement!="D")
					gosub, lGUIShow_1
		}
	}
	return
	lLV_WhiteStorage_EditSelected:
	{ ; A_DefaultGui
		gui, 1: default
		gui, listview, SysListView322
		StoredWhiteBackUp:=StoredArrays[1].clone()
		sEditedString:=f_EditArrayElement(StoredArrays[1][A_EventInfo])
		if (GuiAction="Escaped") ; If Escaped → nothing has been edited once the menu was up → just go back to guishow
			gosub, lGUIShow_1
		else if (GuiAction="Submitted") ; if Submitted → either stuff has been changed, or not. Check format of sEditedString to see more
		{
			if sEditedString ; whatever is stored in sEditedString is now either the original value or a changed value
			{ ; LastGuiEvent_f_EditArrayElement
				StoredWhiteBackUp:=StoredArrays[1].clone()
				StoredArrays[1][A_EventInfo]:=sEditedString
				gui, 1: default
				gui, listview, SysListView322
				f_UpdateLV(StoredArrays[1])
				gosub, lGUIShow_1
			}
			Else  ; array has not been edited, so don't update anything?
				if (LastGuiEvent_f_EditArrayElement!="D")
					gosub, lGUIShow_1
		}
	}
	return
	lLV_BlackActive_EditSelected:
	{
		gui, 1: default
		gui, listview, SysListView323
		ActiveBlackBackup:=ActiveArrays[2].clone()
		sEditedString:=f_EditArrayElement(ActiveArrays[2][A_EventInfo])
		if (GuiAction="Escaped") ; If Escaped → nothing has been edited once the menu was up → just go back to guishow
			gosub, lGUIShow_1
		else if (GuiAction="Submitted") ; if Submitted → either stuff has been changed, or not. Check format of sEditedString to see more
		{ ; A_DefaultListView
			if sEditedString ; whatever is stored in sEditedString is now either the original value or a changed value
			{ ; LastGuiEvent_f_EditArrayElement
				ActiveBlackBackup:=ActiveArrays[2].clone()
				ActiveArrays[2][A_EventInfo]:=sEditedString
				gui, 1: default
				gui, listview, SysListView323
				f_UpdateLV(ActiveArrays[2])
				gosub, lGUIShow_1
			}
			Else  ; array has not been edited, so don't update anything?
				if (LastGuiEvent_f_EditArrayElement!="D")
					gosub, lGUIShow_1
		}
	}
	return
	lLV_BlackStorage_EditSelected:
	{
		gui, 1: default
		; m("rework this and LV_BlackStorage_EditSelected according to the example in 'lLV_WhiteStorage_EditSelected'")
		gui, listview, SysListView324
		StoredBlackBackUp:=StoredArrays[2].clone()
		sEditedString:=f_EditArrayElement(StoredArrays[2][A_EventInfo])
		if (GuiAction="Escaped") ; If Escaped → nothing has been edited once the menu was up → just go back to guishow
			gosub, lGUIShow_1
		else if (GuiAction="Submitted") ; if Submitted → either stuff has been changed, or not. Check format of sEditedString to see more
		{
			if sEditedString ; whatever is stored in sEditedString is now either the original value or a changed value
			{ ; LastGuiEvent_f_EditArrayElement
				StoredBlacKBackup:=StoredArrays[2].clone()
				StoredArrays[2][A_EventInfo]:=sEditedString
				gui, 1: default
				gui, listview, SysListView324
				f_UpdateLV(StoredArrays[2])
				gosub, lGUIShow_1
			}
			Else  ; array has not been edited, so don't update anything?
				if (LastGuiEvent_f_EditArrayElement!="D")
					gosub, lGUIShow_1
		}
	}
	return
	lSaveWhiteActiveToStorage:
	{
		gui, 1: default
		gui, ListView, SysListView321
		sel:=f_GetSelectedLVEntries()
		gosub, lRemoveWhiteActiveFromActive
		StoredArrays[1]:=f_CopySelectionIntoArray(sel,StoredArrays[1],"WhiteDef")
		gui, listview, SysListView322
		StoredWhiteBackUp:=StoredArrays[1].clone()
		f_UpdateLV(StoredArrays[1])
	}
	return
	lSaveBlackActiveToStorage:
	{
		gui, 1: default
		gui, ListView, SysListView323
		sel:=f_GetSelectedLVEntries()
		gosub, lRemoveBlackActiveFromActive
		StoredArrays[2]:=f_CopySelectionIntoArray(sel,StoredArrays[2],"BlackDef")
		gui, listview, SysListView324
		StoredBlackBackUp:=StoredArrays[2].clone()
		f_UpdateLV(StoredArrays[2])
	}
	return

	lRestoreWhiteActiveFromBackup:
	{ ; restore  version before last addition/removal of items to WhiteActive from its previous state.
		gui, 1: default
		gui, listview, SysListView321
		if ActiveWhiteBackup
		{
			ActiveArrays[1]:=ActiveWhiteBackup.Clone()  ; restore the data-array itself
			f_UpdateLV(ActiveWhiteBackup)				; and the visual representation.
		}
	}
	return
	lRestoreWhiteStorageFromBackup:
	{ ; see above
		gui, 1: default
		gui, listview, SysListView322
		if StoredWhiteBackUp
		{
			StoredArrays[1]:=StoredWhiteBackUp.Clone()
			f_UpdateLV(StoredWhiteBackUp)
		}
	}
	return
	lRestoreBlackActiveFromBackup:
	{ ; see above
		gui, 1: default
		gui, listview, SysListView323
		if ActiveBlackBackup 
		{
			ActiveArrays[2]:=ActiveBlackBackup.Clone()
			f_UpdateLV(ActiveBlackBackup)
		}
	}
	return
	lRestoreBlackStorageFromBackup:
	{ ; see above
		gui, 1: default
		gui, listview, SysListView324
		if StoredBlackBackup
		{
			StoredArrays[2]:=StoredBlackBackUp.Clone()
			f_UpdateLV(StoredBlackBackup)
		}
	}
	return


	lLoadWhiteStorageToActive:
	{ ; load selected rows of white storage to White active
		gui, 1: default
		gui, listview, SysListView322
		sel:=f_GetSelectedLVEntries()
		ActiveWhiteBackup:=ActiveArrays[1].clone()
		gosub, lRemoveWhiteStorageFromStorage
		ActiveArrays[1]:=f_CopySelectionIntoArray(sel,ActiveArrays[1],"WhiteDef")
		; m(ActiveArrays[1])
		gui, listview, SysListView321
		f_UpdateLV(ActiveArrays[1])
	}
	return
	lLoadBlackStorageToActive:
	{ ; see above
		gui, 1: default
		gui, listview, SysListView324
		sel:=f_GetSelectedLVEntries()
		ActiveBlackBackup:=ActiveArrays[2].clone()
		gosub, lRemoveBlackStorageFromStorage
		ActiveArrays[2]:=f_CopySelectionIntoArray(sel,ActiveArrays[2],"BlackDef")
		gui, ListView, SysListView323
		f_UpdateLV(ActiveArrays[2])
	}
	return


	lRemoveWhiteActiveFromActive:
	{ ; remove to be selected white entries from white active
		gui, 1: default
		gui, ListView, SysListView321
		sel:=f_GetSelectedLVEntries()
		; MsgBox,4,%A_ScriptNameNoExt%, Do you want to remove the selected entries?
		if IniObj["General Settings"].bLVDelete_RequireConfirmation
			bCQOut:=f_Confirm_Question("Do you want to remove the selected entries?",AU,VN)
		if (bCQOut and (bCQOut!=-1)) || !IniObj["General Settings"].bLVDelete_RequireConfirmation
		{
			gui, 1:Default
			gui, ListView, SysListView321
			StoredActiveWhiteArrays:=f_RemoveSelectionFromArray(sel,ActiveArrays[1],"WhiteDef") ; rebuild the active array by removing selected entries
			ActiveArrays[1]:=StoredActiveWhiteArrays[1]
			ActiveWhiteBackup:=StoredActiveWhiteArrays[2]
			; m(ActiveArrays[1],ActiveWhiteBackup)
			gui, ListView, SysListView321
			f_UpdateLV(ActiveArrays[1])
		}
	}
	return
	lRemoveBlackActiveFromActive:
	{ ; see above
		gui, 1: default
		gui, ListView, SysListView323
		sel:=f_GetSelectedLVEntries()
		if IniObj["General Settings"].bLVDelete_RequireConfirmation
			bCQOut:=f_Confirm_Question("Do you want to remove the selected entries?",AU,VN)
		if (bCQOut and (bCQOut!=-1)) || !IniObj["General Settings"].bLVDelete_RequireConfirmation
		{
			gui, 1:Default
			gui, ListView, SysListView323
			StoredActiveBlackArrays:=f_RemoveSelectionFromArray(sel,ActiveArrays[2],"BlackDef") ; rebuild the active array by removing selected entries
			ActiveArrays[2]:=StoredActiveBlackArrays[1]
			ActiveBlackBackup:=StoredActiveBlackArrays[2]
			f_UpdateLV(ActiveArrays[2])
		}
	}
	return
	lRemoveWhiteStorageFromStorage:
	{ ; remove settings from white storage
		gui, 1: default
		gui, ListView, SysListView322
		sel:=f_GetSelectedLVEntries()
		if IniObj["General Settings"].bLVDelete_RequireConfirmation
			bCQOut:=f_Confirm_Question("Do you want to remove the selected entries?",AU,VN)
		if (bCQOut and (bCQOut!=-1)) || !IniObj["General Settings"].bLVDelete_RequireConfirmation
		{
			gui, 1:Default
			gui, ListView, SysListView322
			StoredWhiteArrays:=f_RemoveSelectionFromArray(sel,StoredArrays[1],"WhiteDef")
			StoredArrays[1]:=StoredWhiteArrays[1]
			StoredWhiteBackUp:=StoredWhiteArrays[2]
			f_UpdateLV(StoredArrays[1])
			LV_ModifyCol(2,"auto")
		}
	}
	return
	lRemoveBlackStorageFromStorage:
	{ ; see above
		gui, 1: default
		gui, ListView, SysListView324
		sel:=f_GetSelectedLVEntries()
		if IniObj["General Settings"].bLVDelete_RequireConfirmation
			bCQOut:=f_Confirm_Question("Do you want to remove the selected entries?",AU,VN)
		if (bCQOut and (bCQOut!=-1)) || !IniObj["General Settings"].bLVDelete_RequireConfirmation
		{
			gui, 1:Default
			gui, ListView, SysListView324
			sel:=f_GetSelectedLVEntries()
			StoredBlackArrays:=f_RemoveSelectionFromArray(sel,StoredArrays[2],"BlackDef")
			StoredArrays[2]:=StoredBlackArrays[1]
			StoredBlacKBackup:=StoredBlackArrays[2]
			f_UpdateLV(StoredArrays[2])
			LV_ModifyCol(2,"auto")
		}
	}
	return
	lRemoveWhiteAll:
	{ ; remove settings from both white active and white storage
		gui, 1: default
		if (StoredArrays[1].count()>0) 
		{
			StoredWhiteBackUp:=StoredArrays[1]
			StoredArrays[1]:=[]
		}
		if (ActiveArrays[1].count()>0)
		{
			ActiveWhiteBackup:=ActiveArrays[1]
			ActiveArrays[1]:=[]
		}
		gui, 1: default
		gui, Listview, SysListView321
		f_UpdateLV([])
		gui, Listview, SysListView322
		f_UpdateLV([])
	}
	return
	lRemoveBlackAll:
	{ ; see above
		gui, 1: default
		if (StoredArrays[2].count()>0) 
		{
			StoredBlacKBackup:=StoredArrays[2]
			StoredArrays[2]:=[]
		}
		if (ActiveArrays[2].count()>0)
		{
			ActiveBlackBackup:=ActiveArrays[2]
			ActiveArrays[2]:=[]
		}
		gui, 1: default
		gui, Listview, SysListView323
		f_UpdateLV([])
		gui, Listview, SysListView324
		f_UpdateLV([])
	}
	return

	lAddSubstringToActiveWhiteList:
	{
		gui, 1: default
		gui, ListView, SysListView321
		gui, 1: submit, nohide	
		Sel_Type:=(TypeSelected="Website") ? "w" : "p"
		sel:=[]
		if (sCriteria_Substring="")
			return
		if (Sel_Type="w")
		{
			if (sCriteria_Substring=".*") && (!URLToCheckAgainst) ; prohibit the user  
				return
			if (sCriteria_Substring=".*") && (URLToCheckAgainst=".*") ; prohibit the user  from inserting absolute wildcards
			{
				ttip("Input not valid. You can only set either the URL or the title substring to '.*'")
				return 
			}
			sel[1]:="||" Sel_Type "||" sCriteria_Substring "||" URLToCheckAgainst  ; this string is not yet finished completely.
		}
		Else
			sel[1]:="||" Sel_Type "||" sCriteria_Substring "||" ; this string is not yet finished completely.
		ActiveWhiteBackup:=ActiveArrays[1].clone()
		f_UpdateLV(f_CopySelectionIntoArray(sel,ActiveArrays[1],"WhiteDef"))
	}
	return
	lAddSubstringToActiveBlackList:
	{
		gui, 1: default
		gui, ListView, SysListView323
		gui, 1: submit, nohide
		Sel_Type:=(TypeSelected="Website") ? "w" : "p"
		sel:=[]
		if (sCriteria_Substring="")
			return
		if (Sel_Type="w")
		{
			if (sCriteria_Substring=".*") && (!URLToCheckAgainst)
				return
			if (sCriteria_Substring=".*") && (URLToCheckAgainst=".*") ; prohibit the user  from inserting absolute wildcards
			{
				ttip("Input not valid. You can only set either the URL or the title substring to '.*'")
				return 
			}
			sel[1]:="||" Sel_Type "||" sCriteria_Substring "||" URLToCheckAgainst  ; this string is not yet finished completely.
		}
		Else
		{
			if (sCriteria_Substring=".*") ; this would force-close any and all windows matching, i.e. all that are not explicitly whitelisted. Be careful. Do I even want to enable this? Would be better to restrict .* -  usage to websites only.
			{
				ttip("Input not valid. You cannot set '.*'-name-wildcards for blacklisted programs, or you risk closing every program, always")
				return
			}
			sel[1]:="||" Sel_Type "||" sCriteria_Substring "||" ; this string is not yet finished completely.
		}
		ActiveBlackBackup:=ActiveArrays[2].clone()
		f_UpdateLV(f_CopySelectionIntoArray(sel,ActiveArrays[2],"BlackDef"))
	}
	return

	lOpenIniFileCreator:
	; gui, 1: destroy
	; gui, 99: destroy
	; gui, color
	; gui, font
	; gui, 99: new
	; lChooseFile:=false
	; FedFile:= IniSettingsFilePath
	; bMainGuiDestroyed:=true
	; Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
	; #Include %A_MyDocuments%\AutoHotkey\Lib\IniFileCreator_v8.ahk
	; WinWaitNotActive, IniFileCreator 8
	gui, 1: destroy
	gui, 99: destroy
	gui, color
	gui, font
	gui, 99: new
	lChooseFile:=false
	FedFile:= IniSettingsFilePath
	bMainGuiDestroyed:=true
	Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
	;#Include %A_MyDocuments%\AutoHotkey\Lib\IniFileCreator_v8.ahk
	#Include %A_ScriptDir%\Library\IniFileCreator_v8.ahk ; can't continue on this cuz of restricted file access
	WinWaitNotActive, IniFileCreator 8
	return
	;_________________ common labels
	NotifyTrayClick_203:
	menu, tray, show
	return
	GuiEscape:
	gui, hide
	return
	RemoveToolTip: 
	Tooltip,
	return
	Label_AboutFile:
	MsgBox,, File Overview, Name: %ScriptName%`nAuthor: %AU%`nVersionNumber: %VN%`nLast Edit: %LE%`n`nScript Location: %A_ScriptDir%
	return
	;}______________________________________________________________________________________
	;{#[Functions Section]
	f_GetSelectedLVEntries()
	{
		vRowNum:=0
		sel:=[]
		loop 
		{
			vRowNum:=LV_GetNext(vRowNum)
			if not vRowNum  ; The above returned zero, so there are no more selected rows.
				break
			LV_GetText(sCurrText1,vRowNum,1)
			LV_GetText(sCurrText2,vRowNum,2)
			LV_GetText(sCurrText3,vRowNum,3)
			LV_GetText(sCurrText4,vRowNum,4)
			sel[A_Index]:="||" sCurrText1 "||" sCurrText2 "||" sCurrText3
		}
		return sel
	}
	
	f_CopySelectionIntoArray(sel,DestinationArray,ListType)
	{
		Ind:=1
		InsArr:=[]
		str:=""
		for k,v in sel
		{
			CurrSet:=StrSplit(v,"||")
			type:= (CurrSet[2]="w") ? "WhiteDef" : "BlackDef"
			searchedstr:="list:(" ListType ")|type:(" Currset[2] ")|name:(" CurrSet[3] ")|URL:(" CurrSet[4] ")"
			InsArr[Ind]:=searchedstr
			Ind++
		}
		; InsArr contains all selected values rows that are to be inserted into the other array
		; now check which one of those is already existing, and add all that are not already present
		for k,v in InsArr
		{
			Hit:=0
			for a,b in DestinationArray
				if (b==v)
					Hit++
			if (Hit=0) ; selection does not yet exist in destination array
				DestinationArray.push(v)
		}		
		return DestinationArray
	}

	f_RemoveSelectionFromArray(sel,Array,ListType)
	{
		ArrNew:=[]
		ArrStorage:=Array.Clone()
		for k,v in sel
		{ ; assemble search string, then remove hits from array
			CurrSet:=StrSplit(v,"||")
			; type:= (CurrSet[2]="w") ? "WhiteDef" : "BlackDef"
			if (CurrSet[2]=="w")
				searchedstr:="list:(" ListType ")|type:(" Currset[2] ")|name:(" CurrSet[3] ")|URL:(" CurrSet[4] ")"
			Else ; programs don't have url's attached, hence don't add that part of the string for comparison
				searchedstr:="list:(" ListType ")|type:(" Currset[2] ")|name:(" CurrSet[3] ")|URL:()"	
			for a,b in Array
			{
				b:=f_RemoveURLsFromProgramEntries(b)
				if (searchedstr==b) 
					Array[a]:=""
			}	
		}
		for a,b in Array
			if (b!="")
				ArrNew.push(b)
		return [ArrNew,ArrStorage]
	}

	f_UpdateLV(Array)
	{ ; updates the selected LV. LV MUST BE SELECTED BEFORE.
		LV_Delete()
		for k,v in Array
		{
			RegExMatch(v, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",s)
			if (sType="w")
				LV_Add("-E0x200",sType,sName,sURL)	
			Else
				LV_Add("-E0x200",sType,sName,"")	
		}
		LV_ModifyCol(2,"auto")
		return
	}

	f_RemoveURLsFromProgramEntries(b)
	{
		RegExMatch(b, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",s)
		if (sType="p")
			return "list:(" sList ")|type:(p)|name:(" sName ")|URL:()"
		else
			return b
	}

	f_EditArrayElement(Element)
	{
		global
		Sel:=f_GetSelectedLVEntries()
		LastGuiEvent_f_EditArrayElement:=A_GuiEvent
		if % (A_GuiEvent="DoubleClick") and Sel.Length()
		{
			static EditedURL
			RegExMatch(Element, "list:\((?<List>WhiteDef|BlackDef)\)\|type:\((?<Type>p|w)\)\|name:\((?<Name>.*)\)\|URL:\((?<URL>.*)\)",s)
			gosub, lGuiHide_1
			Settimer, lEnforceRules, Off
			gosub, lClearAdditionFields ;; this gosub clears all arrays before VN=1.2.2.4
			gui, 2: destroy
			Gui, 2: New, -Caption +LastFound +ToolWindow +LabeleAE_ +AlwaysOnTop 
			gui_control_options := "xm w420 " . cForeground . " -E0x200"  ; remove border around edit field
			cBackground := "c" . "1d1f21"
			cCurrentLine := "c" . "282a2e"
			cSelection := "c" . "373b41"
			cForeground := "c" . "c5c8c6"
			cComment := "c" . "969896"
			cRed := "c" . "cc6666"
			cOrange := "c" . "de935f"
			cYellow := "c" . "f0c674"
			cGreen := "c" . "b5bd68"""
			cAqua := "c" . "8abeb7"
			cBlue := "c" . "81a2be"
			cPurple := "c" . "b294bb"
			Gui, Color, 1d1f21, 373b41, 
			Gui, Font, s9 cWhite, Segoe UI 
			gui, add, text,, Edit String
			Gui, Font, s9 cWhite, Segoe UI 
			if IniObj["Hidden Settings"].bEditDirectStringIn_f_EditArrayElement
				gui, add, edit, %gui_control_options% -VScroll vEditedElement, % Element
			Else
			{
				gui, add, edit, %gui_control_options% -VScroll vEditedElement, % sName
				if (stype="w")
				{
					Gui, Font, s9 cWhite, Segoe UI 
					gui, add, text,, Edit URL (remove to remove URL checking)
					Gui, Font, s9 cWhite, Segoe UI 
					gui, add, edit, %gui_control_options% -VScroll vEditedURL, % sURL
				}
			}
			hk(0,0) ; safety in case you somehow manage to open a gui while locking the keyboard.
			gui, show,,DistracLess_2
			WinWaitNotActive,  DistracLess_2
			str:="list:(" sList ")|type:(" sType ")|name:(" EditedElement ")|URL:(" EditedURL ")"
			if ((EditedElement=".*") && (EditedURL=".*"))
			{
				ttip("Input not valid. You can only set either the URL or the title substring to '.*'")
				return
			}
			if ((EditedElement=".*") && (EditedURL=""))
			{
				ttip("Input not valid. You cannot use the '.*'-pattern to match all if you don't set a url")
				return
			}
			if ((sType="p") && (EditedElement=".*"))
			{
				ttip("Input not valid. You cannot set '.*'-name-wildcards for blacklisted programs, or you risk closing every program, always")
				return
			}
			if IniObj["Hidden Settings"].bEditDirectStringIn_f_EditArrayElement
				return EditedElement
			else
			{
				if (GuiAction="Escaped")
					return Element ; user didn't confirm possible changes, so feed back the original data
				Else
					return str
			}
		}
		Else 
		{
			GuiAction:="notDoubleClick_SkippedEdit"
			return 0
		}
	}
	GC2_Submit()
	{
		global EditedElement
		global EditedURL
		global GuiAction:="Submitted"
		gui, 2: submit
		return str
	}
	eAE_Escape()
	{
		global EditedElement
		global EditedURL .="GuiEscaped"
		global GuiAction:="Escaped"
		gui, 2: destroy
		return -1
	}
	
	f_ReadBackTestArraysFromFile(mode)
	{
		ActiveArrays:=[[],[]]
		StoredArrays:=[[],[]]
		if (mode=1)
			return [ActiveArrays,StoredArrays]
		Else if (mode=2)
		{
			StoredTestArrays:=ActiveTestArrays:=[]
			sReadBack:=fReadINI(A_ScriptDir . "\DistractLess_Storage\INI-Files\TestSettings.ini")
			return [sReadBack[1],sReadBack[2]]
		}
	}

	f_EnableDisableGuiElements(ArrayOfControlVariables,Enable1Disable0,GuiNumberOrIdentifier,AlsoDisable1OnlyHide0:=1)
	{ ; (enables+shows) or (disables+hides)  all gui-controls listed in "ArrayOfControlVariables" in Gui "GuiNumberOrIdentifier"
		if Enable1Disable0
			loop, % ArrayOfControlVariables.Length()
			{
				CurrentControl:=ArrayOfControlVariables[A_Index]
				if AlsoDisable1OnlyHide0
					GuiControl, %GuiNumberOrIdentifier%: enable, %CurrentControl%
				GuiControl, %GuiNumberOrIdentifier%: show, %CurrentControl%
			}
		else
			loop, % ArrayOfControlVariables.Length()
			{
				CurrentControl:=ArrayOfControlVariables[A_Index]
				if AlsoDisable1OnlyHide0
					GuiControl, %GuiNumberOrIdentifier%: disable, %CurrentControl%
				GuiControl, %GuiNumberOrIdentifier%: hide, %CurrentControl%
			}
		return
	}

	f_Confirm_Question(q,AU:="Gewerd Strauss",VN:="VNI",b:="Yes",b2:="No",Wrap:=1)
	{
		VNI=1.0.1.3	
		; thank you u/anonymous1184 for your help in reworking the previous version of this function.
		; https://www.reddit.com/r/AutoHotkey/comments/or8x0z/how_can_i_replace_my_labels_in_a_yesnoescapegui/h6gnlrf?utm_source=share&utm_medium=web2x&context=3
		
		; Note: the gui is 33* letters wide at the settings set in the function. 
		; Hence, the text is wrapped at that point if one chooses so to not make the proportions weird
		
		;* or the length of this piece of nonsense letters
		;abcdefghijklmnopqrstuvwxyz1234567
		; compared to this one, which will extend the width of the gui
		;abcdefghijklmnopqrstuvwxyz12345678
		global f_cQ_Callback := b3
		x:=y:=width:=height:=""
		gui, cQ: destroy
		loop, 2
		{
			Gui, cQ: New, -Caption +LastFound +ToolWindow +LabelcQ_ +AlwaysOnTop ; <- this doesn't work
			Gui, cQ: Margin, 16, 16
			Gui, cQ: Color, 1d1f21, 373b41, 
			Gui, cQ: Font, s11 cWhite, Segoe UI 
			if (A_Index=2)
			{
				if Wrap
					Gui, Add, Text, xm ym, % st_wordWrap(q,33)
				else
					Gui, Add, Text, xm ym, % q
			}
			Gui, Add, Button, xm+20  w30 gf_cQ_Callback, &%b%
			Gui, Add, Button, xm+170 yp w30 gf_cQ_Callback, &%b2%
			Gui, cQ: Font, s7 cWhite, Verdana
			if (VN="VNI")
				Gui, cQ: Add, Text,x25, Version: %VNI%	Author: %AU% 
			else
				Gui, cQ: Add, Text,x25, Version: %VN%	Author: %AU% 
			Gui, Show,, cQ
		}
		cQ_MoveOffset()
		GuiControl, Focus, %b2%
		SendInput, {Left}{Right}
		WinWaitClose
		gui, cQ: destroy
		;ttip(f_cQ_Callback)
		return {(b):1, (b2):0, (b3):-1}[f_cQ_Callback]
	}
	f_cQ_Callback()
	{
		global f_cQ_Callback := StrReplace(A_GuiControl,"&","")
		Gui, cQ: Destroy
	}
	cQ_Escape()
	{
		Gui, cQ:Destroy
	}
	cQ_MoveOffset()
	{
		yc:=A_ScreenHeight-200
		xc:=A_ScreenWidth-300
		Gui, cQ: show,autosize  x%xc% y%yc%, CQ%A_ThisLabel%
		WinGetPos,,,Width,Height,CQ%A_ThisLabel%
		NewXGui:=A_ScreenWidth-Width
		NewYGui:=A_ScreenHeight-Height
		Gui, cQ: show,autosize  x%NewXGui% y%NewYGui%, CQ%A_ThisLabel%
		Gui, cQ: show,autosize, CQ%A_ThisLabel%
		winactivate, CQ
		return answer
	}

	f_CreateStoredArrays(IncludeProgramParameters:=1)
	{ ; creates the Array to be stored to file by the various saving functions (Save LV's, as well as some OnExit-functions)
		global
		if IncludeProgramParameters
		{
			if !vACtiveFilterMode
				vACtiveFilterMode:="Both"
			if !bTrumping
				bTrumping:="White > Black"
			if !bCheckURLsInBrowsers
				bCheckURLsInBrowsers:="Yes"
			vActiveFilterMode.=  A_Space "; ActiveFilterMode"
			bTrumping.=  A_Space "; TrumpingRule"
			bCheckURLsInBrowsers.=  A_Space "; CheckUrlsInBrowsers"
			bIsProgramOn.=  A_Space "; bIsProgramOn"
			if bIsLocked && (IniObj["General Settings"].LockingBehaviour="Time-protected") && (DefaultTime!="")
			{
				vDefaultTime:= DefaultTime A_Space "; program is again unlocked after this timestamp"
				CurrentSettings:=[vActiveFilterMode,bTrumping,bCheckURLsInBrowsers,bIsProgramOn,vDefaultTime]
			}
			else
				CurrentSettings:=[vActiveFilterMode,bTrumping,bCheckURLsInBrowsers,bIsProgramOn]
		}
		if Instr(vActiveFilterMode,";")
			StringTrimRight, vActiveFilterMode, vActiveFilterMode, 19
		if Instr(bTrumping,";")
			StringTrimRight, bTrumping, bTrumping, 15
		if Instr(bCheckURLsInBrowsers,";")
			StringTrimRight, bCheckURLsInBrowsers, bCheckURLsInBrowsers, 22
		if Instr(bIsProgramOn,";")
			StringTrimRight, bIsProgramOn, bIsProgramOn, 15
		if Instr(vDefaultTime,";")
			StringTrimRight, vDefaultTime, vDefaultTime, 48
		if !bActiveSetIsOriginal ; last time the lManageTestSimulation was run, we have entered test mode - and the variables ActiveArrays/StoredArrays don't contain the "original" settings
		{ ; prevent the 
			temp_testFlag:=testFlag
			testFlag:=false
			SoundBeep, 1750, 150
			sleep, 300
			SoundBeep, 1750, 150
			sleep, 300
			gosub, lManageTestSimulation
		}
		if IncludeProgramParameters
			return Arr:=[ActiveArrays[1],ActiveArrays[2],StoredArrays[1],StoredArrays[2],CurrentSettings]
		Else
			return Arr:=[ActiveArrays[1],ActiveArrays[2],StoredArrays[1],StoredArrays[2]]
	}

	f_RestartWithLastBundle(ExitReason,ExitCode)
	{	; restarts the script from a hidden secondary script using a timer
		/*
			; restarts the script from a hidden secondary script using a timer
			; Logoff: The user is logging off.
			; Shutdown: The system is being shut down or restarted, such as by the Shutdown command.
			; Close: 	The script was sent a WM_CLOSE or WM_QUIT message, had a critical error, or is being 	closed in some other way. Although all of these are unusual, WM_CLOSE might be caused by WinClose having been used on the script's main window. To close (hide) the window without terminating the script, use WinHide.
			;	If the script is exiting due to a critical error or its main window being destroyed, it will unconditionally terminate after the OnExit thread completes.
			;	If the main window is being destroyed, it may still exist but cannot be displayed. This condition can be detected by monitoring the WM_DESTROY message with OnMessage().
			; Error: 	A runtime error occurred in a script that has no hotkeys and that is not persistent. An example of a runtime error is Run/RunWait being unable to launch the specified program or document.
			; Menu: 	The user selected Exit from the main window's menu or from the standard tray menu.
			; Exit: 	The Exit or ExitApp command was used (includes custom menu items).
			; Reload:	The script is being reloaded via the Reload command or menu item.
			; Single:	The script is being replaced by a new instance of itself as a result of #SingleInstance.
		*/
		global
		if bIsExitWOSaving ; cf bIsExitWOSaving/lExitWOSaving
			return
		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
			m(A_ThisFunc)
		Splitpath, A_ScriptFullPath,,ScriptPath
		; ttip("OverWritten:" OverWriteRestart:=GetKeyState("CapsLock", "p"))
		INI_File:=ScriptPath "\DistractLess_Storage\CurrentSettings"	
		Arr:=f_CreateStoredArrays()
		Count:=0
		loop, % Arr.MaxIndex() - 1
		{
			if (Arr[A_Index].MaxIndex()!="")
				Count+=Arr[A_Index].MaxIndex()
		}
		IF dbFlag
			m("Executing " A_ThisFunc,ExitReason,Arr)
		if !testFlag
			fWriteIni(Arr,INI_File)
		else
			m("No settings could be saved from the current setting, because the program was running in testsimulation-mode. Please exit this mode first before saving any settings.")
		if  (!GetKeyState("CapsLock", "p")) && (ExitReason ~= "iAD)Close|Error|Exit")  && !(ExitReason ~= "iAD)Logoff|Shutdown|Menu|Reload")
		{
			if A_IsCompiled
			{
				if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					m("Restarting now")
				run, %A_ScriptDir%\Library\DistractLess_Restart.exe
			}
			Else
			{
				if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					m("Restarting now")
				run, %A_ScriptDir%\Library\DistractLess_Restart.ahk
			}
		}
	}
	return
	f_RestartWithSpecificBundle(ExitReason,ExitCode)
	{
		global
		if bIsExitWOSaving ; cf bIsExitWOSaving/lExitWOSaving
			return
		ttip("OverWritten:" OverWriteRestart:=GetKeyState("CapsLock", "p"))
		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
			m(A_ThisFunc)
		if FileExist(IniObj["General Settings"].sDefaultBundle) && (IniObj["General Settings"].sDefaultBundle!="")
		{
			INI_File:=IniObj["General Settings"].sDefaultBundle
			if (st_count(INI_File,".ini")>0)
			{
				INI_File:=st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
				if (st_count(INI_File,".ini")>0)  
					INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance
			}
			tmparr:=fReadINI((A_ScriptDir "\" INI_File ".ini"))
			if bIsLocked && (IniObj["General Settings"].LockingBehaviour="Time-protected") && (DefaultTime!="")
			{
				vDefaultTime:=DefaultTime A_Space "; program is again unlocked after this timestamp"
				tmparr[5].push(vDefaultTime)
			}
			Splitpath, A_ScriptFullPath,,ScriptPath
			INI_File:=ScriptPath "\DistractLess_Storage\CurrentSettings"
			if (SubStr(INI_File,-4,4)==".ini")
				INI_File:=SubStr(INI_File,1, (StrLen(INI_File)-4))
			if !testFlag
				fWriteIni(tmparr,INI_File)
		}
		Else
		{
			Splitpath, A_ScriptFullPath,,ScriptPath
			INI_File:=ScriptPath "\DistractLess_Storage\CurrentSettings"
			Arr:=f_CreateStoredArrays()
			Count:=0
			loop, % Arr.MaxIndex() - 1
			{
				if (Arr[A_Index].MaxIndex()!="")
					Count+=Arr[A_Index].MaxIndex()
			}
			IF dbFlag
				m("Executing " A_ThisFunc,ExitReason,Arr)
			if !testFlag 
				fWriteIni(Arr,INI_File)
			else
				m("No settings could be saved from the current setting, because the program was running in testsimulation-mode. Please exit this mode first before saving any settings.")
		}
		if  (!OverWriteRestart) && (ExitReason ~= "iAD)Close|Error|Exit")  && !(ExitReason ~= "iAD)Logoff|Shutdown|Menu|Reload") ; at this point, the actual ation of the reload fn is already finished → means reloading via menu or reload doesn't need to invoke _another_ reload
		{
			if A_IsCompiled
			{
				if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					m("Restarting now")
				run, %A_ScriptDir%\Library\DistractLess_Restart.exe
			}
			Else
			{
				if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					m("Restarting now")
				run, %A_ScriptDir%\Library\DistractLess_Restart.ahk
			}
		}
	}
	return
	f_RestartEmpty(ExitReason,ExitCode)
	{	
		global
		if bIsExitWOSaving ; cf bIsExitWOSaving/lExitWOSaving
			return
		ttip("OverWritten:" OverWriteRestart:=GetKeyState("CapsLock", "p"))
		if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin)
			m(A_ThisFunc)
		/*
			; restarts the script from a hidden secondary script using a timer
			; Logoff: The user is logging off.
			; Shutdown: The system is being shut down or restarted, such as by the Shutdown command.
			; Close: 	The script was sent a WM_CLOSE or WM_QUIT message, had a critical error, or is being closed in some other way. Although all of these are unusual, WM_CLOSE might be caused by WinClose having been used on the script's main window. To close (hide) the window without terminating the script, use WinHide.
			;	If the script is exiting due to a critical error or its main window being destroyed, it will unconditionally terminate after the OnExit thread completes.
			;	If the main window is being destroyed, it may still exist but cannot be displayed. This condition can be detected by monitoring the WM_DESTROY message with OnMessage().
			; Error 	A runtime error occurred in a script that has no hotkeys and that is not persistent. An example of a runtime error is Run/RunWait being unable to launch the specified program or document.
			; Menu: 	The user selected Exit from the main window's menu or from the standard tray menu.
			; Exit: 	The Exit or ExitApp command was used (includes custom menu items).
			; Reload:	The script is being reloaded via the Reload command or menu item.
			; Single:	The script is being replaced by a new instance of itself as a result of #SingleInstance.
		*/
		if  (!OverWriteRestart) && (ExitReason ~= "iAD)Close|Error|Exit")  && !(ExitReason ~= "iAD)Logoff|Shutdown|Menu|Reload")
		{
			if A_IsCompiled
			{
				if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					m("Restarting now")
				run, %A_ScriptDir%\Library\DistractLess_Restart.exe
			}
			Else
			{
				if (GetKeyState("CapsLock","T") and bIsDevPC and !bLockOutAdmin) 
					m("Restarting now")
				run, %A_ScriptDir%\Library\DistractLess_Restart.exe
			}
		}
	}
	return
	f_DoNothingOnExit(ExitReason,ExitCode)
	{
		if bIsExitWOSaving ; cf bIsExitWOSaving/lExitWOSaving
			return
	}
	return

	f_ThrowError(Source,Message,ErrorCode:=0,ReferencePlace:="S")
	{ ; throws an error-message, possibly with further postprocessing
		if (ReferencePlace="D")
			Reference:="Documentation"
		else 
			Reference:="Source Code: Function called on line " ReferencePlace "`nError invoked in function body on line " Exception("", -1).Line
		if (ErrorCode!=0)
		{
			str=
	(
	Function: %Source%
	Errorcode: "%ErrorCode%" - Refer to %Reference%

	Error: 
	%Message%
	)
		}
		else
		{
			str=
	(
	Function: %Source%	
	Errorcode: Refer to %Reference%

	Error: 
	%Message%
	)
		}
		MsgBox, % str
		return
	}
	
	;bCheckURLsInBrowsers sURL sCurrURL
	f_CloseCurrentWindow(sCurrWindowTitle,sCurrClass,sCurrExe,sCurrURL,stype,MatchedTitleEntry,WindowID,BrowserClasses,BrowserExes,bCheckURLsInBrowsers,sURL,vActiveFilterMode,bWhiteTrumpedThisTitle)
	{ ; closes the current window according to its type: webbrowser → Ctrl+W, program → WinClose
		if dbFlag
			ttip(A_ThisFunc "0" sCurrWindowTitle "||" sCurrClass "||" sCurrExe,4)
		bActionWasClosed:=false ; give out the return value to feed back if last window has been closed or not. 
		if (sCurrWindowTitle="") || (sCurrClass="") || (sCurrExe="")
		{
			if dbFlag
				ttip(A_ThisFunc "1" ) ;sCurrWindowTitle "||" sCurrClass "||" sCurrExe,4)
			return
		}
		if dbFlag
			ttip(A_ThisFunc "2")
		;____________
		; disable all keys and mouse functionality → Win+L still works, because that hook is too deeply build into windows.
		BlockInput, On
		if ((HasVal(BrowserExes,sCurrExe)) && (HasVal(BrowserClasses,sCurrClass)) && (WinACtive(sCurrWindowTitle) && (stype="w"))) || ((WinActive("A") && WinACtive(sCurrWindowTitle) && !((HasVal(BrowserClasses,sCurrClass)) && (HasVal(BrowserExes,sCurrExe))) && (stype="p")))
		{
			if (IniObj["General Settings"].bEnableBlockingBanner)
				hk(1,1,"Blocking User Input")
			Else
				hk(1,1)
		}
		;____________
		if dbFlag
			ttip(A_ThisFunc "3")
		;SetTimer, lEmergencyUnlock, -12000 ; set an emergency label to restore kbm functionality in case this locks up (which it absolutely shouldn't)
		if !(dbFlag) ; normal behaviour
		{
			; if dbFlag
			; 	ttip(A_ThisFunc "4")
			if (HasVal(BrowserExes,sCurrExe)) && (HasVal(BrowserClasses,sCurrClass)) && (WinACtive(sCurrWindowTitle) && (stype="w")) ; fallback check to ensure the window we are closing is still active, and we are not closing another one because the user has moved on already
			{
				; if dbFlag
				; 	ttip(A_ThisFunc "5")
				; if (bCheckURLsInBrowsers="Yes")
				; {
					; if dbFlag
					; 	ttip(A_ThisFunc "6")
					; m(sCurrURL,sURL)
					if (!Instr(sCurrURL,sURL) and (vActiveFilterMode!="white")) && (sURL!=".*")
					{
						; if dbFlag
						; 	ttip(A_ThisFunc "7")
						BlockInput, Off
						bInputIsLocked:=true
						if (IniObj["General Settings"].bEnableBlockingBanner)
							hk(0,0,"Allowing User Input",0.5)
						Else
							hk(0,0)
						SetTimer, lEmergencyUnlock, off
						; if dbFlag
						; 	ttip(A_ThisFunc "8",4)
						return bActionWasClosed:=false ; we are returning early, so we need to reenable user input again, as we are not following through to the end of the function.
					}
				; }
				; if dbFlag
				; 	ttip(A_ThisFunc "9",4)
				if WinActive(sCurrWindowTitle)
					SendInput, ^w
				sleep, 200
				; if dbFlag
				; 	ttip(A_ThisFunc "10",4)
				; WinWaitClose, %sCurrWindowTitle%
				; if dbFlag
				; 	ttip(A_ThisFunc "11",4)
				; sleep, 120
			}
			Else if WinActive("A") && WinActive(sCurrWindowTitle) && !((HasVal(BrowserClasses,sCurrClass)) && (HasVal(BrowserExes,sCurrExe))) && (stype="p") ; Window is not a browser → use winclose. Both checks are necessary to sort out the many windows that share a class with BrowserClasses, while not being a browser for the sake of this.
			{
				; if dbFlag
				; 	ttip(A_ThisFunc "12",4)
				WinClose, 
				sleep, 200
				; WinWaitClose, %sCurrWindowTitle%
				bActionWasClosed:=true
			}
		}
		else															; debug behaviour
		{
			if dbFlag
				ttip(A_ThisFunc "4")
			if (HasVal(BrowserExes,sCurrExe)) && (HasVal(BrowserClasses,sCurrClass)) && (WinACtive(sCurrWindowTitle) && (stype="w")) ; fallback check to ensure the window we are closing is still active, and we are not closing another one because the user has moved on already
			{
				if dbFlag
					ttip(A_ThisFunc "5")
				; if (bCheckURLsInBrowsers="Yes")
				; {
					if dbFlag
						ttip(A_ThisFunc "6")
					; m(sCurrURL,sURL)
					
					
					;; I HAVE NO IDEA WHAT THIS SECTION IS FOR... that's what you comment your code for.
					; if !Instr(sCurrURL,sURL) and (vActiveFilterMode!="white")
					; {
					; 	if dbFlag
					; 		ttip(A_ThisFunc "7")
					; 	BlockInput, Off
					; 	bInputIsLocked:=true
					; 	if (IniObj["General Settings"].bEnableBlockingBanner)
					; 		hk(0,0,"Allowing User Input",0.5)
					; 	Else
					; 		hk(0,0)
					; 	SetTimer, lEmergencyUnlock, off
					; 	if dbFlag
					; 		ttip(A_ThisFunc "8",4)
					; 	return bActionWasClosed:=false ; we are returning early, so we need to reenable user input again, as we are not following through to the end of the function.
					; }
				; }
				if dbFlag
					ttip(A_ThisFunc "9",4)
				
					; sURL:=""
				str:="Browser Match:`n`nFilterMode: [[" vActiveFilterMode "]]`nTrumping Rule: [[" (bWhiteTrumpedThisTitle? "white > black":"black > white") "]]`nWindow Title [[" sCurrWindowTitle "]]`nhas been chosen to close.`nMatchedTitleEntry: [[" MatchedTitleEntry "]]" (MatchedTitleEntry=".*"?" - See Current URL and Matched URL for more Info":"")"`n________`nCurrent URL: [["sCurrURL "]]`nMatched URL: [[" (sURL? sURL:"no URL given") "]]`n________`nCurrent Class: [[" sCurrClass "]]`nCurrent Exe: [[" sCurrExe "]]`nWindow ID: [[" WindowID "]]`n"
				if dbFlag
					ttip(A_ThisFunc "10",4)
				if IniObj["General Settings"].EnableDiagnosticMode
					ttip(A_ThisFunc "11",4)
			}
			Else if WinActive("A") && WinACtive(sCurrWindowTitle) && !((HasVal(BrowserClasses,sCurrClass)) && (HasVal(BrowserExes,sCurrExe))) && (stype="p") ; Window is not a browser → use winclose. Both checks are necessary to sort out the many windows that share a class with BrowserClasses, while not being a browser for the sake of this.
			{
				if dbFlag
					ttip(A_ThisFunc "12",4)
				str:="Program  Match:`n`nFilterMode: [[" vActiveFilterMode "]]`nTrumping Rule: [[" (bWhiteTrumpedThisTitle? "white > black":"black > white") "]]`nWindow Title [[" sCurrWindowTitle "]] has been chosen to close.`nMatchedTitleEntry: [[" MatchedTitleEntry "]]`n________`nCurrent Class: [[" sCurrClass "]]`nCurrent Exe: [[" sCurrExe "]]`nWindow ID: [[" WindowID "]]`n"
				bActionWasClosed:=true
			}
		}
		
		if ((HasVal(BrowserExes,sCurrExe)) && (HasVal(BrowserClasses,sCurrClass)) && (WinACtive(sCurrWindowTitle) && (stype="w"))) || ((WinActive("A") && WinACtive(sCurrWindowTitle) && !((HasVal(BrowserClasses,sCurrClass)) && (HasVal(BrowserExes,sCurrExe))) && (stype="p")))
		{	
			if (IniObj["General Settings"].bEnableBlockingBanner)
				hk(0,0,"Allowing User Input",0.5)
			Else
				hk(0,0)
		}	
		SetTimer, lEmergencyUnlock, off
		;  order matters → if we open the messagebox first, the entire PC is softlocked because code cannot progress, and the code-stopping msgbox cannot be closed because the input is fully blocked.
		if dbFlag ; debug behaviour
		{
			if (str!="")
			{
				ttip(A_ThisFunc "13: Closing " sCurrWindowTitle " with Class " sCurrClass)
				if (IniObj["General Settings"].bEnableBlockingBanner) ; make sure we are not softlocking the program
					hk(0,0)
				m("Diagnostics:`n" (stype="w"? "Website will be closed.":"Program will be closed." ) "`n" str)
			}
		}
		if (IniObj["General Settings"].bEnableBlockingBanner)
				hk(0,0,"Allowing User Input",0.5)
			Else
				hk(0,0)
		BlockInput, Off
		if dbFlag
			ttip(A_ThisFunc "14",4)
		return bActionWasClosed
		
		
		lEmergencyUnlock:
		hk(0,0)
		SetTimer, lEmergencyUnlock, off
		; ttip(A_ThisLabel "15",4)
		Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime
		return 
	}
	
	f_CheckFocusChange()
	{ ; tested for checking focus change, but not sure this would even work. 
		global 
		PrevFocusedCtrl:=FocusedCtrl
		GuiControlGet, FocusedCtrl, Focus
		ToolTip, % "PrevFocusedCtrl: " PrevFocusedCtrl "`n`n" "FocusedCtrl: " FocusedCtrl
		If (PrevFocusedCtrl!=FocusedCtrl)
			return 1
		SetTimer RemoveToolTip,-3000
	}
	f_ToggleStartup(bBootSetting)
	{
		startUpDir:=(A_Startup "\" A_ScriptName " - Shortcut.lnk")
		if bBootSetting 
			FileCreateShortcut, %A_ScriptFullPath%, %startUpDir%
		else
			FileDelete, %startUpDir%
		return
	}
	

	f_CreateTrayMenu(IniObj)
	{ ; facilitates creation of the tray menu
		; global vAllowedTogglesCount
		VNI=1.0.0.6
		menu, tray, Add, Show Gui, Gui1_ShowLogic
		menu, tray, add,
		Menu, Misc, add, Open Script-folder, lOpenScriptFolder
		Menu, Misc, add, Open Settings, lOpenSettings
		menu, Misc, Add, Reload, lReload
		menu, Misc, Add, About, Label_AboutFile
		;bLockOutAdmin:=bLockOutAdmin+0
		if (bIsDevPC) ; toggle to add development buttons easier. 
		{
			;m(bIsDevPC,bLockOutAdmin,exception.Line())
			menu, Misc, Add, DEV: Hidden Settings, lHiddenSettings
			menu, Misc, Add, DEV: Edit Settings File, lEditSettingsOverall
			menu, Misc, Add, DEV: RESET SETTINGS, lResetSettingsForTesting
			menu, Misc, Add, DEV: Exit App without saving anything, lExitWOSaving
		}
		SplitPath, A_ScriptName,,,, ScriptName
		f_AddStartupToggleToTrayMenu(ScriptName,"Misc")
		Menu, tray, add, Miscellaneous, :Misc
		menu, tray, add,
		return
	}
	lExitWOSaving:
	; this is useful if you just want to terminate the program without altering any files. Only accessible to Devs.
	global bIsExitWOSaving:=true
	OnExit("f_DoNothingOnExit",-1)
	ExitApp
	return
	
	lResetSettingsForTesting: ; necessary for testing mostly. 
	{ ; developer shortcut for resetting the settings.
		OnExit("f_RestartWithLastBundle") ; when rewriting settings, we don't want to loose our currently set-up conditions.
		FileCopy, %A_ScriptDir%\DistractLess_Storage\INI-Files\DistractLessSettings.ini, %A_ScriptDir%\DistractLess_Storage\INI-Files\DistractLessSettings_ResetBackup.ini, 1
		FileDelete, %A_ScriptDir%\DistractLess_Storage\INI-Files\DistractLessSettings.ini
		sleep, 200	
		reload
	}
	return

	f_AddStartupToggleToTrayMenu(ScriptName,MenuNameToInsertAt:="Tray")
	{ ; add a toggle to create a link in startup folder for this script to the respective menu
		VNI=1.0.0.1
		global startUpDir 
		global MenuNameToInsertAt2
		global bBootSetting
		MenuNameToInsertAt2:=MenuNameToInsertAt
		startUpDir:=(A_Startup "\" A_ScriptName " - Shortcut.lnk")
		Menu, %MenuNameToInsertAt%, add, Start at Boot, lStartUpToggle
		If FileExist(startUpDir)
		{
			Menu, %MenuNameToInsertAt%, Check, Start at Boot
			bBootSetting:=1
		}
		else
		{
			Menu, %MenuNameToInsertAt%, UnCheck, Start at Boot
			bBootSetting:=0
		}
		return
		lStartUpToggle: ; I could really use a better way to know the name of the menu item that was selected
		if !bBootSetting 
		{
			bBootSetting:=1
			FileCreateShortcut, %A_ScriptFullPath%, %startUpDir%
			Menu, %MenuNameToInsertAt2%, Check, Start at Boot
		}
		else if bBootSetting
		{
			bBootSetting:=0
			; FileDelete, %startUpDir%
			Menu, %MenuNameToInsertAt2%, UnCheck, Start at Boot
		}
		return
		
		/* Original from Exaskryz: https://www.autohotkey.com/boards/viewtopic.php?p=176247#p176247
			Menu, Tray, UseErrorLevel
			
			If FileExist(startUpDir:=("C:\Users\" A_UserName "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\" A_ScriptName " - Shortcut.lnk"))
				Menu, Tray, Add, Remove from StartUp, StartUpToggle
			else
				Menu, Tray, Add, Add to StartUp, StartUpToggle
			GoSub, SkipLabel_StartUp
			return
			
			StartUpToggle: ; I could really use a better way to know the name of the menu item that was selected
			; Using now errorlevel to determine if the menu item name exists
			Menu, Tray, Rename, Remove from StartUp, Add to StartUp
			If ErrorLevel ; Remove from StartUp doesn't exist. So Add to StartUp does. So we're adding this script to startup
			{
				FileCreateShortcut, %A_ScriptFullPath%, %startUpDir%
				Menu, Tray, Rename, Add to StartUp, Remove from StartUp
			}
			else ; we successfully renamed the Remove from StartUp, which means that was selected, so we need to remove the script from startup
				FileDelete, %startUpDir%
			return
			
			SkipLabel_StartUp:
			
			
		*/
	}
	lEditSettingsOverall:
	; gui, 1: destroy
	; gui, 99: destroy
	; gui, color
	; gui, font
	; gui, 99: new
	; lChooseFile:=false
	; FedFile:= IniSettingsFilePath
	; bMainGuiDestroyed:=true
	; Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
	gosub, lIniFileCreator
	; #Include %A_MyDocuments%\AutoHotkey\Lib\IniFileCreator_v8.ahk
	; sleep, 3000
	WinWaitNotActive, IniFileCreator 8
	gosub, lGuiCreate_1
	Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer once we've closed the window
	return
	gui, 1: destroy
	gui, 99: destroy
	gui, color
	gui, font
	gui, 99: new
	lChooseFile:=false
	FedFile:= IniSettingsFilePath
	bMainGuiDestroyed:=true
	Settimer, lEnforceRules, off ; disable the timer to save performance while editing the settings
	#Include %A_ScriptDir%\Library\IniFileCreator_v8.ahk ; can't continue on this cuz of restricted file access
	;#Include %A_MyDocuments%\AutoHotkey\Lib\IniFileCreator_v8.ahk
	gosub, lIniFileCreator
	WinWaitNotActive, IniFileCreator 8
	; gosub, lGuiCreate_1
	Settimer, lEnforceRules, % IniObj["GeneralSettings"].RefreshTime ; reactivate the timer once we've closed the window
	return 
	lHiddenSettings:
	DL_IniSettingsEditor("DistractLess",IniSettingsFilePath,0,0,1)
	return
	lOpenSettings:
	DL_IniSettingsEditor("DistractLess",IniSettingsFilePath,0,0,0)
	return
	lOpenScriptFolder:
	run, % A_ScriptDir
	return
	lReload:
	if (IniObj["General Settings"].OnExitBehaviour="Restart with current bundle")
		OnExit("f_RestartWithLastBundle")
	else if (IniObj["General Settings"].OnExitBehaviour="Empty Restart")
		OnExit("f_RestartEmpty")
	else if (IniObj["General Settings"].OnExitBehaviour="Restart with specific bundle")
		OnExit("f_RestartWithSpecificBundle")
	reload
	return

	ttip(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",to2:=1750,currTip:=20)
	{
		/*
			Date: 24 Juli 2021 19:40:56: Modes:  
			1: remove tt after "to" seconds 
			2: remove tt after "to" seconds, but show again after "to2" seconds. Then repeat 
			3: not sure anymore what the plan was lol - remove 
			4: shows tooltip slightly offset from current mouse, does not repeat
			5: keep that tt until the function is called again  
			----  Function uses tooltip 20 by default, use parameter
			"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
			separately from each other, hence a removal of ttip20 will not remove tt14 
		*/
		
		;if (text="TTIP: Test")
			;m(to)
		if (text="")
			gosub, lRemovettip
		static ttip_text
		static lastcall_tip
		static CurrTip2
		tooltip,
		if (mode=99)
		{
			SetTimer, lRepeatedshow, off	
			return
		}
		currTip2:=currTip
		ttip_text:=text
		lUnevenTimers:=false 
		MouseGetPos,xp1,yp1
		if (mode=4) ; set text offset from cursor
		{
			yp:=yp1+15
		}	
		else
		{
			if (xp="NaN")
				xp:=xp1
			if (yp="NaN")
				yp:=yp1
		}
		tooltip, % ttip_text,xp,yp,% currTip
		if (mode=1) ; remove after given time
		{
			SetTimer, lRemovettip, % "-" to
		}
		else if (mode=2) ; remove, but repeatedly show every "to"
		{
			if (to2>to)
				SetTimer, lRepeatedshow, %  to2
			else 
				SetTimer, lRepeatedshow, %  to
		}
		else if (mode=3)
		{
			lUnevenTimers:=true
			SetTimer, lRepeatedshow, %  to
		}
		else if (mode=5) ; keep until function called again
		{
			
		}
		else if (mode=99)
			SetTimer, lRepeatedshow, off
		return
		lRepeatedshow:
		tooltip, % ttip_text,,,20
		if lUnevenTimers
			sleep, % to2
		Else
			sleep, % to
		return
		lRemovettip:
		;m("hi there")
		Tooltip,,,,currTip2
		return
	}

	LogError(exception) 
	{ ; write error messages to file. Log-File is deleted if greater than 30 MB
		If Instr(exception.File,"DistractLess_WindowSpy.ahk")
			return -1
		FileAppend % "Error on line " exception.Line ": " exception.Message "`n", errorlog.txt
		return true
	}
	f_FixInfoTextLinesInIniFile(DefSettings,IniSettingsFilePath)
	{ ; a maybe successful attempt at resolving the Description-Lines of the Ini-file being muddied when using the IniSettingsEditor
		FileRead, StoredFile, %IniSettingsFilePath%
		StoredFileLines:=StrSplit(StoredFile,"`n")
		TemplateFileLines:=StrSplit(DefSettings,"`n")
		OutArr:=[]
		newArr:=[]
		Ind:=1
		str:=""
		for k,v in StoredFileLines
		{
			if Instr(SubStr(v,1,1),";") ; we are  in a comment line → check
			{
				if (Substr(v,0)="`r")
					v:=Substr(v,1,StrLen(v)-1)
				if HasVal(TemplateFileLines,v)
					newArr.push(v)
			}
			else
			{
				str.=v "`r`n"
				newArr.push(v)
			}
		}
		for k,v in newArr
			str.=v "`n"
  		return [newArr,str]
	}
	;}_____________________________________________________________________________________
	;{#[Include Section]
/*
	For all functions, see the function definition and associated documentation for more details. License-files are located under A_SCriptDir\DistractLess_Storage\licenses where required.
	All Functions below have the URL at which they were retrieved stated.
	HasVal | jNizM | https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
	st_wordwrap | tidbit | located at https://www.autohotkey.com/boards/viewtopic.php?t=53
	st_removeDuplicates | s.a.
	st_count | s.a.
	WriteINI/ReadINI | wolf_II | adopted from https://www.autohotkey.com/boards/viewtopic.php?p=256714#p256714
	hk | this specific version by SpeedMaster, original by feiyue | adopted from https://www.autohotkey.com/boards/viewtopic.php?p=283777#p283777
	HideFocusBorder | this specific version by "just me" | adopted from https://www.autohotkey.com/boards/viewtopic.php?p=55162#p55162
	getURL | anonymous1184 | adopted from reddit: https://www.reddit.com/r/AutoHotkey/comments/mqnuql/comment/guinpck/?utm_source=share&utm_medium=web2x&context=3
	ACC.ahk | could not find definitive author | retrieved from https://www.autohotkey.com/boards/viewtopic.php?t=26201
	CodeTimer | CodeKnight | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=316296#p316296
	f_TrayIconSingleClickCallBack | Lexikos, afaik | retrieved from https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954
	NotifyTrayClick | SKAN | retrieved from https://www.autohotkey.com/boards/viewtopic.php?t=81157
	
	
	TF_ReplaceInLines | forum name ahk7, github hi5 | retrieved from https://www.autohotkey.com/boards/viewtopic.php?f=6&t=576
	TF_GetData | s.a.
	_MakeMatchList | s.a.
	TF_ReturnOutPut | s.a.
	; IniSettingsEditor v6 see below.
	IniSettingsEditor v6 | Rajat, mod by toralf | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=237927#p237927, specifically gamax92_archive of the download
	IniFileCreator_v8 |  toralf, modded by Gewerd Strauss | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=237927#p237927, specifically gamax92_archive of the download
	; retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=237927#p237927, specifically gamax92_archive of the download. 
	
*/


	HasVal(haystack, needle) 
	{	; code from jNizM on the ahk forums: https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
 		if !(IsObject(haystack)) || (haystack.Length() = 0)
			return 0
		for index, value in haystack
			if (value = needle)
				return index
		return 0
	}
	
	
	fWriteINI(ByRef Array2D, INI_File)  ; write 2D-array to INI-file
	{ ; writes associative, multilevel settings array to file
		if !FileExist("INI-Files") ; check for ini-files directory
		{
			;MsgBox, Creating "INI-Files"-directory at Location`n"%A_ScriptDir%", containing an ini-file named "%INI_File%.ini"
			; FileCreateDir, INI-Files
		}
		if (fWriteINI_st_count(INI_File,".ini")>0)
		{
			INI_File:=fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
			if (fWriteINI_st_count(INI_File,".ini")>0)  
				INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance

		}
		for SectionName, Entry in Array2D 
		{
			Pairs := ""
			for Key, Value in Entry
				Pairs .= Key "=" Value "`n"
			IniWrite, %Pairs%, %INI_File%.ini, %SectionName%
		}
		
		/* Original File from https://www.autohotkey.com/boards/viewtopic.php?p=256714#p256714
			
		;-------------------------------------------------------------------------------
			WriteINI(ByRef Array2D, INI_File) { ; write 2D-array to INI-file
		;-------------------------------------------------------------------------------
				for SectionName, Entry in Array2D {
					Pairs := ""
					for Key, Value in Entry
						Pairs .= Key "=" Value "`n"
					IniWrite, %Pairs%, %INI_File%, %SectionName%
				}
			}
		*/
	}
	fWriteINI_st_removeDuplicates(string, delim="`n")
	{ ; remove all but the first instance of 'delim' in 'string'
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
		/*
			RemoveDuplicates
			Remove any and all consecutive lines. A "line" can be determined by
			the delimiter parameter. Not necessarily just a `r or `n. But perhaps
			you want a | as your "line".
			
			string = The text or symbols you want to search for and remove.
			delim  = The string which defines a "line".
			
			example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
			output:  aaa|bbb|ccc|ddd
		*/
		delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
		Return RegExReplace(string, "(" delim ")+", "$1")
	}
	
	fWriteINI_st_count(string, searchFor="`n")
	{ ; count number of occurences of 'searchFor' in 'string'
		; copy of the normal function to avoid conflicts.
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
		/*
			Count
			Counts the number of times a tolken exists in the specified string.
			
			string    = The string which contains the content you want to count.
			searchFor = What you want to search for and count.
			
			note: If you're counting lines, you may need to add 1 to the results.
			
			example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
			output:  4
		*/
		StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
		return ErrorLevel
	}



	fReadINI(INI_File) ; return 2D-array from INI-file
	{ ; reads associative, multilevel settings array from file
		
		Result := []
		OrigWorkDir:=A_WorkingDir
		SetWorkingDir, INI-Files
		IniRead, SectionNames, %INI_File%
		for each, Section in StrSplit(SectionNames, "`n") {
			IniRead, OutputVar_Section, %INI_File%, %Section%
			for each, Haystack in StrSplit(OutputVar_Section, "`n")
				RegExMatch(Haystack, "(.*?)=(.*)", $)
			, Result[Section, $1] := $2
		}
		if A_WorkingDir!=OrigWorkDir
			SetWorkingDir, %OrigWorkDir%
		return Result
		/* Original File from https://www.autohotkey.com/boards/viewtopic.php?p=256714#p256714
		;-------------------------------------------------------------------------------
			ReadINI(INI_File) { ; return 2D-array from INI-file
		;-------------------------------------------------------------------------------
				Result := []
				IniRead, SectionNames, %INI_File%
				for each, Section in StrSplit(SectionNames, "`n") {
					IniRead, OutputVar_Section, %INI_File%, %Section%
					for each, Haystack in StrSplit(OutputVar_Section, "`n")
						RegExMatch(Haystack, "(.*?)=(.*)", $)
				, Result[Section, $1] := $2
				}
				return Result
		*/
	}
	
	hk(keyboard:=false, mouse:=0, message:="", timeout:=3, displayonce:=false,screen:=false, screencolor:="blue") 
	{ ; disables the keyboard without relying on admin privileges. Can hide the screen and or show a message
		; retrieved 20.09.2021 20:56:58 at https://www.autohotkey.com/boards/viewtopic.php?p=283777#p283777
		
		;keyboard (true/false).......................... disable/enable keyboard
		;mouse=1........................................ disable all mouse buttons
		;mouse=2........................................ disable right mouse button only
		;msessage....................................... display a message
		;timeout........................................ how long to display the message in sec
		;displayonce (true/false) ...................... display a message only once or always
		;hide the screen (true/false)................... hide or show everything
		;ScreenColor ................................... RGB Hex background color for the hiding GUI 
		
		
		static AllKeys, z, d, kb, ms, sc
		z:=message, d:=displayonce, kb:=keyboard, ms:=mouse, sc:=screen
		
		For k,v in AllKeys {
			Hotkey, *%v%, Block_Input, off         ; initialisation
		}
		if !AllKeys {
			s := "||NumpadEnter|Home|End|PgUp|PgDn|Left|Right|Up|Down|Del|Ins|"
			Loop, 254
				k := GetKeyName(Format("VK{:0X}", A_Index))
		, s .= InStr(s, "|" k "|") ? "" : k "|"
			For k,v in {Control:"Ctrl",Escape:"Esc"}
				AllKeys := StrReplace(s, k, v)
			AllKeys := StrSplit(Trim(AllKeys, "|"), "|")
		}
		;------------------
		if (mouse!=2)  ; if mouse=1 disable right and left mouse buttons  if mouse=0 don't disable mouse buttons
		{
			For k,v in AllKeys {
				IsMouseButton := Instr(v, "Wheel") || Instr(v, "Button")
				Hotkey, *%v%, Block_Input, % (keyboard && !IsMouseButton) || (mouse && IsMouseButton) ? "On" : "Off"
			}
		}
		if (mouse=2)   ;disable right mouse button (but not left mouse)
		{                
			ExcludeKeys:="LButton"
			For k,v in AllKeys {
				IsMouseButton := Instr(v, "Wheel") || Instr(v, "Button")
				if v not in %ExcludeKeys%
					Hotkey, *%v%, Block_Input, % (keyboard && !IsMouseButton) || (mouse && IsMouseButton) ? "On" : "Off"
			}
		}
		if d
		{
			if (z != "") {
				Progress, +AlwaysOnTop W2000 H43 b zh0 cwFF0000 FM20 CTFFFFFF,, %z%
				SetTimer, TimeoutTimer, % -timeout*1000
			}
			else
				Progress, Off
		}
		Block_Input:
		if (d!=1)
		{
			if (z != "") {
				if (kb || ms)
					Progress, W2000 H43 b zh0 cwFF0000 FM20 CTFFFFFF,, %z%
				else
					Progress, W2000 H43 b zh0 cw009F00 FM20 CTFFFFFF,, %z%
				SetTimer, TimeoutTimer, % -timeout*1000
			}
			else
				Progress, Off
		}
		
		
		if (sc=1)
		{
			;SysGet,vNumCount, MonitorCount
			;for k,v in % vNumCount
			;{
				;SysGet, vMonC, Monitor, %v%
				;m(vMonCLeft,vMonCTop,vMonCRight,vMonCBottom)
				;vWidthC:=vMonCRight-vMonCLeft
				;vHeightC:=vMonCTop-vMonCBottom
				v:="Screen"
				Gui %v%:  -Caption
				Gui %v%: Color,  % screencolor
				Gui %v%: Show, x0 y0 h74 w%a_screenwidth% h%a_screenheight%, New GUI Window
				Gui screen:  -Caption
				Gui screen: Color,  % screencolor
				Gui screen: Show, x0 y0 h74 w%a_screenwidth% h%a_screenheight%, New GUI Window
			;}
		}
		else
			gui screen: Hide
		
		
		Return 
		TimeoutTimer:
		Progress, Off
		Return
	}
	
	HideFocusBorder(wParam, lParam := "", uMsg := "", hWnd := "") 
	{ ; removes the focus border from a gui control
		;  fetched from https://www.autohotkey.com/boards/viewtopic.php?t=9684, version from "just me", adapted
		; ==================================================================================================================================
		; Hides the focus border for the given GUI control or GUI and all of its children.
		; Call the function passing only the HWND of the control / GUI in wParam as only parameter.
		; WM_UPDATEUISTATE  -> msdn.microsoft.com/en-us/library/ms646361(v=vs.85).aspx
		; The Old New Thing -> blogs.msdn.com/b/oldnewthing/archive/2013/05/16/10419105.aspx
		; ==================================================================================================================================
		; WM_UPDATEUISTATE = 0x0128
		Static Affected := [] ; affected controls / GUIs
			, HideFocus := 0x00010001 ; UIS_SET << 16 | UISF_HIDEFOCUS
			, OnMsg := OnMessage(0x0128, Func("HideFocusBorder"))
		If (uMsg = 0x0128) { ; called by OnMessage()
			If (wParam = HideFocus)
				Affected[hWnd] := True
			Else If Affected[hWnd]
				PostMessage, 0x0128, %HideFocus%, 0, , ahk_id %hWnd%
		}
		Else If DllCall("IsWindow", "Ptr", wParam, "UInt")
			PostMessage, 0x0128, %HideFocus%, 0, , ahk_id %wParam%
	}
	
	
	
	fgetUrl(hWnd)
	{ ; obtains the url of the current browser window. works in chrome, firefox, IE and opera. 
		/*
			retrieved from https://www.reddit.com/r/AutoHotkey/comments/mqnuql/comment/guinpck/?utm_source=share&utm_medium=web2x&context=3
		*/
		accWindow := Acc_ObjectFromWindow(hWnd)
		Out:=getAddressBar(accWindow).accValue(0)
		return Out
	}
	getAddressBar(accObj)
	{
		if (accObj.accRole(0) == 42
		&& accObj.accValue(0) != "")
			return accObj
		for i,accChild in Acc_Children(accObj)
			if IsObject(accObj := %A_ThisFunc%(accChild))
				return accObj
	}
	
	Acc_Init()
	{
		static h
		If Not h
			h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
	}
	Acc_ObjectFromWindow(hWnd, idObject = 0)
	{
		Acc_Init()
		If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
			Return ComObjEnwrap(9,pacc,1)
	}
	Acc_Query(Acc) {
		Try Return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
	}
	Acc_Children(Acc) {
		If ComObjType(Acc,"Name") != "IAccessible"
			ErrorLevel := "Invalid IAccessible Object"
		Else {
			Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
			If DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
				Loop %cChildren%
					i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
				Return Children.MaxIndex()?Children:
			} Else
				ErrorLevel := "AccessibleChildren DllCall Failed"
		}
	}
	
	m(x*){
		static List:={BTN:{OC:1,ARI:2,YNC:3,YN:4,RC:5,CTC:6},ico:{X:16,"?":32,"!":48,I:64}},Msg:=[]
		static Title
		List.Title:="AutoHotkey",List.Def:=0,List.Time:=0,Value:=0,TXT:="",Bottom:=0
		WinGetTitle,Title,A
		for a,b in x{
			Obj:=StrSplit(b,":"),(Obj.1="Bottom"?(Bottom:=1):""),(VV:=List[Obj.1,Obj.2])?(Value+=VV):(List[Obj.1]!="")?(List[Obj.1]:=Obj.2):TXT.=(IsObject(b)?Obj2String(b,,Bottom):b) "`n"
		}
		Msg:={option:Value+262144+(List.Def?(List.Def-1)*256:0),Title:List.Title,Time:List.Time,TXT:TXT}
		Sleep,120
		/*
			SetTimer,Move,-1
		*/
		MsgBox,% Msg.option,% Msg.Title,% Msg.TXT,% Msg.Time
		/*
			SetTimer,ActivateAfterm,-150
		*/
		for a,b in {OK:Value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
			IfMsgBox,%a%
				return b
		return % Msg.Txt
		Move:
		TT:=List.Title " ahk_class #32770 ahk_exe AutoHotkey.exe"
		WinGetPos,x,y,w,h,%TT%
		WinMove,%TT%,,2000,% Round((A_ScreenHeight-h)/2)
		/*
			ToolTip,% A_ScriptFullPath
			USE THIS TO SAVE LAST POSITIONS FOR MSGBOX'S
		*/
		return 
		/*
			ActivateAfterm:
			if(InStr(Title,"Omni-Search")||!Title){
				Loop,20
				{
					WinGetActiveTitle,ATitle
					if(InStr(ATitle,"AHK Studio"))
						Break
					Sleep,50
				}
			}else{
				WinActivate,%Title%
			}
			return
		*/
	}
	
	Obj2String(Obj,FullPath:=1,BottomBlank:=0){
		static String,Blank
		if(FullPath=1)
			String:=FullPath:=Blank:=""
		if(IsObject(Obj)){
			for a,b in Obj{
				if(IsObject(b))
					Obj2String(b,FullPath "." a,BottomBlank)
				else{
					if(BottomBlank=0)
						String.=FullPath "." a " = " b "`n"
					else if(b!="")
						String.=FullPath "." a " = " b "`n"
					else
						Blank.=FullPath "." a " =`n"
				}
		}}
		return String Blank
	}
	
	lLaunchWindowSpy:
	run, %A_ScriptDir%\Library\DistractLess_WindowSpy.exe ; explicitly choose the compiled version so we don't run into the gui-error that seems to happen when I include the script here instead of just running it. If we need to run it anyways, I can just evade this error by taking the compiled version, as there doesn't need to be any direct code-sided interaction between both scripts anyways. 
	return
	
	
	f_TrayIconSingleClickCallBack(wParam, lParam)
	{ ; taken and adapted from https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954
		VNI:=1.0.3.12
		; 0x201 WM_LBUTTONDOWN
		; 0x202 WM_LBUTTONUP
		if (lParam = 0x202) || (lParam = 0x201)
		{
			menu, tray, show
			return 0
		}
	}
	NotifyTrayClick(P*) 
	{ ; NotifyTrayClick | SKAN | https://www.autohotkey.com/boards/viewtopic.php?t=81157
		;  v0.41 by SKAN on D39E/D39N @ tiny.cc/notifytrayclick
		VNI=1.0.0.17
		Static Msg, Fun:="NotifyTrayClick", NM:=OnMessage(0x404,Func(Fun),-1),  Chk,T:=-250,Clk:=1
		If ( (NM := Format(Fun . "_{:03X}", Msg := P[2])) && P.Count()<4 )
			Return ( T := Max(-5000, 0-(P[1] ? Abs(P[1]) : 250)) )
		Critical
		If ( ( Msg<0x201 || Msg>0x209 ) || ( IsFunc(NM) || Islabel(NM) )=0 )
			Return
		Chk := (Fun . "_" . (Msg<=0x203 ? "203" : Msg<=0x206 ? "206" : Msg<=0x209 ? "209" : ""))
		SetTimer, %NM%,  %  (Msg==0x203        || Msg==0x206        || Msg==0x209)
		? (-1, Clk:=2) : ( Clk=2 ? ("Off", Clk:=1) : ( IsFunc(Chk) || IsLabel(Chk) ? T : -1) )
		Return True
	}
	
	
	CodeTimer(Description="",x:=500,y:=500,ClipboardFlag:=0)
	{ ; adapted from https://www.autohotkey.com/boards/viewtopic.php?p=316296#p316296
		
		Global StartTimer
		If (StartTimer != "")
		{
			FinishTimer := A_TickCount
			TimedDuration := FinishTimer - StartTimer
			StartTimer := ""
			If ClipboardFlag
				Clipboard:=TimedDuration
			tooltip, Timer`n%Description%`n%TimedDuration% ms have elapsed!, x,y,14
			Settimer,lCodeTimer_RemoveToolTip, -2500
			Return TimedDuration
		}
		Else
			StartTimer := A_TickCount
		Return

		lCodeTimer_RemoveToolTip:
		tooltip,,,,14
		return
	}
	;}_____________________________________________________________________________________
	; Includes from StringThings-lib see below.
	
	st_wordWrap(string, column=56, indentChar="")
	{ 
		; taken from ST-lib at https://www.autohotkey.com/boards/viewtopic.php?t=53, published by tidbit
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
		indentLength := StrLen(indentChar)
		
		Loop, Parse, string, `n, `rff
		{
			If (StrLen(A_LoopField) > column)
			{
				pos := 1
				Loop, Parse, A_LoopField, %A_Space%
					If (pos + (loopLength := StrLen(A_LoopField)) <= column)
						out .= (A_Index = 1 ? "" : " ") A_LoopField
						, pos += loopLength + 1
				Else
					pos := loopLength + 1 + indentLength
						, out .= "`n" indentChar A_LoopField
				
				out .= "`n"
			} Else
				out .= A_LoopField "`n"
		}
		
		return SubStr(out, 1, -1)
	}
	
	st_removeDuplicates(string, delim="`n")
	{ ; remove all but the first instance of 'delim' in 'string'
		; taken from ST-lib at https://www.autohotkey.com/boards/viewtopic.php?t=53, published by tidbit
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
		/*
			RemoveDuplicates
			Remove any and all consecutive lines. A "line" can be determined by
			the delimiter parameter. Not necessarily just a `r or `n. But perhaps
			you want a | as your "line".
			
			string = The text or symbols you want to search for and remove.
			delim  = The string which defines a "line".
			
			example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
			output:  aaa|bbb|ccc|ddd
		*/
		delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
		Return RegExReplace(string, "(" delim ")+", "$1")
	}
	
	st_count(string, searchFor="`n")
	{ ; count number of occurences of 'searchFor' in 'string'
		; taken from ST-lib at https://www.autohotkey.com/boards/viewtopic.php?t=53, published by tidbit
		; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
		/*
			Count
			Counts the number of times a tolken exists in the specified string.
			
			string    = The string which contains the content you want to count.
			searchFor = What you want to search for and count.
			
			note: If you're counting lines, you may need to add 1 to the results.
			
			example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
			output:  4
		*/
		StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
		return ErrorLevel
	}
	;}_____________________________________________________________________________________
	; Includes from TF-lib see below.

	/*
		Name          : TF: Textfile & String Library for AutoHotkey
		Version       : 3.8
		Documentation : https://github.com/hi5/TF
		AutoHotkey.com: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=576
		AutoHotkey.com: http://www.autohotkey.com/forum/topic46195.html (Also for examples)
		License       : see license.txt (GPL 2.0) | filename changed to "license (TF.ahk)", found under A_ScriptDir\DistractLess_Storage\licenses\license(TF.ahk).txt
		Credits & History: See documentation at GH above.

		Structure of most functions:

		TF_...(Text, other parameters)
			{
			; get the basic data we need for further processing and returning the output:
			TF_GetData(OW, Text, FileName)
			; OW = 0 Copy inputfile
			; OW = 1 Overwrite inputfile
			; OW = 2 Return variable
			; Text : either contents of file or the var that was passed on
			; FileName : Used in case OW is 0 or 1 (=file), not used for OW=2 (variable)

			; Creates a matchlist for use in Loop below
			TF_MatchList:=_MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; A_ThisFunc useful for debugging your scripts

			Loop, Parse, Text, `n, `r
				{
				If A_Index in %TF_MatchList%
					{
					...
					}
				Else
					{
					...
					}
				}
			; either copy or overwrite file or return variable
			Return TF_ReturnOutPut(OW, OutPut, FileName, TrimTrailing, CreateNewFile)
			; OW 0 or 1 = file
			; Output = new content of file to save or variable to return
			; FileName
			; TrimTrailing: because of the loops used most functions will add trailing newline, this will remove it by default
			; CreateNewFile: To create a file that doesn't exist this parameter is needed, only used in few functions
			}

	*/
	DL_TF_ReplaceInLines(Text, StartLine = 1, EndLine = 0, SearchText = "", ReplaceText = "")
	{
	 DL_TF_GetData(OW, Text, FileName)
	 IfNotInString, Text, %SearchText%
		Return Text ; SearchText not in TextFile so return and do nothing, we have to return Text in case of a variable otherwise it would empty the variable contents bug fix 3.3
	 TF_MatchList:=DL__MakeMatchList(Text, StartLine, EndLine, 0, A_ThisFunc) ; create MatchList
	 Loop, Parse, Text, `n, `r
		{
		 If A_Index in %TF_MatchList%
			{
			 StringReplace, LoopField, A_LoopField, %SearchText%, %ReplaceText%, All
			 OutPut .= LoopField "`n"
			}
		 Else
			OutPut .= A_LoopField "`n"
		}
	 Return DL_TF_ReturnOutPut(OW, OutPut, FileName)
	}

	DL_TF_GetData(byref OW, byref Text, byref FileName)
	{
	 If (text = 0 "") ; v3.6 -> v3.7 https://github.com/hi5/TF/issues/4 and https://autohotkey.com/boards/viewtopic.php?p=142166#p142166 in case user passes on zero/zeros ("0000") as text - will error out when passing on one 0 and there is no file with that name
		{
		 IfNotExist, %Text% ; additional check to see if a file 0 exists
			{
			 MsgBox, 48, TF Lib Error, % "Read Error - possible reasons (see documentation):`n- Perhaps you used !""file.txt"" vs ""!file.txt""`n- A single zero (0) was passed on to a TF function as text"
			 ExitApp
			}
		}
	 OW=0 ; default setting: asume it is a file and create file_copy
	 IfNotInString, Text, `n ; it can be a file as the Text doesn't contact a newline character
		{
		 If (SubStr(Text,1,1)="!") ; first we check for "overwrite"
			{
			 Text:=SubStr(Text,2)
			 OW=1 ; overwrite file (if it is a file)
			}
		 IfNotExist, %Text% ; now we can check if the file exists, it doesn't so it is a var
			{
			 If (OW=1) ; the variable started with a ! so we need to put it back because it is variable/text not a file
				Text:= "!" . Text
			 OW=2 ; no file, so it is a var or Text passed on directly to TF
			}
		}
	 Else ; there is a newline character in Text so it has to be a variable
		{
		 OW=2
		}
	 If (OW = 0) or (OW = 1) ; it is a file, so we have to read into var Text
		{
		 Text := (SubStr(Text,1,1)="!") ? (SubStr(Text,2)) : Text
		 FileName=%Text% ; Store FileName
		 FileRead, Text, %Text% ; Read file and return as var Text
		 If (ErrorLevel > 0)
			{
			 MsgBox, 48, TF Lib Error, % "Can not read " FileName
			 ExitApp
			}
		}
	 Return
	}


	; DL__MakeMatchList()
	; Purpose:
	; Make a MatchList which is used in various functions
	; Using a MatchList gives greater flexibility so you can process multiple
	; sections of lines in one go avoiding repetitive fileread/append actions
	; For TF 3.4 added COL = 0/1 option (for TF_Col* functions) and CallFunc for
	; all TF_* functions to facilitate bug tracking
	DL__MakeMatchList(Text, Start = 1, End = 0, Col = 0, CallFunc = "Not available")
		{
		ErrorList=
		(join|
	Error 01: Invalid StartLine parameter (non numerical character)`nFunction used: %CallFunc%
	Error 02: Invalid EndLine parameter (non numerical character)`nFunction used: %CallFunc%
	Error 03: Invalid StartLine parameter (only one + allowed)`nFunction used: %CallFunc%
		)
		StringSplit, ErrorMessage, ErrorList, |
		Error = 0

		If (Col = 1)
			{
			LongestLine:=TF_Stat(Text)
			If (End > LongestLine) or (End = 1) ; FIXITHERE BUG
				End:=LongestLine
			}

		TF_MatchList= ; just to be sure
		If (Start = 0 or Start = "")
			Start = 1

		; some basic error checking

		; error: only digits - and + allowed
		If (RegExReplace(Start, "[ 0-9+\-\,]", "") <> "")
			Error = 1

		If (RegExReplace(End, "[0-9 ]", "") <> "")
			Error = 2

		; error: only one + allowed
		If (TF_Count(Start,"+") > 1)
			Error = 3

		If (Error > 0 )
			{
			MsgBox, 48, TF Lib Error, % ErrorMessage%Error%
			ExitApp
			}

		; Option #0 [ added 30-Oct-2010 ]
		; Startline has negative value so process X last lines of file
		; endline parameter ignored

		If (Start < 0) ; remove last X lines from file, endline parameter ignored
			{
			Start:=TF_CountLines(Text) + Start + 1
			End=0 ; now continue
			}

		; Option #1
		; StartLine has + character indicating startline + incremental processing.
		; EndLine will be used
		; Make TF_MatchList

		IfInString, Start, `+
			{
			If (End = 0 or End = "") ; determine number of lines
				End:= TF_Count(Text, "`n") + 1
			StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
			Loop, %Section0%
				{
				StringSplit, SectionLines, Section%A_Index%, `+
				LoopSection:=End + 1 - SectionLines1
				Counter=0
					TF_MatchList .= SectionLines1 ","
				Loop, %LoopSection%
					{
					If (A_Index >= End) ;
						Break
					If (Counter = (SectionLines2-1)) ; counter is smaller than the incremental value so skip
						{
						TF_MatchList .= (SectionLines1 + A_Index) ","
						Counter=0
						}
					Else
						Counter++
					}
				}
			StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
			Return TF_MatchList
			}

		; Option #2
		; StartLine has - character indicating from-to, COULD be multiple sections.
		; EndLine will be ignored
		; Make TF_MatchList

		IfInString, Start, `-
			{
			StringSplit, Section, Start, `, ; we need to create a new "TF_MatchList" so we split by ,
			Loop, %Section0%
				{
				StringSplit, SectionLines, Section%A_Index%, `-
				LoopSection:=SectionLines2 + 1 - SectionLines1
				Loop, %LoopSection%
					{
					TF_MatchList .= (SectionLines1 - 1 + A_Index) ","
					}
				}
			StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
			Return TF_MatchList
			}

		; Option #3
		; StartLine has comma indicating multiple lines.
		; EndLine will be ignored

		IfInString, Start, `,
			{
			TF_MatchList:=Start
			Return TF_MatchList
			}

		; Option #4
		; parameters passed on as StartLine, EndLine.
		; Make TF_MatchList from StartLine to EndLine

		If (End = 0 or End = "") ; determine number of lines
				End:= TF_Count(Text, "`n") + 1
		LoopTimes:=End-Start
		Loop, %LoopTimes%
			{
			TF_MatchList .= (Start - 1 + A_Index) ","
			}
		TF_MatchList .= End ","
		StringTrimRight, TF_MatchList, TF_MatchList, 1 ; remove trailing ,
		Return TF_MatchList
		}


	; Write to file or return variable depending on input
	DL_TF_ReturnOutPut(OW, Text, FileName, TrimTrailing = 1, CreateNewFile = 0) 
	{
		If (OW = 0) ; input was file, file_copy will be created, if it already exist file_copy will be overwritten
			{
			IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
			{
				If (CreateNewFile = 1) ; CreateNewFile used for TF_SplitFileBy* and others
				{
					OW = 1
					Goto lCreateNewFile
				}
				Else
					Return
			}
			If (TrimTrailing = 1)
				StringTrimRight, Text, Text, 1 ; remove trailing `n
			SplitPath, FileName,, Dir, Ext, Name
			If (Dir = "") ; if Dir is empty Text & script are in same directory
				Dir := A_WorkingDir
			IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
				FileCopy, % Dir "\" Name "_copy." Ext, % Dir "\backup\" Name "_copy.bak", 1
			FileDelete, % Dir "\" Name "_copy." Ext
			FileAppend, %Text%, % Dir "\" Name "_copy." Ext
			Return Errorlevel ? False : True
			}
		lCreateNewFile:
		If (OW = 1) ; input was file, will be overwritten by output
		{
			IfNotExist, % FileName ; check if file Exist, if not return otherwise it would create an empty file. Thanks for the idea Murp|e
			{
				If (CreateNewFile = 0) ; CreateNewFile used for TF_SplitFileBy* and others
					Return
			}
			If (TrimTrailing = 1)
				StringTrimRight, Text, Text, 1 ; remove trailing `n
			SplitPath, FileName,, Dir, Ext, Name
			If (Dir = "") ; if Dir is empty Text & script are in same directory
				Dir := A_WorkingDir
			IfExist, % Dir "\backup" ; if there is a backup dir, copy original file there
				FileCopy, % Dir "\" Name "." Ext, % Dir "\backup\" Name ".bak", 1
			FileDelete, % Dir "\" Name "." Ext
			FileAppend, %Text%, % Dir "\" Name "." Ext
			Return Errorlevel ? False : True
		}
		If (OW = 2) ; input was var, return variable
		{
			If (TrimTrailing = 1)
				StringTrimRight, Text, Text, 1 ; remove trailing `n
			Return Text
		}
	}
	;}_____________________________________________________________________________________
	; IniSettingsEditor v6 see below.
	; retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=237927#p237927, specifically gamax92_archive of the download. 
	; edited to alternatively also edit hidden sections/Settings by settings ShowHidden=true
	; IniFileCreator_v8 also retrieved from the same archive.
	; Creator-script by toralf, modded by Gewerd Strauss to preload files from variables if included
	; 

	#Include %A_ScriptDir%\Library\DL_Func_IniSettingsEditor_v6.ahk
