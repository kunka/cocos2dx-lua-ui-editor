local MainModel = class("MainModel")

function MainModel:ctor()
    MainModel.super.ctor(self)

    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    self:addChild(layerColor)

    local sprite = gk.create_sprite("hello")
    self:addChild(sprite)

    local sprite = gk.create_sprite("hello2")
    self:addChild(sprite)
end

function MainModel:onSettingClick()
    gk.SceneManager:pushDialog("demo.SettingDialog")
end

function MainModel:onRankClick()
    gk.SceneManager:push("demo.RankLayer")
end

return MainModel