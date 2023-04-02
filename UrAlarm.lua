local UrAlarm = {}
_G.UrAlarm = UrAlarm
local frame1 = CreateUIComponent("Frame", "UrAlarmFrame1", "UIParent")
local up1, frame2, up2, frame3, up3
local function Print(str, ...)
	DEFAULT_CHAT_FRAME:AddMessage(str:format(...), 1, 1, 1)
end

SLASH_URALARM1 = "/uralarm"
SLASH_URALARM2 = "/ua"
SlashCmdList["URALARM"] = function()
	if XBARVERSION and XBARVERSION>=1.51 then
		XAddon_ShowPage("UrAlarmGUI")
	else
		ToggleUIFrame(UrAlarmGUI)
	end
end

local function Updat()
	local m = tonumber(os.date("%M"))
	local s = os.date("%S")
	if UrAlarmSet["Alarm"] then
		local set = UrAlarmSet["ATime"]
		up1 = GetTime() + (set:match("^..") * 3600 + set:match("^..(..)") * 60 + set:match("..$")) - (os.date("%H") * 3600 + m * 60 + s)
		frame1:Show()
	end
	if UrAlarmSet["Repeat"] and UrAlarmSet["RTime"]>0 then
		up2 = GetTime() + UrAlarmSet["RTime"] * 60
		frame2 = CreateUIComponent("Frame", "UrAlarmFrame2", "UIParent")
		frame2:SetScripts("OnUpdate", [=[ UrAlarm.Repeat() ]=])
		frame2:Show()
		_G.UrAlarmFrame2 = nil
	end
	if UrAlarmSet["Hourly"] or UrAlarmSet["HalfH"] then
		up3 = GetTime() + ((UrAlarmSet["HalfH"] and m<=29 and 29 or 59) - m) * 60 + 60 - os.date("%S")
		frame3 = CreateUIComponent("Frame", "UrAlarmFrame3", "UIParent")
		frame3:SetScripts("OnUpdate", [=[ UrAlarm.Chime() ]=])
		frame3:Show()
		_G.UrAlarmFrame3 = nil
	end
end

function UrAlarm.Event()
	local def = {
		["Alarm"] = false,
		["ATime"] = "122100",
		["Repeat"] = false,
		["RTime"] = 20,
		["Hourly"] = false,
		["HalfH"] = false,
	}
	for k, v in pairs(def) do
		if UrAlarmSet[k]==nil then
			UrAlarmSet[k] = v
		end
	end
	SaveVariables("UrAlarmSet")
	Updat()
	if XBARVERSION and XBARVERSION>=1.51 then
		XAddon_Register(
		{gui={{
			name = "UrAlarm",
			version = "Plus",
			window = "UrAlarmGUI",
		}},
		popup={{
			GetText = function() return "UrAlarm |cffBA8B61Plus|r" end,
			GetTooltip = function() return "/ua, /uralarm" end,
			OnClick = function() XAddon_ShowPage("UrAlarmGUI") end,
		}}})
	end
	Print("|cffBA8B61UrAlarm Plus|r loaded, type |cffBA8B61/ua|r to config.")
end

function UrAlarm.GUIShow(this)
	UrAlarmGUIAlarm:SetChecked(UrAlarmSet["Alarm"])
	UrAlarmGUIATime:SetText(UrAlarmSet["ATime"])
	UrAlarmGUIRepeat:SetChecked(UrAlarmSet["Repeat"])
	UrAlarmGUIRTime:SetText(UrAlarmSet["RTime"])
	UrAlarmGUIHourly:SetChecked(UrAlarmSet["Hourly"])
	UrAlarmGUIHalfH:SetChecked(UrAlarmSet["HalfH"])
	if UrAlarmSet["HalfH"] then UrAlarmGUIHourly:Disable() end
	UrAlarmGUITitle:SetText("UrAlarm")
	UrAlarmGUIAlarmName:SetText("Alarm")
	UrAlarmGUIATimeName:SetText("Time: ")
	UrAlarmGUIRepeatName:SetText("Repeat")
	UrAlarmGUIRTimeName:SetText("Time: ")
	UrAlarmGUIHourlyName:SetText("Hourly Chime")
	UrAlarmGUIHalfHName:SetText("Half Hourly Chime")
	if XBARVERSION and XBARVERSION>=1.51 then
		XAddon_Page(this)
		XAddon_HideBack1(this)
		UrAlarmGUITitle:SetText("")
	end
end

function UrAlarm.Save()
	UrAlarmSet["Alarm"] = UrAlarmGUIAlarm:IsChecked()
	UrAlarmSet["ATime"] = UrAlarmGUIATime:GetText()
	UrAlarmSet["Repeat"] = UrAlarmGUIRepeat:IsChecked()
	UrAlarmSet["RTime"] = tonumber(UrAlarmGUIRTime:GetText())
	UrAlarmSet["Hourly"] = UrAlarmGUIHourly:IsChecked()
	UrAlarmSet["HalfH"] = UrAlarmGUIHalfH:IsChecked()
	if not UrAlarmSet["Alarm"] then
		frame1:Hide()
	end
	if (not UrAlarmSet["Repeat"] or UrAlarmSet["RTime"]<1) and frame2 then
		frame2:Hide()
		frame2 = nil
	end
	if not UrAlarmSet["Hourly"] and not UrAlarmSet["HalfH"] and frame3 then
		frame3:Hide()
		frame3 = nil
	end
	Updat()
end

function UrAlarm.Alarm()
	if GetTime()>=up1 then
		if string.find(UrAlarmSet["ATime"], os.date("%H%M%S")) then
			Print("UrAlarm: |cffBA8B61%s|r %s - Alarm %s", os.date("%H:%M.%S"), TEXT("SC_DANCEFES_SUKI_MAKE15"), OFF)
			PlaySoundByPath("Interface/Addons/UrAlarm/sound.mp3")
			frame1:Hide()
			UrAlarmSet["Alarm"] = false
		end
	end
end

function UrAlarm.Repeat()
	if GetTime()>=up2 then
		up2 = GetTime() + UrAlarmSet["RTime"] * 60
		Print("UrAlarm: |cffBA8B61%s%s Repeat|r %s", UrAlarmSet["RTime"], UNIT_MINUTE, TEXT("SC_DANCEFES_SUKI_MAKE15"))
		PlaySoundByPath("Interface/Addons/UrAlarm/sound.mp3")
	end
end

function UrAlarm.Chime()
	if GetTime()>=up3 then
		if UrAlarmSet["Hourly"] and string.find("00", os.date("%M")) then
			up3 = GetTime() + (UrAlarmSet["HalfH"] and 1800 or 3600)
			Print("UrAlarm: |cffBA8B61Hourly Chime|r - %s", os.date("%H:%M"))
			PlaySoundByPath("Interface/Addons/UrAlarm/sound.mp3")
		elseif UrAlarmSet["HalfH"] and string.find("30", os.date("%M")) then
			up3 = GetTime() + 1800
			Print("UrAlarm: |cffBA8B61Half Hourly Chime|r - %s", os.date("%H:%M"))
			PlaySoundByPath("Interface/Addons/UrAlarm/sound.mp3")
		end
	end
end

_G.UrAlarmFrame1 = nil
frame1:SetScripts("OnLoad", [=[ this:RegisterEvent("VARIABLES_LOADED") UrAlarmSet = {} ]=])
frame1:SetScripts("OnEvent", [=[ UrAlarm.Event() ]=])
frame1:SetScripts("OnUpdate", [=[ UrAlarm.Alarm() ]=])
frame1:Hide()
