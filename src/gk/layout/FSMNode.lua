--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 19/12/2017
-- Time: 17:57
-- To change this template use File | Settings | File Templates.
--

local FSMNode = class("FSMNode", gk.Widget)

function FSMNode:ctor(...)
    self.state = ""
    self:registerCustomProp("state", "string")
    self:registerCustomProp("default", "bool")
    FSMNode.super.ctor(self, ...)
end

function FSMNode:setState(state)
    self.state = state
    if self.nameLabel then
        self.nameLabel:setString(((self.default and self.default == 0) and "*" or "") .. self.state)
    end
end

function FSMNode:setSelected(select)
    self.layerColor1:setColor(select and cc.c3b(151, 205, 0) or cc.c3b(153, 153, 153))
end

return FSMNode
