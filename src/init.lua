require "config"
require "cocos.init"
require "gk.init"

local init = {}

local function getConfig(entry)
    entry = 1
    return entry == 0 and {
        -- run demo app
        entry = entry,
        codeDir = "demoapp/",
        fontDir = "src/demoapp/res/font/",
        shaderDir = "res/shader/",
        genDir = "demoapp/gen/",
        textureDir = "demoapp/res/texture/",
        launchEntry = "demoapp/SplashLayer",
        launchEntryKey = "gk_launchEntry_1",
        designSize = cc.size(720, 1280),
    } or {
        -- run test mode
        entry = entry,
        codeDir = "gk/test/",
        fontDir = "src/gk/test/res/font/",
        shaderDir = "",
        genDir = "gk/test/gen/",
        textureDir = "gk/test/res/texture/",
        launchEntry = "gk/test/MainLayer",
        launchEntryKey = "gk_launchEntry_2",
        designSize = cc.size(1280, 768),
    }
end

local config = getConfig()

-- mode 1 --> Press F1 to restart app with debug mode at current designing scene.
-- mode 2 --> Press F2 to restart app with release mode at current designing scene.
-- mode 0 --> Press F3 to restart app with release mode at default launch entry.
function init:startGame(mode, ...)
    mode = mode or 0
    gk.log("init:startGame with mode %d", mode)
    init:initGameKit(mode, ...)

    gk.lastLaunchEntryKey = config.launchEntryKey
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 and mode ~= gk.MODE_RELEASE then
        --    cc.UserDefault:getInstance():setStringForKey("gk_lastLaunchEntry", launchEntry)
        local path = cc.UserDefault:getInstance():getStringForKey(gk.lastLaunchEntryKey, config.launchEntry)
        local _, ret = gk.SceneManager:replace(path)
        if not ret then
            -- use default
            cc.UserDefault:getInstance():setStringForKey(gk.lastLaunchEntryKey, config.launchEntry)
        end
    else
        gk.SceneManager:replace(config.launchEntry)
    end
end

function init:initGameKit(mode, MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME)
    -- init code root
    gk.MAC_ROOT = MAC_ROOT
    gk.ANDROID_ROOT = ANDROID_ROOT
    gk.ANDROID_PACKAGE_NAME = ANDROID_PACKAGE_NAME

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

    -- print code root
    gk.log("# MAC_ROOT                     = " .. MAC_ROOT)
    gk.log("# ANDROID_ROOT                 = " .. ANDROID_ROOT)
    gk.log("# ANDROID_PACKAGE_NAME         = " .. ANDROID_PACKAGE_NAME)

    -- print runtime version
    gk.log("runtime version = %s", gk:getRuntimeVersion())

    -- dump search path
    gk.util:dump(package.path)
    local searchPath = cc.FileUtils:getInstance():getSearchPaths()
    gk.log("app search paths:")
    for _, v in ipairs(searchPath) do
        gk.log("searchPath:\"" .. v .. "\"")
    end

    -- custom profile func, such as calculate execute time
    gk.profile.onStart = function(key, ...)
    end
    gk.profile.onStop = function(key, desc, ...)
    end

    -- init lua gamekit
    gk.mode = mode
    gk.display:initWithDesignSize(config.designSize)
    gk.resource.defaultSpritePath = DEBUG > 0 and gk.defaultSpritePathDebug or gk.defaultSpritePathRelease
    gk.resource:setTextureDir(config.textureDir)
    gk.resource:setFontDir(config.fontDir)
    gk.resource:setGenSrcPath(config.codeDir)
    gk.resource:setShaderDir(config.shaderDir)
    gk.resource:setGenDir(config.genDir)
    gk.resource:setGenOutputPath(config.genDir .. "layout/")

    -- custom localize string get func
    local strings = {
        en = require(config.genDir .. "value/strings"),
        cn = require(config.genDir .. "value/strings_cn"),
    }
    gk.resource:setSupportLans(table.keys(strings), "en")
    gk.resource:setStringGetFunc(function(key, lan)
        lan = lan or gk.resource:getCurrentLan()
        return strings[lan][key] or "undefined"
    end)

    -- restart func
    gk.util:registerRestartGameCallback(function(...)
        restartGame(...)
    end)
    -- call before restart
    gk.util:registerOnRestartGameCallback(function()
    end)
    -- on error callback
    gk.util:registerOnErrorCallback(function(msg)
    end)

    -- mac scan files
    local scan_files = true
    if scan_files and cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC and gk.mode == gk.MODE_EDIT and MAC_ROOT then
        local root = MAC_ROOT
        gk.resource:scanGenNodes(root .. "src/")
        gk.resource:scanFontFiles(root .. config.fontDir)
        gk.resource:flush(root .. "src/" .. config.genDir .. "config.lua")
    else
        gk.resource:load(config.genDir .. "config.lua")
    end

    --- editor ex ---

    -- shaders
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/Freeze.fsh")
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/HighLight.fsh")

    -- hint c3bs
    gk.generator.config:registerHintColor3B(cc.c3b(255, 0, 0))
    gk.generator.config:registerHintColor3B(cc.c3b(0, 255, 0))
    gk.generator.config:registerHintColor3B(cc.c3b(0, 255, 255))
    gk.generator.config:registerHintColor3B(cc.c3b(0, 0, 0))
    gk.generator.config:registerHintColor3B(cc.c3b(255, 255, 255))

    -- hint contentSizes or button size
    gk.generator.config:registerHintContentSize(cc.size(200, 100))

    -- hint fontSizes
    gk.generator.config:registerHintFontSize(20)
    gk.generator.config:registerHintFontSize(24)
end

function init:initConfig()
    gk.config:registerBool("CFG_LOG_OPEN", true, "Print gk.log.")
    gk.config:registerBool("CFG_SHOW_FPS", false, "Show FPS.")
    gk.config:dump()
end

return init