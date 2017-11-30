--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 上午10:22
-- To change this template use File | Settings | File Templates.
--

--- [Editor use only]
local EditBox = class("EditBox", function()
    return cc.Node:create()
end)

-- TODO: use global
local kDeleteCharAction = -0xFFFF1
local kCursorBlinkAction = -0xFFFF2
local kCursorMoveAction = -0xFFFF3
local kInsertCharAction = -0xFFFF4
local kRepeatActionDur = 0.12
local kRepeatInsertActionDur = 0.15
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

function EditBox:setAutoCompleteFunc(func)
    self.autoCompleteFunc = func
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

    gk.util:addMouseMoveEffect(self)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC then
        local listener = cc.EventListenerMouse:create()
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocationInView()
            if gk.util:touchInNode(self, location) then
                if not self.isFocus then
                    gk.util:drawNodeBounds(self, cc.c4f(1, 0.5, 0.5, 0.7), -3)
                end
            else
                gk.util:clearDrawNode(self, -3)
            end
        end, cc.Handler.EVENT_MOUSE_MOVE)
        self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    end
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
        gk.util:drawNodeBounds(self, cc.c4f(1, 0, 0, 1), -2)
        self:changeCursorPos(self.label:getString():len())
        self:startBlinkCursor(self.cursorPos)
        if self.onEditBeganCallback then
            self.onEditBeganCallback(self, self:getInput())
        end
        if self.autoCompleteFunc then
            self:openPopup(self.autoCompleteFunc(self:getInput()))
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
        self.cursorNode:stopAllActions()
        self:stopBlinkCursor()
        if self.onEditEndedCallback then
            self.onEditEndedCallback(self, self:getInput())
        end
        self:closePopup()
        gk.log("[EDITBOX] unfocus %s", self:getInput())
    end
end

