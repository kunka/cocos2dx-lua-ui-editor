--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk = {}
gk.MODE_EDIT = 1 -- KEY_F1: debug mode, restart with current editing entry
gk.MODE_RELEASE_CURRENT = 2 -- KEY_F2: release mode, restart with current entry
gk.MODE_RELEASE = 0 -- KEY_F3: release mode, restart with default entry

gk.mode = gk.MODE_RELEASE
gk.defaultSpriteDebug = "gk/res/texture/default_debug.png"
gk.defaultSpriteRelease = "gk/res/texture/default_release.png"
gk.errorOccurs = false -- disable sync when error occurs
gk.displayRuntimeVersion = true -- display runtime version on scene's right-bottom corner
gk.exNodeDisplayer = {} -- for custom nodes

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
require "gk.action.init"
require "gk.node.init"
require "gk.fsm.init"
require "gk.controller.init"
require "gk.editor.init"
require "gk.tools.init"