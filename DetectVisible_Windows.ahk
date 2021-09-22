#SingleInstance, Force ;; WinList is a listbox control with delim set to newline

WinList:
WinGet,WinList,List,,,Program Manager
List=
loop,%WinList%{
Current:=WinList%A_Index%
WinGetTitle,WinTitle,ahk_id %Current%
WinGet,PID,PID,ahk_id %Current%

Cont=1
loop,parse,TempPID,`n
Cont:=(A_LoopField=PID) ? 0 : Cont

TempPID.=PID "`n"

If WinTitle && Cont
{

     m(strsplit(List,"`r`n"))
    List.="`n" WinTitle
}
}
TempPID=
GuiControl,,WinList,%List%
m(List)
Return