function EditBox:startBlinkCursor(cursorPos)
    if self.cursorNode then
        gk.util:stopActionByTagSafe(self.cursorNode, kCursorBlinkAction)
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
        --        gk.log("[EDITBOX]: change cursorPos %d --> %d, len = %d", self.cursorPos, newPos, input:len())
        self.cursorPos = newPos

        if not self.cursorNode then
            -- TODO: fix pos and fontSize
            local fontName = gk.theme.font_fnt
            self.cursorNode = gk.create_label(self.cursorChar, fontName, 32)
            self.cursorNode:setColor(cc.c3b(0, 0, 0))
            self.label:addChild(self.cursorNode)
        end
        local pos = cc.p(10, self.label:getContentSize().height / 2)
        if input:len() > 0 and self.cursorPos >= 1 and self.cursorPos <= input:len() then
            local letter = self.label:getLetter(self.cursorPos - 1)
            if letter then
                if letter:getContentSize().width == 0 or letter:getPositionX() == 0 then
                    -- letter like " ", contentSize and posX has bug! maybe zero
                    local offset = 0
                    for i = self.cursorPos - 1, 0, -1 do
                        local pre = self.label:getLetter(i)
                        if pre and pre:getContentSize().width > 0 and letter:getPositionX() > 0 then
                            pos.x = pos.x + pre:getPositionX()
                            break
                        end
                        offset = offset + 1
                    end
                    pos.x = pos.x + (self.lastLetterWidth or 15) * offset
                else
                    self.lastLetterWidth = self.lastLetterWidth or letter:getContentSize().width
                    pos.x = pos.x + letter:getPositionX()
                end
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
            gk.util:stopActionByTagSafe(self.cursorNode, kDeleteCharAction)
            gk.util:stopActionByTagSafe(self.cursorNode, kCursorMoveAction)
            gk.util:stopActionByTagSafe(self.cursorNode, kInsertCharAction)

            if key == "KEY_HYPER" then
                self.commandPressed = true
                return
            elseif key == "KEY_SHIFT" then
                self.shiftPressed = true
                return
            end
            if self.commandPressed then
                if key == "KEY_BACKSPACE" then
                    --                        gk.log("[EDITBOX]: clear all chars")
                    self.label:setString("")
                    self:changeCursorPos(0)
                    self:_onInputChanged()
                    return
                end
                if key == "KEY_V" then
                    local v = io.popen("pbpaste"):read("*all")
                    if v and v ~= "" then
                        --                        gk.log("past string %s", v)
                        local str = self:getInput()
                        str = str:insertChar(self.cursorPos + 1, v)
                        --                        gk.log("[EDITBOX]: insert char '%s' at %d, str = %s", v, self.cursorPos, str)
                        self.label:setString(str)
                        self:changeCursorPos(self.cursorPos + v:len())
                        self:_onInputChanged()
                    end
                elseif key == "KEY_C" or key == "KEY_X" then
                    local str = self:getInput()
                    io.popen("printf " .. str .. " | pbcopy")
                    local v = io.popen("pbpaste"):read("*all")
                    --                    gk.log("copy string %s", v)
                    if key == "KEY_X" then
                        self.label:setString("")
                        self:changeCursorPos(0)
                        self:_onInputChanged()
                    end
                end
                return
            end
            if key == "KEY_LEFT_ARROW" then
                if self.cursorNode then
                    local moveChar = function()
                        local str = self:getInput()
                        if self.cursorPos >= 1 and #str >= 1 then
                            self:changeCursorPos(self.cursorPos - 1)
                        end
                    end
                    moveChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(kRepeatActionDur), cc.CallFunc:create(function()
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
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(kRepeatActionDur), cc.CallFunc:create(function()
                        moveChar()
                    end))))
                    action:setTag(kCursorMoveAction)
                end
                return
            elseif key == "KEY_UP_ARROW" then
                if self.popup then
                    self:setSelectIndex(self.selectIndex - 1)
                else
                    -- number var ++
                    if tonumber(self:getInput()) then
                        local changeVar = function()
                            local numVar = tonumber(self:getInput())
                            local str = tostring(numVar + 0.5)
                            self.label:setString(str)
                            self:changeCursorPos(str:len())
                            if self.onEditEndedCallback then
                                self.onEditEndedCallback(self, self:getInput(), true)
                            end
                        end
                        changeVar()
                        local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(kRepeatActionDur / 2), cc.CallFunc:create(function()
                            changeVar()
                        end))))
                        action:setTag(kCursorMoveAction)
                    end
                end
                return
            elseif key == "KEY_DOWN_ARROW" then
                if self.popup then
                    self:setSelectIndex(self.selectIndex + 1)
                else
                    -- number var --
                    if tonumber(self:getInput()) then
                        local changeVar = function()
                            local numVar = tonumber(self:getInput())
                            local str = tostring(numVar - 0.5)
                            self.label:setString(str)
                            self:changeCursorPos(str:len())
                            if self.onEditEndedCallback then
                                self.onEditEndedCallback(self, self:getInput(), true)
                            end
                        end
                        changeVar()
                        local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(kRepeatActionDur / 2), cc.CallFunc:create(function()
                            changeVar()
                        end))))
                        action:setTag(kCursorMoveAction)
                    end
                end
                return
            elseif key == "KEY_TAB" then
                --                local root = gk.util:getRootNode(self)
                --                local next = gk.nextFocusNode(self, root)
                --                if next then
                --                    -- delay
                --                    self:runAction(cc.CallFunc:create(function()
                --                        self:unfocus()
                --                        next:focus()
                --                    end))
                --                    return
                --                end
                local x, y = self:getPosition()
                local root = gk.util:getRootNode(self)
                local next = gk.__nextFocusNode(x, y, root)
                if next then
                    self:unfocus()
                end
                -- delay
                root:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
                    local next = gk.__nextFocusNode(x, y, root)
                    if next then
                        next:focus()
                    end
                end)))
                return
            end
            local inputTable = self:getInputTable(self.shiftPressed)
            --            dump(inputTable)
            local delete = table.indexof(cc.KeyCodeKey, "KEY_BACKSPACE") - 1
            local enter = table.indexof(cc.KeyCodeKey, "KEY_ENTER") - 1
            local esc = table.indexof(cc.KeyCodeKey, "KEY_ESCAPE") - 1
            if inputTable[key] then
                if self.cursorNode then
                    local insertChar = function()
                        local str = self:getInput()
                        str = str:insertChar(self.cursorPos + 1, inputTable[key])
                        --                        gk.log("[EDITBOX]: insert char '%s' at %d, str = %s", inputTable[key], self.cursorPos, str)
                        self.label:setString(str)
                        self:changeCursorPos(self.cursorPos + 1)
                        self:_onInputChanged()
                    end
                    insertChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(kRepeatInsertActionDur), cc.CallFunc:create(function()
                        insertChar()
                    end))))
                    action:setTag(kInsertCharAction)
                end
            elseif keyCode == delete then
                if self.cursorNode then
                    local deleteChar = function()
                        local str = self:getInput()
                        if self.cursorPos >= 1 and #str >= 1 then
                            str = str:deleteChar(self.cursorPos)
                            --                            gk.log("[EDITBOX]: delete char at %d, str = %s", self.cursorPos, str)
                            self.label:setString(str)
                            self:changeCursorPos(self.cursorPos - 1)
                            self:_onInputChanged()
                        end
                    end
                    deleteChar()
                    local action = self.cursorNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(kRepeatActionDur), cc.CallFunc:create(function()
                        deleteChar()
                    end))))
                    action:setTag(kDeleteCharAction)
                end
            elseif keyCode == enter then
                if self.popup then
                    local str = self.prefix .. self.items[self.selectIndex]
                    self.label:setString(str)
                    self:changeCursorPos(str:len())
                    self:_onInputChanged(self.prefix ~= "")
                else
                    self:unfocus()
                end
            elseif keyCode == esc then
                self:unfocus()
            end
        end
    end

    local function onKeyReleased(keyCode, event)
        if gk.focusNode == self then
            local key = cc.KeyCodeKey[keyCode + 1]
            --            gk.log("%s:onKeyReleased %s", "EditBox", key)
            gk.util:stopActionByTagSafe(self.cursorNode, kDeleteCharAction)
            gk.util:stopActionByTagSafe(self.cursorNode, kCursorMoveAction)
            gk.util:stopActionByTagSafe(self.cursorNode, kInsertCharAction)
            if key == "KEY_SHIFT" then
                self.shiftPressed = false
            end
            if key == "KEY_HYPER" then
                self.commandPressed = false
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
            inputTable["KEY_GRAVE"] = "~"
            inputTable["KEY_MINUS"] = "_"
            inputTable["KEY_EQUAL"] = "+"
            inputTable["KEY_LEFT_BRACKET"] = "{"
            inputTable["KEY_RIGHT_BRACKET"] = "}"
            inputTable["KEY_BACK_SLASH"] = "|"
            inputTable["KEY_SEMICOLON"] = ":"
            inputTable["KEY_APOSTROPHE"] = "\""
            inputTable["KEY_COMMA"] = "<"
            inputTable["KEY_PERIOD"] = ">"
            inputTable["KEY_SLASH"] = "?"
        else
            for i = 0, 9 do
                inputTable[string.format("KEY_%d", i)] = string.format("%d", i)
            end
            for i = 97, 97 + 25 do
                inputTable[string.format("KEY_%s", string.char(i - 32))] = string.char(i)
            end
            inputTable["KEY_GRAVE"] = "`"
            inputTable["KEY_MINUS"] = "-"
            inputTable["KEY_EQUAL"] = "="
            inputTable["KEY_LEFT_BRACKET"] = "["
            inputTable["KEY_RIGHT_BRACKET"] = "]"
            inputTable["KEY_BACK_SLASH"] = "\\"
            inputTable["KEY_SEMICOLON"] = ";"
            inputTable["KEY_APOSTROPHE"] = "'"
            inputTable["KEY_COMMA"] = ","
            inputTable["KEY_PERIOD"] = "."
            inputTable["KEY_SLASH"] = "/"
        end
        inputTable["KEY_SPACE"] = " "

        if shiftPressed then
            self.inputTableShift = inputTable
        else
            self.inputTable = inputTable
        end
    end
    return inputTable
