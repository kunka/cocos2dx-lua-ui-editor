--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 下午4:09
-- To change this template use File | Settings | File Templates.
--

local resource = {}
resource.textureRelativePath = ""

function resource:setTextureRelativePath(path)
    resource.textureRelativePath = path
    gk.log("resource.setTextureRelativePath %s", path)
end

function resource:setGetStringFunc(func)
    resource.getString = function(_, key, ...)
        -- TODO: input content start with '@'
        if key:len() > 0 and key:sub(1, 1) == "@" then
            return func(key:sub(2, #key), ...)
        end
        return func(key, ...)
    end
end

function resource:getCurrentLan()
    local lan = cc.UserDefault:getInstance():getStringForKey("app_language")
    if lan == "" then
        if table.indexof(resource.lans, device.language) then
            lan = device.language
            gk.log("resource.getCurrentLan init first time, use local lan %s", lan)
        else
            gk.log("resource.getCurrentLan init first time, not supported local lan(%s), use English!", device.language)
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
                local isEditable = iskindof(clazz, "Layer") or iskindof(clazz, "Dialog")
                if not isEditable then
                    local instance = clazz:create()
                    --                if iskindof(clazz, "Layer") or iskindof(clazz, "cc.TableViewCell") then
                    isEditable = iskindof(instance, "cc.TableViewCell")
                end
                if isEditable then
                    resource.genNodes[clazz.__cname] = { path = path .. name, clazz = clazz }
                    gk.log("resource:scan genNode --> %s", clazz.__cname)
                end
            end
        end
    end
end

function resource:require(key, default)
    gk.log("resource:require --> %s, default= %s", key, default)
    if gk.resource.genNodes[key] then
        local status, clazz = pcall(require, gk.resource.genNodes[key].path)
        if status then
            return clazz, gk.resource.genNodes[key].path
        end
    end
    local status, clazz = pcall(require, key)
    if status then
        return clazz, key
    end
    if default then
        local clazz = require(gk.resource.genNodes[default].path)
        return clazz, gk.resource.genNodes[default].path
    else
        return nil
    end
end

return resource