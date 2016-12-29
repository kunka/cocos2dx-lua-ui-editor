--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/7
-- Time: 下午5:21
-- To change this template use File | Settings | File Templates.
--

-- 弹窗类,默认响应Android back键自动pop自己
local Layer = import(".Layer")
local Dialog = class("Dialog", Layer)

function Dialog:ctor()
    Dialog.super.ctor(self)
    -- 不监听keyPad事件,不要修改,让Layer来处理
    self.enableKeyPad = false
    -- dialog内容bg容器,设置后可以对内容部分做弹出动画
    self.dialogBg = nil
    -- 点击到内容bg外自动pop
    self.popOnTouchOutsideBg = false
    -- 点击到内容bg内自动pop
    self.popOnTouchInsideBg = false
    -- pop动画淡出
    self.popFadeOut = false
    -- 回调
    self.onPop = nil
end

-- 黑色背景
function Dialog:addMaskLayer(opacity)
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    self:addChild(layerColor, -1)
    layerColor:runAction(cc.FadeTo:create(0.15, opacity and opacity or CR_BLACK_COVER_OPACITY))
    self.maskLayer = layerColor
end

-- 使用动画弹出来
function Dialog:animateOut()
    if self.dialogBg then
        self.dialogBg:setScale(0)
        self.dialogBg:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.15, FIX_SCALE)))
    end
end

function Dialog:removeMaskLayer()
    if self.popFadeOut then
        if self.dialogBg then
            self.dialogBg:hide()
        end
        if self.maskLayer then
            self.maskLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.1, 0), cc.CallFunc:create(function()
                self:removeFromParent()
            end)))
        else
            self:runAction(cc.CallFunc:create(function()
                self:removeFromParent()
            end))
        end
    else
        self:runAction(cc.CallFunc:create(function()
            self:removeFromParent()
        end))
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
    removeValue(self.parent.dialogsStack, self)
    -- remove on next tick
    self:removeMaskLayer()
    if self.onPop then
        self.onPop()
    end
end

function Dialog:onKeyBack()
    if self.popOnBack then
        self:pop()
    else
        gk.log("%s:pop onKeyBack is disable", self.__cname)
    end
end

return Dialog