--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午6:03
-- To change this template use File | Settings | File Templates.
--

local generator = import(".generator")
local panel = {}

local marginTop = 15
local leftX = 16
local stepY = 20
local stepX = 11
function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), gk.display.leftWidth, winSize.height - gk.display.topHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(0, 0)

    local size = self:getContentSize()
    local createLine = function(y)
        gk.util:drawLineOnNode(self, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
    end
    createLine(size.height - 0.5)

    self:handleEvent()

    return self
end

function panel:undisplayNode()
    if self.displayInfoNode then
        self.displayInfoNode:removeFromParent()
        self.displayInfoNode = nil
    end
    self.draggingNode = nil
    self.sortedChildren = nil
    self._containerNode = nil
    self.selectedNode = nil
end

function panel:displayDomTree(rootLayer)
    if rootLayer then
        gk.log("displayDomTree")
        -- current layout
        self:undisplayNode()
        self.displayInfoNode = cc.Node:create()
        self:addChild(self.displayInfoNode)
        self.domDepth = 0
        self.displayingDomDepth = -1

        -- other layout
        local keys = table.keys(gk.resource.genNodes)
        table.sort(keys, function(k1, k2) return k1 < k2 end)
        for _, key in ipairs(keys) do
            if key == rootLayer.__cname then
                local lastDisplayLayer = gk.resource.genNodes[key]
                if lastDisplayLayer then
                    cc.UserDefault:getInstance():setStringForKey("lastDisplayLayer", key)
                    cc.UserDefault:getInstance():flush()
                end
                self:displayDomNode(rootLayer, 0)
            else
                self:displayOthers({ key })
            end
        end
        self.displayInfoNode:setContentSize(cc.size(gk.display.leftWidth, stepY * self.domDepth + gk.display.bottomHeight))
        -- scroll to displaying node
        if self.displayingDomDepth ~= -1 then
            gk.log("displayingDomDepth = %d", self.displayingDomDepth)
            local size = self.displayInfoNode:getContentSize()
            local topY = size.height - marginTop
            local offsetY = topY - (stepY * self.displayingDomDepth + gk.display.bottomHeight)
            local y = size.height - offsetY - self:getContentSize().height / 2
            y = cc.clampf(y, 0, size.height - self:getContentSize().height)
            self.displayInfoNode:setPositionY(y)
        end
    end
end

function panel:displayDomNode(node, layer)
    if tolua.type(node) == "cc.DrawNode" or node:getTag() == -99 then
        return
    end
    local fixChild = node.__info == nil
    local realNode = node
    local size = self:getContentSize()
    local fontName = "Consolas"
    local fontSize = 11 * 4
    local scale = 0.25
    local topY = size.height - marginTop
    local createButton = function(content, x, y)
        local group = false
        local children = node:getChildren()
        if children then
            for i = 1, #children do
                local child = children[i]
                if child and tolua.type(child) ~= "cc.DrawNode" and child:getTag() ~= -99 then --and child.__info and child.__info.id then
                group = true
                break
                end
            end
        end
        if group then
            x = x - 11
            local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
            label:setTextColor(cc.c3b(200, 200, 200))
            if fixChild or not node.__info._flod then
                label:setRotation(90)
            end
            label:setDimensions(10 / scale, 10 / scale)
            label:setContentSize(10 / scale, 10 / scale)
            local button = gk.ZoomButton.new(label)
            if fixChild or not node.__info._flod then
                button:setScale(scale, scale * 0.6)
                button:setPosition(x - 3, y)
            else
                button:setScale(scale * 0.6, scale)
                button:setPosition(x + 1, y)
            end
            self.displayInfoNode:addChild(button)
            button:setAnchorPoint(0, 0.5)
            button:onClicked(function()
                if fixChild then
                    return
                end
                gk.log("fold container %s, %s", node.__info.id, node.__info._flod)
                node.__info._flod = not node.__info._flod
                gk.log("fold container %s, %s", node.__info.id, node.__info._flod)
                gk.event:post("displayDomTree")
            end)
            x = x + 11
        end

        local label = cc.Label:createWithSystemFont(string.format("%s(%d", content, node:getLocalZOrder()), fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setDimensions(contentSize.width  - x/scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(cc.c3b(0x99, 0xcc, 0x00))
        if fixChild then --or (node.__info and node.__info.lock == 1) then
        label:setTextColor(cc.c3b(200, 200, 200))
        label:setOpacity(100)
        end
        if not gk.util:isAncestorsVisible(node) then
            label:setTextColor(cc.c3b(200, 200, 200))
            label:setOpacity(100)
        end
        if (node.__info and node.__info.lock == 0) then
            label:setTextColor(cc.c3b(200, 200, 200))
            label:setOpacity(100)
        end
        label:setScale(scale)
        self.displayInfoNode:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        -- select
        if self.parent.displayingNode == node then
            self.displayingDomDepth = self.domDepth
            gk.util:drawNodeBg(label, cc.c4f(0.5,0.5,0.5,0.5), -2)
            self.selectedNode = label
        end
        -- drag button
        if not fixChild then
            label:setTag(1)
            label.content = content
            local node = label
            local listener = cc.EventListenerTouchOneByOne:create()
            listener:setSwallowTouches(true)
            listener:registerScriptHandler(function(touch, event)
                local location = touch:getLocation()
                self._touchBegainLocation = cc.p(location)
                local s = node:getContentSize()
                local rect = { x = 0, y = 0, width = s.width, height = s.height }
                local p = node:convertToNodeSpace(location)
                if not self.draggingNode and cc.rectContainsPoint(rect, p) then
                    gk.log("dom:choose node %s", content)
                    local nd = self.parent.scene.layer[content]
                    local voidContent = realNode.__info and realNode.__info.voidContent
                    if nd or voidContent then
                        if self.selectedNode ~= node then
                            if self.selectedNode then
                                gk.util:clearDrawNode(self.selectedNode, -2)
                            end
                        end
                        self.selectedNode = node
                        gk.util:drawNodeBg(node, cc.c4f(0.5,0.5,0.5,0.5), -2)
                        gk.event:post("displayNode", nd)
                    end
                    if voidContent then
                        return false
                    end
                    return true
                else
                    return false
                end
            end, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(function(touch, event)
                local location = touch:getLocation()
                local p = self:convertToNodeSpace(location)
                if not self.draggingNode then
                    gk.log("dom:create dragging node %s", content)
                    local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
                    local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
                    label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
                    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                    label:setTextColor(cc.c3b(200, 200, 200))
                    label:setAnchorPoint(0, 0.5)
                    label:setScale(scale)
                    self.displayInfoNode:addChild(label)
                    self.draggingNode = label
                end
                self.draggingNode:setPosition(cc.pAdd(cc.p(x, y), cc.pSub(p, self.displayInfoNode:convertToNodeSpace(self._touchBegainLocation))))

                -- find dest container
                if self.sortedChildren == nil then
                    self:sortChildrenOfSceneGraphPriority(self.displayInfoNode, true)
                end
                if self._containerNode then
                    gk.util:clearDrawNode(self._containerNode, -2)
                end
                if self.selectedNode then
                    gk.util:clearDrawNode(self.selectedNode, -2)
                end
                self._containerNode = nil
                local children = self.sortedChildren
                for i = #children, 1, -1 do
                    local node = children[i]
                    local s = node:getContentSize()
                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    local p = node:convertToNodeSpace(location)
                    if cc.rectContainsPoint(rect, p) then
                        local nd1 = self.parent.scene.layer[node.content]
                        local nd2 = self.parent.scene.layer[content]
                        if nd1 and nd2 then
                            if nd1 == nd2 or nd1:getParent() == nd2 then
                                break
                            end
                            if p.y < s.height / 2 and nd1 and nd2 and (nd1:getParent() == nd2:getParent() or nd2:getParent() == nd1) then
                                -- reorder mode
                                local size = node:getContentSize()
                                gk.util:drawSolidRectOnNode(node, cc.p(0, 5), cc.p(size.width, 0), cc.c4f(0, 1, 0, 1), -2)
                                self.mode = 1
                            elseif nd2:getParent() == nd1 then
                                break
                            else
                                -- change container mode
                                gk.util:drawNode(node, cc.c4f(1, 0, 0, 1), -2)
                                self.mode = 2
                            end
                            self._containerNode = node
                            --                            gk.log("dom:find container node %s", self._containerNode.content)
                            local nd = self.parent.scene.layer[self._containerNode.content]
                            if nd then
                                gk.event:post("displayNode", nd)
                            end
                            break
                        end
                    end
                end
            end, cc.Handler.EVENT_TOUCH_MOVED)
            listener:registerScriptHandler(function(touch, event)
                if self._containerNode then
                    if self.mode == 2 then
                        -- change container mode
                        local container = self.parent.scene.layer[self._containerNode.content]
                        local node = self.parent.scene.layer[content]
                        if node and container then
                            local p = cc.p(node:getPosition())
                            p = container:convertToNodeSpace(node:getParent():convertToWorldSpace(p))
                            node:retain()
                            node:removeFromParent()
                            self.parent:rescaleNode(node, container)
                            local scaleX = generator:parseValue("scaleX", node, node.__info.scaleXY.x)
                            local scaleY = generator:parseValue("scaleY", node, node.__info.scaleXY.y)
                            node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
                            container:addChild(node)
                            node:release()
                            gk.log("dom:move node to %.2f, %.2f", node.__info.x, node.__info.y)
                            gk.event:post("displayDomTree")
                            return
                        end
                    elseif self.mode == 1 then
                        -- reorder mode
                        local bro = self.parent.scene.layer[self._containerNode.content]
                        local node = self.parent.scene.layer[content]
                        if node and bro and (node:getParent() == bro:getParent() or node:getParent() == bro) then
                            if node:getParent() == bro then
                                -- put in the first place
                                local parent = node:getParent()
                                parent:sortAllChildren()
                                local children = parent:getChildren()
                                local child = children[1]
                                if child ~= node then
                                    local z1, z2 = child:getLocalZOrder(), node:getLocalZOrder()
                                    if z2 > z1 then
                                        -- demotion
                                        z2 = z1
                                    end
                                    parent:reorderChild(node, z2)
                                    for i = 1, #children do
                                        local child = children[i]
                                        if child and child.__info then
                                            if child:getLocalZOrder() == z1 and node ~= child then
                                                parent:reorderChild(child, z1)
                                            end
                                        end
                                    end
                                    gk.log("dom:reorder node %s before %s", node.__info.id, child.__info.id)
                                end
                            else
                                local parent = node:getParent()
                                local z1, z2 = bro:getLocalZOrder(), node:getLocalZOrder()
                                if z2 < z1 then
                                    -- promotion
                                    z2 = z1
                                end
                                parent:sortAllChildren()
                                local reorder = false
                                local children = parent:getChildren()
                                for i = 1, #children do
                                    local child = children[i]
                                    if child and child.__info then
                                        if z2 > z1 then
                                            if child:getLocalZOrder() == z2 and node ~= child then
                                                parent:reorderChild(child, z2)
                                            end
                                        else
                                            if child:getLocalZOrder() == z1 then
                                                if child == bro then
                                                    reorder = true
                                                    parent:reorderChild(node, z2)
                                                elseif reorder and child ~= node then
                                                    parent:reorderChild(child, z1)
                                                end
                                            end
                                        end
                                    end
                                end
                                node.__info.localZOrder = z2
                                gk.log("dom:reorder node %s after %s", node.__info.id, bro.__info.id)
                            end
                            gk.event:post("displayDomTree")
                            gk.event:post("postSync")
                        end
                    end
                end
                if self._containerNode then
                    gk.util:clearDrawNode(self._containerNode, -2)
                end
                if self.draggingNode then
                    self.draggingNode:removeFromParent()
                    self.draggingNode = nil
                end
                self.sortedChildren = nil
                self._containerNode = nil
            end, cc.Handler.EVENT_TOUCH_ENDED)
            listener:registerScriptHandler(function(touch, event)
                if self.draggingNode then
                    self.draggingNode:removeFromParent()
                    self.draggingNode = nil
                end
                self.sortedChildren = nil
                self._containerNode = nil
            end, cc.Handler.EVENT_TOUCH_CANCELLED)
            cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
        end
        return label
    end

    createButton(fixChild and tolua.type(node) or node.__info.id, leftX + stepX * layer, topY - stepY * self.domDepth)
    self.domDepth = self.domDepth + 1
    layer = layer + 1
    if not (node.__info and node.__info.isWidget and node.__info.isWidget == 0) then
        if fixChild or not node.__info._flod then
            node:sortAllChildren()
            local children = node:getChildren()
            if children then
                for i = 1, #children do
                    local child = children[i]
                    if child then --and child.__info and child.__info.id then
                    self:displayDomNode(child, layer)
                    end
                end
            end
        end
    end

    if iskindof(node, "cc.ProgressTimer") then
        local sprite = node:getSprite()
        self:displayDomNode(sprite, layer)
    end
end

function panel:displayOthers(keys)
    local size = self:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 16
    local stepY = 20
    local createButton = function(content, x, y)
        x = x - 11
        local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
        label:setTextColor(cc.c3b(200, 200, 200))
        label:setDimensions(10 / scale, 10 / scale)
        label:setContentSize(10 / scale, 10 / scale)
        local button = gk.ZoomButton.new(label)
        button:setScale(scale * 0.6, scale)
        self.displayInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x + 1, y)
        button:onClicked(function()
            gk.event:post("unfoldRootLayout", content)
        end)
        x = x + 11

        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(cc.c3b(200, 200, 200))
        local button = gk.ZoomButton.new(label)
        button:setScale(scale)
        self.displayInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x, y)
        button:onClicked(function()
            gk.log("post changeRootLayout")
            gk.event:post("changeRootLayout", content)
        end)
        return button
    end
    for _, key in ipairs(keys) do
        createButton(key, leftX, topY - stepY * self.domDepth)
        self.domDepth = self.domDepth + 1
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
            if child and child:getLocalZOrder() < 0 and child:getTag() == 1 then
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
            if child and child:getTag() == 1 then
                self:sortChildrenOfSceneGraphPriority(child, false)
            end
        end
    else
        if not table.indexof(self.sortedChildren, node) then
            table.insert(self.sortedChildren, node)
        end
    end
end

function panel:handleEvent()
    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocationInView()
        if gk.util:touchInNode(self, location) then
            if self.displayInfoNode:getContentSize().height > self:getContentSize().height then
                local scrollY = touch:getScrollY()
                local x, y = self.displayInfoNode:getPosition()
                y = y + scrollY * 10
                y = cc.clampf(y, 0, self.displayInfoNode:getContentSize().height - self:getContentSize().height)
                self.displayInfoNode:setPosition(x, y)
            end
        end
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return panel