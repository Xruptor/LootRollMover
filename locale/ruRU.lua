local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ruRU")
if not L then return end
-- Translator ZamestoTV
L.SlashAnchor = "anchor"
L.SlashAnchorText = "Переключить якорь фрейма"
L.SlashAnchorOn = "LootRollMover: Якорь теперь [|cFF99CC33ПОКАЗАН|r]"
L.SlashAnchorOff = "LootRollMover: Якорь теперь [|cFF99CC33СКРЫТ|r]"
L.SlashAnchorInfo = "Переключает перемещаемый якорь."

L.SlashReset = "reset"
L.SlashResetText = "Сбросить позицию якоря"
L.SlashResetInfo = "Сбросить позицию якоря."
L.SlashResetAlert = "LootRollMover: Позиция якоря сброшена!"

L.SlashScale = "scale"
L.SlashScaleSet = "LootRollMover: масштаб установлен на [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: Масштаб недействителен! Число должно быть от [0.5 - 5]. (0.5, 1, 3, 4.6 и т.д.)"
L.SlashScaleInfo = "Установить масштаб фреймов лута LootRollMover (0.5 - 5)."
L.SlashScaleText = "Масштаб фрейма лута LootRollMover"

L.DragFrameInfo = "ПКМ, когда закончите перетаскивание"
L.AddonLoginMsg = "Показывать объявление о загрузке аддона при входе."
