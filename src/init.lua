require "config"
require "cocos.init"
require "gk.init"

local init = {}

local function getConfig(entry)
    entry = entry or 1
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
        -- run test mode
        entry = entry,
        codeDir = "gk/test/",
        fontDir = "gk/test/res/font/",
        shaderDir = "",
        genDir = "gk/test/gen/",
        textureDir = "gk/test/res/texture/",
        launchEntry = "gk/test/MainLayer",
        launchEntryKey = "gk_launchEntry_2", -- remember last entry when restart
        designSize = cc.size(1280, 768),
    }
end

local config = getConfig()

-- mode 1 --> Press F1 to restart app with debug mode at current designing scene.
-- mode 2 --> Press F2 to restart app with release mode at current designing scene.
-- mode 0 --> Press F3 to restart app with release mode at default launch entry.
function init:startGame(mode, ...)
    mode = mode or 0
    local curVersion = cc.UserDefault:getInstance():getStringForKey("gk_currentVersion")
    local codeVersion = require("version")
    printf("init:startGame with mode %d, curVersion = %s, codeVersion = %s", mode, curVersion, codeVersion)
    self:initGameKit(mode, ...)

    gk.lastLaunchEntryKey = config.launchEntryKey -- remember last entry by editor
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 and mode ~= gk.MODE_RELEASE then
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
    gk.MAC_ROOT = MAC_ROOT or ""
    gk.ANDROID_ROOT = ANDROID_ROOT or ""
    gk.ANDROID_PACKAGE_NAME = ANDROID_PACKAGE_NAME or ""

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
    gk.log("# MAC_ROOT                     = " .. gk.MAC_ROOT)
    gk.log("# ANDROID_ROOT                 = " .. gk.ANDROID_ROOT)
    gk.log("# ANDROID_PACKAGE_NAME         = " .. gk.ANDROID_PACKAGE_NAME)

    -- print runtime version
    gk.log("runtime version = %s", gk:getRuntimeVersion())

    -- dump package path
    gk.util:dump(package.path)
    local searchPath = cc.FileUtils:getInstance():getSearchPaths()
    gk.log("app search paths:")
    for _, v in ipairs(searchPath) do
        gk.log("searchPath:\"" .. v .. "\"")
    end

    -- custom profile func, such as calculate execute time
    gk.profile.onStart = function(key, ...)
        --
    end
    gk.profile.onStop = function(key, desc, ...)
        --
    end

    -- init lua gamekit
    gk.mode = mode
    -- custom desigin size for editor
    gk.display:registerCustomDeviceSize(cc.size(1280, 768), "1280x768(5:3)")
    gk.display:initWithDesignSize(config.designSize, cc.ResolutionPolicy.FIXED_WIDTH)
    gk.resource.defaultSpritePath = DEBUG > 0 and gk.defaultSpritePathDebug or gk.defaultSpritePathRelease
    gk.resource:setTextureDir(config.textureDir)
    gk.resource:setFontDir(config.fontDir)
    gk.resource:setGenSrcPath(config.codeDir)
    gk.resource:setShaderDir(config.shaderDir)
    gk.resource:setGenDir(config.genDir)

    -- custom localize string get func
    local strings = {
        en = require(config.genDir .. "value/strings"),
        cn = require(config.genDir .. "value/strings_cn"),
    }
    gk.resource:setSupportLans(table.keys(strings), "en")
    gk.resource:setStringGetFunc(function(key, lan)
        lan = lan or gk.resource:getCurrentLan()
        return strings[lan][key] or ("@" .. key)
    end)

    -- u can scan by scripts
    local k1 = { "@strings" }
    local maxTipsCount = 16
    gk.resource:setAutoCompleteFunc(function(key)
        if key == "@" then
            return k1
        end
        if key:len() > 1 and key:sub(1, 1) == "@" then
            -- TODO:
        end
        return {}
    end)

    -- call before restart
    gk.util:registerOnRestartGameCallback(function()
        -- release resource here
    end)
    -- restart func
    gk.util:registerRestartGameCallback(function(...)
        restartGame(...)
    end)
    -- on error callback
    gk.util:registerOnErrorCallback(function(msg)
        gk.log(msg)
    end)

    -- mac scan files
    if CFG_SCAN_NODES and cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC and gk.mode == gk.MODE_EDIT and MAC_ROOT then
        local root = MAC_ROOT
        gk.resource:scanGenNodes(root .. "src/")
        gk.resource:scanFontFiles(root .. config.fontDir)
        gk.resource:flush(root .. "src/" .. config.genDir .. "config.lua")
    else
        gk.resource:load(config.genDir .. "config.lua")
    end

    ---------------------- for edtior ----------------------
    --- editor ex ---

    -- shaders
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/Freeze.fsh")
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/HighLight.fsh")

    -- hint c3bs
    gk.generator.config:registerHintColor3B(cc.c3b(255, 0, 0), "Red")
    gk.generator.config:registerHintColor3B(cc.c3b(0, 255, 0), "Green")
    gk.generator.config:registerHintColor3B(cc.c3b(0, 255, 255), "Yellow")
    gk.generator.config:registerHintColor3B(cc.c3b(0, 0, 0), "Black")
    gk.generator.config:registerHintColor3B(cc.c3b(255, 255, 255), "White")

    -- hint contentSizes or button size
    gk.generator.config:registerHintContentSize(cc.size(200, 50))

    -- hint fontSizes
    gk.generator.config:registerHintFontSize(16)
    gk.generator.config:registerHintFontSize(18)
    gk.generator.config:registerHintFontSize(20)
    gk.generator.config:registerHintFontSize(24)
    ---------------------- for edtior ----------------------
end

function init:initConfig()
    gk.config:registerBool("CFG_LOG_OPEN", true, "Print gk.log.")
    gk.config:registerBool("CFG_SHOW_FPS", false, "Show FPS.")
    gk.config:dump()
end

return init