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

function resource:getCurrentLan()
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

        resource:setCurrentLan(lan)
    end
    return lan
end

function resource:setCurrentLan(lan)
    gk.log("resource.setCurrentLan %s", lan)
    cc.UserDefault:getInstance():setStringForKey("app_language", lan)
    cc.UserDefault:getInstance():flush()
end

function resource:setSupportLans(lans)
    resource.lans = lans
end

function resource:setGenNodePath(path)
    gk.log("resource:setGenNodePath %s", path)
    resource.genNodePath = path
    resource.genNodes = {}
    -- scan files
    local f = io.popen('ls ' .. path)
    for name in f:lines() do
        if name:ends(".lua") then
            local status, clazz = pcall(require, path .. name)
            if status then
                -- TODO: other types
                local isEditable = iskindof(clazz, "Layer")
                if not isEditable then
                    local instance = clazz:create()
                    --                if iskindof(clazz, "Layer") or iskindof(clazz, "cc.TableViewCell") then
                    isEditable = iskindof(instance, "cc.TableViewCell")
                end
                if isEditable then
                    resource.genNodes[clazz.__cname] = path .. name
                    gk.log("resource:scan genNode --> %s", clazz.__cname)
                end
            end
        end
    end
end

return resource