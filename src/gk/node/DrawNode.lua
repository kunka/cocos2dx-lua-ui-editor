--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 31/08/2017
-- Time: 16:07
-- To change this template use File | Settings | File Templates.
--

local DrawNode = class("DrawNode", function()
    return cc.Node:create()
end)

function DrawNode:ctor()
    self:enableNodeEvents()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self.child = cc.DrawNode:create()
    self:addChild(self.child)
    self:addProperty("c4f", cc.c4f(0, 1, 0, 1))
    self:addProperty("lineWidth", 1)
end

function DrawNode:onEnter()
    self:draw()
end

function DrawNode:addProperty(propName, defaultValue)
    self[propName] = defaultValue
    local getter = "get" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
    local setter = "set" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
    self[getter] = function(_)
        return self[propName]
    end
    self[setter] = function(_, var)
        if self[propName] ~= var then
            self[propName] = var
            self:draw()
        end
    end
end

function DrawNode:addBoolProperty(propName, defaultValue)
    self[propName] = defaultValue
    local getter = "is" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
    local setter = "set" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
    self[getter] = function(_)
        return self[propName]
    end
    self[setter] = function(_, var)
        if self[propName] ~= var then
            self[propName] = var
            self:draw()
        end
    end
end

function DrawNode:draw()
    -- Override to custom draw
    self.child:clear()
    self.child:setLineWidth(self.lineWidth)
end

function DrawNode:afterDraw()
    if self.onDrawCallback then
        self.onDrawCallback()
    end
end

return DrawNode