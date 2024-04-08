local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L.SlashAnchor = "锚点"
L.SlashAnchorText = "移动窗口锚点"
L.SlashAnchorOn = "LootRollMover: 锚点 [|cFF99CC33显示|r]"
L.SlashAnchorOff = "LootRollMover: 锚点 [|cFF99CC33隐藏|r]"
L.SlashAnchorInfo = "切换移动锚点。"

L.SlashReset = "重置"
L.SlashResetText = "重置锚点位置。"
L.SlashResetInfo = "重置锚点位置。"
L.SlashResetAlert = "LootRollMover: 锚点位置已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "LootRollMover: 比例设置为 [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: 数值无效！数字必须是 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
L.SlashScaleInfo = "设置LootRollMover战利品窗口的比例 (0.5 - 5)。"
L.SlashScaleText = "战利品窗口比例"

L.DragFrameInfo = "LootRollMover\n\n移动到位后右键点击。"
