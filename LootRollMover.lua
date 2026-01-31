--LootRollMover by Xruptor

local ADDON_NAME, private = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
local addon = _G[ADDON_NAME]

-- Locale files load with the addon's private table (2nd return from "...").
addon.private = private
addon.L = (private and private.L) or addon.L or {}
local L = addon.L

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC
--local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local WOW_PROJECT_WRATH_CLASSIC = _G.WOW_PROJECT_WRATH_CLASSIC

addon.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
addon.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
--BSYC.IsTBC_C = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
addon.IsWLK_C = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		if event == "ADDON_LOADED" then
			local arg1 = ...
			if arg1 and arg1 == ADDON_NAME then
				self:UnregisterEvent("ADDON_LOADED")
				self:RegisterEvent("PLAYER_LOGIN")
			end
			return
		end
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if self[event] then
		return self[event](self, event, ...)
	end
end)

local function CanAccessObject(obj)
	return obj and (issecure() or not obj:IsForbidden())
end

local function ClampScale(value)
	value = tonumber(value) or 1
	if value < 0.5 then return 0.5 end
	if value > 5 then return 5 end
	return value
end

local function SetScaleIfNeeded(frame, scale)
	if frame and frame.GetScale and frame:GetScale() ~= scale then
		frame:SetScale(scale)
	end
end

addon.ClampScale = ClampScale
local GetMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local RepositionLootFrames
local SetupHooks

--[[------------------------
	ENABLE
--------------------------]]

function addon:EnableAddon()

	if CanAccessObject(_G.GroupLootContainer) then
		_G.GroupLootContainer:EnableMouse(false)
	end

	if not self.IsRetail and _G.UIPARENT_MANAGED_FRAME_POSITIONS then
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	end

	--setup the DB
	if not LRMDB then LRMDB = {} end
	if LRMDB.scale == nil then LRMDB.scale = 1 end
	if LRMDB.addonLoginMsg == nil then LRMDB.addonLoginMsg = true end
	LRMDB.scale = ClampScale(LRMDB.scale)

	--draw the anchor
	self:DrawAnchor()

	--restore previous layout
	self:RestoreLayout("LootRollMoverAnchor_Frame")
	self:RestoreLayout("LRM_AlertFrame_Anchor")

	--slash commands
	SLASH_LOOTROLLMOVER1 = "/lrm"
	local function PrintHelp()
		DEFAULT_CHAT_FRAME:AddMessage(ADDON_NAME, 64/255, 224/255, 208/255)
		DEFAULT_CHAT_FRAME:AddMessage("/lrm "..L.SlashAnchor.." - "..L.SlashAnchorInfo)
		DEFAULT_CHAT_FRAME:AddMessage("/lrm "..L.SlashReset.." - "..L.SlashResetInfo)
		DEFAULT_CHAT_FRAME:AddMessage("/lrm "..L.SlashScale.." # - "..L.SlashScaleInfo)
	end
	SlashCmdList["LOOTROLLMOVER"] = function(cmd)
		local subcmd, rest = cmd:match("^%s*(%S+)%s*(.-)%s*$")
		if not subcmd then
			PrintHelp()
			return
		end
		subcmd = subcmd:lower()
		if subcmd == L.SlashAnchor then
			addon.aboutPanel.btnAnchor.func()
			return
		elseif subcmd == L.SlashReset then
			addon.aboutPanel.btnReset.func()
			return
		elseif subcmd == L.SlashScale then
			local scalenum = tonumber(rest)
			if scalenum and scalenum >= 0.5 and scalenum <= 5 then
				addon:SetScale(scalenum)
			else
				DEFAULT_CHAT_FRAME:AddMessage(L.SlashScaleSetInvalid)
			end
			return
		end

		PrintHelp()
	end

	if addon.configFrame then addon.configFrame:EnableConfig() end
	SetupHooks()

	if LRMDB.addonLoginMsg then
		local ver = (GetMetadata and GetMetadata(ADDON_NAME, "Version")) or "1.0"
		DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /lrm", ADDON_NAME, ver or "1.0"))
	end
end

--[[------------------------
	CORE
--------------------------]]

--replace the grouplootframe show, it has fixanchors in it
--http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/LootFrame.lua

