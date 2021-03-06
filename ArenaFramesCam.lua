local addonName, AFC = ...; 
local donerino = false
local defaultResourcePoint
local defaultSecondaryPoint
local _

local ArenaFramesCam_EventFrame = CreateFrame("Frame")
ArenaFramesCam_EventFrame:RegisterEvent("ADDON_LOADED")
ArenaFramesCam_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ArenaFramesCam_EventFrame:SetScript("OnEvent", function(self,event,...) self[event](self,event,...);end)

--init
function ArenaFramesCam_EventFrame:ADDON_LOADED(self, addon)
	if addon == addonName then 
		if not ArenaFramesCamDB then -- Set defaults
			ArenaFramesCamDB = {
				setPlayerBottom = false,
				useFlameCat = true,
				stanceBar = true,
				useBottomRightBarForVehicles = false,
				moveClassResource = false,
				enableBarHideKeys = false, 
				hideMacroText = false,
				hideBindingText = false,
				waterwalking = false,
				hideBarArt = false,
				hideEndCaps = false
			}
		end
		
		--Check what class you are for class resource moving
		local playerClass = UnitClass("player")
		local classResourceFrame
		local classSecondaryFrame
		if playerClass == "Rogue" then 
			AFC.moveClassResource = AFC.Rouge
			classResourceFrame = ComboPointPlayerFrame
			defaultResourcePoint = {ComboPointPlayerFrame:GetPoint()}

		elseif playerClass == "Death Knight" then 
			AFC.moveClassResource = AFC.DK
			classResourceFrame = RuneFrame
			defaultResourcePoint = {RuneFrame:GetPoint()}

		elseif playerClass == "Monk" then 
			AFC.moveClassResource = AFC.Monk
			classResourceFrame = MonkHarmonyBarFrame
			classSecondaryFrame = MonkStaggerBar
			defaultResourcePoint = {MonkHarmonyBarFrame:GetPoint()}
			defaultSecondaryPoint = {MonkStaggerBar:GetPoint()}

		elseif playerClass == "Druid" then 
			AFC.moveClassResource = AFC.Druid
			classResourceFrame = ComboPointPlayerFrame
			defaultResourcePoint = {ComboPointPlayerFrame:GetPoint()}
		else
			AFC.moveClassResource = function() end
		end
		
		--create flame cat button and set its attribute based on setting
		flameCatBtn = CreateFrame("Button", "flameCatBtn", ArenaFramesCam_EventFrame, "SecureActionButtonTemplate")
		flameCatBtn:SetAttribute("type", "item")
		AFC.flameCatBtnSetting()

		--create buttons for bar hide hotkeys in their own frame so the bindings can be easily cleared if option is disabled
		BarHideKeysFrame = CreateFrame("Frame", "BarHideKeysFrame", ArenaFramesCam_EventFrame)

		hideRightActionBarBtn = CreateFrame("Button", "hideRightActionBarBtn", BarHideKeysFrame, "SecureActionButtonTemplate")
		hideRightActionBarBtn:SetAttribute("type", "macro")
		hideRightActionBarBtn:SetAttribute("macrotext", "/click InterfaceOptionsActionBarsPanelRight")

		hideBottomRightBarBtn = CreateFrame("Button", "hideBottomRightBarBtn", BarHideKeysFrame, "SecureActionButtonTemplate")
		hideBottomRightBarBtn:SetAttribute("type", "macro")
		hideBottomRightBarBtn:SetAttribute("macrotext", "/click InterfaceOptionsActionBarsPanelBottomRight")

		--create buttons for the walterwalking mount bind
		waterwalkingMountFrame = CreateFrame("Frame", "waterwalkingMountFrame", ArenaFramesCam_EventFrame)

		waterwalkingMountBtn = CreateFrame("Button", "waterwalkingMountBtn", waterwalkingMountFrame, "SecureActionButtonTemplate")
		waterwalkingMountBtn:SetAttribute("type", "macro")
		waterwalkingMountBtn:SetAttribute("macrotext", "/cast Azure Water Strider")

		-- create hooks for class resource frame
		if classResourceFrame then 
			hooksecurefunc(classResourceFrame,"SetPoint", AFC.moveClassResource)
			if classSecondaryFrame then
				hooksecurefunc(classSecondaryFrame,"SetPoint", AFC.moveClassResource)
			end
		end
	end
