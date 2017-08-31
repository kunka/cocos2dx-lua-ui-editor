--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 12/08/2017
-- Time: 23:06
-- To change this template use File | Settings | File Templates.
--

local PhysicsTest = class("PhysicsTest", gk.PhysicsLayer)

function PhysicsTest:ctor(...)
    PhysicsTest.super.ctor(self, ...)

    --    local ball = gk.create_sprite("info.png")
    --    -- ball:setScale(1)
    --    local body = cc.PhysicsBody:createCircle(ball:getContentSize().width / 2, cc.PhysicsMaterial(0.1, 0.5, 0.5))
    --    ball:setPhysicsBody(body)
    --    body:setMass(1.0)
    --    body:setMoment(PHYSICS_INFINITY)
    --    body:setVelocity(cc.p(0, 300))
    --    ball:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    --    self:addChild(ball)
    --
    --    local wall = cc.Node:create()
    --    wall:setPhysicsBody(cc.PhysicsBody:createEdgeBox(cc.size(self:getContentSize().width,
    --        self:getContentSize().height),
    --        cc.PhysicsMaterial(0.1, 1.0, 0.0)))
    --    wall:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    --    self:addChild(wall)

    local function onContactBegin(contact)
        print(contact)
        return contact:getContactData().normal.y < 0
    end

    local contactListener = cc.EventListenerPhysicsContactWithBodies:create(self.body1, self.body2)
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self)
end

return PhysicsTest