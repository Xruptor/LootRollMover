local ADDON_NAME, private = ...

local L = private:NewLocale("deDE")
if not L then return end

L.SlashAnchor = "anker"
L.SlashAnchorText = "Anker des Rahmens umschalten"
L.SlashAnchorOn = "LootRollMover: Anker jetzt [|cFF99CC33ANGEZEIGT|r]"
L.SlashAnchorOff = "LootRollMover: Anker jetzt [|cFF99CC33VERSTECKT|r]"
L.SlashAnchorInfo = "Schaltet den beweglichen Anker um."

L.LRM_Anchor = "LootRollMover-Anker"
L.Alert_Anchor = "Alarm-Anker"

L.SlashReset = "zurücksetzen"
L.SlashResetText = "Ankerposition zurücksetzen"
L.SlashResetInfo = "Ankerposition zurücksetzen."
L.SlashResetAlert = "LootRollMover: Ankerposition wurde zurückgesetzt!"

L.SlashScale = "skalierung"
L.SlashScaleSet = "LootRollMover: Skalierung wurde auf [|cFF20ff20%s|r] gesetzt"
L.SlashScaleSetInvalid = "LootRollMover: Skalierung ungültig! Zahl muss zwischen [0.5 - 5] liegen. (0.5, 1, 3, 4.6, usw.)"
L.SlashScaleInfo = "Skaliert die LootRollMover-Lootrahmen (0.5 - 5)."
L.SlashScaleText = "LootRollMover-Lootrahmen-Skalierung"

L.DragFrameInfo = "Rechtsklick, wenn du mit dem Ziehen fertig bist"
L.AddonLoginMsg = "Ankündigung beim Einloggen anzeigen."
