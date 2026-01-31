local ADDON_NAME, private = ...

local L = private:NewLocale("zhCN")
if not L then return end

L.SlashAnchor = "锚点"
L.SlashAnchorText = "切换框体锚点"
L.SlashAnchorOn = "LootRollMover: 锚点 [|cFF99CC33显示|r]"
L.SlashAnchorOff = "LootRollMover: 锚点 [|cFF99CC33隐藏|r]"
L.SlashAnchorInfo = "切换可移动锚点。"

L.LRM_Anchor = "LootRollMover 锚点"
L.Alert_Anchor = "提醒锚点"

L.SlashReset = "重置"
L.SlashResetText = "重置锚点位置"
L.SlashResetInfo = "重置锚点位置。"
L.SlashResetAlert = "LootRollMover: 锚点位置已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "LootRollMover: 比例设置为 [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: 数值无效！数字必须是 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
L.SlashScaleInfo = "设置 LootRollMover 战利品窗口的比例 (0.5 - 5)。"
L.SlashScaleText = "LootRollMover 战利品窗口比例"

L.DragFrameInfo = "移动到位后右键点击。"
L.AddonLoginMsg = "登录时显示插件已加载的提示。"
