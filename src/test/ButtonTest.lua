--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/18/17
-- Time: 15:31
-- To change this template use File | Settings | File Templates.
--

local ButtonTest = class("ButtonTest", gk.Layer)

function ButtonTest:ctor()
    ButtonTest.super.ctor(self)
end

function ButtonTest:onSpriteButtonClicked(button)
    gk.log("onSpriteButtonClicked %s", button)
end

return ButtonTest