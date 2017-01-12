DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

require "cocos.init"
require "gk.init"

gk.config.defaultSprite = "HelloWorld.png"
gk.display.initWithDesignSize(cc.size(960, 720))
gk.resource:setTextureRelativePath("texture/")
gk.resource:setAtlasRelativePath("atlas/")

-- set gen path
local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
path = path .. "src/demo/gen/"
gk.config.genPath = path
gk.config.genRelativePath = "demo/gen/"
print("gen path = " .. gk.config.genPath)
print("gen relative path = " .. gk.config.genRelativePath)
cc.FileUtils:getInstance():createDirectory(gk.config.genPath)

local init = {}

function init.startGame()
    gk.log("init.startGame")
    gk.SceneManager:init()
    gk.SceneManager:replace("demo.MainLayer")
    gk.util.registerRestartGameCallback(function()
        restartGame()
    end)
end

return init