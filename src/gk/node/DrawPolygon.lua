--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 31/08/2017
-- Time: 18:02
-- To change this template use File | Settings | File Templates.
--

local DrawNode = import(".DrawNode")
local drawPolygon = class("drawPolygon", DrawNode)

function drawPolygon:ctor()
    drawPolygon.super.ctor(self)
    self:addProperty("points", { cc.p(0, 0), cc.p(100, 0), cc.p(100, 50), cc.p(0, 50) })
    self:addProperty("borderWidth", 1)
    self:addProperty("fillColor", cc.c4f(0, 0, 0.5, 0))
    self.pointsNum = 4
end

function drawPolygon:getPointsNum()
    return self.pointsNum
end

function drawPolygon:setPointsNum(pointsNum)
    self.pointsNum = pointsNum
    while #self.points < self.pointsNum do
        table.insert(self.points, cc.pAdd(self.points[#self.points], cc.p(10, 10)))
    end
    self:draw()
end

function drawPolygon:draw()
    drawPolygon.super.draw(self)
    self.child:drawPolygon(self.points, self.pointsNum, self.fillColor, self.borderWidth, self.c4f)
end

function drawPolygon:getMovablePoints()
    local ps = {}
    for i, p in ipairs(self.points) do
        if i > self.pointsNum then
            return {}
        end
        table.insert(ps, p)
    end
    return ps
end

function drawPolygon:setMovablePoints(p, index)
    for i, dst in ipairs(self.points) do
        if i > self.pointsNum then
            return
        end
        if i == index then
            self.points[i] = p
            break
        end
    end
    self:draw()
end

return drawPolygon