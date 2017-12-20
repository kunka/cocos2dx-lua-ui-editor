--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 19/12/2017
-- Time: 18:47
-- To change this template use File | Settings | File Templates.
--
local FSMTransNode = class("FSMTransNode", gk.Widget)

function FSMTransNode:ctor(...)
    self:registerCustomProp("action", "string")
    self:registerCustomProp("from", "string")
    self:registerCustomProp("to", "string")
    FSMTransNode.super.ctor(self, ...)

    self.quadBezierNode1.onDrawCallback = function()
        local origin = self.quadBezierNode1.origin
        local c1 = self.quadBezierNode1.destination[1].c1
        local destination = self.quadBezierNode1.destination[1].dst
        local angle = -180 * cc.pToAngleSelf(cc.pSub(c1, destination)) / math.pi
        self.drawPolygon1:setPosition(destination)
        self.drawPolygon1:setRotation(angle)
        local p = {}
        local t = 0.5
        p.x = math.pow(1 - t, 2) * origin.x + 2.0 * (1 - t) * t * c1.x + t * t * destination.x
        p.y = math.pow(1 - t, 2) * origin.y + 2.0 * (1 - t) * t * c1.y + t * t * destination.y
        self.nameLabel:setPosition(p)
    end
end

function FSMTransNode:setAction(action)
    self.action = action
    if self.nameLabel then
        self.nameLabel:setString(action)
    end
end

return FSMTransNode
