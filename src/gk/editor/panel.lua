local panel = {}
local generator = import(".generator")

function panel:create(scene)
    self.scene = scene
    -- whole
    local winSize = cc.Director:getInstance():getWinSize()
    local editorPanel = cc.Layer:create()
    self.editorPanel = editorPanel
    -- left
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), gk.display.leftWidth, winSize.height - gk.display.topHeight)
    layerColor:setPosition(0, 0)
    editorPanel:addChild(layerColor)
    self.leftPanel = layerColor
    -- right
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), gk.display.rightWidth, winSize.height - gk.display.topHeight)
    layerColor:setPosition(winSize.width - gk.display.rightWidth, 0)
    editorPanel:addChild(layerColor)
    self.rightPanel = layerColor
    -- top
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width, gk.display.topHeight)
    layerColor:setPosition(0, winSize.height - gk.display.topHeight)
    editorPanel:addChild(layerColor)
    self.topPanel = layerColor
    -- bottom
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width - gk.display.leftWidth - gk.display.rightWidth, gk.display.bottomHeight)
    layerColor:setPosition(gk.display.leftWidth, 0)
    editorPanel:addChild(layerColor)
    layerColor:setPosition(gk.display.leftWidth, 0)
    self.bottomPanel = layerColor

    -- size label
    local label = cc.Label:createWithSystemFont(string.format("winSize(%.0fx%.0f) designSize(%.0fx%.0f) xScale(%.2f) yScale(%.2f) minScale(%.2f)", gk.display.winSize().width, gk.display.winSize().height, gk.display.width(), gk.display.height(), gk.display.xScale(), gk.display.yScale(), gk.display.minScale()),
        "Consolas", 48)
    label:setScale(0.2)
    self.bottomPanel:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setPosition(0, gk.display.bottomHeight / 2)

    self:addTopPanel()
    self:handleEvent()
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
    gk.event:subscribe(self, "displayDomTree", function(node)
        self:displayDomTree(node or self.scene.layer)
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
    --    if node == self.scene.layer then
    self:initLayer(node)
    --    end
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
                return
            end
            if self._containerNode ~= node:getParent() then
                local p = self._containerNode:convertToNodeSpace(node:getParent():convertToWorldSpace(destPos))
                node:retain()
                node:removeFromParent()
                node.__info.x, node.__info.y = math.shrink(p.x, 1), math.shrink(p.y, 1)
                local sx, sy = gk.util.getGlobalScale(self._containerNode)
                if sx ~= 1 or sy ~= 1 then
                    node.__info.scaleX, node.__info.scaleY = 1, 1
                else
                    node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale" --gk.display.minScale() ,gk.display.minScale() --math.shrink(gk.display
                end
                self._containerNode:addChild(node)
                node:release()
            else
                node.__info.x, node.__info.y = math.shrink(destPos.x, 1), math.shrink(destPos.y, 1)
            end
            gk.log("move node to %.2f, %.2f", node.__info.x, node.__info.y)
            gk.event:post("postSync")
            gk.event:post("displayNode", node)
            gk.event:post("displayDomTree")
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
    if self.displayingNode then
        gk.util:clearDrawNode(self.displayingNode)
        self.displayingNode = nil
    end
    if self.displayInfoNode then
        self.displayInfoNode:removeFromParent()
        self.displayInfoNode = nil
    end
    if self.nodePosNode then
        self.nodePosNode:removeFromParent()
        self.nodePosNode = nil
    end
end

function panel:drawNodePos(node)
    if self.nodePosNode then
        self:undisplayNode()
    end
    if node.__info and node.__info.id then
        local parent = node:getParent()
        local x, y = node:getPositionX(), node:getPositionY()
        self.nodePosNode = cc.Node:create()
        parent:addChild(self.nodePosNode, 99999)
        self.nodePosNode:setCascadeOpacityEnabled(true)

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
            self.nodePosNode:addChild(arrow)
            -- label
            local label = cc.Label:createWithSystemFont(tostring(math.floor(width)), "Arial", 50)
            label:setScale(scale)
            label:setColor(cc.c3b(200, 100, 200))
            label:setAnchorPoint(ap.x, ap.y)
            label:setPosition(p)
            self.nodePosNode:addChild(label)
        end
        local size = parent:getContentSize()

        -- left
        createArrow(x, sx, cc.p(3, y + 2), 180, cc.p(0, 0))
        -- down
        createArrow(y, sy, cc.p(x + 5, 3), 90, cc.p(0, 0))
        -- right
        createArrow(size.width - x, sx, cc.p(size.width - 3, y + 2), 0, cc.p(1, 0))
        -- top
        createArrow(size.height - y, sy, cc.p(x + 5, size.height - 3), -90, cc.p(0, 1))
    end
end

function panel:displayNode(panel, node)
    if not node then
        return
    end
    self:undisplayNode()
    self.displayingNode = node
    gk.util:drawNodeRect(node)
    self:drawNodePos(node)

    -- right panel
    if self.displayInfoNode then
        self.displayInfoNode:removeFromParent()
    end
    self.displayInfoNode = cc.Node:create()
    panel:addChild(self.displayInfoNode)
    local size = panel:getContentSize()

    local fontSize = 10 * 4
    local fontName = "gk/res/font/Consolas.ttf"
    local scale = 0.25
    local topY = size.height - 12
    local leftX = 10
    local leftX2 = 70
    local leftX2_1 = 80
    local leftX3 = 135
    local leftX3_1 = 145
    local leftX4_1 = 110 + 2.5
    local leftX4_2 = 120 + 2.5
    local leftX5_1 = 155
    local leftX5_2 = 165
    local stepY = 25
    local stepX = 40
    local inputWidth1 = 110
    local inputWidth2 = 45
    local inputWidth3 = 25
    local createLabel = function(content, x, y)
        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        label:setScale(scale)
        label:setTextColor(cc.c3b(189, 189, 189))
        self.displayInfoNode:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback)
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
        node:setScale9SpriteBg(CREATE_SCALE9_SPRITE("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
        local label = gk.create_label({ string = content, fontFile = fontName, fontSize = fontSize })
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
        self.displayInfoNode:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:onEditEnded(function(...)
            callback(...)
        end)
        node:setPosition(x, y)
        return node
    end

    local createCheckBox = function(selected, x, y, callback)
        local node = ccui.CheckBox:create("gk/res/texture/check_box_normal.png", "gk/res/texture/check_box_selected.png")
        node:setPosition(x, y)
        node:setScale(scale * 2)
        node:setSelected(selected)
        self.displayInfoNode:addChild(node)
        node:setAnchorPoint(0, 0.5)
        node:addEventListener(function(sender, eventType)
            callback(eventType)
        end)
        return node
    end
    local createLine = function(y)
        y = y + 12
        gk.util:drawLineOnNode(self.displayInfoNode, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
    end
    if not node.__info then
        createLabel("Type: " .. node.type, leftX, topY)
        return
    end

    local yIndex = 0
    createLine(topY - stepY * yIndex)
    -- id
    createLabel("Id", leftX, topY)
    createInput(node.__info.id, leftX2_1, topY, inputWidth1, function(editBox, input)
        editBox:setInput(generator.modify(node, "id", input, "string"))
    end)
    yIndex = yIndex + 1
    -- position
    createLabel("Position", leftX, topY - stepY * yIndex)
    createLabel("X", leftX2, topY - stepY * yIndex)
    createInput(tostring(node.__info.x), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(generator.modify(node, "x", input, "number"))
    end)
    createLabel("Y", leftX3, topY - stepY * yIndex)
    createInput(tostring(node.__info.y), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(generator.modify(node, "y", input, "number"))
    end)
    yIndex = yIndex + 1
    -- scale
    createLabel("Scale", leftX, topY - stepY * yIndex)
    createLabel("X", leftX2, topY - stepY * yIndex)
    createInput(tostring(node.__info.scaleX), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(generator.modify(node, "scaleX", input, "number"))
    end)
    createLabel("Y", leftX3, topY - stepY * yIndex)
    createInput(tostring(node.__info.scaleY), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(generator.modify(node, "scaleY", input, "number"))
    end)
    yIndex = yIndex + 1
    if not iskindof(node, "cc.Layer") then
        -- anchor
        createLabel("Anchor", leftX, topY - stepY * yIndex)
        createLabel("X", leftX2, topY - stepY * yIndex)
        createInput(tostring(node.__info.anchorX), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "anchorX", input, "number"))
        end)
        createLabel("Y", leftX3, topY - stepY * yIndex)
        createInput(tostring(node.__info.anchorY), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "anchorY", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    if not iskindof(node, "cc.Label") then
        -- size
        createLabel("Size", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(string.format("%.2f", node:getContentSize().width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(string.format("%.2f", node:getContentSize().height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    -- color
    createLabel("Color", leftX, topY - stepY * yIndex)
    createLabel("R", leftX2, topY - stepY * yIndex)
    createInput(string.format("%d", node.__info.color.r), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator.modify(node, "color.r", input, "number"))
    end)
    createLabel("G", leftX4_1, topY - stepY * yIndex)
    createInput(string.format("%d", node.__info.color.g), leftX4_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator.modify(node, "color.g", input, "number"))
    end)
    createLabel("B", leftX5_1, topY - stepY * yIndex)
    createInput(string.format("%d", node.__info.color.b), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator.modify(node, "color.b", input, "number"))
    end)
    yIndex = yIndex + 1
    -- rotation
    createLabel("Rotation", leftX, topY - stepY * yIndex)
    createInput(tostring(node.__info.rotation), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator.modify(node, "rotation", input, "number"))
    end)
    -- opacity
    createLabel("Opacity", leftX4_2, topY - stepY * yIndex)
    createInput(tostring(node.__info.opacity), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator.modify(node, "opacity", input, "number"))
    end)
    yIndex = yIndex + 1
    if iskindof(node, "cc.Sprite") or node.__info.type == "ZoomButton" then
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        -- file
        createLabel("File", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.file), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator.modify(node, "file", input, "string"))
        end)
        yIndex = yIndex + 1
    end
    if iskindof(node, "cc.Label") then
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        -- string
        createLabel("String", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.string), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator.modify(node, "string", input, "string"))
        end)
        yIndex = yIndex + 1
        -- font file
        createLabel("FontFile", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.fontFile), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator.modify(node, "fontFile", input, "string"))
        end)
        yIndex = yIndex + 1
        -- font size
        createLabel("FontSize", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.fontSize), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator.modify(node, "fontSize", input, "number"))
        end)
        yIndex = yIndex + 1
        -- dimensions
        createLabel("Dimensions", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(string.format("%.2f", node.__info.width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(string.format("%.2f", node.__info.height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- alignment
        createLabel("Alignment", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(string.format("%d", node.__info.hAlign), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "hAlign", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(string.format("%d", node.__info.vAlign), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator.modify(node, "vAlign", input, "number"))
        end)
        yIndex = yIndex + 1
        -- lineHeight
        createLabel("LineHeight", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.lineHeight), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator.modify(node, "lineHeight", input, "number"))
        end)
        -- overflow
        createLabel("Overflow", leftX4_1, topY - stepY * yIndex)
        createInput(tostring(node.__info.overflow), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator.modify(node, "overflow", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    -- visible
    createLabel("Visible", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.visible == 0, leftX2_1, topY - stepY * yIndex, function(selected)
        generator.modify(node, "visible", selected, "number")
    end)
    yIndex = yIndex + 1
end

function panel:handleEvent()
    local function onKeyPressed(keyCode, event)
        if gk.focusNode then
            return
        end
        local key = cc.KeyCodeKey[keyCode + 1]
        --        gk.log("%s:onKeyPressed %s", "EditorPanel", key)
        if self.displayingNode then
            local x, y = self.displayingNode:getPosition()
            if key == "KEY_LEFT_ARROW" then
                x = math.floor(x - 1)
                self.displayingNode.__info.x = x
            elseif key == "KEY_RIGHT_ARROW" then
                x = math.floor(x + 1)
                self.displayingNode.__info.x = x
            elseif key == "KEY_UP_ARROW" then
                y = math.floor(y + 1)
                self.displayingNode.__info.y = y
            elseif key == "KEY_DOWN_ARROW" then
                y = math.floor(y - 1)
                self.displayingNode.__info.y = y
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

function panel:addTopPanel()
    local size = self.topPanel:getContentSize()
    -- winSize
    local fontSize = 10 * 4
    local fontName = "gk/res/font/Consolas.ttf"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local leftX2 = 50
    local leftX2_1 = 80
    local leftX3 = 135
    local leftX3_1 = 145
    local leftX4_1 = 110 + 2.5
    local leftX4_2 = 120 + 2.5
    local leftX5_1 = 155
    local leftX5_2 = 165
    local stepY = 25
    local stepX = 40
    local inputWidth1 = 80
    local createLabel = function(content, x, y)
        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        label:setScale(scale)
        label:setTextColor(cc.c3b(189, 189, 189))
        self.topPanel:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback)
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
        node:setScale9SpriteBg(CREATE_SCALE9_SPRITE("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
        local label = gk.create_label({ string = content, fontFile = fontName, fontSize = fontSize })
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
        self.topPanel:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:onEditEnded(function(...)
            callback(...)
        end)
        node:setPosition(x, y)
        node.enabled = false
        return node
    end
    local createCheckBox = function(selected, x, y, callback)
        local node = ccui.CheckBox:create("gk/res/texture/check_box_normal.png", "gk/res/texture/check_box_selected.png")
        node:setPosition(x, y)
        node:setScale(scale * 2)
        node:setSelected(selected)
        self.displayInfoNode:addChild(node)
        node:setAnchorPoint(0, 0.5)
        node:addEventListener(function(sender, eventType)
            callback(eventType)
        end)
        return node
    end

    local yIndex = 0
    -- id
    createLabel("Size", leftX, topY)
    local items = gk.display.deviceSizesDesc
    local sizeItems = gk.display.deviceSizes
    local index = cc.UserDefault:getInstance():getIntegerForKey("deviceSizeIndex")
    local node = gk.SelectBox:create(cc.size(inputWidth1 / scale, 16 / scale), items, index)
    node:setScale9SpriteBg(CREATE_SCALE9_SPRITE("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
    local label = gk.create_label({ string = "", fontFile = fontName, fontSize = fontSize })
    label:setTextColor(cc.c3b(0, 0, 0))
    node:setDisplayLabel(label)
    node:onCreatePopupLabel(function()
        local label = gk.create_label({ string = "", fontFile = fontName, fontSize = fontSize })
        label:setTextColor(cc.c3b(0, 0, 0))
        return label
    end)
    local contentSize = node:getContentSize()
    --    node:didCreatePopupLabel(function(label)
    --        local pos = cc.p(label:getPosition())
    --        pos.x = pos.x - 5
    --        pos.y = pos.y - 5
    --        label:setPosition(pos)
    --        --        label:setDimensions(contentSize.width - 25, contentSize.height)
    --    end)
    label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
    label:setDimensions(contentSize.width - 25, contentSize.height)
    self.topPanel:addChild(node)
    node:setScale(scale)
    node:setAnchorPoint(0, 0.5)
    node:setPosition(leftX2, topY)
    node:onSelectChanged(function(index)
        local size = sizeItems[index]
        cc.UserDefault:getInstance():setIntegerForKey("deviceSizeIndex", index)
        cc.UserDefault:getInstance():flush()
        -- set editor win size
        size.width = size.width + gk.display.leftWidth + gk.display.rightWidth
        size.height = size.height + gk.display.topHeight + gk.display.bottomHeight
        local director = cc.Director:getInstance()
        local view = director:getOpenGLView()
        view:setFrameSize(size.width, size.height)
        gk.util:restartGame()
    end)

    -- widgets
    self.widgets = {
        { type = "cc.Layer", },
        { type = "cc.Sprite", file = "?", },
        { type = "ZoomButton", file = "?", },
        { type = "cc.Label", },
    }
    local winSize = cc.Director:getInstance():getWinSize()
    for i = 1, #self.widgets do
        local node = CREATE_SPRITE(self.widgets[i].file)
        node.type = self.widgets[i].type
        node:setScale(0.35)
        local originPos = cc.p(gk.display.leftWidth + node:getScale() * node:getContentSize().width / 2 + 50 * (i - 1), size.height / 2)
        node:setPosition(originPos)
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
                node:setScale(gk.display.minScale())
                self.topPanel:addChild(node)
                self.draggingNode = node
            end
            self.draggingNode:setPosition(cc.pAdd(originPos, cc.pSub(p, self.topPanel:convertToNodeSpace(self._touchBegainLocation))))

            -- find dest container
            if self.sortedChildren == nil then
                self:sortChildrenOfSceneGraphPriority(self.scene.layer, true)
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
                        gk.log("find container node %s, id = %s", type, node.__info.id)
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
                    local info = clone(self.widgets[i])
                    local node = generator.createNode(info, nil, self.scene.layer)
                    if node then
                        node.__info.x, node.__info.y = math.shrink(p.x, 1), math.shrink(p.y, 1)
                        if tolua.type(node) ~= "cc.Layer" then
                            local sx, sy = gk.util.getGlobalScale(self._containerNode)
                            if sx ~= 1 or sy ~= 1 then
                                node.__info.scaleX, node.__info.scaleY = 1, 1
                            else
                                node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale" --gk.display.minScale() ,gk.display.minScale() --math.shrink(gk.display
                            end
                        else
                            --                            gk.util:drawNodeRect(node, cc.c4f(1, 200 / 255, 0, 1), -2)
                        end
                        self._containerNode:addChild(node)
                        gk.log("put node %s, id = %s, pos = %.1f,%.1f", type, node.__info.id, p.x, p.y)
                        gk.event:post("postSync")
                        gk.event:post("displayNode", node)
                        gk.event:post("displayDomTree")
                    else
                        gk.log("cannot create node %s", type)
                    end
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
    local file = gk.config.genPath .. "_" .. self.scene.layer.__cname:lower() .. ".lua"
    gk.log("sync to file: " .. file)
    --    gk.log(table2lua.encode_pretty(info))
    io.writefile(file, table2lua.encode_pretty(info))
end

function panel:initLayer(layer)
    if tolua.type(layer) == "cc.Layer" and layer.__cname == "MainLayer" then
        local file = gk.config.genRelativePath .. "_" .. layer.__cname:lower()
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

function panel:displayDomTree(rootLayer)
    if rootLayer then
        -- left panel
        if self.displayDomInfoNode then
            self.displayDomInfoNode:removeFromParent()
        end
        self.displayDomInfoNode = cc.Node:create()
        self.leftPanel:addChild(self.displayDomInfoNode)
        self.domDepth = 0
        panel:displayDomNode(rootLayer, 0)
        local size = self.leftPanel:getContentSize()
        local createLine = function(y)
            gk.util:drawLineOnNode(self.displayDomInfoNode, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
        end
        createLine(size.height)
    end
end

function panel:displayDomNode(node, layer)
    local size = self.leftPanel:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local stepY = 20
    local stepX = 40
    local createButton = function(content, x, y)
        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(cc.c3b(200, 200, 200))
        if not gk.util:isGlobalVisible(node) then
            label:setOpacity(100)
        end
        local button = gk.ZoomButton.new(label)
        button:setScale(scale)
        self.displayDomInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x, y)
        button:onClicked(function()
            gk.event:post("displayNode", node)
            gk.event:post("displayDomTree")
        end)
        -- select
        if self.displayingNode == node then
            gk.util:drawNodeRect(button, nil)
        end
        return button
    end
    local whiteSpace = ""
    for i = 1, layer do
        whiteSpace = whiteSpace .. " "
    end
    createButton(whiteSpace .. node.__info.id, leftX, topY - stepY * self.domDepth)
    self.domDepth = self.domDepth + 1
    layer = layer + 1
    local children = node:getChildren()
    if children then
        for i = 1, #children do
            local child = children[i]
            if child and child.__info and child.__info.id then
                panel:displayDomNode(child, layer)
            end
        end
    end
end

return panel