﻿/*
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*					POE Trades Helper																															*
*					See all the information about the trade request upon receiving a poe.trade whisper															*
*																																								*
*					https://github.com/lemasato/POE-Trades-Helper/																								*
*					https://www.reddit.com/r/pathofexile/comments/57oo3h/																						*
*					https://www.pathofexile.com/forum/view-thread/1755148/																						*
*																																								*	
*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*
*/

OnExit("Exit_Func")
#SingleInstance Off
#Persistent
#NoEnv
SetWorkingDir, %A_ScriptDir%
FileEncoding, UTF-8 ; Required for cyrillic characters
#KeyHistory 0
ListLines Off
SetWinDelay, 0
DetectHiddenWindows, Off

;	Creating Window Switch Detect
Gui +LastFound 
Hwnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt,Hwnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage")

Start_Script()
Return

Start_Script() {
/*
*/
	global ProgramValues, GlobalValues, TradesGUI_Controls
	global POEGameArray, POEGameList

;	Values Assignation
	EnvGet, userprofile, userprofile

	TradesGUI_Controls := Object() ; TradesGUI controls handlers

	GlobalValues := Object() ; Preferences.ini keys + some other shared global variables
	GlobalValues.Insert("Screen_DPI", Get_DPI_Factor())

	ProgramValues := Object() ; Specific to the program's informations
	ProgramValues.Insert("Name", "POE Trades Helper")
	ProgramValues.Insert("Version", "1.8.8")
	ProgramValues.Insert("Debug", "0")

	GlobalValues.Insert("Trades_GUI_Skin", "Path of Exile")
	GlobalValues.Insert("Trades_GUI_Font", "Fontin SmallCaps")

	ProgramValues.Insert("PID", DllCall("GetCurrentProcessId"))

	ProgramValues.Insert("Reddit", "https://redd.it/57oo3h")
	ProgramValues.Insert("GGG", "https://www.pathofexile.com/forum/view-thread/1755148/")
	ProgramValues.Insert("GitHub", "https://github.com/lemasato/POE-Trades-Helper")

	ProgramValues.Insert("Local_Folder", userprofile "\Documents\AutoHotkey\" ProgramValues["Name"])
	ProgramValues.Insert("SFX_Folder", ProgramValues["Local_Folder"] "\SFX")
	ProgramValues.Insert("Logs_Folder", ProgramValues["Local_Folder"] "\Logs")
	ProgramValues.Insert("Skins_Folder", ProgramValues["Local_Folder"] "\Skins")
	ProgramValues.Insert("Fonts_Folder", ProgramValues["Local_Folder"] "\Fonts")

	ProgramValues.Insert("Ini_File", ProgramValues["Local_Folder"] "\Preferences.ini")
	ProgramValues.Insert("Logs_File", ProgramValues["Logs_Folder"] "\" A_YYYY "-" A_MM "-" A_DD "_" A_Hour "-" A_Min "-" A_Sec ".txt")
	ProgramValues.Insert("Changelogs_File", ProgramValues["Logs_Folder"] "\changelogs.txt")

	GroupAdd, POEGame, ahk_exe PathOfExile.exe
	GroupAdd, POEGame, ahk_exe PathOfExile_x64.exe
	GroupAdd, POEGame, ahk_exe PathOfExileSteam.exe
	GroupAdd, POEGame, ahk_exe PathOfExile_x64Steam.exe
	POEGameArray := Object()
	POEGameArray.Insert(0, "PathOfExile.exe", "PathOfExile_x64.exe", "PathOfExileSteam.exe", "PathOfExile_x64Steam.exe")
	POEGameList := "PathOfExile.exe,PathOfExile_x64.exe,PathOfExileSteam.exe,PathOfExile_x64Steam.exe"

;	Directories Creation
	Loop {
		directory := (A_Index=1)?(ProgramValues["Local_Folder"])
					:(A_Index=2)?(ProgramValues["SFX_Folder"])
					:(A_Index=3)?(ProgramValues["Logs_Folder"])
					:(A_Index=4)?(ProgramValues["Skins_Folder"])
					:(A_Index=5)?(ProgramValues["Fonts_Folder"])
					:("ERROR")
		if ( directory = "ERROR" )
			Break

		else if (!InStr(FileExist(directory), "D")) {
			FileCreateDir, % directory
		}
	}

	; global iniFilePath, programName, programVersion, programFolder, programPID, programSFXFolderPath, programChangelogsFilePath, POEGameArray, POEGameList
	; global programFontFolderPath, programLogsFilePath, programLogsPath, programRedditURL, programSkinFolderPath

;	Function Calls
	Create_Tray_Menu()
	Run_As_Admin()
	Close_Previous_Program_Instance()
	Tray_Refresh()
	Set_INI_Settings()
	settingsArray := Get_INI_Settings()
	Declare_INI_Settings(settingsArray)
	Create_Tray_Menu(1)
	Delete_Old_Logs_Files(10)
	Do_Once()
	Extract_Sound_Files()
	Extract_Skin_Files()
	Extract_Font_Files()
	Check_Update()
	Enable_Hotkeys()

;	Pre-rendering Trades-GUI
	Gui_Trades(,"CREATE")


	;	Debug purposes. Simulates TradesGUI tabs. 
	if ( ProgramValues["Debug"] ) {
		Loop 4 {
			newItemInfos := Object()
			newItemInfos.Insert(0, "iSellStuff", "level 1 Faster Attacks Support", "5 alteration", "Breach (stash tab ""Gems""; position: left 6, top 8)", "",A_Hour ":" A_Min, "Offering 1alch?")
			newItemArray := Gui_Trades_Manage_Trades("ADD_NEW", newItemInfos)
			Gui_Trades(newItemArray, "UPDATE")
			newItemInfos.Insert(0, "aktai0", "Kaom's Heart Glorious Plate", "10 exalted", "Hardcore Legacy", "",A_Hour ":" A_Min, "-")
			newItemArray := Gui_Trades_Manage_Trades("ADD_NEW", newItemInfos)
			Gui_Trades(newItemArray, "UPDATE")
			newItemInfos.Insert(0, "MindDOTA2pl", "Voll's Devotion Agate Amulet ", "4 exalted", "Standard", "",A_Hour ":" A_Min, "-")
			newItemArray := Gui_Trades_Manage_Trades("ADD_NEW", newItemInfos)
			Gui_Trades(newItemArray, "UPDATE")
			newItemInfos.Insert(0, "Krillson", "Rainbowstride Conjurer Boots", "3 mirror", "Hadcore", "",A_Hour ":" A_Min, "-")
			newItemArray := Gui_Trades_Manage_Trades("ADD_NEW", newItemInfos)
			Gui_Trades(newItemArray, "UPDATE")
		}
	}

	Logs_Append("START", settingsArray)
	Monitor_Game_Logs()
}

;==================================================================================================================
;
;										LOGS MONITORING
;
;==================================================================================================================

Restart_Monitor_Game_Logs() {
	global ProgramValues
	global guiTradesHandler

	iniFilePath := ProgramValues["Ini_File"]

	WinGetPos, xpos, ypos, , ,% "ahk_id " GuiTradesHandler
	IniWrite,% xpos,% iniFilePath,PROGRAM,X_POS
	IniWrite,% ypos,% iniFilePath,PROGRAM,Y_POS
	Monitor_Game_Logs("CLOSE")
	Monitor_Game_Logs()
}

Monitor_Game_Logs(mode="") {
;			Retrieve the logs file location by adding \Logs\Client.txt to the PoE executable path
;			Monitor the logs file, waiting for new whispers
;			Upon receiving a poe.trade whisper, pass the trades infos to Gui_Trades()
	static
	global GlobalValues
	global GuiTradesHandler, POEGameArray

	if (mode = "CLOSE") {
		fileObj.Close()
		Return
	}

	r := Get_All_Games_Instances()
	if ( r = "EXE_NOT_FOUND" ) {
		messagesArray := Gui_Trades_Manage_Trades("GET_ALL")
		Gui_Trades(messagesArray, "EXE_NOT_FOUND")
	}
	else {
		messagesArray := Gui_Trades_Manage_Trades("GET_ALL")
		Gui_Trades(messagesArray, "UPDATE")
		logsFile := r
	}
	Logs_Append(A_ThisFunc,,logsFile)

	fileObj := FileOpen(logsFile, "r")
	fileObj.pos := fileObj.length
	Loop {
		if !FileExist(logsFile) || ( fileObj.pos > fileObj.length ) || ( fileObj.pos = -1 ) {
			Logs_Append("Monitor_Game_Logs_Break",,fileObj.pos,fileObj.length)
			Break
		}
		if ( fileObj.pos < fileObj.length ) {
			lastMessage := fileObj.Read() ; Stores the last message into a variable
			Loop, Parse, lastMessage, `n, `r ; For each new individual line since last check
			{
				; New RegEx pattern matches the trading message, but only from whispers and local chat (for debugging), and specifically ignores global/trade/guild/party chats
				if ( RegExMatch( A_LoopField, "^(?:[^ ]+ ){6}(\d+)\] (?=[^#$&%]).*@(?:From|De|От кого) (.*?): (.*)", subPat ) )
				{
					gamePID := subPat1, whispName := subPat2, whispMsg := subPat3
					GlobalValues.Insert("Last_Whisper", whispName)

					; Append the new whisper to the buyer's Other slots
					tradesInfos := Gui_Trades_Manage_Trades("GET_ALL")
					for key, element in tradesInfos.BUYERS {
						if (whispName = element) {
							otherContent := tradesInfos.OTHER[key]
							if otherContent not contains (Hover to see all messages) ; Only one message in the Other slot.
							{
								StringReplace, otherContent, otherContent,% "`n",% "",1 ; Remove blank lines
								otherContent := "[" tradesInfos.TIME[key] "] " otherContent ; Add timestamp
							}
							StringReplace, otherContent, otherContent,% "(Hover to see all messages)`n",% "",1
							otherText := "(Hover to see all messages)`n" otherContent "`n[" A_Hour ":" A_Min "] " whispMsg
							setInfos := Object(), setInfos.OTHER := otherText, setInfos.TabID := key
							Gui_Trades_Set_Trades_Infos(setInfos)
						}
					}

					if ( GlobalValues["Whisper_Tray"] = 1 ) && !WinActive("ahk_pid " gamePID) { ; Show a tray notification of the whisper
						Loop 2 {
							TrayTip, Whisper Received:,%whispName%: %whispMsg%
						}
						SetTimer, Remove_TrayTip, -10000
					}

					if ( GlobalValues["Whisper_Flash"] = 1 ) && !WinActive("ahk_pid " gamePID) { ; Flash the game window taskbar icon
						gameHwnd := WinExist("ahk_pid " gamePID)
						DllCall("FlashWindow", UInt, gameHwnd, Int, 1)
					}

					whisp := whispName ": " whispMsg "`n"
					if RegExMatch(whisp, ".*: (.*)Hi, I(?: would|'d) like to buy your (?:(.*) |(.*))(?:listed for (.*)|for my (.*)|)(?!:listed for|for my) in (?:(.*)\(.*""(.*)""(.*)\)|Hardcore (.*?)\W|(.*?)\W)(.*)", subPat ) ; poe.trade whisper found
					{
						tradeItem := (subPat2)?(subPat2):(subPat3)?(subPat3):("ERROR RETRIEVING ITEM")
						tradePrice := (subPat4)?(subPat4):(subPat5)?(subPat5):("UNPRICED ITEM")
						tradeStash := (subPat6)?(subPat6 "- " subpat7 " " subPat8):(subPat9)?("Hardcore " subPat9):(subPat10)?(subPat10):("ERROR RETRIEVING LOCATION")
						tradeOther := (subPat10!=subPat6 && subPat10!=subPat9 && subPat10!=tradeStash)?(subPat1 subPat10):(subPat11 && subPat11!="`n")?(subPat11):("-")
						tradeItem = %tradeItem% ; Remove blank spaces
						tradePrice = %tradePrice%
						tradeStash = %tradeStash%
						tradeOther = %tradeOther%
						StringReplace, tradeItem, tradeItem,% " 0%",% "", 1 ; Remove 0% quality gem

						; Do not add the trade if the same is already in queue
						tradesExists := 0
						tradesInfos := Gui_Trades_Manage_Trades("GET_ALL")
						for key, element in tradesInfos.BUYERS {
							buyerContent := tradesInfos.BUYERS[key], itemContent := tradesInfos.ITEMS[key], priceContent := tradesInfos.PRICES[key], locationContent := tradesInfos.LOCATIONS[key], otherContent = tradesInfos.OTHER[key]
							if (buyerContent=whispName && itemContent=tradeItem && priceContent=tradePrice && locationContent=tradeStash) {
								tradesExists := 1
							}
						}

						; Trade does not already exist
						if (tradesExists = 0) {
							newTradesInfos := Object()
							newTradesInfos.Insert(0, whispName, tradeItem, tradePrice, tradeStash, gamePID, A_Hour ":" A_Min, tradeOther)
							messagesArray := Gui_Trades_Manage_Trades("ADD_NEW", newTradesInfos)
							Gui_Trades(messagesArray, "UPDATE")

							if ( GlobalValues["Clip_New_Items"] = 1 ) { ; Clipboard the item
								Clipboard := tradeItem
							}

							if ( GlobalValues["Trade_Toggle"] = 1 ) && FileExist(GlobalValues["Trade_Sound_Path"]) { ; Play the sound set for trades
								SoundPlay,% GlobalValues["Trade_Sound_Path"]
							}
						}
					}
					else {
						if ( GlobalValues["Whisper_Toggle"] = 1 ) && FileExist(GlobalValues["Whisper_Sound_Path"]) { ; Play the sound set for whispers
							SoundPlay,% GlobalValues["Whisper_Sound_Path"]
						}
					}
				}
			}
		}
		sleep 100
	}
	Loop 2 {
		TrayTip,% "POE Trades Helper - Issue with the logs file!",% "It could be one of the following reasons: "
		. "`n- The file doesn't exist anymore."
		. "`n- Content from the file was deleted."
		. "`n- The file object used by the program was closed."
		. "`n`nThe logs monitoring function will be restarting in 5 seconds."
	}
	SetTimer, Remove_TrayTip, -5000
	sleep 5000
	Restart_Monitor_Game_Logs()
}

;==================================================================================================================
;
;												HOTKEYS
;
;==================================================================================================================

Hotkeys_User_1:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_2:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_3:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_4:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_5:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_6:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_7:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_8:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_9:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_10:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_11:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_12:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_13:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_14:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_15:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_16:
	Hotkeys_User_Handler(A_ThisLabel)
Return

Hotkeys_User_Handler(thisLabel) {
	global GlobalValues, ProgramValues

	iniFilePath := ProgramValues["Ini_File"]

	RegExMatch(thisLabel, "\d+", hotkeyID)
	tradesInfosArray := Object()
	tabID := GlobalValues["Trades_GUI_Current_Active_Tab"]
	if ( tabID ) {
		tabInfos := Gui_Trades_Get_Trades_Infos(tabID) ; [0] buyerName - [1] itemName - [2] itemPrice
	}

	if ( GlobalValues["Hotkeys_Mode"] = "Advanced" ) {
		key := "HK" hotkeyID
		IniRead, textToSend,% iniFilePath,HOTKEYS_ADVANCED,% key "_ADV_TEXT"
	}
	else {
		key := "HK" hotkeyID
		IniRead, textToSend,% iniFilePath,HOTKEYS,% key "_TEXT"
	}
	Send_InGame_Message(textToSend, tabInfos,1)
}

;==================================================================================================================
;
;												TRADES GUI
;
;==================================================================================================================
	
Gui_Trades(infosArray="", errorMsg="") {
;			Trades GUI. Each new item will be added in a new tab
;			Clicking on a button will do its corresponding action
;			Switching tab will clipboard the item's infos if the user enabled
;			Is transparent and click-through when there is no trade on queue
	static
	global ProgramValues, GlobalValues, TradesGUI_Controls
	global GuiTradesHandler, TradesGuiHeight, TradesGuiWidth

	iniFilePath := ProgramValues["Ini_File"]
	programName := ProgramValues["Name"]
	programSkinFolderPath := ProgramValues["Skins_Folder"]

	if ( errorMsg = "CREATE" ) {
		defaultMaxTabs := 10
		maxTabsRow := 7

		Gui, Trades:Destroy
		Gui, Trades:New, +ToolWindow +AlwaysOnTop -Border +hwndGuiTradesHandler +LabelGui_Trades_ +LastFound -SysMenu -Caption
		Gui, Trades:Default
		tabHeight := Gui_Trades_Get_Tab_Height(), tabWidth := 390
		guiWidth := 402, guiHeight := tabHeight+38, guiHeightMin := 30
		Gui, Font, s10 cWhite,% GlobalValues["Trades_GUI_Font"]
		Gui, Add, Picture,% "x0 y0 w" guiWidth " h30 ",% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\Header.png"
		Gui, Add, Text,% "x35 y2 w" guiWidth-100 " h28 cC18F55 BackgroundTrans gGui_Trades_Move +0x200 hwndguiTradesTitleHandler",% programName " - Queued Trades: 0"
		Gui, Add, Text,% "x" guiWidth-65 " w65 y2 h28 + +0x200 cC18F55 gGui_Trades_Minimize +BackgroundTrans",% "MINIMIZE"
		Gui, Color, 181511
		Gui, Add, Picture, x1 y30 w%guiWidth% h%guiHeight%,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\Background.png"
		Gui, Add, Picture, x1 y50 w%guiWidth% h2,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabUnderline.png"
		Gui, Add, Text,% "x0 y0 w" guiWidth " h2 +0x4",% "" ; Top
		Gui, Add, Text,% "x0 y0 w2 h" guiHeight " +0x4",% "" ; Left
		Gui, Add, Text,% "x0 y" guiHeight-2 " w" guiWidth + 5 " h2 +0x4",% "" ; Bottom
		Gui, Add, Text,% "x" guiWidth-2 " y0 w2 h" guiHeight " +0x4",% "" ; Right

		aeroStatus := Get_Aero_Status()
		themeState := (aeroStatus=1)?("+Theme -0x8000"):("-Theme +0x8000")

		GlobalValues.Insert("Trades_GUI_Current_State", "Active")
		IniRead, tabsMax,% iniFilePath, PROGRAM, Rendered_Tabs
		tabsMax := (tabsMax="ERROR"||tabsMax=""||!tabsMax)?(defaultMaxTabs):(tabsMax)
		if ( tabsMax > 25 ) {
			Loop 2
				TrayTip,% programName,Rendering more tabs,3
			SetTimer, Remove_TrayTip,-3000
		}
		Loop %tabsMax% {
			index := A_Index
			tabPos := A_Index
			xposMult := 50
			xpos := (tabPos * xposMult) - xposMult + 2, ypos := 30
			
			Gui, Add, Picture, x%xpos% y%ypos% w50 h20 hwndTabIMG%index%Handler vTabIMG%index% gGui_Trades_Tabs_Handler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabInactive.png"
			Gui, Font, Bold
			Gui, Add, Text, xp yp+3 +BackgroundTrans w50 h20 hwndTabTXT%index%Handler vTabTXT%index% gGui_Trades_Tabs_Handler 0x01,% index
			Gui, Font, Norm
			GuiControl, Trades:Hide,% TabIMG%index%Handler
			GuiControl, Trades:Hide,% TabTXT%index%Handler

			TradesGUI_Controls.Insert("Tab_IMG_" index,TabIMG%index%Handler)
			TradesGUI_Controls.Insert("Tab_TXT_" index,TabTXT%index%Handler)
		}
		Loop %tabsMax% {
			index := A_Index
			Gui, Font, cC18F55

			if ( index = 1 ) {
				Gui, Add, Text, x9 y60 w60 h15 hwndBuyerText%index%Handler +BackgroundTrans,% "Buyer: "
				Gui, Add, Text, w60 h15 xp yp+15 hwndItemText%index%Handler +BackgroundTrans,% "Item: "
				Gui, Add, Text, w60 h15 xp yp+15 hwndPriceText%index%Handler +BackgroundTrans,% "Price: "
				Gui, Add, Text, w60 h15 xp yp+15 hwndLocationText%index%Handler +BackgroundTrans,% "Location: "
				Gui, Add, Text, w60 h15 xp yp+15 hwndOtherText%index%Handler +BackgroundTrans,% "Other: "

				TradesGUI_Controls.Insert("Buyer_Text_" index,BuyerText%index%Handler)
				TradesGUI_Controls.Insert("Item_Text_" index,ItemText%index%Handler)
				TradesGUI_Controls.Insert("Price_Text_" index,PriceText%index%Handler)
				TradesGUI_Controls.Insert("Location_Text_" index,LocationText%index%Handler)
				TradesGUI_Controls.Insert("Other_Text_" index,OtherText%index%Handler)
			}

			Gui, Font, cFFFFFF
			Gui, Add, Text, x75 y60 w255 h15 vBuyerSlot%index% hwndBuyerSlot%index%Handler +BackgroundTrans +0x0100,% ""
			Gui, Add, Text, xp yp+15 w310 h15 vItemSlot%index% hwndItemSlot%index%Handler +BackgroundTrans +0x0100,% ""
			Gui, Add, Text, xp yp+15 w310 h15 vPriceSlot%index% hwndPriceSlot%index%Handler +BackgroundTrans +0x0100,% ""
			if ( infosArray.PRICES[index] = "UNPRICED ITEM")
				GuiControl, Trades: +cRed,% PriceSlot%index%Handler
			Gui, Add, Text, xp yp+15 w310 h15 vLocationSlot%index% hwndLocationSlot%index%Handler +BackgroundTrans +0x0100,% ""
			Gui, Add, Text, xp yp+15 w310 h15 vOtherSlot%index% hwndOtherSlot%index%Handler +BackgroundTrans +0x100,% ""
			Gui, Add, Text, x340 y55 w30 h15 vTimeSlot%index% hwndTimeSlot%index%Handler +BackgroundTrans,% ""
			Gui, Add, Text, w0 h0 x0 y0 vPIDSlot%index% hwndPIDSlot%index%Handler,

			GuiControl, Hide,BuyerSlot%index%
			GuiControl, Hide,ItemSlot%index%
			GuiControl, Hide,PriceSlot%index%
			GuiControl, Hide,LocationSlot%index%
			GuiControl, Hide,OtherSlot%index%
			GuiControl, Hide,TimeSlot%index%

			TradesGUI_Controls.Insert("Buyer_Slot_" index,BuyerSlot%index%Handler)
			TradesGUI_Controls.Insert("Item_Slot_" index,ItemSlot%index%Handler)
			TradesGUI_Controls.Insert("Price_Slot_" index,PriceSlot%index%Handler)
			TradesGUI_Controls.Insert("Location_Slot_" index,LocationSlot%index%Handler)
			TradesGUI_Controls.Insert("Other_Slot_" index,OtherSlot%index%Handler)
			TradesGUI_Controls.Insert("Time_Slot_" index,TimeSlot%index%Handler)
			TradesGUI_Controls.Insert("PID_Slot_" index,PIDSlot%index%Handler)
		}
		Gui, Add, Picture,x360 y30 w20 h20 gGui_Trades_Arrow_Left vGoLeft hwndGoLeftHandler +BackgroundTrans,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ArrowLeft.png"
		Gui, Add, Picture,x380 y30 w20 h20 gGui_Trades_Arrow_Right vGoRight hwndGoRightHandler +BackgroundTrans,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ArrowRight.png"
		Gui, Add, Picture,x370 y55 w25 h25 vdelBtn1 %themeState% gGui_Trades_RemoveItem hwndCloseBtn1Handler +BackgroundTrans,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\Close.png"

		TradesGUI_Controls.Insert("Arrow_Left", GoLeftHandler)
		TradesGUI_Controls.Insert("Arrow_Right", GoRightHandler)
		TradesGUI_Controls.Insert("Button_Close", CloseBtn1Handler)
		Loop 9 {
			btnW := (GlobalValues["Button" A_Index "_SIZE"]="Small")?(124):(GlobalValues["Button" A_Index "_SIZE"]="Medium")?(254):(GlobalValues["Button" A_Index "_SIZE"]="Large")?(374):("ERROR")
			btnX := (GlobalValues["Button" A_Index "_H"]="Left")?(9):(GlobalValues["Button" A_Index "_H"]="Center")?(139):(GlobalValues["Button" A_Index "_H"]="Right")?(269):("ERROR")
			btnY := (GlobalValues["Button" A_Index "_V"]="Top")?(140):(GlobalValues["Button" A_Index "_V"]="Middle")?(180):(GlobalValues["Button" A_Index "_V"]="Bottom")?(220):("ERROR")
			btnName := GlobalValues["Button" A_Index "_Label"]
			btnSub := RegExReplace(GlobalValues["Button" A_Index "_Action"], "[ _+()]", "_")
			btnSub := RegExReplace(btnSub, "___", "_")
			btnSub := RegExReplace(btnSub, "__", "_")
			btnSub := RegExReplace(btnSub, "_", "", ,1,-1)
			if ( btnW != "ERROR" && btnX != "ERROR" && btnY != "ERROR" && btnSub != "" && btnSub != "ERROR" ) {
				Gui, Add, Picture,x%btnX% y%btnY% w%btnW% h35 vCustomBtn%A_Index% gGui_Trades_%btnSub% hwndCustomBtn%A_Index%Handler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ButtonBackground.png"
				Gui, Add, Picture,% "x" btnX " y" btnY " w8 h35 +BackgroundTrans vCustomBtn" A_Index "OrnamentLeft hwndCustomBtn" A_Index "OrnamentLeftHandler",% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ButtonOrnamentLeft.png"
				Gui, Add, Picture,% "x" btnX+btnW-8 " y" btnY " w8 h35 +BackgroundTrans vCustomBtn" A_Index "OrnamentRight hwndCustomBtn" A_Index "OrnamentRightHandler",% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ButtonOrnamentRight.png"
				Gui, Font, cC18F55
				Gui, Add, Text,x%btnX% yp+10 w%btnW% Center vCustomBtnTXT%A_Index% hwndCustomBtnTXT%A_Index%Handler +BackgroundTrans,% btnName

				TradesGUI_Controls.Insert("Button_Custom_" A_Index, CustomBtn%A_Index%Handler)
				TradesGUI_Controls.Insert("Button_Custom_" A_Index "_OrnamentLeft", CustomBtn%A_Index%OrnamentLeftHandler)
				TradesGUI_Controls.Insert("Button_Custom_" A_Index "_OrnamentRight", CustomBtn%A_Index%OrnamentRightHandler)
				TradesGUI_Controls.Insert("Button_Custom_" A_Index "_Text", CustomBtnTXT%A_Index%Handler)
			}
		}
	}

	if ( errorMsg = "UPDATE" || errorMsg = "CREATE" || errorMsg = "EXE_NOT_FOUND" ) {
		tabsCount := infosArray.BUYERS.Length()
		allTabs := ""
		for key, element in infosArray.BUYERS {
			allTabs .= "|" key
			GuiControl, Trades:,% buyerSlot%key%Handler,% infosArray.BUYERS[key]
			GuiControl, Trades:,% itemSlot%key%Handler,% infosArray.ITEMS[key]
			GuiControl, Trades:,% priceSlot%key%Handler,% infosArray.PRICES[key]
			GuiControl, Trades:,% locationSlot%key%Handler,% infosArray.LOCATIONS[key]
			GuiControl, Trades:,% PIDSlot%key%Handler,% infosArray.GAMEPID[key]
			GuiControl, Trades:,% TimeSlot%key%Handler,% infosArray.TIME[key]
			GuiControl, Trades:,% OtherSlot%key%Handler,% infosArray.OTHER[key]
			if ( key <= maxTabsRow ) {
				GuiControl, Trades:Show,% TabIMG%key%Handler
				GuiControl, Trades:Show,% TabTXT%key%Handler
			}
		}

		; Fix to remove the deleted tab image
		tabsCount++
		GuiControl, Trades:Hide,% TabIMG%tabsCount%Handler
		GuiControl, Trades:Hide,% TabTXT%tabsCount%Handler
		tabsCount--

		if ( tabsCount = 0 || tabsCount = "" ) {
			tabsCount := 0
			allTabs := "|Monitoring"
			showState := "Hide"
			txtColor := "C18F55"
			if ( errorMsg = "EXE_NOT_FOUND" )
				GuiControl, Trades:,% BuyerText1Handler,% "`n`nProcess not found, retrying in 10 seconds...`n`nRight click on the tray icon,`nthen [Settings] to set your preferences."
			else
				GuiControl, Trades:,% BuyerText1Handler,% "`n`nNo trade on queue!`n`nRight click on the tray icon,`nthen [Settings] to set your preferences."
			GuiControl, Trades:Move,% BuyerText1Handler,x0 w%guiWidth% h%guiHeight%
			GuiControl, Trades:+0x1,% BuyerText1Handler,
			GlobalValues.Insert("Trades_GUI_Current_State", "Inactive")
			if ( GlobalValues["Trades_Click_Through"] )
				Gui, Trades: +E0x20
			WinSet, Transparent,% GlobalValues["Transparency"],% "ahk_id " guiTradesHandler
		}
		else {
			showState := "Show"
			txtColor := "C18F55"
			GuiControl, Trades:Move,% BuyerText1Handler,x9 w60 h15
			GuiControl, Trades:,% BuyerText1Handler,Buyer:
			GuiControl, Trades:-0x1,% BuyerText1Handler,
			GlobalValues.Insert("Trades_GUI_Current_State", "Active")
			Gui, Trades: -E0x20
			WinSet, Transparent,% GlobalValues["Transparency_Active"],% "ahk_id " guiTradesHandler
		}
		Gui, Trades:Font, c%txtColor%
		GuiControl, Trades:Font,% guiTradesTitleHandler
		GuiControl, Trades:Text,% guiTradesTitleHandler,% programName " - Queued Trades: " tabsCount ; Update the GUI Title
;		Hide or show the controls
		Loop 9 {
			GuiControl, Trades:%showState%,% CustomBtn%A_Index%Handler
			GuiControl, Trades:%showState%,% CustomBtnTXT%A_Index%Handler
			GuiControl, Trades:%showState%,% CustomBtn%A_Index%OrnamentLeftHandler
			GuiControl, Trades:%showState%,% CustomBtn%A_Index%OrnamentRightHandler
		}

		GuiControl, Trades:%showState%,% ItemText1Handler
		GuiControl, Trades:%showState%,% PriceText1Handler
		GuiControl, Trades:%showState%,% LocationText1Handler
		GuiControl, Trades:%showState%,% CloseBtn1Handler
		GuiControl, Trades:%showState%,% OtherText1Handler

		Gosub Gui_Trades_Tabs_Handler

		if (tabsCount >= tabsMax - 1 && tabsMax != 255) {
			tabsMax := (tabsMax=defaultMaxTabs)?(25):(tabsMax=25)?(50):(tabsMax=50)?(100):(tabsMax=100)?(255):(50)
			IniWrite,% tabsMax,% iniFilePath,PROGRAM,Rendered_Tabs
			tradesArray := Gui_Trades_Manage_Trades("GET_ALL")
			lastActiveTab := currentActiveTab+1
			Gui_Trades(tradesArray,"CREATE")
			Loop { ; Go back to the previously selected tab
				currentActiveTab := (GlobalValues["Trades_Select_Last_Tab"] = 1)?(tabsCount):(currentActiveTab) ; Set the active tab to the latest available tab if Select_Last_Tab is enabled
				GuiControlGet, lastTab, Trades:,% TradesGUI_Controls["Tab_TXT_" maxTabsRow]
				GuiControlGet, firstTab, Trades:,% TradesGUI_Controls["Tab_TXT_1"]
				if currentActiveTab between %firstTab% and %lastTab%
					Break
				GoSub Gui_Trades_Arrow_Right
			}
			GoSub Gui_Trades_Tabs_Handler
			lastActiveTab := (GlobalValues["Trades_Select_Last_Tab"] = 1)?(currentActiveTab):(lastActiveTab) ; Avoid controls content overlap
			Return
		}
		if (tabsCount=0 && tabsMax>defaultMaxTabs) {
			tabsMax := defaultMaxTabs
			IniWrite,% tabsMax,% iniFilePath,PROGRAM,Rendered_Tabs
			tradesArray := Gui_Trades_Manage_Trades("GET_ALL")
			Gui_Trades(tradesArray,"CREATE")
			Gui_Trades(,"UPDATE")
			currentActiveTab := 0, lastActiveTab := 0 ; __TO_BE_FIXED__ Temporary workaround to avoid new tabs from being blank
			Return
		}
	}

	WinSet, Redraw, ,% "ahk_id " guiTradesHandler ; Make sure to update the GUI appearance (the custom "title bar" would sometimes disappear)
	IniWrite,% tabsCount,% iniFilePath,PROGRAM,Tabs_Number

	if ( errorMsg = "CREATE" ) {
		showWidth := guiWidth
		showHeight := (GlobalValues["Trades_GUI_Minimized"]=1)?(guiHeightMin):(guiHeight)
		IniRead, showX,% iniFilePath,PROGRAM,X_POS
		IniRead, showY,% iniFilePath,PROGRAM,Y_POS
		showXDefault := A_ScreenWidth-(showWidth), showYDefault := 0
		showX := (showX="ERROR"||showX=""||(!showX && showX != 0))?(showXDefault):(showX)
		showY := (showY="ERROR"||showY=""||(!showY && showY != 0))?(showYDefault):(showY)
		Gui, Trades:Show,% "NoActivate w" showWidth " h" showHeight " x" showX " y" showY,% programName " - Queued Trades"
		OnMessage(0x200, "WM_MOUSEMOVE")
		OnMessage(0x201, "WM_LBUTTONDOWN")
		OnMessage(0x203, "WM_LBUTTONDBLCLK")
		OnMessage(0x2A3, "WM_MOUSELEAVE")

		dpiFactor := GlobalValues["Screen_DPI"], showX := guiWidth-49
	}
	else {
		if ( GlobalValues["Trades_Select_Last_Tab"] = 1 ) && ( tabsCount > previousTabsCount ) {
			if ( currentActiveTab != tabsCount && tabsCount > 0) {
				lastActiveTab := currentActiveTab, currentActiveTab := tabsCount
				GoSub Gui_Trades_Tabs_Handler
				GoSub Gui_Trades_Arrow_Right
				GoSub Gui_Trades_Arrow_Right ; Make sure the tab bar is on far right
			}
		}

		if ( GlobalValues["Trades_Auto_Minimize"] && tabsCount = 0 && tradesGuiHeight != guiHeightMin && errorMsg != "EXE_NOT_FOUND" ) {
			GlobalValues.Insert("Trades_GUI_Minimized", 0)
			GoSub, Gui_Trades_Minimize
		}

		if ( GlobalValues["Trades_Auto_UnMinimize"] && tabsCount > 0 && tradesGuiHeight != guiHeight) {
			GlobalValues.Insert("Trades_GUI_Minimized", 1)
			GoSub, Gui_Trades_Minimize
		}
	}

	if ( errorMsg = "EXE_NOT_FOUND" ) {
		countdown := 10
		Loop 11 {
			GuiControl, Trades:,% BuyerText1Handler,% "`n`nProcess not found, retrying in " countdown " seconds...`n`nRight click on the tray icon,`nthen [Settings] to set your preferences."
			countdown--
			sleep 1000
		}
		Monitor_Game_Logs()
	}
	if ( GlobalValues["Trades_GUI_Mode"] = "Overlay") {
		try	Gui_Trades_Set_Position()
	}

	previousTabsCount := tabsCount

	sleep 10
	return

	Gui_Trades_Arrow_Left:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		GuiControlGet, lastTab, Trades:,% TradesGUI_Controls["Tab_TXT_" maxTabsRow]
		GuiControlGet, firstTab, Trades:,% TradesGUI_Controls["Tab_TXT_1"]

		if ( firstTab > 1 ) {
			index := maxTabsRow
			Loop %maxTabsRow% {
				index := A_Index
				txtContent := firstTab+index-2
				GuiControl,Trades:,% TradesGUI_Controls["Tab_TXT_" index],% txtContent
			}
			inactiveTabID := lastActiveTab-firstTab+1
			activeTabID := currentActiveTab-firstTab+2
			if (inactiveTabID > 0) ; Prevents from using a negative TabID due to the users selecting a tab, then moving with the arrows and selecting a new tab while the old one is out of range
				GuiControl, Trades:,% TradesGUI_Controls["Tab_IMG_" inactiveTabID],% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabInactive.png"
			if (activeTabID > 0) ; Prevents from using a negative TabID due to the users selecting a tab, then moving with the arrows and selecting a new tab while the old one is out of range
				GuiControl, Trades:,% TradesGUI_Controls["Tab_IMG_" activeTabID],% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabActive.png"
		}
		Return

	Gui_Trades_Arrow_Right:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		GuiControlGet, lastTab, Trades:,% TradesGUI_Controls["Tab_TXT_" maxTabsRow]
		GuiControlGet, firstTab, Trades:,% TradesGUI_Controls["Tab_TXT_1"]

		if ( tabsCount > lastTab ) {
			index := maxTabsRow
			Loop %maxTabsRow% {
				index := A_Index
				txtContent := firstTab+index
				GuiControl,Trades:,% TradesGUI_Controls["Tab_TXT_" index],% txtContent
			}
			inactiveTabID := lastActiveTab-firstTab+1
			activeTabID := currentActiveTab-firstTab
			if (inactiveTabID > 0) ; Prevents from using a negative TabID due to the users selecting a tab, then moving with the arrows and selecting a new tab while the old one is out of range
				GuiControl, Trades:,% TradesGUI_Controls["Tab_IMG_" inactiveTabID],% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabInactive.png"
			if (activeTabID > 0) ; Prevents from using a negative TabID due to the users selecting a tab, then moving with the arrows and selecting a new tab while the old one is out of range
				GuiControl, Trades:,% TradesGUI_Controls["Tab_IMG_" activeTabID],% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabActive.png"
		}
	Return

	Gui_Trades_Tabs_Handler:
		GuiControlGet, lastTab, Trades:,% TradesGUI_Controls["Tab_TXT_" maxTabsRow]
		GuiControlGet, firstTab, Trades:,% TradesGUI_Controls["Tab_TXT_1"]

		RegExMatch(A_GuiControl, "\D+", btnType)
		RegExMatch(A_GuiControl, "\d+", btnID)

		btnType := (btnType = "CustomBtn")?("delBtn"):(btnType) ; Label is accessed from a Custom button, act like the DelBtn

		if ( btnType = "TabIMG" ) { ; User switched tab
			GuiControlGet, tabID, Trades:,% TradesGUI_Controls["Tab_TXT_" btnID]
			currentActiveTab := tabID
			tabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab) ; [0] buyerName - [1] itemName - [2] itemPrice
			if ( GlobalValues["Clip_On_Tab_Switch"] = 1 )
				Clipboard := tabInfos.Item
		}

		if ( btnType != "delBtn" && A_GuiControl ) {
			GuiControlGet, tabID, Trades:,% TradesGUI_Controls["Tab_TXT_" btnID]
			currentActiveTab := tabID
		}

		if ( !currentActiveTab ) {
			currentActiveTab := 1
		}

		if ( tabsCount < currentActiveTab ) && ( tabsCount > 0 ) {
;			User closed the highest available tab
;			Add one to the lastActiveTab prevent from having new trades text from overlapping the current tab
			currentActiveTab--
			lastActiveTab := currentActiveTab+1
			wasReduced := 1
		}

	   	if ( lastActiveTab != currentActiveTab ) { ; btnType != "delBtn": Prevents from resetting to the first available tab when closing a tab
			showState := "Hide"
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Buyer_Slot_" lastActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Item_Slot_" lastActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Price_Slot_" lastActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Location_Slot_" lastActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Time_Slot_" lastActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Other_Slot_" lastActiveTab]

			showState := "Show"
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Buyer_Slot_" currentActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Item_Slot_" currentActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Price_Slot_" currentActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Location_Slot_" currentActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Time_Slot_" currentActiveTab]
			GuiControl, Trades:%showState%,% TradesGUI_Controls["Other_Slot_" currentActiveTab]

			activeTabID := (wasReduced=1 && currentActiveTab > maxTabsRow)?(currentActiveTab-firstTab+2):(currentActiveTab-firstTab+1)
			inactiveTabID := (wasReduced=1)?(activeTabID+1):(lastActiveTab-firstTab+1)

			if (inactiveTabID > 0) ; Prevents from using a negative TabID due to the users selecting a tab, then moving with the arrows and selecting a new tab while the old one is out of range 
				GuiControl, Trades:,% TradesGUI_Controls["Tab_IMG_" inactiveTabID],% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabInactive.png"
			GuiControl, Trades:,% TradesGUI_Controls["Tab_IMG_" activeTabID],% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabActive.png"
		}

		if ( btnType != "delBtn" || wasReduced = 1 ) {
			lastActiveTab := currentActiveTab
			wasReduced := 0
		}

		if ( (lastTab > tabsCount && tabsCount > maxTabsRow) || (lastTab = maxTabsRow+1 && firstTab = 2 && tabsCount = maxTabsRow) ) {
			GoSub Gui_Trades_Arrow_Right
			GoSub Gui_Trades_Arrow_Left
		}

		GlobalValues.Insert("Trades_GUI_Current_Active_Tab", currentActiveTab)
	Return

	Gui_Trades_Minimize:
		GlobalValues.Insert("Trades_GUI_Minimized", !GlobalValues["Trades_GUI_Minimized"])
		if ( GlobalValues["Trades_GUI_Minimized"] ) {
			tHeight := guiHeight
			Loop {
				if ( tHeight = guiHeightMin )
					Break
				tHeight := (guiHeightMin<tHeight)?(tHeight-30):(guiHeightMin)
				tHeight := (tHeight-30<guiHeightMin)?(guiHeightMin):(tHeight)
				Gui, Trades:Show, NoActivate h%tHeight%
				sleep 1
			}
		}
		else  {
			tHeight := guiHeightMin
			Loop {
				if ( tHeight = guiHeight )
					Break
				tHeight := (guiHeight>tHeight)?(tHeight+30):(guiHeight)
				tHeight := (tHeight+30>guiHeight)?(guiHeight):(tHeight)
				Gui, Trades:Show, NoActivate h%tHeight%
				sleep 1
			}
		}
		sleep 10
	Return

	Gui_Trades_Move:
		if ( GlobalValues["Trades_GUI_Mode"] = "Window" ) {
			PostMessage, 0xA1, 2,,,% "ahk_id " guiTradesHandler
		}
	Return 

	Gui_Trades_Close:
	Return

	Gui_Trades_Escape:
	Return

	Gui_Trades_Clipboard_Item:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		tabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab) ; [0] buyerName - [1] itemName - [2] itemPrice
		Clipboard := tabInfos.Item
	Return

	Gui_Trades_Message_Basic:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		RegExMatch(A_GuiControl, "\d+", btnID)
		tabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab)
		Send_InGame_Message(GlobalValues["Button" btnID "_Message"], tabInfos)
	Return

	Gui_Trades_Message_Basic_Close_Tab:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		RegExMatch(A_GuiControl, "\d+", btnID)
		tabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab)
		errorLvl := Send_InGame_Message(GlobalValues["Button" btnID "_Message"], tabInfos)
		if !(errorLvl) {
			if ( GlobalValues["Support_Text_Toggle"] = 1 )
				Send_InGame_Message("@%buyerName% - - - POE Trades Helper: Keep track of your trades! // Look it up! (not a bot!)", tabInfos)
			Gosub, Gui_Trades_RemoveItem
		}
	Return

	Gui_Trades_Message_Advanced:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		RegExMatch(A_GuiControl, "\d+", btnID)
		tabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab)
		Send_InGame_Message(GlobalValues["Button" btnID "_Message"], tabInfos,0,1)
	Return

	Gui_Trades_Message_Advanced_Close_Tab:
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		RegExMatch(A_GuiControl, "\d+", btnID)
		tabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab)
		errorLvl := Send_InGame_Message(GlobalValues["Button" btnID "_Message"], tabInfos,0,1)
		if !(errorLvl) {
			if ( GlobalValues["Support_Text_Toggle"] = 1 )
				Send_InGame_Message("@%buyerName% - - - POE Trades Helper: Keep track of your trades! // Look it up! (not a bot!)", tabInfos)
			Gosub, Gui_Trades_RemoveItem
		}
	Return
	
	Gui_Trades_RemoveItem:
