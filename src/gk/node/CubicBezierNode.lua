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
    self:addProperty("destination", { { c1 = cc.p(25, 50), c2 = cc.p(75, -50), dst = cc.p(100, 0) } })
    self:addProperty("segments", 50)
    self.curvesNum = 1
end

function CubicBezierNode:getCurvesNum()
    return self.curvesNum
end

function CubicBezierNode:setCurvesNum(curvesNum)
    self.curvesNum = curvesNum
    while #self.destination < self.curvesNum do
        local count = #self.destination
        table.insert(self.destination, { c1 = cc.p(25 + count * 100, 50), c2 = cc.p(75 + count * 100, -50), dst = cc.p((count + 1) * 100, 0) })
    end
    self:draw()
end

function CubicBezierNode:draw()
    CubicBezierNode.super.draw(self)
    local origin = cc.p(self.origin)
    for i, dst in ipairs(self.destination) do
        if i > self.curvesNum then
            return
        end
        self.child:drawCubicBezier(origin, dst.c1, dst.c2, dst.dst, self.segments, self.c4f)
        origin = dst.dst
    end
    self:afterDraw()
end

function CubicBezierNode:getMovablePoints()
    local ps = {}
    table.insert(ps, self.origin)
    for i, dst in ipairs(self.destination) do
        if i > self.curvesNum then
            return {}
        end
        table.insert(ps, dst.c1)
        table.insert(ps, dst.c2)
        table.insert(ps, dst.dst)
    end
    return ps
end

function CubicBezierNode:setMovablePoints(p, index)
    local idx = 1
    if idx == index then
        self.origin = cc.p(p)
    else
        for i, dst in ipairs(self.destination) do
            idx = idx + 1
            if idx == index then
                self.destination[i].c1 = p
                break
            end
            idx = idx + 1
            if idx == index then
                self.destination[i].c2 = p
                break
            end
            idx = idx + 1
            if idx == index then
                self.destination[i].dst = p
                break
            end
        end
    end
    self:draw()
end

return CubicBezierNode