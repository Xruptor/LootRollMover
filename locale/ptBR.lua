local ADDON_NAME, private = ...

local L = private:NewLocale("ptBR")
if not L then return end

L.SlashAnchor = "ancora"
L.SlashAnchorText = "Alternar âncora do quadro"
L.SlashAnchorOn = "LootRollMover: Âncora agora [|cFF99CC33EXIBIDA|r]"
L.SlashAnchorOff = "LootRollMover: Âncora agora [|cFF99CC33OCULTA|r]"
L.SlashAnchorInfo = "Alterna a âncora móvel."

L.LRM_Anchor = "Âncora do LootRollMover"
L.Alert_Anchor = "Âncora de alerta"

L.SlashReset = "redefinir"
L.SlashResetText = "Redefinir posição da âncora"
L.SlashResetInfo = "Redefine a posição da âncora."
L.SlashResetAlert = "LootRollMover: a posição da âncora foi redefinida!"

L.SlashScale = "escala"
L.SlashScaleSet = "LootRollMover: a escala foi definida para [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "LootRollMover: Escala inválida! O número deve ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Define a escala dos quadros de saque do LootRollMover (0.5 - 5)."
L.SlashScaleText = "Escala dos quadros de saque do LootRollMover"

L.DragFrameInfo = "Clique com o botão direito quando terminar de arrastar"
L.AddonLoginMsg = "Mostrar aviso de carregamento do addon ao entrar."