;		Copy the first item or the second item if the first tab is being closed
		if ( GlobalValues["Trades_GUI_Button_Cancel"] ) {
			GlobalValues.Insert("Trades_GUI_Button_Cancel", 0)
			Return
		}

		GuiControlGet, lastTab, Trades:,% TradesGUI_Controls["Tab_TXT_" maxTabsRow]
		GuiControlGet, firstTab, Trades:,% TradesGUI_Controls["Tab_TXT_1"]
		if ( GlobalValues["Clip_On_Tab_Switch"] = 1 ) {
			tabInfos := Gui_Trades_Get_Trades_Infos(btnID) ; [0] buyerName - [1] itemName - [2] itemPrice
			Clipboard := tabInfos.Item
		}

		tabToDel := currentActiveTab
;		Check for other trades with different buyer but same item/price/location
		duplicatesID := Gui_Trades_Check_Duplicate(tabToDel)
		if ( duplicatesID.MaxIndex() = 0 || duplicatesID.MaxIndex() ) {
			duplicatesInfos := Gui_Trades_Get_Trades_Infos(duplicatesID[0])
			MsgBox, 4100,% programName,% "Multiple tabs share the same infos:"
			. "`nItem: " duplicatesInfos.Item
			. "`nPrice: " duplicatesInfos.Price
			. "`nLocation: " duplicatesInfos.Location
			. "`n`nWould you like to close them as well?"
			IfMsgBox, Yes
			{
				for key, element in duplicatesID {
					messagesArray := Gui_Trades_Manage_Trades("REMOVE_CURRENT", ,element-key)
					if ( tabToDel >= element-key ) ; our tabToDel moved to the left due to a lesser tab being deleted
						tabToDel--
					Gui_Trades(messagesArray, "UPDATE")
					Gosub, Gui_Trades_Tabs_Handler
				}		
			}
		}


;		Remove the current tab
		messagesArray := Gui_Trades_Manage_Trades("REMOVE_CURRENT", ,tabToDel)
		Gui_Trades(messagesArray, "UPDATE")
		Gosub, Gui_Trades_Tabs_Handler
	return

	Gui_Trades_Size:
;		Declare the GUI width and height
		tradesGuiWidth := A_GuiWidth
		tradesGuiHeight := A_GuiHeight
	return
}

Gui_Trades_Check_Duplicate(currentActiveTab) {
/*			Returns an array (Index:0) containing the tab IDs of all tabs containing the same infos (with different buyer)
*/
	duplicates := Object()
	messagesArray := Gui_Trades_Manage_Trades("GET_ALL")
	maxIndex := messagesArray.BUYERS.MaxIndex()
	currentTabInfos := Gui_Trades_Get_Trades_Infos(currentActiveTab)
	arrayKey := 0
	Loop %maxIndex% {
		if (A_Index != currentActiveTab) {
			otherTabInfos := Gui_Trades_Get_Trades_Infos(A_Index)
			if (otherTabInfos.Item = currentTabInfos.Item && otherTabInfos.Price = currentTabInfos.Price && otherTabInfos.Location = currentTabInfos.Location) {
				duplicates.Insert(arrayKey, A_Index)
				arrayKey++
			}
		}
	}
	return duplicates
}


