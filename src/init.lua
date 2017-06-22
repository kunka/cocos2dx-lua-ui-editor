DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

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

-- mode 0 --> Press F1 to restart app with debug mode at current designing scene.
-- mode 1 --> Press F2 to restart app with release mode at current designing scene.
-- mode 2 --> Press F3 to restart app with release mode at default launch entry.
function init:startGame(mode)
    mode = mode or 0
    gk.log("init:startGame with mode %d", mode)
    init:initGameKit(mode)

    gk.lastLaunchEntryKey = config.launchEntryKey
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 and mode ~= 2 then
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

function init:initGameKit(mode)
    gk.mode = mode
    gk.display:initWithDesignSize(config.designSize)
    gk.resource.defaultSpritePath = DEBUG > 0 and gk.defaultSpritePathDebug or gk.defaultSpritePathRelease
    gk.resource:setTextureDir(config.textureDir)
    gk.resource:setFontDir(config.fontDir)
    gk.resource:setGenSrcPath(config.codeDir)
    gk.resource:setShaderDir(config.shaderDir)
    gk.resource:setGenDir(config.genDir)
    gk.resource:setGenOutputPath(config.genDir .. "layout/")
    local strings = {
        en = require(config.genDir .. "value/strings"),
        cn = require(config.genDir .. "value/strings_cn"),
    }
    gk.resource:setSupportLans(table.keys(strings), "en")
    gk.resource:setStringGetFunc(function(key, lan)
        lan = lan or gk.resource:getCurrentLan()
        return strings[lan][key] or "undefined"
    end)
    gk.SceneManager:init()
    -- restart func
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 then
        gk.util:registerRestartGameCallback(function(...)
            restartGame(...)
        end)
    end

    if platform == 2 and gk.mode == gk.MODE_EDIT then
        --        cc.FileUtils:getInstance():createDirectory(gk.resource.genNodePath)
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        gk.resource:scanGenNodes(path .. "src/")
        --    end
        gk.resource:scanFontFiles(path .. config.fontDir)
        gk.resource:flush(path .. "src/" .. config.genDir .. "config.lua")
    else
        gk.resource:load(config.genDir .. "config.lua")
    end

    -- shader
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/Freeze.fsh")
    gk.shader:addGLProgram("gk/res/shader/NoMvp.vsh", "gk/res/shader/HighLight.fsh")
end

return init