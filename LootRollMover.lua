--LootRollMover by Xruptor
-- Changes made:
-- - Centralized and localized hot-path globals for fewer lookups and safer access.
-- - Made addon enable and hook setup idempotent to avoid repeated work.
-- - Added defensive guards around frame access and scaling to reduce errors and taint risk.
-- - Streamlined event handling and slash parsing for clarity and early returns.

local _G = _G
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local hooksecurefunc = _G.hooksecurefunc
local IsLoggedIn = _G.IsLoggedIn
local IsAddOnLoaded = _G.IsAddOnLoaded
local print = _G.print
local tonumber = tonumber
local tostring = tostring
local type = type
local string_format = string.format
local string_lower = string.lower
local string_match = string.match

local ADDON_NAME, private = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
local addon = _G[ADDON_NAME]

-- Locale files load with the addon's private table (2nd return from "...").
addon.private = private
addon.L = (private and private.L) or addon.L or {}
local L = addon.L

local function PrintMessage(message)
	if message == nil then return end
	local prefix = string_format("|cFF99CC33%s|r: ", ADDON_NAME)
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
	else
		print(prefix .. message)
	end
end

addon.PrintMessage = PrintMessage

local ANCHOR_BACKDROP = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local ANCHOR_OFFSET_X = 4
local ANCHOR_OFFSET_Y = 2
local STACK_STEP_Y = 3
local LOOT_ANCHOR_NAME = "LootRollMoverAnchor_Frame"
local ALERT_ANCHOR_NAME = "LRM_AlertFrame_Anchor"
local XAM_ADDON_NAME = "xanAchievementMover"

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC
--local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local WOW_PROJECT_WRATH_CLASSIC = _G.WOW_PROJECT_WRATH_CLASSIC

addon.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
addon.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
--BSYC.IsTBC_C = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
addon.IsWLK_C = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC

local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local arg1 = ...
		if arg1 == ADDON_NAME then
			self:UnregisterEvent("ADDON_LOADED")
			if IsLoggedIn() then
				self:EnableAddon(event, ...)
			else
				self:RegisterEvent("PLAYER_LOGIN")
			end
		end
		return
	end

	if event == "PLAYER_LOGIN" then
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end

	local handler = self[event]
	if handler then
		return handler(self, event, ...)
	end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", OnEvent)

local function CanAccessObject(obj)
	if not obj then return false end
	if type(obj.IsForbidden) == "function" and obj:IsForbidden() then
		return false
	end
	return true
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

local function IsEditModeActive()
	local manager = _G.EditModeManagerFrame
	if manager then
		if type(manager.IsEditModeActive) == "function" then
			local ok, active = pcall(manager.IsEditModeActive, manager)
			if ok then return active end
		end
		if manager.editModeActive ~= nil then
			return manager.editModeActive
		end
	end
	if _G.C_EditMode and type(_G.C_EditMode.IsEditModeActive) == "function" then
		local ok, active = pcall(_G.C_EditMode.IsEditModeActive)
		if ok then return active end
	end
	return false
end

local function IsTalkingHeadActive()
	local th = _G.TalkingHeadFrame
	if not th then return false end
	if type(th.IsShown) == "function" and th:IsShown() then
		return true
	end
	return false
end

addon.ClampScale = ClampScale
local GetMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
local RepositionLootFrames
local SetupHooks
local SetupXamWatcher

local function IsAddonLoaded(name)
	if not name then return false end
	if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded then
		return _G.C_AddOns.IsAddOnLoaded(name)
	end
	if type(IsAddOnLoaded) == "function" then
		return IsAddOnLoaded(name)
	end
	return false
end

local function IsXanAchievementMoverLoaded()
	return IsAddonLoaded(XAM_ADDON_NAME)
end

local function IsAlertSystemEnabled()
	if type(LRMDB) ~= "table" then
		return true
	end
	if LRMDB.alertEnabled == nil then
		return true
	end
	return LRMDB.alertEnabled
end

function addon:IsAlertAnchorEnabled()
	return IsAlertSystemEnabled() and not IsXanAchievementMoverLoaded()
end

local function GetManagedPositions()
	local managedPositions = _G.UIPARENT_MANAGED_FRAME_POSITIONS
	if type(managedPositions) == "table" then
		return managedPositions
	end
	return nil
end

