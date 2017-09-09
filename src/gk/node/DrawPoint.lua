--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 03/09/2017
-- Time: 12:09
-- To change this template use File | Settings | File Templates.
--

local DrawNode = import(".DrawNode")
local DrawPoint = class("DrawPoint", DrawNode)

function DrawPoint:ctor()
    DrawPoint.super.ctor(self)

    self:addProperty("pointSize", 10)
    self:addBoolProperty("dot", false)
end

function DrawPoint:draw()
    DrawPoint.super.draw(self)
    self:setContentSize(cc.size(self.pointSize, self.pointSize))
    if self.dot then
        self.child:drawDot(cc.p(self.pointSize / 2, self.pointSize / 2), self.pointSize, self.c4f)
    else
        self.child:drawPoint(cc.p(self.pointSize / 2, self.pointSize / 2), self.pointSize, self.c4f)
    end
end

return DrawPoint