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
    dump(self.progressTime1)
    dump(self.progressTime1_sprite)
end

return ProgressTimerTest