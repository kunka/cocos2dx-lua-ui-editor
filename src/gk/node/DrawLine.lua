--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 03/09/2017
-- Time: 12:32
-- To change this template use File | Settings | File Templates.
--

local DrawNode = import(".DrawNode")
local DrawLine = class("DrawLine", DrawNode)

function DrawLine:ctor()
    DrawLine.super.ctor(self)

    self:addProperty("from", cc.p(0, 0))
    self:addProperty("to", cc.p(100, 50))
    self:addProperty("radius", 5)
    self:addBoolProperty("segment", false)
end

function DrawLine:draw()
    DrawLine.super.draw(self)
    if self.segment then
        self.child:drawSegment(self.from, self.to, self.radius, self.c4f)
    else
        self.child:drawLine(self.from, self.to, self.c4f)
    end
end

function DrawLine:getMovablePoints()
    return { self.from, self.to }
end

function DrawLine:setMovablePoints(p, index)
    if index == 1 then
        self.from = p
    elseif index == 2 then
        self.to = p
    end

    self:draw()
end


return DrawLine