end

function EditBox:_onInputChanged(done)
    if self.onInputChangedCallback then
        self.onInputChangedCallback(self, self:getInput())
    end
    if done then
        self:unfocus()
    elseif self.autoCompleteFunc then
        self:openPopup(self.autoCompleteFunc(self:getInput()))
    end
end

function EditBox:configLabel(label)
    local contentSize = self:getContentSize()
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(cc.p(2, contentSize.height / 2))
    label:setDimensions(contentSize.width, contentSize.height)
    --    label:setOverflow(2)
    label:enableWrap(false)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
end

function EditBox:onCreatePopupLabel(creator)
    self.popupLabelCreator = creator
end

function EditBox:openPopup(items, prefix, tips, key)
    --    gk.log("openPopup")
    self:closePopup()
    if #items == 0 then
        return
    end
    self.prefix = prefix or ""
    local bg = gk.create_scale9_sprite("gk/res/texture/select_box_popup.png", cc.rect(20, 20, 20, 20))
    local size = self:getContentSize()
    local height = size.height * (#items)
    bg:setContentSize(cc.size(size.width, height))
    bg:setAnchorPoint(cc.p(0, 1))
    self.popup = bg

    -- add to the top layer
    local root = gk.util:getRootNode(self)
    root:addChild(bg, 9999999)
    local p = self:convertToWorldSpace(cc.p(0, 0))
    local p = root:convertToNodeSpace(p)
    bg:setPosition(p)
    bg:setScale(gk.util:getGlobalScale(self))

    self.selectIndex = 1
    if p.y - height * bg:getScaleY() < 0 then
        -- pop upside
        bg:setAnchorPoint(cc.p(0, 0))
        local p = self:convertToWorldSpace(cc.p(0, size.height))
        local p = root:convertToNodeSpace(p)
        bg:setPosition(p)
        local reversedTable = {}
        local count = #items
        for k, v in ipairs(items) do
            reversedTable[count + 1 - k] = v
        end
        items = reversedTable
        -- reverse
        self.selectIndex = #items
    else
        if tips then
            local reversedTable = {}
            local count = #tips
            for k, v in ipairs(tips) do
                reversedTable[count + 1 - k] = v
            end
            tips = reversedTable
        end
    end
    self.items = items

    if self.popupLabelCreator then
        for i = 1, #items do
            local label = self.popupLabelCreator()
            self:configLabel(label)
            label:setString(items[i])
            label:setDimensions(0, 0)
            if key then
                local p1, p2 = string.find(items[i], key)
                local len = items[i]:len()
                if p1 >= 1 and p1 <= len then
                    local size = label:getContentSize()
                    gk.util:drawSolidRectOnNode(label, cc.p((p1 - 1) * size.width / len, size.height), cc.p(p2 * size.width / len, 0), cc.c4f(1, 0, 1, 0.2), -2)
                end
            end
            gk.set_label_color(label, cc.c3b(0, 0, 0))
            local layer = cc.LayerColor:create(cc.c3b(0x99, 0xcc, 0x00), size.width, size.height)
            layer:addChild(label)
            if tips then
                -- tips
                label:setPosition(cc.p(2, size.height * 3 / 4))
                --                label:setAnchorPoint(0, 0)
                local label = self.popupLabelCreator()
                self:configLabel(label)
                label:setPosition(cc.p(2, size.height * 1 / 4))
                label:setString(tips[i])
                gk.set_label_color(label, cc.c3b(0, 150, 150))
                layer:addChild(label)
                label:setOverflow(1)
                --                label:setAnchorPoint(0, 1)
            end

            layer:setIgnoreAnchorPointForPosition(false)
            layer:setOpacity(i == self.selectIndex and 255 or 0)
            local button = gk.Button.new(layer)
            bg:addChild(button)
            button:setPosition(cc.p(size.width / 2, height - size.height / 2 - (i - 1) * size.height))
            button:onClicked(function()
                local str = self.prefix .. items[i]
                self.label:setString(str)
                self:changeCursorPos(str:len())
                self:_onInputChanged(self.prefix ~= "")
            end)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        if self.popup and not gk.util:hitTest(self.popup, touch) then
            self:closePopup()
            return true
        else
            return false
        end
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.popup)

    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocationInView()
        if self.popup and gk.util:touchInNode(self.popup, location) then
            for i, child in ipairs(self.popup:getChildren()) do
                if gk.util:instanceof(child, "Button") then
                    local label = child:getContentNode():getChildren()[1]
                    if gk.util:touchInNode(child, location) then
                        --                        gk.set_label_color(label,cc.c3b(45, 35, 255))
                        child:getContentNode():setOpacity(255)
                        self.selectIndex = i
                    else
                        --                        gk.set_label_color(label,self.selectIndex == i and cc.c3b(255, 255, 255) or cc.c3b(0, 0, 0))
                        child:getContentNode():setOpacity(0)
                    end
                end
            end
        end
    end, cc.Handler.EVENT_MOUSE_MOVE)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.popup)
end

function EditBox:setSelectIndex(index)
    self.selectIndex = cc.clampf(index, 1, #self.popup:getChildren())
    for i, child in ipairs(self.popup:getChildren()) do
        if gk.util:instanceof(child, "Button") then
            local label = child:getContentNode():getChildren()[1]
            if i == self.selectIndex then
                child:getContentNode():setOpacity(255)
            else
                child:getContentNode():setOpacity(0)
            end
        end
    end
end

function EditBox:closePopup()
    if self.popup then
        local root = gk.util:getRootNode(self)
        if not root then
            self.popup = nil
        else
            --            gk.log("closePopup")
            self.popup:removeFromParent()
            self.popup = nil
        end
    end
end

return EditBox