function addon:UpdateAlertFramePositionManager()
	local alertFrame = _G.AlertFrame
	if not alertFrame then return end

	if self:IsAlertAnchorEnabled() then
		if not self._alertFrameManagedOverride then
			local managedPositions = GetManagedPositions()
			if managedPositions then
				self._alertFrameManagedBackup = managedPositions["AlertFrame"]
				managedPositions["AlertFrame"] = nil
			end
			self._alertFrameManagedIgnoreBackup = alertFrame.ignoreFramePositionManager
			self._alertFrameManagedOverride = true
		end
		alertFrame.ignoreFramePositionManager = true
	else
		if self._alertFrameManagedOverride and not IsXanAchievementMoverLoaded() then
			local managedPositions = GetManagedPositions()
			if managedPositions then
				managedPositions["AlertFrame"] = self._alertFrameManagedBackup
			end
			self._alertFrameManagedBackup = nil
			self._alertFrameManagedOverride = false
			alertFrame.ignoreFramePositionManager = self._alertFrameManagedIgnoreBackup
			self._alertFrameManagedIgnoreBackup = nil
		end
	end
end

function addon:HandleXanAchievementMoverLoaded()
	if self._xamHandled then return end
	self._xamHandled = true

	local alertAnchor = _G[ALERT_ANCHOR_NAME]
	if alertAnchor then
		alertAnchor:Hide()
	end

	self:UpdateAlertFramePositionManager()

	if _G.AlertFrame and _G.AlertFrame.UpdateAnchors then
		_G.AlertFrame:UpdateAnchors()
	end
end

local function EnsureLayout(frameName)
	if type(frameName) ~= "string" then return nil end
	if not _G[frameName] then return nil end
	LRMDB = LRMDB or {}

	local opt = LRMDB[frameName]
	if not opt then
		opt = {}
		LRMDB[frameName] = opt
	end

	if opt.point == nil then opt.point = "CENTER" end
	if opt.relativePoint == nil then opt.relativePoint = "CENTER" end
	if opt.xOfs == nil then opt.xOfs = 0 end
	if opt.yOfs == nil then opt.yOfs = 0 end

	return opt
end

local function CreateAnchorFrame(name, width, height, labelText, r, g, b, scale)
	local frame = _G[name]
	if not frame then
		frame = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	end

	frame:SetFrameStrata("DIALOG")
	frame:SetSize(width, height)
	frame:EnableMouse(true)
	frame:SetMovable(true)

	if not frame._lrm_scripts then
		frame._lrm_scripts = true
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
	end

	local label = frame._lrm_label
	if not label then
		label = frame:CreateFontString()
		label:SetAllPoints(frame)
		label:SetFontObject("GameFontNormalSmall")
		frame._lrm_label = label
	end
	label:SetText(labelText)

	frame:SetBackdrop(ANCHOR_BACKDROP)
	frame:SetBackdropColor(r, g, b, 1)
	frame:SetBackdropBorderColor(r, g, b, 1)
	SetScaleIfNeeded(frame, scale)
	frame:Hide()

	return frame
end

--[[------------------------
	ENABLE
--------------------------]]

