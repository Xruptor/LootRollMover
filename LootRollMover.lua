LootRollMover = {};
LootRollMover.version = GetAddOnMetadata("LootRollMover", "Version")

local _G = _G

function LootRollMover:SetupDB()

	--remove old DB
	if LootRollMoverDB then
		LootRollMoverDB = nil
	end

	--check new DB
	if not LRMDB then
		LRMDB = {}
	end
	
	--check for window position if not available then load default
	if LRMDB and not LRMDB["LootRollMoverAnchor_Frame"] then
		LRMDB["LootRollMoverAnchor_Frame"] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}	
	end
	
	if LRMDB.scale == nil then LRMDB.scale = 1 end
	
end


function LootRollMover:Enable()

	--database setup (check for updates to db)
	LootRollMover:SetupDB()
	
	--lets create the GUI
	LootRollMover:DrawGUI();
	
	--load the position hook for saved location
	LootRollMover:LoadPositionHook()

	--show loading notification
	LootRollMover:Print("Version ["..LootRollMover.version.."] loaded. /lrm");

end

function LootRollMover:Print(msg)
	if not msg then return end
	if type(msg) == 'table' then

		local success,err = pcall(function(msg) return table.concat(msg, ", ") end, msg)
		
		if success then
			msg = "Table: "..table.concat(msg, ", ")
		else
			msg = "Table: Error, table cannot contain sub tables."
		end
	end
	
	msg = tostring(msg)
	msg = "|cFF80FF00LootRollMover|r: " .. msg
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

function LootRollMover:AnchorToggle()
	if LootRollMoverAnchor_Frame:IsVisible() then
		LootRollMoverAnchor_Frame:Hide()
	else
		LootRollMoverAnchor_Frame:Show()
	end
end

function LootRollMover:AnchorReset()
	LootRollMoverAnchor_Frame:ClearAllPoints()
	LootRollMoverAnchor_Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	LootRollMoverAnchor_Frame:Show();
end

function LootRollMover:DrawGUI()

	local frame = CreateFrame("Frame", "LootRollMoverAnchor_Frame", UIParent)
	
	frame:SetFrameStrata("DIALOG")
	frame:SetWidth(GroupLootFrame1:GetWidth())
	frame:SetHeight(GroupLootFrame1:GetHeight())

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function() this:StartMoving() end )
	frame:SetScript("OnDragStop", function() 
		this:StopMovingOrSizing() 
	end )
	frame:SetScript("OnMouseDown", function()
		if arg1 == "RightButton" then
			LootRollMover:SaveLayout("LootRollMoverAnchor_Frame")
			LootRollMoverAnchor_Frame:Hide()

			LootRollMover:LoadPositionHook()
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
	
	--restore saved layout
	LootRollMover:RestoreLayout("LootRollMoverAnchor_Frame");
	
end

function LootRollMover:SaveLayout(frame)

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

	local point,relativeTo,relativePoint,xOfs,yOfs = getglobal(frame):GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function LootRollMover:RestoreLayout(frame)

	local f = getglobal(frame);
	
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

function LootRollMover:LoadPositionHook()
	local frame = _G["GroupLootFrame1"]
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMLEFT", LootRollMoverAnchor_Frame, "BOTTOMLEFT", 4, 2)
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

--------------------------------------------------------------------------------------
---MOD START
--------------------------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "LootRollMoverEventFrame", UIParent)
eventFrame:RegisterEvent("ADDON_LOADED");

eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and arg1 == "LootRollMover" then
		LootRollMover:Enable()
	end
end)


local function SlashCommand(cmd)

	local a,b,c=strfind(cmd, "(%S+)"); --contiguous string of non-space characters
	
	if a then
		if c and c:lower() == "show" then
			LootRollMover:AnchorToggle()
			return true
		elseif c and c:lower() == "reset" then
			LootRollMover:AnchorReset()
			return true
		elseif c and c:lower() == "scale" then
			if b then
				local scalenum = strsub(cmd, b+2)
				if scalenum and scalenum ~= "" and tonumber(scalenum) then
					LRMDB.scale = tonumber(scalenum)
					LootRollMoverAnchor_Frame:SetScale(tonumber(scalenum))
					--do group loop scales
					LootRollMover:LoadPositionHook()
					LootRollMover:Print("Loot scale has been set to ["..tonumber(scalenum).."]")
					return true
				end
			end
		end
	end
	
	LootRollMover:Print("/lrm show - Toggle moveable anchor")
	LootRollMover:Print("/lrm reset - Reset anchor position")
	LootRollMover:Print("/lrm scale # - Set the scale of the Loot Frames (Default 1)")
 	
 	return false
end

SLASH_LOOTROLLMOVER1 = "/lrm";
SLASH_LOOTROLLMOVER2 = "/lootrollmover";
SlashCmdList["LOOTROLLMOVER"] = SlashCommand;


