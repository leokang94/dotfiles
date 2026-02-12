ENGLISH_INPUTS = {
	["com.apple.keylayout.ABC"] = true,
}
KOREAN_INPUTS = {
	["com.apple.inputmethod.Korean.2SetKorean"] = true,
}

-- foundation_remapping을 사용한 키 리맵핑 (카라비너 대체)
FRemap = require('foundation_remapping')
remapper = FRemap.new()
remapper:remap('capslock', 'lctrl')  -- Caps Lock → Left Control
remapper:remap('rcmd', 'f17')        -- Right Command → F17
remapper:register()

-- 한글 입력시 상단과 하단에 overlay rectangle 표시.
require("modules.inputsource_aurora")

-- F17 키로 한영 전환
require("modules.inputsource_switch")
