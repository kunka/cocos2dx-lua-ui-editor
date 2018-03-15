local panel = {}
local cmd = import(".cmd")

local kMoveNodeAction = -1102
function panel.create(scene)
    local winSize = cc.Director:getInstance():getWinSize()
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

    -- win frame
    local bg = gk.create_scale9_sprite("gk/res/texture/frame.png", cc.rect(30, 30, 290, 130))
    local p = cc.p(15, 17)
    bg:setContentSize(cc.size(gk.display:accuWinSize().width + p.x * 2 + gk.display.extWidth, gk.display:accuWinSize().height + p.y * 2))
    bg:setAnchorPoint(cc.p(0, 0))
    bg:setPosition(cc.p(gk.display.leftWidth - p.x, gk.display.bottomHeight - p.y))
    self:addChild(bg)
    -- contentSize frame
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), gk.display:accuWinSize().width, gk.display:accuWinSize().height)
    bg:addChild(layer)
    layer:setAnchorPoint(cc.p(0.5, 0.5))
    layer:setIgnoreAnchorPointForPosition(false)
    layer:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
    --    gk.util:drawNodeBounds(layer, cc.c4f(0, 1, 1, 0.2), -99)
    gk.util:drawNodeBounds(layer, cc.c4f(0, 0, 0, 1), -99)
    if gk.display.extWidth > 0 then
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), gk.display:accuWinSize().width + gk.display.extWidth, gk.display:accuWinSize().height)
        bg:addChild(layer)
        layer:setAnchorPoint(cc.p(0.5, 0.5))
        layer:setIgnoreAnchorPointForPosition(false)
        layer:setPosition(bg:getContentSize().width / 2, bg:getContentSize().height / 2)
        gk.util:drawNodeBounds(layer, cc.c4f(0, 1, 1, 0.2), -99)
    end
    -- iPhoneX safe area frame
    if gk.display:iPhoneX() then
        local xScale = gk.display:accuWinSize().width / 2436
        local x1 = gk.display.leftWidth + 132 * xScale
        local x2 = gk.display.leftWidth + (2436 - 132) * xScale
        local y1 = gk.display.bottomHeight
        local y2 = gk.display.bottomHeight + gk.display:accuWinSize().height
        gk.util:drawSegmentOnNode(self, cc.p(x1, y1), cc.p(x1, y2), 5, cc.c4f(0, 1, 1, 0.15), -991)
        gk.util:drawSegmentOnNode(self, cc.p(x2, y1), cc.p(x2, y2), 5, cc.c4f(0, 1, 1, 0.15), -991)

        local overlay = gk.create_sprite("gk/res/texture/ipx.png")
        layer:addChild(overlay, -1)
        overlay:setColor(cc.c3b(26, 26, 26))
        overlay:setScale(layer:getContentSize().width / overlay:getContentSize().width)
        overlay:setPosition(layer:getContentSize().width / 2, layer:getContentSize().height / 2)
    end

    if gk.mode == gk.MODE_EDIT then
        self:handleEvent()
        bg:setOpacity(0)
        local breathAction = gk.BreathAction:create(cc.FadeTo:create(6, 255))
        breathAction:start(bg)
        bg:enableNodeEvents()
        bg.onExitCallback_ = function()
            breathAction:stop()
        end
        self:subscribeEvent()
    end
    if gk.mode == gk.MODE_RELEASE_CURRENT then
        self:enableNodeEvents()
        self.onExitCallback_ = function()
            gk.event:unsubscribeAll(self)
        end
        self.onEnterCallback_ = function()
            self:subscribeEvent()
            gk.event:post("displayDomTree")
        end
    end
    return self
end

