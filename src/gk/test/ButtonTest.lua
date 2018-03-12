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
    gk.log("onZoomBtnClicked")
end

function ButtonTest:onZoomBtnLongPressed(button)
    gk.log("onZoomBtnLongPressed")
end

function ButtonTest:onSpriteBtnClicked(button)
    gk.log("onSpriteBtnClicked")
end

function ButtonTest:onSpriteBtnSelectChanged(button, selected)
    gk.log("onSpriteBtnSelectChanged %s", selected)
end

function ButtonTest:onSpriteBtnEnableChanged(button, enabled)
    gk.log("onSpriteBtnEnableChanged %s", enabled)
end

function ButtonTest:onSelectedTagChanged(button, tag)
    gk.log("onSelectedTagChanged %d", tag)
    if tag >= 1 and tag <= 3 then
        local colors = { cc.c3b(255, 255, 255), cc.c3b(0, 255, 0), cc.c3b(0, 0, 255) }
        self.label3:setColor(colors[tag])
    end
end

return ButtonTest