function addon:EnableAddon()
	if self._enabled then return end
	self._enabled = true

	-- Ensure the Achievement UI is loaded so test alerts don't error before the frame exists.
	if type(_G.AchievementFrame_LoadUI) == "function" and not _G.AchievementFrame then
		_G.AchievementFrame_LoadUI()
	end

	local groupLootContainer = _G.GroupLootContainer
	if CanAccessObject(groupLootContainer) then
		groupLootContainer:EnableMouse(false)
	end

	if not self.IsRetail and _G.UIPARENT_MANAGED_FRAME_POSITIONS then
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	end

	--setup the DB
	LRMDB = LRMDB or {}
	if LRMDB.scale == nil then LRMDB.scale = 1 end
	if LRMDB.addonLoginMsg == nil then LRMDB.addonLoginMsg = true end
	if LRMDB.alertEnabled == nil then LRMDB.alertEnabled = true end
	LRMDB.scale = ClampScale(LRMDB.scale)

	--draw the anchor
	self:DrawAnchor()

	--restore previous layout
	self:RestoreLayout(LOOT_ANCHOR_NAME)
	if self:IsAlertAnchorEnabled() then
		self:RestoreLayout(ALERT_ANCHOR_NAME)
	end
	self:UpdateAlertFramePositionManager()

	--slash commands
	SLASH_LOOTROLLMOVER1 = "/lrm"
	local function PrintHelp()
		PrintMessage("Available commands:")
		PrintMessage("  /lrm "..L.SlashAnchor.." - "..L.SlashAnchorInfo)
		PrintMessage("  /lrm "..(L.SlashAlert or "alert").." - "..(L.AlertAnchorText or "Toggle Alert System"))
		PrintMessage("  /lrm "..L.SlashReset.." - "..L.SlashResetInfo)
		PrintMessage("  /lrm "..L.SlashScale.." # - "..L.SlashScaleInfo)
	end
	SlashCmdList["LOOTROLLMOVER"] = function(cmd)
		local subcmd, rest = string_match(cmd or "", "^%s*(%S+)%s*(.-)%s*$")
		if not subcmd then
			PrintHelp()
			return
		end
		subcmd = string_lower(subcmd)
		if subcmd == L.SlashAnchor then
			if addon.aboutPanel and addon.aboutPanel.btnAnchor then
				addon.aboutPanel.btnAnchor.func()
			end
			return
		elseif subcmd == L.SlashReset then
			if addon.aboutPanel and addon.aboutPanel.btnReset then
				addon.aboutPanel.btnReset.func()
			end
			return
		elseif subcmd == L.SlashScale then
			local scalenum = tonumber(rest)
			if scalenum and scalenum >= 0.5 and scalenum <= 5 then
				addon:SetScale(scalenum)
			else
				PrintMessage(L.SlashScaleSetInvalid)
			end
			return
		elseif subcmd == (L.SlashAlert or "alert") then
			addon:ToggleAlertSystem()
			return
		end

		PrintHelp()
	end

	if addon.configFrame then addon.configFrame:EnableConfig() end
	SetupHooks() -- hooks are applied after login to avoid duplicate work and ensure Blizzard frames exist.
	SetupXamWatcher()
	if self:IsAlertAnchorEnabled() then
		-- Ensure alert subsystems are anchored to the LRM alert anchor once we are enabled.
		if _G.AlertFrame and _G.AlertFrame.UpdateAnchors then
			_G.AlertFrame:UpdateAnchors()
		end
	end

	if LRMDB.addonLoginMsg then
		local ver = (GetMetadata and GetMetadata(ADDON_NAME, "Version")) or "1.0"
		PrintMessage(string_format("[v|cFF20ff20%s|r] loaded:   /lrm", ver or "1.0"))
	end
end

--[[------------------------
	CORE
--------------------------]]

--replace the grouplootframe show, it has fixanchors in it
--http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/LootFrame.lua

RepositionLootFrames = function()
	if not _G[LOOT_ANCHOR_NAME] then return end
	if not LRMDB then return end
	local frame
	local scale = ClampScale(LRMDB.scale)
	if LRMDB.scale ~= scale then LRMDB.scale = scale end

	local groupLootContainer = _G.GroupLootContainer
	if CanAccessObject(groupLootContainer) then
		groupLootContainer:ClearAllPoints()
		groupLootContainer:SetPoint("BOTTOMLEFT", _G[LOOT_ANCHOR_NAME], "BOTTOMLEFT", ANCHOR_OFFSET_X, ANCHOR_OFFSET_Y)
		SetScaleIfNeeded(groupLootContainer, scale)
	end

	local bonusRollFrame = _G.BonusRollFrame
	if CanAccessObject(bonusRollFrame) then
		bonusRollFrame:ClearAllPoints()
		bonusRollFrame:SetPoint("BOTTOMLEFT", _G[LOOT_ANCHOR_NAME], "BOTTOMLEFT", ANCHOR_OFFSET_X, ANCHOR_OFFSET_Y)
		SetScaleIfNeeded(bonusRollFrame, scale)

		local maxFrames = _G.NUM_GROUP_LOOT_FRAMES or 4
		for i=1, maxFrames do
			frame = _G["BonusRollFrame" .. i]
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				if i == 1 then
					frame:SetPoint("BOTTOM", "BonusRollFrame", "TOP", 0, STACK_STEP_Y)
				else
					frame:SetPoint("BOTTOM", "BonusRollFrame" .. (i-1), "TOP", 0, STACK_STEP_Y)
				end
				SetScaleIfNeeded(frame, scale)
			end
		end
	end
	local maxFrames = _G.NUM_GROUP_LOOT_FRAMES or 4
	for i=1, maxFrames do
		frame = _G["GroupLootFrame" .. i]
		if i == 1 then
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", _G[LOOT_ANCHOR_NAME], "BOTTOMLEFT", ANCHOR_OFFSET_X, ANCHOR_OFFSET_Y)
				SetScaleIfNeeded(frame, scale)
			end
		elseif i > 1 then
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, STACK_STEP_Y)
				SetScaleIfNeeded(frame, scale)
			end
		end
	end
