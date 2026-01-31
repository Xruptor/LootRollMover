local ADDON_NAME, private = ...

local L = private:NewLocale("koKR")
if not L then return end

L.SlashAnchor = "앵커"
L.SlashAnchorText = "프레임 앵커 전환"
L.SlashAnchorOn = "LootRollMover: 앵커 [|cFF99CC33표시됨|r]"
L.SlashAnchorOff = "LootRollMover: 앵커 [|cFF99CC33숨김|r]"
L.SlashAnchorInfo = "이동 가능한 앵커를 전환합니다."

L.LRM_Anchor = "LootRollMover 앵커"
L.Alert_Anchor = "알림 앵커"

L.SlashReset = "재설정"
L.SlashResetText = "앵커 위치 재설정"
L.SlashResetInfo = "앵커 위치를 재설정합니다."
L.SlashResetAlert = "LootRollMover: 앵커 위치가 재설정되었습니다!"

L.SlashScale = "스케일"
L.SlashScaleSet = "LootRollMover: 스케일이 [|cFF20ff20%s|r](으)로 설정되었습니다"
L.SlashScaleSetInvalid = "LootRollMover: 스케일이 올바르지 않습니다! 숫자는 [0.5 - 5] 사이여야 합니다. (0.5, 1, 3, 4.6 등)"
L.SlashScaleInfo = "LootRollMover 전리품 프레임의 스케일을 설정합니다 (0.5 - 5)."
L.SlashScaleText = "LootRollMover 전리품 프레임 스케일"

L.DragFrameInfo = "드래그를 마친 후 마우스 오른쪽 버튼을 클릭하세요"
L.AddonLoginMsg = "로그인 시 애드온 로드 알림을 표시합니다."
