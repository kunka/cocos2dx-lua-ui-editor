local panel = {}
local generator = import(".generator")

function panel:create(scene)
    self.scene = scene
    -- whole
    local winSize = cc.Director:getInstance():getWinSize()
    local editorPanel = cc.Layer:create()
    self.editorPanel = editorPanel
    -- right
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width / 4, winSize.height * 3 / 4)
    layerColor:setPosition(winSize.width * 3 / 4, 0)
    editorPanel:addChild(layerColor)
    self.rightPanel = layerColor
    -- top
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width, winSize.height / 4)
    layerColor:setPosition(0, winSize.height * 3 / 4)
    self.topPanel = layerColor
    editorPanel:addChild(layerColor)

    self:addTopPanel()
    self:handleKeyboardEvent()
    self:subscribeEvent()

    return editorPanel
end

function panel:subscribeEvent(node)
    gk.event:subscribe(self, "onNodeCreate", function(node)
        self:onNodeCreate(node)
    end)
    gk.event:subscribe(self, "displayNode", function(node)
        self:displayNode(self.rightPanel, node)
    end)
end

function panel:onNodeCreate(node)
    node:onNodeEvent("enter", function()
        if node == self.scene.layer then
            node.__id = node.__cname
            return
        end
        if not node.__id then
            return
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local s = node:getContentSize()
            local rect = { x = 0, y = 0, width = s.width, height = s.height }
            local p = node:convertToNodeSpace(location)
            if cc.rectContainsPoint(rect, p) then
                local p = node:getParent():convertToNodeSpace(location)
                self._touchBegainPos = cc.p(p)
                self._originPos = cc.p(node:getPosition())
                local type = node.__cname and node.__cname or tolua.type(node)
                gk.log("click node %s, id = %s", type, node.__id)
                gk.event:post("displayNode", node)
                return true
            else
                return false
            end
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local p = node:getParent():convertToNodeSpace(location)
            node:setPosition(cc.pAdd(self._originPos, cc.pSub(p, self._touchBegainPos)))
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local p = node:getParent():convertToNodeSpace(location)
            gk.log("move node to %f, %f", p.x, p.y)
            node:setPosition(cc.pAdd(self._originPos, cc.pSub(p, self._touchBegainPos)))
        end, cc.Handler.EVENT_TOUCH_ENDED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end)
end

function panel:undisplayNode()
    if self.displayingNode then
        gk.util:clearDrawNode(self.displayingNode)
        self.displayingNode = nil
    end
end

function panel:displayNode(panel, node)
    self:undisplayNode()
    self.displayingNode = node
    gk.util:drawNodeRect(node)

    -- right panel
    if self.displayInfoNode then
        self.displayInfoNode:removeFromParent()
    end
    self.displayInfoNode = cc.Node:create()
    panel:addChild(self.displayInfoNode)
    local size = panel:getContentSize()

    local fontSize = 15
    local fontName = "Consolas"
    -- id
    local title = cc.Label:createWithSystemFont(string.format("id: %s", node.__id), fontName, fontSize)
    self.displayInfoNode:addChild(title)
    title:setAnchorPoint(0, 0.5)
    title:setPosition(10, size.height - 20)

    -- sprite file
    local protos = require("demo.gen.sprite")
    local id2sprite = require("gk.core.id2sprite")
    local proto = id2sprite.id2proto(node.__id)
    local title = cc.Label:createWithSystemFont(string.format("file: %s", proto.file), fontName, fontSize)
    self.displayInfoNode:addChild(title)
    title:setAnchorPoint(0, 0.5)
    title:setPosition(10, size.height - 20 - 20)

    --    local node = ccui.EditBox:create(cc.size(150, 20), CREATE_SCALE9_SPRITE("edbox_bg_2.png", cc.rect(20, 8, 10, 5)))
    --    self.displayInfoNode:addChild(node)
    --    node:setAnchorPoint(0, 0.5)
    --    node:setFontColor(cc.c3b(255, 149, 15))
    --    node:setPlaceholderFontColor(cc.c3b(255, 149, 15))
    --    node:setPlaceholderFontSize(fontSize)
    --    node:setFontSize(fontSize)
    --    node:setPlaceholderFontName(fontName)
    --    node:setFontName(fontName)
    --    node:setPosition(10, size.height - 20 - 40)
    --    node:registerScriptEditBoxHandler(function(eventType)
    --        gk.log("eventType %s", eventType)
    --    end)
    --    node:setPlaceHolder("???????")
end

function panel:handleKeyboardEvent()
    local function onKeyReleased(keyCode, event)
        gk.log("%s:onKeypad %d", "EditorPanel", keyCode)
        if self.displayingNode then
            local x, y = self.displayingNode:getPosition()
            if table.indexof(cc.KeyCodeKey, "KEY_LEFT_ARROW") - 1 == keyCode then
                x = x - 1
            elseif table.indexof(cc.KeyCodeKey, "KEY_RIGHT_ARROW") - 1 == keyCode then
                x = x + 1
            elseif table.indexof(cc.KeyCodeKey, "KEY_UP_ARROW") - 1 == keyCode then
                y = y + 1
            elseif table.indexof(cc.KeyCodeKey, "KEY_DOWN_ARROW") - 1 == keyCode then
                y = y - 1
            elseif table.indexof(cc.KeyCodeKey, "KEY_S") - 1 == keyCode then
                -- save
                self:sync()
            end
            self.displayingNode:setPosition(cc.p(x, y))
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.editorPanel)
end

