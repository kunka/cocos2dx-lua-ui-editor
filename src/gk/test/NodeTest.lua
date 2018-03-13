--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/3/1
-- Time: 下午9:26
-- To change this template use File | Settings | File Templates.
--

local NodeTest = class("NodeTest", gk.Layer)

function NodeTest:ctor()
    NodeTest.super.ctor(self)
    gk.util:drawNodeBounds(self.layer1, nil, -3)
    gk.util:drawNodeBounds(self.scrollView1, nil, -3)
end

return NodeTest