end

function ArenaFramesCam_EventFrame:PLAYER_ENTERING_WORLD()
	--assess whether we should customize certain things and then do/don't
	AFC.setArenaFramesAndCam()
	AFC.setStanceBar()
	AFC.SetVehicleBar()
	AFC.moveClassResource()
	AFC.setBarHideKeys()
	AFC.hideMacroText()
	AFC.hideBindingText()
	AFC.bindWaterwalkingMount()
end


--slash commands
SLASH_ARENAFRAMESCAM1 = "/arenaframescam"
SLASH_ARENAFRAMESCAM2 = "/afc"

function SlashCmdList.ARENAFRAMESCAM(msg)
	local green = "|cFF00FF00"
	local red = "|cFFFF0000"
	local blue = "|cFF0000FF"
	local yellow = "|cFFFFFF00"
	local orange = "|cFFFFA500"
	local white = "|cFFFFFFFF"
	msg = string.lower(msg)
	if msg == "" then
		print(green.."ArenaFramesCam Commands:"..
			"\narenaframes / af: Player always bottom of raid frames."..
			"\nflamecat / fc / c: Flame Kitty Toy macro"..
			"\nstance / sb / s: Hide/Show Stance Bar"..
			"\nvehiclebinds / vb / v: Use BottomRight bar bindings for vehicle ui"..
			"\nclassresource / cr: Move your class resource counter"..
			"\nhidebars / hb / bh: Enables SHIFT-6/7 for hiding action bars"..
			"\nmacrotext / m: hide macro text on action bars"..
			"\nbindingtext / b: hide binding text on action bars"..
			"\nhidebarart / ba: hides all the action bar artwork"..
			"\nhideendcaps / ec: hides the gryphon end caps")

	elseif msg == "arenaframes" or msg == "af" then -- toggle setPlayerBottom if there is no message
		if ArenaFramesCamDB.setPlayerBottom then 
			ArenaFramesCamDB.setPlayerBottom = false
			ReloadUI()
		else
			ArenaFramesCamDB.setPlayerBottom = true
			print(green.."Player always on the bottom.")
		end
		AFC.setArenaFramesAndCam()

	elseif msg == "fc" or msg == "flamecat" or msg == "c" then  --toggle use of fandral's seed pouch
		if ArenaFramesCamDB.useFlameCat then 
			ArenaFramesCamDB.useFlameCat = false
			print(orange.."Fandral's Seed Pouch Disabled.")
		else
			ArenaFramesCamDB.useFlameCat = true
			print(orange.."Fandral's Seed Pouch Enabled.")
		end
		AFC.flameCatBtnSetting()

	elseif msg == "s" or msg == "stance" or msg == "sb" then 
		if ArenaFramesCamDB.stanceBar then 
			ArenaFramesCamDB.stanceBar = false
			print(blue.."Stance Bar Hidden.")
		else
			ArenaFramesCamDB.stanceBar = true
			print(blue.."Stance Bar Shown.")
		end
		AFC.setStanceBar()

	elseif msg == "v" or msg == "vb" or msg == "vehiclebinds" then 
		if ArenaFramesCamDB.useBottomRightBarForVehicles then 
			ArenaFramesCamDB.useBottomRightBarForVehicles = false
			print("|cFF00FF00Vehicle Bar binds set to default.")
		else
			ArenaFramesCamDB.useBottomRightBarForVehicles = true
			print("|cFF00FF00Vehicle Bar will work with BottomRight action bar binds.")
		end
		AFC.SetVehicleBar()

	elseif msg == "classresource" or msg == "cr" or msg == "cp" then 
		if ArenaFramesCamDB.moveClassResource then 
			ArenaFramesCamDB.moveClassResource = false
			print(red.."Class resource moved to default position.")
		else
			ArenaFramesCamDB.moveClassResource = true
			print(red.."Class resource moved.")
		end
		AFC.moveClassResource()

	elseif msg == "barhide" or msg == "bh" or msg == "hb" then 
		if ArenaFramesCamDB.enableBarHideKeys then
			ArenaFramesCamDB.enableBarHideKeys = false
			print(blue.."Hide Bar HotKeys disabled.")
		else
			ArenaFramesCamDB.enableBarHideKeys = true
			print(blue.."Hide Bar HotKeys (SHIFT-6/7) enabled.")
		end
		AFC.setBarHideKeys()

	elseif msg == "macrotext" or msg == "m" then 
		if ArenaFramesCamDB.hideMacroText then
			ArenaFramesCamDB.hideMacroText = false
			print(white.."Macro Text Shown.")
		else
			ArenaFramesCamDB.hideMacroText = true
			print(white.."Macro Text Hidden.")
		end
		AFC.hideMacroText()

	elseif msg == "bindingtext" or msg == "b" then
		if ArenaFramesCamDB.hideBindingText then
			ArenaFramesCamDB.hideBindingText = false
			print(white.."Binding Text Shown.")
		else
			ArenaFramesCamDB.hideBindingText = true
			print(white.."Binding Text Hidden.")
		end
		AFC.hideBindingText()

	elseif msg == "bm" or msg == "mb" then 
		SlashCmdList.ARENAFRAMESCAM('m')
		SlashCmdList.ARENAFRAMESCAM('b')

	elseif msg == "ww" then 
		if ArenaFramesCamDB.waterwalking then 
			ArenaFramesCamDB.waterwalking = false
			print(blue.."Waterwalking mount unbound from Shift-`.")
		else
			ArenaFramesCamDB.waterwalking = true
			print(blue.."Waterwalking mount bound to Shift-`.")
		end
		AFC.bindWaterwalkingMount()

	elseif msg == "hidebarart" or msg == "ba" then 
		if ArenaFramesCamDB.hideBarArt then 
			ArenaFramesCamDB.hideBarArt = false
			print(orange.."Bar Art Shown.")
		else
			ArenaFramesCamDB.hideBarArt = true
			print(orange.."Bar Art Hidden.")
		end
		AFC.hideBarArt()
		AFC.hideEndCaps()

	elseif msg == "endcaps" or msg == "ec" then 
		if ArenaFramesCamDB.hideEndCaps then 
			ArenaFramesCamDB.hideEndCaps = false
			print(orange.."End Caps Shown.")
		else
			ArenaFramesCamDB.hideEndCaps = true
			print(orange.."End Caps Hidden.")
		end
		AFC.hideEndCaps()

	elseif msg == "test" or msg == "t" then -- TEST CODE
		testtab = {['key'] = 1, ['key2'] = 2}
		testtab2 = testtab
		testtab2['key'] = 42
		print(testtab['key'])
											-- END TEST CODE
	else
		print("Invalid Command.")
	end

