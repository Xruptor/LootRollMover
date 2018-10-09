--LootRollMover by Xruptor

local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent)
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

addon:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

--[[------------------------
	ENABLE
--------------------------]]

UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil

function addon:PLAYER_LOGIN()

	--setup the DB
	if not LRMDB then LRMDB = {} end
	if LRMDB.scale == nil then LRMDB.scale = 1 end
	
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
					if scalenum and scalenum ~= "" and tonumber(scalenum) and tonumber(scalenum) > 0 and tonumber(scalenum) <= 200 then
						addon.aboutPanel.sliderScale.func(tonumber(scalenum))
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
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /lrm", ADDON_NAME, ver or "1.0"))
	
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
	for i=1, NUM_GROUP_LOOT_FRAMES do
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

hooksecurefunc("GroupLootContainer_OnLoad", RepositionLootFrames)
hooksecurefunc("GroupLootContainer_RemoveFrame", RepositionLootFrames)
hooksecurefunc("GroupLootFrame_OnShow", RepositionLootFrames)
hooksecurefunc("GroupLootFrame_OpenNewFrame", RepositionLootFrames)
hooksecurefunc("GroupLootFrame_OnEvent", RepositionLootFrames)
hooksecurefunc("GroupLootContainer_Update", RepositionLootFrames)
--hooksecurefunc("AlertFrame_FixAnchors", RepositionLootFrames)

function addon:DrawAnchor()

	local frame = CreateFrame("Frame", "LootRollMoverAnchor_Frame", UIParent)

	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(GroupLootFrame1:GetWidth())
	frame:SetHeight(GroupLootFrame1:GetHeight())

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

	frame:SetScale(LRMDB.scale)

	frame:Hide()

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

if IsLoggedIn() then addon:PLAYER_LOGIN() else addon:RegisterEvent("PLAYER_LOGIN") end
