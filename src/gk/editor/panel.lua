local panel = {}
local generator = import(".generator")

local kMoveNodeAction = -1102
function panel.create(scene)
    local self = cc.Layer:create()
    setmetatableindex(self, panel)
    self.scene = scene
    local leftPanelModule = require("gk.editor.leftPanel")
    local rightPanelModule = require("gk.editor.rightPanel")
    local topPanelModule = require("gk.editor.topPanel")
    local bottomPanelModule = require("gk.editor.bottomPanel")
    -- whole
    local winSize = cc.Director:getInstance():getWinSize()
    -- left
    self.leftPanel = leftPanelModule.create(self)
    self:addChild(self.leftPanel)
    -- right
    self.rightPanel = rightPanelModule.create(self)
    self:addChild(self.rightPanel)
    -- top
    self.topPanel = topPanelModule.create(self)
    self:addChild(self.topPanel)
    -- bottom
    self.bottomPanel = bottomPanelModule.create(self)
    self:addChild(self.bottomPanel)

    self:handleEvent()
    self:subscribeEvent()

    return self
end

function panel:subscribeEvent()
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
    gk.event:subscribe(self, "changeRootLayout", function(clazz)
        gk.log("changeRootLayout --> %s", clazz)
        local path = gk.resource.genNodes[clazz]
        if path then
            gk.event:unsubscribeAll(self)
            --            gk.SceneManager:replace(layer)
            --            local clazz = require(layer)
            --            print(layer)
            --            local node = clazz:create()
            --            local scene = gk.SceneManager:getRunningScene()
            --            if scene.layer then
            --                scene.layer:removeFromParent()
            --            end
            --            scene:addChild(node)
            --            scene.layer = node
            local clazz = require(path)
            local isLayer = iskindof(clazz, "Layer")
            if isLayer then
                gk.SceneManager:replace(path)
            else
                gk.log("changeRootLayout ??")
                local scene = gk.Layer:createScene()
                local node = clazz:create()
                scene:addChild(node)
                scene.layer = node
                gk.SceneManager:replaceScene(scene)
            end
        end
    end)
    gk.event:subscribe(self, "postSync", function(node)
        gk.util:stopActionByTagSafe(self, -234)
        local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            local inject = require("gk.core.inject")
            inject:sync(node or self.scene.layer)
        end)))
        action:setTag(-234)
    end)
    gk.event:subscribe(self, "syncNow", function(node)
        local inject = require("gk.core.inject")
        inject:sync(node or self.scene.layer)
    end)
end

