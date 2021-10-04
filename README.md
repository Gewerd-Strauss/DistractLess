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

A program is only matched according to its window title against any ***p***rogram-condition.
