--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 11/08/2017
-- Time: 15:42
-- To change this template use File | Settings | File Templates.
--

local DrawNode = import(".DrawNode")
local CubicBezierNode = class("CubicBezierNode", DrawNode)

function CubicBezierNode:ctor()
    CubicBezierNode.super.ctor(self)
    self:addProperty("origin", cc.p(0, 0))
    self:addProperty("destination", { { c1 = cc.p(0, 0), c2 = cc.p(0, 0), dst = cc.p(100, 0) } })
    self:addProperty("segments", 10)
    self.curvesNum = 1
end

function CubicBezierNode:getCurvesNum()
    return self.curvesNum
end

function CubicBezierNode:setCurvesNum(curvesNum)
    self.curvesNum = curvesNum
    while #self.destination < self.curvesNum do
        table.insert(self.destination, { c1 = cc.p(0, 0), c2 = cc.p(0, 0), dst = cc.p(100, 0) })
    end
    self:draw()
end

function CubicBezierNode:draw()
    CubicBezierNode.super.draw(self)
    if gk.mode == gk.MODE_EDIT then
        -- draw control points
        self.child:drawPoint(self.origin, 5, cc.c4f(1, 0, 0, 0.5))
        for _, dst in ipairs(self.destination) do
            self.child:drawPoint(dst.c1, 5, cc.c4f(1, 1, 0, 0.5))
            self.child:drawPoint(dst.c2, 5, cc.c4f(1, 1, 0, 0.5))
            self.child:drawPoint(dst.dst, 5, cc.c4f(1, 0, 0, 0.5))
        end
    end
    local origin = self.origin
    for i, dst in ipairs(self.destination) do
        if i > self.curvesNum then
            return
        end
        self.child:drawCubicBezier(origin, dst.c1, dst.c2, dst.dst, self.segments, self.c4f)
        origin = dst.dst
    end
end

return CubicBezierNode