end

-- Achievement-related subsystems (long toast + criteria).
local function IsAchievementSubSystem(alertFrameSubSystem)
	return alertFrameSubSystem
		and (alertFrameSubSystem == _G.AchievementAlertSystem
			or alertFrameSubSystem == _G.CriteriaAlertSystem)
end

local function IsTalkingHeadSubSystem(alertFrameSubSystem)
	if not alertFrameSubSystem then return false end
	local th = _G.TalkingHeadFrame
	if not th then return false end
	if alertFrameSubSystem.anchorFrame == th or alertFrameSubSystem.alertFrame == th then
		return true
	end
	if alertFrameSubSystem.alertFrame and alertFrameSubSystem.alertFrame.GetName then
		local name = alertFrameSubSystem.alertFrame:GetName()
		if name and name == "TalkingHeadFrame" then
			return true
		end
	end
	if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame.GetName then
		local name = alertFrameSubSystem.anchorFrame:GetName()
		if name and name == "TalkingHeadFrame" then
			return true
		end
	end
	return false
end

-- Run AdjustAnchors for a filtered set of subsystems against a start anchor.
local function ApplySubSystemAnchors(subsystems, startAnchor, shouldAnchor)
	if not startAnchor then return end
	local relativeFrame = startAnchor
	for i = 1, #subsystems do
		local subSystem = subsystems[i]
		if subSystem and subSystem.AdjustAnchors and shouldAnchor(subSystem) then
			-- Clear existing points to avoid stacking offsets from prior anchoring passes.
			if subSystem.alertFramePool and subSystem.alertFramePool.EnumerateActive then
				for alertFrame in subSystem.alertFramePool:EnumerateActive() do
					alertFrame:ClearAllPoints()
				end
			elseif subSystem.alertFrame and subSystem.alertFrame.ClearAllPoints then
				subSystem.alertFrame:ClearAllPoints()
			elseif subSystem.anchorFrame and subSystem.anchorFrame.ClearAllPoints then
				subSystem.anchorFrame:ClearAllPoints()
			end
			relativeFrame = subSystem:AdjustAnchors(relativeFrame)
		end
	end
end

-- Anchor non-achievement alert subsystems to the LRM alert anchor.
local function FixAlertAnchors(self)
	if not addon:IsAlertAnchorEnabled() then return end
	if IsEditModeActive() then return end
	if IsTalkingHeadActive() then return end
	addon:UpdateAlertFramePositionManager()
	local container = self or _G.AlertFrame
	if not CanAccessObject(container) then return end
	local alertAnchor = _G[ALERT_ANCHOR_NAME]
	if not alertAnchor then return end

	if LRMDB then
		local scale = ClampScale(LRMDB.scale)
		if LRMDB.scale ~= scale then LRMDB.scale = scale end
		SetScaleIfNeeded(alertAnchor, scale)
		SetScaleIfNeeded(container, scale)
	end

	local subsystems = container.alertFrameSubSystems
	if type(subsystems) ~= "table" then return end

	ApplySubSystemAnchors(subsystems, alertAnchor, function(subSystem)
		return not IsAchievementSubSystem(subSystem) and not IsTalkingHeadSubSystem(subSystem)
	end)
end

--AlertFrame (are for Toasts like achievements but can show loot sometimes)
--https://www.wowinterface.com/forums/showthread.php?t=58990
local hookRegistry = {}
local function SafeHook(nameOrObject, method, callback)
	if not nameOrObject then return end
	local key = method and (tostring(nameOrObject) .. ":" .. method) or tostring(nameOrObject)
	if hookRegistry[key] then return end
	hookRegistry[key] = true
	local func = callback or RepositionLootFrames
	if method then
		hooksecurefunc(nameOrObject, method, func)
	else
		hooksecurefunc(nameOrObject, func)
	end
end

local hooksApplied = false
local alertHooksApplied = false
local function SetupAlertHooks()
	if alertHooksApplied then return end
	if _G.AlertFrame_FixAnchors then
		SafeHook("AlertFrame_FixAnchors", nil, FixAlertAnchors)
	end
	if _G.AlertFrame and _G.AlertFrame.UpdateAnchors then
		SafeHook(_G.AlertFrame, "UpdateAnchors", FixAlertAnchors)
	end
	addon:UpdateAlertFramePositionManager()
	alertHooksApplied = true
end