Gui_Trades_Get_Tab_Height() {
/*			Returns a number based on the lowest custom button to determine the GUI height
*/
	global GlobalValues

	tabHeight := 145
	Loop 9 {
		index := A_Index
		if ( GlobalValues["Button" index "_SIZE"] != "Disabled" ) {
			if ( GlobalValues["Button" index "_V"] = "Middle" && tabHeight = 145 ) {
				tabHeight := 185
			}
			if ( GlobalValues["Button" index "_V"] = "Bottom" && ( tabHeight = 145 || tabHeight = 185 ) ) {
				tabHeight := 225
			}
		}
	}
	return tabHeight
}

GUI_Trades_Mode:
	Gui_Trades_Mode_Func(A_ThisMenuItem)
Return

Gui_Trades_Mode_Func(thisMenuItem) {
/*			Switch between Overlay and Window mode
*/
	global GlobalValues, ProgramValues

	iniFilePath := ProgramValues["Ini_File"]

	if ( thisMenuItem = "Mode: Overlay") {
		Menu, Tray, UnCheck,% "Mode: Window"
		Menu, Tray, Check,% "Mode: Overlay"
		GlobalValues.Insert("Trades_GUI_Mode", "Overlay")
	}
	else if ( thisMenuItem = "Mode: Window") {
		Menu, Tray, UnCheck,% "Mode: Overlay"
		Menu, Tray, Check,% "Mode: Window"
		GlobalValues.Insert("Trades_GUI_Mode", "Window")
	}
	IniWrite,% GlobalValues["Trades_GUI_Mode"],% iniFilePath,SETTINGS,Trades_GUI_Mode
	messagesArray := Gui_Trades_Manage_Trades("GET_ALL")
	Gui_Trades(messagesArray)
}

Gui_Trades_Get_Tab_ID(controlName=""){
/*			__TO_BE_FIXED__
 *			Function deprecated
*/
	GuiControlGet, tabID, Trades:, Tab
	return tabID
}

Gui_Trades_Get_Trades_Infos(tabID){
/*			Returns the specified tab informations
*/
	global TradesGUI_Controls

	GuiControlGet, tabBuyer, Trades:,% TradesGUI_Controls["Buyer_Slot_" tabID]
	tabBuyer := Gui_Trades_RemoveGuildPrefix(tabBuyer) ; Removing guild prefix so we can use the actual player name
	GuiControlGet, tabItem, Trades:,% TradesGUI_Controls["Item_Slot_" tabID]
	GuiControlGet, tabPrice, Trades:,% TradesGUI_Controls["Price_Slot_" tabID]
	GuiControlGet, tabLocation,Trades:,% TradesGUI_Controls["Location_Slot_" tabID]
	GuiControlGet, tabOther,Trades:,% TradesGUI_Controls["Other_Slot_" tabID]
	GuiControlGet, tabPID, Trades:,% TradesGUI_Controls["PID_Slot_" tabID]
	GuiControlGet, tabTime, Trades:,% TradesGUI_Controls["Time_Slot_" tabID]

	TabInfos := {}
	TabInfos.Buyer := tabBuyer
	TabInfos.Item := tabItem
	TabInfos.Price := tabPrice
	TabInfos.Location := tabLocation
	TabInfos.Other := tabOther
	TabInfos.PID := tabPID
	TabInfos.Time := tabTime
	TabInfos.TabID := tabID
	return tabInfos
}

Gui_Trades_Set_Trades_Infos(setInfos){
/*			Overrides the specified tab content
*/
	global TradesGUI_Controls

	newPID := setInfos.NewPID, oldPID := setInfos.OldPID, other := setInfos.Other, tabID := setInfos.TabID

	if ( newPID ) {
		; Replace the PID for all trades matching the same PID
		allTrades := Gui_Trades_Manage_Trades("GET_ALL")
		tradeInfos := Gui_Trades_Get_Trades_Infos(tabID)
		for key, element in allTrades.BUYERS {
			if ( tradeInfos.PID = oldPID ) {
				GuiControl,Trades:,% TradesGUI_Controls["PID_Slot_" key],% newPID
			}
		}
	}

	else if ( other ) {
		GuiControl,Trades:,% TradesGUI_Controls["Other_Slot_" tabID],% other
	}
}

