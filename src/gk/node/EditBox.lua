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

local kDeleteCharAction = -0xFF22
local kCursorBlinkAction = -0xFF23
local kCursorMoveAction = -0xFF24
local kInsertCharAction = -0xFF25
function EditBox:ctor(size)
    self:enableNodeEvents()
    self:setContentSize(size)
    self:handleKeyboardEvent()
    self.cursorChar = "|"
    self.cursorPos = 0
    self.enabled = true
    self.focusable = true
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
    -- TODO: set independent properties
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
    return self.label:getString()
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

function EditBox:onExit()
    if gk.focusNode == self then
        gk.focusNode = nil
        self.isFocus = false
        gk.log("[EDITBOX] unfocus %s", self:getInput())
    end
end

function EditBox:onTouchBegan(touch, event)
    local camera = cc.Camera:getVisitingCamera()
    if not self.enabled or not self:isVisible() or not camera then
        self:unfocus()
        return false
    end
    local c = self:getParent()
    while c ~= nil do
        if not c:isVisible() then
            self:unfocus()
            return false
        end
        c = c:getParent()
    end
    assert(self.label, "EditBox's input label is necessary!")
    -- hit test
    if gk.util:hitTest(self, touch) then
        self:focus()
        self.trackingTouch = true
        self.touchBeginPoint = self:convertTouchToNodeSpace(touch)
        return true
    end
    self:unfocus()
    return false
end

function EditBox:onTouchMoved(touch, event)
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

function EditBox:onTouchEnded(touch, event)
    if self.trackingTouch then
        --        gk.log("EditBox:onTouchEnded")
        self:stopTracking()
    end
end

function EditBox:onTouchCancelled(touch, event)
    if self.trackingTouch then
        --        gk.log("EditBox:onTouchCancelled")
        self:stopTracking()
    end
end

function EditBox:focus()
    if gk.focusNode ~= self then
        if gk.focusNode then --and gk.focusNode["unfocus"] and type(gk.focusNode["unfocus"]) == "function" then
        gk.focusNode:unfocus()
        end
        gk.focusNode = self
        self.isFocus = true
        gk.util:drawNode(self, cc.c4f(1, 0, 0, 1), -2)
        self:changeCursorPos(self.label:getString():len())
        self:startBlinkCursor(self.cursorPos)
        if self.onEditBeganCallback then
            self.onEditBeganCallback(self, self:getInput())
        end
        -- test draw
        --        local next = gk.nextFocusNode(self)
        --        if next then
        --            gk.log("focus %s, next = %s", self:getInput(), next:getInput())
        --        end
        gk.log("[EDITBOX] focus %s", self:getInput())
    end
end

function EditBox:unfocus()
    if gk.focusNode == self then
        gk.focusNode = nil
        self.isFocus = false
        gk.util:clearDrawNode(self, -2)
        self:stopBlinkCursor()
        if self.onEditEndedCallback then
            self.onEditEndedCallback(self, self:getInput())
        end
        gk.log("[EDITBOX] unfocus %s", self:getInput())
    end
end

function EditBox:startBlinkCursor(cursorPos)
    if self.cursorNode then
        self.cursorPos = cursorPos
        local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            self.cursorNode:setVisible(not self.cursorNode:isVisible())
        end))))
        action:setTag(kCursorBlinkAction)
    end
end

function EditBox:stopBlinkCursor()
    if self.cursorNode then
        self.cursorNode:removeFromParent()
        self.cursorNode = nil
    end
end

function EditBox:changeCursorPos(newPos)
    local input = self.label:getString()
    if newPos >= 0 and newPos <= input:len() then
        gk.log("[EDITBOX]: change cursorPos %d --> %d", self.cursorPos, newPos)
        self.cursorPos = newPos

        if not self.cursorNode then
            -- TODO: fix pos and fontSize
            local fontName = "gk/res/font/Consolas.ttf"
            self.cursorNode = cc.Label:createWithTTF(self.cursorChar, fontName, 32)
            self.cursorNode:setTextColor(cc.c3b(0, 0, 0))
            self.label:addChild(self.cursorNode)
        end
        local pos = cc.p(10, self.label:getContentSize().height / 2)
        if input:len() > 0 and self.cursorPos >= 1 and self.cursorPos <= input:len() then
            local letter = self.label:getLetter(self.cursorPos - 1)
            if letter then
                pos.x = pos.x + letter:getPositionX()
            end
        elseif input:len() == 0 then
            -- empty input
            pos.x = pos.x - self.label:getDimensions().width / 2
        else
            -- not empty input
            local letter = self.label:getLetter(0)
            if letter then
                pos.x = pos.x - letter:getPositionX()
            end
        end
        self.cursorNode:setPosition(pos)

        gk.util:stopActionByTagSafe(self.cursorNode, kCursorBlinkAction)
        self.cursorNode:setVisible(true)
        self:startBlinkCursor(self.cursorPos)
    end
end

function EditBox:stopTracking()
    --    gk.log("EditBox:stopTracking")
    self.trackingTouch = false
end

