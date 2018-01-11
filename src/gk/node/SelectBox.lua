--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 上午11:34
-- To change this template use File | Settings | File Templates.
--

--- [Editor use only]
local SelectBox = class("SelectBox", function()
    return cc.Node:create()
end)

function SelectBox:ctor(size, items, index)
    --    assert(((not items) or (#items == 0)), "SelectBox's items == nil or size == 0 !")
    self:enableNodeEvents()
    self:setContentSize(size)
    self.selectItems = items
    self.selectIndex = index or 0
    self.selectIndex = cc.clampf(self.selectIndex, 0, #items)
    self.enabled = true
    self.marginLeft = 5
    self.marginRight = 0
    self.marginTop = 0
    self.marginBottom = 0
    self.focusable = false
    --    self:handleKeyboardEvent()
end

function SelectBox:onEnter()
    gk.util:addMouseMoveEffect(self)
end

function SelectBox:onSelectChanged(callback)
    self.onSelectChangedCallback = callback
end

function SelectBox:setItems(items)
    self.selectItems = clone(items)
    self.selectIndex = cc.clampf(self.selectIndex, 0, #items)
    self.label:setString(self.selectItems[self.selectIndex])
end

function SelectBox:setItemColors(itemColors)
    self.itemColors = itemColors
end

function SelectBox:setSelectIndex(index)
    if index ~= self.selectIndex and index > 0 and index <= #self.selectItems then
        self.label:setString(self.selectItems[index])
        if self.onSelectChangedCallback then
            self.onSelectChangedCallback(index)
        end
    end
end

function SelectBox:setScale9SpriteBg(scale9Sprite)
    local contentSize = self:getContentSize()
    scale9Sprite:setContentSize(contentSize)
    self.bg = scale9Sprite
    local button = gk.Button.new(scale9Sprite)
    self:addChild(button, -1)
    button:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
    button:onClicked(function()
        if self.enabled then
            self:openPopup()
            --            self:focus()
        end
    end)
    self.bgButton = button
end

function SelectBox:setMarginLeft(marginLeft)
    self.marginLeft = marginLeft
end

function SelectBox:setMarginRight(marginRight)
    self.marginRight = marginRight
end

function SelectBox:setMarginTop(marginTop)
    self.marginTop = marginTop
end

function SelectBox:setMarginBottom(marginBottom)
    self.marginBottom = marginBottom
end

function SelectBox:setDisplayLabel(label)
    assert(label:getParent() == nil, "SelectBox's display label cannot be added again!")
    self.label = label
    if self.selectIndex > 0 then
        self.label:setString(self.selectItems[self.selectIndex])
    end
    self:addChild(label)
    self:configLabel(label)
end

function SelectBox:configLabel(label)
    local contentSize = self:getContentSize()
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(cc.p(self.marginLeft, (contentSize.height - self.marginTop - self.marginBottom) / 2 + self.marginBottom))
    label:setDimensions(contentSize.width - self.marginLeft - self.marginRight, contentSize.height)
    --    label:setOverflow(2)
    label:enableWrap(false)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
end

function SelectBox:onCreatePopupLabel(creator)
    self.popupLabelCreator = creator
end

function SelectBox:openPopup()
    --    gk.log("openPopup")
    self:closePopup()
    local bg = gk.create_scale9_sprite("gk/res/texture/select_box_popup.png", cc.rect(20, 20, 20, 20))
    local size = self:getContentSize()
    local height = size.height * (#self.selectItems)
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

    if p.y - height * bg:getScaleY() < 0 then
        -- pop upside
        bg:setAnchorPoint(cc.p(0, 0))
        local p = self:convertToWorldSpace(cc.p(0, size.height))
        local p = root:convertToNodeSpace(p)
        bg:setPosition(p)
    end

    if self.popupLabelCreator then
        for i = 1, #self.selectItems do
            local label = self.popupLabelCreator()
            self:configLabel(label)
            label:setString(self.selectItems[i])
            gk.set_label_color(label, i == self.selectIndex and cc.c3b(255, 0, 0) or cc.c3b(0, 0, 0))
            local layer = cc.LayerColor:create(cc.c3b(0x99, 0xcc, 0x00), size.width, size.height)
            if self.itemColors then
                local dot = cc.LayerColor:create(cc.c3b(0, 0, 0), size.height, size.height)
                layer:addChild(dot)
                dot:setPositionX(-size.height)
                local dot = cc.LayerColor:create(self.itemColors[i], size.height - 2, size.height - 2)
                layer:addChild(dot)
                dot:setPositionX(-size.height)
            end
            layer:addChild(label)
            layer:setIgnoreAnchorPointForPosition(false)
            layer:setOpacity(i == self.selectIndex and 255 or 0)
            local button = gk.Button.new(layer)
            bg:addChild(button)
            button:setPosition(cc.p(size.width / 2, height - size.height / 2 - (i - 1) * size.height))
            button:onClicked(function()
                if self.popup then
                    self:closePopup()
                    --                self:unfocus()
                    if self.selectIndex ~= i and i > 0 and i <= #self.selectItems then
                        self.selectIndex = i
                        self.label:setString(self.selectItems[i])
                        gk.set_label_color(label, i == self.selectIndex and cc.c3b(255, 0, 0) or cc.c3b(0, 0, 0))
                        if self.onSelectChangedCallback then
                            self.onSelectChangedCallback(i)
                        end
                    end
                end
            end)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        if self.popup and not gk.util:hitTest(self.popup, touch) then
            self:closePopup()
            --            self:unfocus()
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

function SelectBox:closePopup()
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

function SelectBox:handleKeyboardEvent()
    local function onKeyPressed(keyCode, event)
        if gk.focusNode == self then
            local key = cc.KeyCodeKey[keyCode + 1]
            gk.log("[SelectBox]: onKeyPressed %s", key)
            if key == "KEY_ESCAPE" then
                self:unfocus()
            elseif key == "KEY_ENTER" then
                self:unfocus()
                self.label:setString(self.selectItems[self.selectIndex])
                if self.onSelectChangedCallback then
                    self.onSelectChangedCallback(self.selectIndex)
                end
            elseif key == "KEY_TAB" then
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
            end
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function SelectBox:focus()
    if gk.focusNode ~= self then
        if gk.focusNode then
            gk.focusNode:unfocus()
        end
        gk.focusNode = self
        self.isFocus = true
        gk.util:drawNodeBounds(self, cc.c4f(1, 0, 0, 1), -2)
        gk.log("[SelectBox] focus")
        self:openPopup()
    end
end

function SelectBox:unfocus()
    if gk.focusNode == self then
        gk.focusNode = nil
        self.isFocus = false
        gk.util:clearDrawNode(self, -2)
        self:closePopup()
        gk.log("[SelectBox] unfocus")
    end
end


function SelectBox:onExit()
    if gk.focusNode == self then
        gk.focusNode = nil
        self.isFocus = false
        gk.log("[SelectBox] unfocus")
    end
end

return SelectBox