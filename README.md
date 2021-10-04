# DistractLess

A small program meant to keep you focused by closing websites and programs matching different set of rules regarding their window/tab name and URL

NOT finished by any means. 
First version is operational. 
Documentation is in the works, but won't be published for some time, because I have more important things to do right now.

Manual version 1.0

# 1. Fundamentals

DistractLess is a program designed to shut down distracting programs and browser tabs as soon as they gain focus.
It does so by comparing the current window's title against your sets of whitelisted and blacklisted criteria. Depending on the type of the criteria, a URL can be compared as well. 

For more information, see [Understanding the filter mechanism]

# 2. The GUI

![Figure 1: The Main Window](D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\Documentation\DL_MainWindow.PNG "")

The main overlay can be broken up into three different sections:
The left section displays stored and active _whitelisted_ strings. The right third displays _blacklisted_ ones. 

The middle section allows the creation of new conditions, the loading from and saving to a file (both in the upper section) and to quickly change the program behaviour (lower section)

## 2.1 Adding a criterium to a list

### 2.1.1 Criteria categories
Criteria are split into two categories:

1. programs
2. websites

Both are exclusively checked depending on the current window. 

### 2.1.1.1 Browser matches
The rules to detect a browser are predefined for the following browsers out of the box:

1. Google Chrome 
2. Mozilla Firefox
3. Internet Explorer
4. Microsoft Edge
5. Opera

To edit these rules, open the settings (cf. Changing program settings) and edit the comma-separated lists of `BrowserClasses`, `BrowserExes`  according to the instructions there. Any window matching both of these lists is considered a browser window.

A browser match requires the "website"-type to be selected. 


### 2.1.1.2 Program matches

A program, for DistractLess, is any application that is not considered a browser - and therefore doesn't match the `BrowserClasses` and `BrowserExes` with their respective class and exe as displayed by the window spy. For people who don't have autohotkey itself installed and are using the compiled version of the window spy in `DistractLess\includes\DistractLess_WindowSpy.exe`. Keep the window open and click on the browser you want to add. 

* the first line displays the window title of the currently active window
* the string displayed _behind_ "ahk_class" (without the space inbetween, _just_ whatever comes after the space) must be added to BrowserClasses in the settings.
* the string displayed _behind_ "ahk_exe" (without the space inbetween, _just_ whatever comes after the space) must be added to BrowserExes in the settings.
* the last line is absolutely irrelevant for the scope of this application.

In case of the following example, you would add `MozillaWindowClass` to `BrowserClasses` and `firefox.exe` to `BrowserExes` respectively. Don't forget to separate each entry by a commata (,).

You can ignore the first and last line of this first field (under "Window Title, Class and Process"), as well as all other info displayed.

![Figure 2: relevant contents of the window spy overlay](D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\Documentation\DL_ContentsWindowSpy.PNG "")

---

Now that you have added any possible browsers you might be using, let's go over _programs_ (remember, those have distinctly nothing in common with the settings you have just edited.)

A program is only matched according to its window title against any ***p***rogram-condition currently visible within the top two listviews visible in figure 1.

### 2.1.2 Syntax


DistractLess always checks if the current window's title _contains_ the substring. There is no distinction made between upper and lowercase, only the order of symbols must match anywhere within the current window's title.

To have a criteria match any title, set the title string to `.*`.

A few notes:
1. this must be the only element in the substring criteria
2. it cannot be applied to **blacklisted programs**, but to blacklisted websites which have a specific url on which they act.
3. this cannot be implemented for URL-wildcards (you cannot set title substring AND website url to ".*" simultaneously)


These restrictions are necessary so the program doesn't suddenly start closing everything in an uncontrollable manner.

### 2.1.3 Adding an existing window's conditions.

When the main gui (cf. Figure 1) is open, you can press `Alt+e` to launch a helper-tool for setting conditions faster.

![Figure 3: Choose a condition from existing windows](D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\Documentation\DL_ChooseCurrentWindowOverlay.PNG "")

After the window of figure 3 opens, navigate to the desired program/browser tab and press Ctrl+Left Mouse **onto that window**. The respective title (and url if it is considered a browser) are added into the edit fields seen in figure 4. The conditions' type (website or program) is selected automatically. Edit the substring to a suitable level of specificity and the url possibly and decide wether or not to add it as a blacklist- or whitelist-criteria.
If you want to generalise a certain criteria, replace title or URL substring with ".*", according to the rules displayed in [syntax](#212-syntax).

![Figure 4: Create a (website) condition](D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\Documentation\DL_CloseUpAddSSAllShown.PNG "")


Alteratively, you can just create your conditions by hand, but usually that will be more prone to error and take longer :P

Pressing `Save LV's` will open a dialogue to save the current configuration for later access. The default folder can be changed under `sLocationUserBackup` in the settings 3. Accessing and editing the [settings](#3.-accessing-and-editing-the-settings).

### 2.2 The lower middle section

This section is pretty quickly explained, because not a lot is happening here.
Two Dropdownlists influence the behaviour of the program.

The program has three filter-modes:

#### 2.2.1. Both

The easiest to use, fastest to balance mode. 
Rules for the "Both"-mode:

##### 2.2.1.1 White>Black

1. If both the whitelist and blacklist contain a matching entry, the window/browser tab is not closed.
2. If only black contains a matching criterium, and whitelist does not match at all, the window/website _is_ closed.

##### 2.2.1.2 Black>White
As soon as blacklist matches the current window/browser tab, it _is_ closed, regardless of wether or not whitelist matches. After I finished implementing this, I realised that it is effectively just a more confusing blacklist-only mode. I might rehaul it at some point to work differently, but I am not sure.


#### 2.2.2. Black Only

As soon as a window matches a criteria, it is closed.


#### 2.2.3. White Only\*

This option is only available if the setting "bAllowWhiteOnly" is checked in the settings.
This extra barrier of entry is necessary because this mode is extremely restrictive. Under its ruleset, _any_ window not explicitly matching _any one_ condition of the whitelist is closed.

When setting up criteria sets for this mode, please ensure you are running in [diagnostics mode](#4.-entering-diagnostics-mode) first.


### 3. Accessing and editing the settings

In order to access the settings, double-click the author-section of the bar at the bottom of the main window _once_. You should hear a high-pitched double-beep, but you might also not depending on a variety of factors outside of my control. Afterwards, every double-click on the second section (DistractLess v.W.X.Y.Z) will open the settings dialogue (cf Figure 5). 

Each setting comes with a small description about its usecase, and possible options. The type of the input is displayed, as well as a default value which is restored when pressing "Restore". Settings are saved automatically. In the example of figure 5, we are looking at the `OnExitBehaviour`, and a dropdown-list displays possible options.

![Figure 5: Settings Menu](D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\Documentation\DL_SettingsMenu.PNG "")

Figure 6 displays a known, but to me not solvable bug. The description displayed can sometimes be muddied by the display of another setting's description. 

These cases can be identified because the "Default:...."- and "Type:...."- information is displayed twice. In these cases, the _lowest_ description is the "correct" one.

![Figure 6: Faulty double description](D:\DokumenteCSA\000 AAA Dokumente\000 AAA HSRW\General\AHK scripts\Projects\DistractLess\Documentation\DL_FaultySettingsDescription.PNG "")

Settings are autosaved upon change or closing of the window. Most settings take effect immediately, but some require a program restart.

### 4. Entering diagnostics-mode

[syntax](#212-syntax)
[go to test](#212-syntax)
