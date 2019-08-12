﻿Set_LocalSettings() {
	global PROGRAM
	settingsFile := PROGRAM.SETTINGS_FILE
	; Set default settings if first time running
	defaultSettings := Get_LocalSettings_DefaultValues()
	if !FileExist(settingsFile) {
		Save_LocalSettings(defaultSettings)
		return
	}
	LocalSettings_VerifyValuesValidity()
	; Load settings and reset updating related settings
	localSettings := Get_LocalSettings()
	localSettings.UPDATING.ScriptHwnd := defaultSettings.UPDATING.ScriptHwnd
	localSettings.UPDATING.FileProcessName := defaultSettings.UPDATING.FileProcessName
	localSettings.UPDATING.FileName := defaultSettings.UPDATING.FileName
	localSettings.UPDATING.PID 	:= defaultSettings.UPDATING.PID
	Save_LocalSettings(localSettings)

	/*
	Loop 3 {
		rowNum := A_Index
		Loop % settingsDefaultValues["SETTINGS_CUSTOM_BUTTON_ROW_" A_Index].Buttons_Count {
			btnNum := A_Index
			for key, value in localSettings["SETTINGS_CUSTOM_BUTTON_ROW_" rowNum "_Num" btnNum] {
				doesCustomBtnRow%rowNum%Num%btnNum%Exist := True
				Break
			}
		}
	}

	; Set the order to go through sections
	order := ""
	Loop, Parse, sectsOrder,% ","
	{
		loopedSect := A_LoopField
		for iniSect, nothing in settingsDefaultValues {
			if IsContaining(iniSect, loopedSect) && !IsIn(iniSect, order)
				order .= iniSect ","
		}
	}
	StringTrimRight, order, order, 1
	; Make sure each value is valid
	Loop, Parse, order,% ","
	{
		iniSect := A_LoopField
		for iniKey, defValue in settingsDefaultValues[iniSect] {
			iniValue := localSettings[iniSect][iniKey]
			isValueValid := LocalSettings_IsValueValid(iniSect, iniKey, iniValue)
			if RegExMatch(iniSect, "O)SETTINGS_CUSTOM_BUTTON_ROW_(\d+)_NUM_(\d+)", iniSectPat) {
				rowNum := iniSectPat.1, btnNum := iniSectPat.2

				isValueValid := iniKey="Name"?isValueValid
				: doesCustomBtnRow%rowNum%Num%btnNum%Exist=True?True
				: False
			}

			if (!isValueValid) {
				if (IsFirstTimeRunning != "True")
				&& !IsIn(iniKey, "IsFirstTimeRunning,AddShowGridActionToInviteButtons,HasAskedForImport,RemoveCopyItemInfosIfGridActionExists,ReplaceOldTradeVariables,UpdateKickMyselfOutOfPartyHideoutHotkey,LastUpdateCheck,AskForLanguage")
				&& (iniValue != "")
					warnMsg .= "Section: " iniSect "`nKey: " iniKey "`nValue: " iniValue "`nDefault value: " defValue "`n`n"
				Restore_LocalSettings(iniSect, iniKey)
			}
		}
	}
	; Show which values were restored to default
	warnMsg := ""
	if (warnMsg) {
		Gui, ErrorLog:New, +AlwaysOnTop +ToolWindow +hwndhGuiErrorLog
		Gui, ErrorLog:Add, Text, x10 y10,% "One or multiple ini entries were deemed invalid and were reset to their default value."
		Gui, ErrorLog:Add, Edit, xp y+5 w500 R25 ReadOnly,% warnMsg
		Gui, ErrorLog:Add, Link, xp y+5,% "If you need assistance, you can contact me on: "
		. "<a href=""" PROGRAM.LINK_GITHUB """>GitHub</a> - <a href=""" PROGRAM.LINK_REDDIT """>Reddit</a> - <a href=""" PROGRAM.LINK_GGG """>PoE Forums</a> - <a href=""" PROGRAM.LINK_DISCORD """>Discord</a>"
		Gui, ErrorLog:Show,xCenter yCenter,% PROGRAM.NAME " - Error log"
		WinWait, ahk_id %hGuiErrorLog%
		WinWaitClose, ahk_id %hGuiErrorLog%
	}
	*/
}

Get_LocalSettings() {
	global PROGRAM
	return JSON_Load(PROGRAM.SETTINGS_FILE)
}

