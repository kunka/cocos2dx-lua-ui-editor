--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 下午4:09
-- To change this template use File | Settings | File Templates.
--

local resource = {}

----------------------------- texture relative path -----------------------------------
resource.textureRelativePath = ""
function resource:setTextureRelativePath(path)
    gk.log("resource.setTextureRelativePath \"%s\"", path)
    self.textureRelativePath = path
end

----------------------------------- lans and strings -----------------------------------
function resource:setStringGetFunc(func)
    self.getString = function(_, key, ...)
        return func(key, ...)
    end
end

function resource:getCurrentLan()
    local lan = cc.UserDefault:getInstance():getStringForKey("app_language")
    if lan == "" then
        if table.indexof(self.lans, device.language) then
            lan = device.language
            gk.log("resource.getCurrentLan init first time, use local lan \"%s\"", lan)
        else
            gk.log("resource.getCurrentLan init first time, not supported local lan(\"%s\"), use default lan \"%s\"!", device.language, self.defaultLan)
            lan = self.defaultLan
        end

        self:setCurrentLan(lan)
    end
    return lan
end

function resource:setCurrentLan(lan)
    gk.log("resource.setCurrentLan \"%s\"", lan)
    cc.UserDefault:getInstance():setStringForKey("app_language", lan)
    cc.UserDefault:getInstance():flush()
end

function resource:setSupportLans(lans, defaultLan)
    self.lans = lans
    self.defaultLan = defaultLan and defaultLan or "en"
    gk.log("resource.setSupportLans: {%s}, defaultLan = \"%s\", curLan = \"%s\"", table.concat(lans, ","), defaultLan, self:getCurrentLan())
end

----------------------------- gen node search path -----------------------------------
function resource:setGenSrcPath(path)
    gk.log("resource:setGenSrcPath \"%s\"", path)
    self.genSrcPath = path
end

function resource:setGenOutputPath(path)
    gk.log("resource:setGenOutputPath \"%s\"", path)
    self.genOutputPath = path
end

function resource:scanGenNodes(path)
    gk.log("resource:scanGenNodes fullpath = \"%s\"", path .. self.genSrcPath)
    self.genFullPathPrefix = path
    self.genNodes = {}
    -- scan all gen-able files, TODO: scan sub dirs
    local f = io.popen('ls ' .. path .. self.genSrcPath)
    for name in f:lines() do
        if name:ends(".lua") then
            local path = self.genSrcPath .. name
            local status, clazz = pcall(require, path)
            if status and clazz then
                -- TODO: other types
                local isEditable = iskindof(clazz, "Layer") or iskindof(clazz, "Dialog") or iskindof(clazz, "TableViewCell")
                --                if not isEditable then
                --                    print("?")
                --                    local instance = clazz:create()
                --                    isEditable = iskindof(instance, "cc.TableViewCell")
                --                end

                if isEditable then
                    local genPath = self:getGenNodePath(clazz.__cname)
                    self.genNodes[clazz.__cname] = { path = path, clazz = clazz, genPath = genPath }
                    gk.log("resource:scanGenNodes file:%s, output:%s", path, genPath)
                end
            end
        end
    end
end

function resource:getGenNodePath(cname)
    if self.genSrcPath then
        local path = self.genSrcPath:gsub("/", "_")
        local genPath = self.genOutputPath .. path:lower() .. cname:lower() .. ".lua"
        return genPath
    else
        return nil
    end
end

function resource:getGenNodeFullPath(cname)
    return self.genFullPathPrefix .. self:getGenNodePath(cname)
end

function resource:require(path)
    local status, clazz = pcall(require, path)
    if status then
        return clazz
    end
    gk.log("resource:require --> %s failed", path)
    return nil
end

return resource