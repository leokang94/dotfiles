-- F17 키로 한영 전환
-- 카라비너에서 right_command → F17로 매핑된 키를 감지하여 입력 소스 전환

-- 입력 소스 전환 함수
local function toggleInputSource()
    local currentSourceID = hs.keycodes.currentSourceID()

    if ENGLISH_INPUTS[currentSourceID] then
        -- 영어 -> 한글
        for sourceID, _ in pairs(KOREAN_INPUTS) do
            hs.keycodes.currentSourceID(sourceID)
            break
        end
    elseif KOREAN_INPUTS[currentSourceID] then
        -- 한글 -> 영어
        for sourceID, _ in pairs(ENGLISH_INPUTS) do
            hs.keycodes.currentSourceID(sourceID)
            break
        end
    end
end

-- F17 키 바인딩
hs.hotkey.bind({}, 'F17', function()
    toggleInputSource()
end)
