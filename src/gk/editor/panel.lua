local panel = {}
local generator = import(".generator")
panel.leftPanel = import(".leftPanel")
panel.rightPanel = import(".rightPanel")
panel.topPanel = import(".topPanel")
panel.bottomPanel = import(".bottomPanel")

function panel:create(scene)
    self.scene = scene
    -- whole
    local winSize = cc.Director:getInstance():getWinSize()
    local editorPanel = cc.Layer:create()
    self.editorPanel = editorPanel
    -- left
    editorPanel:addChild(self.leftPanel:create(self))
    -- right
    editorPanel:addChild(self.rightPanel:create(self))
    -- top
    editorPanel:addChild(self.topPanel:create(self))
    -- bottom
    editorPanel:addChild(self.bottomPanel:create(self))

    self:handleEvent()
    self:subscribeEvent()

    return editorPanel
end

function panel:subscribeEvent(node)
    gk.event:subscribe(self, "onNodeCreate", function(node)
        self:onNodeCreate(node)
    end)
    gk.event:subscribe(self, "undisplayNode", function(node)
        self:undisplayNode()
    end)
    gk.event:subscribe(self, "displayNode", function(node)
        self:displayNode(node)
    end)
    gk.event:subscribe(self, "displayDomTree", function(node)
        self.leftPanel:displayDomTree(node or self.scene.layer)
    end)
    gk.event:subscribe(self, "postSync", function(node)
        gk.util:stopActionByTagSafe(self.editorPanel, -234)
        local action = cc.CallFunc:create(function()
            self:sync()
        end)
        action:setTag(-234)
        self.editorPanel:runAction(action)
    end)
end

function panel:onNodeCreate(node)
    self:initLayer(node)
    node:onNodeEvent("enter", function()
        if not node.__info or not node.__info.id then
            return
        end
        gk.log("onNodeCreate %s", node.__info.id)
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            if gk.util:hitTest(node, touch) then
                local location = touch:getLocation()
                local p = node:getParent():convertToNodeSpace(location)
                self._touchBegainPos = cc.p(p)
                self._originPos = cc.p(node:getPosition())
                local type = node.__cname and node.__cname or tolua.type(node)
                gk.log("click node %s, id = %s", type, node.__info.id)
                self._containerNode = node:getParent()
                cc.Director:getInstance():setDepthTest(true)
                node:setPositionZ(1)
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

            -- find dest container
            if self.sortedChildren == nil then
                self:sortChildrenOfSceneGraphPriority(self.scene.layer, true)
            end
            local children = self.sortedChildren
            for i = #children, 1, -1 do
                local nd = children[i]
                if nd.__info and nd.__info.id and nd ~= node then
                    local s = nd:getContentSize()
                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    local p = nd:convertToNodeSpace(location)
                    if cc.rectContainsPoint(rect, p) then
                        local type = nd.__cname and nd.__cname or tolua.type(nd)
                        if self._containerNode ~= nd then
                            self._containerNode = nd
                            gk.log("find container node %s, id = %s", type, nd.__info.id)
                            gk.event:post("displayNode", nd)
                            gk.event:post("displayDomTree")
                        end
                        break
                    end
                end
            end
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local p = node:getParent():convertToNodeSpace(location)
            local destPos = cc.pAdd(self._originPos, cc.pSub(p, self._touchBegainPos))
            cc.Director:getInstance():setDepthTest(false)
            node:setPositionZ(0)
            if p.x == self._touchBegainPos.x and p.y == self._touchBegainPos.y then
                gk.event:post("displayDomTree")
                return
            end
            if self._containerNode ~= node:getParent() then
                local p = self._containerNode:convertToNodeSpace(node:getParent():convertToWorldSpace(destPos))
                node:retain()
                node:removeFromParent()
                local sx, sy = gk.util.getGlobalScale(self._containerNode)
                if sx ~= 1 or sy ~= 1 then
                    node.__info.scaleX, node.__info.scaleY = 1, 1
                    node.__info.scaleXY = { x = "1", y = "1" }
                else
                    node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale"
                    node.__info.scaleXY = { x = "$xScale", y = "$yScale" }
                end
                local scaleX = generator.parseValue(node.__info.scaleXY.x)
                local scaleY = generator.parseValue(node.__info.scaleXY.y)
                node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
                self._containerNode:addChild(node)
                node:release()
            else
                local scaleX = generator.parseValue(node.__info.scaleXY.x)
                local scaleY = generator.parseValue(node.__info.scaleXY.y)
                node.__info.x, node.__info.y = math.round(destPos.x / scaleX), math.round(destPos.y / scaleY)
            end
            gk.log("move node to %.2f, %.2f", node.__info.x, node.__info.y)
            gk.event:post("postSync")
            gk.event:post("displayNode", node)
            gk.event:post("displayDomTree")
            self.sortedChildren = nil
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function(touch, event)
            cc.Director:getInstance():setDepthTest(false)
            node:setPositionZ(0)
            node:setPosition(self._originPos)
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end)
end