function panel:subscribeEvent()
    -- cmds
    if gk.mode == gk.MODE_EDIT then
        self.cmd = cmd:create(200)
        gk.event:subscribe(self, "executeCmd", function(name, params)
            self.cmd:execute(name, self.scene.layer, params)
        end)
        gk.event:subscribe(self, "undoCmd", function()
            self.cmd:undo()
        end)
        gk.event:subscribe(self, "onNodeCreate", function(node)
            self:onNodeCreate(node)
        end)
        gk.event:subscribe(self, "undisplayNode", function(node)
            self:undisplayNode()
        end)
        gk.event:subscribe(self, "displayNode", function(node, var)
            -- do not display tablecell in tableView
            local type = tolua.type(node)
            if type ~= "cc.TableView" then
                if gk.util:isAncestorsType(node, "cc.TableView") then
                    return
                end
            end
            local layer = self.scene.layer
            if layer then
                gk.util:stopActionByTagSafe(layer, -2342)
                local action = layer:runAction(cc.CallFunc:create(function()
                    self:displayNode(node, var)
                end))
                action:setTag(-2342)
            end
        end)
        gk.event:subscribe(self, "changeRootLayout", function(key)
            gk.log("changeRootLayout --> %s", key)
            local path = gk.resource:getGenNode(key).path
            if path then
                gk.event:unsubscribeAll(self)
                gk.SceneManager:replace(path)
            end
        end)
        gk.event:subscribe(self, "postSync", function(node)
            gk.util:stopActionByTagSafe(self, -234)
            local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
                local injector = require("gk.core.injector")
                injector:sync(node or self.scene.layer)
            end)))
            action:setTag(-234)
        end)
        gk.event:subscribe(self, "syncNow", function(node)
            local injector = require("gk.core.injector")
            injector:sync(node or (self.scene and self.scene.layer))
        end)
    end

    gk.event:subscribe(self, "displayDomTree", function(...)
        local node = self.scene.layer
        if node then
            local param = { ... }
            gk.util:stopActionByTagSafe(node, -2341)
            local action = node:runAction(cc.CallFunc:create(function()
                self.leftPanel:displayDomTree(node or self.scene.layer, unpack(param))
            end))
            action:setTag(-2341)
        end
    end)
end

