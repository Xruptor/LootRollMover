--LootRollMover by Xruptor

local f = CreateFrame("frame","LootRollMoverEventFrame",UIParent)
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
	
	--restore the position hooks for the group frames
	self:LoadPositionHook()
	
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

function f:LoadPositionHook()
	if not _G["LootRollMoverAnchor_Frame"] then return end
	if not LRMDB then return end
	
	local frame = _G["GroupLootFrame1"]
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", _G["LootRollMoverAnchor_Frame"], "BOTTOMLEFT", 4, 2)
	frame:SetParent(UIParent)
	frame:SetFrameLevel(0)
	frame:SetScale(LRMDB.scale)
	for i=2, NUM_GROUP_LOOT_FRAMES do
		frame = _G["GroupLootFrame" .. i]
		if i > 1 then
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOM", "GroupLootFrame" .. (i-1), "TOP", 0, 3)
			frame:SetParent(UIParent)
			frame:SetFrameLevel(0)
			frame:SetScale(LRMDB.scale)
		end
	end
end

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
			f:LoadPositionHook()
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

	local string = frame:CreateFontString()
	string:SetAllPoints(frame)
	string:SetFontObject("GameFontNormalSmall")
	string:SetText("LootRollMover\n\nRight click when finished dragging")

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

	local opt = LRMDB[frame]

	if not opt then
		LRMDB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = LRMDB[frame]
	end

	local point,relativeTo,relativePoint,xOfs,yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function f:RestoreLayout(frame)

	local f = _G[frame];

	local opt = LRMDB[frame]

	if not opt then
		LRMDB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = LRMDB[frame]
	end

	f:ClearAllPoints()
	f:SetPoint( opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs )
	f:Hide()
end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
