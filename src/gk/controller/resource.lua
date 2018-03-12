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
    self:setGenOutputPath(self.genDir .. "layout/")
end

function resource:scanFontFiles(path)
    if not self.fontFiles then
        self.fontFiles = {}
        self:scanFontDir(path)
    end
end

function resource:getFontFile(key)
    local file = self.fontDir .. key
    if cc.FileUtils:getInstance():isFileExist(file) then
        return file
    else
        if cc.FileUtils:getInstance():isFileExist(key) then
            return key
        else
            return "Arial"
        end
    end
end

function resource:scanFontDir(dir)
    if not dir or dir == "" then
        return
    end
    gk.log("resource:scanFontDir dir = \"%s\"", dir)
    -- scan all font files
    local files = cc.FileUtils:getInstance():listFiles(dir)
    for _, name in ipairs(files) do
        if cc.FileUtils:getInstance():isFileExist(name) and (name:ends(".fnt") or name:ends(".ttf")) then
            table.insert(self.fontFiles, "" .. string.gsub(name, dir, ""))
        end
    end

    table.sort(self.fontFiles)
end

----------------------------------- lans and strings -----------------------------------
function resource:setStringGetFunc(func)
    self.getString = function(_, key, ...)
        return func(key, ...)
    end
end

function resource:setAutoCompleteFunc(func)
    self.autoCompleteFunc = func
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

function resource:getSupportLans()
    return self.lans or {}
end

function resource:setDefaultFontForLans(defaultFontForLans)
    self.defaultFontForLans = defaultFontForLans
end

function resource:getDefaultFont(lan)
    if self.defaultFontForLans then
        -- default use en font
        return self.defaultFontForLans[lan] or self.defaultFontForLans["en"]
    else
        return "Arial"
    end
end

----------------------------- gen node search path -----------------------------------
function resource:setCodeDir(path)
    gk.log("resource:setCodeDir \"%s\"", path)
    self.genSrcPath = path
end

function resource:setGenOutputPath(path)
    gk.log("resource:setGenOutputPath \"%s\"", path)
    self.genOutputPath = path
end

resource.genFullPathPrefix = ""
function resource:scanGenNodes(path)
    gk.log("resource:scanGenNodes fullpath = \"%s\"", path .. self.genSrcPath)
    self.genFullPathPrefix = path
    self.genNodes = {}
    self:scanDir(path .. self.genSrcPath, self.genSrcPath)
    -- internal
    self.genNodesInternal = {}
    self:scanDir(path .. "gk/layout/", "gk/layout/", true)
end

function resource:displayInternalNodes()
    self.isDisplayInternalNodes = true
end

function resource:scanDir(dir, genSrcPath, internal)
    if not dir or dir == "" or genSrcPath:find(self.genDir) then
        return
    end
    --    gk.log("resource:scanDir dir = \"%s\", genSrcPath = \"%s\"", dir, genSrcPath)
    -- scan all gen-able files
    local files = cc.FileUtils:getInstance():listFiles(dir)
    for _, name in ipairs(files) do
        if cc.FileUtils:getInstance():isFileExist(name) and name:ends(".lua") then
            self:loadEditableNodes(name, genSrcPath, internal)
        elseif cc.FileUtils:getInstance():isDirectoryExist(name) and not name:find("%.") then
            self:scanDir(name, string.gsub(name, self.genFullPathPrefix, ""), internal)
        end
    end
end

