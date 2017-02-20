--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/10
-- Time: 下午9:34
-- To change this template use File | Settings | File Templates.
--

local LabelTest = class("LabelTest", gk.Layer)

function LabelTest:ctor()
    LabelTest.super.ctor(self)
    local color = cc.c4f(128 / 255, 128 / 255, 0, 255 / 255)
    gk.util:drawNode(self.label4, color, -3)
    gk.util:drawNode(self.label5, color, -3)
    gk.util:drawNode(self.label6, color, -3)
    gk.util:drawNode(self.label7, color, -3)
end

return LabelTest