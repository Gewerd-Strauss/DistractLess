#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
;#Persistent
;#Warn All  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
;DetectHiddenWindows, On
;SetKeyDelay -1
SetBatchLines -1
SetTitleMatchMode, 2
ntfy:=Notify()
;;_____________________________________________________________________________________
;{#[General Information for file management]
ScriptName=MISSING 
VN=1.0.1.1                                                                    
LE=20 März 2021 17:51:52                                                       
AU=Gewerd Strauss
;}______________________________________________________________________________________
;{#[File Overview]
Menu, Tray, Icon, C:\WINDOWS\system32\imageres.dll,101 ;Set custom Script icon
menu, Tray, Add, About, Label_AboutFile
;}______________________________________________________________________________________
;{#[Autorun Section]
	gosub, g_AddAlCurrentToWhiteList
Numpad0::
gui, destroy
gui_control_options := "xm w220 " . cForeground . " -E0x200"  ; remove border around edit field
Gui, Margin, 16, 16
Gui, +AlwaysOnTop -ToolWindow -caption +Border
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
;_____________________________________________________________________________________
; Creating Menus
Menu, FileMenu, Add, &Open`tCtrl+O, MenuFileOpen  ; See remarks below about Ctrl+O.
Menu, FileMenu, Add, E&xit, MenuHandler
Menu, HelpMenu, Add, &Rules, lDisplayRules
Menu, MyMenuBar, Add, &File, :FileMenu  ; Attach the two sub-menus that were created above.
Menu, MyMenuBar, Add, &Help, :HelpMenu
Gui, Menu, MyMenuBar

;_____________________________________________________________________________________



Gui,Add,Text,xm ym cWhite,Add currently existing windows to:
Gui,Add,Radio,xm ym+25 cWhite gg_AddAlCurrentToWhiteList,Radio
Gui,Add,Radio,x25 y120 w50 h13 cWhite,Radio
Gui,Add,Button,x12 y199 w160 h28 gSubmit,Submit current settings
Gui,Show,,DistractLess - by %AU%
return
lDisplayRules: ; give rules textbox displaying how stuff works
return
g_AddAlCurrentToWhiteList: ; 
f_CreateListOfAllCurrentWindows()
MenuFileOpen:
MenuHandler:
return
Submit:

return
;}______________________________________________________________________________________
;{#[Hotkeys Section]
XButton1::gui, destroy

#IfWinActive, DistractLess - 
	Escape:: gui, destroy
;}______________________________________________________________________________________
;{#[Label Section]


return
RemoveToolTip: 
Tooltip,
return
Label_AboutFile:
MsgBox,, File Overview, Name: %ScriptName%`nAuthor: %AU%`nVersionNumber: %VN%`nLast Edit: %LE%`n`nScript Location: %A_ScriptDir%
return
;}______________________________________________________________________________________
;{#[Functions Section]

f_CreateListOfAllCurrentWindows()
{
	WinGet vWindowsList, List
	m(vWindowsList)
	DetectHiddenWindows, Off
	;WinGet
	naWindowTitles:=[]
	naWindowExe:=[]
	naWindowID:=[]
	Loop %vWindowsList%
	{
		WinGet, vCurrExe, ProcessName, % "ahk_id " vWindowsList%A_Index%
		WinGet, vCurrState, MinMax, % "ahk_id " vWindowsList%A_Index%
		Winget, vCurrTitle, 
		;naWindowTitles
		ttip("hi")
	}
	m(naWindowTitles,"|" naWindowExe,"|" naWindowID,"|" vWindowsList)
	DetectHiddenWindows, On
}


;}_____________________________________________________________________________________
;{#[Include Section]



;}_____________________________________________________________________________________