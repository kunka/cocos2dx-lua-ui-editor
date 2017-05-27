--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/18
-- Time: 上午11:44
-- To change this template use File | Settings | File Templates.
--

local ZoomButton = import(".ZoomButton")
local ToggleButton = class("ToggleButton", ZoomButton)

function ToggleButton:_addChild(child, zorder, tag)
    if tag then
        self.__addChild(self, child, zorder, tag)
    elseif zorder then
        self.__addChild(self, child, zorder)
    else
        self.__addChild(self, child)
    end
    local tg = child:getTag()
    local isDebugNode = gk.util:isDebugTag(tg)
    if not self.contentNode and not isDebugNode then
        self:setContentNode(child)
    end

    if tg ~= -1 and not isDebugNode then
        child:setVisible(tg ~= -1 and tg == self:getSelectedTag())
    end
end

function ToggleButton:setSelectedTag(tag)
    gk.log("setSelectedTag %s", tag)
    if self.selectedTag ~= tag then
        local children = self:getChildren()
        for i = 1, #children do
            local child = children[i]
            if child and child:getTag() ~= -1 and not gk.util:isDebugNode(child) then
                child:setVisible(tag ~= -1 and child:getTag() == tag)
            end
        end
        self.selectedTag = tag
        if self.onSelectedTagChangedCallback then
            self.onSelectedTagChangedCallback(self, tag)
        end
    end
end

function ToggleButton:getSelectedTag()
    return self.selectedTag or 1
end

function ToggleButton:onSelectedTagChanged(callback)
    self.onSelectedTagChangedCallback = callback
end

function ToggleButton:activate()
    if self.isEnabled then
        local tag = self:getSelectedTag()
        if tag > 0 then
            while true do
                local next = self:getChildByTag(tag + 1)
                if next then
                    self:setSelectedTag(tag + 1)
                    break
                elseif tag == 0 then
                    break
                else
                    tag = 0
                end
            end
        end
        ToggleButton.super.activate(self)
    end
end

return ToggleButton