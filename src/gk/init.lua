--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk = {}
gk.MODE = 1

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
