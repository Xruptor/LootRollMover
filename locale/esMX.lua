local _, private = ...

local L = private:NewLocale("esMX")
if not L then return end

L.SlashAnchor = "ancla"
L.SlashAnchorText = "Alternar ancla del marco"
L.SlashAnchorOn = "Ancla ahora [|cFF99CC33MOSTRADA|r]"
L.SlashAnchorOff = "Ancla ahora [|cFF99CC33OCULTA|r]"
L.SlashAnchorInfo = "Alterna el ancla movible."
L.AlertAnchorText = "Alternar sistema de alertas"
L.SlashAlert = "alerta"

L.LRM_Anchor = "Ancla de LootRollMover"
L.Alert_Anchor = "Ancla de alerta"
L.Bonus_Anchor = "Ancla de tirada de bonificación"

L.SlashReset = "restablecer"
L.SlashResetText = "Restablecer posición del ancla"
L.SlashResetInfo = "Restablece la posición del ancla."
L.SlashResetAlert = "¡La posición del ancla ha sido restablecida!"

L.SlashScale = "escala"
L.SlashScaleSet = "la escala se ha establecido en [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "¡Escala inválida! El número debe ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Establece la escala de los marcos de botín de LootRollMover (0.5 - 5)."
L.SlashScaleText = "Escala de los marcos de botín de LootRollMover"

L.DragFrameInfo = "Clic derecho cuando termine de arrastrar"
L.AddonLoginMsg = "Mostrar el anuncio de carga del addon al iniciar sesión."