function panel:onNodeCreate(node)
    if not node then
        gk.log("warning! onNodeCreate = nil")
        return
    end
    self.multiSelectNodes = self.multiSelectNodes or {}
    --    gk.log("onNodeCreate onCreate %s %s", node, node.__info)

    local onEnterCallback = function()
        if gk.errorOccurs then
            return
        end
        if not node.__info or not node.__info._id then
            return
        end
        -- cannot select and move tableView cell which is auto gen
        local c = node:getParent()
        while c ~= nil do
            if gk.util:instanceof(c, "cc.TableView") then
                return
            end
            c = c:getParent()
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            self.draggingNode = nil
            self._containerNode = nil
            self.draggingControlPoint = nil
            self.draggingControlPointIndex = nil
            if not self.commandPressed then
                for _, nd in ipairs(self.multiSelectNodes) do
                    gk.util:clearDrawNode(nd)
                end
                self.multiSelectNodes = {}
                --                gk.event:post("undisplayNode")
            end
            -- dragging control points
            if self.displayingNode and gk.util:instanceof(self.displayingNode, "DrawNode") and type(self.displayingNode.getMovablePoints) == "function" then
                local touchP = self.displayingNode:convertTouchToNodeSpace(touch)
                local ps = self.displayingNode:getMovablePoints()
                for i, p in ipairs(ps) do
                    if cc.pDistanceSQ(p, touchP) < 100 then
                        self.draggingControlPoint = cc.p(p)
                        self.draggingControlPointIndex = i
                        self._touchBegainPos = cc.p(touchP)
                        gk.util:drawNode(self.displayingNode)
                        return true
                    end
                end
            end

            local hit = false
            -- child of locked widget
            if node.__info._isWidget then
                hit = node.__info and node ~= self.scene.layer and gk.util:isAncestorsVisible(node) and gk.util:hitTest(node, touch)
            else
                hit = node.__info and node.__info._lock == 1 and node ~= self.scene.layer and gk.util:isAncestorsVisible(node) and gk.util:hitTest(node, touch)
                if hit then
                    local c = node:getParent()
                    while c ~= nil do
                        if node.__rootTable == c and c.__info and c.__info._isWidget then
                            if c.__info._lock == 0 then
                                return false
                            end
                            break
                        end
                        c = c:getParent()
                    end
                end
            end
            if hit then
                local location = touch:getLocation()
                local p = node:getParent():convertToNodeSpace(location)
                self._touchBegainPos = cc.p(p)
                self._originPos = cc.p(node:getPosition())
                local type = node.__cname and node.__cname or tolua.type(node)
                self._containerNode = node:getParent()
                cc.Director:getInstance():setDepthTest(true)
                node:setPositionZ(1)
                if self.commandPressed then
                    if self.displayingNode and not table.indexof(self.multiSelectNodes, self.displayingNode) then
                        table.insert(self.multiSelectNodes, self.displayingNode)
                    end
                    local index = table.indexof(self.multiSelectNodes, node)
                    if index then
                        -- unselect
                        gk.util:clearDrawNode(node)
                        table.remove(self.multiSelectNodes, index)
                    else
                        table.insert(self.multiSelectNodes, node)
                        gk.log("multi select node %s, id = %s, count = %d", type, node.__info._id, #self.multiSelectNodes)
                        gk.util:drawNode(node)
                    end
                    if not self.displayingNode then
                        gk.event:post("displayNode", node)
                    end
                else
                    for _, nd in ipairs(self.multiSelectNodes) do
                        gk.util:clearDrawNode(nd)
                    end
                    self.multiSelectNodes = {}
                    --                    gk.log("click node %s, id = %s", type, node.__info._id)
                    gk.event:post("displayNode", node)
                end
                gk.util:clearDrawNode(self.scene.layer, -3)
                self:onNodeMoved(node, nil, 0)

                return true
            else
                if not self.commandPressed and not gk.util:hitTest(self.scene.layer, touch) then
                    self:undisplayNode(true)
                    gk.util:clearDrawNode(self.scene.layer, -3)
                end
                --                gk.log("click none %s", node.__info._id)
                return false
            end
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)
            if self.draggingControlPoint then
                local touchP = self.displayingNode:convertTouchToNodeSpace(touch)
                local ps = self.displayingNode:getMovablePoints()
                local dt = cc.pSub(touchP, self._touchBegainPos)
                local p = cc.pAdd(self.draggingControlPoint, dt)
                self.displayingNode:setMovablePoints(p, self.draggingControlPointIndex)
                gk.util:drawNode(self.displayingNode)
                return
            end
            if self.commandPressed or gk.util:isAncestorsIgnore(node) then
                return
            end
            if node.__info and (node.__info._lock == 0 and not node.__info._isWidget) then
                return
            end
            if node.__rootTable and node.__rootTable.__info and node.__rootTable.__info._isWidget then
                return
            end
            self.draggingNode = node
            local p = node:getParent():convertTouchToNodeSpace(touch)
            p = cc.pAdd(self._originPos, cc.pSub(p, self._touchBegainPos))
            p = self:onNodeMoved(node, p)

            -- find dest container
            if self.sortedChildren == nil then
                self:sortChildrenOfSceneGraphPriority(self.scene.layer)
            end
            local children = self.sortedChildren
            for i = #children, 1, -1 do
                local nd = children[i]
                local canBeContainer = false
                repeat
                    if nd.__rootTable ~= self.scene.layer then
                        -- widget
                        break
                    end
                    if not node or nd == node or not gk.util:isAncestorsVisible(nd) then
                        break
                    end
                    if gk.util:isAncestorOf(node, nd) then
                        break
                    end
                    if nd.__info then
                        if nd.__info._lock == 0 then --or nd.__info._isWidget then
                        break
                        end
                    end
                    if gk.util:isAncestorsType(nd, "cc.TableView") then
                        break
                    end
                    canBeContainer = true
                until true
                if canBeContainer then
                    -- move out of parent
                    --                    local parent = node:getParent()
                    --                    local s = iskindof(parent, "cc.ScrollView") and parent:getViewSize() or parent:getContentSize()
                    --                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    --                    local p = parent:convertToNodeSpace(location)
                    --                    if cc.rectContainsPoint(rect, p) then
                    --                        return
                    --                    end
                    local s = gk.util:instanceof(nd, "cc.ScrollView") and nd:getViewSize() or nd:getContentSize()
                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    local p = nd:convertTouchToNodeSpace(touch)
                    if cc.rectContainsPoint(rect, p) then
                        local type = nd.__cname and nd.__cname or tolua.type(nd)
                        if self._containerNode ~= nd then
                            self._containerNode = nd
                            gk.log("find container node %s, id = %s", type, nd.__info._id)
                            gk.event:post("displayNode", nd, true)
                            gk.event:post("displayDomTree")
                        end
                        break
                    end
                end
            end
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)
            if self.draggingControlPoint then
                local touchP = self.displayingNode:convertTouchToNodeSpace(touch)
                local ps = self.displayingNode:getMovablePoints()
                local dt = cc.pSub(touchP, self._touchBegainPos)
                local p = cc.pAdd(self.draggingControlPoint, dt)
                self.displayingNode:setMovablePoints(p, self.draggingControlPointIndex)
                gk.util:clearDrawNode(self.displayingNode)
                self.draggingControlPoint = nil
                self.draggingControlPointIndex = nil
                gk.event:post("postSync")
                gk.event:post("displayNode", self.displayingNode)
                gk.event:post("displayDomTree")
                return
            end
            if gk.util:isAncestorsIgnore(node) then
                return
            end
            if self.commandPressed then
                self._containerNode = nil
                return
            end
            self.draggingNode = nil
            local location = touch:getLocation()
            local p = node:getParent():convertToNodeSpace(location)
            cc.Director:getInstance():setDepthTest(false)
            node:setPositionZ(0)
            if node.__info and (node.__info._lock == 0 and not node.__info._isWidget) then
                self._containerNode = nil
                gk.event:post("displayDomTree")
                return
            end
            if node.__rootTable and node.__rootTable.__info and node.__rootTable.__info._isWidget then
                self._containerNode = nil
                gk.event:post("displayDomTree")
                return
            end
            if p.x == self._touchBegainPos.x and p.y == self._touchBegainPos.y then
                gk.event:post("displayDomTree")
                self._containerNode = nil
                return
            end
            -- move out of screen, cancel modify
            if not gk.util:hitTest(self.scene.layer, touch) then
                self._containerNode = nil
                p = cc.p(self._touchBegainPos)
            end
            local p = cc.pAdd(self._originPos, cc.pSub(p, self._touchBegainPos))
            p = self:onNodeMoved(node, p)

            local type = tolua.type(self._containerNode)
            if self._containerNode and self._containerNode ~= node:getParent() and
                    (not (type == "cc.ScrollView" and self._containerNode:getContainer() == node:getParent())) then
                local parent = node:getParent()
                local p = self._containerNode:convertToNodeSpace(node:getParent():convertToWorldSpace(p))
                local sx = clone(node.__info.scaleX)
                local sy = clone(node.__info.scaleY)
                local sxy = clone(node.__info.scaleXY)
                gk.event:post("executeCmd", "CHANGE_CONTAINER", {
                    id = node.__info._id,
                    fromPid = node.__info.parentId,
                    toPid = self._containerNode.__info._id,
                    fromPos = cc.p(node.__info.x, node.__info.y),
                    sx = sx,
                    sy = sy,
                    sxy = sxy,
                })
                node:retain()
                -- button child
                if parent and parent.__info and gk.util:instanceof(parent, "Button") and parent:getContentNode() == node then
                    parent:setContentNode(nil)
                end
                self:rescaleNode(node, self._containerNode)
                local x = math.round(gk.generator:parseXRvs(node, p.x, node.__info.scaleXY.x))
                local y = math.round(gk.generator:parseYRvs(node, p.y, node.__info.scaleXY.y))
                node.__info.x, node.__info.y = x, y
                node:removeFromParentAndCleanup(false)
                self._containerNode:addChild(node)
                node:release()
                gk.log("change node's container %s, new pos = %.2f, %.2f", node.__info._id, node.__info.x, node.__info.y)
            else
                local x = math.round(gk.generator:parseXRvs(node, p.x, node.__info.scaleXY.x))
                local y = math.round(gk.generator:parseYRvs(node, p.y, node.__info.scaleXY.y))
                --                node.__info.x, node.__info.y = x, y
                --                gk.log("move node %s to %.2f, %.2f", node.__info._id, node.__info.x, node.__info.y)
                if self._containerNode ~= nil then
                    gk.event:post("executeCmd", "MOVE", {
                        id = node.__info._id,
                        from = cc.p(node.__info.x, node.__info.y),
                        to = cc.p(x, y)
                    })
                end
            end
            self.sortedChildren = nil
            self._containerNode = nil
            self.draggingControlPoint = nil
            self.draggingControlPointIndex = nil
            gk.event:post("postSync")
            gk.event:post("displayNode", node)
            gk.event:post("displayDomTree")
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function(touch, event)
            cc.Director:getInstance():setDepthTest(false)
            node:setPositionZ(0)
            node:setPosition(self._originPos)
            self._containerNode = nil
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end
    if node.onEnterCallback_ then
        local pre = node.onEnterCallback_
        node:onNodeEvent("enter", function()
            pre()
            onEnterCallback()
        end)
    else
        node:onNodeEvent("enter", function()
            onEnterCallback()
        end)
    end
