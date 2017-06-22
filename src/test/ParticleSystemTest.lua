--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/20/17
-- Time: 16:39
-- To change this template use File | Settings | File Templates.
--

local ParticleSystemTest = class("ParticleSystemTest", gk.Layer)

function ParticleSystemTest:ctor()
    ParticleSystemTest.super.ctor(self)

    self.sprite1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(2, cc.p(0, 500 * gk.display:minScale())),
        cc.MoveBy:create(2, cc.p(0, -500 * gk.display:minScale())))))
    self.particleSystemQuad2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(2, cc.p(0, 500 * gk.display:minScale())),
        cc.MoveBy:create(2, cc.p(0, -500 * gk.display:minScale())))))
end

return ParticleSystemTest