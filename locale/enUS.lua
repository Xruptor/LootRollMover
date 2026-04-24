local _, private = ...

local L = private:NewLocale("enUS", true)
if not L then return end

L.SlashAnchor = "anchor"
L.SlashAnchorText = "Toggle Frame Anchor"
L.SlashAnchorOn = "Anchor now [|cFF99CC33SHOWN|r]"
L.SlashAnchorOff = "Anchor now [|cFF99CC33HIDDEN|r]"
L.SlashAnchorInfo = "Toggles movable anchor."
L.AlertAnchorText = "Toggle Alert System"
L.SlashAlert = "alert"

L.LRM_Anchor = "LootRollMover Anchor"
L.Alert_Anchor = "Alert Anchor"
L.Bonus_Anchor = "Bonus Roll Anchor"

L.SlashReset = "reset"
L.SlashResetText = "Reset Anchor Position"
L.SlashResetInfo = "Reset anchor position."
L.SlashResetAlert = "Anchor position has been reset!"

L.SlashScale = "scale"
L.SlashScaleSet = "scale has been set to [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Scale invalid! Number must be from [0.5 - 5].  (0.5, 1, 3, 4.6, etc..)"
L.SlashScaleInfo = "Set the scale of the LootRollMover loot frames (0.5 - 5)."
L.SlashScaleText = "LootRollMover loot frame Scale"

L.DragFrameInfo = "Right click when finished dragging"
L.AddonLoginMsg = "Show addon loaded announcement at login."
