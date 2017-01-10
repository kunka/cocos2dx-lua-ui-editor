--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 17/1/9
-- Time: 下午4:18
-- To change this template use File | Settings | File Templates.
--

local Node = class("Node", function()
    return cc.Node:create()
end)

function Node:ctor(type)
    gk.log("Node(%s:ctor)", type)
    self.NodeType = type
end

return Node