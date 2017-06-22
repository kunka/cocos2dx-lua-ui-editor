--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/19/17
-- Time: 09:33
-- To change this template use File | Settings | File Templates.
--

local WidgetTest = class("WidgetTest", gk.Layer)
local model = require("test.model.model")

function WidgetTest:ctor()
    WidgetTest.super.ctor(self)
end

function WidgetTest:onSubDiamond()
    model.diamondCount = model.diamondCount - 10
    gk.event:post("onDiamondChanged", model.diamondCount)
end

function WidgetTest:onAddDiamond()
    model.diamondCount = model.diamondCount + 10
    gk.event:post("onDiamondChanged", model.diamondCount)
end

return WidgetTest