function resource:loadEditableNodes(path, genSrcPath, internal)
    if not gk.errorOccurs then
        local status, clazz = xpcall(function()
            return require(path)
        end, function(msg)
            gk.errorOccurs = true
            local msg = debug.traceback(msg, 3)
            gk.log(msg)
        end)
        if status and clazz then
            -- TODO: other types
            local isEditable = gk.util:iskindof(clazz, "Layer") or gk.util:iskindof(clazz, "TableViewCell") or gk.util:iskindof(clazz, "Widget")
            if isEditable then
                local genPath = self:_getGenNodePath(genSrcPath, clazz.__cname, internal)
                local table = internal and self.genNodesInternal or self.genNodes
                table[clazz.__cname] = {
                    isWidget = clazz._isWidget,
                    cname = clazz.__cname,
                    genPath = genPath,
                    genSrcPath = genSrcPath,
                    path = genSrcPath .. clazz.__cname
                }
                --            gk.log("resource:scanGenNodes file:%s, output --> %s", genSrcPath .. clazz.__cname, genPath)
            end
        end
    end
end

function resource:_getGenNodePath(genSrcPath, cname, internal)
    local output = internal and "gk/gen/layout/" or self.genOutputPath
    local path = genSrcPath:gsub("/", "_")
    local genPath = output .. path:lower() .. cname:lower() .. ".lua"
    return genPath
end

function resource:getGenNode(cname)
    return self.genNodes[cname] or self.genNodesInternal[cname]
end

function resource:getGenNodePath(cname)
    local node = self.genNodes[cname] or self.genNodesInternal[cname]
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
    local status, clazz = xpcall(function()
        return require(path)
    end, function(msg)
        local msg = debug.traceback(msg, 3)
        gk.util:reportError(msg)
    end)
    if status and clazz then
        return clazz
    else
        gk.log("resource:require --> %s failed", path)
        return nil
    end
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
    local table2lua = require("gk.tools.table2lua")
    if gk.errorOccurs then
        gk.log(table2lua.encode_pretty(info))
        gk.log("[Warning!] exception occured! please fix it then flush to file!")
    else
        gk.log("flush to file: " .. path .. (io.writefile(path, table2lua.encode_pretty(info)) and " success!" or " failed!!!"))
    end
    -- flush internal
    path = self.genFullPathPrefix .. "gk/gen/config.lua"
    local info = {
        genNodes = self.genNodesInternal,
    }
    if gk.errorOccurs then
        gk.log(table2lua.encode_pretty(info))
        gk.log("[Warning!] exception occured! please fix it then flush to file!")
    else
        gk.log("flush to file: " .. path .. (io.writefile(path, table2lua.encode_pretty(info)) and " success!" or " failed!!!"))
    end
    -- flush internal
end

function resource:load(path)
    gk.log("resource:load --> %s", path)
    local status, info = xpcall(function()
        return require(path)
    end, function(msg)
        local msg = debug.traceback(msg, 3)
        gk.util:reportError(msg)
    end)
    if status and info then
        self.fontFiles = info.fontFiles
        self.fontDir = info.fontDir
        self.genNodes = info.genNodes
        self.shaderDir = info.shaderDir
        self.genDir = info.genDir
    else
        gk.log("resource:load --> %s failed", path)
    end
    -- load internal
    path = self.genFullPathPrefix .. "gk/gen/config.lua"
    local status, info = xpcall(function()
        return require(path)
    end, function(msg)
        local msg = debug.traceback(msg, 3)
        gk.util:reportError(msg)
    end)
    if status and info then
        self.genNodesInternal = info.genNodes
    else
        gk.log("resource:load --> %s failed", path)
    end
end

function resource:testAllGenNodes()
    local co = coroutine.create(function()
        local co = coroutine.running()
        local keys = table.keys(gk.resource.genNodes)
        table.sort(keys)
        for _, k in ipairs(keys) do
            local v = gk.resource.genNodes[k]
            gk.scheduler:performWithDelayGlobal(function()
                gk.event:unsubscribeAll(gk.editorPanel:getPanel(gk.SceneManager:getRunningScene()))
                local scene, ret = gk.SceneManager:replace(v.path)
                if ret and not gk.errorOccurs then
                    coroutine.resume(co)
                else
                    gk.log("error create node %s", v.path)
                end
            end, 0.1)
            coroutine.yield()
        end
    end)
    coroutine.resume(co)
end

return resource