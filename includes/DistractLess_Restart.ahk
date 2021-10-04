#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#NoTrayIcon
sleep, 8000
SplitPath, A_ScriptDir,,ScriptPath
if A_IsCompiled
{
    if (A_ComputerName="DESKTOP-FH4RU5C")
        m("executing:" ScriptPath "\DistractLess.exe" )
    run, %ScriptPath%\DistractLess.exe
}
Else
{
    if (A_ComputerName="DESKTOP-FH4RU5C")
        m("executing:" ScriptPath "\DistractLess.ahk" )
    run, %ScriptPath%\DistractLess.ahk
}
