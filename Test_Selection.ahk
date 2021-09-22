#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
Gui, Add, ListView, r5 w100, Number
LV_Add("", "one")
LV_Add("", "two")
LV_Add("", "three")
Gui, Add, Button, gShowMe w100, Show Me
Gui, Add, Slider, Range1-3 Center vMySlider gSwitchMe w100, 1
Gui, Show

return

ShowMe:
; straight from the docs: https://www.autohotkey.com/docs/commands/ListView.htm#LV_GetNext
RowNumber := 0  ; This causes the first loop iteration to start the search at the top of the list.
Loop
{
	RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
	if not RowNumber  ; The above returned zero, so there are no more selected rows.
		break
	LV_GetText(Text, RowNumber)
	MsgBox The next selected row is #%RowNumber%, whose first field is "%Text%".
}
return

SwitchME:
Gui, Submit, NoHide
MsgBox, Three-Way Switch is set to: %MySlider%
return

Guiclose:
ExitApp
