--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk = {}
gk.MODE_RELEASE = 0
gk.MODE_EDIT = 1
gk.mode = gk.MODE_RELEASE
gk.defaultSpritePathDebug = "gk/res/texture/default.png"
gk.defaultSpritePathRelease = "gk/res/texture/release.png"
gk.exception = false

-- export global variable
local __g = _G
gk.exports = {}
setmetatable(gk.exports, {
    __newindex = function(_, name, value)
        rawset(__g, name, value)
    end,
    __index = function(_, name)
        return rawget(__g, name)
    end
})

require "gk.core.init"
require "gk.node.init"
require "gk.controller.init"
gk.util = require "gk.tools.util"