Gui_Trades_Manage_Trades(mode, newItemInfos="", activeTabID=""){
/*			GET_ALL retrieves all the currently existing tabs infos
 *			ADD_NEW add the provided infos to a new tab
 *			REMOVE_CURRENT deletes the currently active tab infos
*/
	global TradesGUI_Controls

	returnArray := Object()
	returnArray.COUNT := Object()
	returnArray.BUYERS := Object()
	returnArray.ITEMS := Object()
	returnArray.PRICES := Object()
	returnArray.LOCATIONS := Object()
	returnArray.GAMEPID := Object()
	returnArray.TIME := Object()
	returnArray.OTHER := Object()
	btnID := activeTabID

	if ( mode = "GET_ALL" || mode = "ADD_NEW") {
	;	___BUYERS___	
		Loop {
			bcount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Buyer_Slot_" A_Index]
			if ( content ) {
				returnArray.BUYERS.Insert(A_Index, content)
			}
			else break
		}
		
	;	___ITEMS___
		Loop {
			icount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Item_Slot_" A_Index]
			if ( content ) {
				returnArray.ITEMS.Insert(A_Index, content)
			}
			else break
		}
		
	;	___PRICES___
		Loop {
			pcount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Price_Slot_" A_Index]
			if ( content ) {
				returnArray.PRICES.Insert(A_Index, content)
			}
			else break
		}
		
	;	___LOCATIONS___
		Loop {
			lcount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Location_Slot_" A_Index]
			if ( content ) {
				returnArray.LOCATIONS.Insert(A_Index, content)
			}
			else break
		}

	;	___GAMEPID___
		Loop {
			PIDCount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["PID_Slot_" A_Index]
			if ( content ) {
				returnArray.GAMEPID.Insert(A_Index, content)
			}
			else break
		}

	;	___TIME___
		Loop {
			timeCount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Time_Slot_" A_Index]
			if ( content ) {
				returnArray.TIME.Insert(A_Index, content)
			}
			else break
		}
	;	___OTHER___
		Loop {
			otherCount := A_Index
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Other_Slot_" A_Index]
			if ( content ) {
				returnArray.OTHER.Insert(A_Index, content)
			}
			else break
		}
	}

	if ( mode = "ADD_NEW") {
		name := newItemInfos[0], item := newItemInfos[1], price := newItemInfos[2], location := newItemInfos[3], gamePID := newItemInfos[4], time := newItemInfos[5], other := newItemInfos[6]
		returnArray.COUNT.Insert(0, bCount)
		returnArray.BUYERS.Insert(bCount, name)
		returnArray.ITEMS.Insert(iCount, item)
		returnArray.PRICES.Insert(pCount, price)
		returnArray.LOCATIONS.Insert(lCount, location)
		returnArray.GAMEPID.Insert(PIDCount, gamePID)
		returnArray.TIME.Insert(timeCount, time)
		returnArray.OTHER.Insert(timeCount, other)
	}

	if ( mode = "REMOVE_CURRENT") {
	;	___BUYERS___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Buyer_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.BUYERS.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["Buyer_Slot_" counter],% "" ; Empties the slot content

	;	___ITEMS___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Item_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.ITEMS.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["Item_Slot_" counter],% ""
		
	;	___PRICES___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Price_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.PRICES.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["Price_Slot_" counter],% ""
		
	;	___LOCATIONS___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Location_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.LOCATIONS.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["Location_Slot_" counter],% ""

;	___GAMEPID___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["PID_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.GAMEPID.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["PID_Slot_" counter],% ""

;	___TIME___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Time_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.TIME.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["Time_Slot_" counter],% ""

;	___OTHER___
		Loop {
			if ( A_Index < btnID )
				counter := A_Index
			else if ( A_Index >= btnID )
				counter := A_Index+1
			GuiControlGet, content, Trades:,% TradesGUI_Controls["Other_Slot_" counter]
			if ( content ) {
				index := A_Index
				returnArray.Other.Insert(index, content)
			}
			else break
		}
		counter--
		GuiControl,Trades:,% TradesGUI_Controls["Other_Slot_" counter],% ""
	}

	return returnArray
}

Gui_Trades_RemoveGuildPrefix(name) {
/*			Remvove the guild prefix from the name, is there is one
*/
	AutoTrim, On
	RegExMatch(name, "<.*>(.*)", namePat)
	if ( namePat1 )
		name := namePat1
	name = %name% ; Removes whitespaces
	return name
}

Gui_Trades_Set_Position(xpos="UNSPECIFIED", ypos="UNSPECIFIED"){
/*			Update the Trades GUI position
 *			__TO_BE_FIXED__ : VALUE_Trades_GUI_Current_State is not used anymore?
*/
	static
	global GlobalValues
	global tradesGuiWidth, tradesGuiHeight

	dpiFactor := GlobalValues["Screen_DPI"]

	if ( WinExist("ahk_id " GlobalValues["Dock_Window"] ) ) {
		WinGetPos, winX, winY, winWidth, winHeight,% "ahk_id " GlobalValues["Dock_Window"]
		xpos := ( (winX+winWidth)-tradesGuiWidth * dpiFactor ), ypos := winY
		WinGet, isMinMax, MinMax,% "ahk_id " GlobalValues["Dock_Window"] ; -1: Min | 1: Max | 0: Neither
		xpos := (isMinMax=1)?(xpos-8):(isMinMax=-1)?(((A_ScreenWidth/dpiFactor) - tradesGuiWidth ) * dpiFactor):(xpos)
		ypos := (isMinMax=1)?(ypos+8):(isMinMax=-1)?(0):(ypos)
		if xpos is not number
			xpos := ( ( (A_ScreenWidth/dpiFactor) - tradesGuiWidth ) * dpiFactor )
		if ypos is not number
			ypos := 0
		Gui, Trades:Show, % "x" xpos " y" ypos " NoActivate"
	}
	else {
		xpos := ( ( (A_ScreenWidth/dpiFactor) - tradesGuiWidth ) * dpiFactor )
		Gui, Trades:Show, % "x" xpos " y0" " NoActivate"
	}

	GlobalValues.Insert("Trades_GUI_Last_State", GlobalValues["Trades_GUI_Current_State"]) ; backup of the old state, so we know when we switch from one to another
	Logs_Append(A_ThisFunc,, xpos, ypos)
}


;==================================================================================================================
;
;												SETTINGS GUI
;
;==================================================================================================================

Gui_Settings() {
	static
	global GlobalValues, ProgramValues
	global Hotkey1_KEYHandler, Hotkey2_KEYHandler, Hotkey3_KEYHandler, Hotkey4_KEYHandler, Hotkey5_KEYHandler, Hotkey6_KEYHandler

	programName := ProgramValues["Name"], iniFilePath := ProgramValues["Ini_File"], programSFXFolderPath := ProgramValues["SFX_Folder"]

	guiCreated := 0
	aeroStatus := Get_Aero_Status()
	themeState := (aeroStatus=1)?("+Theme -0x8000"):("-Theme +0x8000")
	
	Gui, Settings:Destroy
	Gui, Settings:New, +AlwaysOnTop +SysMenu -MinimizeBox -MaximizeBox +OwnDialogs +LabelGui_Settings_ hwndSettingsHandler,% programName " - Settings"
	Gui, Settings:Default

	Gui, Add, Tab3, vTab x10 y10 %themeState%,Settings|TradesGUI|Hotkeys
	Gui, Tab, 1
;	Settings Tab
;		Trades GUI
		Gui, Add, GroupBox, x20 y40 w200 h260,Trades GUI
		Gui, Add, Radio, xp+10 yp+20 vShowAlways hwndShowAlwaysHandler,Always show
		Gui, Add, Radio, xp yp+15 vShowInGame hwndShowInGameHandler,Only show while in game
;			Transparency
			Gui, Add, GroupBox, x25 yp+25 w190 h140,Transparency
			Gui, Add, Checkbox, xp+10 yp+25 hwndClickThroughHandler vClickThrough,Click-through while inactive
			Gui, Add, Text, xp yp+20,Inactive (no trade on queue)
			Gui, Add, Slider, xp+10 yp+15 hwndShowTransparencyHandler gGui_Settings_Transparency vShowTransparency AltSubmit ToolTip Range0-100
			Gui, Add, Text, xp-10 yp+30,Active (trades are on queue)
			Gui, Add, Slider, xp+10 yp+15 hwndShowTransparencyActiveHandler gGui_Settings_Transparency vShowTransparencyActive AltSubmit ToolTip Range30-100
;			Bottom
			Gui, Add, Checkbox, x25 yp+45 hwndSelectLastTabHandler vSelectLastTab,Focus newly created tabs
			Gui, Add, Checkbox, xp yp+15 hwndAutoMinimizeHandler vAutoMinimize,Minimize when inactive
			Gui, Add, Checkbox, xp yp+15 hwndAutoUnMinimizeHandler vAutoUnMinimize,Un-Minimize when active
;		Notifications
;			Trade Sound Group
			Gui, Add, GroupBox, x230 y40 w210 h120,Notifications
			Gui, Add, Checkbox, xp+10 yp+20 vNotifyTradeToggle hwndNotifyTradeToggleHandler,Trade
			Gui, Add, Edit, xp+65 yp-2 w70 h17 vNotifyTradeSound hwndNotifyTradeSoundHandler ReadOnly
			Gui, Add, Button, xp+80 yp-2 h20 vNotifyTradeBrowse gGui_Settings_Notifications_Browse,Browse
;			Whisper Sound Group
			Gui, Add, Checkbox, x240 y85 vNotifyWhisperToggle hwndNotifyWhisperToggleHandler,Whisper
			Gui, Add, Edit, xp+65 yp-2 w70 h17 vNotifyWhisperSound hwndNotifyWhisperSoundHandler ReadOnly
			Gui, Add, Button, xp+80 yp-2 h20 vNotifyWhisperBrowse gGui_Settings_Notifications_Browse,Browse
;			Whisper Tray Notification
			Gui, Add, Checkbox, x240 yp+24 vNotifyWhisperTray hwndNotifyWhisperTrayHandler,Tray notifications for whispers`n when POE is not active
			Gui, Add, Checkbox, x240 yp+29 vNotifyWhisperFlash hwndNotifyWhisperFlashHandler,Make the game's taskbar icon flash
;		Clipboard
		Gui, Add, GroupBox, x230 y160 w210 h60,Clipboard
		Gui, Add, Checkbox, xp+10 yp+20 hwndClipNewHandler vClipNew,Clipboard new items
		Gui, Add, Checkbox, xp yp+15 hwndClipTabHandler vClipTab,Clipboard item on tab switch
;		Support
		Gui, Add, GroupBox, x230 y220 w210 h80,Support
		Gui, Add, Checkbox, xp+80 yp+20 vMessageSupportToggle hwndMessageSupportToggleHandler gGui_Settings_Support_MsgBox
		Gui, Add, Text, gGUI_Settings_Tick_Case vMessageSupportToggleText xp-55 yp+13,% "Support the software by allowing`n   an additional message when`nclicking the Thanks/Sold buttons"
;		Apply Button
		Gui, Add, Button, x20 y310 w300 h30 gGui_Settings_Btn_Apply vApplyBtn,Apply Settings
		Gui, Add, Button, x320 y310 w120 h30 vWikiBtn gGui_Settings_Btn_WIKI,Visit the WIKI
	
;	TradesGUI tab
	Gui, Tab, 2
	DynamicGUIHandlersArray := Object()
	DynamicGUIHandlersArray.Btn := Object()
	DynamicGUIHandlersArray.HPOS := Object()
	DynamicGUIHandlersArray.HPOSText := Object()
	DynamicGUIHandlersArray.VPOS := Object()
	DynamicGUIHandlersArray.VPOSText := Object()
	DynamicGUIHandlersArray.SIZE := Object()
	DynamicGUIHandlersArray.SIZEText := Object()
	DynamicGUIHandlersArray.Label := Object()
	DynamicGUIHandlersArray.LabelText := Object()
	DynamicGUIHandlersArray.Action := Object()
	DynamicGUIHandlersArray.ActionText := Object()
	DynamicGUIHandlersArray.Msg := Object()
	Loop 9 {
		index := A_Index
		xpos := (index=1||index=4||index=7)?(60):(index=2||index=5||index=8)?(175):(index=3||index=6||index=9)?(290):("ERROR")
		ypos := (index=1||index=2||index=3)?(40):(index=4||index=5||index=6)?(75):(index=7||index=8||index=9)?(110):("ERROR")
		Gui, Add, Button, x%xpos% y%ypos% %themeState% w115 h35 vTradesBtn%index% hwndTradesBtn%index%Handler gGui_Settings_Custom_Label,% "Custom " index

		Gui, Add, Text, x60 y160 hwndTradesHPOS%index%TextHandler,H-POS:
		Gui, Add, DropDownList, w70 xp+50 yp-3 vTradesHPOS%index% hwndTradesHPOS%index%Handler,% "Left|Center|Right"
		Gui, Add, Text, xp+75 yp+3 hwndTradesVPOS%index%TextHandler,V-POS:
		Gui, Add, DropDownList, w70 xp+40 yp-3 vTradesVPOS%index% hwndTradesVPOS%index%Handler,% "Top|Middle|Bottom"
		Gui, Add, Text, xp+75 yp+3 hwndTradesSIZE%index%TextHandler,SIZE:
		Gui, Add, DropDownList, w70 xp+35 yp-3 vTradesSIZE%index% hwndTradesSIZE%index%Handler,% "Disabled|Small|Medium|Large"

		Gui, Add, Text, x60 yp+33 hwndTradesLabel%index%TextHandler,Label:
		Gui, Add, Edit, xp+50 yp-3 w295 vTradesLabel%index% hwndTradesLabel%index%Handler gGui_Settings_Custom_Label,
		Gui, Add, Text, x60 yp+33 hwndTradesAction%index%TextHandler,Action:
		Gui, Add, DropDownList, xp+50 yp-3 w295 vTradesAction%index% hwndTradesAction%index%Handler gGui_Settings_Custom_Label,% "Clipboard Item|Message (Basic)|Message (Basic) + Close Tab|Message (Advanced)|Message (Advanced) + Close Tab"
		Gui, Add, Edit, xp yp+25 w295 vTradesMsg%index% hwndTradesMsg%index%Handler,

		GuiControl,Settings:Hide,% TradesHPOS%index%Handler
		GuiControl,Settings:Hide,% TradesHPOS%index%TextHandler
		GuiControl,Settings:Hide,% TradesVPOS%index%Handler
		GuiControl,Settings:Hide,% TradesVPOS%index%TextHandler
		GuiControl,Settings:Hide,% TradesSIZE%index%Handler
		GuiControl,Settings:Hide,% TradesSIZE%index%TextHandler
		GuiControl,Settings:Hide,% TradesLabel%index%Handler
		GuiControl,Settings:Hide,% TradesLabel%index%TextHandler
		GuiControl,Settings:Hide,% TradesAction%index%Handler
		GuiControl,Settings:Hide,% TradesAction%index%TextHandler
		GuiControl,Settings:Hide,% TradesMsg%index%Handler

		DynamicGUIHandlersArray.Btn.Insert(index,TradesBtn%index%Handler)
		DynamicGUIHandlersArray.HPOS.Insert(index,TradesHPOS%index%Handler)
		DynamicGUIHandlersArray.HPOSText.Insert(index, TradesHPOS%index%TextHandler)
		DynamicGUIHandlersArray.VPOS.Insert(index, TradesVPOS%index%Handler)
		DynamicGUIHandlersArray.VPOSText.Insert(index, TradesVPOS%index%TextHandler)
		DynamicGUIHandlersArray.SIZE.Insert(index, TradesSIZE%index%Handler)
		DynamicGUIHandlersArray.SIZEText.Insert(index, TradesSIZE%index%TextHandler)
		DynamicGUIHandlersArray.Label.Insert(index,TradesLabel%index%Handler)
		DynamicGUIHandlersArray.LabelText.Insert(index,TradesLabel%index%TextHandler)
		DynamicGUIHandlersArray.Action.Insert(index,TradesAction%index%Handler)
		DynamicGUIHandlersArray.ActionText.Insert(index,TradesAction%index%TextHandler)		
		DynamicGUIHandlersArray.Msg.Insert(index,TradesMsg%index%Handler)		
	}
	Gui, Add, Button, x130 y280 w200 gGui_Settings_Trades_Preview,Preview
	;		Apply Button
	Gui, Add, Button, x20 y310 w300 h30 gGui_Settings_Btn_Apply vApplyBtn2,Apply Settings
	Gui, Add, Button, x320 y310 w120 h30 vWikiBtn2 gGui_Settings_Btn_WIKI,Visit the WIKI

;	Hotkeys Tab
	Gui, Tab, 3
	Gui, Add, Button, x130 y35 gGui_Settings_Hotkeys_Switch w200 hwndHotkeys_SwitchToBasicHandler,Switch to Basic
	xpos := 20, ypos := 70
	Loop 16 {
		btnID := A_Index
		if ( btnID > 1 && btnID <= 8 ) || ( btnID > 9 )
			ypos += 30
		else if ( btnID = 9 )
			xpos := 235, ypos := 70
		Gui, Add, Checkbox, x%xpos% y%ypos% vHotkeyAdvanced%btnID%_Toggle hwndHotkeyAdvanced%btnID%_ToggleHandler
		Gui, Add, Edit, xp+30 yp-3 w60 vHotkeyAdvanced%btnID%_KEY hwndHotkeyAdvanced%btnID%_KEYHandler
		Gui, Add, Edit, xp+65 yp w110 gGui_Settings_Hotkeys_Tooltip vHotkeyAdvanced%btnID%_Text hwndHotkeyAdvanced%btnID%_TextHandler
		if ( GlobalValues["Hotkeys_Mode"] != "Advanced" )  {
			GuiControl,Settings:Hide,% Hotkeys_SwitchToBasicHandler
			GuiControl,Settings:Hide,% HotkeyAdvanced%btnID%_ToggleHandler
			GuiControl,Settings:Hide,% HotkeyAdvanced%btnID%_KEYHandler
			GuiControl,Settings:Hide,% HotkeyAdvanced%btnID%_TextHandler
		}
	}

	Gui, Add, Button, x130 y35 gGui_Settings_Hotkeys_Switch w200 hwndHotkeys_SwitchToAdvancedHandler,Switch to Advanced
	xpos := 20, ypos := 55
	Loop 6 {
		btnID := A_Index
		if (btnID > 1 && btnID <= 3) || (btnID > 4)
			ypos += 80
		else if (btnID = 4)
			xpos := 230, ypos := 55
		Gui, Add, GroupBox, x%xpos% y%ypos% w209 h90 hwndHotkey%btnID%_GroupBox
		Gui, Add, Checkbox, xp+10 yp+20 vHotkey%btnID%_Toggle hwndHotkey%btnID%_ToggleHandler
		Gui, Add, Edit, xp+30 yp-4 w150 vHotkey%btnID%_Text hwndHotkey%btnID%_TextHandler,
		Gui, Add, Hotkey, xp yp+25 w150 vHotkey%btnID%_KEY hwndHotkey%btnID%_KEYHandler gGui_Settings_Hotkeys,
		Gui, Add, Checkbox, xp yp+28 vHotkey%btnID%_CTRL hwndHotkey%btnID%_CTRLHandler,CTRL
		Gui, Add, Checkbox, xp+50 yp vHotkey%btnID%_ALT hwndHotkey%btnID%_ALTHandler,ALT
		Gui, Add, Checkbox, xp+42 yp vHotkey%btnID%_SHIFT hwndHotkey%btnID%_SHIFTHandler,SHIFT
		if ( GlobalValues["Hotkeys_Mode"] != "Basic" ) {
			GuiControl,Settings:Hide,% Hotkeys_SwitchToAdvancedHandler
			GuiControl,Settings:Hide,% Hotkey%btnID%_GroupBox
			GuiControl,Settings:Hide,% Hotkey%btnID%_ToggleHandler
			GuiControl,Settings:Hide,% Hotkey%btnID%_TextHandler
			GuiControl,Settings:Hide,% Hotkey%btnID%_KEYHandler
			GuiControl,Settings:Hide,% Hotkey%btnID%_CTRLHandler
			GuiControl,Settings:Hide,% Hotkey%btnID%_ALTHandler
			GuiControl,Settings:Hide,% Hotkey%btnID%_SHIFTHandler
		}
	}
	Gui, Add, Button, x20 y310 w300 h30 gGui_Settings_Btn_Apply vApplyBtn3,Apply Settings
	Gui, Add, Button, x320 y310 w120 h30 vWikiBtn3 gGui_Settings_Btn_WIKI,Visit the WIKI
	GuiControl, Choose, Tab, 1
	GoSub, Gui_Settings_Set_Preferences
	Gui, Trades: -E0x20
	Gui, Show
	guiCreated := 1
return

	Gui_Settings_Trades_Preview:
		Gosub, Gui_Settings_Btn_Apply
		Gui_Trades_Clone()
	Return

	Gui_Settings_Custom_Label:
		Gui, Settings:Submit, NoHide
		RegExMatch(A_GuiControl, "\d+", btnID)
		RegExMatch(A_GuiControl, "\D+", btnType)
		actionContent := (btnID=1)?(TradesAction1):(btnID=2)?(TradesAction2):(btnID=3)?(TradesAction3):(btnID=4)?(TradesAction4):(btnID=5)?(TradesAction5):(btnID=6)?(TradesAction6):(btnID=7)?(TradesAction7):(btnID=8)?(TradesAction8):(btnID=9)?(TradesAction9):("ERROR")
		labelContent := (btnID=1)?(TradesLabel1):(btnID=2)?(TradesLabel2):(btnID=3)?(TradesLabel3):(btnID=4)?(TradesLabel4):(btnID=5)?(TradesLabel5):(btnID=6)?(TradesLabel6):(btnID=7)?(TradesLabel7):(btnID=8)?(TradesLabel8):(btnID=9)?(TradesLabel9):("ERROR")
		Gui_Settings_Custom_Label_Func(btnType, DynamicGUIHandlersArray, btnID, actionContent, labelContent)
	Return

	Gui_Settings_Btn_WIKI:
		Run, % "https://github.com/lemasato/POE-Trades-Helper/wiki"
	Return
	
	Gui_Settings_Hotkeys_Tooltip:
		if ( guiCreated = 0 )
			Return

		Gui, Settings:Submit, NoHide
		RegExMatch(A_GuiControl, "\d+", btnID)
		ctrlHandler := (btnID=1)?(HotkeyAdvanced1_TextHandler):(btnID=2)?(HotkeyAdvanced2_TextHandler):(btnID=3)?(HotkeyAdvanced3_TextHandler):(btnID=4)?(HotkeyAdvanced4_TextHandler):(btnID=5)?(HotkeyAdvanced5_TextHandler):(btnID=6)?(HotkeyAdvanced6_TextHandler):(btnID=7)?(HotkeyAdvanced7_TextHandler):(btnID=8)?(HotkeyAdvanced8_TextHandler):(btnID=9)?(HotkeyAdvanced9_TextHandler):(btnID=10)?(HotkeyAdvanced10_TextHandler):(btnID=11)?(HotkeyAdvanced11_TextHandler):(btnID=12)?(HotkeyAdvanced12_TextHandler):(btnID=13)?(HotkeyAdvanced13_TextHandler):(btnID=14)?(HotkeyAdvanced14_TextHandler):(btnID=15)?(HotkeyAdvanced15_TextHandler):(btnID=16)?(HotkeyAdvanced16_TextHandler):("ERROR")
		GuiControlGet, ctrlContent, Settings:,% ctrlHandler
		try 
			ToolTip,% ctrlContent
	Return

	Gui_Settings_Hotkeys_Switch:
		if ( A_GuiControl = "Switch to Advanced" ) {
			IniWrite,% "Advanced",% iniFilePath, SETTINGS,Hotkeys_Mode
			GlobalValues.Insert("Hotkeys_Mode", "Advanced")
		}
		else {
			IniWrite,% "Basic",% iniFilePath, SETTINGS,Hotkeys_Mode
			GlobalValues.Insert("Hotkeys_Mode", "Basic")
		}
		GoSub Gui_Settings_Btn_Apply
		Gui_Settings()
		GuiControl, Settings:Choose, Tab, 3
	Return

	Gui_Settings_Support_MsgBox:
		Gui, Settings: Submit, NoHide
	Return

	
	GUI_Settings_Tick_Case:
		Gui, Settings: Submit, NoHide
		if ( A_GuiControl = "MessageSupportToggleText" ) {
			GuiControl, Settings:,% MessageSupportToggleHandler,% !MessageSupportToggle 
			GoSub Gui_Settings_Support_MsgBox
		}
	Return

	Gui_Settings_Transparency:
	;	Set the transparency
		Gui, Settings: Submit, NoHide
		trans := ( ShowTransparency / 100 ) * 255 ; ( value - percentage ) * max // Convert percentage to 0-255 range
		transActive := ( ShowTransparencyActive / 100 ) * 255 ; ( value - percentage ) * max // Convert percentage to 0-255 range
		Gui, Trades: +LastFound
		if ( A_GuiControl = "ShowTransparency" )
			WinSet, Transparent,% trans
		else
			WinSet, Transparent,% transActive
		if ( A_GuiControlEvent = "Normal" ) {
			IniRead, isActive,% iniFilePath,PROGRAM,Tabs_Number
			Gui, Trades: +LastFound
			if ( isActive > 0 )
				Winset, Transparent,% transActive
			else
				Winset, Transparent,% trans
		}
	return
	
	Gui_Settings_Close:
		Gui, Settings: Destroy
		IniRead, isActive,% iniFilePath,PROGRAM,Tabs_Number
		if ( isActive = 0 && GlobalValues["Trades_Click_Through"] = 1 )
			Gui, Trades: +E0x20
		Gui, TradesClone:Destroy
	return
	
	Gui_Settings_Notifications_Browse:
		FileSelectFile, soundFile, ,% programSFXFolderPath, Select an audio file (%programName%),Audio (*.wav; *.mp3)
		if ( soundFile ) {
			SplitPath, soundFile, soundFileName
			if ( A_GuiControl = "NotifyTradeBrowse" ) {
				GuiControl, Settings:,% NotifyTradeSoundHandler,% soundFileName
				tradesSoundFile := soundFile
			}
			if ( A_GuiControl = "NotifyWhisperBrowse" ) {
				GuiControl, Settings:,% NotifyWhisperSoundHandler,% soundFileName
				whispersSoundFile := soundFile
			}
		}
	return
	
	Gui_Settings_Hotkeys:
		RegExMatch(A_GuiControl, "\d+", btnID)
		hotkeyHandler := (btnID="1")?(Hotkey1_KEYHandler):(btnID="2")?(Hotkey2_KEYHandler):(btnID="3")?(Hotkey3_KEYHandler):(btnID="4")?(Hotkey4_KEYHandler):(btnID="5")?(Hotkey5_KEYHandler):(btnID="6")?(Hotkey6_KEYHandler):("ERROR")
		Gui_Settings_Hotkeys_Func(hotkeyHandler)
	return
	
	Gui_Settings_Btn_Apply:
		Gui, +OwnDialogs
		Gui, Submit, NoHide
;	Trades GUI
		trans := ( ShowTransparency / 100 ) * 255 ; ( value - percentage ) * max // Convert percentage to 0-255 range
		transActive := ( ShowTransparencyActive / 100 ) * 255 ; ( value - percentage ) * max // Convert percentage to 0-255 range
		IniWrite,% trans,% iniFilePath,SETTINGS,Transparency
		IniWrite,% transActive,% iniFilePath,SETTINGS,Transparency_Active
		showMode := ( ShowAlways = 1 ) ? ( "Always" ) : ( ShowInGame = 1 ) ? ( "InGame" ) : ( "Always" )
		IniWrite,% showMode,% iniFilePath,SETTINGS,Show_Mode
		IniWrite,% AutoMinimize,% iniFilePath,SETTINGS,Trades_Auto_Minimize
		IniWrite,% AutoUnMinimize,% iniFilePath,SETTINGS,Trades_Auto_UnMinimize
		IniWrite,% ClickThrough,% iniFilePath,SETTINGS,Trades_Click_Through
		if ( ClickThrough )
			Gui, Trades: +E0x20
		else 
			Gui, Trades: -E0x20
		IniWrite,% SelectLastTab,% iniFilePath,SETTINGS,Trades_Select_Last_Tab
;	Clipboard
		IniWrite,% ClipNew,% iniFilePath,AUTO_CLIP,Clip_New_Items
		IniWrite,% ClipTab,% iniFilePath,AUTO_CLIP,Clip_On_Tab_Switch
;	Notifications
		IniWrite,% NotifyTradeToggle,% iniFilePath,NOTIFICATIONS,Trade_Toggle
		IniWrite,% NotifyTradeSound,% iniFilePath,NOTIFICATIONS,Trade_Sound
		if ( tradesSoundFile )
			IniWrite,% tradesSoundFile,% iniFilePath,NOTIFICATIONS,Trade_Sound_Path
		IniWrite,% NotifyWhisperToggle,% iniFilePath,NOTIFICATIONS,Whisper_Toggle
		IniWrite,% NotifyWhisperSound,% iniFilePath,NOTIFICATIONS,Whisper_Sound
		if ( whispersSoundFile )
			IniWrite,% whispersSoundFile,% iniFilePath,NOTIFICATIONS,Whisper_Sound_Path
		IniWrite,% NotifyWhisperTray,% iniFilePath,NOTIFICATIONS,Whisper_Tray
		IniWrite,% NotifyWhisperFlash,% iniFilePath,NOTIFICATIONS,Whisper_Flash
;	Support
		IniWrite,% MessageSupportToggle,% iniFilePath,MESSAGES,Support_Text_Toggle
;	Messages
;		Wait
		IniWrite,% MessageWaitToggle,% iniFilePath,MESSAGES,Wait_Text_Toggle
		IniWrite,% MessageWait,% iniFilePath,MESSAGES,Wait_Text
;		Party
		IniWrite,% MessageInviteToggle,% iniFilePath,MESSAGES,Invite_Text_Toggle
		IniWrite,% MessageInvite,% iniFilePath,MESSAGES,Invite_Text
;		Thanks
		IniWrite,% MessageThanksToggle,% iniFilePath,MESSAGES,Thanks_Text_Toggle
		IniWrite,% MessageThanks,% iniFilePath,MESSAGES,Thanks_Text
;		Sold
		IniWrite,% MessageSoldToggle,% iniFilePath,MESSAGES,Sold_Text_Toggle
		IniWrite,% MessageSold,% iniFilePath,MESSAGES,Sold_Text
;	Hotkeys
	;	1
		IniWrite,% Hotkey1_Toggle,% iniFilePath,HOTKEYS,HK1_Toggle
		IniWrite,% Hotkey1_Text,% iniFilePath,HOTKEYS,HK1_Text
		IniWrite,% Hotkey1_KEY,% iniFilePath,HOTKEYS,HK1_KEY
		IniWrite,% Hotkey1_CTRL,% iniFilePath,HOTKEYS,HK1_CTRL
		IniWrite,% Hotkey1_ALT,% iniFilePath,HOTKEYS,HK1_ALT
		IniWrite,% Hotkey1_SHIFT,% iniFilePath,HOTKEYS,HK1_SHIFT
	;	2
		IniWrite,% Hotkey2_Toggle,% iniFilePath,HOTKEYS,HK2_Toggle
		IniWrite,% Hotkey2_Text,% iniFilePath,HOTKEYS,HK2_Text
		IniWrite,% Hotkey2_KEY,% iniFilePath,HOTKEYS,HK2_KEY
		IniWrite,% Hotkey2_CTRL,% iniFilePath,HOTKEYS,HK2_CTRL
		IniWrite,% Hotkey2_ALT,% iniFilePath,HOTKEYS,HK2_ALT
		IniWrite,% Hotkey2_SHIFT,% iniFilePath,HOTKEYS,HK2_SHIFT
	;	3
		IniWrite,% Hotkey3_Toggle,% iniFilePath,HOTKEYS,HK3_Toggle
		IniWrite,% Hotkey3_Text,% iniFilePath,HOTKEYS,HK3_Text
		IniWrite,% Hotkey3_KEY,% iniFilePath,HOTKEYS,HK3_KEY
		IniWrite,% Hotkey3_CTRL,% iniFilePath,HOTKEYS,HK3_CTRL
		IniWrite,% Hotkey3_ALT,% iniFilePath,HOTKEYS,HK3_ALT
		IniWrite,% Hotkey3_SHIFT,% iniFilePath,HOTKEYS,HK3_SHIFT
	;	4
		IniWrite,% Hotkey4_Toggle,% iniFilePath,HOTKEYS,HK4_Toggle
		IniWrite,% Hotkey4_Text,% iniFilePath,HOTKEYS,HK4_Text
		IniWrite,% Hotkey4_KEY,% iniFilePath,HOTKEYS,HK4_KEY
		IniWrite,% Hotkey4_CTRL,% iniFilePath,HOTKEYS,HK4_CTRL
		IniWrite,% Hotkey4_ALT,% iniFilePath,HOTKEYS,HK4_ALT
		IniWrite,% Hotkey4_SHIFT,% iniFilePath,HOTKEYS,HK4_SHIFT
	;	5
		IniWrite,% Hotkey5_Toggle,% iniFilePath,HOTKEYS,HK5_Toggle
		IniWrite,% Hotkey5_Text,% iniFilePath,HOTKEYS,HK5_Text
		IniWrite,% Hotkey5_KEY,% iniFilePath,HOTKEYS,HK5_KEY
		IniWrite,% Hotkey5_CTRL,% iniFilePath,HOTKEYS,HK5_CTRL
		IniWrite,% Hotkey5_ALT,% iniFilePath,HOTKEYS,HK5_ALT
		IniWrite,% Hotkey5_SHIFT,% iniFilePath,HOTKEYS,HK5_SHIFT
	;	6
		IniWrite,% Hotkey6_Toggle,% iniFilePath,HOTKEYS,HK6_Toggle
		IniWrite,% Hotkey6_Text,% iniFilePath,HOTKEYS,HK6_Text
		IniWrite,% Hotkey6_KEY,% iniFilePath,HOTKEYS,HK6_KEY
		IniWrite,% Hotkey6_CTRL,% iniFilePath,HOTKEYS,HK6_CTRL
		IniWrite,% Hotkey6_ALT,% iniFilePath,HOTKEYS,HK6_ALT
		IniWrite,% Hotkey6_SHIFT,% iniFilePath,HOTKEYS,HK6_SHIFT
;	Hotkeys Advanced
		Loop 16 {
			index := A_Index
			KEY := "HK" index "_ADV_Toggle"
			CONTENT := (index=1)?(HotkeyAdvanced1_Toggle):(index=2)?(HotkeyAdvanced2_Toggle):(index=3)?(HotkeyAdvanced3_Toggle):(index=4)?(HotkeyAdvanced4_Toggle):(index=5)?(HotkeyAdvanced5_Toggle):(index=6)?(HotkeyAdvanced6_Toggle):(index=7)?(HotkeyAdvanced7_Toggle):(index=8)?(HotkeyAdvanced8_Toggle):(index=9)?(HotkeyAdvanced9_Toggle):(index=10)?(HotkeyAdvanced10_Toggle):(index=11)?(HotkeyAdvanced11_Toggle):(index=12)?(HotkeyAdvanced12_Toggle):(index=13)?(HotkeyAdvanced13_Toggle):(index=14)?(HotkeyAdvanced14_Toggle):(index=15)?(HotkeyAdvanced15_Toggle):(index=16)?(HotkeyAdvanced16_Toggle):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,HOTKEYS_ADVANCED,% KEY

			KEY := "HK" index "_ADV_KEY"
			CONTENT := (index=1)?(HotkeyAdvanced1_KEY):(index=2)?(HotkeyAdvanced2_KEY):(index=3)?(HotkeyAdvanced3_KEY):(index=4)?(HotkeyAdvanced4_KEY):(index=5)?(HotkeyAdvanced5_KEY):(index=6)?(HotkeyAdvanced6_KEY):(index=7)?(HotkeyAdvanced7_KEY):(index=8)?(HotkeyAdvanced8_KEY):(index=9)?(HotkeyAdvanced9_KEY):(index=10)?(HotkeyAdvanced10_KEY):(index=11)?(HotkeyAdvanced11_KEY):(index=12)?(HotkeyAdvanced12_KEY):(index=13)?(HotkeyAdvanced13_KEY):(index=14)?(HotkeyAdvanced14_KEY):(index=15)?(HotkeyAdvanced15_KEY):(index=16)?(HotkeyAdvanced16_KEY):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,HOTKEYS_ADVANCED,% KEY

			KEY := "HK" index "_ADV_Text"
			CONTENT := (index=1)?(HotkeyAdvanced1_Text):(index=2)?(HotkeyAdvanced2_Text):(index=3)?(HotkeyAdvanced3_Text):(index=4)?(HotkeyAdvanced4_Text):(index=5)?(HotkeyAdvanced5_Text):(index=6)?(HotkeyAdvanced6_Text):(index=7)?(HotkeyAdvanced7_Text):(index=8)?(HotkeyAdvanced8_Text):(index=9)?(HotkeyAdvanced9_Text):(index=10)?(HotkeyAdvanced10_Text):(index=11)?(HotkeyAdvanced11_Text):(index=12)?(HotkeyAdvanced12_Text):(index=13)?(HotkeyAdvanced13_Text):(index=14)?(HotkeyAdvanced14_Text):(index=15)?(HotkeyAdvanced15_Text):(index=16)?(HotkeyAdvanced16_Text):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,HOTKEYS_ADVANCED,% KEY
		}
;	Dynamic TradesGUI
		Loop 9 {
			index := A_Index

			KEY := "Button" index "_Label"
			CONTENT := (index=1)?(TradesLabel1):(index=2)?(TradesLabel2):(index=3)?(TradesLabel3):(index=4)?(TradesLabel4):(index=5)?(TradesLabel5):(index=6)?(TradesLabel6):(index=7)?(TradesLabel7):(index=8)?(TradesLabel8):(index=9)?(TradesLabel9):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,TRADES_GUI,% KEY

			KEY := "Button" index "_Action"
			CONTENT := (index=1)?(TradesAction1):(index=2)?(TradesAction2):(index=3)?(TradesAction3):(index=4)?(TradesAction4):(index=5)?(TradesAction5):(index=6)?(TradesAction6):(index=7)?(TradesAction7):(index=8)?(TradesAction8):(index=9)?(TradesAction9):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,TRADES_GUI,% KEY

			KEY := "Button" index "_Message"
			CONTENT := (index=1)?(TradesMsg1):(index=2)?(TradesMsg2):(index=3)?(TradesMsg3):(index=4)?(TradesMsg4):(index=5)?(TradesMsg5):(index=6)?(TradesMsg6):(index=7)?(TradesMsg7):(index=8)?(TradesMsg8):(index=9)?(TradesMsg9):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,TRADES_GUI,% KEY

			KEY := "Button" index "_H"
			CONTENT := (index=1)?(TradesHPOS1):(index=2)?(TradesHPOS2):(index=3)?(TradesHPOS3):(index=4)?(TradesHPOS4):(index=5)?(TradesHPOS5):(index=6)?(TradesHPOS6):(index=7)?(TradesHPOS7):(index=8)?(TradesHPOS8):(index=9)?(TradesHPOS9):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,TRADES_GUI,% KEY

			KEY := "Button" index "_V"
			CONTENT := (index=1)?(TradesVPOS1):(index=2)?(TradesVPOS2):(index=3)?(TradesVPOS3):(index=4)?(TradesVPOS4):(index=5)?(TradesVPOS5):(index=6)?(TradesVPOS6):(index=7)?(TradesVPOS7):(index=8)?(TradesVPOS8):(index=9)?(TradesVPOS9):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,TRADES_GUI,% KEY

			KEY := "Button" index "_SIZE"
			CONTENT := (index=1)?(TradesSIZE1):(index=2)?(TradesSIZE2):(index=3)?(TradesSIZE3):(index=4)?(TradesSIZE4):(index=5)?(TradesSIZE5):(index=6)?(TradesSIZE6):(index=7)?(TradesSIZE7):(index=8)?(TradesSIZE8):(index=9)?(TradesSIZE9):("ERROR")
			IniWrite,% CONTENT,% iniFilePath,TRADES_GUI,% KEY
		}
;	Declare the new settings
		Disable_Hotkeys()
		settingsArray := Get_INI_Settings()
		Declare_INI_Settings(settingsArray)
		Enable_Hotkeys()
	return

	Gui_Settings_Size:
		static GuiWidth, GuiHeight

		GuiWidth := A_GuiWidth
		GuiHeight := A_GuiHeight
		sleep 10
	return
	
	Gui_Settings_Set_Preferences:
;	Trades GUI
		returnArray := Gui_Settings_Get_Settings_Arrays()
		sectionArray := returnArray.sectionArray
		SETTINGS_HandlersArray := returnArray.SETTINGS_HandlersArray
		SETTINGS_HandlersKeysArray := returnArray.SETTINGS_HandlersKeysArray
		AUTO_CLIP_HandlersArray := returnArray.AUTO_CLIP_HandlersArray
		AUTO_CLIP_HandlersKeysArray := returnArray.AUTO_CLIP_HandlersKeysArray
		HOTKEYS_HandlersArray := returnArray.HOTKEYS_HandlersArray
		HOTKEYS_HandlersKeysArray := returnArray.HOTKEYS_HandlersKeysArray
		NOTIFICATIONS_HandlersArray := returnArray.NOTIFICATIONS_HandlersArray
		NOTIFICATIONS_HandlersKeysArray := returnArray.NOTIFICATIONS_HandlersKeysArray
		MESSAGES_HandlersArray := returnArray.MESSAGES_HandlersArray
		MESSAGES_HandlersKeysArray := returnArray.MESSAGES_HandlersKeysArray
		HOTKEYS_ADVANCED_HandlersArray := returnArray.HOTKEYS_ADVANCED_HandlersArray
		HOTKEYS_ADVANCED_HandlersKeysArray := returnArray.HOTKEYS_ADVANCED_HandlersKeysArray
		TRADES_GUI_HandlersArray := returnArray.TRADES_GUI_HandlersArray
		TRADES_GUI_HandlersKeysArray := returnArray.TRADES_GUI_HandlersKeysArray

		for key, element in sectionArray
		{
			sectionName := element
			for key, element in %sectionName%_HandlersKeysArray
			{
				keyName := element
				handler := %sectionName%_HandlersArray[key]
				IniRead, var,% iniFilePath,% sectionName,% keyName
				if ( keyName = "Show_Mode" ) { ; Make sure only one goes through
					GuiControl, Settings:,% Show%var%Handler,1
				}
				else if ( keyName = "Dock_Mode" ) { ; Make sure only one goes through
					GuiControl, Settings:, % Dock%var%Handler,1
				}
				else if ( keyName = "Transparency" || keyName = "Transparency_Active" ) { ; Convert to pecentage
					var := ((var - 0) * 100) / (255 - 0)
					GuiControl, Settings:,% %handler%Handler,% var
				}
				else if ( keyName = "Logs_Mode" ) { ; Make sure only one goes through
					GuiControl, Settings:,% Logs%var%Handler,1
				}
				else if ( sectionName = "TRADES_GUI" ) {
					if keyName contains _H,_V,_SIZE,_ACTION
						GuiControl, Settings:Choose,% %handler%Handler,% var
					else {
						handler := %sectionName%_HandlersArray[key]
						GuiControl, Settings:,% %handler%Handler,% var
					}
				}
				else if ( var != "ERROR" && var != "" ) { ; Everything else
					handler := %sectionName%_HandlersArray[key]
					GuiControl, Settings:,% %handler%Handler,% var
				}
			}
		}
	return
}

Gui_Trades_Clone() {
/*			Clone of the Trades GUI used as a preview
 *			__TO_BE_ADDED__ Custom skin compatibility
*/
	static
	global GlobalValues, ProgramValues

	programSkinFolderPath := ProgramValues["Skins_Folder"], programName := ProgramValues["Name"]

	infosArray := Object()
	infosArray.BUYERS := Object()
	infosArray.ITEMS := Object()
	infosArray.PRICES := Object()
	infosArray.LOCATIONS := Object()
	infosArray.TIME := Object()
	infosArray.OTHER := Object()
	infosArray.BUYERS.Insert(1, "iSellStuff")
	infosArray.ITEMS.Insert(1, "level 1 Faster Attacks Support")
	infosArray.PRICES.Insert(1, "5 alteration")
	infosArray.LOCATIONS.Insert(1, "Breach (stash tab ""Gems""; position: left 6, top 8)")
	infosArray.TIME.Insert(1, A_Hour ":" A_Min)
	infosArray.OTHER.Insert(1, "Offering 1alch?")

	aeroStatus := Get_Aero_Status()
	themeState := (aeroStatus=1)?("+Theme -0x8000"):("-Theme +0x8000")

	tabHeight := Gui_Trades_Get_Tab_Height(), tabWidth := 390
	guiWidth := 402, guiHeight := tabHeight+38, guiHeightMin := 30

	showWidth := guiWidth
	showHeight := (GlobalValues["Trades_GUI_Minimized=1"])?(guiHeightMin):(guiHeight)
	showX := 10, showY := 10

	defaultMaxTabs := 1, maxTabsRow := 1

	Gui, TradesClone:Destroy
	Gui, TradesClone:New, +AlwaysOnTop +hwndGuiTradesCloneHandler +LastFound +LabelGui_Trades_Clone_
	Gui, TradesClone:Default
	
	Gui, Font, s10 cWhite,% GlobalValues["Trades_GUI_Font"]
	Gui, Add, Picture,% "x0 y0 w" guiWidth " h30 ",% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\Header.png"
	Gui, Add, Text,% "x35 y2 w" guiWidth-100 " h28 cC18F55 BackgroundTrans +0x200",% programName " - Queued Trades: 0"
	Gui, Add, Text,% "x" guiWidth-65 " w65 y2 h28 + +0x200 cC18F55 +BackgroundTrans",% "MINIMIZE"
	Gui, Color, 181511
	Gui, Add, Picture, x1 y30 w%guiWidth% h%guiHeight%,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\Background.png"
	Gui, Add, Picture, x1 y50 w%guiWidth% h2,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabUnderline.png"
	Gui, Add, Text,% "x0 y0 w" guiWidth " h2 +0x4",% "" ; Top
	Gui, Add, Text,% "x0 y0 w2 h" guiHeight " +0x4",% "" ; Left
	Gui, Add, Text,% "x0 y" guiHeight-2 " w" guiWidth + 5 " h2 +0x4",% "" ; Bottom
	Gui, Add, Text,% "x" guiWidth-2 " y0 w2 h" guiHeight " +0x4",% "" ; Right

	

	tabsMax := defaultMaxTabs
	Loop %tabsMax% {
		index := A_Index
		tabPos := A_Index
		xposMult := 50
		xpos := (tabPos * xposMult) - xposMult + 2, ypos := 30
		
		Gui, Add, Picture, x%xpos% y%ypos% w50 h20 hwndTabIMGClone%index%Handler vTabIMGClone%index% ,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\TabActive.png"
		Gui, Font, Bold
		Gui, Add, Text, xp yp+3 +BackgroundTrans w50 h20 hwndTabTXTClone%index%Handler vTabTXTClone%index% 0x1,% index
		Gui, Font, Norm
	}

	Loop %tabsMax% {
		index := A_Index
		Gui, Font, cC18F55
		if ( index = 1 ) {
			Gui, Add, Text, x9 y60 w60 h15 hwndBuyerTextClone%index%Handler +BackgroundTrans,% "Buyer: "
			Gui, Add, Text, w60 h15 xp yp+15 hwndItemTextClone%index%Handler +BackgroundTrans,% "Item: "
			Gui, Add, Text, w60 h15 xp yp+15 hwndPriceTextClone%index%Handler +BackgroundTrans,% "Price: "
			Gui, Add, Text, w60 h15 xp yp+15 hwndLocationTextClone%index%Handler +BackgroundTrans,% "Location: "
			Gui, Add, Text, w60 h15 xp yp+15 hwndOtherTextClone%index%Handler +BackgroundTrans,% "Other: "
		}
		Gui, Font, cFFFFFF
		Gui, Add, Text, x75 y60 w255 h15 vBuyerSlotClone%index% +BackgroundTrans +0x0100,% ""
		Gui, Add, Text, xp yp+15 w310 h15 vItemSlotClone%index% +BackgroundTrans +0x0100,% ""
		Gui, Add, Text, xp yp+15 w310 h15 vPriceSlotClone%index% +BackgroundTrans +0x0100,% ""
		if ( infosArray.PRICES[index] = "UNPRICED ITEM")
			GuiControl, TradesClone: +cRed, PriceSlotClone%index%
		Gui, Add, Text, xp yp+15 w310 h15 vLocationSlotClone%index% +BackgroundTrans +0x0100,% ""
		Gui, Add, Text, xp yp+15 w310 h15 vOtherSlotClone%index% +BackgroundTrans +0x100,% ""
		Gui, Add, Text, x340 y55 w30 h15 vTimeSlotClone%index% +BackgroundTrans,% ""
		Gui, Add, Text, w0 h0 x0 y0 vPIDSlotClone%index%,
	}

	Gui, Add, Picture,x360 y30 w20 h20 vGoLeftClone +BackgroundTrans,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ArrowLeft.png"
	Gui, Add, Picture,x380 y30 w20 h20 vGoRightClone +BackgroundTrans,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ArrowRight.png"
	Gui, Add, Picture,x370 y55 w25 h25 vdelBtnClone1 %themeState% hwndCloseBtnClone1Handler +BackgroundTrans,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\Close.png"

	Loop 9 {
		btnW := (GlobalValues["Button" A_Index "_SIZE"]="Small")?(124):(GlobalValues["Button" A_Index "_SIZE"]="Medium")?(254):(GlobalValues["Button" A_Index "_SIZE"]="Large")?(374):("ERROR")
		btnX := (GlobalValues["Button" A_Index "_H"]="Left")?(9):(GlobalValues["Button" A_Index "_H"]="Center")?(139):(GlobalValues["Button" A_Index "_H"]="Right")?(269):("ERROR")
		btnY := (GlobalValues["Button" A_Index "_V"]="Top")?(140):(GlobalValues["Button" A_Index "_V"]="Middle")?(180):(GlobalValues["Button" A_Index "_V"]="Bottom")?(220):("ERROR")
		btnName := GlobalValues["Button" A_Index "_Label"]
		btnSub := RegExReplace(GlobalValues["Button" A_Index "_Action"], "[ _+()]", "_")
		btnSub := RegExReplace(btnSub, "___", "_")
		btnSub := RegExReplace(btnSub, "__", "_")
		btnSub := RegExReplace(btnSub, "_", "", ,1,-1)
		if ( btnW != "ERROR" && btnX != "ERROR" && btnY != "ERROR" && btnSub != "" && btnSub != "ERROR" ) {
			Gui, Add, Picture,x%btnX% y%btnY% w%btnW% h35 vCustomBtnClone%A_Index% hwndCustomBtnClone%A_Index%Handler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ButtonBackground.png"
			Gui, Add, Picture,% "x" btnX " y" btnY " w8 h35 +BackgroundTrans vCustomBtnClone" A_Index "OrnamentLeft",% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ButtonOrnamentLeft.png"
			Gui, Add, Picture,% "x" btnX+btnW-8 " y" btnY " w8 h35 +BackgroundTrans vCustomBtnClone" A_Index "OrnamentRight",% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\ButtonOrnamentRight.png"
			Gui, Font, cC18F55
			Gui, Add, Text,x%btnX% yp+10 w%btnW% Center vCustomBtnTXTClone%A_Index% +BackgroundTrans,% btnName
		}
	}

	for key, element in infosArray.BUYERS {
		GuiControl, TradesClone:,buyerSlotClone%key%,% infosArray.BUYERS[key]
		GuiControl, TradesClone:,itemSlotClone%key%,% infosArray.ITEMS[key]
		GuiControl, TradesClone:,priceSlotClone%key%,% infosArray.PRICES[key]
		GuiControl, TradesClone:,locationSlotClone%key%,% infosArray.LOCATIONS[key]
		GuiControl, TradesClone:,PIDSlotClone%key%,% infosArray.GAMEPID[key]
		GuiControl, TradesClone:,TimeSlotClone%key%,% infosArray.TIME[key]
		GuiControl, TradesClone:,OtherSlotClone%key%,% infosArray.OTHER[key]
	}

	Gui, TradesClone:Show,% "NoActivate w" showWidth " h" showHeight " x" showX " y" showY,% programName " - Queued Trades"

	sleep 10
	WinSet, Redraw, ,% "ahk_id " guiTradesCloneHandler 
	return

	Gui_Trades_Clone_Close:
 		Gui, TradesClone:Destroy
 	Return
 
 	Gui_Trades_Clone_Escape:
 		Gosub, Gui_Trades_Clone_Close
 	Return
}

Gui_Settings_Custom_Label_Func(type, controlsArray, btnID, action, label) {
	if ( type = "TradesBtn" ) {
		for key, element in controlsArray.HPOS
			GuiControl,Settings:Hide,% element
		for key, element in controlsArray.HPOSText
			GuiControl,Settings:Hide,% element

		for key, element in controlsArray.VPOS
			GuiControl,Settings:Hide,% element
		for key, element in controlsArray.VPOSText
			GuiControl,Settings:Hide,% element

		for key, element in controlsArray.SIZE
			GuiControl,Settings:Hide,% element
		for key, element in controlsArray.SIZEText
			GuiControl,Settings:Hide,% element
		
		for key, element in controlsArray.Label
			GuiControl,Settings:Hide,% element
		for key, element in controlsArray.LabelText
			GuiControl,Settings:Hide,% element

		for key, element in controlsArray.Action
			GuiControl,Settings:Hide,% element	
		for key, element in controlsArray.ActionText
			GuiControl,Settings:Hide,% element

		for key, element in controlsArray.Msg
			GuiControl,Settings:Hide,% element

		GuiControl,Settings:Show,% controlsArray.HPOS[btnID]
		GuiControl,Settings:Show,% controlsArray.HPOSText[btnID]

		GuiControl,Settings:Show,% controlsArray.VPOS[btnID]
		GuiControl,Settings:Show,% controlsArray.VPOSText[btnID]

		GuiControl,Settings:Show,% controlsArray.SIZE[btnID]
		GuiControl,Settings:Show,% controlsArray.SIZEText[btnID]

		GuiControl,Settings:Show,% controlsArray.Label[btnID]
		GuiControl,Settings:Show,% controlsArray.LabelText[btnID]

		GuiControl,Settings:Show,% controlsArray.Action[btnID]
		GuiControl,Settings:Show,% controlsArray.ActionText[btnID]
	}

	if ( type = "TradesLabel" )
		GuiControl,Settings:,% controlsArray.Btn[btnID],% label

	if ( type = "TradesAction" || type = "TradesBtn" ) && ( action != "Clipboard Item" && action != "" )
		GuiControl,Settings:Show,% controlsArray.Msg[btnID]

	if ( type = "TradesAction" || type = "TradesBtn" ) && ( action = "Clipboard Item" || action = "" )
		GuiControl,Settings:Hide,% controlsArray.Msg[btnID]
}

Gui_Settings_Hotkeys_Func(ctrlHandler) {
	GuiControlGet, strHotkey, ,% ctrlHandler
	if strHotKey contains ^,!,+ ; Prevent modifier keys from slipping through
		GuiControl, Settings: ,% ctrlHandler, None
}

Show_Tooltip(ctrlName, ctrlHandler) {
	RegExMatch(ctrlName, "\d+", btnID)
	GuiControlGet, ctrlVar, Settings:,% ctrlHandler
	ToolTip,% ctrlVar
}


Gui_Settings_Get_Settings_Arrays() {
;			Contains all the section/handlers/keys/defaut values for the Settings GUI
;			Return an array containing all those informations
	global ProgramValues

	programSFXFolderPath := ProgramValues["SFX_Folder"]

	returnArray := Object()
	returnArray.sectionArray := Object() ; contains all the .ini SECTIONS
	returnArray.sectionArray.Insert(0, "SETTINGS", "AUTO_CLIP", "HOTKEYS", "NOTIFICATIONS", "MESSAGES", "HOTKEYS_ADVANCED", "TRADES_GUI")
	
	returnArray.SETTINGS_HandlersArray := Object() ; contains all the Gui_Settings HANDLERS from this SECTION
	returnArray.SETTINGS_HandlersArray.Insert(0, "ShowAlways", "ShowInGame", "ShowTransparency", "ShowTransparencyActive", "AutoMinimize", "AutoUnMinimize", "ClickThrough", "SelectLastTab")
	returnArray.SETTINGS_HandlersKeysArray := Object() ; contains all the .ini KEYS for those HANDLERS
	returnArray.SETTINGS_HandlersKeysArray.Insert(0, "Show_Mode", "Show_Mode", "Transparency", "Transparency_Active", "Trades_Auto_Minimize", "Trades_Auto_UnMinimize", "Trades_Click_Through", "Trades_Select_Last_Tab")
	returnArray.SETTINGS_KeysArray := Object() ; contains all the individual .ini KEYS
	returnArray.SETTINGS_KeysArray.Insert(0, "Show_Mode", "Transparency", "Trades_GUI_Mode", "Transparency_Active", "Hotkeys_Mode", "Trades_Auto_Minimize", "Trades_Auto_UnMinimize", "Trades_Click_Through", "Trades_Select_Last_Tab")
	returnArray.SETTINGS_DefaultValues := Object() ; contains all the DEFAULT VALUES for the .ini KEYS
	returnArray.SETTINGS_DefaultValues.Insert(0, "Always", "255", "Window", "255", "Basic", "0", "0", "0", "0")
	
	returnArray.AUTO_CLIP_HandlersArray := Object()
	returnArray.AUTO_CLIP_HandlersArray.Insert(0, "ClipNew", "ClipTab")
	returnArray.AUTO_CLIP_HandlersKeysArray := Object()
	returnArray.AUTO_CLIP_HandlersKeysArray.Insert(0, "Clip_New_Items", "Clip_On_Tab_Switch")
	returnArray.AUTO_CLIP_KeysArray := Object()
	returnArray.AUTO_CLIP_KeysArray.Insert(0, "Clip_New_Items", "Clip_On_Tab_Switch")
	returnArray.AUTO_CLIP_DefaultValues := Object()
	returnArray.AUTO_CLIP_DefaultValues.Insert(0, "1", "1")
	
	returnArray.HOTKEYS_HandlersArray := Object()
	returnArray.HOTKEYS_HandlersKeysArray := Object()
	returnArray.HOTKEYS_KeysArray := Object()
	returnArray.HOTKEYS_DefaultValues := Object()
	keyID := 0
	Loop 6 {
		index := A_Index
		returnArray.HOTKEYS_HandlersArray.Insert(keyID, "Hotkey" index "_Toggle", "Hotkey" index "_Text", "Hotkey" index "_KEY", "Hotkey" index "_CTRL", "Hotkey" index "_ALT", "Hotkey" index "_SHIFT")
		returnArray.HOTKEYS_HandlersKeysArray.Insert(keyID, "HK" index "_Toggle", "HK" index "_Text", "HK" index "_KEY","HK" index "_CTRL", "HK" index "_ALT", "HK" index "_SHIFT")
		returnArray.HOTKEYS_KeysArray.Insert(keyID, "HK" index "_Toggle", "HK" index "_Text", "HK" index "_KEY","HK" index "_CTRL", "HK" index "_ALT", "HK" index "_SHIFT")
		hkToggle := (index=1)?(1) : (0)
		hkTxtCmd := (index=1)?("/hideout") : (index=2)?("/kick YourName") : (index=3)?("/oos") : ("Insert Command or Message")
		hkKeyCmd := (index=1)?("F2") : ("")
		returnArray.HOTKEYS_DefaultValues.Insert(keyID, hkToggle, hkTxtCmd, hkKeyCmd, "0", "0", "0")
		keyID+=6
	}

	returnArray.NOTIFICATIONS_HandlersArray := Object()
	returnArray.NOTIFICATIONS_HandlersArray.Insert(0, "NotifyTradeToggle", "NotifyTradeSound", "NotifyWhisperToggle", "NotifyWhisperSound", "NotifyWhisperTray", "NotifyWhisperFlash")
	returnArray.NOTIFICATIONS_HandlersKeysArray := Object()
	returnArray.NOTIFICATIONS_HandlersKeysArray.Insert(0, "Trade_Toggle", "Trade_Sound", "Whisper_Toggle", "Whisper_Sound", "Whisper_Tray", "Whisper_Flash")
	returnArray.NOTIFICATIONS_KeysArray := Object()
	returnArray.NOTIFICATIONS_KeysArray.Insert(0, "Trade_Toggle", "Trade_Sound", "Trade_Sound_Path", "Whisper_Toggle", "Whisper_Sound", "Whisper_Sound_Path", "Whisper_Tray", "Whisper_Flash")
	returnArray.NOTIFICATIONS_DefaultValues := Object()
	returnArray.NOTIFICATIONS_DefaultValues.Insert(0, "1", "WW_MainMenu_Letter.wav", programSFXFolderPath "\WW_MainMenu_Letter.wav", "0", "None", "", "1", "0")
	
	returnArray.MESSAGES_HandlersArray := Object()
	returnArray.MESSAGES_HandlersArray.Insert(0, "MessageWaitToggle", "MessageWait", "MessageInviteToggle","MessageInvite", "MessageThanksToggle","MessageThanks", "MessageSoldToggle", "MessageSold", "MessageSupportToggle")
	returnArray.MESSAGES_HandlersKeysArray := Object()
	returnArray.MESSAGES_HandlersKeysArray.Insert(0, "Wait_Text_Toggle", "Wait_Text", "Invite_Text_Toggle", "Invite_Text", "Thanks_Text_Toggle", "Thanks_Text", "Sold_Text_Toggle", "Sold_Text", "Support_Text_Toggle")
	returnArray.MESSAGES_KeysArray := Object()
	returnArray.MESSAGES_KeysArray.Insert(0, "Wait_Text_Toggle", "Wait_Text", "Invite_Text_Toggle", "Invite_Text", "Thanks_Text_Toggle", "Thanks_Text", "Sold_Text_Toggle", "Sold_Text", "Support_Text_Toggle")
	returnArray.MESSAGES_DefaultValues := Object()
	returnArray.MESSAGES_DefaultValues.Insert(0, "1", "@%buyerName% One moment please! (%itemName% // %itemPrice%)", "1", "@%buyerName% Your item is ready to be picked up at my hideout! (%itemName% // %itemPrice%)", "1", "@%buyerName% Thank you, good luck & have fun!", "1", "@%buyerName% The requested item was sold! (%itemName% // %itemPrice%)", "0")

	returnArray.HOTKEYS_ADVANCED_HandlersArray := Object()
	returnArray.HOTKEYS_ADVANCED_HandlersKeysArray := Object()
	returnArray.HOTKEYS_ADVANCED_KeysArray := Object()
	returnArray.HOTKEYS_ADVANCED_DefaultValues := Object()
	keyID := 0
	Loop 16 {
		index := A_Index
		returnArray.HOTKEYS_ADVANCED_HandlersArray.Insert(keyID, "HotkeyAdvanced" index "_Toggle", "HotkeyAdvanced" index "_Text", "HotkeyAdvanced" index "_KEY")
		returnArray.HOTKEYS_ADVANCED_HandlersKeysArray.Insert(keyID, "HK" index "_ADV_Toggle", "HK" index "_ADV_Text", "HK" index "_ADV_KEY")
		returnArray.HOTKEYS_ADVANCED_KeysArray.Insert(keyID, "HK" index "_ADV_Toggle", "HK" index "_ADV_Text", "HK" index "_ADV_KEY")
		hkToggle := (index=1)?(1) : (0)
		hkTxtCmd := (index=1)?("{Enter}/hideout{Enter}") : (index=2)?("{Enter}/kick YourCharacter{Enter}{Enter}/kick YourOtherCharacter{Enter}") : (index=3)?("{Enter}/oos{Enter}") : ("")
		hkKeyCmd := (index=1)?("F2") : ("")
		returnArray.HOTKEYS_ADVANCED_DefaultValues.Insert(keyID, hkToggle, hkTxtCmd, hkKeyCmd)
		keyID+=3
	}

	returnArray.TRADES_GUI_HandlersArray := Object()
	returnArray.TRADES_GUI_HandlersKeysArray := Object()
	returnArray.TRADES_GUI_KeysArray := Object()
	returnArray.TRADES_GUI_DefaultValues := Object()
	keyID := 0
	keyID2 := 0
	Loop 9 {
		index := A_Index
		returnArray.TRADES_GUI_HandlersArray.Insert(keyID, "TradesBtn" index, "TradesHPOS" index, "TradesVPOS" index, "TradesSIZE" index, "TradesLabel" index, "TradesMsg" index, "TradesAction" index)
		returnArray.TRADES_GUI_HandlersKeysArray.Insert(keyID, "Button" index "_Label", "Button" index "_H", "Button" index "_V", "Button" index "_SIZE", "Button" index "_Label", "Button" index "_Message", "Button" index "_Action")
		returnArray.TRADES_GUI_KeysArray.Insert(keyID2, "Button" index "_Label", "Button" index "_Action","Button" index "_Message", "Button" index "_H", "Button" index "_V", "Button" index "_SIZE")
		btnLabel := (index=1)?("Clipboard Item"):(index=2)?("Ask to Wait"):(index=3)?("Party Invite"):(index=4)?("Thank You"):(index=5)?("Sold It"):(index=6)?("Still Interested?"):(index=7)?("Trade Request"):("[Undefined]")
		btnAction := (index=1)?("Clipboard Item"):(index=2)?("Message (Basic)"):(index=3)?("Message (Advanced)"):(index=4)?("Message (Advanced) + Close Tab"):(index=5)?("Message (Basic) + Close Tab"):(index=6)?("Message (Basic)"):(index=7)?("Message (Basic)"):("")
		btnMsg := (index=1)?(""):(index=2)?("@%buyerName% One moment please! (%itemName% // %itemPrice%)"):(index=3)?("{Enter}/invite %buyerName%{Enter}{Enter}@%buyerName% Your item is ready to be picked up at my hideout! (%itemName% // %itemPrice%){Enter}"):(index=4)?("{Enter}/kick %buyerName%{Enter}{Enter}@%buyerName% Thank you, good luck & have fun!{Enter}"):(index=5)?("@%buyerName% The requested item was sold! (%itemName% // %itemPrice%)"):(index=6)?("@%buyerName% Still interested in the item? (%itemName% // %itemPrice%)"):(index=7)?("/tradewith %buyerName%"):("")
		btnH := (index=1)?("Left"):(index=2)?("Center"):(index=3)?("Right"):(index=4)?("Left"):(index=5)?("Right"):(index=6)?:("")
		btnV := (index=1)?("Top"):(index=2)?("Top"):(index=3)?("Top"):(index=4)?("Middle"):(index=5)?("Middle"):(index=6)?:("")
		btnSIZE := (index=1)?("Small"):(index=2)?("Small"):(index=3)?("Small"):(index=4)?("Medium"):(index=5)?("Small"):("Disabled")
		returnArray.TRADES_GUI_DefaultValues.Insert(keyID2, btnLabel, btnAction, btnMsg, btnH, btnV, btnSIZE)
		keyID += 6
		keyID2 += 6
	}
	
	return returnArray
}

Get_Control_ToolTip(controlName) {
;			Retrieves the tooltip for the corresponding control
;			Return a variable conaining the tooltip content
	global ProgramValues

	programName := ProgramValues["Name"]

	ShowInGame_TT := ShowAlways_TT := "Decide when should the GUI show."
	. "`nAlways show:" A_Tab . A_Tab "The GUI will always appear."
	. "`nOnly show while in game:" A_Tab "The GUI will only appear when the game's window is active."

	ClickThrough_TT := "Clicks will go through the Trades GUI whil it is inactive,"
	. "`nallowing you to click the windows beneath it."
	ShowTransparency_TT := "Transparency of the GUI when no trade is on queue."
	. "`nSetting the value to 0% will effectively make the GUI invisible."
	. "`nWhile moving the slider, you can see a preview of the result."
	. "`nUpon releasing the slider, it will revert back to its default transparency based on if it's active or inactive."
	ShowTransparencyActive_TT := "Transparency of the GUI when trades are on queue."
	. "`nThe minimal value is set to 30% to make sure you can still see the window."
	. "`nWhile moving the slider, you can see a preview of the result."
	. "`nUpon releasing the slider, it will revert back to its default transparency based on if it's active or inactive."

	SelectLastTab_TT := "Always focus the new tab upon receiving a new trade whisper."
	. "`nIf disabled, it will stay on the current tab instead."

	AutoMinimize_TT := "Automatically minimize the Trades GUI when no trades are on queue."
	AutoUnMinimize_TT := "Automatically un-minimize the Trades GUI upon receiving a trade whisper."
	
	DockSteam_TT := DockGGG_TT := "Mostly used when running two instancies, one being your shop and the other your main account"
	. "`nIf you run only one instancie of the game, make sure that both settings are set to the same PoE executable."
	. "`nWhen the window is not found, it will default on the top right of your primary monitor"
	. "`n"
	. "`nDecide on which window should the GUI dock to."
	. "`nGGG:" A_Tab "Dock the GUI to GGG'executable."
	. "`nSteam:" A_Tab "Dock the GUI to Steam's executable."
	
	LogsSteam_TT := LogsGGG_TT := "Mostly used when running two instancies, one being your shop and the other your main account"
	. "`nIf you run only one instancie of the game, make sure that both settings are set to the same PoE executable."
	. "`n"
	. "`nDecide which log file should be read."
	. "`nGGG:" A_Tab "Dock the GUI to GGG'executable."
	. "`nSteam:" A_Tab "Dock the GUI to Steam's executable."
	
	NotifyTradeBrowse_TT := NotifyTradeSound_TT := NotifyTradeToggle_TT := "Play a sound when you receive a trade message."
	. "`nTick the case to enable."
	. "`nClick on [Browse] to select a sound file."
	
	NotifyWhisperBrowse_TT := NotifyWhisperSound_TT := NotifyWhisperToggle_TT := "Play a sound when you receive a whisper message."
	. "`nTick the case to enable."
	. "`nClick on [Browse] to select a sound file."
	
	NotifyWhisperTray_TT := "Show a tray notification when you receive"
	. "`na whisper while the game window is not active."

	NotifyWhisperFlash_TT := "Make the game's window flash when you receive"
	. "`na whisper while the game window is not active."
	
	ClipTab_TT := ClipNew_TT := ClipNew_TT := "Automatically put an item's infos in clipboard"
	. "`nso you can easily ctrl+f ctrl+v in your stash to search for the item."
	. "`n"
	. "`nClipboard new items:" A_Tab . A_Tab "New trade item will be placed in clipboard."
	. "`nClipboard item on tab switch:" A_Tab "Active tab's item will be placed on clipboard."

	MessageSupportToggle_TT := ":)", MessageSupportToggleText_TT := "(:"
	
	HelpBtn2_TT := HelpBtn_TT := "Hover controls to get infos about their function."
	ApplyBtn3_TT := ApplyBtn2_TT := ApplyBtn_TT := "Do not forget that the game needs to be in ""Windowed"" or ""Windowed Fullscreen"" for the Trades GUI to work!"
		
	MessageSoldToggle_TT := MessageSold_TT := MessageWaitToggle_TT := MessageInvite_TT := MessageInviteToggle_TT := MessageThanks_TT := MessageThanksToggle_TT := MessageWait_TT := "Message that will be sent upon clicking the corresponding button."
	. "`nTick the case to enable."
	. "`nIf you wish to reset the message to default, delete its content and reload " programName "."

		
	Hotkey1_Toggle_TT := "Tick the case to enable this hotkey."
	Hotkey1_Text_TT := "Message that will be sent upon pressing this hotkey."
	Hotkey1_KEY_TT := "Hotkey to trigger this custom command/message."
	Hotkey1_CTRL_TT := "Enable CTRL as a modifier for this hotkey."
	Hotkey1_ALT_TT := "Enable ALT as a modifier for this hotkey."
	Hotkey1_SHIFT_TT := "Enable SHIFT as a modifier for this hotkey."
	Hotkey6_Toggle_TT := Hotkey5_Toggle_TT := Hotkey4_Toggle_TT := Hotkey3_Toggle_TT := Hotkey2_Toggle_TT := Hotkey1_Toggle_TT
	Hotkey6_Text_TT := Hotkey5_Text_TT := Hotkey4_Text_TT := Hotkey3_Text_TT := Hotkey2_Text_TT := Hotkey1_Text_TT
	Hotkey6_KEY_TT := Hotkey5_KEY_TT := Hotkey4_KEY_TT := Hotkey3_KEY_TT := Hotkey2_KEY_TT := Hotkey1_KEY_TT
	Hotkey6_CTRL_TT := Hotkey5_CTRL_TT := Hotkey4_CTRL_TT := Hotkey3_CTRL_TT := Hotkey2_CTRL_TT := Hotkey1_CTRL_TT
	Hotkey6_ALT_TT := Hotkey5_ALT_TT := Hotkey4_ALT_TT := Hotkey3_ALT_TT := Hotkey2_ALT_TT := Hotkey1_ALT_TT
	Hotkey6_SHIFT_TT := Hotkey5_SHIFT_TT := Hotkey4_SHIFT_TT := Hotkey3_SHIFT_TT := Hotkey2_SHIFT_TT := Hotkey1_SHIFT_TT

	TradesHPOS1_TT := "Horizontal position of the button."
	. "`nLeft:" A_Tab . A_Tab "The button will be positioned on the left side."
	. "`nCenter:" A_Tab . A_Tab "The button will be positioned on the center."
	. "`nRight:" A_Tab . A_Tab "The button will be positioned on the right side."
	TradesVPOS1_TT := "Vertical position of the button."
	. "`nTop:" A_Tab . A_Tab "The button will be positioned on the top row."
	. "`nCenter:" A_Tab . A_Tab "The button will be positioned on the middle row."
	. "`nBottom:" A_Tab . A_Tab "The button will be positioned on the bottom row."
	TradesSIZE1_TT := "Size of the button."
	. "`nDisabled:" A_Tab "The button will not appear."
	. "`nSmall:" A_Tab . A_Tab "The button will take one third of the row."
	. "`nMedium:" A_Tab "The button will take two third of the row."
	. "`nLarge:" A_Tab . A_Tab "The button will take the whole row."
	TradesLabel1_TT := "Label of the button."
	TradesAction1_TT := "Action that will be triggered upon clicking the button."
	. "`nClipboard Item:" A_Tab . A_Tab "Will put the current tab's item into the clipboard."
	. "`nMessage (Basic):" A_Tab . A_Tab "Will send a single message."
	. "`nMessage (Advanced):" A_Tab "Can send multiple messages."
	. "`nClose Tab:" A_Tab . A_Tab "Will close the tab upon clicking the button."
	TradesHPOS9_TT := TradesHPOS8_TT := TradesHPOS7_TT := TradesHPOS6_TT := TradesHPOS5_TT := TradesHPOS4_TT := TradesHPOS3_TT := TradesHPOS2_TT := TradesHPOS1_TT
	TradesVPOS9_TT := TradesVPOS8_TT := TradesVPOS7_TT := TradesVPOS6_TT := TradesVPOS5_TT := TradesVPOS4_TT := TradesVPOS3_TT := TradesVPOS2_TT := TradesVPOS1_TT
	TradesSIZE9_TT := TradesSIZE8_TT := TradesSIZE7_TT := TradesSIZE6_TT := TradesSIZE5_TT := TradesSIZE4_TT := TradesSIZE3_TT := TradesSIZE2_TT := TradesSIZE1_TT
	TradesLabel9_TT := TradesLabel8_TT := TradesLabel7_TT := TradesLabel6_TT := TradesLabel5_TT := TradesLabel4_TT := TradesLabel3_TT := TradesLabel2_TT := TradesLabel1_TT
	TradesAction9_TT := TradesAction8_TT := TradesAction7_TT := TradesAction6_TT := TradesAction5_TT := TradesAction4_TT := TradesAction3_TT := TradesAction2_TT := TradesAction1_TT

	Preview_TT := "Show a preview of the TradesGUI."
	. "`nNote: The button's function are disabled in preview mode."
	. "`nYou will need to reload the script to take the new buttons in count!"
	
	try
		controlTip := % %controlName%_TT
;	if ( controlTip ) 
;		return controlTip
;	else 
;		controlTip := controlName ; Used to get the control tooltip
	return controlTip
}

;==================================================================================================================
;
;												UPDATE GUI
;
;==================================================================================================================

Check_Update() {
;			It works by downloading both the new version and the auto-updater
;			then closing the current instancie and renaming the new version
	static
	global ProgramValues

	programVersion := ProgramValues["Version"], programFolder := ProgramValues["Local_Folder"], programChangelogsFilePath := ProgramValues["Changelogs_File"]
	
	updaterPath := "poe_trades_helper_updater.exe"
	updaterDL := "https://raw.githubusercontent.com/lemasato/POE-Trades-Helper/master/Updater.exe"
	versionDL := "https://raw.githubusercontent.com/lemasato/POE-Trades-Helper/master/version.txt"
	changelogDL := "https://raw.githubusercontent.com/lemasato/POE-Trades-Helper/master/changelogs.txt"
	
;	Delete files remaining from updating
	if (FileExist(updaterPath))
		FileDelete,% updaterPath
	if (FileExist("poe_trades_helper_newversion.exe"))
		FileDelete,% "poe_trades_helper_newversion.exe"
	
;	Retrieve the changelog file and update the local file if required
	ComObjError(0)
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", changelogDL, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to r'emain responsive.
	whr.WaitForResponse(10) ; 10 seconds
	changelogText := whr.ResponseText
	changelogText = %changelogText%
	if ( changelogText != "" ) && !(RegExMatch(changelogText, "NotFound")) && !(RegExMatch(changelogText, "404: Not Found")) {
		FileRead, changelogLocal,% programChangelogsFilePath
		if ( changelogLocal != changelogText ) {
			FileDelete, % programChangelogsFilePath
			UrlDownloadToFile, % changelogDL,% programChangelogsFilePath
		}
	}
	
;	Retrieve the version number
	ComObjError(0)
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", versionDL, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse(10) ; 10 seconds
	versionNumber := whr.ResponseText
	if ( versionNumber != "" ) && !(RegExMatch(versionNumber, "NotFound")) && !(RegExMatch(versionNumber, "404: Not Found")) {
		newVersion := versionNumber
		StringReplace, newVersion, newVersion, `n,,1 ; remove the 2nd white line
		newVersion = %newVersion% ; remove any whitespace
	}
	else
		newVersion := programVersion ; couldn't reach the file, cancel update
	if ( programVersion != newVersion )
		Gui_Update(newVersion, updaterPath, updaterDL)
}

Gui_Update(newVersion, updaterPath, updaterDL) {
	static
	global ProgramValues

	iniFilePath := ProgramValues["Ini_File"], programName := ProgramValues["Name"], programPID := ProgramValues["PID"]

	IniRead, auto,% iniFilePath,PROGRAM,AutoUpdate
	if ( auto = 1 ) {
		GoSub Gui_Update_Accept
		return
	}
	Gui, Update:Destroy
	Gui, Update:New, +AlwaysOnTop +SysMenu -MinimizeBox -MaximizeBox +OwnDialogs +HwndUpdateGuiHwnd,% "Update! v" newVersion " - " programName
	Gui, Update:Default
	Gui, Add, Text, x70 y10 ,Would you like to update now?
	Gui, Add, Text, x10 y30,The process is automatic, only your permission is required.
	Gui, Add, Button, x10 y55 w135 h35 gGui_Update_Accept,Accept
	Gui, Add, Button, x145 y55 w135 h35 gGui_Update_Refuse,Refuse
	Gui, Add, Button, x10 y95 w270 h40 gGui_Update_Open_Page,Open the download page ; Open download page
	Gui, Add, CheckBox, x10 y150 vautoUpdate,Update automatically from now ; Update automatically...
	Gui, Show
	WinWait, ahk_id %UpdateGuiHwnd%
	WinWaitClose, ahk_id %UpdateGuiHwnd%
	return
	
	Gui_Update_Accept:
;		Downlaod the updater that will handle the updating process
		Gui, Submit
		if ( autoUpdate )
			IniWrite, 1,% iniFilePath,PROGRAM,AutoUpdate
		IniWrite,% A_ScriptName,% iniFilePath,PROGRAM,FileName
		UrlDownloadToFile,% updaterDL,% updaterPath
		sleep 1000
		Run, % updaterPath
		Process, close, %programPID%
		OnExit("Exit_Func", 0)
		ExitApp
	return
	
	Gui_Update_Refuse:
		Gui, Submit
		if ( autoUpdate )
			IniWrite, 1,% iniFilePath,PROGRAM,AutoUpdate
	return

	Gui_Update_Open_Page:
		Gui, Submit
		Run, % "https://github.com/lemasato/POE-Trades-Helper/releases"
	return
}

;==================================================================================================================
;
;												ABOUT GUI
;
;==================================================================================================================

Gui_About() {
	static
	global ProgramValues

	programChangelogsFilePath := ProgramValues["Changelogs_File"]
	iniFilePath := ProgramValues["Ini_File"], programName := ProgramValues["Name"], programVersion := ProgramValues["Version"]

	aeroStatus := Get_Aero_Status()
	themeState := (aeroStatus=1)?("+Theme -0x8000"):("-Theme +0x8000")

	Gui, About:Destroy
	Gui, About:New, +HwndaboutGuiHandler +AlwaysOnTop +SysMenu -MinimizeBox -MaximizeBox +OwnDialogs,% programName " by lemasato v" programVersion
	Gui, About:Default

	Gui, Add, Tab3,x10 y10 vTab hwndTabHandler h190 w425 %themeState%,About|Changelogs
	Gui, Tab, 1
		Gui, Add, Text, x20 y40 ,Hello, thank you for using %programName%!
		Gui, Add, Text, xp yp+15 h50,It allows you to keep at sight your trade requests!
		Gui, Add, Text, xp yp+20 h50,Upon receiving a typical whisper from poe.trade, a new tab will appear containing:
		Gui, Add, Text, xp yp+15 ,The buyer's name, the item, the price listed, and the league/stash tab.
		Gui, Add, Text, xp yp+15 ,Several buttons will let you invite/message the person.
		Gui, Add, Text, xp yp+20,If you would like to change your preferences, head over the [Settings] tray menu.
		Gui, Add, Text, xp yp+30,See on:
		Gui, Add, Link, gGitHub_Link xp yp+15,% "<a href="""">GitHub</a> - "
		Gui, Add, Link, gReddit_Link xp+45 yp,% "<a href="""">Reddit</a> - "
		Gui, Add, Link, gGGG_Link xp+45 yp,% "<a href="""">GGG</a>"

	Gui, Tab, 2
		FileRead, changelogText,% programChangelogsFilePath
		allChanges := Object()
		allVersions := ""
		Loop {
			if RegExMatch(changelogText, "sm)\\\\.*?--(.*?)--(.*?)//(.*)", subPat) {
				version%A_Index% := subPat1, changes%A_Index% := subPat2, changelogText := subPat3
				StringReplace, changes%A_Index%, changes%A_Index%,`n,% "",0
				
				allVersions .= version%A_Index% "|"
				allChanges.Insert(changes%A_Index%)
			}
		else
			break
		}
		Gui, Add, DropDownList, gVersion_Change AltSubmit vVerNum hwndVerNumHandler,%allVersions%
		Gui, Add, Edit, vChangesText hwndChangesTextHandler w395 R9 ReadOnly,An internet connection is required
		GuiControl, Choose,%VerNumHandler%,1
		GoSub, Version_Change
	Gui, Show, AutoSize
	
	IniRead, state,% iniFilePath,PROGRAM,Show_Changelogs
	if ( state = 1 ) {
		GuiControl,About:Choose,%tabHandler%,2
		IniWrite, 0,% iniFilePath,PROGRAM,Show_Changelogs
	}
	return
	
	Version_Change:
		Gui, Submit, NoHide
		GuiControl, ,%ChangesTextHandler%,% allChanges[verNum]
		Gui, Show, AutoSize
	return

	Reddit_Link:
		Run,% ProgramValues["Reddit"]
	Return

	Github_Link:
		Run,% ProgramValues["GitHub"]
	Return

	GGG_Link:
		Run,% ProgramValues["GGG"]
	Return
}

