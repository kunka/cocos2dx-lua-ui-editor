--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 13/03/2018
-- Time: 14:31
-- To change this template use File | Settings | File Templates.
--

local PopupBg = class("PopupBg", gk.Widget)

function PopupBg:ctor()
    PopupBg.super.ctor(self)
end

function PopupBg:onEnter()
    -- auto set position
    local size = self:getContentSize()
    self.bg:setContentSize(size)
    self.bg:setPosition(cc.p(size.width / 2, size.height / 2))
end

return PopupBg