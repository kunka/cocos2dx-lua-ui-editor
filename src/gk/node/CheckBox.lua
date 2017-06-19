--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/12/17
-- Time: 14:30
-- To change this template use File | Settings | File Templates.
--

local SpriteButton = import(".SpriteButton")
local CheckBox = class("CheckBox", SpriteButton)

function CheckBox:ctor(...)
    CheckBox.super.ctor(self, ...)
    self.autoSelected = false
end

function CheckBox:onTouchEnded(touch, event)
    if self.trackingTouch then
        self:setSelected(not self.selected)
    end
    CheckBox.super.onTouchEnded(self, touch, event)
end

return CheckBox