;==================================================================================================================
;
;											INI SETTINGS
;
;==================================================================================================================

Get_INI_Settings() {
;			Retrieve the INI settings
;			Return a big array containing arrays for each section containing the keys and their values
	global ProgramValues

	iniFilePath := ProgramValues["Ini_File"]
	
	returnArray := Object()
	returnArray := Gui_Settings_Get_Settings_Arrays()
	
	sectionArray := returnArray.sectionArray
	SETTINGS_KeysArray := returnArray.SETTINGS_KeysArray
	AUTO_CLIP_KeysArray := returnArray.AUTO_CLIP_KeysArray
	HOTKEYS_KeysArray := returnArray.HOTKEYS_KeysArray
	NOTIFICATIONS_KeysArray := returnArray.NOTIFICATIONS_KeysArray
	MESSAGES_KeysArray := returnArray.MESSAGES_KeysArray
	HOTKEYS_ADVANCED_KeysArray := returnArray.HOTKEYS_ADVANCED_KeysArray
	TRADES_GUI_KeysArray := returnArray.TRADES_GUI_KeysArray
	
	returnArray.KEYS := Object()
	returnArray.VALUES := Object()
	for key, element in sectionArray
	{
		sectionName := element
		for key, element in %sectionName%_KeysArray
		{
			keyName := element
			IniRead, var,% iniFilePath,% sectionName,% keyName
			returnArray.KEYS.Insert(keyName)
			returnArray.VALUES.Insert(var)
		}
	}
	return returnArray
} 