end

--my sort function
function AFC.playerOnBottom(t1, t2) 
	if UnitIsUnit(t1,"player") then 
		return false 
	elseif UnitIsUnit(t2,"player") then 
		return true
	else
		return t1 < t2 
	end 
end 

--set sort layout
function AFC.setArenaFramesAndCam()
	if ArenaFramesCamDB.setPlayerBottom then 
		CRFSort_Group = AFC.playerOnBottom
	end
end

--use flamecat (or not)
function AFC.flameCatBtnSetting()
	if ArenaFramesCamDB.useFlameCat then
		flameCatBtn:SetAttribute("item", "Fandral's Seed Pouch")
	else
		flameCatBtn:SetAttribute("item", nil)

		-- excessively long code to cancel a buff.
		local i = 1
		local buff = {UnitBuff('player', i)}
		while buff[1] do
			if buff[1] == "Burning Essence" then
				CancelUnitBuff('player', i)
				buff[1] = nil
			else
				i = i + 1
				buff = {UnitBuff('player', i)}
			end
		end 
	end
end

--stance bar handlers
function AFC.setStanceBar()
	if ArenaFramesCamDB.stanceBar then 
		StanceBarFrame:Show()
		StanceBarFrame:SetScript("OnShow", function() end)
		UnregisterStateDriver(StanceBarFrame, "visibility")
		StanceBarFrame:Show()
	else
		StanceBarFrame:Hide()
		StanceBarFrame:SetScript("OnShow",function() if not InCombatLockdown() then StanceBarFrame:Hide() end end)
		RegisterStateDriver(StanceBarFrame, "visibility", "hide")
	end
