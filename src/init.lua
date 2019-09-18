require "config"
require "cocos.init"
require "gk.init"

local init = {}

local function getConfig(entry)
    return entry == 0 and {
        -- run demo app
        entry = entry,
        codeDir = "demoapp/",
        fontDir = "demoapp/res/font/",
        shaderDir = "demoapp/shader/",
        genDir = "demoapp/gen/",
        textureDir = "demoapp/res/texture/",
        launchEntry = "demoapp/SplashLayer",
        launchEntryKey = "gk_launchEntry_1", -- remember last entry when restart
        designSize = cc.size(720, 1280),
    } or {
        -- run gk test
        entry = entry,
        codeDir = "gk/test/",
        fontDir = "gk/test/res/font/",
        shaderDir = "",
        genDir = "gk/test/gen/",
        textureDir = "gk/test/res/texture/",
        launchEntry = "gk/test/NodeTest",
        launchEntryKey = "gk_launchEntry_2", -- remember last entry when restart
--        designSize = cc.size(1280, 720),
        designSize = cc.size(750, 1334),
    }
end

local config = getConfig(1)

-- mode 1 --> Press F1 to restart app with edit mode at current designing scene.
-- mode 2 --> Press F2 to restart app with release mode at current designing scene.
-- mode 0 --> Press F3 to restart app with release mode at default launch entry.
function init:startGame(mode)
    mode = mode or 0
    local curVersion = cc.UserDefault:getInstance():getStringForKey("gk_currentVersion")
    local codeVersion = require("version")
    printf("init:startGame with mode %d, curVersion = %s, codeVersion = %s", mode, curVersion, codeVersion)
    self:initGameKit(mode)

    gk.lastLaunchEntryKey = config.launchEntryKey -- remember last entry by editor
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_MAC and mode ~= gk.MODE_RELEASE then
        local path = cc.UserDefault:getInstance():getStringForKey(gk.lastLaunchEntryKey, config.launchEntry)
        local _, ret = gk.SceneManager:replace(path)
        if not ret then
            -- reset to default entry
            cc.UserDefault:getInstance():setStringForKey(gk.lastLaunchEntryKey, config.launchEntry)
        end
    else
        gk.SceneManager:replace(config.launchEntry)
    end

    -- gk.resource:testAllGenNodes()
end