RepositionLootFrames = function()
	if not _G.LootRollMoverAnchor_Frame or not _G.LRM_AlertFrame_Anchor then return end
	if not LRMDB then return end
	local frame
	local scale = ClampScale(LRMDB.scale)
	if LRMDB.scale ~= scale then LRMDB.scale = scale end

	if _G.GroupLootContainer and CanAccessObject(_G.GroupLootContainer) then
		_G.GroupLootContainer:ClearAllPoints()
		_G.GroupLootContainer:SetPoint("BOTTOMLEFT", _G.LootRollMoverAnchor_Frame, "BOTTOMLEFT", 4, 2)
		SetScaleIfNeeded(_G.GroupLootContainer, scale)
	end

	if _G.AlertFrame and CanAccessObject(_G.AlertFrame) then
		_G.AlertFrame:ClearAllPoints()
		_G.AlertFrame:SetPoint("CENTER", _G.LRM_AlertFrame_Anchor, "BOTTOM", 0, -15)
		SetScaleIfNeeded(_G.AlertFrame, scale)

		--do each individual alert frame that is queued
		--for i, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
			--alertFrameSubSystem:SetScale(LRMDB.scale)
		--end

		--set the base anchor frame location, it's usually the default AlertFrame but just in case it changes
		--_G.AlertFrame.baseAnchorFrame:ClearAllPoints()
		--_G.AlertFrame.baseAnchorFrame:SetPoint("BOTTOMLEFT", _G.LRM_AlertFrame_Anchor, "BOTTOMLEFT", 4, 2)
	end

	if BonusRollFrame and CanAccessObject(BonusRollFrame) then
		BonusRollFrame:ClearAllPoints()
		BonusRollFrame:SetPoint("BOTTOMLEFT", _G.LootRollMoverAnchor_Frame, "BOTTOMLEFT", 4, 2)
		SetScaleIfNeeded(BonusRollFrame, scale)

		for i=1, NUM_GROUP_LOOT_FRAMES or 4 do
			frame = _G["BonusRollFrame" .. i]
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				if i == 1 then
					frame:SetPoint("BOTTOM", "BonusRollFrame", "TOP", 0, 3)
				else
					frame:SetPoint("BOTTOM", "BonusRollFrame" .. (i-1), "TOP", 0, 3)
				end
				SetScaleIfNeeded(frame, scale)
			end
		end
	end
	for i=1, NUM_GROUP_LOOT_FRAMES or 4 do
		frame = _G["GroupLootFrame" .. i]
		if i == 1 then
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", _G.LootRollMoverAnchor_Frame, "BOTTOMLEFT", 4, 2)
				SetScaleIfNeeded(frame, scale)
			end
		elseif i > 1 then
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, 3)
				SetScaleIfNeeded(frame, scale)
			end
		end
	end
end

--AlertFrame (are for Toasts like achievements but can show loot sometimes)
--https://www.wowinterface.com/forums/showthread.php?t=58990
local hookRegistry = {}
local function SafeHook(nameOrObject, method)
	if not nameOrObject then return end
	local key = method and (tostring(nameOrObject) .. ":" .. method) or tostring(nameOrObject)
	if hookRegistry[key] then return end
	hookRegistry[key] = true
	if method then
		hooksecurefunc(nameOrObject, method, RepositionLootFrames)
	else
		hooksecurefunc(nameOrObject, RepositionLootFrames)
	end
end

SetupHooks = function()
	if _G.GroupLootContainer_OnLoad then
		SafeHook("GroupLootContainer_OnLoad")
	end
	if _G.GroupLootContainer_RemoveFrame then
		SafeHook("GroupLootContainer_RemoveFrame")
	end
	if _G.GroupLootContainer_Update then
		SafeHook("GroupLootContainer_Update")
	end
	if _G.GroupLootFrame_OnShow then
		SafeHook("GroupLootFrame_OnShow")
	end

	--Bonus Rolls found on Live Servers
	if _G.BonusRollFrame_OnLoad then
		SafeHook("BonusRollFrame_OnLoad")
	end
	if _G.BonusRollFrame_StartBonusRoll then
		SafeHook("BonusRollFrame_StartBonusRoll")
	end
	if _G.BonusRollFrame_OnUpdate then
		SafeHook("BonusRollFrame_OnUpdate")
	end
	if _G.BonusRollFrame_OnShow then
		SafeHook("BonusRollFrame_OnShow")
	end

	--old AlertFrame FixAnchors, backwards compatible if found
	if _G.AlertFrame_FixAnchors then
		SafeHook("AlertFrame_FixAnchors")
	end
	if _G.AlertFrame and _G.AlertFrame.UpdateAnchors then
		SafeHook(_G.AlertFrame, "UpdateAnchors")
		_G.AlertFrame.ignoreFramePositionManager = true
	end
end

SetupHooks()

-- For testing Alert purposes
-- https://wowinterface.com/forums/showthread.php?t=53443