end

-- set alternate vehicle UI binds to be BottomRightBar binds
function AFC.SetVehicleBar()
	if ArenaFramesCamDB.useBottomRightBarForVehicles then
		--build buttons
		AFCVehicleButtonFrame = CreateFrame("Frame", "AFCVehicleButtonFrame", UIParent)
		for i = 1,6 do 
			AFCVehicleButtonFrame["VehicleButton"..i] = CreateFrame("Button", "VehicleButton"..i, AFCVehicleButtonFrame, "SecureActionButtonTemplate")
			AFCVehicleButtonFrame["VehicleButton"..i]:SetAttribute("type", "macro")
			AFCVehicleButtonFrame["VehicleButton"..i]:SetAttribute("macrotext", 
					"/click [vehicleui] OverrideActionBarButton"..i.."; MultiBarBottomRightButton"..i)

			if select(1,GetBindingKey("MULTIACTIONBAR2BUTTON"..i)) then
				SetOverrideBinding(AFCVehicleButtonFrame, false, 
					select(1,GetBindingKey("MULTIACTIONBAR2BUTTON"..i), "CLICK VehicleButton"..i..":LeftButton"))
			end
		end
	else
		if AFCVehicleButtonFrame then 
			ClearOverrideBindings(AFCVehicleButtonFrame)
		end
	end 
end

-- Deal with Combo Points/Runes/Shadow/Orbs/Chi/etc
function AFC.Rouge(frame, anchPoint, parent, relPoint, x, y)
	local X, Y = 0, -201.5
	if ArenaFramesCamDB.moveClassResource then
		if parent ~= UIParent then 
			ComboPointPlayerFrame:ClearAllPoints()
			ComboPointPlayerFrame:SetPoint('CENTER', UIParent, 'CENTER', X, Y)
			ComboPointPlayerFrame:EnableMouse(false)
		end
	else
		if parent ~= defaultResourcePoint[2] then 
			ComboPointPlayerFrame:ClearAllPoints()
			ComboPointPlayerFrame:SetPoint(unpack(defaultResourcePoint))
			ComboPointPlayerFrame:EnableMouse(true)
		end
	end
end

function AFC.DK(frame, anchPoint, parent, relPoint, x, y)
	local X, Y = 6.6, -120
	if ArenaFramesCamDB.moveClassResource then
		if parent ~= UIParent then
			RuneFrame:SetScale(1.5)
			RuneFrame:ClearAllPoints()
			RuneFrame:SetPoint('CENTER', UIParent, 'CENTER', X, Y)
			for i = 1, 6 do 
				RuneFrame["Rune"..i]:EnableMouse(false) 
			end
		end
	else
		if parent ~= defaultResourcePoint[2] then
			RuneFrame:SetScale(1) 
			RuneFrame:ClearAllPoints()
			RuneFrame:SetPoint(unpack(defaultResourcePoint))
			RuneFrame:EnableMouse(true)
		end
	end
end

function AFC.Monk(frame, anchPoint, parent, relPoint, x, y)
	--local spec = select(2, GetSpecializationInfo(GetSpecialization()))
	local mhb = MonkHarmonyBarFrame
	local X, Y = .5,-184
	if ArenaFramesCamDB.moveClassResource then
		if parent ~= UIParent then
			mhb:ClearAllPoints()
			mhb:SetPoint('CENTER', UIParent, 'CENTER', X, Y)
			local k={ mhb:GetChildren()} 
			for _,c in ipairs(k) do 
				c:EnableMouse(false) 
			end
		end
	else
		if parent ~= defaultResourcePoint[2] then
			mhb:ClearAllPoints()
			mhb:SetPoint(unpack(defaultResourcePoint))
			mhb:EnableMouse(true)
		end
	end

	local msb = MonkStaggerBar
	local X, Y = 0, -184
	if ArenaFramesCamDB.moveClassResource then
		if parent ~= UIParent then 
			msb:ClearAllPoints()
			msb:SetPoint('CENTER', UIParent, 'CENTER', X, Y)
			msb:EnableMouse(false)
		end
	else
		if parent ~= defaultSecondaryPoint[2] then 
			msb:ClearAllPoints()
			msb:SetPoint(unpack(defaultSecondaryPoint))
			msb:EnableMouse(true)
		end
	end
