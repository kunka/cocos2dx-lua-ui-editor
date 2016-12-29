DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

require "cocos.init"
require "gk.init"

gk.config.defaultSprite = "HelloWorld.png"
gk.display.initWithDesignSize(cc.size(960, 720))

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