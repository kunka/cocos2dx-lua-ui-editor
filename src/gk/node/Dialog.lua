--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/7/7
-- Time: 下午5:21
-- To change this template use File | Settings | File Templates.
--

-- Pop up dialog, default pop self when click Android back
local Layer = import(".Layer")
local Dialog = class("Dialog", Layer)

function Dialog:ctor()
    Dialog.super.ctor(self)
    -- set dialog bg, use to animate out
    self.enableKeyPad = false
    self.popOnBack = true -- popScene on back
    self.popOnTouchOutsideBg = false
    self.popOnTouchInsideBg = false
end

function Dialog:addMaskLayer(opacity)
    if gk.mode ~= gk.MODE_EDIT then
        -- black cover bg
        local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
        self:addChild(layerColor, -1)
        layerColor:runAction(cc.FadeTo:create(0.15, opacity and opacity or 156))
        self.maskLayer = layerColor
    end
end

function Dialog:animateOut()
    if gk.mode ~= gk.MODE_EDIT then
        if self.dialogBg then
            self.dialogBg:setScale(0)
            self.dialogBg:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.15, gk.display.minScale())))
        end
    end
end

function Dialog:onTouchBegan(touch, event)
    if self.dialogBg then
        local location = touch:getLocation()
        local touchBeginPoint = { x = location.x, y = location.y }
        local s = self.dialogBg:getContentSize()
        local rect = { x = 0, y = 0, width = s.width, height = s.height }
        local touchP = self.dialogBg:convertToNodeSpace(touchBeginPoint)
        if not cc.rectContainsPoint(rect, touchP) then
            if self.popOnTouchOutsideBg then
                gk.log("%s:popOnTouchOutsideBg", self.__cname)
                self:runAction(cc.CallFunc:create(function()
                    self:pop()
                end))
                return self.swallowTouchEvent
            end
        else
            if self.popOnTouchInsideBg then
                gk.log("%s:popOnTouchInsideBg", self.__cname)
                self:runAction(cc.CallFunc:create(function()
                    self:pop()
                end))
                return self.swallowTouchEvent
            end
        end
    end

    return self.swallowTouchEvent
end

function Dialog:pop()
    gk.log("%s:popDialog --> %s", self.parent.__cname, self.__cname)
    table.removebyvalue(self.parent.dialogsStack, self)
    self:retain()
    if self.onPopCallback then
        self.onPopCallback()
    end
    self:release()
    self:removeFromParent()
end

function Dialog:onKeyBack()
    if self.popOnBack then
        self:pop()
    else
        gk.log("%s:pop onKeyBack is disable", self.__cname)
    end
end

function Dialog:show()
    return gk.SceneManager:showDialogNode(self)
end

return Dialog