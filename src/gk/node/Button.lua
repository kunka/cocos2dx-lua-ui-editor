--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/11/25
-- Time: 上午10:37
-- To change this template use File | Settings | File Templates.
--

local Button = class("Button", function()
    return cc.Node:create()
end)
-- TODO: use global
local kDelaySelectActionTag = -0xFFF1
local kLongPressedActionTag = -0xFFF2
Button.trackingButton = false

function Button:ctor(contentNode)
    self:enableNodeEvents()
    self.enabled = true
    self.selected = false
    self.contentNode = nil -- content node, must be set
    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0.5, 0.5)
    self.trackingTouch = false
    self.delaySelect = nil -- optimize for button in ScrollView
    self.swallowTouches = true
    self.autoSelected = true -- auto select and unselect when touch
    self.clickedSid = "" -- sound id, when clicked
    self.cacheProgram = {}
    self.cascadeGLProgramEnabled = true -- set shader of all children(only cc.Sprite)
    self.selectedGLProgram = nil
    self.disabledGLProgram = nil

    self.__addChild = self.addChild
    self.addChild = function(_self, ...)
        self:_addChild(...)
    end
    if contentNode then
        self:_addChild(contentNode)
    else
        self:setContentNode(nil)
    end
end

function Button:_addChild(child, zorder, tag)
    local isDebugNode = gk.util:isDebugTag(tag)
    if self.contentNode and not isDebugNode then
        if tag then
            self.contentNode:addChild(child, zorder, tag)
        elseif zorder then
            self.contentNode:addChild(child, zorder)
        else
            self.contentNode:addChild(child)
        end
    else
        if tag then
            self.__addChild(self, child, zorder, tag)
        elseif zorder then
            self.__addChild(self, child, zorder)
        else
            self.__addChild(self, child)
        end
        if not isDebugNode then
            self:setContentNode(child)
        end
    end
end

function Button:getClickedSid()
    return self.clickedSid
end

function Button:setClickedSid(sid)
    self.clickedSid = sid
end

function Button:getContentNode()
    return self.contentNode
end

function Button:setContentNode(node)
    --    assert(node:getParent() ~= self, "Button's content node cannot be added again!")
    self.contentNode = node

    if node then
        local contentSize = node:getContentSize()
        local anchorPoint = node:getAnchorPoint()
        node:setPosition(cc.p(contentSize.width * anchorPoint.x, contentSize.height * anchorPoint.y))
        self:setContentSize(contentSize)
        if gk.mode == gk.MODE_EDIT and node.__info then
            node.__info._lock = 0
        end
    else
        self:setContentSize(cc.size(150, 50))
    end
end

function Button:getContentSize()
    return self.contentNode and self.contentNode:getContentSize() or cc.size(150, 50)
end

function Button:onEnter()
    gk.util:addMouseMoveEffect(self)
    if gk.mode == gk.MODE_EDIT and self.__info then
        return
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self.swallowTouches)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self.touchListener = listener
    self:updateDelaySelect()
end

function Button:setSwallowTouches(swallowTouches)
    if self.swallowTouches ~= swallowTouches then
        --        gk.log("[%s]: setSwallowTouches %s", self.__cname, swallowTouches)
        self.swallowTouches = swallowTouches
        if self.touchListener then
            self.touchListener:setSwallowTouches(swallowTouches)
        end
    end
end

function Button:updateDelaySelect()
    -- delay select and don't swallow touches when in ScrollView
    if self.delaySelect == nil then
        self.delaySelect = false
        local c = self:getParent()
        while c ~= nil do
            if gk.util:instanceof(c, "cc.ScrollView") then
                self.delaySelect = true
                self:setSwallowTouches(false)
                --                gk.log("[%s]: In ScrollView, auto set delaySelect = true, swallowTouches = false", self.__cname)
                break
            end
            c = c:getParent()
        end
    end
end

function Button:onSelectChanged(callback)
    self.onSelectChangedCallback = callback
end

function Button:onEnableChanged(callback)
    self.onEnableChangedCallback = callback
end

function Button:onClicked(callback)
    self.onClickedCallback = callback
end

function Button:onLongPressed(callback)
    self.longPressdCallback = callback
end

function Button:setDisabledProgram(program)
    self.disabledProgram = program
end

function Button:activate()
    if self.enabled then
        if self.clickedSid then
            gk.audio:playEffect(self.clickedSid)
        end
        if self.onClickedCallback then
            --            gk.log("[%s]: activate", self.__cname)
            self.onClickedCallback(self)
        end
    end
end

function Button:triggleLongPressed()
    if self.enabled then
        if self.longPressdCallback then
            --            gk.log("[%s]: triggleLongPressed", self.__cname)
            self.longPressdCallback(self)
        end
    end
end

function Button:setSelected(selected)
    if self.enabled and self.selected ~= selected then
        self.selected = selected
        if self.enabled and self.selectedGLProgram then
            self:setCascadeProgram(self, selected and self.selectedGLProgram)
        end
        if self.onSelectChangedCallback then
            self.onSelectChangedCallback(self, self.selected)
        end
    end
