local donerino = false

local ArenaFramesCam_EventFrame = CreateFrame("Frame")
ArenaFramesCam_EventFrame:RegisterEvent("ADDON_LOADED")
ArenaFramesCam_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ArenaFramesCam_EventFrame:SetScript("OnEvent", function(self,event,...) self[event](self,event,...);end)

--init
function ArenaFramesCam_EventFrame:ADDON_LOADED(self, addon)
	if addon == "ArenaFramesCam" then 
		if not ArenaFramesCamDB then
			ArenaFramesCamDB = {
				setPlayerBottom = true,
				useFlameCat = true,
				stanceBar = true,
				useBottomRightBarForVehicles = false
			}
		end
		
		--create flame cat button and set its attribute based on setting
		flameCatBtn = CreateFrame("Button", "flameCatBtn", UIParent, "SecureActionButtonTemplate")
		flameCatBtn:SetAttribute("type", "item")
		ArenaFramesCam_flameCatBtnSetting()
	end
end

function ArenaFramesCam_EventFrame:PLAYER_ENTERING_WORLD()
	--assess whether we should customize certain things and then do/don't
	ArenaFramesCam_setArenaFramesAndCam()
	ArenaFramesCam_setStanceBar()
	ArenaFramesCam_SetVehicleBar()
end


--slash commands
SLASH_ARENAFRAMESCAM1 = "/arenaframescam"
SLASH_ARENAFRAMESCAM2 = "/afc"

function SlashCmdList.ARENAFRAMESCAM(msg)
	msg = string.lower(msg)
	if msg == "" then -- toggle setPlayerBottom if there is no message
		if ArenaFramesCamDB.setPlayerBottom then 
			ArenaFramesCamDB.setPlayerBottom = false
			print("|cFF00FF00Default group sort.")
		else
			ArenaFramesCamDB.setPlayerBottom = true
			print("|cFF00FF00Player always on the bottom.")
		end
		ArenaFramesCam_setArenaFramesAndCam()

	elseif msg == "fc" or msg == "flamecat" or msg == "c" then  --toggle use of fandral's seed pouch
		if ArenaFramesCamDB.useFlameCat then 
			ArenaFramesCamDB.useFlameCat = false
			print("|cFFFFA500Fandral's Seed Pouch Disabled.")
			CancelUnitBuff("player", "Burning Essence")
		else
			ArenaFramesCamDB.useFlameCat = true
			print("|cFFFFA500Fandral's Seed Pouch Enabled.")
		end
		ArenaFramesCam_flameCatBtnSetting()

	elseif msg == "f" or msg == "fix" then
		ArenaFramesCamDB.setPlayerBottom = false
		print("|cFF00FF00Default group sort.")
		ReloadUI()

	elseif msg == "s" or msg == "stance" or msg == "sb" then 
		if ArenaFramesCamDB.stanceBar then 
			ArenaFramesCamDB.stanceBar = false
			print("|cFF00FF00Stance Bar Hidden.")
		else
			ArenaFramesCamDB.stanceBar = true
			print("|cFF00FF00Stance Bar Shown.")
		end
		ArenaFramesCam_setStanceBar()

	elseif msg == "v" or msg == "vb" or msg == "vehiclebinds" then 
		if ArenaFramesCamDB.useBottomRightBarForVehicles then 
			ArenaFramesCamDB.useBottomRightBarForVehicles = false
			print("|cFF00FF00Vehicle Bar binds set to default.")
		else
			ArenaFramesCamDB.useBottomRightBarForVehicles = true
			print("|cFF00FF00Vehicle Bar will work with BottomRight action bar binds.")
		end
		ArenaFramesCam_SetVehicleBar()

	elseif msg == "test" or msg == "t" then -- TEST CODE
											-- END TEST CODE
	else
		print("Invalid Command.")
	end

end

--my sort function
function ArenaFramesCam_playerOnBottom(t1, t2) 
	if UnitIsUnit(t1,"player") then 
		return false 
	elseif UnitIsUnit(t2,"player") then 
		return true
	else
		return t1 < t2 
	end 
end 

-- function ArenaFramesCam_setArenaFramesAndCam()
-- 	local name,type,_ = GetInstanceInfo()
-- 	if donerino == false then
-- 		--LoadAddOn("CompactRaidFrameContainer")
-- 		function CRFSort_Group(t1, t2) 
-- 			if UnitIsUnit(t1,"player") then 
-- 				return false 
-- 			elseif UnitIsUnit(t2,"player") then 
-- 				return true
-- 			else
-- 				return t1 < t2 
-- 			end 
-- 		end 
-- 		CompactRaidFrameContainer.flowSortFunc=CRFSort_Group
-- 		donerino = true
-- 	end
-- end

--set sort layout
function ArenaFramesCam_setArenaFramesAndCam()
	if ArenaFramesCamDB.setPlayerBottom then
		CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, ArenaFramesCam_playerOnBottom)
	else
		CompactRaidFrameContainer_SetFlowSortFunction(CompactRaidFrameContainer, CRFSort_Group)
	end
end

--use flamecat (or not)
function ArenaFramesCam_flameCatBtnSetting()
	if ArenaFramesCamDB.useFlameCat then
		flameCatBtn:SetAttribute("item", "Fandral's Seed Pouch")
	else
		flameCatBtn:SetAttribute("item", nil)
	end
end

--stance bar handlers
function ArenaFramesCam_setStanceBar()
	if ArenaFramesCamDB.stanceBar then 
		StanceBarFrame:Show()
		UnregisterStateDriver(StanceBarFrame, "visibility")
	else
		StanceBarFrame:Hide()
		RegisterStateDriver(StanceBarFrame, "visibility", "hide")
	end
end

function ArenaFramesCam_SetVehicleBar()
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

-- change arena enemy nameplate names
local U=UnitIsUnit 
hooksecurefunc("CompactUnitFrame_UpdateName",
	function(F)
		if IsActiveBattlefieldArena() and F.unit:find("nameplate") then 
			for i=1,5 do
				if U(F.unit,"arena" .. i) then 
					F.name:SetText("arena " .. i)
					F.name:SetTextColor(1,1,0)
					break 
				end 
			end 
		end 
	end)
