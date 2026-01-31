local ADDON_NAME, private = ...

local L = private:NewLocale("esES")
if not L then return end

L.SlashAnchor = "ancla"
L.SlashAnchorText = "Alternar ancla del marco"
L.SlashAnchorOn = "LootRollMover: Ancla ahora [|cFF99CC33MOSTRADA|r]"
L.SlashAnchorOff = "LootRollMover: Ancla ahora [|cFF99CC33OCULTA|r]"
L.SlashAnchorInfo = "Alterna el ancla movible."

L.LRM_Anchor = "Ancla de LootRollMover"
L.Alert_Anchor = "Ancla de alerta"

L.SlashReset = "restablecer"
L.SlashResetText = "Restablecer posición del ancla"
L.SlashResetInfo = "Restablece la posición del ancla."
L.SlashResetAlert = "LootRollMover: ¡La posición del ancla ha sido restablecida!"

L.SlashScale = "escala"
L.SlashScaleSet = "LootRollMover: la escala se ha establecido en [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: ¡Escala inválida! El número debe ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Establece la escala de los marcos de botín de LootRollMover (0.5 - 5)."
L.SlashScaleText = "Escala de los marcos de botín de LootRollMover"

L.DragFrameInfo = "Clic derecho cuando termine de arrastrar"
L.AddonLoginMsg = "Mostrar el anuncio de carga del addon al iniciar sesión."
