--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 13/03/2018
-- Time: 14:24
-- To change this template use File | Settings | File Templates.
--

local TextButton = class("TextButton", gk.Widget)

function TextButton:ctor()
    self:registerCustomProp("labelString", "string")
    self:registerCustomProp("onClicked", "function")
    TextButton.super.ctor(self)
end

function TextButton:setLabelString(key)
    if self.label1 then
        if key:len() > 0 and key:sub(1, 1) == "@" then
            key = gk.resource:getString(key:sub(2, #key))
        end
        self.label1:setString(key)
    end
end

function TextButton:setOnClicked(onClicked)
    local func, macro = gk.generator:parseCustomMacroFunc(self, onClicked)
    if func then
        self.button1:onClicked(function()
            func(self.__rootTable, self)
        end)
    end
end

function TextButton:onEnter()
    -- auto set position
    local size = self:getContentSize()
    self.scale9Sprite1:setContentSize(size)
    self.button1:setContentNode(self.scale9Sprite1)
    self.button1:setPosition(cc.p(size.width / 2, size.height / 2))
    self.label1:setPosition(cc.p(size.width / 2, size.height / 2))
end

return TextButton