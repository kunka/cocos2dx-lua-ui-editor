--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/1/30
-- Time: 上午9:58
-- To change this template use File | Settings | File Templates.
--

local LayerTest = class("LayerTest", gk.Layer)

function LayerTest:ctor()
    LayerTest.super.ctor(self)

    gk.util:drawNode(self.layer2, nil, -3)
    gk.util:drawNode(self.layer3, nil, -3)
    gk.util:drawNode(self.layer5, nil, -3)
end

return LayerTest