


# [Scripting Language and Region settings for current user, default user and welcome screen](https://engineering.thetrainline.com/scripting-language-and-region-settings-for-current-user-default-user-and-welcome-screen-859bbd58900d)
 
## [Trainline Engineering](https://engineering.thetrainline.com/)


Jun 2, 2015 · 3 min read
At first glance, this seems like a simple and straight forward task; set the language and region for the current user, default user and welcome screen using command line tools. It’s easily done with the GUI, and Microsoft like to ensure that anything that can be done in the GUI can also be done in PowerShell, so this should be easy, no? Sadly, no.
### Current User
Okay, so this one is easy. Three PowerShell commandlets are all you need; set-Culture, Set-WinHomeLocation, and SetWinUserLanguageList. While you’re at it, you can also set the System Locale using Set-SystemLocale.

```
  Set-Culture en-GB
  Set-WinSystemLocale en-GB
  Set-WinHomeLocation -GeoId 242
  Set-WinUserLanguageList en-GB -force
```

See the [Windows GeoID list](https://msdn.microsoft.com/en-us/library/windows/desktop/dd374073%28v=vs.85%29.aspx) for a complete list of GeoIDs for use with the Get-WinHomeLocation commandlet.

### Default User and System Accounts

Anyone who’s ever built a Windows Server manually knows how to use the GUI to copy the Region and Language settings from the current user to the Default User and Welcome Screen/System accounts using the ‘Administrative’ tab on the Region Control Panel snap-in. However, there are no PowerShell commandlets to achieve the same, which means we must figure it out for ourselves.

If we run [ProcMon](https://technet.microsoft.com/en-us/library/bb896645.aspx) we can see which registry keys are modified when we use the GUI to copy the settings. Three hives are modified; HKU\.DEFAULT, HKU\S-1–5–19, and HKU\S-1–5–20. These are the hives for Default User, Local Service, and Network Service, respectively. We also see that the Default User hive C:\Users\Default\NTUSER.DAT is loaded, modified and saved — it is mounted as HKU\TEMP.

The following keys are modified under each of the above User Hives:

* Keyboard Layout
* Control Panel\International
* Control Panel\Input Methods

It’s simple enough to export these keys from the current user and import them with reg or regedit. Below is an example reg file to import — you’ll need four in total; one for .DEFAULT, S-1–5–19, S-1–5–20, and a temporary mount point for the Default User NTUser.DAT (I’ve loaded this as ‘TEMP’).
The following PowerShell code will import the four reg files (ensure they’re in the same directory as the script)

```
$path = Split-Path -parent $PSCommandPath$TempKey= "HKU\TEMP"
$DefaultRegPath = "C:\Users\Default\NTUSER.DAT"reg load $TempHKEY $DefaultRegPathGet-ChildItem $path -Filter *.reg | % {
    Start-Process regedit -ArgumentList "/s `"$($_.FullName)`"" -Wait
}reg unload $TempHKEYWindows Registry Editor Version 5.00[HKEY_USERS\TEMP\Control Panel\Input Method]
"Show Status"="1"[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys][HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000010]
"Key Modifiers"=hex:02,c0,00,00
"Virtual Key"=hex:20,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000011]
"Key Modifiers"=hex:04,c0,00,00
"Virtual Key"=hex:20,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000012]
"Key Modifiers"=hex:02,c0,00,00
"Virtual Key"=hex:be,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000070]
"Key Modifiers"=hex:02,c0,00,00
"Virtual Key"=hex:20,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000071]
"Key Modifiers"=hex:04,c0,00,00
"Virtual Key"=hex:20,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000072]
"Key Modifiers"=hex:03,c0,00,00
"Virtual Key"=hex:bc,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000104]
"Key Modifiers"=hex:06,c0,00,00
"Virtual Key"=hex:30,00,00,00
"Target IME"=hex:11,04,01,e0[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000200]
"Key Modifiers"=hex:03,c0,00,00
"Virtual Key"=hex:47,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000201]
"Key Modifiers"=hex:03,c0,00,00
"Virtual Key"=hex:4b,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000202]
"Key Modifiers"=hex:03,c0,00,00
"Virtual Key"=hex:4c,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\Input Method\Hot Keys0000203]
"Key Modifiers"=hex:03,c0,00,00
"Virtual Key"=hex:56,00,00,00
"Target IME"=hex:00,00,00,00[HKEY_USERS\TEMP\Control Panel\International]
"Locale"="00000809"
"LocaleName"="en-GB"
"s1159"="AM"
"s2359"="PM"
"sCountry"="United Kingdom"
"sCurrency"="£"
"sDate"="/"
"sDecimal"="."
"sGrouping"="3;0"
"sLanguage"="ENG"
"sList"=","
"sLongDate"="dd MMMM yyyy"
"sMonDecimalSep"="."
"sMonGrouping"="3;0"
"sMonThousandSep"=","
"sNativeDigits"="0123456789"
"sNegativeSign"="-"
"sPositiveSign"="+"
"sShortDate"="dd/MM/yyyy"
"sThousand"=","
"sTime"=":"
"sTimeFormat"="HH:mm:ss"
"sShortTime"="HH:mm"
"sYearMonth"="MMMM yyyy"
"iCalendarType"="1"
"iCountry"="44""iCurrDigits"="2"
"iCurrency"="0"
"iDate"="1"
"iDigits"="2"
"NumShape"="1"
"iFirstDayOfWeek"="0"
"iFirstWeekOfYear"="2"
"iLZero"="1"
"iMeasure"="0"
"iNegCurr"="1"
"iNegNumber"="1"
"iPaperSize"="9"
"iTime"="1"
"iTimePrefix"="0"
"iTLZero"="1"[HKEY_USERS\TEMP\Control Panel\International\Geo]
"Nation"="242"[HKEY_USERS\TEMP\Control Panel\International\User Profile]
"Languages"=hex(7):65,00,6e,00,2d,00,47,00,42,00,00,00
"ShowAutoCorrection"=dword:00000001
"ShowTextPrediction"=dword:00000001
"ShowCasing"=dword:00000001
"ShowShiftLock"=dword:00000001
"WindowsOverride"="en-GB"
"UserLocaleFromLanguageProfileOptOut"=dword:00000001[HKEY_USERS\TEMP\Control Panel\International\User Profile\en-GB]
"CachedLanguageName"="@Winlangdb.dll,-1110"
"0809:00000809"=dword:00000001[HKEY_USERS\TEMP\Control Panel\International\User Profile System Backup]
"Languages"=hex(7):65,00,6e,00,2d,00,47,00,42,00,00,00
"ShowAutoCorrection"=dword:00000001
"ShowTextPrediction"=dword:00000001
"ShowCasing"=dword:00000001
"ShowShiftLock"=dword:00000001
"WindowsOverride"="en-GB"
"UserLocaleFromLanguageProfileOptOut"=dword:00000001[HKEY_USERS\TEMP\Control Panel\International\User Profile System Backup\en-GB]
"CachedLanguageName"="@Winlangdb.dll,-1110"
"0809:00000809"=dword:00000001[HKEY_USERS\TEMP\Keyboard Layout][HKEY_USERS\TEMP\Keyboard Layout\Preload]
"1"="00000809"[HKEY_USERS\TEMP\Keyboard Layout\Substitutes][HKEY_USERS\TEMP\Keyboard Layout\Toggle]
"Hotkey"="1"
•	

```
