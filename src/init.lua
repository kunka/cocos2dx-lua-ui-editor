DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

require "cocos.init"
require "gk.init"

local init = {}

function init:initGameKit(mode)
    gk.MODE = mode

    gk.resource.defaultSprite = "gk/res/texture/default.png"
    gk.display:initWithDesignSize(cc.size(960, 720))
    gk.resource:setTextureRelativePath("texture/")
    gk.resource:setAtlasRelativePath("atlas/")
    local strings = {
        en = require("demo.gen.value.strings"),
        cn = require("demo.gen.value.strings_cn"),
    }
    gk.resource:setStringGetter(function(key, lan)
        return strings[lan][key] or "undefined"
    end)
    gk.resource:setSupportLans(table.keys(strings))

    -- set gen path
    local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
    path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
    local genPath = path .. "src/demo/gen/"
    gk.resource.genPath = genPath
    print("gen path = " .. gk.resource.genPath)
    cc.FileUtils:getInstance():createDirectory(gk.resource.genPath)
    -- set gen node search path
    local genNodePath = path .. "src/demo/"
    gk.resource:setGenNodePath(genNodePath)
end

function init:startGame(mode)
    gk.log("init:startGame with mode %d", mode)
    init:initGameKit(mode)
    gk.SceneManager:init()
    local clazz = cc.UserDefault:getInstance():getStringForKey("lastDisplayLayer", "MainLayer")
    gk.SceneManager:replace(gk.resource.genNodes[clazz])
    gk.util:registerRestartGameCallback(function(...)
        restartGame(...)
    end)
end

return init