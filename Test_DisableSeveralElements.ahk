#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
gui, 1: new
gui, add, button, vbtn1, this is a button
gui, add, button, vbtn2, this is a button 2
gui, add, edit, vedt1, this is a edit 1
gui, show
gui, 2: new

guiNumber:=1
sleep, 2000
arr:=["btn1","btn2","edt1"]
loop, % arr.length()
{
    currcont:=arr[A_Index]
    guicontrol, %guiNumber%:  disable, %currcont%
    sleep, 500
}
sleep, 3000
loop, % arr.length()
{
    currcont:=arr[A_Index]
    guicontrol, %guiNumber%:  enable, %currcont%
    sleep, 500
}
GuiControl, 1:disable, btn2 ; ← this successfully deactivates btn2.\**
m("hi") ; msgbox fn to signify end cuz too many sleeps
