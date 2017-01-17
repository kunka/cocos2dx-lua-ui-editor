--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk = {}
gk.config = {}

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

----------------------------------------- switch function  -------------------------------------------------
-- function to simulate a switch
local function switch(t)
    t.case = function(self, x, ...)
        local f = self[x] or self.default
        if f then
            if type(f) == "function" then
                return f(...)
            else
                error("case " .. tostring(x) .. " not a function")
            end
        end
        return nil
    end

    return t
end

gk.exports.switch = switch

require "gk.core.init"
require "gk.controller.init"
gk.util = require "gk.util"