end

function Button:isSelected()
    return self.selected
end

function Button:setEnabled(enabled)
    if self.enabled ~= enabled then
        self.enabled = enabled
        if self.disabledGLProgram then
            self:setCascadeProgram(self, (not enabled) and self.disabledGLProgram)
        end
        if self.onEnableChangedCallback then
            self.onEnableChangedCallback(self, self.enabled)
        end
    end
end

function Button:isEnabled()
    return self.enabled
end

function Button:onTouchBegan(touch, event)
    local camera = cc.Camera:getVisitingCamera()
    if not self.enabled or not camera then
        return false
    end
    if not gk.util:isAncestorsVisible(self) then
        return false
    end
    -- hit test
    if not Button.trackingButton and gk.util:hitTest(self, touch) then
        --        gk.log("Button:onTouchBegan")
        self:updateDelaySelect()
        if self.autoSelected then
            if self.delaySelect then
                local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(0.048), cc.CallFunc:create(function()
                    if self.trackingTouch and not self.selected then
                        self:setSelected(true)
                    end
                end)))
                action:setTag(kDelaySelectActionTag)
            else
                self:setSelected(true)
            end
        end
        self.longPressdTriggled = false
        local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            if self.trackingTouch then
                self:retain()
                self:stopTracking()
                if self.longPressdCallback then
                    self.longPressdTriggled = true
                    self.longPressdCallback()
                end
                self:release()
            end
        end)))
        action:setTag(kLongPressedActionTag)
        self.trackingTouch = true
        Button.trackingButton = true
        --        gk.log("Button.tracking true")
        self.touchBeginPoint = self:convertTouchToNodeSpace(touch)
        return true
    end

    return false
end

function Button:onTouchMoved(touch, event)
    if self.trackingTouch then
        if gk.util:hitTest(self, touch) then
            -- cancel select item when touch moved too much
            local p = self:convertTouchToNodeSpace(touch)
            if cc.pDistanceSQ(p, self.touchBeginPoint) > 225 then
                self:stopTracking()
            end
        else
            self:stopTracking()
        end
    end
end

function Button:onTouchEnded(touch, event)
    if self.trackingTouch then
        --        gk.log("Button:onTouchEnded")
        self:retain()
        -- must before the callback, callback maybe crash, then touch state will be locked forever.
        self:stopTracking()
        if not self.longPressdTriggled then
            self:activate()
        end
        self:release()
    end
end

function Button:onTouchCancelled(touch, event)
    if self.trackingTouch then
        --        gk.log("Button:onTouchCancelled")
        self:retain()
        self:stopTracking()
        self:release()
    end
end

function Button:stopTracking()
    --    gk.log("Button:stopTracking")
    if self.autoSelected then
        self:setSelected(false)
    end
    self.trackingTouch = false
    Button.trackingButton = false
    --    gk.log("Button.tracking false")
    gk.util:stopActionByTagSafe(self, kDelaySelectActionTag)
    gk.util:stopActionByTagSafe(self, kLongPressedActionTag)
end

function Button:onExit()
    if self.trackingTouch then
        --        gk.log("Button:onExit when tracking")
        self:retain()
        self:stopTracking()
        self:release()
    end
end

function Button:isCascadeGLProgramEnabled()
    return self.cascadeGLProgramEnabled
end

function Button:setCascadeGLProgramEnabled(var)
    self.cascadeGLProgramEnabled = var
end

function Button:getSelectedGLProgram()
    return self.selectedGLProgram
end

function Button:setSelectedGLProgram(var)
    if self.selectedGLProgram ~= var then
        self.selectedGLProgram = var
        if self.enabled and self.selected then
            self:setCascadeProgram(self, self.selectedGLProgram)
        end
    end
end

function Button:getDisabledGLProgram()
    return self.disabledGLProgram
end

function Button:setDisabledGLProgram(var)
    if self.disabledGLProgram ~= var then
        self.disabledGLProgram = var
        if not self.enabled then
            self:setCascadeProgram(self, self.disabledGLProgram)
        end
    end
end

function Button:setCascadeProgram(node, var)
    if var then
        if node ~= self and gk.util:instanceof(node, "cc.Sprite") then
            local pgm = node:getGLProgram()
            if pgm then
                self.cacheProgram[node] = pgm
            end
            local program = cc.GLProgramState:getOrCreateWithGLProgramName(var)
            if program then
                node:setGLProgramState(program)
            end
        end
        if self.cascadeGLProgramEnabled or node == self then
            local children = node:getChildren()
            for _, c in pairs(children) do
                self:setCascadeProgram(c, var)
            end
        end
    else
        self:restoreCascadeProgram(node)
    end
end

function Button:restoreCascadeProgram(node)
    if node ~= self and gk.util:instanceof(node, "cc.Sprite") then
        local pgm = self.cacheProgram[node]
        if pgm then
            node:setGLProgram(pgm)
        end
    end
    if self.cascadeGLProgramEnabled or node == self then
        local children = node:getChildren()
        for _, c in pairs(children) do
            self:restoreCascadeProgram(c)
        end
    end
end

return Button