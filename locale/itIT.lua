local ADDON_NAME, private = ...

local L = private:NewLocale("itIT")
if not L then return end

L.SlashAnchor = "ancora"
L.SlashAnchorText = "Attiva/disattiva l'ancora del riquadro"
L.SlashAnchorOn = "LootRollMover: Ancora ora [|cFF99CC33MOSTRATA|r]"
L.SlashAnchorOff = "LootRollMover: Ancora ora [|cFF99CC33NASCOSTA|r]"
L.SlashAnchorInfo = "Attiva/disattiva l'ancora spostabile."

L.LRM_Anchor = "Ancora LootRollMover"
L.Alert_Anchor = "Ancora avviso"

L.SlashReset = "ripristina"
L.SlashResetText = "Ripristina posizione dell'ancora"
L.SlashResetInfo = "Ripristina la posizione dell'ancora."
L.SlashResetAlert = "LootRollMover: la posizione dell'ancora è stata ripristinata!"

L.SlashScale = "scala"
L.SlashScaleSet = "LootRollMover: la scala è stata impostata a [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: Scala non valida! Il numero deve essere tra [0.5 - 5]. (0.5, 1, 3, 4.6, ecc.)"
L.SlashScaleInfo = "Imposta la scala dei riquadri bottino di LootRollMover (0.5 - 5)."
L.SlashScaleText = "Scala dei riquadri bottino di LootRollMover"

L.DragFrameInfo = "Clic destro quando hai finito di trascinare"
L.AddonLoginMsg = "Mostra l'annuncio di caricamento dell'addon all'accesso."
