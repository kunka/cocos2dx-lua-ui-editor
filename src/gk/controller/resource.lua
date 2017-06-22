--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 下午4:09
-- To change this template use File | Settings | File Templates.
--

local resource = {}

----------------------------- texture relative path -----------------------------------
resource.textureDir = ""
function resource:setTextureDir(dir)
    gk.log("resource:setTextureDir \"%s\"", dir)
    self.textureDir = dir
end

resource.fontDir = ""
function resource:setFontDir(dir)
    gk.log("resource:setFontDir \"%s\"", dir)
    self.fontDir = dir
end

resource.shaderDir = ""
function resource:setShaderDir(dir)
    gk.log("resource:setShaderDir \"%s\"", dir)
    self.shaderDir = dir
end

resource.genDir = ""
function resource:setGenDir(dir)
    gk.log("resource:setGenDir \"%s\"", dir)
    self.genDir = dir
end

function resource:scanFontFiles(path)
    if not self.fontFiles then
        self.fontFiles = {}
        self:scanFontDir(path)
    end
end

function resource:getFontFile(key)
    return self.fontDir and (self.fontDir .. key) or key
end

function resource:scanFontDir(dir)
    if not dir or dir == "" then
        return
    end
    gk.log("resource:scanFontDir dir = \"%s\"", dir)
    -- scan all font files
    local f = io.popen('ls ' .. dir, "r")
    if f then
        local lines = {}
        for name in f:lines() do
            table.insert(lines, name)
        end
        for _, name in ipairs(lines) do
            if name:ends(".fnt") or name:ends(".ttf") then
                table.insert(self.fontFiles, "" .. name)
                gk.log("resource:scanFontfile:%s", "" .. name)
            elseif not name:find("%.") then
                self:scanFontDir(dir .. name .. "/")
            end
        end
        f:close()
    end

    table.sort(self.fontFiles, function(k1, k2) return k1 < k2 end)
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
    self:scanDir(path .. self.genSrcPath, self.genSrcPath)
end

function resource:scanDir(dir, genSrcPath)
    if not dir or dir == "" then
        return
    end
    gk.log("resource:scanDir dir = \"%s\"", genSrcPath)
    -- scan all gen-able files
    local f = io.popen('ls ' .. dir, "r")
    if f then
        local lines = {}
        for name in f:lines() do
            table.insert(lines, name)
        end
        for _, name in ipairs(lines) do
            if name:ends(".lua") then
                self:loadEditableNodes(dir .. name, genSrcPath)
            elseif not name:find("%.") then
                self:scanDir(dir .. name .. "/", genSrcPath .. name .. "/")
            end
        end
        f:close()
    end
end

function resource:loadEditableNodes(path, genSrcPath)
    local status, clazz = pcall(require, path)
    if status and clazz then
        -- TODO: other types
        local isEditable = gk.util:iskindof(clazz, "Layer") or gk.util:iskindof(clazz, "TableViewCell") or gk.util:iskindof(clazz, "Widget")
        if isEditable then
            local genPath = self:_getGenNodePath(genSrcPath, clazz.__cname)
            self.genNodes[clazz.__cname] = {
                isWidget = clazz._isWidget,
                cname = clazz.__cname,
                genPath = genPath,
                genSrcPath = genSrcPath,
                path = genSrcPath .. clazz.__cname
            }
            gk.log("resource:scanGenNodes file:%s, output --> %s", genSrcPath .. clazz.__cname, genPath)
        end
    end
end

function resource:_getGenNodePath(genSrcPath, cname)
    local path = genSrcPath:gsub("/", "_")
    local genPath = self.genOutputPath .. path:lower() .. cname:lower() .. ".lua"
    return genPath
end

function resource:getGenNodePath(cname)
    local node = self.genNodes[cname]
    if node then
        return node.genPath
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

function resource:flush(path)
    gk.log("resource:flush --> %s", path)
    local info = {
        fontFiles = self.fontFiles,
        genNodes = self.genNodes,
        fontDir = self.fontDir,
        shaderDir = self.shaderDir,
        genDir = self.genDir,
    }
    -- root container node
    local table2lua = require("gk.tools.table2lua")
    if gk.exception then
        gk.log(table2lua.encode_pretty(info))
        gk.log("[Warning!] exception occured! please fix it then flush to file!")
    else
        gk.log("flush to file: " .. path .. (io.writefile(path, table2lua.encode_pretty(info)) and " success!" or " failed!!!"))
    end
end

function resource:load(path)
    gk.log("resource:load --> %s", path)
    local status, info = pcall(require, path)
    if status then
        self.fontFiles = info.fontFiles
        self.fontDir = info.fontDir
        self.genNodes = info.genNodes
        self.shaderDir = info.shaderDir
        self.genDir = info.genDir
    else
        gk.log("resource:load --> %s failed", path)
    end
end

return resource