function panel:addTopPanel()
    local size = self.topPanel:getContentSize()
    self.widgets = { { file = "?", type = "Layer", index = 1 }, { file = "?", type = "ZoomButton", index = 1 }, { file = "?", type = "Sprite", index = 1 } }
    for i = 1, #self.widgets do
        local node = CREATE_SPRITE(self.widgets[i].file)
        local originPos = cc.p(50 + 80 * (i - 1), size.height / 2)
        node:setPosition(originPos)
        node:setScale(0.3)
        self.topPanel:addChild(node)

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            self._touchBegainLocation = cc.p(location)
            local s = node:getContentSize()
            local rect = { x = 0, y = 0, width = s.width, height = s.height }
            local p = node:convertToNodeSpace(location)
            if cc.rectContainsPoint(rect, p) then
                local type = self.widgets[i].type
                gk.log("choose node %s", type)
                self:undisplayNode()
                gk.event:post("displayNode", node)
                return true
            else
                return false
            end
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local p = self.topPanel:convertToNodeSpace(location)
            if not self.draggingNode then
                local node = CREATE_SPRITE(self.widgets[i].file)
                node:setPosition(originPos)
                node:setScale(0.3)
                self.topPanel:addChild(node)
                self.draggingNode = node
            end
            self.draggingNode:setPosition(cc.pAdd(originPos, cc.pSub(p, self.topPanel:convertToNodeSpace(self._touchBegainLocation))))

            -- find dest container
            if self.sortedChildren == nil then
                self:sortEventListenersOfSceneGraphPriority(self.scene.layer, true)
            end
            local children = self.sortedChildren
            for i = #children, 1, -1 do
                local node = children[i]
                local s = node:getContentSize()
                local rect = { x = 0, y = 0, width = s.width, height = s.height }
                local p = node:convertToNodeSpace(location)
                if cc.rectContainsPoint(rect, p) then
                    local type = node.__cname and node.__cname or tolua.type(node)
                    if self._containerNode ~= node then
                        self._containerNode = node
                        gk.log("find container node %s, id = %s", type, node.__id)
                    end
                    gk.event:post("displayNode", node)
                    break
                end
            end
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)
            if self._containerNode then
                local s = self.scene.layer:getContentSize()
                local rect = { x = 0, y = 0, width = s.width, height = s.height }
                --            local p = self.scene.layer:convertTouchToNodeSpace(touch)
                local location = touch:getLocation()
                local p = self.topPanel:convertToNodeSpace(location)
                local p = cc.pAdd(originPos, cc.pSub(p, self.topPanel:convertToNodeSpace(self._touchBegainLocation)))
                p = self._containerNode:convertToNodeSpace(self.topPanel:convertToWorldSpace(p))
                --            local p = self.scene.layer:convertToNodeSpace(cc.pSub(location, self._touchBegainLocation))
                if cc.rectContainsPoint(rect, p) then
                    local type = self.widgets[i].type
                    gk.log("put node %s", type)
                    local node = gk.create_sprite(string.format("%s%d", self.widgets[i].type, self.widgets[i].index))
                    self.widgets[i].index = self.widgets[i].index + 1
                    node:setPosition(p)
                    local sx, sy = gk.util.getGolbalScale(self._containerNode)
                    if sx == 1 and sy == 1 then
                        node:setScale(0.3)
                    else
                        node:setScale(0.3 / sx, 0.3 / sy)
                    end
                    self._containerNode:addChild(node)
                else
                    gk.log("cancel put node")
                end
            else
                gk.log("cancel put node")
            end
            if self.draggingNode then
                self.draggingNode:removeFromParent()
                self.draggingNode = nil
            end
            self.sortedChildren = nil
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function(touch, event)
            if self.draggingNode then
                self.draggingNode:removeFromParent()
                self.draggingNode = nil
            end
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end
end

function panel:sortEventListenersOfSceneGraphPriority(node, isRootNode)
    if isRootNode then
        self.sortedChildren = {}
    end
    node:sortAllChildren()
    local children = node:getChildren()
    local childrenCount = #children
    if childrenCount > 0 then
        for i = 1, childrenCount do
            local child = children[i]
            if child and child:getLocalZOrder() < 0 then
                panel:sortEventListenersOfSceneGraphPriority(child, false)
            else
                break
            end
        end
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
        for i = 1, childrenCount do
            local child = children[i]
            if child then
                panel:sortEventListenersOfSceneGraphPriority(child, false)
            end
        end
    else
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
    end
end

function panel:sync()
    gk.log("sync")
    local info = generator.serialize(self.scene.layer)
    local ret = json.encode(info)
    if type(ret) == "string" then
        local file = gk.config.genPath .. self.scene.layer.__cname .. ".json"
        gk.log(file)
        gk.log(ret)
        io.writefile(file, ret)
    end
end

return panel