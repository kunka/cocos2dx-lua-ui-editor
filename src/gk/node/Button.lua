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

function Button:ctor(contentNode, callback)
    self:enableNodeEvents()
    self.callback = callback
    self.enabled = true
    self.isSelected = false
    -- TODO: set selected shader
    self.disabledProgram = nil -- set shader of disabled state
    self.cascadeProgramEnable = true -- set shader of all children(not Label child)
    self.contentNode = nil -- content node, must be set
    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0.5, 0.5)
    self.cacheProgram = {}
    self.trackingTouch = false
    self.delaySelect = nil -- optimize for button in ScrollView
    self.swallowTouches = true

    self.__addChild = self.addChild
    self.addChild = function(_self, ...)
        self:_addChild(...)
    end
    if contentNode then
        self:addChild(contentNode)
    end
end

function Button:_addChild(child, zorder, tag)
    if tag then
        self.__addChild(self, child, zorder, tag)
    elseif zorder then
        self.__addChild(self, child, zorder)
    else
        self.__addChild(self, child)
    end
    if #self:getChildren() == 1 then
        self:setContentNode(child)
    end
end

function Button:getNode()
    return self.contentNode
end

function Button:setContentNode(node)
    --    assert(node:getParent() ~= self, "Button's content node cannot be added again!")
    self.contentNode = node

    local contentSize = node:getContentSize()
    local anchorPoint = node:getAnchorPoint()
    node:setPosition(cc.p(contentSize.width * anchorPoint.x, contentSize.height * anchorPoint.y))
    self:setContentSize(contentSize)

    -- test draw
    if GK_DRAW_BUTTON then
        self:runAction(cc.CallFunc:create(function()
            gk.util:drawNode(self)
        end))
    end
end

function Button:onEnter()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self.swallowTouches)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self.touchListener = listener
end

function Button:setSwallowTouches(swallowTouches)
    if self.swallowTouches ~= swallowTouches then
        gk.log("[%s]: setSwallowTouches %s", self.__cname, swallowTouches)
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
            local type = tolua.type(c)
            if type == "cc.ScrollView" then
                self.delaySelect = true
                self:setSwallowTouches(false)
                gk.log("[%s]: In ScrollView, auto set delaySelect = true, swallowTouches = false", self.__cname)
                break
            end
            c = c:getParent()
        end
    end
end

function Button:onClicked(callback)
    self.callback = callback
end

function Button:onLongPressed(callback)
    self.longPressdCallback = callback
end

function Button:setDisabledProgram(program)
    self.disabledProgram = program
end

function Button:activate()
    if gk.mode == gk.MODE_EDIT and self.__info then
        return
    end
    if self.enabled then
        if self.callback then
            gk.log("[%s]: activate", self.__cname)
            self.callback(self)
        end
    end
end

function Button:triggleLongPressed()
    if gk.mode == gk.MODE_EDIT and self.__info then
        return
    end
    if self.enabled then
        if self.longPressdCallback then
            gk.log("[%s]: triggleLongPressed", self.__cname)
            self.longPressdCallback(self)
        end
    end
end

function Button:selected()
    self.isSelected = true
end

function Button:unselected()
    self.isSelected = false
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
        if self.delaySelect then
            local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(0.064), cc.CallFunc:create(function()
                if self.trackingTouch and not self.isSelected then
                    self:selected()
                end
            end)))
            action:setTag(kDelaySelectActionTag)
        else
            self:selected()
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
    if self.isSelected then
        self:unselected()
    end
    self.trackingTouch = false
    Button.trackingButton = false
    --    gk.log("Button.tracking false")
    gk.util:stopActionByTagSafe(self, kDelaySelectActionTag)
    gk.util:stopActionByTagSafe(self, kLongPressedActionTag)
end

function Button:setEnabled(enabled)
    if self.enabled ~= enabled then
        gk.log("[%s]: setEnabled %s", self.__cname, enabled)
        self.enabled = enabled
        if self.disabledProgram then
            if enabled then
                self:restoreCascadeProgram(self)
            else
                self:setCascadeProgram(self)
            end
        end
    end
end

function Button:onExit()
    if self.trackingTouch then
        --        gk.log("Button:onExit when tracking")
        self:retain()
        self:stopTracking()
        self:release()
    end
end

function Button:setCascadeProgram(node)
    if tolua.type(node) ~= "cc.Label" then
        if node ~= self then
            local pgm = node:getGLProgram()
            if pgm then
                self.cacheProgram[node] = pgm
            end
            node:setGLProgram(self.disabledProgram)
        end
        local children = node:getChildren()
        for _, c in pairs(children) do
            self:setCascadeProgram(c)
        end
    end
end

function Button:restoreCascadeProgram(node)
    if tolua.type(node) ~= "cc.Label" then
        if node ~= self then
            local pgm = self.cacheProgram[node]
            if pgm then
                node:setGLProgram(pgm)
            end
        end
        local children = node:getChildren()
        for _, c in pairs(children) do
            self:restoreCascadeProgram(c)
        end
    end
end

return Button