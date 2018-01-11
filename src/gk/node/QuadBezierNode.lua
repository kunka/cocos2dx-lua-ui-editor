--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 20/12/2017
-- Time: 11:02
-- To change this template use File | Settings | File Templates.
--

local DrawNode = import(".DrawNode")
local QuadBezierNode = class("QuadBezierNode", DrawNode)

function QuadBezierNode:ctor()
    QuadBezierNode.super.ctor(self)
    self:addProperty("origin", cc.p(0, 0))
    self:addProperty("destination", { { c1 = cc.p(50, 50), dst = cc.p(100, 0) } })
    self:addProperty("segments", 50)
    self.curvesNum = 1
end

function QuadBezierNode:getCurvesNum()
    return self.curvesNum
end

function QuadBezierNode:setCurvesNum(curvesNum)
    self.curvesNum = curvesNum
    while #self.destination < self.curvesNum do
        local count = #self.destination
        table.insert(self.destination, { c1 = cc.p(50 + count * 100, 50), dst = cc.p((count + 1) * 100, 0) })
    end
    self:draw()
end

function QuadBezierNode:draw()
    QuadBezierNode.super.draw(self)
    local origin = cc.p(self.origin)
    for i, dst in ipairs(self.destination) do
        if i > self.curvesNum then
            return
        end
        self.child:drawQuadBezier(origin, dst.c1, dst.dst, self.segments, self.c4f)
        origin = dst.dst
    end
    self:afterDraw()
end

function QuadBezierNode:getMovablePoints()
    local ps = {}
    table.insert(ps, self.origin)
    for i, dst in ipairs(self.destination) do
        if i > self.curvesNum then
            return {}
        end
        table.insert(ps, dst.c1)
        table.insert(ps, dst.dst)
    end
    return ps
end

function QuadBezierNode:setMovablePoints(p, index)
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
                self.destination[i].dst = p
                break
            end
        end
    end
    self:draw()
end

return QuadBezierNode