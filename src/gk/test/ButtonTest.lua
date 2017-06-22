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

function ButtonTest:onZoomBtnClicked(button)
    gk.log("onZoomBtnClicked %s", button)
    self.spriteButton:setEnabled(not self.spriteButton.isEnabled)
end

function ButtonTest:onZoomBtnLongPressed(button)
    gk.log("onZoomBtnLongPressed %s", button)
end

function ButtonTest:onSpriteBtnClicked(button)
    gk.log("onSpriteBtnClicked %s", button)
end

function ButtonTest:onSpriteBtnSelectChanged(button, selected)
    gk.log("onSpriteBtnSelectChanged %s --> %s", button, selected)
    self.label2:setColor(selected and cc.c3b(255, 0, 0) or cc.c3b(255, 255, 255))
end

function ButtonTest:onSpriteBtnEnableChanged(button, enabled)
    gk.log("onSpriteBtnEnableChanged %s --> %s", button, enabled)
    self.label2:setColor(enabled and cc.c3b(255, 255, 255) or cc.c3b(128, 128, 128))
end

function ButtonTest:onSelectedTagChanged(button, index)
    gk.log("onSelectedTagChanged %s --> %d", button, index)
    if index >= 1 and index <= 3 then
        local colors = { cc.c3b(255, 0, 0), cc.c3b(0, 255, 0), cc.c3b(0, 0, 255) }
        self.label3:setColor(colors[index])
    end
end

return ButtonTest