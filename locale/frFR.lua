local ADDON_NAME, private = ...

local L = private:NewLocale("frFR")
if not L then return end

L.SlashAnchor = "ancre"
L.SlashAnchorText = "Basculer l'ancre de la fenêtre"
L.SlashAnchorOn = "LootRollMover : ancre [|cFF99CC33AFFICHÉE|r]"
L.SlashAnchorOff = "LootRollMover : ancre [|cFF99CC33MASQUÉE|r]"
L.SlashAnchorInfo = "Active/désactive l'ancre déplaçable."

L.LRM_Anchor = "Ancre LootRollMover"
L.Alert_Anchor = "Ancre d'alerte"

L.SlashReset = "réinitialiser"
L.SlashResetText = "Réinitialiser la position de l'ancre"
L.SlashResetInfo = "Réinitialise la position de l'ancre."
L.SlashResetAlert = "LootRollMover : la position de l'ancre a été réinitialisée !"

L.SlashScale = "échelle"
L.SlashScaleSet = "LootRollMover : l'échelle a été définie sur [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover : échelle invalide ! Le nombre doit être entre [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Définit l'échelle des fenêtres de butin LootRollMover (0.5 - 5)."
L.SlashScaleText = "Échelle des fenêtres de butin LootRollMover"

L.DragFrameInfo = "Cliquez avec le bouton droit lorsque le déplacement est terminé"
L.AddonLoginMsg = "Afficher l'annonce de chargement de l'addon à la connexion."