Set_INI_Settings(){
;			Set the default INI settings if they do not exist
	global ProgramValues

	iniFilePath := ProgramValues["Ini_File"], programPID := ProgramValues["PID"]

;	Set the PID and filename, used for the auto updater
	IniWrite,% programPID,% iniFilePath,PROGRAM,PID
	IniWrite,% A_ScriptName,% iniFilePath,PROGRAM,FileName
	IniWrite, 10,% iniFilePath,PROGRAM,Rendered_Tabs

	HiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows On
	WinGet, fileProcessName, ProcessName, ahk_pid %programPID%
	IniWrite,% fileProcessName,% iniFilePath,PROGRAM,FileProcessName
	DetectHiddenWindows, %HiddenWindows%

	IniRead, showLogs,% iniFilePath,PROGRAM,Show_Changelogs
	if ( showLogs != 0 && showLogs != 1 )
		IniWrite, 0,% iniFilePath,PROGRAM,Show_Changelogs
	
;	Retrieve the settings arrays
	settingsArray := Gui_Settings_Get_Settings_Arrays()
	sectionArray := settingsArray.sectionArray
	SETTINGS_KeysArray := settingsArray.SETTINGS_KeysArray
	SETTINGS_DefaultValues := settingsArray.SETTINGS_DefaultValues
	AUTO_CLIP_KeysArray := settingsArray.AUTO_CLIP_KeysArray
	AUTO_CLIP_DefaultValues := settingsArray.AUTO_CLIP_DefaultValues
	HOTKEYS_KeysArray := settingsArray.HOTKEYS_KeysArray
	HOTKEYS_DefaultValues := settingsArray.HOTKEYS_DefaultValues
	NOTIFICATIONS_KeysArray := settingsArray.NOTIFICATIONS_KeysArray
	NOTIFICATIONS_DefaultValues := settingsArray.NOTIFICATIONS_DefaultValues
	MESSAGES_KeysArray := settingsArray.MESSAGES_KeysArray
	MESSAGES_DefaultValues := settingsArray.MESSAGES_DefaultValues	
	HOTKEYS_ADVANCED_KeysArray := settingsArray.HOTKEYS_ADVANCED_KeysArray
	HOTKEYS_ADVANCED_DefaultValues := settingsArray.HOTKEYS_ADVANCED_DefaultValues
	TRADES_GUI_KeysArray := settingsArray.TRADES_GUI_KeysArray
	TRADES_GUI_DefaultValues := settingsArray.TRADES_GUI_DefaultValues
;	Set the value for each key
	for key, element in sectionArray
	{
		sectionName := element
		for key, element in %sectionName%_KeysArray
		{
			keyName := element
			value := %sectionName%_DefaultValues[key]
			IniRead, var,% iniFilePath,% sectionName,% keyName
			if ( var = "ERROR" || var = "" ) {
				IniWrite,% value,% iniFilePath,% sectionName,% keyName
			}
		}
	}
}

Declare_INI_Settings(iniArray) {
;			Declare the settings to global variables
	global GlobalValues

	for key, element in iniArray.KEYS {
		value := iniArray.VALUES[key]
		GlobalValues.Insert(element, value) ;access value using: GlobalValues["element"]
	}
}

;==================================================================================================================
;
;												HOTKEYS
;
;==================================================================================================================

Disable_Hotkeys() {
;	Disable the current hotkeys
;	Always run Enable_Hotkeys() after to retrieve and assign the new hotkeys
	global GlobalValues

	titleMatchMode := A_TitleMatchMode
	SetTitleMatchMode, RegEx

	Loop 6 {
	index := A_Index
	if ( GlobalValues["HK" index "_Toggle"] ) {
			userHotkey%index% := GlobalValues["HK" index "_KEY"]
		if ( GlobalValues["HK" index "_CTRL"] )
			userHotkey%index% := "^" userHotkey%index%
		if ( GlobalValues["HK" index "_ALT"] )
			userHotkey%index% := "!" userHotkey%index%
		if ( GlobalValues["HK" index "_SHIFT"] )
			userHotkey%index% := "+" userHotkey%index%
			Hotkey,IfWinActive,ahk_group POEGame
			if ( userHotkey%index% != "" && userHotkey%index% != "ERROR" ) {
				try {
					Hotkey,% userHotkey%index%,Off
				}
			}
		}
	}
	Loop 16 {
		index := A_Index
		if ( GlobalValues["HK" index "_ADV_Toggle"] ) {
			userHotkey%index% := GlobalValues["HK" index "_ADV_KEY"]
			Hotkey,IfWinActive,ahk_group POEGame
			if ( userHotkey%index% != "" && userHotkey%indzex% != "ERROR" ) {
				try {
					Hotkey,% userHotkey%index%,Off
				}
			}
		}
	}		
	SetTitleMatchMode, %titleMatchMode%	
}