end

function panel:rescaleNode(node, parent)
    if node.__info._is3d then
        return
    end
    if node:isIgnoreAnchorPointForPosition() then
        -- Layer, ScrollView ...
        node.__info.scaleX, node.__info.scaleY = "1", "1"
    elseif not (self.scene.layer and self.scene.layer.class and self.scene.layer.class._isWidget) and not gk.util:instanceof(self.scene.layer, "TableViewCell") then
        -- normal node
        local sx, sy = gk.util:getGlobalScale(parent)
        gk.log("rescaleNode(%s) sx %f, sy %f", node.__info._id, sx, sy)
        if sx ~= 1 or sy ~= 1 then
            node.__info.scaleX, node.__info.scaleY = 1, 1
            node.__info.scaleXY = { x = "1", y = "1" }
        else
            node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale"
            node.__info.scaleXY = { x = "$scaleX", y = "$scaleY" }
        end
    end
end

function panel:drawNodeCoordinate(node)
    if node.__info and node.__info._id then
        local parent = node:getParent()
        if not parent then
            return
        end
        local x, y = node:getPositionX(), node:getPositionY()
        self.coordinateNode = cc.Node:create()
        self.coordinateNode:setTag(gk.util.tags.coordinateTag)
        parent:addChild(self.coordinateNode, 99999)
        self.coordinateNode:setPositionZ(1)
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
            arrow:setOpacity(100)
            self.coordinateNode:addChild(arrow)
            if width > 30 then
                -- label
                local fontName = gk.theme.font_fnt
                local label = gk.create_label(tostring(math.round(dis)), fontName, 50)
                label:setScale(scale)
                gk.set_label_color(label, cc.c3b(200, 100, 200))
                label:setAnchorPoint(ap.x, ap.y)
                label:setPosition(p)
                self.coordinateNode:addChild(label)
            end
        end
        local size = parent:getContentSize()

        local disX = gk.generator:parseXRvs(node, x, node.__info.scaleXY.x)
        local disY = gk.generator:parseXRvs(node, y, node.__info.scaleXY.y)
        local disX2 = gk.generator:parseXRvs(node, (size.width - x), node.__info.scaleXY.x)
        local disY2 = gk.generator:parseXRvs(node, (size.height - y), node.__info.scaleXY.y)
        -- left
        createArrow(x, disX, sx, cc.p(3, y + 2), 180, cc.p(0, 0))
        -- down
        createArrow(y, disY, sy, cc.p(x + 5, 3), 90, cc.p(0, 0))
        -- right
        createArrow((size.width - x), disX2, sx, cc.p(size.width - 3, y + 2), 0, cc.p(1, 0))
        -- top
        createArrow((size.height - y), disY2, sy, cc.p(x + 5, size.height - 3), -90, cc.p(0, 1))
    end