function panel:onNodeCreate(node)
    node:onNodeEvent("enter", function()
        if not node.__info or not node.__info.id then
            return
        end
        local c = node:getParent()
        while c ~= nil do
            if iskindof(c, "cc.TableView") then
                return
            end
            c = c:getParent()
        end
        if gk.mode == gk.MODE_EDIT and node == self.scene.layer then
            gk.util:drawNode(node, cc.c4f(1, 200 / 255, 0, 1), -2)
        end
        gk.log("onNodeCreate %s", node.__info.id)
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            if node ~= self.scene.layer and gk.util:isGlobalVisible(node) and gk.util:hitTest(node, touch) then
                local location = touch:getLocation()
                local p = node:getParent():convertToNodeSpace(location)
                self._touchBegainPos = cc.p(p)
                self._originPos = cc.p(node:getPosition())
                local type = node.__cname and node.__cname or tolua.type(node)
                gk.log("click node %s, id = %s", type, node.__info.id)
                self._containerNode = node:getParent()
                --                if self._containerNode and not self._containerNode.__info then
                --                    gk.event:post("displayNode", node)
                --                    return false
                --                end
                cc.Director:getInstance():setDepthTest(true)
                node:setPositionZ(0.00000001)
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
            --            local scaleX = generator:parseValue("scaleX", node, node.__info.scaleXY.x)
            --            local scaleY = generator:parseValue("scaleY", node, node.__info.scaleXY.y)
            --            node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
            --            gk.event:post("displayNode", node)
            local delta = self:onNodeMoved(node)
            p = cc.pAdd(p, delta)

            -- find dest container
            if self.sortedChildren == nil then
                self:sortChildrenOfSceneGraphPriority(self.scene.layer, true)
            end
            local children = self.sortedChildren
            for i = #children, 1, -1 do
                local nd = children[i]
                if gk.util:isGlobalVisible(nd) and nd.__info and nd.__info.lock == 0 and nd.__info.id and nd ~= node then
                    local s = iskindof(nd, "cc.ScrollView") and nd:getViewSize() or nd:getContentSize()
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
            cc.Director:getInstance():setDepthTest(false)
            node:setPositionZ(0)
            if p.x == self._touchBegainPos.x and p.y == self._touchBegainPos.y then
                gk.event:post("displayDomTree")
                return
            end
            local destPos = cc.pAdd(self._originPos, cc.pSub(p, self._touchBegainPos))
            node:setPosition(destPos)
            local delta = self:onNodeMoved(node)
            destPos = cc.pAdd(destPos, delta)

            local type = tolua.type(self._containerNode)
            if self._containerNode and self._containerNode ~= node:getParent() and
                    (not (type == "cc.ScrollView" and self._containerNode:getContainer() == node:getParent())) then
                local p = self._containerNode:convertToNodeSpace(node:getParent():convertToWorldSpace(destPos))
                node:retain()
                node:removeFromParent()
                self:rescaleNode(node, self._containerNode)
                local scaleX = generator:parseValue("scaleX", node, node.__info.scaleXY.x)
                local scaleY = generator:parseValue("scaleY", node, node.__info.scaleXY.y)
                node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
                self._containerNode:addChild(node)
                node:release()
                gk.log("change node's container %s", node.__info.id)
            else
                local scaleX = generator:parseValue("scaleX", node, node.__info.scaleXY.x)
                local scaleY = generator:parseValue("scaleY", node, node.__info.scaleXY.y)
                node.__info.x, node.__info.y = math.round(destPos.x / scaleX), math.round(destPos.y / scaleY)
                gk.log("move node to %.2f, %.2f", node.__info.x, node.__info.y)
                local delta = self:onNodeMoved(node)
                --                p = cc.pAdd(p, delta)
            end
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

function panel:rescaleNode(node, parent)
    if node:isIgnoreAnchorPointForPosition() then
        -- Layer, ScrollView ...
        node.__info.scaleX, node.__info.scaleY = 1, 1
    else
        -- normal node
        local sx, sy = gk.util:getGlobalScale(parent)
        if sx ~= 1 or sy ~= 1 then
            node.__info.scaleX, node.__info.scaleY = 1, 1
        else
            node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale"
            node.__info.scaleXY = { x = "$xScale", y = "$yScale" }
        end
    end
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
        if not parent then
            return
        end
        local x, y = node:getPositionX(), node:getPositionY()
        self.coordinateNode = cc.Node:create()
        self.coordinateNode:setTag(-99)
        parent:addChild(self.coordinateNode, 99999)
        self.coordinateNode:setCascadeOpacityEnabled(true)

        local sx, sy = gk.util:getGlobalScale(parent)
        if sx ~= 0 and sy ~= 0 then
            sx = 0.2 / sx
            sy = 0.2 / sy
        end

        local createArrow = function(width, dis, scale, p, rotation, ap)
            if width < 0 then
                return
            end
            local arrow = gk.create_scale9_sprite("gk/res/texture/arrow.png", cc.rect(0, 13, 40, 5))
            arrow:setContentSize(cc.size(width / scale, 57))
            arrow:setScale(scale)
            arrow:setPosition(x, y)
            arrow:setRotation(rotation)
            arrow:setAnchorPoint(cc.p(0, 0.5))
            arrow:setOpacity(128)
            self.coordinateNode:addChild(arrow)
            -- label
            local label = cc.Label:createWithSystemFont(tostring(math.round(dis)), "Arial", 50)
            label:setScale(scale)
            label:setColor(cc.c3b(200, 100, 200))
            label:setAnchorPoint(ap.x, ap.y)
            label:setPosition(p)
            self.coordinateNode:addChild(label)
        end
        local size = parent:getContentSize()

        -- left
        local scaleX = generator:parseValue("x", node, node.__info.scaleXY.x)
        local scaleY = generator:parseValue("y", node, node.__info.scaleXY.y)
        createArrow(x, x / scaleX, sx, cc.p(3, y + 2), 180, cc.p(0, 0))
        -- down
        createArrow(y, y / scaleY, sy, cc.p(x + 5, 3), 90, cc.p(0, 0))
        -- right
        createArrow((size.width - x), (size.width - x) / scaleX, sx, cc.p(size.width - 3, y + 2), 0, cc.p(1, 0))
        -- top
        createArrow((size.height - y), (size.height - y) / scaleY, sy, cc.p(x + 5, size.height - 3), -90, cc.p(0, 1))
    end
end

function panel:displayNode(node)
    if not node then
        return
    end
    self:undisplayNode()
    self.displayingNode = node
    if node ~= self.scene.layer then
        gk.util:drawNode(node)
    end
    self:drawNodeCoordinate(node)

    self.rightPanel:displayNode(node)
end

function panel:handleEvent()
    local function onKeyPressed(keyCode, event)
        if gk.focusNode then
            return
        end
        local key = cc.KeyCodeKey[keyCode + 1]
        if key == "KEY_SHIFT" then
            self.shiftPressed = true
            return
        end
        if key == "KEY_HYPER" then
            self.commandPressed = true
            return
        end

        --        gk.log("%s:onKeyPressed %s", "EditorPanel", key)
        if self.displayingNode and self.displayingNode.__info then
            -- copy node
            if self.commandPressed then
                if key == "KEY_C" then
                    gk.log("copy node %s", self.displayingNode.__info.id)
                    self.copyingNode = self.displayingNode
                    return
                elseif key == "KEY_V" and self.copyingNode then
                    --                    local info = clone(self.copyingNode.__info)
                    local info = clone(generator:deflate(self.copyingNode))
                    local node = generator:inflate(info, nil, self.scene.layer)
                    if node then
                        node.__info.x, node.__info.y = node.__info.x + 20, node.__info.y + 20
                        self.copyingNode:getParent():addChild(node)
                        gk.log("paste node %s", node.__info.id)
                        gk.event:post("postSync")
                        gk.event:post("displayNode", node)
                        gk.event:post("displayDomTree")
                    end
                    return
                end
            end

            -- TODO: hold
            self.moveActions = self.moveActions or {
                KEY_LEFT_ARROW = function(info, step)
                    info.x = info.x - step
                end,
                KEY_RIGHT_ARROW = function(info, step)
                    info.x = info.x + step
                end,
                KEY_UP_ARROW = function(info, step)
                    info.y = info.y + step
                end,
                KEY_DOWN_ARROW = function(info, step)
                    info.y = info.y - step
                end,
            }
            local move = self.moveActions[key]
            if move then
                move(self.displayingNode.__info, 1)
                local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
                    local action = self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
                        move(self.displayingNode.__info, 5)
                        gk.event:post("displayNode", self.displayingNode)
                    end))))
                    action:setTag(kMoveNodeAction)
                end)))
                action:setTag(kMoveNodeAction)
                self:onNodeMoved(self.displayingNode, 0)
            end
            gk.event:post("displayNode", self.displayingNode)
        end
        self.copyingNode = nil

        if key == "KEY_S" then
            -- save
            gk.event:post("postSync")
        elseif key == "KEY_BACKSPACE" then
            -- delete node
            if self.shiftPressed and self.displayingNode and self.displayingNode.__info.id then
                gk.log("delete node %s", self.displayingNode.__info.id)
                self:removeNodeIndex(self.displayingNode, self.scene.layer)
                self.displayingNode:removeFromParent()
                self.displayingNode = nil
                gk.event:post("postSync")
                gk.event:post("displayDomTree")
                self:undisplayNode()
            end
        end
    end

    local function onKeyReleased(keyCode, event)
        if gk.focusNode then
            return
        end
        local key = cc.KeyCodeKey[keyCode + 1]
        if key == "KEY_SHIFT" then
            self.shiftPressed = false
            return
        end
        if key == "KEY_HYPER" then
            self.commandPressed = false
            return
        end
        if self.moveActions and self.moveActions[key] then
            gk.util:stopActionByTagSafe(self, kMoveNodeAction)
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    -- TODO: mouse move event
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
    --    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function panel:removeNodeIndex(node, rootTable)
    if node.__info and node.__info.id and rootTable[node.__info.id] == node then
        rootTable[node.__info.id] = nil
    end
    local children = node:getChildren()
    if children then
        for i = 1, #children do
            local child = children[i]
            if child then
                self:removeNodeIndex(child, rootTable)
            end
        end
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
                self:sortChildrenOfSceneGraphPriority(child, false)
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
                self:sortChildrenOfSceneGraphPriority(child, false)
            end
        end
    else
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
    end
