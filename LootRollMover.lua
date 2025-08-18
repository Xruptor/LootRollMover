--LootRollMover by Xruptor

local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

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
	return issecure() or not obj:IsForbidden();
end

--[[------------------------
	ENABLE
--------------------------]]

function addon:EnableAddon()

	_G.GroupLootContainer:EnableMouse(false)

	if not self.IsRetail then
		_G.UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	end

	--setup the DB
	if not LRMDB then LRMDB = {} end
	if LRMDB.scale == nil then LRMDB.scale = 1 end
	if LRMDB.addonLoginMsg == nil then LRMDB.addonLoginMsg = true end

	--draw the anchor
	self:DrawAnchor()

	--restore previous layout
	self:RestoreLayout("LootRollMoverAnchor_Frame")

	--slash commands
	SLASH_LOOTROLLMOVER1 = "/lrm"
	SlashCmdList["LOOTROLLMOVER"] = function(cmd)
		local a,b,c=strfind(cmd, "(%S+)"); --contiguous string of non-space characters

		if a then
			if c and c:lower() == L.SlashAnchor then
				addon.aboutPanel.btnAnchor.func()
				return true
			elseif c and c:lower() == L.SlashReset then
				addon.aboutPanel.btnReset.func()
				return true
			elseif c and c:lower() == L.SlashScale then
				if b then
					local scalenum = strsub(cmd, b+2)
					if scalenum and scalenum ~= "" and tonumber(scalenum) and tonumber(scalenum) >= 0.5 and tonumber(scalenum) <= 5 then
						addon:SetScale(tonumber(scalenum))
					else
						DEFAULT_CHAT_FRAME:AddMessage(L.SlashScaleSetInvalid)
					end
					return true
				end
			end
		end

		DEFAULT_CHAT_FRAME:AddMessage(ADDON_NAME, 64/255, 224/255, 208/255)
		DEFAULT_CHAT_FRAME:AddMessage("/lrm "..L.SlashAnchor.." - "..L.SlashAnchorInfo)
		DEFAULT_CHAT_FRAME:AddMessage("/lrm "..L.SlashReset.." - "..L.SlashResetInfo)
		DEFAULT_CHAT_FRAME:AddMessage("/lrm "..L.SlashScale.." # - "..L.SlashScaleInfo)

	end

	if addon.configFrame then addon.configFrame:EnableConfig() end

	if LRMDB.addonLoginMsg then
		local ver = C_AddOns.GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
		DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /lrm", ADDON_NAME, ver or "1.0"))
	end
end

--[[------------------------
	CORE
--------------------------]]

--replace the grouplootframe show, it has fixanchors in it
--http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/LootFrame.lua

local function RepositionLootFrames()
	if not _G["LootRollMoverAnchor_Frame"] then return end
	if not LRMDB then return end
	local frame
	frame = _G["GroupLootContainer"]

	if frame and CanAccessObject(frame) then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", _G["LootRollMoverAnchor_Frame"], "BOTTOMLEFT", 4, 2)
		frame:SetScale(LRMDB.scale)
	end
	if BonusRollFrame and CanAccessObject(BonusRollFrame) then
		BonusRollFrame:ClearAllPoints()
		BonusRollFrame:SetPoint("BOTTOMLEFT", _G["LootRollMoverAnchor_Frame"], "BOTTOMLEFT", 4, 2)
		BonusRollFrame:SetScale(LRMDB.scale)

		for i=1, NUM_GROUP_LOOT_FRAMES or 4 do
			frame = _G["BonusRollFrame" .. i]
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOM", "BonusRollFrame" .. (i-1), "TOP", 0, 3)
				frame:SetScale(LRMDB.scale)
			end
		end
	end
	for i=1, NUM_GROUP_LOOT_FRAMES or 4 do
		frame = _G["GroupLootFrame" .. i]
		if i == 1 then
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOMLEFT", _G["LootRollMoverAnchor_Frame"], "BOTTOMLEFT", 4, 2)
				frame:SetScale(LRMDB.scale)
			end
		elseif i > 1 then
			if frame and CanAccessObject(frame) then
				frame:ClearAllPoints()
				frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, 3)
				frame:SetScale(LRMDB.scale)
			end
		end
	end
end

--AlertFrame (are for Toasts like achievements but can show loot sometimes)
--https://www.wowinterface.com/forums/showthread.php?t=58990
if _G["GroupLootContainer_OnLoad"] then
	hooksecurefunc("GroupLootContainer_OnLoad", RepositionLootFrames)
end
if _G["GroupLootContainer_RemoveFrame"] then
	hooksecurefunc("GroupLootContainer_RemoveFrame", RepositionLootFrames)
end
if _G["GroupLootContainer_Update"] then
	hooksecurefunc("GroupLootContainer_Update", RepositionLootFrames)
end
if _G["GroupLootFrame_OnShow"] then
	hooksecurefunc("GroupLootFrame_OnShow", RepositionLootFrames)
end

--Bonus Rolls found on Live Servers
if _G["BonusRollFrame_OnLoad"] then
	hooksecurefunc("BonusRollFrame_OnLoad", RepositionLootFrames)
end
if _G["BonusRollFrame_StartBonusRoll"] then
	hooksecurefunc("BonusRollFrame_StartBonusRoll", RepositionLootFrames)
end
if _G["BonusRollFrame_OnUpdate"] then
	hooksecurefunc("BonusRollFrame_OnUpdate", RepositionLootFrames)
end
if _G["BonusRollFrame_OnShow"] then
	hooksecurefunc("BonusRollFrame_OnShow", RepositionLootFrames)
end

function addon:DrawAnchor()

	local frame = CreateFrame("Frame", "LootRollMoverAnchor_Frame", UIParent, BackdropTemplateMixin and "BackdropTemplate")

	frame:SetFrameStrata("DIALOG")

	local width = GroupLootFrame1:GetWidth()
	local height = GroupLootFrame1:GetHeight()

	if not width or width < 0 then width = 277 end
	if not height or height < 0 then height = 67 end

	frame:SetWidth(width)
	frame:SetHeight(height)

	frame:EnableMouse(true)
	frame:SetMovable(true)

	frame:SetScript("OnMouseDown",function(self, button)
		if button == "LeftButton" then
			self.isMoving = true
			self:StartMoving()
		else
			self:Hide()
		end

	end)
	frame:SetScript("OnMouseUp",function(self)
		if( self.isMoving ) then
			self.isMoving = nil
			self:StopMovingOrSizing()

			addon:SaveLayout(self:GetName())
		end
	end)

	local stringA = frame:CreateFontString()
	stringA:SetAllPoints(frame)
	stringA:SetFontObject("GameFontNormalSmall")
	stringA:SetText(L.DragFrameInfo)

	frame:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	frame:SetBackdropColor(0.75,0,0,1)
	frame:SetBackdropBorderColor(0.75,0,0,1)

	--fix this in case it's ever smaller than 
	if LRMDB.scale < 0.5 then LRMDB.scale = 0.5 end --anything smaller and it would vanish
	if LRMDB.scale > 5 then LRMDB.scale = 5 end --WAY too big
	frame:SetScale(LRMDB.scale)

	frame:Hide()
end

function addon:SetScale(value)
	LRMDB.scale = value
	DEFAULT_CHAT_FRAME:AddMessage(string.format(L.SlashScaleSet, value))
	_G["LootRollMoverAnchor_Frame"]:SetScale(LRMDB.scale)
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
		return
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
