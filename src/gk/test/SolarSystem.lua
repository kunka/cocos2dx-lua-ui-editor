--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 15/08/2017
-- Time: 22:34
-- To change this template use File | Settings | File Templates.
--

local SolarSystem = class("SolarSystem", gk.Layer)

function SolarSystem:ctor()
    SolarSystem.super.ctor(self)

    local durations = { 0.24, 0.62, 1, 1.88, 11.86, 29.46, 1 / 30 }
    self:move(self.mercury, self.circle_mercury:getContentSize().width / 2, durations[1])
    self:move(self.venus, self.circle_venus:getContentSize().width / 2, durations[2])
    self:move(self.earth, self.circle_earth:getContentSize().width / 2, durations[3])
    self:move(self.mars, self.circle_mars:getContentSize().width / 2, durations[4])
    self:move(self.jupiter, self.circle_jupiter:getContentSize().width / 2, durations[5])
    self:move(self.saturn, self.circle_saturn:getContentSize().width / 2, durations[6])
    self:move(self.moon, self.circle_moon:getContentSize().width / 2, durations[7])
end

function SolarSystem:move(node, radius, dur)
    local magic = 0.552284749831
    local time = 8
    local delta = time * dur / 4
    node:setPosition(cc.p(radius, 0))
    self:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(2, 20) / 10), cc.CallFunc:create(function()
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.BezierTo:create(delta, {
            cc.p(radius * (1 + magic), 0), cc.p(radius * 2, radius * (1 - magic)), cc.p(radius * 2, radius)
        }), cc.BezierTo:create(delta, {
            cc.p(radius * 2, radius * (1 + magic)), cc.p(radius * (1 + magic), radius * 2), cc.p(radius, radius * 2)
        }), cc.BezierTo:create(delta, {
            cc.p(radius * (1 - magic), radius * 2), cc.p(0, radius * (1 + magic)), cc.p(0, radius)
        }), cc.BezierTo:create(delta, {
            cc.p(0, radius * (1 - magic)), cc.p(radius * (1 - magic), 0), cc.p(radius, 0)
        }))))
    end)))
end

return SolarSystem