Enable_Hotkeys() {
;	Enable the hotkeys, based on its global VALUE_ content
	global GlobalValues, ProgramValues

	programName := ProgramValues["Name"], iniFilePath := ProgramValues["Ini_File"]

	titleMatchMode := A_TitleMatchMode
	SetTitleMatchMode, RegEx

	if ( GlobalValues["Hotkeys_Mode"] = "Advanced" ) {
		Loop 16 {
			index := A_Index
			if ( GlobalValues["HK" index "_ADV_Toggle"] ) {
				userHotkey%index% := GlobalValues["HK" index "_ADV_KEY"]
				Hotkey,IfWinActive,ahk_group POEGame
				if ( userHotkey%index% != "" && userHotkey%index% != "ERROR" ) {
					try	
						Hotkey,% userHotkey%index%,Hotkeys_User_%index%,On
					catch {
						IniWrite,0,% iniFilePath,HOTKEYS_ADVANCED,% "HK" index "_ADV_Toggle"
						MsgBox, 4096,% programName,% "The following Hotkey is invalid: " userHotkey%index%
						. "`n`nThe Hotkey will be disabled."
						. "`nPlease refer to the WIKI."
					}
				}
			}
		}		
	}
	else {
		Loop 6 {
			index := A_Index
			if ( GlobalValues["HK" index "_Toggle"] ) {
				userHotkey%index% := GlobalValues["HK" index "_KEY"]
				if ( GlobalValues["HK" index "_CTRL"] )
					userHotkey%index% := "^" userHotkey%index%
				if ( GlobalValues["HK" index "_ALT"] )
					userHotkey%index% := "!" userHotkey%index%
				if ( GlobalValues["HK" index "_SHIFT"] )
					userHotkey%index% := "+" userHotkey%index%
				Hotkey,IfWinActive,ahk_group POEGame
				if ( userHotkey%index% != "" && userHotkey%index% != "ERROR" ) {
					Hotkey,% userHotkey%index%,Hotkeys_User_%index%,On
				}
			}
		}
	}
	SetTitleMatchMode, %titleMatchMode%
}

;==================================================================================================================
;
;												OTHERS GUI
;
;==================================================================================================================

GUI_Replace_PID(handlersArray, gamePIDArray) {
;		GUI used when clicking one of the Trades GUI buttons and the PID is not associated with POE anymore
;		Provided two array containing all the POE handlers and PID, it allows the user to choose which PID to use as a replacement
	static
	global ProgramValues

	programName := ProgramValues["Name"]

	Gui, ReplacePID:Destroy
	Gui, ReplacePID:New, +ToolWindow +AlwaysOnTop -SysMenu +hwndGUIInstancesHandler
	Gui, ReplacePID:Add, Text, x10 y10,% "The previous PID is no longer associated to a POE instance."
	Gui, ReplacePID:Add, Text, x10 y25,% "Please, select the new one you would like to use!"
	ypos := 30
	for key, element in handlersArray {
		index := A_Index - 1
		Gui, Add, Text, x10 yp+30,Executable:
		WinGet, pName, ProcessName,ahk_id %element%
		Gui, Add, Edit, xp+55 yp-3 ReadOnly w150,% pName
		Gui, Add, Button,xp+155 yp-2 gGUI_Replace_PID_Continue vContinue%index%,Continue with this one
		Gui, Add, Text, x10 yp+32,Path:
		WinGet, pPath, ProcessPath,ahk_id %element%
		Gui, Add, Edit, xp+55 yp-3 ReadOnly,% pPath
		if ( index != handlersArray.MaxIndex() ) ; Put a 10px margin if it's not the last element
			Gui, Add, Text, w0 h0 xp yp+10
		Logs_Append(A_ThisFunc,,element,pPath)
	}
	Gui, ReplacePID:Show,NoActivate,% programName " - Replace PID"
	WinWait, ahk_id %GUIInstancesHandler%
	WinWaitClose, ahk_id %GUIInstancesHandler%
	return r

	GUI_Replace_PID_Continue:
		btnID := RegExReplace(A_GuiControl, "\D")
		r := gamePIDArray[btnID]
		Gui, ReplacePID:Destroy
		Logs_Append("GUI_Replace_PID_Return",,r)
	Return
}

GUI_Multiple_Instances(handlersArray) {
;		GUI used when multiple instances of POE running in different folders have been found upon running the Monitor_Logs() function
;		Provided an array containing all the POE handlers, it allows the user to choose which logs file to monitor
	static
	global ProgramValues

	programName := ProgramValues["Name"]

	Gui, Instances:Destroy
	Gui, Instances:New, +ToolWindow +AlwaysOnTop -SysMenu +hwndGUIInstancesHandler
	Gui, Instances:Add, Text, x10 y10,% "Detected instances are using different logs file."
	Gui, Instances:Add, Text, x10 y25,% "Please, select the one you would like to use!"
	ypos := 30
	for key, element in handlersArray {
		index := A_Index - 1
		Gui, Add, Text, x10 yp+30,Executable:
		WinGet, pName, ProcessName,ahk_id %element%
		Gui, Add, Edit, xp+55 yp-3 ReadOnly w150,% pName
		Gui, Add, Button,xp+155 yp-2 gGUI_Multiple_Instances_Continue vContinue%index%,Continue with this one
		Gui, Add, Text, x10 yp+32,Path:
		WinGet, pPath, ProcessPath,ahk_id %element%
		Gui, Add, Edit, xp+55 yp-3 ReadOnly,% pPath
		if ( index != handlersArray.MaxIndex() ) ; Put a 10px margin if it's not the last element
			Gui, Add, Text, w0 h0 xp yp+10
		Logs_Append(A_ThisFunc,,element,pPath)
	}
	Gui, Instances:Show,NoActivate,% programName " - Multiple instances found"
	WinWait, ahk_id %GUIInstancesHandler%
	WinWaitClose, ahk_id %GUIInstancesHandler%
	return r

	GUI_Multiple_Instances_Continue:
		btnID := RegExReplace(A_GuiControl, "\D")
		r := handlersArray[btnID]
		Gui, Instances:Destroy
		Logs_Append("GUI_Multiple_Instances_Return",,r)
	Return
}

;==================================================================================================================
;
;												WM_MESSAGES
;
;==================================================================================================================

Set_Mouse_Leave_Tracking(hwnd) {
/*			Allows to use WM_MouseLeave (0x2A3) with GUI that do not have a border.
 *			Credits: RHCP - autohotkey.com/board/topic/120763-wm-mousemove-how/?p=685998
 *
 *			Requires: 	Existing functions: WM_MOUSEMOVE(wParam, lParam, msg, hwnd)
 *											WM_MOUSELEAVE(wParam, lParam, msg, hwnd)
 *						A global variable shared between these two
 *
 *			Usage:		Inside WM_MOUSEMOVE: if !VALUE_Mouse_Tracking
 *											 VALUE_Mouse_Tracking := Set_Mouse_Leave_Tracking(hwnd)
 *
*/
	static v
	if !v
	{
		VarSetCapacity(v, size := A_Ptrsize = 8 ? 24 : 16, 0)
		NumPut(size, v, 0, "UInt")            ; cbSize
		NumPut(0x00000002, v, 4, "UInt")    ; dwFlags (TME_LEAVE)
		NumPut(hwnd, v, 8, "Ptr")          ; HWND
		NumPut(0, v, A_Ptrsize = 8 ? 16 : 12, "UInt")            ; dwHoverTime (ignored) 
	}
	return  DllCall("TrackMouseEvent", "Ptr", &v) ; Non-zero on success
}

WM_LBUTTONDBLCLK(wParam, lParam, msg, hwnd) {
/*			Blocks the default behaviour of placing in clipboard
 *				when double-clicking a static (text) control
 *
 *			Usage: 	OnMessage(0x203, "WM_LBUTTONDBLCLK") - Enabled
 *					OnMessage(0x203, "WM_LBUTTONDBLCLK", 0) - Disabled
 *
 *			Credits: Lexikos
 *			autohotkey.com/board/topic/94962-doubleclick-on-gui-pictures-puts-their-path-in-your-clipboard/?p=682595
*/
	WinGetClass class, ahk_id %hwnd%
	if (class = "Static") {
		if !A_Gui
			return 0  ; Just prevent Clipboard change.
		; Send a WM_COMMAND message to the Gui to trigger the control's g-label.
		Gui +LastFound
		id := DllCall("GetDlgCtrlID", "ptr", hwnd) ; Requires AutoHotkey v1.1.
		static STN_DBLCLK := 1
		PostMessage 0x111, id | (STN_DBLCLK << 16), hwnd
		if GetKeyState("LButton") ; LButton down
			WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
		; Return a value to prevent the default handling of this message.
		return 0
	}

}

WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
	static
	global GlobalValues, ProgramValues, TradesGUI_Controls
	global guiTradesHandler

	programSkinFolderPath := ProgramValues["Skins_Folder"]

	lastButton := GlobalValues["TradesGUI_Last_Hover_Button"]
	lastPngFilePrefix := GlobalValues["TradesGUI_Last_PNG"]
	RegExMatch(A_GuiControl, "\D+", btnType)
	RegExMatch(A_GuiControl, "\d+", btnID)

	; if (A_GUI) {
	; 	sleep 10
	; 	if !VALUE_Mouse_Tracking {
	; 		VALUE_TradesGUI_Last_Hover_Control := A_GuiControl
	; 		VALUE_Mouse_Tracking := Set_Mouse_Leave_Tracking(hwnd)
	; 	}
	; }
	if (A_GUI = "Trades") {

		btnHandler := (btnType="CustomBtn")?(TradesGUI_Controls["Button_Custom_" btnID])
				     :(btntype="delBtn")?(TradesGUI_Controls["Button_Close"])
				     :(btnType="GoRight")?(TradesGUI_Controls["Arrow_Right"])
				     :(btnType="GoLeft")?(TradesGUI_Controls["Arrow_Left"])
				     :(btntype="BuyerSlot")?(TradesGUI_Controls["Buyer_Slot_" btnID])
				     :(btntype="ItemSlot")?(TradesGUI_Controls["Item_Slot_" btnID])
				     :(btntype="PriceSlot")?(TradesGUI_Controls["Price_Slot_" btnID])
				     :(btntype="LocationSlot")?(TradesGUI_Controls["Location_Slot_" btnID])
				     :(btntype="OtherSlot")?(TradesGUI_Controls["Other_Slot_" btnID])
				     :("ERROR")

		if (btnType = "CustomBtn" || btnType = "delBtn" || btnType = "GoRight" || btnType = "GoLeft") {
			if ( btnHandler != lastButton && btnHandler ) {
				; GuiControlGet, outVar, Hwnd,%A_GuiControl%
				pngFilePrefix := (btnType="CustomBtn")?("ButtonBackground"):(btnType="delBtn")?("Close"):(btnType="GoRight")?("ArrowRight"):(btnType="GoLeft")?("ArrowLeft"):("ERROR")
				; tooltip % pngFilePrefix "`n" FileExist(programSkinFolderPath "\" pngFilePrefix "Hover.png")
				if FileExist(programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Hover.png") && FileExist(programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Press.png") {
					GetKeyState, LButtonState, LButton
					if ( LButtonState = "D" && btnHandler = GlobalValues["Trades_GUI_Button_Held"] ) {
					 	GuiControl, Trades:,% btnHandler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Press.png"
					}
					else {
						GuiControl, Trades:,% btnHandler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Hover.png"
					}
					GuiControl, Trades:,% lastButton,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" lastPngFilePrefix ".png"
					lastPngFilePrefix := pngFilePrefix
					; tooltip % btnType
					; Gui, Trades:Font, c875516
					; GuiControl, Trades:Font,CustomBtnTXT%lastBtnID%
					; GuiControl, Trades:,% lastButton,% programSkinFolderPath "\" VALUE_Trades_GUI_Skin "\" lastPngFilePrefix ".png"
				}
			}

			GlobalValues.Insert("TradesGUI_Last_Hover_Button", btnHandler)
			btnState := "Hover"
		}
		else if (btnState = "Hover") {
			GuiControl, Trades:,% lastButton,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" lastPngFilePrefix ".png"
			btnState := "Default"

			; Gui, Trades:Font, c875516
			; tooltip % btnType " - " A_GuiControl " - " lastBtnID "- " VALUE_Trades_GUI_Hover_Control " - " VALUE_TradesGUI_Last_Hover_Button
			RegExMatch(GlobalValues["TradesGUI_Last_Hover_Button"], "\D+", lastbtnType)
			GlobalValues.Insert("TradesGUI_Last_Hover_Button", "")
			if (lastbtnType = "CustomBtn") {
				; GuiControl, Trades:Hide,% TradesGUI_Controls["Button_Custom_" lastBtnID]
				; GuiControl, Trades:+Redraw,CustomBtn%lastbtnID%OrnamentLeft
				; GuiControl, Trades:+Redraw,CustomBtn%lastbtnID%OrnamentRight
				; GuiControl, Trades:+Redraw,CustomBtnTXT%lastbtnID%
			}
		}
		else if (btnType = "BuyerSlot" || btnType = "ItemSlot" || btnType = "PriceSlot" || btnType = "LocationSlot" || btnType = "OtherSlot") {
			CoordMode, ToolTip, Screen
			GuiControlGet, content,Trades:,% btnHandler
			GuiControlGet, ctrlPOS,Trades:Pos,% btnHandler
			WinGetPos, tradesXPOS, tradesYPOS
			ToolTip, % content,% tradesXPOS+ctrlPOSX,% tradesYPOS+ctrlPOSY
			MouseGetPos, mouseX, mouseY
			SetTimer, ToolTipTimer, 100
		}
		else {
			ToolTip, 
		}
	}

	else if ( A_GUI = "Settings" ) {
		curControl := A_GuiControl
		If ( curControl <> prevControl ) {
			controlTip := Get_Control_ToolTip(curControl)
			if ( controlTip )
				SetTimer, Display_ToolTip, -1000
			Else
				Gosub, Remove_ToolTip
			prevControl := curControl
		}
		return
		
		Display_ToolTip:
			controlTip := Get_Control_ToolTip(curControl)
			if ( controlTip ) {
				try
					ToolTip,% controlTip
				SetTimer, Remove_ToolTip, -20000
			}
			else {
				ToolTip,
			}
		return
		
		Remove_ToolTip:
			ToolTip
		return

		ToolTipTimer:
;			Credits to POE-TradeMacro: https://github.com/PoE-TradeMacro/POE-TradeMacro
			MouseGetPos, ,CurrY
			MouseMoved := (CurrY - mouseY) ** 2 > 10 ** 2
			if (MouseMoved)	{
				SetTimer, ToolTipTimer, Off
				ToolTip 
			}
		return
	}

	; MouseGetPos, , , underMouseHandler
	; if (underMouseHandler != guiTradesHandler) {
	; 	; tooltip ok
	; 	btnType := "CustomBtn"
	; 	pngFilePrefix := (btnType="CustomBtn")?("ButtonBackground"):(btnType="delBtn")?("Close"):(btnType="GoRight")?("ArrowRight"):(btnType="GoLeft")?("ArrowLeft"):("ERROR")
	; 	; Loop 9 {
	; 		GuiControlGet, var,Trades:,CustomBtn1
	; 		tooltip % A_Index " : " var
	; 		; sleep 500
	; 		; if ( var && var != programSkinFolderPath "\" VALUE_Trades_GUI_Skin "\" pngFilePrefix ".png")
	; 		; tooltip % var
	; 		; GuiControl, Trades:,CustomBtn%A_Index%,% programSkinFolderPath "\" VALUE_Trades_GUI_Skin "\" pngFilePrefix ".png"
	; 	; }
	; }
	if (btnID)
		lastBtnID := btnID
	if (pngFilePrefix)
		GlobalValues.Insert("TradesGUI_Last_PNG", pngFilePrefix)
	if (A_GuiControl)
		GlobalValues.Insert("Trades_GUI_Hover_Control", A_GuiControl)
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	global GlobalValues, ProgramValues, TradesGUI_Controls

	programSkinFolderPath := ProgramValues["Skins_Folder"]

	RegExMatch(A_GuiControl, "\D+", btnType)
	RegExMatch(A_GuiControl, "\d+", btnID)

	if (A_GUI = "Trades") {
		btnHandler := (btnType="CustomBtn")?(TradesGUI_Controls["Button_Custom_" btnID])
				     :(btntype="delBtn")?(TradesGUI_Controls["Button_Close"])
				     :(btnType="GoRight")?(TradesGUI_Controls["Arrow_Right"])
				     :(btnType="GoLeft")?(TradesGUI_Controls["Arrow_Left"])
				     :("ERROR")

		if (btnType = "CustomBtn" || btnType = "delBtn" || btnType = "GoRight" || btnType = "GoLeft") {
			pngFilePrefix := (btnType="CustomBtn")?("ButtonBackground"):(btnType="delBtn")?("Close"):(btnType="GoRight")?("ArrowRight"):(btnType="GoLeft")?("ArrowLeft"):("ERROR")
			if FileExist(programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Hover.png") && FileExist(programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Press.png") {
				GuiControl, Trades:,% btnHandler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Press.png"
				GlobalValues.Insert("Trades_GUI_Button_Held", btnHandler)
				KeyWait, LButton, U

;				Retrieve handlers of the button's assets
				MouseGetPos, , , , underMouseHandler, 2
				if ( btnType = "CustomBtn" ) {
					GuiControlGet, ClickedBtnHandler, Trades:Hwnd,% TradesGUI_Controls["Button_Custom_" btnID]
					GuiControlGet, ClickedBtnOrnateLeftHandler, Trades:Hwnd,% TradesGUI_Controls["Button_Custom_" btnID "_OrnamentLeft"]
					GuiControlGet, ClickedBtnOrnateRightHandler, Trades:Hwnd,% TradesGUI_Controls["Button_Custom_" btnID "_OrnamentRight"]
					GuiControlGet, ClickedBtnTXTHandler, Trades:Hwnd,% TradesGUI_Controls["Button_Custom_" btnID "_Text"]
					matchsList := ClickedBtnHandler "," ClickedBtnOrnateLeftHandler "," ClickedBtnOrnateRightHandler "," ClickedBtnTXTHandler
				}
				else {
					GuiControlGet, ClickedBtnHandler, Trades:Hwnd,% btnHandler
					matchsList := ClickedBtnHandler
				}
				
				if underMouseHandler in %matchsList% ; Button still under cursor after releasing click, revert to Hover state
					GuiControl, Trades:,% btnHandler,% programSkinFolderPath "\" GlobalValues["Trades_GUI_Skin"] "\" pngFilePrefix "Hover.png"
				else ; Button not anymore under cursor, cancel the button gLabel
					GlobalValues.Insert("Trades_GUI_Button_Cancel", 1)
			}
		}
	}
}

WM_MOUSELEAVE(wParam, lParam, Msg, hwnd){
	static
	global ProgramValues, GlobalValues
	global guiTradesHandler

	programSkinFolderPath := ProgramValues["Skins_Folder"]

	; Set_Mouse_Leave_Tracking(hwnd)

	; if (A_GUI="Trades" && !VALUE_TradesGUI_Last_Hover_Control) {
	; 		MouseGetPos, , , underMouseHandler
	; 		if (underMouseHandler != guiTradesHandler) {
	; 			tooltip fuk
	; 			btnType := "CustomBtn"
	; 			pngFilePrefix := (btnType="CustomBtn")?("ButtonBackground"):(btnType="delBtn")?("Close"):(btnType="GoRight")?("ArrowRight"):(btnType="GoLeft")?("ArrowLeft"):("ERROR")
	; 			Loop 9 {
	; 				GuiControlGet, var,Trades:Font,CustomBtnTXT%A_Index%
	; 				msgbox % var
	; 				GuiControl, Trades:,CustomBtn%A_Index%,% programSkinFolderPath "\" VALUE_Trades_GUI_Skin "\" pngFilePrefix ".png"
	; 			}
	; 		}

		; GuiControl, Trades:,% VALUE_TradesGUI_Last_Hover_Control,% programSkinFolderPath "\" VALUE_Trades_GUI_Skin "\" VALUE_TradesGUI_Last_PNG ".png"
		; RegExMatch(VALUE_TradesGUI_Last_Hover_Control, "\D+", btnType)
		; if ( btnType = "CustomBtn" ) {
		; 	RegExMatch(VALUE_TradesGUI_Last_Hover_Control, "\d+", btnID)
		; 	Gui, Trades:Font, c875516
		; 	GuiControl, Trades:Font,CustomBtn%btnID%
		; 	GuiControl, Trades:+Redraw,CustomBtn%btnID%
		; 	GuiControl, Trades:+Redraw,CustomBtn%btnID%OrnamentLeft
		; 	GuiControl, Trades:+Redraw,CustomBtn%btnID%OrnamentRight
		; }
	; }
	; if (!A_GUI) {
	; 	GuiControl, Trades:,% VALUE_TradesGUI_Last_Hover_Button,% programSkinFolderPath "\" VALUE_Trades_GUI_Skin "\" VALUE_TradesGUI_Last_PNG ".png"
	; 	RegExMatch(VALUE_TradesGUI_Last_Hover_Button, "\D+", btnType)
	; 	if ( btnType = "CustomBtn" ) {
	; 		RegExMatch(VALUE_TradesGUI_Last_Hover_Button, "\d+", btnID)
	; 		Gui, Trades:Font, c875516
	; 		GuiControl, Trades:Font,CustomBtn%btnID%
	; 		GuiControl, Trades:+Redraw,CustomBtn%btnID%
	; 		GuiControl, Trades:+Redraw,CustomBtn%btnID%OrnamentLeft
	; 		GuiControl, Trades:+Redraw,CustomBtn%btnID%OrnamentRight
	; 	}
	; }

	; else {
	; 	traytip,,%A_GUI% - %VALUE_TradesGUI_Last_Hover_Control%
	; }
	; sleep 100
	GlobalValues.Insert("Mouse_Tracking", 0)
}


ShellMessage(wParam,lParam) {
/*			Triggered upon activating a window
 *			Is used to correctly position the Trades GUI while in Overlay mode
*/
	global ProgramValues, GlobalValues
	global guiTradesHandler, tradesGuiWidth, POEGameList

	programSkinFolderPath := ProgramValues["Skins_Folder"]

	if ( wParam=4 or wParam=32772 ) { ; 4=HSHELL_WINDOWACTIVATED | 32772=HSHELL_RUDEAPPACTIVATED
		if WinActive("ahk_id" guiTradesHandler) {
;		Prevent these keyboard presses from interacting with the Trades GUI
			Hotkey, IfWinActive, ahk_id %guiTradesHandler%
			Hotkey, NumpadEnter, DoNothing, 
			Hotkey, Escape, DoNothing, On
			Hotkey, Space, DoNothing, On
			Hotkey, Tab, DoNothing, On
			Hotkey, Enter, DoNothing, On
			Hotkey, Left, DoNothing, On
			Hotkey, Right, DoNothing, On
			Hotkey, Up, DoNothing, On
			Hotkey, Down, DoNothing, On
			Return ; returning prevents from triggering Gui_Trades_Set_Position while the GUI is active
		}

		WinGet, winEXE, ProcessName, ahk_id %lParam%
		WinGet, winID, ID, ahk_id %lParam%
		if ( GlobalValues["Show_Mode"] = "InGame" ) {

			if ( tradesGuiWidth > 0 ) { ; TradesGUI exists
				if POEGameList not contains %winEXE%
				{
					Gui, Trades:Show, NoActivate Hide
				}
				else {
					Gui, Trades:Show, NoActivate
				}
			}
		}
		else
			Gui, Trades:Show, NoActivate ; Always Shwo

		if ( GlobalValues["Gui_Trades_Mode"] = "Overlay")
			Gui_Trades_Set_Position() ; Re-position the GUI
	}
}

;==================================================================================================================
;
;												MISC STUFF
;
;==================================================================================================================

Remove_TrayTip:
	TrayTip
Return

Get_All_Games_Instances() {
	global GlobalValues

	WinGet windows, List
	matchHandlers := Get_Matching_Windows_Infos("ID")

	if ( matchHandlers.MaxIndex() = "" ) { ; No matching process found
		return "EXE_NOT_FOUND"
	}
	for key, element in matchHandlers {
		index := A_Index
		WinGet, tempExeLocation, ProcessPath,% "ahk_id " element
		SplitPath, tempExeLocation, ,tempExeDir
		tempLogsFile%index% := tempExeDir "\logs\Client.txt"
	}
	tempLogsFileBackup := tempLogsFile1
	Loop %index% {
		index := A_Index
			if ( tempLogsFileBackup = tempLogsFile%index% ) {
				logsFile := tempLogsFileBackup
				GlobalValues.Insert("Dock_Window", matchHandlers[0])
			}
			Else
				multipleInstances := 1
		tempLogsFileBackup := tempLogsFile%index%
	}
	if ( multipleInstances = 1 ) {
		winHandler := GUI_Multiple_Instances(matchHandlers)
		WinGet, exeLocation, ProcessPath,% "ahk_id " winHandler
		SplitPath, exeLocation, ,exeDir
		logsFile := exeDir "\logs\Client.txt"
		GlobalValues.Insert("Dock_Window", winHandler) ; assign global var after choosing the right instance
	}

	r := logsFile
	return r
}

Do_Once() {
/*			
 *			Things that only need to be done ONCE
*/
	global ProgramValues

	iniFilePath := ProgramValues["Ini_File"]

;	Open the changelog menu
	IniRead, state,% iniFilePath,PROGRAM,Show_Changelogs
	if ( state = 1 ) {
		Gui_About()
		IniWrite, 0,% iniFilePath,PROGRAM,Show_Changelogs
	}
}

Get_DPI_Factor() {
;			Credits to ANT-ilic
;			autohotkey.com/board/topic/6893-guis-displaying-differently-on-other-machines/?p=77893
;			Retrieves the current DPI value and returns it
;			If the key wasn't found or is set at 96, returns default setting
	RegRead, dpiValue, HKEY_CURRENT_USER, Control Panel\Desktop\WindowMetrics, AppliedDPI 
	dpiFactor := (ErrorLevel || dpiValue=96)?(1):(dpiValue/96)
	return dpiFactor
}

Logs_Append(funcName, paramsArray="", params*) {
	global ProgramValues, GlobalValues

	programName := ProgramValues["Name"]
	programVersion := ProgramValues["Version"]
	iniFilePath := ProgramValues["Ini_File"]
	programLogsFilePath := ProgramValues["Logs_File"]

	if ( funcName = "START" ) {
		dpiFactor := GlobalValues["Screen_DPI"]
		OSbits := (A_Is64bitOS)?("64bits"):("32bits")
		FileAppend,% "OS: Type:" A_OSType " - Version:" A_OSVersion " - " OSbits "`n",% programLogsFilePath
		FileAppend,% "DPI: " dpiFactor "`n",% programLogsFilePath
		FileAppend,% ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>`n",% programLogsFilePath
		FileAppend,% ">>> PROGRAM SECTION DUMP START`n",% programLogsFilePath
		IniRead, content,% iniFilePath,PROGRAM
		FileAppend,% content "`n",% programLogsFilePath
		FileAppend,% "PROGRAM SECTION DUMP END <<<`n",% programLogsFilePath
		FileAppend,% "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<`n`n",% programLogsFilePath
		FileAppend,% ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>`n",% programLogsFilePath
		FileAppend,% ">>> GLOBAL VALUE_ DUMP START`n",% programLogsFilePath
		for key, element in paramsArray.KEYS {
			FileAppend,% paramsArray.KEYS[A_Index] ": """ paramsArray.VALUES[A_Index] """`n",% programLogsFilePath
		}
		FileAppend,% "GLOBAL VALUE_ DUMP END <<<`n",% programLogsFilePath
		FileAppend,% "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<`n",% programLogsFilePath
	}

	if ( funcName = "GUI_Multiple_Instances" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Found multiple instances. Handler: " params[1] " - Path: " params[2],% programLogsFilePath
	}
	if ( funcName = "GUI_Multiple_Instances_Return" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Found multiple instances (Return). Handler: " params[1],% programLogsFilePath
	}

	if ( funcName = "Monitor_Game_Logs" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Monitoring logs: " params[1],% programLogsFilePath
	}
	if ( funcName = "Monitor_Game_Logs_Break" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Monitoring logs (Break). Obj.pos: " params[1] " - Obj.length: " params[2],% programLogsFilePath
	}

	if ( funcName = "Gui_Trades_Set_Position" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Trades GUI Position: x" params[1] " y" params[2] ".",% programLogsFilePath
	}

	if (funcName = "ShellMessage" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Trades GUI Hidden: Show_Mode: " params[1] " - Dock_Window ID: " params[2] " - Current Win ID: " winID "."
	}

	if ( funcName = "Send_InGame_Message" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Sending IG Message to PID """ params[3] """ with content: """ params[1] """ | %buyerName%:""" params[2] """",% programLogsFilePath
		matchsArray := Get_Matching_Windows_Infos("PID")
		for key, element in matchsArray
			FileAppend,% " | Instance" key " PID: " element,% programLogsFilePath
	}

	if ( funcName = "Gui_Trades_Cycle_Func" ) {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Docking the GUI to ID: " params[1] " - Total matchs found: " params[2] + 1,% programLogsFilePath
	}

	if ( funcName = "GUI_Replace_PID_Return") {
		FileAppend,% "[" A_YYYY "-" A_MM "-" A_DD "_" A_Hour ":" A_Min ":" A_Sec "] ",% programLogsFilePath
		FileAppend,% "Replacing linked PID (Return). PID: " params[1],% programLogsFilePath
	}

	FileAppend,% "`n",% programLogsFilePath
}

Delete_Old_Logs_Files(filesToKeep) {
/*
 *			Delete logs files
 *			Keeps only the ammount specified
*/
	global ProgramValues

	programLogsPath := ProgramValues["Logs_Folder"]

	loop, %programLogsPath%\*.txt
	{
		filesNum := A_Index
		if ( A_LoopFileName != "changelog.txt" ) {
			allFiles .= A_LoopFileName "|"
		}
	}
	Sort, allFiles, D|
	split := StrSplit(allFiles, "|")
	if ( filesNum >= filesToKeep ) {
		Loop {
			index := A_Index
			fileLocation := programLogsPath "\" split[A_Index]
			FileDelete,% fileLocation
			filesNum -= 1
			if ( filesNum <= filesToKeep )
				break
		}
	}
}

Get_Aero_Status(){
/*			Retrieve the AERO status
 *			Used in GUIs. If AERO is disabled, we have to enable -Theme to avoid blacked out text
*/
	hr := DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", isEnabled)
	state := (hr=0 && isEnabled)?(1):(hr=0 && !isEnabled)?(0):("ERROR")
	return state
}

DoNothing:
return

Send_InGame_Message(messageToSend, tabInfos="", isHotkey=0, isAdvanced=0) {
/*
 *			Sends a message in game
 *			Replaces all the %variables% into their actual content
*/
	global GlobalValues, ProgramValues

	programName := ProgramValues["Name"]

	buyerName := tabInfos.Buyer, itemName := tabInfos.Item, itemPrice := tabInfos.Price, gamePID := tabInfos.PID, activeTab := tabInfos.TabID
	messageToSendRaw := messageToSend
	StringReplace, messageToSend, messageToSend, `%buyerName`%, %buyerName%, 1
	StringReplace, messageToSend, messageToSend, `%itemName`%, %itemName%, 1
	StringReplace, messageToSend, messageToSend, `%itemPrice`%, %itemPrice%, 1
	StringReplace, messageToSend, messageToSend, `%lastWhisper`%,% GlobalValues["Last_Whisper"], 1
	if ( isHotkey = 1 ) {
		if ( GlobalValues["Hotkeys_Mode"] = "Advanced" ) {
			SendInput,%messageToSend%
		}
		else {
			SendInput,{Enter}/{BackSpace}
			SendInput,{Raw}%messageToSend%
			SendInput,{Enter}
		}
		Return
	}
	else {
		if !WinExist("ahk_pid " gamePID " ahk_group POEGame") {
			PIDArray := Get_Matching_Windows_Infos("PID")
			handlersArray := Get_Matching_Windows_Infos("ID")
			if ( handlersArray.MaxIndex() = "" ) {
				Loop 2
					TrayTip,% programName,% "The PID assigned to the tab does not belong to a POE instance, and no POE instance was found!`n`nPlease click the button again after restarting the game."
				return 1
			}
			else {
				newPID := GUI_Replace_PID(handlersArray, PIDArray)
				setInfos := Object(), setInfos.NewPID := newPID, setInfos.OldPID := gamePID, setInfos.TabID := tabInfos.TabID
				Gui_Trades_Set_Trades_Infos(setInfos)
				gamePID := newPID
			}
		}
		titleMatchMode := A_TitleMatchMode
		SetTitleMatchMode, RegEx
		WinActivate,[a-zA-Z0-9_] ahk_pid %gamePID%
		WinWaitActive,[a-zA-Z0-9_] ahk_pid %gamePID%, ,5
		if (!ErrorLevel) {
			if ( isAdvanced = 1 ) {
				StringReplace, messageToSend, messageToSend, !, {!}, 1
				StringReplace, messageToSend, messageToSend, ^, {^}, 1
				StringReplace, messageToSend, messageToSend, +, {+}, 1
				StringReplace, messageToSend, messageToSend, #, {#}, 1
				sleep 10
				SendInput,%messageToSend%
			}
			else {
				sleep 10
				SendInput,{Enter}/{BackSpace}
				SendInput,{Raw}%messageToSend%
				SendInput,{Enter}
			}
		}

		Logs_Append(A_ThisFunc,, messageToSend, buyerName, gamePID)
		BlockInput, Off
	}
}

Extract_Font_Files() {
/*			Include the ressources into the compiled executable
 *			Extract the ressources into their specified folder
*/
	global ProgramValues

	programFontFolderPath := ProgramValues["Fonts_Folder"]

	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Fonts\Fontin-SmallCaps.ttf,% programFontFolderPath "\Fontin-SmallCaps.ttf"
	Loop, Files, %programFontFolderPath%\*.*
	{
		if A_LoopFileExt in otf,otc,ttf,ttc
		{
			DllCall( "GDI32.DLL\AddFontResourceEx", Str, A_LoopFileFullPath,UInt,(FR_PRIVATE:=0x10), Int,0)
		}
	}
}

Extract_Skin_Files() {
/*			Include the default skins into the compilled executable
 *			Extracts the included skins into the skins Folder
*/
	global ProgramValues

	programSkinFolderPath := ProgramValues["Skins_Folder"]

;	Path of Exile skin
	if !( InStr(FileExist(programSkinFolderPath "\Path of Exile"), "D") )
		FileCreateDir, % programSkinFolderPath "\Path of Exile"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ArrowLeft.png,% programSkinFolderPath "\Path Of Exile\ArrowLeft.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ArrowLeftHover.png,% programSkinFolderPath "\Path Of Exile\ArrowLeftHover.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ArrowLeftPress.png,% programSkinFolderPath "\Path Of Exile\ArrowLeftPress.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ArrowRight.png,% programSkinFolderPath "\Path Of Exile\ArrowRight.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ArrowRightHover.png,% programSkinFolderPath "\Path Of Exile\ArrowRightHover.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ArrowRightPress.png,% programSkinFolderPath "\Path Of Exile\ArrowRightPress.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\Background.png,% programSkinFolderPath "\Path Of Exile\Background.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ButtonBackground.png,% programSkinFolderPath "\Path Of Exile\ButtonBackground.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ButtonBackgroundHover.png,% programSkinFolderPath "\Path Of Exile\ButtonBackgroundHover.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ButtonBackgroundPress.png,% programSkinFolderPath "\Path Of Exile\ButtonBackgroundPress.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ButtonOrnamentLeft.png,% programSkinFolderPath "\Path Of Exile\ButtonOrnamentLeft.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ButtonOrnamentRight.png,% programSkinFolderPath "\Path Of Exile\ButtonOrnamentRight.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\Close.png,% programSkinFolderPath "\Path Of Exile\Close.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\CloseHover.png,% programSkinFolderPath "\Path Of Exile\CloseHover.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\ClosePress.png,% programSkinFolderPath "\Path Of Exile\ClosePress.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\TabActive.png,% programSkinFolderPath "\Path Of Exile\TabActive.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\TabInactive.png,% programSkinFolderPath "\Path Of Exile\TabInactive.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\TabUnderline.png,% programSkinFolderPath "\Path Of Exile\TabUnderline.png"
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\Skins\Path Of Exile\Header.png,% programSkinFolderPath "\Path Of Exile\Header.png"
}

Extract_Sound_Files() {
/*			Include the SFX into the compilled executable
 *			Extracts the included SFX into the SFX Folder
*/
	global ProgramValues

	programSFXFolderPath := ProgramValues["SFX_Folder"]

	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\SFX\MM_Tatl_Gleam.wav,% programSFXFolderPath "\MM_Tatl_Gleam.wav", 0
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\SFX\MM_Tatl_Hey.wav,% programSFXFolderPath "\MM_Tatl_Hey.wav", 0
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\SFX\WW_MainMenu_CopyErase_Start.wav,% programSFXFolderPath "\WW_MainMenu_CopyErase_Start.wav", 0
	FileInstall, C:\Users\Hatsune\Documents\GitHub\POE-Trades-Helper\Ressources\SFX\WW_MainMenu_Letter.wav,% programSFXFolderPath "\WW_MainMenu_Letter.wav", 0
}

Close_Previous_Program_Instance() {
/*
 *			Prevents from running multiple instances of this program
 *			Works by reading the last PID and process name from the .ini
 *				, checking if there is an existing match
 *				and closing if a match is found
*/
	global ProgramValues

	iniFilePath := ProgramValues["Ini_File"]

	IniRead, lastPID,% iniFilePath,PROGRAM,PID
	IniRead, lastProcessName,% iniFilePath,PROGRAM,FileProcessName

	if ( A_IsAdmin = 0 )
		Return ; Not running as admin means script will be going through the Run_As_Admin function

	Process, Exist, %lastPID%
	existingPID := ErrorLevel
	if ( existingPID = 0 )
		Return ; No match found
	else {
		HiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On ; Required to access the process name
		WinGet, existingProcessName, ProcessName, ahk_pid %existingPID% ; Get process name from PID
		DetectHiddenWindows, %HiddenWindows%
		if ( existingProcessName = lastProcessName ) { ; Match found, close the previous instance
			Process, Close, %existingPID%
			Process, WaitClose, %existingPID%
		}
	}

}

GUI_Trades_Cycle:
	Gui_Trades_Cycle_Func()
Return

Gui_Trades_Cycle_Func() {
/*
 *			Retrieves the existing POE instances
 *				then cycle the Trades GUI through each instance
 *				for every time the user triggers the function
 *			Once the last match was reached
 *				we reset back to the first match
*/
	static
	global ProgramValues, GlobalValues
	global guiTradesHandler

	programName := ProgramValues["Name"]
	nextID := GlobalValues["Current_DockID"]
	nextID += 1

	if ( GlobalValues["Trades_GUI_Mode"] != "Overlay" )
		Return

	if !(guiTradesHandler) {
		Loop 2
			TrayTip,% programName,% "Couldn't find the Trades GUI!`nOperation Canceled."
		Return
	}
	matchHandlers := Get_Matching_Windows_Infos("ID")
	GlobalValues.Insert("Current_DockID", nextID)
	if ( GlobalValues["Current_DockID"] > matchHandlers.MaxIndex() ) {
		GlobalValues.Insert("Current_DockID", 0)
	}
	GlobalValues.Insert("Dock_Window", matchHandlers[GlobalValues["Current_DockID"]])
	Gui_Trades_Set_Position()
	Logs_Append(A_ThisFunc,, GlobalValues["Dock_Window"], matchHandlers.MaxIndex())
}

Get_Matching_Windows_Infos(mode) {
/*
 *			Retrieves a list of all existing windows
 *				then returns an array containing only those matching the game
*/
	global POEGameList

	matchsArray := Object()
	matchsList := ""
	index := 0

	HiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, Off

	WinGet, windows, List
	Loop %windows%
	{
		ExeID := windows%A_Index%
		WinGet, ExeName, ProcessName,% "ahk_id " ExeID
		WinGet, ExePID, PID,% "ahk_id " ExeID
		if ExeName in %POEGameList%
		{
			if ( mode = "ID" ) {
				if ExeID not in %matchsList%
					matchsList .= ExeID ","
			}
			else if ( mode = "PID" ){
				if ExePID not in %matchsList%
					matchsList .= ExePID ","
			}
		}
	}
	Loop, Parse, matchsList,% ","
	{
		if ( A_LoopField != "" ) {
			matchsArray.Insert(index, A_LoopField)
			index++
		}
	}
	DetectHiddenWindows, %HiddenWindows%
	return matchsArray
}

Create_Tray_Menu(globalDeclared=0) {
/*
 *			Creates the Tray Menu
*/
	global GlobalValues, ProgramValues

	programName := ProgramValues["Name"], programVersion := ProgramValues["Version"]

	if ( globalDeclared = 0 ) {
		Menu, Tray, DeleteAll
		Menu, Tray, Tip,% programName " v" programVersion
		Menu, Tray, NoStandard
		Menu, Tray, Add,Settings, Gui_Settings
		Menu, Tray, Add,About?, Gui_About
		Menu, Tray, Add, 
		Menu, Tray, Add,Cycle Overlay,GUI_Trades_Cycle
		Menu, Tray, Add, 
		Menu, Tray, Add,Mode: Overlay,GUI_Trades_Mode
		Menu, Tray, Add,Mode: Window,GUI_Trades_Mode
		Menu, Tray, Add, 
		Menu, Tray, Add,Reload, Reload_Func
		Menu, Tray, Add,Close, Exit_Func
	}
	else if ( globalDeclared = 1 ) {
		Menu, Tray, Check,% "Mode: " GlobalValues["Trades_GUI_Mode"]
	}
	Menu, Tray, Icon
}

Run_As_Admin() {
/*			Make sure the program is running as Admin
 *			Works for both .ahk and .exe
 *
 *			Credits to art
 *			https://autohotkey.com/board/topic/46526-run-as-administrator-xpvista7-a-isadmin-params-lib/?p=600596
*/
	global 0
	global ProgramValues, GlobalValues

	iniFilePath := ProgramValues["Ini_File"], programName := ProgramValues["Name"]

	IniWrite,% A_IsAdmin,% iniFilePath,PROGRAM,Is_Running_As_Admin

	if ( A_IsAdmin = 1 ) {
		IniWrite, 0,% iniFilePath,PROGRAM,Run_As_Admin_Attempts
		Return
	}

	IniRead, attempts,% iniFilePath,PROGRAM,Run_As_Admin_Attempts
	if ( attempts = "ERROR" || attempts = "" )
		attempts := 0
	attempts++
	IniWrite,% attempts,% iniFilePath,PROGRAM,Run_As_Admin_Attempts
	if ( attempts > 2 ) {

		IniWrite,0,% iniFilePath,PROGRAM,Run_As_Admin_Attempts
		MsgBox, 4100,% "Running as admin failed!",% "It seems " programName " was unable to run with admin rights previously."
		. "`nTry right clicking the executable and choose ""Run as Administrator""."
		. "`n`nPossible known causes could be:"
		. "`n-You are not using an account with administrative rights."
		. "`n-You are using an account with administrative right"
		. "`n    but declined the UAC prompt."
		. "`n-You are using an account with standard rights"
		. "`n    and the administrator disabled UAC."
		. "`n`nWoud you like to continue without admin rights?"
		. "`nYou will still be able to see the incoming trade requests."
		. "`nThough, some of the GUI buttons and the hotkeys will not work."
		IfMsgBox, Yes
		{
			return
		}
		IfMsgBox, Cancel
		{
			OnExit("Exit_Func", 0)
			ExitApp
		}
		IfMsgBox, No
		{
			OnExit("Exit_Func", 0)
			ExitApp
		}
	}
	dpiFactor := GlobalValues["Screen_DPI"]
	SplashTextOn, 370*dpiFactor, 40*dpiFactor,% programName,% programName " needs to run with Admin .`nAttempt to restart with admin rights in 3 seconds..."
	sleep 3000

	Loop, %0%
		params .= A_Space . %A_Index%
	DllCall("shell32\ShellExecute" (A_IsUnicode ? "":"A"),uint,0,str,"RunAs",str,(A_IsCompiled ? A_ScriptFullPath
	: A_AhkPath),str,(A_IsCompiled ? "": """" . A_ScriptFullPath . """" . A_Space) params,str,A_WorkingDir,int,1)
	OnExit("Exit_Func", 0)
	ExitApp
}

Tray_Refresh() {
;			Refreshes the Tray Icons, to remove any "leftovers"
;			Should work both for Windows 7 and 10
	WM_MOUSEMOVE := 0x200
	HiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On
	TrayTitle := "AHK_class Shell_TrayWnd"
	ControlNN := "ToolbarWindow322"
	IcSz := 24
	Loop, 8
	{
		index := A_Index
		if ( index = 1 || index = 3 || index = 5 || index = 7 ) {
			IcSz := 24
		}
		else if ( index = 2 || index = 4 || index = 6 || index = 8 ) {
			IcSz := 32
		}
		if ( index = 1 || index = 2 ) {
			TrayTitle := "AHK_class Shell_TrayWnd"
			ControlNN := "ToolbarWindow322"
		}
		else if ( index = 3 || index = 4 ) {
			TrayTitle := "AHK_class NotifyIconOverflowWindow"
			ControlNN := "ToolbarWindow321"
		}
		if ( index = 5 || index = 6 ) {
			TrayTitle := "AHK_class Shell_TrayWnd"
			ControlNN := "ToolbarWindow321"
		}
		else if ( index = 7 || index = 8 ) {
			TrayTitle := "AHK_class NotifyIconOverflowWindow"
			ControlNN := "ToolbarWindow322"
		}
		ControlGetPos, xTray,yTray,wdTray,htTray, %ControlNN%, %TrayTitle%
		y := htTray - 10
		While (y > 0)
		{
			x := wdTray - IcSz/2
			While (x > 0)
			{
				point := (y << 16) + x
				PostMessage, %WM_MOUSEMOVE%, 0, %point%, %ControlNN%, %TrayTitle%
				x -= IcSz/2
			}
			y -= IcSz/2
		}
	}
	DetectHiddenWindows, %HiddenWindows%
	Return
}

Reload_Func() {
	sleep 10
	Reload
	Sleep 10000
}

Exit_Func(ExitReason, ExitCode) {
	global ProgramValues, GlobalValues
	global GuiTradesHandler

	iniFilePath := ProgramValues["Ini_File"]
	programFontFolderPath := ProgramValues["Fonts_Folder"]

;	Save the current position of the TradesGUI
	if ( GlobalValues["Trades_GUI_Mode"] = "Window" ) {
		WinGetPos, xpos, ypos, , ,% "ahk_id " GuiTradesHandler
		IniWrite,% xpos,% iniFilePath,PROGRAM,X_POS
		IniWrite,% ypos,% iniFilePath,PROGRAM,Y_POS
	}

;	Unload the Fonts ressources
	Loop, Files, %programFontFolderPath%\*.*
	{
		if A_LoopFileExt in otf,otc,ttf,ttc
		{
			DllCall( "GDI32.DLL\RemoveFontResourceEx",Str, A_LoopFileFullPath,UInt,(FR_PRIVATE:=0x10),Int,0)
		}
	}

	ExitApp
}