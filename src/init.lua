DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

require "cocos.init"
require "gk.init"

local init = {}

--- code dir, launch entry key, launch entry, textureRelativePath, design size
function init:getConfig()
    return "test/", "gk_lastLaunchEntry_1", "test/MainLayer", "test/res/texture/", cc.size(1280, 720)
    --    return "demoapp/", "gk_lastLaunchEntry_2", "demoapp/SplashLayer", "demoapp/res/texture/", cc.size(720, 1280)
end

function init:startGame(mode)
    mode = mode or 0
    gk.log("init:startGame with mode %d", mode)
    init:initGameKit(mode)

    local _, lastLaunchEntryKey, launchEntry = self:getConfig()
    gk.lastLaunchEntryKey = lastLaunchEntryKey
    --    if gk.mode == gk.MODE_EDIT then
    --    cc.UserDefault:getInstance():setStringForKey("gk_lastLaunchEntry", launchEntry)
    local path = cc.UserDefault:getInstance():getStringForKey(gk.lastLaunchEntryKey, launchEntry)
    gk.SceneManager:replace(path)
    --    else
    --        gk.SceneManager:replace(launchEntry)
    --    end
end

function init:initGameKit(mode)
    gk.mode = mode
    local dir, _, _, textureRelativePath, designSize = self:getConfig()
    gk.display:initWithDesignSize(designSize)
    gk.resource.defaultSpritePath = DEBUG > 0 and gk.defaultSpritePathDebug or gk.defaultSpritePathRelease
    gk.resource:setTextureRelativePath(textureRelativePath)
    local strings = {
        en = require(dir .. "gen.value.strings"),
        cn = require(dir .. "gen.value.strings_cn"),
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

    gk.resource:setGenSrcPath(dir)
    gk.resource:setGenOutputPath(dir .. "gen/layout/")
    if platform == 2 and gk.mode == gk.MODE_EDIT then
        --        cc.FileUtils:getInstance():createDirectory(gk.resource.genNodePath)
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        local path = path .. "src/"
        gk.resource:scanGenNodes(path)
    end
end

return init