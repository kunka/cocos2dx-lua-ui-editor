--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/22
-- Time: 下午2:32
-- To change this template use File | Settings | File Templates.
--

local ProgressTimerTest = class("ProgressTimerTest", gk.Layer)

function ProgressTimerTest:ctor()
    ProgressTimerTest.super.ctor(self)

    self.progressTimer1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ProgressTo:create(2, 100), cc.ProgressTo:create(2, 0))))
    self.progressTimer2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ProgressTo:create(2, 100), cc.ProgressTo:create(2, 0))))
    self.progressTimer3:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ProgressTo:create(2, 100), cc.ProgressTo:create(2, 0))))
    self.progressTimer4:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ProgressTo:create(2, 100), cc.ProgressTo:create(2, 0))))

    gk.util:drawNodeBounds(self.progressTimer1, nil, -3)
    gk.util:drawNodeBounds(self.progressTimer2, nil, -3)
    gk.util:drawNodeBounds(self.progressTimer3, nil, -3)
    gk.util:drawNodeBounds(self.progressTimer4, nil, -3)
end

return ProgressTimerTest