function panel:undisplayNode()
    self.rightPanel:undisplayNode()

    if self.displayingNode then
        gk.util:clearDrawNode(self.displayingNode)
        self.displayingNode = nil
    end
    if self.coordinateNode then
        self.coordinateNode:removeFromParent()
        self.coordinateNode = nil
    end
end

function panel:drawNodeCoordinate(node)
    if node.__info and node.__info.id then
        local parent = node:getParent()
        local x, y = node:getPositionX(), node:getPositionY()
        self.coordinateNode = cc.Node:create()
        parent:addChild(self.coordinateNode, 99999)
        self.coordinateNode:setCascadeOpacityEnabled(true)

        local sx, sy = gk.util.getGlobalScale(parent)
        sx = 0.2 / sx
        sy = 0.2 / sy

        local createArrow = function(width, scale, p, rotation, ap)
            local arrow = CREATE_SCALE9_SPRITE("gk/res/texture/arrow.png", cc.rect(0, 13, 40, 5))
            arrow:setContentSize(cc.size(width / scale, 57))
            arrow:setScale(scale)
            arrow:setPosition(x, y)
            arrow:setRotation(rotation)
            arrow:setAnchorPoint(cc.p(0, 0.5))
            arrow:setOpacity(128)
            self.coordinateNode:addChild(arrow)
            -- label
            local label = cc.Label:createWithSystemFont(tostring(math.round(width)), "Arial", 50)
            label:setScale(scale)
            label:setColor(cc.c3b(200, 100, 200))
            label:setAnchorPoint(ap.x, ap.y)
            label:setPosition(p)
            self.coordinateNode:addChild(label)
        end
        local size = parent:getContentSize()

        local scaleX = generator.parseValue(node.__info.scaleXY.x)
        local scaleY = generator.parseValue(node.__info.scaleXY.y)
        -- left
        createArrow(x / scaleX, sx, cc.p(3, y + 2), 180, cc.p(0, 0))
        -- down
        createArrow(y / scaleY, sy, cc.p(x + 5, 3), 90, cc.p(0, 0))
        -- right
        createArrow((size.width - x) / scaleX, sx, cc.p(size.width - 3, y + 2), 0, cc.p(1, 0))
        -- top
        createArrow((size.height - y) / scaleY, sy, cc.p(x + 5, size.height - 3), -90, cc.p(0, 1))
    end
end

function panel:displayNode(node)
    if not node then
        return
    end
    self:undisplayNode()
    self.displayingNode = node
    gk.util:drawNodeRect(node)
    self:drawNodeCoordinate(node)

    self.rightPanel:displayNode(node)
end