end

function panel:undisplayNode(expRightPanel)
    if not expRightPanel then
        self.rightPanel:undisplayNode()
    end
    if self.displayingNode then
        gk.util:clearDrawNode(self.displayingNode)
        self.displayingNode = nil
    end
    if self.coordinateNode then
        self.coordinateNode:removeFromParent()
        self.coordinateNode = nil
    end
end

function panel:displayNode(node, noneCoordinate)
    if not node or not node.__info or node.__ignore then
        return
    end
    local displayCoordinate = not noneCoordinate
    gk.log("displayNode --------------------- %s", node.__info._id)
    self:undisplayNode()
    self.displayingNode = node
    if node ~= self.scene.layer or node.class._isWidget then
        gk.util:drawNode(node)
    elseif node == self.scene.layer and gk.util:instanceof(node, "TableViewCell") then
        gk.util:drawNode(node, cc.c4f(120, 200 / 255, 0, 0.2), -10)
    end
    if displayCoordinate then
        self:drawNodeCoordinate(node)
    end
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
        if key == "KEY_ESCAPE" and gk.mode == gk.MODE_EDIT then
            self:undisplayNode(true)
            gk.util:clearDrawNode(self.scene.layer, -3)
        end
        -- copy node
        if self.commandPressed then
            if key == "KEY_C" and self.displayingNode then
                gk.log("copy node %s", self.displayingNode.__info._id)
                self.copyingNode = self.displayingNode
            elseif key == "KEY_V" and self.copyingNode then
                local info = clone(gk.generator:deflate(self.copyingNode))
                self:resetIds(info)
                local node = gk.generator:inflate(info, nil, self.scene.layer)
                if node then
                    self.copyingNodeTimes = self.copyingNodeTimes or 0
                    self.copyingNodeTimes = self.copyingNodeTimes + 1
                    node.__info.x, node.__info.y = node.__info.x + 20 * self.copyingNodeTimes, node.__info.y --+ 20 * self.copyingNodeTimes
                    self.copyingNode:getParent():addChild(node)
                    gk.log("paste node %s", node.__info._id)
                    gk.event:post("executeCmd", "ADD", {
                        id = node.__info._id,
                        panel = self,
                    })
                    gk.event:post("postSync")
                    gk.event:post("displayNode", node)
                    gk.event:post("displayDomTree")
                end
            elseif key == "KEY_Z" then
                gk.event:post("undoCmd")
            end
            return
        end

        --        gk.log("%s:onKeyPressed %s", "EditorPanel", key)
        if self.displayingNode then
            if self.displayingNode.__rootTable ~= self.scene.layer then
                gk.log("[Warning] cannot modify widget's children")
                return
            end

            if key == "KEY_L" then
                self.displayingNode.__info._lock = self.displayingNode.__info._lock == 0 and 1 or 0
                gk.event:post("displayNode", self.displayingNode)
                gk.event:post("displayDomTree", true, true)
                return
            elseif key == "KEY_F" then
                self.displayingNode.__info._fold = not self.displayingNode.__info._fold
                gk.event:post("displayNode", self.displayingNode)
                gk.event:post("displayDomTree", true, true)
                return
            elseif key == "KEY_V" then
                self.displayingNode.__info.visible = self.displayingNode.__info.visible == 0 and 1 or 0
                gk.event:post("displayNode", self.displayingNode)
                gk.event:post("displayDomTree", true, true)
                return
            end

            -- TODO: hold
            self.moveActions = self.moveActions or {
                KEY_LEFT_ARROW = function(info, step)
                    gk.log("%s, %d", info._id, step)
                    info.x = math.floor(info.x - step)
                end,
                KEY_RIGHT_ARROW = function(info, step)
                    info.x = math.floor(info.x + step)
                end,
                KEY_UP_ARROW = function(info, step)
                    info.y = math.floor(info.y + step)
                end,
                KEY_DOWN_ARROW = function(info, step)
                    info.y = math.floor(info.y - step)
                end,
            }
            local move = self.moveActions[key]
            if move then
                if #self.multiSelectNodes > 0 then
                    for _, nd in ipairs(self.multiSelectNodes) do
                        move(nd.__info, 1)
                    end
                else
                    move(self.displayingNode.__info, 1)
                end
                local action = self:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
                    local action = self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
                        if #self.multiSelectNodes > 0 then
                            for _, nd in ipairs(self.multiSelectNodes) do
                                move(nd.__info, 1)
                            end
                        else
                            move(self.displayingNode.__info, 1)
                        end
                        gk.event:post("displayNode", self.displayingNode)
                    end))))
                    action:setTag(kMoveNodeAction)
                end)))
                action:setTag(kMoveNodeAction)
                self:onNodeMoved(self.displayingNode, nil, 0)
                gk.event:post("displayNode", self.displayingNode)
            end
        end

        self.copyingNode = nil
        self.copyingNodeTimes = 0

        if key == "KEY_BACKSPACE" then
            -- delete node
            if self.shiftPressed and self.displayingNode and self.displayingNode.__info._id and self.displayingNode ~= self.scene.layer then
                local info = clone(gk.generator:deflate(self.displayingNode))
                gk.event:post("executeCmd", "DELETE", {
                    info = info,
                    parentId = self.displayingNode.__info.parentId,
                })
                self:deleteNode(self.displayingNode)
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
end