Update_LocalSettings() {
	global PROGRAM
	iniFile := PROGRAM.SETTINGS_FILE_OLD
	localSettings := Get_LocalSettings()
	iniSettings := class_EasyIni(iniFile)

	isFirstTimeRunning := localSettings.GENERAL.IsFirstTimeRunning
	if (isFirstTimeRunning="True") { ; First time running
		localSettings.GENERAL.AddShowGridActionToInviteButtons := "False"
		localSettings.GENERAL.AskForLanguage := "False"
		localSettings.GENERAL.HasAskedForImport := "True"
		localSettings.GENERAL.IsFirstTimeRunning := "False"
		localSettings.GENERAL.RemoveCopyItemInfosIfGridActionExists := "False"
		localSettings.GENERAL.ReplaceOldTradeVariables := "False"
		localSettings.GENERAL.UpdateKickMyselfOutOfPartyHideoutHotkey := "False"
		Save_LocalSettings(localSettings)
		return
	}

	; Splitting version in case of need
	priorVersion := localSettings.UPDATING.Version
	priorVersionSplit := StrSplit(priorVersion, "."), prior_main := priorVersionSplit.1, prior_patch := priorVersionSplit.2, prior_fix := IsContaining(priorVersionSplit.3, "BETA_") ? StrSplit(priorVersionSplit.3, "BETA_").2 : priorVersionSplit.3
	; Reset version setting
	defaultSettings := Get_LocalSettings_DefaultValues()
	localSettings.UPDATING.Version := defaultSettings.UPDATING.Version
	Save_LocalSettings(localSettings)

	; All of those are old and related to the ini file. After updating the ini, we will convert values into JSON
	if FileExist(iniFile) {
		if (iniSettings.GENERAL.AddShowGridActionToInviteButtons = "True") {
			AppendToLogs(A_ThisFunc "(): AddShowGridActionToInviteButtons detected as True."
			. "`n" "Adding SHOW_GRID action to all buttons containing the INVITE_BUYER action.")
			Loop {
				cbIndex := A_Index
				loopedSetting := iniSettings["SETTINGS_CUSTOM_BUTTON_" cbIndex]
				if IsObject(loopedSetting) {
					hasInvite := False, hasGrid := False
					Loop {
						loopActionIndex := A_Index
						loopedActionContent := loopedSetting["Action_" loopActionIndex "_Content"]
						loopedActionType := loopedSetting["Action_" loopActionIndex "_Type"]

						if (!loopedActionType) || (loopedActionType = "") || (loopActionIndex > 50)
							Break
						
						else if IsContaining(loopedActionContent, "/invite %buyer%") || IsContaining(loopedActionContent, "/invite %buyerName%")
						|| (loopedActionType = "INVITE_BUYER")
							hasInvite := True

						else if (loopedActionType = "SHOW_GRID")
							hasGrid := True
					}
					if (hasInvite = True && hasGrid = False) {
						AppendToLogs(A_ThisFunc "(): Adding SHOW_GRID action to button with"
						. "`n" "ID: """ cbIndex """ - Action index: """ loopActionIndex """")
						INI.Set(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" loopActionIndex "_Content", "")
						INI.Set(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" loopActionIndex "_Type", "SHOW_GRID")
					}
				}
				else if (cbIndex > 20)
					Break
				else
					Break
			}
			AppendToLogs(A_ThisFunc "(): Finished adding SHOW_GRID action.")
			INI.Set(iniFile, "GENERAL", "AddShowGridActionToInviteButtons", "False")
		}

		if (iniSettings.GENERAL.RemoveCopyItemInfosIfGridActionExists = "True") {
			AppendToLogs(A_ThisFunc "(): RemoveCopyItemInfosIfGridActionExists detected as True."
			. "`n" "Removing COPY_ITEM_INFOS action to all buttons containing the SHOW_GRID action.")
			Loop {
				cbIndex := A_Index
				loopedSetting := iniSettings["SETTINGS_CUSTOM_BUTTON_" cbIndex]
				if IsObject(loopedSetting) {
					hasCopy := False, hasGrid := False
					Loop {
						loopActionIndex := A_Index
						loopedActionContent := loopedSetting["Action_" loopActionIndex "_Content"]
						loopedActionType := loopedSetting["Action_" loopActionIndex "_Type"]

						if (!loopedActionType) || (loopedActionType = "") || (loopActionIndex > 50) {
							loopActionIndex--
							Break
						}
						
						else if (loopedActionType = "COPY_ITEM_INFOS")
							hasCopy := True, copyActionIndex := loopActionIndex

						else if (loopedActionType = "SHOW_GRID")
							hasGrid := True, gridActionIndex:= loopActionIndex
					}
					if (hasCopy = True && hasGrid = True) {
						AppendToLogs(A_ThisFunc "(): Removing COPY_ITEM_INFOS action to button with" . "`t" "ID: """ cbIndex """ - Action index: """ loopActionIndex """. Action ID: """ copyActionIndex """")

						; Reduce action num by one, for every action after COPY_ITEM_INFOS
						startReplaceIndex := copyActionIndex
						Loop % loopActionIndex - copyActionIndex {
							INI.Set(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" startReplaceIndex "_Content", """" loopedSetting["Action_" startReplaceIndex+1 "_Content"] """")
							INI.Set(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" startReplaceIndex "_Type", loopedSetting["Action_" startReplaceIndex+1 "_Type"])
							startReplaceIndex++

							AppendToLogs(A_ThisFunc "(): Reducing action index by one for button with" . "`t" "ID: """ cbIndex """ - Action index: """ loopActionIndex """. Action ID: """ startReplaceIndex+1 """")
						}
						; Remove COPY_ITEM_INFOS action
						INI.Remove(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" loopActionIndex "_Content")
						INI.Remove(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" loopActionIndex "_Type")					
					}
				}
				else if (cbIndex > 20)
					Break
				else
					Break
			}
			AppendToLogs(A_ThisFunc "(): Finished removing COPY_ITEM_INFOS action to buttons with SHOW_GRID action.")
			INI.Set(iniFile, "GENERAL", "RemoveCopyItemInfosIfGridActionExists", "False")
		}

		if (iniSettings.GENERAL.ReplaceOldTradeVariables = "True") {
			AppendToLogs(A_ThisFunc "(): ReplaceOldTradeVariables detected as True."
			. "`n" "Replacing trade variables with new updated names.")
			variablesToReplace := {"%buyerName%":"%buyer%", "%itemName%":"%item%", "%itemPrice%":"%price%", "%lastWhisper%":"%lwr%"
			, "%lastWhisperReceived%":"%lwr%", "%sentWhisper%":"%lws%", "%lastWhisperSent%":"%lws%"}
			; custom buttons
			Loop {
				cbIndex := A_Index
				loopedBtn := iniSettings["SETTINGS_CUSTOM_BUTTON_" cbIndex]
				if IsObject(loopedBtn) {
					Loop {
						loopActionIndex := A_Index
						loopedActionContent := loopedBtn["Action_" loopActionIndex "_Content"]
						loopedActionType := loopedBtn["Action_" loopActionIndex "_Type"]

						if (!loopedActionType) || (loopedActionType = "") || (loopActionIndex > 50) {
							loopActionIndex--
							Break
						}

						hasReplaced := False, replaceCount := 0
						for key, value in variablesToReplace {
							if IsContaining(loopedActionContent, key) {
								loopedActionContent := StrReplace(loopedActionContent, key, value, replaceCount)
							}
							hasReplaced := hasReplaced=True?True : replaceCount?True : False
						}

						if (hasReplaced) {
							AppendToLogs(A_ThisFunc "(): Replacing " key " variable to button with" . "`t" "ID: """ cbIndex """ - Action index: """ loopActionIndex """")
							INI.Set(iniFile, "SETTINGS_CUSTOM_BUTTON_" cbIndex, "Action_" loopActionIndex "_Content", """" loopedActionContent """")
						}
					}
				}
				else if (cbIndex > 20)
					Break
				else
					Break
			}
			; hotkeys basic
			Loop 15 {
				hkIndex := A_Index
				loopedHK := iniSettings["SETTINGS_HOTKEY_" hkIndex]

				loopedActionContent := loopedHK["Content"]
				loopedActionType := loopedHK["Type"]

				hasReplaced := False, replaceCount := 0
				for key, value in variablesToReplace {
					if IsContaining(loopedActionContent, key)
						loopedActionContent := StrReplace(loopedActionContent, key, value, replaceCount)
					hasReplaced := hasReplaced=True?True : replaceCount?True : False
				}
				
				if (hasReplaced) {
					AppendToLogs(A_ThisFunc "(): Replacing " key " variable to hotkey with"	. "`t" "ID: """ cbIndex """")
					INI.Set(iniFile, "SETTINGS_HOTKEY_" hkIndex, "Content", """" loopedActionContent """")
				}
			}
			; hotkeys adv
			Loop {
				hkIndex := A_Index
				loopedHK := iniSettings["SETTINGS_HOTKEY_ADV_" hkIndex]
				if IsObject(loopedHK) {
					Loop {
						loopActionIndex := A_Index
						loopedActionContent := loopedHK["Action_" loopActionIndex "_Content"]
						loopedActionType := loopedHK["Action_" loopActionIndex "_Type"]

						if (!loopedActionType) || (loopedActionType = "") || (loopActionIndex > 50) {
							loopActionIndex--
							Break
						}

						hasReplaced := False, replaceCount := 0
						for key, value in variablesToReplace {
							if IsContaining(loopedActionContent, key) {
								loopedActionContent := StrReplace(loopedActionContent, key, value, replaceCount)
							}
							hasReplaced := hasReplaced=True?True : replaceCount?True : False
						}

						if (hasReplaced) {
							AppendToLogs(A_ThisFunc "(): Replacing " key " variable to hotkey adv with" . "`t" "ID: """ cbIndex """ - Action index: """ loopActionIndex """")	
							INI.Set(iniFile, "SETTINGS_HOTKEY_ADV_" hkIndex, "Action_" loopActionIndex "_Content", """" loopedActionContent """")
						}
					}
				}
				else if (hkIndex > 200)
					Break
				else
					Break
			}

			AppendToLogs(A_ThisFunc "(): Finished replacing trade variables with new updated names.")
			INI.Set(iniFile, "GENERAL", "ReplaceOldTradeVariables", "False")
		}

		if (iniSettings.GENERAL.UpdateKickMyselfOutOfPartyHideoutHotkey = "True") {
			AppendToLogs(A_ThisFunc "(): UpdateKickMyselfOutOfPartyHideoutHotkey detected as True."
			. "`n" "Replacing adv hotkey with new action.")

			if (iniSettings.SETTINGS_HOTKEY_ADV_1.Name = "Kick myself out of party + hideout") {
				/* Disabled due to incompatibility when converting to JSON (missing functions and settings)
				INI.Remove(iniFile, "SETTINGS_HOTKEY_ADV_1")
				Restore_LocalSettings("SETTINGS_HOTKEY_ADV_1")
				*/
			}

			AppendToLogs(A_ThisFunc "(): Finished replacing adv hotkey with new action.")
			INI.Set(iniFile, "GENERAL", "UpdateKickMyselfOutOfPartyHideoutHotkey", "False")
		}

		if (PROGRAM.IS_BETA = "True")
			INI.Set(iniFile, "UPDATING", "UseBeta", "True")

		; Now converting button actions
		iniSettings := class_EasyIni(iniFile), newJsonSettings := ObjFullyClone(localSettings)
		newJsonSettings.GENERAL := iniSettings.GENERAL
		newJsonSettings.SETTINGS_MAIN := iniSettings.SETTINGS_MAIN
		newJsonSettings.UPDATING := iniSettings.UPDATING

		Loop 2 { ; Normal and UserDefined
			iniSection := A_Index=1?"SETTINGS_CUSTOMIZATION_SKINS":"SETTINGS_CUSTOMIZATION_SKINS_UserDefined"
			newJsonSettings[iniSection] := {}, newJsonSettings[iniSection].COLORS := {}
			for key, value in iniSettings[iniSection] {
				if RegExMatch(key, "iO)Color_(.*)", keyOut)
					newJsonSettings[iniSection].COLORS[keyOut.1] := value 
				else 
					newJsonSettings[iniSection][key] := value
			}
		}

		SpecialButtons_1 := {}, SpecialButtons_2 := {}, SpecialButtons_3 := {}
		Loop 5 { ; Once to get settings
			loopIndex := A_Index
			iniSection := "SETTINGS_SPECIAL_BUTTON_" loopIndex
			if (iniSettings[iniSection].Enabled = "True") { ; Forcing actions based on one of our new buttons
				slotNum := iniSettings[iniSection].Slot
				SpecialButtons_1[slotNum] := iniSettings[iniSection]
			}
		}

		for num, nothing in SpecialButtons_1 ; Another to make sure it starts in order
			SpecialButtons_2[A_Index] := SpecialButtons_1[num]

		for num, nothing in SpecialButtons_2 { ; And last to adapt it to json
			matchObj := (SpecialButtons_2[num].Type = "Whisper") ? localSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_4.1
			: (SpecialButtons_2[num].Type = "Invite") ? localSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_4.2
			: (SpecialButtons_2[num].Type = "Trade") ? localSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_4.3
			: (SpecialButtons_2[num].Type = "Kick") ? localSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_4.4
			: ""
			if (matchObj) {
				specialCount++
				SpecialButtons_3[specialCount] := matchObj
			}
		}
		SpecialButtons := ObjFullyClone(SpecialButtons_3), SpecialButtons_1 := SpecialButtons_2 := SpecialButtons_3 := ""

		CustomButtons_1 := {}, CustomButtons_2 := {}, CustomButtons_3 := {}
		Loop 9 { ; Once to get settings
			loopIndex := A_Index
			iniSection := "SETTINGS_CUSTOM_BUTTON_" loopIndex
			if (iniSettings[iniSection].Enabled = "True") { ; Forcing actions based on one of our new buttons
				slotNum := iniSettings[iniSection].Slot
				CustomButtons_1[slotNum] := iniSettings[iniSection]
			}
		}

		for num, nothing in CustomButtons_1 ; Another to make sure it starts in order
			CustomButtons_2[A_Index] := CustomButtons_1[num]

		for num, nothing in CustomButtons_2 { ; And last to adapt it to json
			actionsObj := {}
			for key, value in CustomButtons_2[num] { ; Creating array of actions
				if RegExMatch(key, "iO)Action_(\d+)_(.*)", outVarObj) {
					if !IsObject(actionsObj[outVarObj.1])
						actionsObj[outVarObj.1] := {}
					actionsObj[outVarObj.1][outVarObj.2] := value
				}
			}
			CustomButtons_3[num] := {Text: CustomButtons_2[num].Name, Actions: ObjFullyClone(actionsObj)}
		}
		CustomButtons := ObjFullyClone(CustomButtons_3), CustomButtons_1 := CustomButtons_2 := CustomButtons_3 := ""

		; Prepating the obj
		newJsonSettings.SELL_INTERFACE := {}
		newJsonSettings.SELL_INTERFACE.Mode := "Tabs"
		; Adding special buttons row
		if ( SpecialButtons.Count() )
			newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_4 := {Buttons_Count: SpecialButtons.Count()}
		Loop % SpecialButtons.Count()
			newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_4[A_Index] := ObjFullyClone(SpecialButtons[A_Index])
		; Creating obj for custom buttons
		if ( CustomButtons.Count() ) {
			Loop 3
				newJsonSettings.SELL_INTERFACE["CUSTOM_BUTTON_ROW_" A_Index] := {}
		}
		newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_1.Buttons_Count := ( CustomButtons.Count() >= 5 ) ? 5 : CustomButtons.Count()
		newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_2.Buttons_Count := ( CustomButtons.Count() >= 5 ) ? CustomButtons.Count() - 5 : CustomButtons.Count()
		newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_3.Buttons_Count := 0
		; Adding custom buttons
		Loop % CustomButtons.Count() {
			if IsBetween(A_Index, 1, 5)
				newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_1[A_Index] := CustomButtons[A_Index]
			else
				newJsonSettings.SELL_INTERFACE.CUSTOM_BUTTON_ROW_2[A_Index-5] := CustomButtons[A_Index]
		}
		; Now converting ini into json
		Save_LocalSettings(newJsonSettings)
		FileMove,% iniFile,% iniFile ".bak", 1
	}
}

Get_LocalSettings_DefaultValues() {
	; Gets the default values of the settings file
	global PROGRAM
	; Getting default poe skin settings
	poeSkinSettings := GUI_Settings.TabCustomizationSkins_GetSkinDefaultSettings("Path of Exile")
	; Getting current preset and skin settings
	currentPreset := JSON_Load(PROGRAM.SETTINGS_FILE).SETTINGS_CUSTOMIZATION_SKINS.Preset
	currentSkin := currentPreset="User Defined"?JSON_Load(PROGRAM.SETTINGS_FILE).SETTINGS_CUSTOMIZATION_SKINS_UserDefined.Skin
				: JSON_Load(PROGRAM.SETTINGS_FILE).SETTINGS_CUSTOMIZATION_SKINS.Skin
	currentSkin := (currentSkin && currentSkin != "" && currentSkin != "ERROR") ? currentSkin : settings.SETTINGS_CUSTOMIZATION_SKINS.Skin
	defaultSkinSettings := GUI_Settings.TabCustomizationSkins_GetSkinDefaultSettings(currentSkin)
	; Getting process name + Setting some other vars
	DetectHiddenWindows("On")
	WinGet, filePName, ProcessName,% "ahk_pid " DllCall("GetCurrentProcessId")
	DetectHiddenWindows("")
	ScriptName := A_ScriptName, ScriptHwnd := A_ScriptHwnd, ProgramVersion := PROGRAM.VERSION, ScriptPid := DllCall("GetCurrentProcessId"), sfxFolder := StrReplace(PROGRAM.SFX_FOLDER, "\", "\\")
	poeSkin := poeSkinSettings.Skin, poeFontSize := poeSkinSettings.FontSize, poeFontQuality := poeSkinSettings.FontQuality, poeFontName := poeSkinSettings.Font
	; Creating the default values obj
	settings =
	(
		{
			"GENERAL": { 
				"IsFirstTimeRunning": "True",
				"AddShowGridActionToInviteButtons": "True",
				"HasAskedForImport": "False",
				"RemoveCopyItemInfosIfGridActionExists": "True",
				"ReplaceOldTradeVariables": "True",
				"UpdateKickMyselfOutOfPartyHideoutHotkey": "True",
				"AskForLanguage": "True",
				"Language": "english"
			},

			"SETTINGS_MAIN": {
				"TradingWhisperSFXPath": "%sfxFolder%\\WW_MainMenu_Letter.wav",
				"RegularWhisperSFXPath": "",
				"BuyerJoinedAreaSFXPath": "",
				"NoTabsTransparency": "100",
				"TabsOpenTransparency": "100",
				"HideInterfaceWhenOutOfGame": "False",
				"CopyItemInfosOnTabChange": "False",
				"AutoFocusNewTabs": "False",
				"AutoMinimizeOnAllTabsClosed": "True",
				"AutoMaximizeOnFirstNewTab": "False",
				"SendTradingWhisperUponCopyWhenHoldingCTRL": "True",
				"TradingWhisperSFXToggle": "True",
				"RegularWhisperSFXToggle": "False",
				"BuyerJoinedAreaSFXToggle": "False",
				"ShowTabbedTrayNotificationOnWhisper": "True",
				"TradesGUI_Mode": "Window",
				"TradesGUI_Locked": "False",
				"AllowClicksToPassThroughWhileInactive": "False",
				"SendMsgMode": "Clipboard",
				"PushBulletToken": "",
				"PushBulletOnTradingWhisper": "True",
				"PushBulletOnPartyMessage": "False",
				"PushBulletOnWhisperMessage": "False",
				"PushBulletOnlyWhenAfk": "True",
				"PoeAccounts": "",
				"MinimizeInterfaceToBottomLeft": "False",
				"ItemGridHideNormalTab": "False",
				"ItemGridHideQuadTab": "False",
				"ItemGridHideNormalTabAndQuadTabForMaps": "False"
			},

			"SETTINGS_CUSTOMIZATION_SKINS": {
				"Preset": "%poeSkin%",
				"Skin": "%poeSkin%",
				"UseRecommendedFontSettings": "True",
				"FontSize": "%poeFontSize%",
				"FontQuality": "%poeFontQuality%",
				"Font": "%poeFontName%",
				"ScalingPercentage": "100",
				"Colors": {
					`%poeSettingsColors`%
				}
			},

			"SETTINGS_CUSTOMIZATION_SKINS_UserDefined": {
				
			},

			"SELL_INTERFACE": {
				"Mode": "Tabs",
				"CUSTOM_BUTTON_ROW_1": {
					"Buttons_Count": 3,
					"1": {
						"Text": "Invite",
						"Actions": {
							"1": {
								"Type": "INVITE_BUYER",
								"Content": "\"/invite `%buyer`%\""
							},
							"2": {
								"Type": "SEND_TO_BUYER",
								"Content": "\"@`%buyer`% Ready to be picked up - (`%item`% for `%price`%)\""
							}
						}
					},
					"2": {
						"Text": "Trade",
						"Actions": {
							"1": {
								"Type": "TRADE_BUYER",
								"Content": "\"/tradewith `%buyer`%\""
							}
						}
					},
					"3": {
						"Text": "Thanks",
						"Actions": {
							"1": {
								"Type": "SEND_TO_BUYER",
								"Content": "\"@`%buyer`% Thank you & good luck!\""
							},
							"2": {
								"Type": "KICK_BUYER",
								"Content": "\"/kick `%buyer`%\""
							},
							"3": {
								"Type": "SAVE_TRADE_STATS",
								"Content": "\"\""
							},
							"4": {
								"Type": "CLOSE_TAB",
								"Content": "\"\""
							}
						}
					}
				},
				"CUSTOM_BUTTON_ROW_2": {
					"Buttons_Count": 4,
					"1": {
						"Text": "Busy",
						"Actions": {
							"1": {
								"Type": "SEND_TO_BUYER",
								"Content": "\"@`%buyer`% Busy for now, will invite asap - (`%item`% for `%price`%)\""
							}
						}
					},
					"2": {
						"Text": "?"
					},
					"3": {
						"Text": "Ignore item",
						"Actions": {
							"1": {
								"Type": "IGNORE_SIMILAR_TRADE",
								"Content": "\"\""
							},
							"2": {
								"Type": "CLOSE_TAB",
								"Content": "\"\""
							}
						}
					},
					"4": {
						"Text": "Sold",
						"Actions": {
							"1": {
								"Type": "SEND_TO_BUYER",
								"Content": "\"@`%buyer`% Already sold, sorry - (`%item`% for `%price`%)\""
							},
							"2": {
								"Type": "CLOSE_TAB",
								"Content": "\"\""
							}
						}
					}
				},
				"CUSTOM_BUTTON_ROW_3": {
					"Buttons_Count": 0
				},
				"CUSTOM_BUTTON_ROW_4": {
					"Buttons_Count": 4,
					"1": {
						"Icon": "Whisper",
						"Actions": {
							"1": {
								"Type": "WRITE_TO_BUYER",
								"Content": "\"@`%buyer`% \""
							}
						}
					},
					"2": {
						"Icon": "Invite",
						"Actions": {
							"1": {
								"Type": "INVITE_BUYER",
								"Content": "\"/invite `%buyer`%\""
							}
						}
					},
					"3": {
						"Icon": "Trade",
						"Actions": {
							"1": {
								"Type": "TRADE_BUYER",
								"Content": "\"/tradewith `%buyer`%\""
							}
						}
					},
					"4": {
						"Icon": "Kick",
						"Actions": {
							"1": {
								"Type": "KICK_BUYER",
								"Content": "\"/kick `%buyer`%\""
							},
							"2": {
								"Type": "SAVE_TRADE_STATS",
								"Content": "\"\""
							},
							"3": {
								"Type": "CLOSE_TAB",
								"Content": "\"\""
							}
						}
					}
				}
			},
			"BUY_INTERFACE": {
				"Mode": "Tabs",
				"CUSTOM_BUTTON_ROW_1": {
					"Buttons_Count": 0
				},
				"CUSTOM_BUTTON_ROW_2": {
					"Buttons_Count": 0
				},
				"CUSTOM_BUTTON_ROW_3": {
					"Buttons_Count": 0
				},
				"CUSTOM_BUTTON_ROW_4": {
					"Buttons_Count": 4,
					"1": {
						"Icon": "Whisper",
						"Actions": {
							"1": {
								"Type": "WRITE_TO_SELLER",
								"Content": "\"@`%seller`% \""
							}
						}
					},
					"2": {
						"Icon": "Hideout",
						"Actions": {
							"1": {
								"Type": "HIDEOUT_SELLER",
								"Content": "\"/hideout `%seller`%\""
							}
						}
					},
					"3": {
						"Icon": "ThumbsUp",
						"Actions": {
							"1": {
								"Type": "SEND_TO_SELLER",
								"Content": "\"@`%seller`% ty, gl!\""
							},
							"2": {
								"Type": "KICK_MYSELF",
								"Content": "\"/kick %myself%\""
							},
							"3": {
								"Type": "SAVE_TRADE_STATS",
								"Content": "\"\""
							},
							"4": {
								"Type": "CLOSE_TAB",
								"Content": "\"\""
							}
						}
					},
					"4": {
						"Text": "SRY",
						"Actions": {
							"1": {
								"Type": "SEND_TO_SELLER",
								"Content": "\"@`%seller`% sry, got another\""
							},
							"2": {
								"Type": "CLOSE_TAB",
								"Content": "\"\""
							}
						}
					}
				}
			},

			"HOTKEYS": {
				"1": {
					"Name": "Hideout",
					"Hotkey": "F2",
					"Actions": {
						"1": {
							"Type": "CMD_HIDEOUT",
							"Content": "\"/hideout\""
						}
					}
				},
				"2": {
					"Name": "Kick self + Hideout",
					"Hotkey": "+F2",
					"Actions": {
						"1": {
							"Type": "KICK_MYSELF",
							"Content": "\"/kick %myself%\""
						},
						"2": {
							"Type": "CMD_HIDEOUT",
							"Content": "\"/hideout\""
						}
					}
				}
			},

			"UPDATING": {
				"PID": %ScriptPid%,
				"FileName": "%ScriptName%",
				"FileProcessName": "%filePName%",
				"ScriptHwnd": "%ScriptHwnd%",
				"Version": "%ProgramVersion%",
				"CheckForUpdatePeriodically": "OnStartAndEveryFiveHours",
				"DownloadUpdatesAutomatically": "True",
				"UseBeta": "True",
				"LastUpdateCheck": "19940426000000"
			}
		}
	)
	; Replacing paths n stuff
	for key, value in poeSkinSettings.COLORS {
		newAppend := """" key """: " """" value """"
		fullAppend := fullAppend?fullAppend "`n," newAppend : newAppend
	}
	settings := StrReplace(settings, "%poeSettingsColors%", fullAppend)
	
	; Loading json obj, return
	return JSON.Load(settings)	
}

LocalSettings_VerifyValuesValidity(obj="") {
	; Make sure values are valid, and reset them if not 
	global PROGRAM

	; Getting settings
	defaultSettings := Get_LocalSettings_DefaultValues()
	if !FileExist(PROGRAM.SETTINGS_FILE) { ; Just saving default and return
		Save_LocalSettings(defaultSettings)
		return
	}
	settings := Get_LocalSettings()
	finalSettings := ObjFullyClone(defaultSettings)

	; GENERAL section
	for key in defaultSettings.GENERAL {
		value := settings.GENERAL[key], defValue := defaultSettings.GENERAL[key]

		if IsIn(key, "IsFirstTimeRunning,AddShowGridActionToInviteButtons,HasAskedForImport,RemoveCopyItemInfosIfGridActionExists"
		. ",ReplaceOldTradeVariables,UpdateKickMyselfOutOfPartyHideoutHotkey,AskForLanguage")
			isValid := IsIn(value, "True,False") ? True : False
		else if (key = "Language")
			isValid := IsIn(iniValue, "english,french,chinese_simplified,chinese_traditional") ? True : False
		else isValid := False

		finalSettings.GENERAL[key] := isValid?value:defValue
	}
	; SETTINGS_MAIN section
	for key in defaultSettings.SETTINGS_MAIN {
		value := settings.SETTINGS_MAIN[key], defValue := defaultSettings.SETTINGS_MAIN[key]

		if IsIn(key, "TradingWhisperSFXToggle,RegularWhisperSFXToggle,BuyerJoinedAreaSFXToggle"
		. ",HideInterfaceWhenOutOfGame,CopyItemInfosOnTabChange,AutoFocusNewTabs,AutoMinimizeOnAllTabsClosed,AutoMaximizeOnFirstNewTab,SendTradingWhisperUponCopyWhenHoldingCTRL"
		. ",TradesGUI_Locked,AllowClicksToPassThroughWhileInactive,ShowTabbedTrayNotificationOnWhisper,PushBulletOnlyWhenAfk,PushBulletOnTradingWhisper,PushBulletOnPartyMessage,PushBulletOnWhisperMessage"
		. ",MinimizeInterfaceToBottomLeft,ItemGridHideNormalTab,ItemGridHideQuadTab,ItemGridHideNormalTabAndQuadTabForMaps,ShowItemGridWithoutInvite,DisableBuyInterface")
			isValid := IsIn(value, "True,False") ? True : False
		else if IsIn(key, "TradingWhisperSFXPath,RegularWhisperSFXPath,BuyerJoinedAreaSFXPath")
			isValid := FileExist(value) ? True : False
		else if IsIn(key, "NoTabsTransparency,TabsOpenTransparency")
			isValid := IsBetween(value, 0, 100) && (key="NoTabsTransparency") ? True : IsBetween(value, 30, 100) && (key="TabsOpenTransparency") ? True : False
		else if (key = "TradesGUI_Mode")
			isValid := IsIn(value, "Window,Dock") ? True : False
		else if IsIn(key, "PushBulletToken,PoeAccounts")
			isValid := True
		else isValid := False

		finalSettings.SETTINGS_MAIN[key] := isValid?value:defValue
	}
	; SETTINGS_CUSTOMIZATION_SKINS section
	skinList := GUI_Settings.TabCustomizationSkins_GetAvailablePresets(), skinsList := StrReplace(skinsList, "|", ",")
	fontsList := GUI_Settings.TabCustomizationSkins_GetAvailableFonts(), fontsList := StrReplace(fontsList, "|", ",")
	Loop 2 {
		sectionKey := A_Index=1?"SETTINGS_CUSTOMIZATION_SKINS":"SETTINGS_CUSTOMIZATION_SKINS_UserDefined"
		for key in defaultSettings[sectionKey] {
			value := settings[sectionKey][key], defValue := defaultSettings[sectionKey][key]

			if IsIn(key, "UseRecommendedFontSettings")
				isValid := IsIn(value, "True,False") ? True : False
			else if IsIn(key, "FontSize,FontQuality,ScalingPercentage")
				isValid := IsNum(value) ? True : False
			else if IsIn(key, "Preset,Skin")
				isValid := IsIn(value, skinList) ? True : False
			else if (key = "Font")
				isValid := IsIn(value, fontsList) ? True : False
			else isValid := False 

			finalSettings[sectionKey][key] := isValid?value:defValue
		}
		for key in defaultSettings[sectionKey].COLORS {
			value := settings[sectionKey].COLORS[key], defValue := defaultSettings[sectionKey].COLORS[key]
			isValid := IsHex(value) && (StrLen(value) = 8) ? True : False
			finalSettings[sectionKey].COLORS[key] := isValid?value:defValue
		}
	}
	; SELL_INTERFACE section
	/*
	for key, value in settings.SELL_INTERFACE { ; For every row name
		if IsObject(settings.SELL_INTERFACE[key]) {
			for key2, value2 in settings.SELL_INTERFACE[key] { ; For every button num
				if (key2 = "Buttons_Count")
					isValid := IsNum(value2) ? True : False
				else if IsObject(settings.SELL_INTERFACE[key][key2]) {
					for key3, value3 in settings.SELL_INTERFACE[key][key2] {
						
					}
				}
				else isValid := False  
			}
		}
	}
	*/

	; HOTKEYS section
	for key, value in settings.HOTKEYS {
		isValid := True
	}

	; UPDATING section
	for key in defaultSettings.UPDATING {
		value := settings.UPDATING[key], defValue := defaultSettings.UPDATING[key]

		if IsIn(iniKey, "UseBeta,DownloadUpdatesAutomatically")
			isValid := IsIn(value,"True,False") ? True : False
		else if (key = "CheckForUpdatePeriodically")
			isValid := IsIn(value, "OnStartOnly,OnStartAndEveryFiveHours,OnStartAndEveryDay") ? True : False
		else if (key = "LastUpdateCheck") {
			FormatTime, timeF, %value%, yyyyMMddhhmmss
			isValid := (value > A_Now || timeF > A_Now || StrLen(value) != 14)?False : True
		}

		finalSettings.UPDATING[key] := isValid?value:defValue
	}
	
	Save_LocalSettings(finalSettings)
}

Restore_LocalSettings(obj, iniKey="") {
	global PROGRAM
	defaultSettings := Get_LocalSettings_DefaultValues()
	settings := Get_LocalSettings()

	

	if (iniKey = "") { ; Replace entire section
		for key, value in PROGRAM.SETTINGS[iniSect]
			INI.Remove(iniFile, iniSect, key)

		for key, value in defSettings[iniSect]
			INI.Set(iniFile, iniSect, key, value)
	}
	else {
		INI.Set(iniFile, iniSect, iniKey, defSettings[iniSect][iniKey])
	}
}

LocalSettings_VerifyEncoding() {
	; Make sure encoding is UTF 16
	global PROGRAM
	settingsFile := PROGRAM.SETTINGS_FILE

	; Opening obj and verifying encoding
	hFile := FileOpen(settingsFile, "r")
	if (hFile.Encoding != "UTF-16") { ; Wrong encoding
		; Read file content
		AppendToLogs(A_ThisFunc "(): Wrong ini file encoding (" hFile.Encoding "). Making backup and creating new file with UTF-16 encoding.")
		fileContent := hFile.Read()
		hFile.Close()
		; Rename old file
		SplitPath, settingsFile, fileName, fileFolder
		FileMove,% settingsFile,% fileFolder "\" A_Now "_" fileName ".bak", 1
		; Make new file with old content
		hFile := FileOpen(settingsFile, "w", "UTF-16")
		hFile.Write(fileContent)
		hFile.Close()
	}
}

Save_LocalSettings(settingsObj="") {
	; Save the content of PROGRAM.SETTINGS in the local settings file
	global PROGRAM
	settingsFile := PROGRAM.SETTINGS_FILE
	if !IsObject(settingsObj)
		settingsObj := ObjFullyClone(PROGRAM.SETTINGS)
	; Making backup of old file
	SplitPath, settingsFile, fileName, fileFolder
	FileMove,% settingsFile,% fileFolder "\" fileName ".bak", 1
	; Setting content into the settings file
	jsonText := JSON.Dump(settingsObj, "", "`t")
	hFile := FileOpen(settingsFile, "w", "UTF-16")
	hFile.Write(jsonText)
	hFile.Close()
	Declare_LocalSettings(settingsObj)
}

Declare_LocalSettings(settingsObj="") {
	global PROGRAM

	if !IsObject(settingsObj)
		settingsObj := Get_LocalSettings()

	PROGRAM["SETTINGS"] := {}
	PROGRAM["SETTINGS"] := ObjFullyClone(settingsObj)
}