function EditBox:handleKeyboardEvent()
    local function onKeyPressed(keyCode, event)
        if gk.focusNode == self then
            local key = cc.KeyCodeKey[keyCode + 1]
            gk.log("[EDITBOX]: onKeyPressed %s", key)
            if key == "KEY_LEFT_ARROW" then
                if self.cursorNode then
                    local moveChar = function()
                        local str = self:getInput()
                        if self.cursorPos >= 1 and #str >= 1 then
                            self:changeCursorPos(self.cursorPos - 1)
                        end
                    end
                    moveChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.08), cc.CallFunc:create(function()
                        moveChar()
                    end))))
                    action:setTag(kCursorMoveAction)
                end
                return
            elseif key == "KEY_RIGHT_ARROW" then
                if self.cursorNode then
                    local moveChar = function()
                        self:changeCursorPos(self.cursorPos + 1)
                    end
                    moveChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.08), cc.CallFunc:create(function()
                        moveChar()
                    end))))
                    action:setTag(kCursorMoveAction)
                end
                return
            elseif key == "KEY_SHIFT" then
                self.shiftPressed = true
                return
            elseif key == "KEY_TAB" then
                local next = gk.nextFocusNode(self)
                if next then
                    -- delay
                    self:runAction(cc.CallFunc:create(function()
                        self:unfocus()
                        next:focus()
                    end))
                    return
                end
            end
            local inputTable = self:getInputTable(self.shiftPressed)
            --            dump(inputTable)
            local delete = table.indexof(cc.KeyCodeKey, "KEY_BACKSPACE") - 1
            local enter = table.indexof(cc.KeyCodeKey, "KEY_ENTER") - 1
            if inputTable[key] then
                if self.cursorNode then
                    local insertChar = function()
                        local str = self:getInput()
                        gk.log("[EDITBOX]: insert char '%s' at %d", inputTable[key], self.cursorPos)
                        str = str:insertChar(self.cursorPos + 1, inputTable[key])
                        self.label:setString(str)
                        self:changeCursorPos(self.cursorPos + 1)
                        if self.onInputChangedCallback then
                            self.onInputChangedCallback(self, self:getInput())
                        end
                    end
                    insertChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                        insertChar()
                    end))))
                    action:setTag(kInsertCharAction)
                end
            elseif keyCode == delete then
                if self.cursorNode then
                    local deleteChar = function()
                        local str = self:getInput()
                        if self.cursorPos >= 1 and #str >= 1 then
                            gk.log("[EDITBOX]: delete char at %d", self.cursorPos)
                            str = str:deleteChar(self.cursorPos)
                            self.label:setString(str)
                            self:changeCursorPos(self.cursorPos - 1)
                            if self.onInputChangedCallback then
                                self.onInputChangedCallback(self, self:getInput())
                            end
                        end
                    end
                    deleteChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.08), cc.CallFunc:create(function()
                        deleteChar()
                    end))))
                    action:setTag(kDeleteCharAction)
                end
            elseif keyCode == enter then
                self:unfocus()
            end
        end
    end

    local function onKeyReleased(keyCode, event)
        if gk.focusNode == self then
            local key = cc.KeyCodeKey[keyCode + 1]
            --            gk.log("%s:onKeyReleased %s", "EditBox", key)
            if key == "KEY_BACKSPACE" then
                gk.util:stopActionByTagSafe(self.cursorNode, kDeleteCharAction)
            end
            if key == "KEY_LEFT_ARROW" or key == "KEY_RIGHT_ARROW" then
                gk.util:stopActionByTagSafe(self.cursorNode, kCursorMoveAction)
            end
            local inputTable = self:getInputTable(self.shiftPressed)
            if inputTable[key] then
                gk.util:stopActionByTagSafe(self.cursorNode, kInsertCharAction)
            end
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

function EditBox:getInputTable(shiftPressed)
    local inputTable
    if shiftPressed then
        inputTable = self.inputTableShift
    else
        inputTable = self.inputTable
    end
    if not inputTable then
        inputTable = {}
        if shiftPressed then
            local cs = ")!@#$%^&*("
            for i = 0, 9 do
                inputTable[string.format("KEY_%d", i)] = cs:sub(i + 1, i + 1)
            end
            for i = 97, 97 + 25 do
                inputTable[string.format("KEY_%s", string.char(i - 32))] = string.char(i - 32)
            end
            inputTable["KEY_MINUS"] = "_"
            inputTable["KEY_SLASH"] = "?"
        else
            for i = 0, 9 do
                inputTable[string.format("KEY_%d", i)] = string.format("%d", i)
            end
            for i = 97, 97 + 25 do
                inputTable[string.format("KEY_%s", string.char(i - 32))] = string.char(i)
            end
            inputTable["KEY_MINUS"] = "-"
            inputTable["KEY_SLASH"] = "/"
        end
        inputTable["KEY_PERIOD"] = "."
        inputTable["KEY_SPACE"] = " "
        inputTable["KEY_COMMA"] = ","
        inputTable["KEY_SEMICOLON"] = ";"
        inputTable["KEY_APOSTROPHE"] = "'"

        if shiftPressed then
            self.inputTableShift = inputTable
        else
            self.inputTable = inputTable
        end
    end
    return inputTable
end

return EditBox

