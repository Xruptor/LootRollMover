local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end

L.SlashAnchor = "anchor"
L.SlashAnchorText = "Toggle Frame Anchor"
L.SlashAnchorOn = "LootRollMover: Anchor now [|cFF99CC33SHOWN|r]"
L.SlashAnchorOff = "LootRollMover: Anchor now [|cFF99CC33HIDDEN|r]"
L.SlashAnchorInfo = "Toggles movable anchor."

L.SlashReset = "reset"
L.SlashResetText = "Reset Anchor Position"
L.SlashResetInfo = "Reset anchor position."
L.SlashResetAlert = "LootRollMover: Anchor position has been reset!"

L.SlashScale = "scale"
L.SlashScaleSet = "LootRollMover: scale has been set to [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: Scale invalid! Number must be from [0.5 - 5].  (0.5, 1, 3, 4.6, etc..)"
L.SlashScaleInfo = "Set the scale of the LootRollMover loot frames (0.5 - 5)."
L.SlashScaleText = "LootRollMover loot frame Scale"

L.DragFrameInfo = "LootRollMover\n\nRight click when finished dragging"