-- /run MoneyWonAlertSystem:AddAlert(815)
-- /run AchievementAlertSystem:AddAlert(5192)
-- /run CriteriaAlertSystem:ShowAlert(80,1)
-- /run GuildChallengeAlertSystem:AddAlert(3, 2, 5)
-- /run InvasionAlertSystem:AddAlert(1,20)
-- /run DigsiteCompleteAlertSystem:AddAlert(1)
--  /run LootUpgradeAlertSystem:AddAlert("|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0:80:0:0:0:0|h[Broken Fang]|h|r", 1, specID, 3, "Cesaor", 3, Awesome);
--  /run GarrisonFollowerAlertSystem:AddAlert(112, "Cool Guy", "100", 3, 1)
--  /run GarrisonShipFollowerAlertSystem:AddAlert(592, "Test", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
--  /run GarrisonBuildingAlertSystem:AddAlert("miau")
--  /run WorldQuestCompleteAlertSystem:AddAlert(112)

function addon:DrawAnchor()

	local backdrop = {
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	}

	local scale = ClampScale(LRMDB and LRMDB.scale)
	if LRMDB then LRMDB.scale = scale end

	local function CreateAnchorFrame(name, width, height, labelText, r, g, b)
		local frame = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
		frame:SetFrameStrata("DIALOG")
		frame:SetSize(width, height)
		frame:EnableMouse(true)
		frame:SetMovable(true)

		frame:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				self.isMoving = true
				self:StartMoving()
			else
				self:Hide()
			end
		end)
		frame:SetScript("OnMouseUp", function(self)
			if self.isMoving then
				self.isMoving = nil
				self:StopMovingOrSizing()
				addon:SaveLayout(self:GetName())
			end
		end)

		local stringA = frame:CreateFontString()
		stringA:SetAllPoints(frame)
		stringA:SetFontObject("GameFontNormalSmall")
		stringA:SetText(labelText)

		frame:SetBackdrop(backdrop)
		frame:SetBackdropColor(r, g, b, 1)
		frame:SetBackdropBorderColor(r, g, b, 1)
		frame:SetScale(scale)
		frame:Hide()

		return frame
	end

	local groupLootFrame = _G.GroupLootFrame1
	local groupWidth = (groupLootFrame and groupLootFrame.GetWidth and groupLootFrame:GetWidth()) or 277
	local groupHeight = (groupLootFrame and groupLootFrame.GetHeight and groupLootFrame:GetHeight()) or 67
	if not groupWidth or groupWidth <= 0 then groupWidth = 277 end
	if not groupHeight or groupHeight <= 0 then groupHeight = 67 end

	CreateAnchorFrame(
		"LootRollMoverAnchor_Frame",
		groupWidth,
		groupHeight,
		L.LRM_Anchor.."\n\n"..L.DragFrameInfo,
		0.75, 0, 0
	)

	--Alert Frame anchor
	----------------------------------------------
	local alertBase = _G.AlertFrame
	local alertWidth = (alertBase and alertBase.GetWidth and alertBase:GetWidth()) or 249
	local alertHeight = (alertBase and alertBase.GetHeight and alertBase:GetHeight()) or 71

	--https://www.townlong-yak.com/framexml/live/Blizzard_FrameXML/AlertFrameSystems.xml
	if not alertWidth or alertWidth < 15 then alertWidth = 249 end
	if not alertHeight or alertHeight < 15 then alertHeight = 71 end

	CreateAnchorFrame(
		"LRM_AlertFrame_Anchor",
		alertWidth,
		alertHeight,
		L.Alert_Anchor.."\n\n"..L.DragFrameInfo,
		0, 0.75, 0
	)
end

function addon:SetScale(value)
	local scale = ClampScale(value)
	LRMDB.scale = scale
	DEFAULT_CHAT_FRAME:AddMessage(string.format(L.SlashScaleSet, scale))
	if _G.LootRollMoverAnchor_Frame then
		_G.LootRollMoverAnchor_Frame:SetScale(scale)
	end
	if _G.LRM_AlertFrame_Anchor then
		_G.LRM_AlertFrame_Anchor:SetScale(scale)
	end
end


--[[------------------------
	LAYOUT SAVE/RESTORE
--------------------------]]
function addon:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not LRMDB then LRMDB = {} end

	local opt = LRMDB[frame] or nil

	if not opt then
		LRMDB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = LRMDB[frame]
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function addon:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not LRMDB then LRMDB = {} end

	local opt = LRMDB[frame] or nil

	if not opt then
		LRMDB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = LRMDB[frame]
	end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end
