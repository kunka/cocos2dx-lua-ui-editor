--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 15/08/2017
-- Time: 21:03
-- To change this template use File | Settings | File Templates.
--

local DrawNodeCircle = class("DrawNodeCircle", function()
    return cc.Node:create()
end)

function DrawNodeCircle:ctor()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self.child = cc.DrawNode:create()
    self:addChild(self.child)
    self.radius1 = 100
    self.lineWidth = 1
    self.angle = 0
    self.segments = 50
    self.drawLineToCenter = false
    self.c4f = cc.c4f(0, 1, 0, 1)
    self.solid = false

    local genGetterAndSetter = function(node, propName)
        local getter = "get" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
        local setter = "set" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
        node[getter] = function(_)
            return node[propName]
        end
        node[setter] = function(_, var)
            if node[propName] ~= var then
                node[propName] = var
                self:draw()
            end
        end
    end
    self.isDrawLineToCenter = function()
        return self.drawLineToCenter
    end
    self.setDrawLineToCenter = function(_, drawLineToCenter)
        if drawLineToCenter ~= self.drawLineToCenter then
            self.drawLineToCenter = drawLineToCenter
            self:draw()
        end
    end
    genGetterAndSetter(self, "radius1")
    self.isSolid = function()
        return self.solid
    end
    self.setSolid = function(_, solid)
        if solid ~= self.solid then
            self.solid = solid
            self:draw()
        end
    end

    genGetterAndSetter(self, "angle")
    genGetterAndSetter(self, "segments")
    genGetterAndSetter(self, "lineWidth")
    genGetterAndSetter(self, "c4f")

    self:draw()
end

function DrawNodeCircle:draw()
    self:setContentSize(cc.size(self.radius1 * 2, self.radius1 * 2))
    self.child:clear()
    self.child:setLineWidth(self.lineWidth)
    if self.solid then
        self.child:drawSolidCircle(cc.p(self.radius1, self.radius1), self.radius1, self.angle, self.segments, self.c4f)
    else
        self.child:drawCircle(cc.p(self.radius1, self.radius1), self.radius1, self.angle, self.segments, self.drawLineToCenter, self.c4f)
    end
end

return DrawNodeCircle