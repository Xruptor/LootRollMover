local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhTW")
if not L then return end

L.SlashAnchor = "錨點"
L.SlashAnchorText = "移動窗口錨點"
L.SlashAnchorOn = "LootRollMover: 錨點 [|cFF99CC33顯示|r]"
L.SlashAnchorOff = "LootRollMover: 錨點 [|cFF99CC33隱藏|r]"
L.SlashAnchorInfo = "切換移動錨點。"

L.SlashReset = "重置"
L.SlashResetText = "重置錨點位置。"
L.SlashResetInfo = "重置錨點位置。"
L.SlashResetAlert = "LootRollMover: 錨點位置已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "LootRollMover: 比例設置為 [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: 數值無效！數字必須來自[0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
L.SlashScaleInfo = "設置 LootRollMover 戰利品窗口比例 (0.5 - 5)。"
L.SlashScaleText = "戰利品窗口比例。"

L.DragFrameInfo = "移動到位後右鍵點擊。"
