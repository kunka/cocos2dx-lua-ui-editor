--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/7/7
-- Time: 下午5:21
-- To change this template use File | Settings | File Templates.
--

--- Pop up dialog: default pop self when click Android back(keyboard Esc)
local Layer = import(".Layer")
local Dialog = class("Dialog", Layer)

function Dialog:ctor()
    -- set default value before ctor, inflate from __info may change it
    self.popOnTouchOutsideBg = false
    self.popOnTouchInsideBg = false
    Dialog.super.ctor(self)
end

function Dialog:setPopOnTouchInsideBg(var)
    self.popOnTouchInsideBg = var
end

function Dialog:isPopOnTouchInsideBg()
    return self.popOnTouchInsideBg
end

function Dialog:setPopOnTouchOutsideBg(var)
    self.popOnTouchOutsideBg = var
end

function Dialog:isPopOnTouchOutsideBg()
    return self.popOnTouchOutsideBg
end

function Dialog:addMaskLayer(opacity)
    local opa = opacity or (Dialog.MASK_OPACITY and Dialog.MASK_OPACITY or 200)
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, opa))
    self:addChild(layerColor, -1)
    self.maskLayer = layerColor
    if gk.display:iPhoneX() then
        local winSize = gk.display:winSize()
        local accWinSize = gk.display:accuWinSize()
        layerColor:setContentSize(accWinSize)
        layerColor:setPositionX(winSize.width / 2 - accWinSize.width / 2)
    end
end

function Dialog:animateOut(callback)
    if gk.mode ~= gk.MODE_EDIT then
        if self.dialogBg then
            local scale = self.dialogBg:getScale()
            self.dialogBg:setScale(0)
            self.dialogBg:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.2, scale)), cc.CallFunc:create(function()
                if callback then
                    callback()
                end
            end)))
        end
        if self.maskLayer then
            local opacity = self.maskLayer:getOpacity()
            self.maskLayer:setOpacity(0)
            self.maskLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.15, opacity), cc.CallFunc:create(function()
                if callback then
                    callback()
                end
            end)))
        end
    else
        if callback then
            callback()
        end
    end
end

function Dialog:onTouchBegan(touch, event)
    if self.popOnTouchOutsideBg and self.popOnTouchInsideBg then
        gk.log("[%s]: popOnTouch", self.__cname)
        self:runAction(cc.CallFunc:create(function()
            self:pop()
        end))
        return true
    end
    if self.dialogBg then
        local location = touch:getLocation()
        local touchBeginPoint = { x = location.x, y = location.y }
        local s = self.dialogBg:getContentSize()
        local rect = { x = 0, y = 0, width = s.width, height = s.height }
        local touchP = self.dialogBg:convertToNodeSpace(touchBeginPoint)
        if not cc.rectContainsPoint(rect, touchP) and gk.mode ~= gk.MODE_EDIT then
            if self.popOnTouchOutsideBg then
                gk.log("[%s]: popOnTouchOutsideBg", self.__cname)
                self:runAction(cc.CallFunc:create(function()
                    self:pop()
                end))
                return true
            end
        else
            if self.popOnTouchInsideBg then
                gk.log("[%s]: popOnTouchInsideBg", self.__cname)
                self:runAction(cc.CallFunc:create(function()
                    self:pop()
                end))
                return true
            end
        end
    end

    return self.swallowTouches
end

function Dialog:pop(...)
    if self.parent then
        gk.log("[%s]: popDialog --> %s", self.parent.__cname, self.__cname)
        table.removebyvalue(self.parent.dialogsStack, self)
        self:retain()
        if self.onPopCallback then
            self.onPopCallback(...)
        end
        self:release()
        self:removeFromParent()
        gk.SceneManager:printSceneStack()
    else
        gk.log("[%s]: pop error, parent is nil", self.__cname)
    end
end

function Dialog:onKeyBack()
    if self.popOnBack then
        gk.log("[%s]: pop onKeyBack", self.__cname)
        if self.onKeyBackCallback then
            self.onKeyBackCallback()
        else
            self:pop()
        end
        return true
    else
        gk.log("[%s]: pop onKeyBack is disable", self.__cname)
        return false
    end
end

function Dialog:show()
    return gk.SceneManager:showDialogNode(self)
end

return Dialog