function panel:handleEvent()
    local function onKeyPressed(keyCode, event)
        if gk.focusNode then
            return
        end
        local key = cc.KeyCodeKey[keyCode + 1]
        --        gk.log("%s:onKeyPressed %s", "EditorPanel", key)
        if self.displayingNode then
            local x, y = self.displayingNode.__info.x, self.displayingNode.__info.y
            if key == "KEY_LEFT_ARROW" then
                self.displayingNode.__info.x = x - 1
            elseif key == "KEY_RIGHT_ARROW" then
                self.displayingNode.__info.x = x + 1
            elseif key == "KEY_UP_ARROW" then
                self.displayingNode.__info.y = y + 1
            elseif key == "KEY_DOWN_ARROW" then
                self.displayingNode.__info.y = y - 1
            end
            gk.event:post("displayNode", self.displayingNode)
        end

        if key == "KEY_S" then
            -- save
            gk.event:post("postSync")
        elseif key == "KEY_BACKSPACE" then
            -- delete node
            gk.log("delete")
            if self.displayingNode and self.displayingNode.__info.id then
                local parent = self.displayingNode:getParent()
                if parent and parent[self.displayingNode.__info.id] == self.displayingNode then
                    parent[self.displayingNode.__info.id] = nil
                end
                self.displayingNode:removeFromParent()
                self.displayingNode = nil
                gk.event:post("postSync")
                gk.event:post("displayDomTree")
                self:undisplayNode()
            end
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.editorPanel)

    local listener = cc.EventListenerMouse:create()
    --    listener:registerScriptHandler(function(touch, event)
    --    end, cc.Handler.EVENT_MOUSE_DOWN)
    --    listener:registerScriptHandler(function(touch, event)
    --    end, cc.Handler.EVENT_MOUSE_UP)
    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocationInView()
        location.y = cc.Director:getInstance():getWinSize().height + location.y
        -- find node
        if self.sortedChildren == nil then
            self:sortChildrenOfSceneGraphPriority(self.scene.layer, true)
        end
        local children = self.sortedChildren
        for i = #children, 1, -1 do
            local node = children[i]
            if node then
                local s = node:getContentSize()
                local rect = { x = 0, y = 0, width = s.width, height = s.height }
                local p = node:convertToNodeSpace(location)
                if cc.rectContainsPoint(rect, p) then
                    local type = node.__cname and node.__cname or tolua.type(node)
                    if self._mouseHoverNode ~= node then
                        self._mouseHoverNode = node
                        --                    gk.event:post("displayNode", node)
                        --                    gk.event:post("displayDomTree")
                    end
                    break
                end
            end
        end
    end, cc.Handler.EVENT_MOUSE_MOVE)
    --    listener:registerScriptHandler(function(touch, event)
    --    end, cc.Handler.EVENT_MOUSE_SCROLL)
    --    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.editorPanel)
end

function panel:sortChildrenOfSceneGraphPriority(node, isRootNode)
    if isRootNode then
        self.sortedChildren = {}
    end
    node:sortAllChildren()
    local children = node:getChildren()
    local childrenCount = #children
    if childrenCount > 0 then
        for i = 1, childrenCount do
            local child = children[i]
            if child and child:getLocalZOrder() < 0 and child.__info then
                panel:sortChildrenOfSceneGraphPriority(child, false)
            else
                break
            end
        end
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
        for i = 1, childrenCount do
            local child = children[i]
            if child and child.__info then
                panel:sortChildrenOfSceneGraphPriority(child, false)
            end
        end
    else
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
    end
end

function panel:sync()
    local info = generator.deflate(self.scene.layer)
    local table2lua = require("gk.tools.table2lua")
    local file = gk.config.genPath .. "layout/_" .. self.scene.layer.__cname:lower() .. ".lua"
    gk.log("sync to file: " .. file)
    --    gk.log(table2lua.encode_pretty(info))
    io.writefile(file, table2lua.encode_pretty(info))
end

function panel:initLayer(layer)
    if tolua.type(layer) == "cc.Layer" and layer.__cname == "MainLayer" then
        local file = gk.config.genPath .. "layout/_" .. layer.__cname:lower()
        local status, info = pcall(require, file)
        layer.__info = generator.wrap({ id = layer.__cname }, layer)
        if status then
            gk.log("initLayer with %s", file)
            --            layer.__info.id = "root"
            generator.inflate(info, layer, layer)
            layer.__info.width = gk.display.winSize().width
            layer.__info.height = gk.display.winSize().height
            --            dump(info)
        end
        local winSize = cc.Director:getInstance():getWinSize()
        layer:setPosition(gk.display.leftWidth, gk.display.bottomHeight)
        gk.util:drawNodeRect(layer, cc.c4f(1, 200 / 255, 0, 1), -2)
        gk.event:post("displayDomTree", layer)
    end
end

return panel