SetupXamWatcher = function()
	if addon._xamWatcher then return end
	if IsXanAchievementMoverLoaded() then
		addon:HandleXanAchievementMoverLoaded()
		return
	end

	local watcher = CreateFrame("Frame")
	addon._xamWatcher = watcher
	watcher:RegisterEvent("ADDON_LOADED")
	watcher:SetScript("OnEvent", function(_, _, addonName)
		if addonName ~= XAM_ADDON_NAME then return end
		addon:HandleXanAchievementMoverLoaded()
		watcher:UnregisterEvent("ADDON_LOADED")
	end)
end

SetupHooks = function()
	if hooksApplied then return end
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
	if addon:IsAlertAnchorEnabled() then
		SetupAlertHooks()
	end

	hooksApplied = true
end

-- hooks are applied during EnableAddon to avoid early missing globals.

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

	local scale = ClampScale(LRMDB and LRMDB.scale)
	if LRMDB then LRMDB.scale = scale end

	local groupLootFrame = _G.GroupLootFrame1
	local groupWidth = (groupLootFrame and groupLootFrame.GetWidth and groupLootFrame:GetWidth()) or 277
	local groupHeight = (groupLootFrame and groupLootFrame.GetHeight and groupLootFrame:GetHeight()) or 67
	if not groupWidth or groupWidth <= 0 then groupWidth = 277 end
	if not groupHeight or groupHeight <= 0 then groupHeight = 67 end

	CreateAnchorFrame(
		LOOT_ANCHOR_NAME,
		groupWidth,
		groupHeight,
		L.LRM_Anchor.."\n\n"..L.DragFrameInfo,
		0.75, 0, 0,
		scale
	)

	--Alert Frame anchor
	----------------------------------------------
	if self:IsAlertAnchorEnabled() then
		local alertBase = _G.AlertFrame
		local alertWidth = (alertBase and alertBase.GetWidth and alertBase:GetWidth()) or 249
		local alertHeight = (alertBase and alertBase.GetHeight and alertBase:GetHeight()) or 71

		--https://www.townlong-yak.com/framexml/live/Blizzard_FrameXML/AlertFrameSystems.xml
		if not alertWidth or alertWidth < 15 then alertWidth = 249 end
		if not alertHeight or alertHeight < 15 then alertHeight = 71 end

		CreateAnchorFrame(
			ALERT_ANCHOR_NAME,
			alertWidth,
			alertHeight,
			L.Alert_Anchor.."\n\n"..L.DragFrameInfo,
			0, 0.75, 0,
			scale
		)
	end
end

function addon:SetScale(value)
	local scale = ClampScale(value)
	LRMDB.scale = scale
	PrintMessage(string_format(L.SlashScaleSet, scale))
	if _G[LOOT_ANCHOR_NAME] then
		_G[LOOT_ANCHOR_NAME]:SetScale(scale)
	end
	if self:IsAlertAnchorEnabled() then
		if _G[ALERT_ANCHOR_NAME] then
			_G[ALERT_ANCHOR_NAME]:SetScale(scale)
		end
		local alertFrame = _G.AlertFrame
		if CanAccessObject(alertFrame) then
			SetScaleIfNeeded(alertFrame, scale)
		end
	end
end

function addon:ToggleAlertSystem()
	LRMDB = LRMDB or {}
	LRMDB.alertEnabled = not IsAlertSystemEnabled()

	local alertAnchor = _G[ALERT_ANCHOR_NAME]
	if self:IsAlertAnchorEnabled() then
		if not alertAnchor then
			self:DrawAnchor()
			alertAnchor = _G[ALERT_ANCHOR_NAME]
		end
		if alertAnchor then
			self:RestoreLayout(ALERT_ANCHOR_NAME)
			alertAnchor:Show()
		end
		SetupAlertHooks()
	else
		if alertAnchor then
			alertAnchor:Hide()
		end
	end

	self:UpdateAlertFramePositionManager()

	if _G.AlertFrame and _G.AlertFrame.UpdateAnchors then
		_G.AlertFrame:UpdateAnchors()
	end
end


--[[------------------------
	LAYOUT SAVE/RESTORE
--------------------------]]
function addon:SaveLayout(frame)
	if frame == ALERT_ANCHOR_NAME and not self:IsAlertAnchorEnabled() then return end
	local opt = EnsureLayout(frame)
	if not opt then return end

	local point, _, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function addon:RestoreLayout(frame)
	if frame == ALERT_ANCHOR_NAME and not self:IsAlertAnchorEnabled() then return end
	local opt = EnsureLayout(frame)
	if not opt then return end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end
