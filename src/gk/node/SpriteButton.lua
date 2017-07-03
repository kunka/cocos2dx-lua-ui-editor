--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/18/17
-- Time: 15:17
-- To change this template use File | Settings | File Templates.
--

local Button = import(".Button")
local SpriteButton = class("SpriteButton", Button)

function SpriteButton:ctor(normalSprite, selectedSprite, disabledSprite, capInsets)
    self.normalSprite = normalSprite
    self.selectedSprite = selectedSprite and selectedSprite or normalSprite
    self.disabledSprite = disabledSprite and disabledSprite or normalSprite
    self.capInsets = capInsets

    self.__setContentSize = self.setContentSize
    self.setContentSize = function(_self, ...)
        self:_setContentSize(...)
    end
    local content = gk.create_sprite(normalSprite)
    SpriteButton.super.ctor(self, content)
    self.addChild = self.__addChild
end

function SpriteButton:setNormalSprite(normalSprite)
    self.normalSprite = normalSprite
    if self.enabled and not self.selected then
        self:updateSpriteFrame(self.normalSprite)
    end
end

function SpriteButton:setSelectedSprite(selectedSprite)
    self.selectedSprite = selectedSprite
    if self.enabled and self.selected then
        self:updateSpriteFrame(self.selectedSprite)
    end
end

function SpriteButton:setDisabledSprite(disabledSprite)
    self.disabledSprite = disabledSprite
    if not self.enabled then
        self:updateSpriteFrame(self.disabledSprite)
    end
end

function SpriteButton:_setContentSize(size)
    self:__setContentSize(size)
    self.contentNode:setContentSize(size)
    local anchorPoint = self.contentNode:getAnchorPoint()
    self.contentNode:setPosition(cc.p(size.width * anchorPoint.x, size.height * anchorPoint.y))
end

function SpriteButton:updateSpriteFrame(spriteFrameName)
    local pre = self:getContentSize()
    self.contentNode:setSpriteFrame(gk.create_sprite_frame(spriteFrameName))
    self:setContentSize(pre)
end

function SpriteButton:getCapInsets()
    return self.capInsets
end

function SpriteButton:setCapInsets(capInsets)
    self.capInsets = capInsets
    if self.capInsets then
        self.contentNode:setCenterRect(capInsets)
    end
end

function SpriteButton:setSelected(selected)
    if self.enabled and self.selected ~= selected then
        self:updateSpriteFrame(selected and self.selectedSprite or self.normalSprite)
    end
    SpriteButton.super.setSelected(self, selected)
end

function SpriteButton:setEnabled(enabled)
    if self.enabled ~= enabled then
        SpriteButton.super.setEnabled(self, enabled)
        self:updateSpriteFrame(enabled and self.normalSprite or self.disabledSprite)
    end
end

return SpriteButton