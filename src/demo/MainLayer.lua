--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local MainLayer = class("MainLayer", gk.Layer)

function MainLayer:ctor()
    MainLayer.super.ctor(self)
    if self.sprite1 then
--        self.sprite1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5, self.sprite1:getScaleX() * 1.1, self.sprite1:getScaleY() * 1.1), cc.ScaleTo:create(0.5, self.sprite1:getScaleX(), self.sprite1:getScaleX()))))
    end
end

return MainLayer