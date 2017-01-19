--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 上午10:22
-- To change this template use File | Settings | File Templates.
--

local EditBox = class("EditBox", function()
    return cc.Node:create()
end)

function EditBox:ctor(size)
    self:enableNodeEvents()
    self:setContentSize(size)
    self:handleKeyboardEvent()
    self.cursorChar = "|"
    self.enabled = true
end

function EditBox:onInputChanged(callback)
    self.onInputChangedCallback = callback
end

function EditBox:onEditBegan(callback)
    self.onEditBeganCallback = callback
end

function EditBox:onEditEnded(callback)
    self.onEditEndedCallback = callback
end

function EditBox:setScale9SpriteBg(scale9Sprite)
    local contentSize = self:getContentSize()
    self:addChild(scale9Sprite, -1)
    scale9Sprite:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
    scale9Sprite:setContentSize(contentSize)
    self.bg = scale9Sprite
end

function EditBox:setInputLabel(label)
    assert(label:getParent() == nil, "EditBox's input label cannot be added again!")
    self.label = label
    self:addChild(label)
    label:setOverflow(2)
    local contentSize = self:getContentSize()
    label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
    label:setDimensions(contentSize.width, contentSize.height)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
end

function EditBox:getInput()
    return (string.gsub(self.label:getString(), self.cursorChar, ""))
end

function EditBox:setInput(str)
    self.label:setString(str)
end

function EditBox:onEnter()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function EditBox:onTouchBegan(touch, event)
    local camera = cc.Camera:getVisitingCamera()
    if not self.enabled or not self:isVisible() or not camera then
        self:unselected()
        return false
    end
    local c = self:getParent()
    while c ~= nil do
        if not c:isVisible() then
            self:unselected()
            return false
        end
        c = c:getParent()
    end
    assert(self.label, "EditBox's input label is necessary!")
    -- hit test
    if gk.util:hitTest(self, touch) then
        self:selected()
        self.trackingTouch = true
        self.touchBeginPoint = self:convertTouchToNodeSpace(touch)
        return true
    end
    self:unselected()
    return false
end

function EditBox:onTouchMoved(touch, event)
    if self.trackingTouch then
        if gk.util:hitTest(self, touch) then
            -- cancel select item when touch moved too much
            local p = self:convertTouchToNodeSpace(touch)
            if cc.pDistanceSQ(p, self.touchBeginPoint) > 225 then
                --                self:unselected()
                self:stopTracking()
            end
        else
            --            self:unselected()
            self:stopTracking()
        end
    end
end

function EditBox:onTouchEnded(touch, event)
    if self.trackingTouch then
        --        gk.log("EditBox:onTouchEnded")
        --        self:unselected()
        -- must before the callback, callback maybe crash, then touch state will be locked forever.
        self:stopTracking()
    end
end

function EditBox:onTouchCancelled(touch, event)
    if self.trackingTouch then
        --        gk.log("EditBox:onTouchCancelled")
        --        self:unselected()
        self:stopTracking()
    end
end

function EditBox:selected()
    if not self.isSelected then
        self.isSelected = true
        self:focus()
    end
end

function EditBox:unselected()
    if self.isSelected then
        self.isSelected = false
        self:unfocus()
    end
end

function EditBox:focus()
    if gk.focusNode ~= self then
        if gk.focusNode then
            gk.focusNode:unfocus()
        end
        gk.focusNode = self
        gk.util:drawNodeRect(self, cc.c4f(1, 0, 0, 1), -2)
        local str = self:getInput()
        self.label:setString(str .. self.cursorChar)
        self:startBlinkCursor()
        if self.onEditBeganCallback then
            self.onEditBeganCallback(self, self:getInput())
        end
    end
end

function EditBox:unfocus()
    if gk.focusNode == self then
        gk.focusNode = nil
        gk.util:clearDrawNode(self, -2)
        self:stopBlinkCursor()
        local str = self:getInput()
        self.label:setString(str)
        if self.onEditEndedCallback then
            self.onEditEndedCallback(self, self:getInput())
        end
    end
end

function EditBox:startBlinkCursor()
    self.label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        local input = self:getInput()
        if self.cursorChar == "" then
            self.cursorChar = "|"
        else
            self.cursorChar = ""
        end
        self.label:setString(input .. self.cursorChar)
    end))))
end

function EditBox:stopBlinkCursor()
    self.cursorChar = "|"
    self.label:stopAllActions()
end

function EditBox:stopTracking()
    --    gk.log("EditBox:stopTracking")
    self.trackingTouch = false
end

function EditBox:handleKeyboardEvent()
    local function onKeyPressed(keyCode, event)
        if gk.focusNode == self then
            local key = cc.KeyCodeKey[keyCode + 1]
            --            gk.log("%s:onKeyPressed %s", "EditBox", key)
            if key == "KEY_SHIFT" then
                self.shiftPressed = true
                return
            end
            -- TODO: optimize table create
            local keyTable = {}
            if self.shiftPressed then
                local cs = ")!@#$%^&*("
                for i = 0, 9 do
                    keyTable[string.format("KEY_%d", i)] = cs:sub(i + 1, i + 1)
                end
                for i = 97, 97 + 25 do
                    keyTable[string.format("KEY_%s", string.char(i - 32))] = string.char(i - 32)
                end
                keyTable["KEY_MINUS"] = "_"
            else
                for i = 0, 9 do
                    keyTable[string.format("KEY_%d", i)] = string.format("%d", i)
                end
                for i = 97, 97 + 25 do
                    keyTable[string.format("KEY_%s", string.char(i - 32))] = string.char(i)
                end
                keyTable["KEY_MINUS"] = "-"
            end
            keyTable["KEY_PERIOD"] = "."
            keyTable["KEY_SLASH"] = "/"
            --            dump(keyTable)
            local delete = table.indexof(cc.KeyCodeKey, "KEY_BACKSPACE") - 1
            local enter = table.indexof(cc.KeyCodeKey, "KEY_ENTER") - 1
            if keyTable[key] then
                local str = self:getInput()
                self.label:setString(str .. keyTable[key] .. self.cursorChar)
                self:stopBlinkCursor()
                self:startBlinkCursor()
                if self.onInputChangedCallback then
                    self.onInputChangedCallback(self, self:getInput())
                end
            elseif keyCode == delete then
                local str = self:getInput()
                if #str >= 1 then
                    str = string.sub(str, 1, #str - 1)
                    self.label:setString(str .. self.cursorChar)
                    self:stopBlinkCursor()
                    self:startBlinkCursor()
                    if self.onInputChangedCallback then
                        self.onInputChangedCallback(self, self:getInput())
                    end
                end
            elseif keyCode == enter then
                self:unselected()
            end
        end
    end

    local function onKeyReleased(keyCode, event)
        if gk.focusNode == self then
            local key = cc.KeyCodeKey[keyCode + 1]
            --            gk.log("%s:onKeyReleased %s", "EditBox", key)
            if key == "KEY_SHIFT" then
                self.shiftPressed = false
            end
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return EditBox

