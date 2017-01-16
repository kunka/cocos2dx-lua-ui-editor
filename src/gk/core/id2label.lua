--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local id2label = {}

local function create_label(info)
    if info.labelType == "ttf" then
    elseif info.labelType == "bmfont" then
    else
        info.labelType = "systemfont"
    end
    local label = cc.Label:createWithTTF(info.content, info.fontFile, info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    return label
end

gk.create_label = create_label

function id2label:getLan()
    local lc = cc.UserDefault:getInstance():getStringForKey("app_language")
    if lc == "" then
        if device.language == "cn" then
            lc = "cn"
        elseif device.language == "cht" then
            lc = "cht"
        elseif device.language == "de" then
            lc = "de"
        elseif device.language == "ru" then
            lc = "ru"
        else
            lc = "en"
        end

        cc.UserDefault:getInstance():setStringForKey("app_language", lc)
        cc.UserDefault:getInstance():flush()
    end
    return lc
end

function id2label:setLan(lc)
    cc.UserDefault:getInstance():setStringForKey("app_language", lc)
    cc.UserDefault:getInstance():flush()
end

return id2label