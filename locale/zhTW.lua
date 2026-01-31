local ADDON_NAME, private = ...

local L = private:NewLocale("zhTW")
if not L then return end

L.SlashAnchor = "錨點"
L.SlashAnchorText = "切換框體錨點"
L.SlashAnchorOn = "LootRollMover: 錨點 [|cFF99CC33顯示|r]"
L.SlashAnchorOff = "LootRollMover: 錨點 [|cFF99CC33隱藏|r]"
L.SlashAnchorInfo = "切換可移動錨點。"

L.LRM_Anchor = "LootRollMover 錨點"
L.Alert_Anchor = "警報錨點"

L.SlashReset = "重置"
L.SlashResetText = "重置錨點位置"
L.SlashResetInfo = "重置錨點位置。"
L.SlashResetAlert = "LootRollMover: 錨點位置已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "LootRollMover: 比例設置為 [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: 數值無效！數字必須介於 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
L.SlashScaleInfo = "設定 LootRollMover 戰利品窗口比例 (0.5 - 5)。"
L.SlashScaleText = "LootRollMover 戰利品窗口比例"

L.DragFrameInfo = "移動到位後右鍵點擊。"
L.AddonLoginMsg = "登入時顯示插件已載入提示。"