end

function AFC.Druid(frame, anchPoint, parent, relPoint, x, y)
	local spec = select(2, GetSpecializationInfo(GetSpecialization()))
	local X, Y = 0, -215
	if ArenaFramesCamDB.moveClassResource and spec == "Feral" then
		if parent ~= UIParent then 
			ComboPointPlayerFrame:ClearAllPoints()
			ComboPointPlayerFrame:SetPoint('CENTER', UIParent, 'CENTER', X, Y)
			ComboPointPlayerFrame:EnableMouse(false)
		end
	else
		if parent ~= defaultResourcePoint[2] then 
			ComboPointPlayerFrame:ClearAllPoints()
			ComboPointPlayerFrame:SetPoint(unpack(defaultResourcePoint))
			ComboPointPlayerFrame:EnableMouse(true)
		end
	end
end

-- set Bar Hide HotKeys
function AFC.setBarHideKeys()
	if ArenaFramesCamDB.enableBarHideKeys then 
		SetOverrideBinding(BarHideKeysFrame, false, "SHIFT-6", "CLICK hideRightActionBarBtn:LeftButton")
		SetOverrideBinding(BarHideKeysFrame, false, "SHIFT-7", "CLICK hideBottomRightBarBtn:LeftButton")
	else
		ClearOverrideBindings(BarHideKeysFrame)
	end
end

-- hide macro text on action bars
function AFC.hideMacroText()
	local val
	if ArenaFramesCamDB.hideMacroText then 
		val = 0
	else
		val = 1
	end

	for i = 1, 12 do 
		_G["MultiBarBottomLeftButton"..i.."Name"]:SetAlpha(val) 
		_G["MultiBarBottomRightButton"..i.."Name"]:SetAlpha(val) 
		_G["ActionButton"..i.."Name"]:SetAlpha(val) 
	end
end

-- hide binding text on action bars
function AFC.hideBindingText()
	local val
	if ArenaFramesCamDB.hideBindingText then 
		val = 0
	else
		val = 1
	end

	for i = 1, 12 do 
		_G["MultiBarBottomLeftButton"..i.."HotKey"]:SetAlpha(val) 
		_G["MultiBarBottomRightButton"..i.."HotKey"]:SetAlpha(val) 
		_G["ActionButton"..i.."HotKey"]:SetAlpha(val) 
	end	
end

-- handle the water skitter waterwalking mount bind
function AFC.bindWaterwalkingMount()
	if ArenaFramesCamDB.waterwalking then
		SetOverrideBinding(waterwalkingMountFrame, false, "CTRL-`", "CLICK waterwalkingMountBtn:LeftButton")
	else
		ClearOverrideBindings(waterwalkingMountFrame)
	end
end

--deal with bar art
function AFC.hideBarArt()
	if ArenaFramesCamDB.hideBarArt then 
		MainMenuBarArtFrameBackground:Hide()
		MainMenuBarArtFrame.PageNumber:Hide()
		ActionBarUpButton:Hide()
		ActionBarDownButton:Hide()
	else
		MainMenuBarArtFrameBackground:Show()
		MainMenuBarArtFrame.PageNumber:Show()
		ActionBarUpButton:Show()
		ActionBarDownButton:Show()
	end
end

function AFC.hideEndCaps()
	if ArenaFramesCamDB.hideEndCaps or ArenaFramesCamDB.hideBarArt then
		MainMenuBarArtFrame.RightEndCap:Hide()
		MainMenuBarArtFrame.LeftEndCap:Hide()
	else
		MainMenuBarArtFrame.RightEndCap:Show()
		MainMenuBarArtFrame.LeftEndCap:Show()
	end
end

-- change arena enemy nameplate names
local U=UnitIsUnit 
local asd = {'A', 'S', 'D'}
hooksecurefunc("CompactUnitFrame_UpdateName",
	function(F)
		if IsActiveBattlefieldArena() and F.unit:find("nameplate") then 
			for i=1,5 do
				if U(F.unit,"arena" .. i) then 
					F.name:SetText("alt-" .. asd[i])
					F.name:SetTextColor(1,1,0)
					break 
				end 
			end 
		end 
	end)
