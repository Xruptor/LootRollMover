local _, private = ...

local L = private:NewLocale("ruRU")
if not L then return end

-- Translator ZamestoTV
L.SlashAnchor = "якорь"
L.SlashAnchorText = "Переключить якорь фрейма"
L.SlashAnchorOn = "Якорь теперь [|cFF99CC33ПОКАЗАН|r]"
L.SlashAnchorOff = "Якорь теперь [|cFF99CC33СКРЫТ|r]"
L.SlashAnchorInfo = "Переключает перемещаемый якорь."
L.AlertAnchorText = "Переключить систему оповещений"
L.SlashAlert = "оповещение"

L.LRM_Anchor = "Якорь LootRollMover"
L.Alert_Anchor = "Якорь оповещений"

L.SlashReset = "сброс"
L.SlashResetText = "Сбросить позицию якоря"
L.SlashResetInfo = "Сбрасывает позицию якоря."
L.SlashResetAlert = "Позиция якоря сброшена!"

L.SlashScale = "масштаб"
L.SlashScaleSet = "масштаб установлен на [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Масштаб недействителен! Число должно быть от [0.5 - 5]. (0.5, 1, 3, 4.6 и т.д.)"
L.SlashScaleInfo = "Установить масштаб фреймов лута LootRollMover (0.5 - 5)."
L.SlashScaleText = "Масштаб фреймов лута LootRollMover"

L.DragFrameInfo = "ПКМ, когда закончите перетаскивание"
L.AddonLoginMsg = "Показывать объявление о загрузке аддона при входе."
