--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/6/2
-- Time: 下午2:50
-- To change this template use File | Settings | File Templates.
--

--- Use as Layer or Scene
--- As Scene: default popDialog when click Android back(keyboard ESC), otherwise popScene
local Layer = class("Layer", function()
    return cc.Layer:create()
end)

function Layer:ctor()
    gk.log("[%s]: ctor", self.__cname)
    self.swallowTouches = true
    self.touchEnabled = true
    self.enableKeyPad = false
    self.popOnBack = false -- popScene on back
    self:enableNodeEvents()
    self.dialogsStack = {}
end

function Layer:showDialog(dialogType, ...)
    gk.log("[%s]: showDialog --> [%s]", self.__cname, dialogType)
    local Dialog, _ = gk.resource:require(dialogType)
    local dialog = Dialog:create(...)
    self:addChild(dialog, 999999)
    dialog.parent = self
    table.insert(self.dialogsStack, dialog)
    return dialog
end

function Layer:showDialogNode(dialogNode)
    gk.log("[%s]: showDialogNode", self.__cname)
    self:addChild(dialogNode, 999999)
    dialogNode.parent = self
    table.insert(self.dialogsStack, dialogNode)
    return dialogNode
end


function Layer:isTouchEnabled()
    return self.touchEnabled
end

function Layer:setTouchEnabled(enabled)
    self.touchEnabled = enabled
    if self.touchListener then
        self.touchListener:setEnabled(enabled)
    end
end

function Layer:isSwallowTouches()
    return self.swallowTouches
end

function Layer:setSwallowTouches(swallow)
    self.swallowTouches = swallow
    if self.touchListener then
        self.touchListener:setSwallowTouches(swallow)
    end
end

function Layer:isEnableKeyPad()
    return self.enableKeyPad
end

function Layer:setEnableKeyPad(enabled)
    self.enableKeyPad = enabled
end

function Layer:isPopOnBack()
    return self.popOnBack
end

function Layer:setPopOnBack(enabled)
    self.popOnBack = enabled
end

function Layer:onTouchBegan(touch, event)
    return self.swallowTouches
end

function Layer:onTouchMoved(touch, event)
end

function Layer:onTouchEnded(touch, event)
end

function Layer:onTouchCancelled(touch, event)
end

function Layer:onEnter()
    gk.log("[%s]: onEnter", self.__cname)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(self.swallowTouches)
    listener:setEnabled(self.touchEnabled)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
    self.touchListener = listener

    if self.enableKeyPad and not self.keyBoardListener then
        -- should only add once
        local function onKeyReleased(keyCode, event)
            if gk.focusNode then
                return
            end
            local key = cc.KeyCodeKey[keyCode + 1]
            if key == "KEY_ESCAPE" then
                gk.log("[%s]: onKeypad %s", self.__cname, key)
                self:handleKeyBack(self)
            end
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
        self.keyBoardListener = listener
    end
end

function Layer:onExit()
    gk.log("[%s]: onExit", self.__cname)
end

function Layer:handleKeyBack(node)
    gk.log("[%s]: handleKeyBack", node.__cname)
    if #node.dialogsStack > 0 then
        for i = #node.dialogsStack, 1, -1 do
            local d = node.dialogsStack[i]
            d:handleKeyBack(d)
            -- dialog on the top which cannot pop on back will block the whole ui
            return
        end
    end
    node:onKeyBack()
end

-- override func for subclasses to process back pressed
function Layer:onKeyBack()
    if self.popOnBack then
        gk.log("[%s]: pop onKeyBack", self.__cname)
        local scene = gk.SceneManager:getRunningScene()
        if scene and scene.layer == self then
            gk.SceneManager:pop()
        end
    else
        gk.log("[%s]: pop onKeyBack is disabled", self.__cname)
    end
end

return Layer