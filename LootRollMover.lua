--LootRollMover by Xruptor

local f = CreateFrame("frame","LRMFrame",UIParent)
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

--[[------------------------
	ENABLE
--------------------------]]

function f:PLAYER_LOGIN()

	--setup the DB
	if not LRMDB then LRMDB = {} end
	if LRMDB.scale == nil then LRMDB.scale = 1 end
	
	--draw the anchor
	self:DrawAnchor()
	
	--restore previous layout
	self:RestoreLayout("LootRollMoverAnchor_Frame")
	
	--slash commands
	SLASH_LOOTROLLMOVER1 = "/lrm"
	SLASH_LOOTROLLMOVER2 = "/lootrollmover"
	SlashCmdList["LOOTROLLMOVER"] = function(cmd)
		local a,b,c=strfind(cmd, "(%S+)"); --contiguous string of non-space characters
		
		if a then
			if c and c:lower() == "show" then
				if not _G["LootRollMoverAnchor_Frame"] then return end
				_G["LootRollMoverAnchor_Frame"]:Show()
				return true
			elseif c and c:lower() == "reset" then
				if not _G["LootRollMoverAnchor_Frame"] then return end
				_G["LootRollMoverAnchor_Frame"]:ClearAllPoints()
				_G["LootRollMoverAnchor_Frame"]:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				_G["LootRollMoverAnchor_Frame"]:Show()
				DEFAULT_CHAT_FRAME:AddMessage("LootRollMover: Frame position has been reset!")
				return true
			elseif c and c:lower() == "scale" then
				if b then
					local scalenum = strsub(cmd, b+2)
					if scalenum and scalenum ~= "" and tonumber(scalenum) then
						if not _G["LootRollMoverAnchor_Frame"] then return end
						_G["LootRollMoverAnchor_Frame"]:SetScale(tonumber(scalenum))
						LRMDB.scale = tonumber(scalenum)
						DEFAULT_CHAT_FRAME:AddMessage("LootRollMover: scale has been set to ["..tonumber(scalenum).."]")
						return true
					end
				end
			end
		end

		DEFAULT_CHAT_FRAME:AddMessage("LootRollMover");
		DEFAULT_CHAT_FRAME:AddMessage("/lrm show - Toggle moveable anchor")
		DEFAULT_CHAT_FRAME:AddMessage("/lrm reset - Reset anchor position")
		DEFAULT_CHAT_FRAME:AddMessage("/lrm scale # - Set the scale of the Loot Frames (Default 1)")

	end
	
	local ver = GetAddOnMetadata("LootRollMover","Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFFDF2B2B%s|r] Loaded", "LootRollMover", ver or "1.0"))
	
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
	if ( frame ) then
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", _G["LootRollMoverAnchor_Frame"], "BOTTOMLEFT", 4, 2)
		frame:SetParent(UIParent)
		frame:SetScale(LRMDB.scale)
	end
	for i=1, NUM_GROUP_LOOT_FRAMES do
		frame = _G["GroupLootFrame" .. i]
		if ( frame ) then
			frame:SetScale(LRMDB.scale)
		end
	end
end

hooksecurefunc("GroupLootContainer_OnLoad", RepositionLootFrames)
hooksecurefunc("GroupLootContainer_RemoveFrame", RepositionLootFrames)
hooksecurefunc("GroupLootFrame_OnShow", RepositionLootFrames)
hooksecurefunc("GroupLootFrame_OpenNewFrame", RepositionLootFrames)
hooksecurefunc("GroupLootFrame_OnEvent", RepositionLootFrames)
hooksecurefunc("AlertFrame_FixAnchors", RepositionLootFrames)

function f:DrawAnchor()

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

			f:SaveLayout(self:GetName())
		end
	end)

	local stringA = frame:CreateFontString()
	stringA:SetAllPoints(frame)
	stringA:SetFontObject("GameFontNormalSmall")
	stringA:SetText("LootRollMover\n\nRight click when finished dragging")

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
function f:SaveLayout(frame)
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

function f:RestoreLayout(frame)
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

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