function panel:resetIds(info)
    -- clear id info
    info._id = nil
    if info._children then
        for i = 1, #info._children do
            local child = info._children[i]
            if child then
                self:resetIds(child)
            end
        end
    end
end

function panel:deleteNode(node)
    gk.log("delete node %s", node.__info._id)
    -- button child
    local parent = node:getParent()
    if parent and parent.__info and gk.util:instanceof(parent, "Button") and parent:getContentNode() == node then
        gk.log("set content node nil %s", parent.__info)
        parent:setContentNode(nil)
    end
    self:removeNodeIndex(node, self.scene.layer)
    if node == self.displayingNode then
        if self.coordinateNode then
            self.coordinateNode:removeFromParent()
            self.coordinateNode = nil
        end
        self.displayingNode = nil
    end
    node:removeFromParent()
    self:undisplayNode()
    gk.event:post("postSync")
    gk.event:post("displayDomTree")
end

function panel:removeNodeIndex(node, rootTable)
    if node.__info and node.__info._id and rootTable[node.__info._id] == node then
        rootTable[node.__info._id] = nil
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

function panel:sortChildrenOfSceneGraphPriority(node)
    self.sortedChildren = self.sortedChildren or {}
    node:sortAllChildren()
    local children = node:getChildren()
    local childrenCount = #children
    if childrenCount > 0 then
        for i = 1, childrenCount do
            local child = children[i]
            if child and child:getLocalZOrder() < 0 and child.__info then
                self:sortChildrenOfSceneGraphPriority(child)
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
                self:sortChildrenOfSceneGraphPriority(child)
            end
        end
    else
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
    end
