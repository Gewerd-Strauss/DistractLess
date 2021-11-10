# DistractLess

A small program meant to keep you focused by closing websites and programs matching different set of rules regarding their window/tab name and URL.


Manual version 1.4

## 1. Fundamentals

DistractLess is a program designed to shut down distracting programs and browser tabs as soon as they gain focus.
It does so by comparing the current window's title against your sets of whitelisted and blacklisted criteria. Depending on the type of the criteria, a URL can be compared as well. 

For more information, see [5. Understanding the filter mechanism](#5-understanding-the-filter) 

## 2. The GUI

![Figure 1: The Main Window](Documentation\DL_MainWindow.PNG "Figure 1: The Main Window")

![Figure 1: The Main Window](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_MainWindow.PNG "Figure 1: The Main Window")

The main overlay can be broken up into three different sections:
The left section displays stored and active _whitelisted_ strings. The right third displays _blacklisted_ ones. 

The middle section allows the creation of new conditions, the loading from and saving to a file (both in the upper section) and to quickly change the program behaviour (lower section)

### 2.1. Adding a criterium to a list

#### 2.1.1. Criteria 

Criteria are split into two categories:

1. programs
2. websites

Both are exclusively checked depending on the current window. 

#### 2.1.1.1. Browser matches

The rules to detect a browser are predefined for the following browsers out of the box:

1. Google Chrome 
2. Mozilla Firefox
3. Internet Explorer
4. Microsoft Edge
5. Opera

To edit these rules, open the settings (cf. Changing program settings) and edit the comma-separated lists of `BrowserClasses`, `BrowserExes`  according to the instructions there. Any window matching both of these lists is considered a browser window.

A browser match requires the "website"-type to be selected. 


##### 2.1.1.2. Program matches

A program, for DistractLess, is any application that is not considered a browser - and therefore doesn't match the `BrowserClasses` and `BrowserExes` with their respective class and exe as displayed by the window spy. For people who don't have autohotkey itself installed and are using the compiled version of the window spy in `DistractLess\includes\DistractLess_WindowSpy.exe`. Keep the window open and click on the browser you want to add. 

* the first line displays the window title of the currently active window
* the string displayed _behind_ "ahk_class" (without the space inbetween, _just_ whatever comes after the space) must be added to BrowserClasses in the settings.
* the string displayed _behind_ "ahk_exe" (without the space inbetween, _just_ whatever comes after the space) must be added to BrowserExes in the settings.
* the last line is absolutely irrelevant for the scope of this application.

In case of the following example, you would add `MozillaWindowClass` to `BrowserClasses` and `firefox.exe` to `BrowserExes` respectively. Don't forget to separate each entry by a commata (,).

You can ignore the first and last line of this first field (under "Window Title, Class and Process"), as well as all other info displayed.

![Figure 2: relevant contents of the window spy overlay](Documentation\DL_ContentsWindowSpy.PNG "Figure 2: relevant contents of the window spy overlay")

![Figure 2: relevant contents of the window spy overlay](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_ContentsWindowSpy.PNG "Figure 2: relevant contents of the window spy overlay")

---

Now that you have added any possible browsers you might be using, let's go over _programs_ (remember, those have distinctly nothing in common with the settings you have just edited.)

A program is only matched according to its window title against any ***p***rogram-condition currently visible within the top two listviews visible in figure 1.


#### 2.1.2. Syntax


DistractLess always checks if the current window's title _contains_ the substring. There is no distinction made between upper and lowercase, only the order of symbols must match anywhere within the current window's title.

To have a criteria match any title, set the title string to `.*`[^1].

To have a criteria match any website, set the URL string to `.*`[^1].

There are a few limitations to prevent unforseen consequences, displayed in the next chapter.

#### 2.1.2.1. A few rules to note

The following combinations are **not** possible. These restrictions are necessary so the program doesn't suddenly start closing everything in an uncontrollable manner.

| Substring | URL | Type | List | Explanation
|-------------|----|--------|------|------------
| .* | / | p | black | Every program would match blacklist
| .* | .* | either | either | This would match virtually  everything
| .* AnotherSubStringHere | / | either | either | not possible


#### 2.1.3. Adding an existing window's conditions

When the main gui (cf. Figure 1) is open, you can press `Alt+e` to launch a helper-tool for setting conditions faster.

![Figure 3: Choose a condition from existing windows](Documentation\DL_ChooseCurrentWindowOverlay.PNG "Figure 3: Choose a condition from existing windows")

![Figure 3: Choose a condition from existing windows](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_ChooseCurrentWindowOverlay.PNG "Figure 3: Choose a condition from existing windows")

1. After the window of figure 3 opens, navigate to the desired program/browser tab and hold  `Ctrl` while left-clicking **onto the desired window**. 
2. The respective title (and url if it is considered a browser) are added into the edit fields seen in figure 4. The conditions' type (website or program) is selected automatically. 
3. Edit the substring to a suitable level of specificity and the url if necessary.
4. Decide wether or not to add it as a blacklist- or whitelist-criteria.
5. If you want to generalise a certain criteria, replace title or URL substring with ".*", according to the rules displayed in [syntax](#212-syntax).

![Figure 4: Create a (website) condition](Documentation\DL_CloseUpAddSSAllShown.PNG "Figure 4: Create a (website) condition")

![Figure 4: Create a (website) condition](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_CloseUpAddSSAllShown.PNG "Figure 4: Create a (website) condition")


Alteratively, you can just create your conditions by hand, but usually that will be more prone to error and take longer :P

Pressing `Save LV's` will open a dialogue to save the current configuration for later access. The default folder can be changed under `sLocationUserBackup` in the [settings](#3-accessing-and-editing-the-settings).

### 2.2. The lower middle section: The filter mechanism

This section is pretty quickly explained, because not a lot is happening here.
Two Dropdownlists influence the behaviour of the program.

The program has three filter-modes.

#### 2.2.1. Both

The easiest to use, fastest to balance mode. 
Rules for the "Both"-mode:

##### 2.2.1.1. White>Black

1. If both the whitelist and blacklist contain a matching entry, the window/browser tab is not closed.
2. If only black contains a matching criterium, and whitelist does not match at all, the window/website _is_ closed.

##### 2.2.1.2. Black>White
As soon as blacklist matches the current window/browser tab, it _is_ closed, regardless of wether or not whitelist matches. After I finished implementing this, I realised that it is effectively just a more confusing blacklist-only mode. I might rehaul it at some point to work differently, but I am not sure.


#### 2.2.2. Black Only

As soon as a window matches a criteria, it is closed.


#### 2.2.3. White Only\*

This option is only available if the setting "bAllowWhiteOnly" is checked in the settings.
This extra barrier of entry is necessary because this mode is extremely restrictive. Under its ruleset, _any_ window not explicitly matching _any one_ condition of the whitelist is closed.

When setting up criteria sets for this mode, please ensure you are running in [diagnostics mode](#4-entering-and-exiting-diagnostics-mode) first.


A detailed flowsheet of each mode can be found in [5. Understanding the filter](#5-understanding-the-filter).


## 3. Accessing and editing the settings

In order to access the settings, double-click the author-section of the bar at the bottom of the main window _once_ (cf. Figure 5). You should hear a high-pitched double-beep, but you might also not depending on a variety of factors outside of my control. Afterwards, every double-click on the second section (DistractLess v.W.X.Y.Z) will open the settings dialogue (cf. Figure 6). 
Alternatively, pressing `Ctrl+O` while  the main window is active will also open the GUI.

![Figure 5: Closeup of the menu bar. Notice that the lock symbol counts as the first section.](Documentation\DL_CloseUpToolBar.PNG "")

![Figure 5: Closeup of the menu bar. Notice that the lock symbol counts as the first section.](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_CloseUpToolBar.PNG "")

Each setting comes with a small description about its usecase, and possible options. The type of the input is displayed, as well as a default value which is restored when pressing "Restore". Settings are saved automatically. In the example of figure 6, we are looking at the `OnExitBehaviour`, and a dropdown-list displays possible options.

![Figure 6: Settings Menu](Documentation\DL_SettingsMenu.PNG "")

![Figure 6: Settings Menu](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_SettingsMenu.PNG "")

Figure 7 displays a known, but to me not solvable bug. The description displayed can sometimes be muddied by the display of another setting's description. 

These cases can be identified because the "Default:...."- and "Type:...."- information is displayed twice. In these cases, the _lowest_ description is the "correct" one.

![Figure 7: Faulty double description](Documentation\DL_FaultySettingsDescription.PNG "")

![Figure 7: Faulty double description](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_FaultySettingsDescription.PNG "")

Settings are autosaved upon change or closing of the window. Most settings take effect immediately, but some require a program restart.

## 4. Entering and exiting diagnostics-mode

In order to enter diagnostics mode, doubleclick the fifth section of the toolbar, saying either "Running in normal mode" or "Running in diagnostics mode". Doubleclicking will enter and exit that mode. Alternatively, pressing `Ctrl+T` does the same while the main GUI is active.

---

In diagnostics mode, windows will not be closed. Instead, information on matches that _would have_ closed the current window/tab will be displayed. I intend to change this mode so that information on why a particular window is _not_ matched will be displayed in those casees as well.


![Figure 8: Diagnostics information](Documentation\DL_Diagnostics.png "")

![Figure 8: Diagnostics information](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_Diagnostics.png "")

Displayed will be

* the type of match (browser match vs program match) - can be useful if you are using browsers that are not defined as such for the program (cf. [Browser Matches](#213-adding-an-existing-windows-conditions) )
* the current filter mode
* the current trumping rule (always displayed, but only relevant if Filtermode is "Both")
* the title of the active window which has been matched to close
* the corresponding criteria string that was matched
* the current URL and the matched URL if it is a browser match



## 5. Understanding the filter 

At each call to the filtering subroutine, the steps in figure 9 must be passed successfully before the active window's information is compared.

![Figure 9: Preliminary Checking routine of the filter](Documentation\DL_PrelimChecks.png "")

![Figure 9: Preliminary Checking routine of the filter](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_PrelimChecks.png "")

Afterwards, refer to the figures 10-13 for the working mechanisms of the different modes.

![Figure 10: Logic for White-only mode](Documentation\DL_WhiteOnlyLogic.png "")

![Figure 10: Logic for White-only mode](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_WhiteOnlyLogic.png "")

![Figure 11: Logic for Black-only mode](Documentation\DL_BlackOnlyLogic.png "")

![Figure 11: Logic for Black-only mode](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_BlackOnlyLogic.png "")

![Figure 12: Logic for "Both"-mode, with white trumping black](Documentation\DL_WhiteTrumpsBlackLogic.png "")

![Figure 12: Logic for "Both"-mode, with white trumping black](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_WhiteTrumpsBlackLogic.png "")

![Figure 13: Logic for "Both"-mode, with black trumping white](Documentation\DL_BlackTrumpsWhiteLogic.png "")

![Figure 13: Logic for "Both"-mode, with black trumping white](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_BlackTrumpsWhiteLogic.png "")

## 6. Hotkeys

All Hotkeys are active while GUIs are active, and most are restricted to the main-gui, except when noted.

### 6.1. Main Gui

| Hotkey | Function
|:------------------|:------------------|
| Alt+E   | Launch [title-adder-tool](213-adding-an-existing-windows-conditions) 
| Escape  | Close Gui
| Ctrl+T  | Enter/Exit Testmode (cf. [Entering and exiting diagnostics-mode](#4-entering-and-exiting-diagnostics-mode) )
| Ctrl+L  | Lock the Gui
| Ctrl+O  | Open Settings
| Shift+1 | Focus on WhiteActive Listview
| Shift+2 | Focus on WhiteStorage Listview
| Shift+3 | Focus on BlackActive Listview
| Shift+4 | Focus on BlackStorage Listview
| Alt+F   | Focus on Filtermode Dropdown-List
| Alt+T   | Focus on Trumpingrule Dropdown-List
| Alt+-   | Open/close Main Gui (active globally)
| ^ / Sc029 | Toggle on/off program


Table 1: Main Gui Hotkeys and Accelerator Keys

### 6.2 "Title-Adder"-GUI 

Launched by pressing Alt+E, cf. table 1

| Hotkey  | Function
|:------------------|:------------------|
| Ctrl+LButton | When pressed _on_ a window, choose its info and import it for further processing into main GUI
| Escape | return to the main gui, don't add current selection into program
| Alt+E | When the display in the bottom right corner has focus, pressing Alt+E results in the same outcome as pressing Escape while the Title-Adder-GUI is visible

Table 2: "Title-Adder" Hotkeys and Accelerator Keys

### 6.3 Submit Password/Time GUI

When entering a password to unlock the GUI[^3] or setting the unlock-time[^2], the following hotkeys are available:

| Hotkey | Function
|:------------------|:------------------|
| Ctrl+Enter | `Time-Protected`: Submit chosen time after which access to the program is possible again. For more info, see [7. Locking the GUI](#7-locking-the-gui)
| Ctrl+Enter | `Password-Protected`: Confirm Password to unlock the gui
| Escape/Alt+E | close the respective window and return to main GUI

Table 3: Hotkeys available when locking/unlocking the GUI via Password/Setting time

## 7. Locking the Gui



You can lock the GUI by pressing `Ctrl+L` while the main GUI is active. 
There are two locking modes:

### 7.1 Time-Protected

| Hotkey | Function
|:------------------|:------------------|
| Tab / Shift+Tab | cycle forwards/backwards through positions of the select-time-GUI

Table 4: Additional Hotkeys in the "Select Time"-Gui

If `LockingBehaviour` is set to `Time-protected`, the time at which the GUI is unlocked can be set. The GUI becomes fully locked until the time of day has passed. 

By default, the GUI is locked until the third next full hour has passed. I.e. if you lock et 14:49, the default time is calculated to be 17:00:00. Not 18:00:00. See the setting `LockingDefaultOffsetHours` in the settings. Only integers (and therefore full hours) can be preset.

![Figure 14: Set Time at which the GUI is unlocked again](Documentation\DL_SetUnlockTime.png "")

![Figure 14: Set Time at which the GUI is unlocked again](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_SetUnlockTime.PNG "")



### 7.2 Password-protected

If `LockingBehaviour` is set to `Password-protected`, a password check is performed against the password set by the user during the first time the program has been started. The password submits itself if it is correct.

![Figure 15: Enter Password to unlock the GUI again](Documentation\DL_EnterPassword.PNG "")

![Figure 15: Enter Password to unlock the GUI again](https://github.com/Gewerd-Strauss/DistractLess/blob/main/Documentation/DL_EnterPassword.PNG "")





## 8. Overview over Settings

| Hotkey | respective_function| Type | Default
|:-------------|:------------------|:--------|:--------|
| **RefreshTime** | Set time in milliseconds until the current window is matched against the set whitelist and/or blacklist. Lower values mean more immediate closing of blocked windows, higher values reduce the frequency of checks. Increase the value if the program causes significant lags - even though that really shouldn't happen, unless you are switching windows/tabs very quickly. In my tests, 200 consecutive "browser tab"-closures took an average of 97ms. Programs are harder to test, and take longer to close usually. | Integer | 200
LockingBehaviour |set wether or not to lock until either time has passed or until pw is inputted | DropDownList | Time-protected
| LockingDefaultOffsetHours | Set the number of hours used when calculating the default unlocking time when locking the program for a set time. Value in hours. | Integer | 3
bAlwaysAskPW | When checked, the gui is always locked (equivalent to left-clicking the padlock-icon on the main GUI window), and a password is checked. | Checkbox | 0
| OnExitBehaviour | Decide what to do when the script is manually closed by any means, except for shutting down, logging off or restarting the PC. Changes in this setting only take effect after restarting the program once. `Restart with current bundle`: the currently active and stored Blacklists and Whitelists, as well as the currently active Filter-mode and Trumping-rule are stored and reloaded when script is closed. This prevents the script from being closed by hand. `Empty Restart`: Program is restarted without reloading the current session. `Nothing`:Script exits normally, without restarting at all. `Restart with specific bundle`: Restart with a specific bundle by default. Bundle must be specified under "sDefaultBundle" | DropDownList |Restart with specific bundle
| sDefaultBundle | Only takes effect if OnExitBehaviour is set to "Restart with specific bundle". Select a bundle to be always loaded on startup. Note that this setting also applies to indirect restarts - and hence this bundle will be loaded even if another one was active before the user attempted to close the program. | File | -
| EnableDiagnosticMode | Enable Diagnostics-mode for the Closing-function. This results in: CLOSING WINDOWS: more information about matching criteria being displayed, instead of closing the window/tab outright. DoubleClick the fifth part of the statusbar of the main gui to enable and disable diagnostic mode quickly. | Checkbox |0
| bEnableBlockingBanner |If checked, the closing function will briefly flash a notification when temporarily disabling all keyboard and mouse input. Another message is sent when keyboard and mouse inputs are restored. If not checked, the kbm will be silently blocked and unblocked. | Checkbox |0
|BrowserClasses|Comma-separated list of ahk_classes which are considered to represent web browsers for the sake of closing only the active tab via Ctrl-W, as opposed to Alt+F4. The ahk_exe of the browser needs to be added to BrowserExes as well for DistractLess to identify the browser correctly. This is necessary as there are _way_ too many programs built on chrome's framework, but we don't want those to count as browsers. (Looking at you, Spotify)  | Text | MozillaWindowClass, Chrome_WidgetWin_1, Chrome_WidgetWin_2, OpWindow, IEFrame
|BrowserExes|Comma-separated list of ahk_exes which are considered to represent web browsers for the sake of closing only the active tab via Ctrl-W, as opposed to Alt+F4. The ahk_class of the browser needs to be added to BrowserClasses as well for DistractLess to identify the browser correctly. This is necessary as there are _way_ too many programs built on chrome's framework, but we don't want those to count as browsers. (Looking at you, Spotify) |Text| firefox.exe, chrome.exe, iexplore.exe, opera.exe, msedge.exe
|BrowserNewTabs|Comma-separated list of new-tab names for each browser you are using. Because this is different depending on language, and it is more or less impossible for me to provide a full-coverage list here now, this must be manually created by the user. To do so, please replace the "-1" by the names of the new tab in your respective browser(s).You are asked to configure this setting upon first start. Afterwards, you can add further cases here if an empty tab is suddenly closed.| Text | -1
|bLVDelete_RequireConfirmation | If  checked, any action removing items from a listview requires specific confirmation. If unchecked, this double-check is skipped. Items can still be restored as usual. | Checkbox |0
|bStartup|Create shortcut (lnk) in the startup folder for DistractLess to start automatically. | Checkbox |0
|sLocationUserBackup|Set time in milliseconds until the current window is matched against the set whitelist and/or blacklist. Lower values mean more immediate closing of blocked windows, higher values reduce the frequency of checks. Choose the folder to store custom lists in via the "Save LV's"-button. | Folder | DistractLess_Storage\\UserBackups
| sFontSize_Text|Set font-size for the following controls: Text, Edit-fields, Sliders | Integer | 7
| sFontType_Text|Set Font for all texts, excluding the listviews.|DropDownList|Times New Roman
| sFontSize_ListView|Set font-size for all listviews | Integer | 7
| sFontType_ListView|Set Font for all listviews.|DropDownList|Segoe UI
| bShowOnProgramStart | Decide wether or not to show the GUI when the program has finished its start-routine. Does not affect silent restarts if closed prematurely (cf. OnExitBehaviour). This has no effect if no set of conditions is loaded. I.e. if "OnExitBehaviour" is set to "Empty", the GUI will never be shown.  | Checkbox |1

Table 5: Settings of the program. All non-bolded settings have little importance and should not necessarily be customised.  Inversely, bolded settings are recommended to be edited.


## 9. Credits

This project hinges on a lot of code by others. The following table gives an overview over what functions are written by whom - if I could attribute a function properly.

For all functions, see the function definition and associated documentation for more details. License-files are located under `A_SCriptDir\DistractLess_Storage\licenses` where required.
All Functions below have the URL at which they were retrieved stated.

| Function | Author | Link
|:------------------|:------------------|:------------------|
|	HasVal | jNizM | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
|	st_wordwrap | tidbit | retrieved from https://www.autohotkey.com/boards/viewtopic.php?t=53
|	st_removeDuplicates | see above
|	st_count | see above
|	WriteINI/ReadINI | wolf_II | adopted from https://www.autohotkey.com/boards/viewtopic.php?p=256714#p256714
|	hk | this specific version by SpeedMaster, original by feiyue | adopted from https://www.autohotkey.com/boards/viewtopic.php?p=283777#p283777
|	HideFocusBorder | this specific version by "just me" | adopted from https://www.autohotkey.com/boards/viewtopic.php?p=55162#p55162
|	getURL | anonymous1184 | adopted from https://www.reddit.com/r/AutoHotkey/comments/mqnuql/comment/guinpck/?utm_source=share&utm_medium=web2x&context=3
|	ACC.ahk | could not find definitive author | retrieved from https://www.autohotkey.com/boards/viewtopic.php?t=26201
|	CodeTimer | CodeKnight | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=316296#p316296
|	f_TrayIconSingleClickCallBack | Lexikos | adopted from https://www.autohotkey.com/board/topic/26639-tray-menu-show-gui/?p=171954
|	NotifyTrayClick | SKAN | retrieved from https://www.autohotkey.com/boards/viewtopic.php?t=81157
|	TF_ReplaceInLines | forum name ahk7, github hi5 | retrieved from https://www.autohotkey.com/boards/viewtopic.php?f=6&t=576
|	TF_GetData | see above
|	\_MakeMatchList | see above
|	TF_ReturnOutPut | see above
|	IniSettingsEditor_v6 | Rajat, mod by toralf | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=237927#p237927, specifically gamax92_archive of the  download
|	IniFileCreator_v8 |  toralf, modded by Gewerd Strauss | retrieved from https://www.autohotkey.com/boards/viewtopic.php?p=237927#p237927, specifically gamax92_archive of the download

Table 6: Contributed Code by others. All URL's last checked as of 09.11.2021 19:45 CET.

## 10.


[^1]: Note that while this is valid Regex-syntax, the program does _not_ perform a regex-search. The `Instr()`-function is used. This syntax is solely used because I needed something that can be expected not to be an actual pattern a user is looking for.
[^2]:Only possible if "LockingBehaviour" is set to "Time-protected".
[^3]:Only possible if "LockingBehaviour" in settings is set to "Password-protected".


---
