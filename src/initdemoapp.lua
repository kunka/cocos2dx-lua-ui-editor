DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

require "cocos.init"
require "gk.init"

local init = {}

function init:initGameKit(mode)
    gk.mode = mode

    gk.resource.defaultSprite = DEBUG > 0 and "gk/res/texture/default.png" or "gk/res/texture/default_release.png"
    gk.display:initWithDesignSize(cc.size(1280, 720))
    gk.resource:setTextureRelativePath("texture/")
    local strings = {
        en = require("demoapp.gen.value.strings"),
        cn = require("demoapp.gen.value.strings_cn"),
    }
    gk.resource:setGetStringFunc(function(key, lan)
        lan = lan or gk.resource:getCurrentLan()
        return strings[lan][key] or "undefined"
    end)
    gk.resource:setSupportLans(table.keys(strings))

    -- set gen path
    local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
    path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
    local genPath = path .. "src/demoapp/gen/layout/"
    gk.resource.genPath = genPath
    print("gen path = " .. gk.resource.genPath)
    cc.FileUtils:getInstance():createDirectory(gk.resource.genPath)
    -- set gen node search path
    local genNodePath = path .. "src/demoapp/"
    gk.resource:setGenNodePath(genNodePath)
end

function init:startGame(mode)
    gk.log("init:startGame with mode %d", mode)
    init:initGameKit(mode)
    gk.SceneManager:init()
    local key = cc.UserDefault:getInstance():getStringForKey("lastDisplayLayer", "SplashLayer")
    local clazz, layerClazz = gk.resource:require(key, "SplashLayer")
    local isLayer = iskindof(clazz, "Layer")
    if isLayer then
        gk.SceneManager:replace(layerClazz)
    else
        local scene = gk.Layer:createScene()
        local node = clazz:create()
        scene:addChild(node)
        scene.layer = node
        gk.SceneManager:replaceScene(scene)
    end
    gk.util:registerRestartGameCallback(function(...)
        restartGame(...)
    end)
end

return init