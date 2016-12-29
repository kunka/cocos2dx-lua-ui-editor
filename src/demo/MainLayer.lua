local MainLayer = class("MainLayer", gk.Layer)

function MainLayer:ctor()
    MainLayer.super.ctor(self)

    local layerColor = cc.LayerColor:create(cc.c4b(100, 0, 0, 100))
    self:addChild(layerColor)

    local sprite = gk.create_sprite("hello")
    self:addChild(sprite)
end

return MainLayer