end

-- smart align node
function panel:onNodeMoved(node, destPos, threshold)
    if destPos then
        destPos.x = math.shrink(destPos.x, 1)
        destPos.y = math.shrink(destPos.y, 1)
        node:setPosition(destPos)
    end
    threshold = threshold or 2

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

    allInfoNodes(self.scene.layer)
    local tag = -3
    gk.util:clearDrawNode(self.scene.layer, tag)
    local findX, findY, findLeftX, findRightX, findTopY, findBottomY
    local delta = cc.p(0, 0)
    local p1 = self.scene.layer:convertToNodeSpace(node:getParent():convertToWorldSpace(cc.p(node:getPosition())))
    local sx, sy = gk.util:getGlobalScale(node)
    local size = node:getContentSize()
    local drawLine = function(p1, p2)
        gk.util:drawSegmentOnNode(self.scene.layer, p1, p2, 8, cc.c4f(0 / 255, 255 / 255, 102 / 255, 0.5), tag):setPositionZ(0.00000001)
        gk.util:drawDotOnNode(self.scene.layer, p1, cc.c4f(0 / 255, 255 / 255, 102 / 255, 0.5), tag)
        gk.util:drawDotOnNode(self.scene.layer, p2, cc.c4f(0 / 255, 255 / 255, 102 / 255, 0.5), tag)
    end
    local updatePosX = function(dtX)
        if destPos and not findX and not findLeftX and not findRightX then
            p1.x = p1.x + dtX
            node:setPosition(node:getParent():convertToNodeSpace(self.scene.layer:convertToWorldSpace(p1)))
        end
    end
    local updatePosY = function(dtY)
        if destPos and not findY and not findTopY and not findBottomY then
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

    return cc.p(node:getPosition())
end

return panel