end

-- smart align node
function panel:onNodeMoved(node, threshold)
    local all = {}
    local function allInfoNodes(nd)
        if nd and nd.__info and nd ~= node then
            table.insert(all, nd)
            local children = nd:getChildren()
            for i = 1, #children do
                allInfoNodes(children[i])
            end
        end
    end

    threshold = threshold or 2
    allInfoNodes(self.scene.layer)
    local tag = -3
    gk.util:clearDrawNode(self.scene.layer, tag)
    local findX, findY, findLeftX, findRightX, findTopY, findBottomY
    local delta = cc.p(0, 0)
    local p1 = self.scene.layer:convertToNodeSpace(node:getParent():convertToWorldSpace(cc.p(node:getPosition())))
    local sx, sy = gk.util:getGlobalScale(node)
    local size = node:getContentSize()
    local drawLine = function(p1, p2)
        gk.util:drawLineOnNode(self.scene.layer, p1, p2, cc.c4f(255 / 255, 102 / 255, 102 / 255, 1), tag):setPositionZ(0.00000001)
        gk.util:drawDotOnNode(self.scene.layer, p1, cc.c4f(0 / 255, 255 / 255, 102 / 255, 1), tag)
        gk.util:drawDotOnNode(self.scene.layer, p2, cc.c4f(0 / 255, 255 / 255, 102 / 255, 1), tag)
    end
    local updatePosX = function(dtX)
        if not findX and not findLeftX and not findRightX then
            delta.x = dtX
            p1.x = p1.x + dtX
            node:setPosition(node:getParent():convertToNodeSpace(self.scene.layer:convertToWorldSpace(p1)))
        end
    end
    local updatePosY = function(dtY)
        if not findY and not findTopY and not findBottomY then
            delta.y = dtY
            p1.y = p1.y + dtY
            node:setPosition(node:getParent():convertToNodeSpace(self.scene.layer:convertToWorldSpace(p1)))
        end
    end
    for _, other in pairs(all) do
        local p2 = self.scene.layer:convertToNodeSpace(other:getParent():convertToWorldSpace(cc.p(other:getPosition())))
        -- x
        if (not findX and math.abs(p1.x - p2.x) <= threshold) or (findX and math.equal(p2.x, findX, 1)) then
            updatePosX(p2.x - p1.x)
            drawLine(cc.p(p2.x, p1.y), p2)
            findX = p2.x
        end
        -- y
        if (not findY and math.abs(p1.y - p2.y) <= threshold) or (findY and math.equal(findY, p2.y, 1)) then
            updatePosY(p2.y - p1.y)
            drawLine(cc.p(p1.x, p2.y), p2)
            findY = p2.y
        end
        -- left x
        local sx2, sy2 = gk.util:getGlobalScale(other)
        local size2 = other:getContentSize()
        local p1_ = cc.p(p1.x - size.width / 2 * sx, p1.y)
        local p2_ = cc.p(p2.x - size2.width / 2 * sx2, p2.y)
        if (not findX and not findLeftX and math.abs(p1_.x - p2_.x) <= threshold) or math.equal(p1_.x, p2_.x, 4) then
            updatePosX(p2_.x - p1_.x)
            drawLine(cc.p(p2_.x, p1_.y), p2_)
            findLeftX = p2_.x
        end
        -- right x
        local p1_ = cc.p(p1.x + size.width / 2 * sx, p1.y)
        local p2_ = cc.p(p2.x + size2.width / 2 * sx2, p2.y)
        if (not findX and not findRightX and math.abs(p1_.x - p2_.x) <= threshold) or math.equal(p1_.x, p2_.x, 1) then
            updatePosX(p2_.x - p1_.x)
            drawLine(cc.p(p2_.x, p1_.y), p2_)
            findRightX = p2_.x
        end
        -- top y
        local p1_ = cc.p(p1.x, p1.y + size.height / 2 * sy)
        local p2_ = cc.p(p2.x, p2.y + size2.height / 2 * sy2)
        if (not findY and not findTopY and math.abs(p1_.y - p2_.y) <= threshold) or math.equal(p1_.y, p2_.y, 1) then
            updatePosY(p2_.y - p1_.y)
            drawLine(cc.p(p1_.x, p2_.y), p2_)
            findTopY = p2_.y
        end
        -- bottom y
        local p1_ = cc.p(p1.x, p1.y - size.height / 2 * sy)
        local p2_ = cc.p(p2.x, p2.y - size2.height / 2 * sy2)
        if (not findY and not findBottomY and math.abs(p1_.y - p2_.y) <= threshold) or math.equal(p1_.y, p2_.y, 1) then
            updatePosY(p2_.y - p1_.y)
            drawLine(cc.p(p1_.x, p2_.y), p2_)
            findBottomY = p2_.y
        end
    end

    return delta
end

return panel