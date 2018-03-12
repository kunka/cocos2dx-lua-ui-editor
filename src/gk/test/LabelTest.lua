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
    local color = cc.c4f(128 / 255, 128 / 255, 0, 100 / 255)
    for _, child in pairs(self:getChildren()) do
        if gk.util:instanceof(child, "cc.Label") and child:getDimensions().width > 0 then
            gk.util:drawNodeBounds(child, color, -3)
        end
    end
end

return LabelTest