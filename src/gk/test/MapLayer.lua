--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 09/09/2017
-- Time: 13:08
-- To change this template use File | Settings | File Templates.
--

local MapLayer = class("MapLayer", gk.PhysicsLayer)

function MapLayer:ctor(...)
    MapLayer.super.ctor(self, ...)

    local radius = 3
    local points = self.drawPolygon1.__info.points
    local pointsNum = self.drawPolygon1.__info.pointsNum
    local outs = {}
    local ins = {}
    for i = 1, pointsNum do
        local p0, p1, p2
        if i == 1 then
            p0 = points[pointsNum]
        else
            p0 = points[i - 1]
        end
        p1 = points[i]
        if i == pointsNum then
            p2 = points[1]
        else
            p2 = points[i + 1]
        end

        local len = cc.pGetLength(cc.pSub(p2, p1))
        local p = cc.pAdd(p1, cc.pMul(cc.pNormalize(cc.pSub(p0, p1)), len))
        p = cc.p((p.x + p2.x) / 2, (p.y + p2.y) / 2)
        local pIn = cc.pAdd(p1, cc.pMul(cc.pNormalize(cc.pSub(p1, p)), radius))
        local pOut = cc.p(2 * p1.x - pIn.x, 2 * p1.y - pIn.y)
        if cc.pGetAngle(cc.pSub(p1, p0), cc.pSub(p2, p1)) < 0 then
            local tmp = pIn
            pIn = pOut
            pOut = tmp
        end
        table.insert(outs, pOut)
        table.insert(ins, pIn)
    end

    local p1 = gk.DrawPolygon:create()
    p1:setPoints(outs)
    p1:setBorderWidth(0.1)
    p1:setC4f(cc.c4f(1, 0, 0, 1))
    p1:setFillColor(cc.c4f(0, 0, 0, 0))
    p1:setPointsNum(pointsNum)
    self.sprite1:addChild(p1)
    p1:setPosition(cc.p(self.sprite1:getContentSize().width / 2, self.sprite1:getContentSize().height / 2))
    local p2 = gk.DrawPolygon:create()
    p2:setPoints(ins)
    p2:setBorderWidth(0.1)
    p2:setC4f(cc.c4f(0, 0, 1, 1))
    p2:setFillColor(cc.c4f(0, 0, 0, 0))
    p2:setPointsNum(pointsNum)
    self.sprite1:addChild(p2)
    p2:setPosition(cc.p(self.sprite1:getContentSize().width / 2, self.sprite1:getContentSize().height / 2))
end

return MapLayer