function init:initGameKit(mode)
    -- use custom log func
    gk.log = function(format, ...)
        if gk.config.CFG_LOG_OPEN then
            local var = { ... }
            local string = #var > 0 and string.format(format, ...) or format
            print(string)
            return string
        else
            return ""
        end
    end

    -- init config
    self:initConfig()
    cc.Director:getInstance():setDisplayStats(gk.config.CFG_SHOW_FPS)

    -- print runtime version
    gk.log("runtime version = %s", gk:getRuntimeVersion())

    -- dump package path
    gk.log("package.path = \"%s\"", package.path)
    local searchPath = cc.FileUtils:getInstance():getSearchPaths()
    gk.log("app search paths:")
    for _, v in ipairs(searchPath) do
        gk.log("searchPath:\"%s\"", v)
    end

    -- optional: custom profile func, such as calculate execute time
    gk.profile.onStart = function(key, ...)
        --
    end
    gk.profile.onStop = function(key, desc, ...)
        --
    end

    -- init lua gamekit
    gk.mode = mode
    gk.display:registerCustomDeviceSize(cc.size(1280, 768), "1280x768(5:3)") -- optional: add custom desigin size for editor
    gk.display:registerCustomDeviceSize(cc.size(750, 1334), "750x1334(ip6)") -- optional: add custom desigin size for editor
    gk.display:initWithDesignSize(config.designSize, cc.ResolutionPolicy.UNIVERSAL)
    gk.resource.defaultSprite = DEBUG > 0 and gk.defaultSpriteDebug or gk.defaultSpriteRelease
    gk.resource:setTextureDir(config.textureDir)
    gk.resource:setFontDir(config.fontDir)
    gk.resource:setCodeDir(config.codeDir)
    gk.resource:setShaderDir(config.shaderDir)
    gk.resource:setGenDir(config.genDir)

    -- custom localize string get func
    local strings = {
        en = require(config.genDir .. "value/strings"),
        cn = require(config.genDir .. "value/strings_cn"),
    }
    local defaultFontForLans = {
        en = "Klee.fnt", -- en as the default for others
        cn = "Arial",
    }
    gk.resource:setSupportLans(table.keys(strings), "en")
    gk.resource:setDefaultFontForLans(defaultFontForLans)
    gk.resource:setStringGetFunc(function(key, lan)
        lan = lan or gk.resource:getCurrentLan()
        return strings[lan][key] or ("@" .. key)
    end)

    -- optional: auto complete string input on edit mode
    local k1 = { "@strings" }
    local maxTipsCount = 16
    -- return items, prefix, tips, key
    gk.resource:setAutoCompleteFunc(function(key)
        local file = strings[gk.resource:getCurrentLan()]
        local all = table.keys(file)
        table.sort(all)
        if key == "@" then
            local items = {}
            for i = 1, maxTipsCount do
                table.insert(items, all[i])
            end
            local tips = {}
            for i = #items, 1, -1 do
                table.insert(tips, file[items[i]])
            end
            return items, "@", tips
        elseif key:sub(1, 1) == "@" then
            key = key:sub(2, #key)
            local items = {}
            -- starts
            for _, k in ipairs(all) do
                k = tostring(k)
                if k:starts(key) then
                    table.insert(items, k)
                end
                if #items >= maxTipsCount then
                    break
                end
            end
            if #items < maxTipsCount then
                local cts = {}
                -- contains
                for _, k in ipairs(all) do
                    k = tostring(k)
                    if k:find(key) and not table.indexof(items, k) and not table.indexof(cts, k) then
                        table.insert(cts, k)
                    end
                    if #items + #cts >= maxTipsCount then
                        break
                    end
                end
                table.sort(cts, function(s1, s2)
                    return s1:find(key) < s2:find(key)
                end)
                table.insertto(items, cts)
            else
                table.sort(items)
            end
            local tips = {}
            for i = #items, 1, -1 do
                local k = items[i]
                if not file[k] then
                    k = tonumber(items[i])
                end
                if file[k] and file[k] then
                    table.insert(tips, file[k])
                end
            end
            return items, "@", tips, key
        end
        return {}
    end)

    -- call before restart
    gk.util:registerOnRestartGameCallback(function()
        -- release resource here
        if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC then
            -- Mac do not purge cache to speed up restart
            cc.Director:getInstance():purgeCachedData()
        end
    end)
    -- did restart func
    gk.util:registerRestartGameCallback(function(...)
        restartGame(...)
    end)
    -- on error callback
    gk.util:registerOnErrorCallback(function(msg)
        gk.ErrorReporter:reportException(msg)
    end)

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC and gk.mode == gk.MODE_EDIT then
        -- mac scan files on edit mode
        local instanceRun = require("gk.instanceRun")
        local MAC_ROOT = instanceRun.MAC_ROOT
        gk.resource:scanGenNodes(MAC_ROOT .. "src/")
        gk.resource:scanFontFiles(MAC_ROOT .. config.fontDir)
        gk.resource:flush(MAC_ROOT .. "src/" .. config.genDir .. "config.lua")
    else
        gk.resource:load(config.genDir .. "config.lua")
    end
    -- display all nodes such as sprite3D, FSMNodes, DrawNodes
    gk.resource:displayInternalNodes()

    ---------------------- for edtior ----------------------
    -- shaders
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/Freeze.fsh")
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/HighLight.fsh")
    gk.shader:reloadOnRenderRecreated()

    -- hint c3bs
    gk.editorConfig:registerHintColor3B(cc.c3b(255, 0, 0), "Red")
    gk.editorConfig:registerHintColor3B(cc.c3b(0, 255, 0), "Green")
    gk.editorConfig:registerHintColor3B(cc.c3b(0, 0, 255), "Blue")
    gk.editorConfig:registerHintColor3B(cc.c3b(160, 160, 160), "Gray")

    -- hint contentSize or button size
    gk.editorConfig:registerHintContentSize(cc.size(200, 50))

    -- hint fontSizes
    gk.editorConfig:registerHintFontSize(16)
    gk.editorConfig:registerHintFontSize(18)
    gk.editorConfig:registerHintFontSize(20)
    gk.editorConfig:registerHintFontSize(24)
end

function init:initConfig()
    gk.config:registerBool("CFG_LOG_OPEN", true, "Print gk.log.")
    gk.config:registerBool("CFG_SHOW_FPS", false, "Show FPS.")
    gk.config:dump()
end

return init