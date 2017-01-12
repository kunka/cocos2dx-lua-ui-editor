--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/6/2
-- Time: 下午2:50
-- To change this template use File | Settings | File Templates.
--

--- 所有的Scene都是基于Layer,可单独作为scene也可以单独作为layer使用
--- 默认响应Android back键自动popScene,有Dialog先pop Dialog
--- swallowTouchEvent:默认Touch事件不会传递到下一层
--- 子类必须调用父类的ctor,onEnter,onExit等
local Layer = class("Layer", function()
    return cc.Layer:create()
end)

-- 作为Scene使用
function Layer:createScene(sceneType, ...)
    --    local scene = require("gk.node.Scene"):create(sceneType)
    local scene = cc.Scene:create()
    local layer = require(sceneType):create(...)
    scene:addChild(layer)
    scene.layer = layer
    return scene
end

function Layer:ctor()
    gk.log("Layer(%s:ctor)", self.__cname)
    -- 默认禁止事件穿透到下层
    self.swallowTouchEvent = true
    -- 默认监听keyPad事件,Android的back键,MAC的ESC键
    self.enableKeyPad = true
    -- 默认按back键时自动popScene
    self.popOnBack = true
    self:enableNodeEvents()
    -- dialog堆栈
    self.dialogsStack = {}
    gk.event:post("onNodeCreate", self)
end

function Layer:showDialog(dialogType, ...)
    gk.log("%s:showDialog --> %s", self.__cname, dialogType)
    local Dialog = require(dialogType)
    local dialog = Dialog:create(...)
    self:addChild(dialog, 999999)
    dialog.parent = self
    table.insert(self.dialogsStack, dialog)
    return dialog
end

function Layer:showDialogNode(dialogNode)
    gk.log("%s:showDialogNode", self.__cname)
    self:addChild(dialogNode, 999999)
    dialogNode.parent = self
    table.insert(self.dialogsStack, dialogNode)
    return dialogNode
end

function Layer:onTouchBegan(touch, event)
    return self.swallowTouchEvent
end

function Layer:onTouchMoved(touch, event)
end

function Layer:onTouchEnded(touch, event)
end

function Layer:onTouchCancelled(touch, event)
end

function Layer:onEnter()
    gk.log("%s:onEnter", self.__cname)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(handler(self, self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    if self.enableKeyPad then
        local function onKeyReleased(keyCode, event)
            if gk.focusNode then
                return
            end
            if not (event and event:isStopped()) then
                local key = cc.KeyCodeKey[keyCode + 1]
                gk.log("%s:onKeypad %s", self.__cname, key)
                if key == "KEY_ESCAPE" then
                    if #self.dialogsStack > 0 then
                        for i = #self.dialogsStack, 1, -1 do
                            local d = self.dialogsStack[i]
                            d:onKeyBack()
                            -- 不能back的dialog,阻塞整个UI
                            if event then
                                event:stopPropagation()
                            end
                            return
                        end
                    end
                    self:onKeyBack()
                    if event then
                        event:stopPropagation()
                    end
                end
            end
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
    end
end

function Layer:onExit()
    gk.log("%s:onExit", self.__cname)
end

-- override func for subclasses to process back pressed
function Layer:onKeyBack()
    if self.popOnBack then
        gk.log("%s:pop onKeyBack", self.__cname)
        gk.SceneManager:pop()
    else
        gk.log("%s:pop onKeyBack is disabled", self.__cname)
    end
end

return Layer