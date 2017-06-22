--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/25/17
-- Time: 14:46
-- To change this template use File | Settings | File Templates.
--

local DiamondBar = class("DiamondBar", gk.Widget)

function DiamondBar:ctor()
    DiamondBar.super.ctor(self)

    local model = require("gk.test.model.model")
    self.diamondLabel:setString(model.diamondCount)
end

function DiamondBar:onEnter()
    gk.event:subscribe(self, "onDiamondChanged", function(data)
        self.diamondLabel:setString(tostring(data))
    end)
end

function DiamondBar:onExit()
    gk.event:unsubscribe(self, "onDiamondChanged")
end

return DiamondBar