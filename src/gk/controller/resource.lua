--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 下午4:09
-- To change this template use File | Settings | File Templates.
--

local resource = {}
resource.textureRelativePath = ""
resource.atlasRelativePath = ""

function resource:setTextureRelativePath(path)
    resource.textureRelativePath = path
    gk.log("resource.setTextureRelativePath %s", path)
end

function resource:setAtlasRelativePath(path)
    resource.atlasRelativePath = path
    gk.log("resource.setAtlasPath %s", path)
end

function resource:setStringGetter(func)
    resource.stringGetter = func
end

function resource:getLan()
    local lan = cc.UserDefault:getInstance():getStringForKey("app_language")
    if lan == "" then
        if device.language == "cn" then
            lan = "cn"
        elseif device.language == "cht" then
            lan = "cht"
        elseif device.language == "de" then
            lan = "de"
        elseif device.language == "ru" then
            lan = "ru"
        else
            lan = "en"
        end

        resource:setLan(lan)
    end
    return lan
end

function resource:setLan(lan)
    gk.log("resource.setLan %s", lan)
    cc.UserDefault:getInstance():setStringForKey("app_language", lan)
    cc.UserDefault:getInstance():flush()
end

function resource:setLans(lans)
    resource.lans = lans
end

return resource