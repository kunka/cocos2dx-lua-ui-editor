local MainLayer = class("MainLayer", gk.Layer)

function MainLayer:ctor()
    MainLayer.super.ctor(self)
end

function MainLayer:onEnter()
    if self.Sprite1 then
        self.Sprite1:runAction(cc.RepeatForever:create(cc.ScaleTo:create(0.5, self.Sprite1:getScale() * 1.1, cc.ScaleTo:create(0.5, self.Sprite1:getScale()))))
    end
end

return MainLayer