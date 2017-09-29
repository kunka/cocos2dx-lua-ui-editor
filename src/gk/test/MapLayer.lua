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

    local wall = cc.Node:create()
    wall:setPosition(cc.p(self.sprite1:getContentSize().width / 2, self.sprite1:getContentSize().height / 2))
    self.sprite1:addChild(wall)
    local obj = cc.PhysicsBody:create()
    wall:setPhysicsBody(obj)
    for i = 1, pointsNum do
        local p1, p2
        if i == 1 then
            p1 = outs[pointsNum]
        else
            p1 = outs[i - 1]
        end
        p2 = outs[i]
        local shape = cc.PhysicsShapeEdgeSegment:create(p1, p2, { density = 0, restitution = 0.5, friction = 0.5 })
        obj:addShape(shape)
    end
    for i = 1, pointsNum do
        local p1, p2
        if i == 1 then
            p1 = ins[pointsNum]
        else
            p1 = ins[i - 1]
        end
        p2 = ins[i]
        local shape = cc.PhysicsShapeEdgeSegment:create(p1, p2, { density = 0, restitution = 0.5, friction = 0.5 })
        obj:addShape(shape)
    end

    local center = cc.p(self.sprite1:getContentSize().width / 2, self.sprite1:getContentSize().height / 2)
    self.sprite2:setPosition(cc.pAdd(center, cc.p(-12.5, 73.5)))

    --    local p1 = gk.DrawPolygon:create()
    --    p1:setPoints(outs)
    --    p1:setBorderWidth(0.1)
    --    p1:setC4f(cc.c4f(1, 0, 0, 1))
    --    p1:setFillColor(cc.c4f(0, 0, 0, 0))
    --    p1:setPointsNum(pointsNum)
    --    self.sprite1:addChild(p1)
    --    p1:setPosition(cc.p(self.sprite1:getContentSize().width / 2, self.sprite1:getContentSize().height / 2))
    --    local p2 = gk.DrawPolygon:create()
    --    p2:setPoints(ins)
    --    p2:setBorderWidth(0.1)
    --    p2:setC4f(cc.c4f(0, 0, 1, 1))
    --    p2:setFillColor(cc.c4f(0, 0, 0, 0))
    --    p2:setPointsNum(pointsNum)
    --    self.sprite1:addChild(p2)
    --    p2:setPosition(cc.p(self.sprite1:getContentSize().width / 2, self.sprite1:getContentSize().height / 2))

    --        self.body1:applyForce(cc.p(5000, 0))
    self.body1:applyImpulse(cc.p(200, 0))
    --    self:runAction(cc.Follow:create(self.sprite2,self.layerColor1:getBoundingBox()))
    --        self.layerColor1:runAction(cc.Follow:create(self.sprite2))
    local size = self.layerColor1:getContentSize()
    print(self.layerColor1:getPosition())
    self:scheduleUpdateWithPriorityLua(function(delta)
        local p = cc.p(self.sprite2:getPosition())
        p = self.sprite1:convertToWorldSpace(p)
        p = self.layerColor1:convertToNodeSpace(p)
        --    print(p.x, p.y)
        p = cc.p(p.x - size.width / 2, p.y - size.height / 2)
        --    print(p.x, p.y)
        p = cc.pMul(p, self.layerColor1:getScale())
        --    print(p.x, p.y)
        p = cc.p(1280 / 2 * gk.display:xScale() - p.x, 768 / 2 * gk.display:yScale() - p.y)
        --    print(p.x, p.y)
        self.layerColor1:setPosition(p)

        --        self.layerColor1:setPosition(size.width / 2 - p.x, size.height / 2 - p.y)
        --                self.layerColor1:setPosition(size.width / 2 - p.x, size.height / 2 - p.y)
    end, 0)
end

function MapLayer:onTouchBegan(touch, event)
    local location = touch:getLocation()
    if location.x < self:getContentSize().width / 2 then
        local rotation = self.sprite2:getRotation()
        self.sprite2:setRotation(rotation - 5)
    else
        local rotation = self.sprite2:getRotation()
        self.sprite2:setRotation(rotation + 5)
    end
    return MapLayer.super.onTouchBegan(self, touch, event)
end

return MapLayer