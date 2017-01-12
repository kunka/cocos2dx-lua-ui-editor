--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/11/25
-- Time: 上午10:48
-- To change this template use File | Settings | File Templates.
--

-- ZoomButton点击时带zoom效果
local Button = import(".Button")
local ZoomButton = class("ZoomButton", Button)
local kZoomActionTag = -872738

function ZoomButton:ctor(node, callback)
    ZoomButton.super.ctor(self, callback)
    self:setContentNode(node)
    -- 默认缩放大小
    local width = self:getContentSize().width
    if width <= 100 then
        self.selectedScale = 0.9
    elseif width <= 200 then
        self.selectedScale = 0.9 + 0.05 / 100 * (width - 100)
    elseif width <= 500 then
        self.selectedScale = 0.95 + 0.04 / 300 * (width - 200)
    else
        self.selectedScale = 0.99
    end
end

function ZoomButton:setSelectedScale(scale)
    self.selectedScale = scale
end

function ZoomButton:setSafeAnchor(anchorX, anchorY)
    local contentSize = self:getContentSize()
    local oldAnchor = self:getAnchorPoint()
    local diffX = (anchorX - oldAnchor.x) * contentSize.width * self.originalScaleX
    local diffY = (anchorY - oldAnchor.y) * contentSize.height * self.originalScaleY
    self:setAnchorPoint(cc.p(anchorX, anchorY))
    self:setPositionX(self:getPositionX() + diffX)
    self:setPositionY(self:getPositionY() + diffY)
end

function ZoomButton:selected()
    if self.enabled and not self.isSelected then
        --        gk.log("ZoomButton:selected")
        local action = self:getActionByTag(kZoomActionTag)
        if action then
            self:stopAction(action)
        else
            self.originalScaleX = self:getScaleX()
            self.originalScaleY = self:getScaleY()
        end

        local zoomAction = cc.ScaleTo:create(0.03, self.originalScaleX * self.selectedScale, self.originalScaleY * self.selectedScale)
        zoomAction:setTag(kZoomActionTag)
        self:runAction(zoomAction)

        self.originalAnchor = self:getAnchorPoint()
        self:setSafeAnchor(0.5, 0.5)
    end
    self.isSelected = true
end

function ZoomButton:unselected()
    if self.enabled and self.isSelected then
        --        gk.log("ZoomButton:unselected")
        self:stopActionByTagSafe(kZoomActionTag)
        local action1 = cc.ScaleTo:create(0.04, self.originalScaleX * (1 + (1 - self.selectedScale) / 2), self.originalScaleY * (1 + (1 - self.selectedScale) / 2))
        local action2 = cc.ScaleTo:create(0.04, 0.5 * self.originalScaleX * (self.selectedScale + 1), 0.5 * self.originalScaleY * (self.selectedScale + 1))
        local action3 = cc.ScaleTo:create(0.06, self.originalScaleX, self.originalScaleY)
        local actionAll = cc.Sequence:create(action1, action2, action3)
        local zoomAction = cc.Sequence:create(actionAll, cc.CallFunc:create(function()
            self:setSafeAnchor(self.originalAnchor.x, self.originalAnchor.y)
        end))
        zoomAction:setTag(kZoomActionTag)
        self:runAction(zoomAction)
    end
    self.isSelected = false
end

return ZoomButton