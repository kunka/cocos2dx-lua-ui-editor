--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 15/08/2017
-- Time: 21:03
-- To change this template use File | Settings | File Templates.
--

local DrawNode = import(".DrawNode")
local DrawNodeCircle = class("DrawNodeCircle", DrawNode)

function DrawNodeCircle:ctor()
    DrawNodeCircle.super.ctor(self)

    self:addProperty("radius", 100)
    self:addProperty("angle", 0)
    self:addProperty("segments", 50)
    self:addBoolProperty("drawLineToCenter", false)
    self:addBoolProperty("solid", false)
end

function DrawNodeCircle:draw()
    DrawNodeCircle.super.draw(self)
    self:setContentSize(cc.size(self.radius * 2, self.radius * 2))
    if gk.mode == gk.MODE_EDIT then
        -- draw control points
        self.child:drawPoint(cc.p(self.radius, self.radius), 5, cc.c4f(1, 0, 0, 0.5))
    end
    if self.solid then
        self.child:drawSolidCircle(cc.p(self.radius, self.radius), self.radius, self.angle, self.segments, self.c4f)
    else
        self.child:drawCircle(cc.p(self.radius, self.radius), self.radius, self.angle, self.segments, self.drawLineToCenter, self.c4f)
    end
end

return DrawNodeCircle