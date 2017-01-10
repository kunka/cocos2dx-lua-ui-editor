--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local id2label = {}

local function create_label(id)
    local label= cc.Label:createWithSystemFont(string.format("undefined_%s", id), "SimHei", 20)
    label.__id = id
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

return id2label