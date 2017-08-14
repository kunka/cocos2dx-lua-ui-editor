--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/18/17
-- Time: 15:17
-- To change this template use File | Settings | File Templates.
--

local Button = import(".Button")
local SpriteButton = class("SpriteButton", Button)

gk.SELECT_MODE_REPLACE = 0 -- replace image on state changed
gk.SELECT_MODE_OVERLAY = 1 -- add image on normalSprite on state changed

function SpriteButton:ctor(normalSprite, selectedSprite, disabledSprite, capInsets)
    self.normalSprite = normalSprite
    self.selectedSprite = selectedSprite and selectedSprite or normalSprite
    self.disabledSprite = disabledSprite and disabledSprite or normalSprite
    self.capInsets = capInsets
    self.selectMode = gk.SELECT_MODE_REPLACE

    self.__setContentSize = self.setContentSize
    self.setContentSize = function(_self, ...)
        self:_setContentSize(...)
    end
    local content = gk.create_sprite(normalSprite)
    SpriteButton.super.ctor(self, content)
    self.addChild = self.__addChild
end

function SpriteButton:setSelectMode(mode)
    if self.selectMode ~= mode then
        self.selectMode = mode
        if mode == gk.SELECT_MODE_OVERLAY then
            self.overlay = gk.create_sprite(self.normalSprite)
            self:addChild(self.overlay)
            self.overlay:setTag(gk.util.tags.buttonOverlayTag)
        else
            if self.overlay then
                self.overlay:removeFromParent()
                self.overlay = nil
            end
        end
        self:updateSpriteFrame()
    end
end

function SpriteButton:getSelectMode()
    return self.selectMode
end

function SpriteButton:setNormalSprite(normalSprite)
    self.normalSprite = normalSprite
    self:updateSpriteFrame()
end

function SpriteButton:setSelectedSprite(selectedSprite)
    self.selectedSprite = selectedSprite
    self:updateSpriteFrame()
end

function SpriteButton:setDisabledSprite(disabledSprite)
    self.disabledSprite = disabledSprite
    self:updateSpriteFrame()
end

function SpriteButton:_setContentSize(size)
    self:__setContentSize(size)
    if self.capInsets and self.capInsets.width ~= 0 and self.capInsets.height ~= 0 then
        self.contentNode:setContentSize(size)
    end
    local anchorPoint = self.contentNode:getAnchorPoint()
    self.contentNode:setPosition(cc.p(size.width * anchorPoint.x, size.height * anchorPoint.y))
    if self.overlay then
        if self.capInsets and self.capInsets.width ~= 0 and self.capInsets.height ~= 0 then
            self.overlay:setContentSize(size)
        end
        self.overlay:setPosition(cc.p(size.width * anchorPoint.x, size.height * anchorPoint.y))
    end
end

function SpriteButton:updateSpriteFrame()
    local pre = self:getContentSize()
    local spriteFrameName = self.enabled and (self.selected and self.selectedSprite or self.normalSprite) or self.disabledSprite
    if self.selectMode == gk.SELECT_MODE_REPLACE then
        self.contentNode:setSpriteFrame(gk.create_sprite_frame(spriteFrameName))
    elseif self.selectMode == gk.SELECT_MODE_OVERLAY and self.overlay then
        if self.enabled and not self.selected then
            self.overlay:hide()
            self.contentNode:setSpriteFrame(gk.create_sprite_frame(spriteFrameName))
        else
            self.overlay:show()
            self.overlay:setSpriteFrame(gk.create_sprite_frame(spriteFrameName))
        end
    end
    self:setContentSize(pre)
end

function SpriteButton:getCapInsets()
    return self.capInsets
end

function SpriteButton:setCapInsets(capInsets)
    self.capInsets = capInsets
    if self.capInsets and capInsets.width ~= 0 and capInsets.height ~= 0 then
        self.contentNode:setCenterRect(capInsets)
        if self.overlay then
            self.overlay:setCenterRect(capInsets)
        end
    end
end

function SpriteButton:setSelected(selected)
    if self.enabled and self.selected ~= selected then
        SpriteButton.super.setSelected(self, selected)
        self:updateSpriteFrame()
    end
end

function SpriteButton:setEnabled(enabled)
    if self.enabled ~= enabled then
        SpriteButton.super.setEnabled(self, enabled)
        self:updateSpriteFrame()
    end
end

return SpriteButton