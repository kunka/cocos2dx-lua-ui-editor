--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午6:03
-- To change this template use File | Settings | File Templates.
--

local generator = import(".generator")
local panel = {}

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
    createLine(size.height)

    return self
end

function panel:undisplayNode()
    if self.displayDomInfoNode then
        self.displayDomInfoNode:removeFromParent()
        self.displayDomInfoNode = nil
    end
end

function panel:displayDomTree(rootLayer)
    if rootLayer then
        -- current layout
        self:undisplayNode()
        self.displayDomInfoNode = cc.Node:create()
        self:addChild(self.displayDomInfoNode)
        self.domDepth = 0

        -- other layout
        local keys = table.keys(gk.resource.genNodes)
        table.sort(keys, function(k1, k2) return k1 < k2 end)
        for _, key in ipairs(keys) do
            if key == rootLayer.__cname then
                self:displayDomNode(rootLayer, 0)
            else
                self:displayOthers({ key })
            end
        end
    end
end

function panel:displayDomNode(node, layer)
    if tolua.type(node) == "cc.DrawNode" or node:getTag() == -99 then
        return
    end
    local fixChild = node.__info == nil
    local size = self:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local stepY = 20
    local stepX = 40
    local createButton = function(content, x, y)
        local group = false
        local children = node:getChildren()
        if children then
            for i = 1, #children do
                local child = children[i]
                if child then --and child.__info and child.__info.id then
                group = true
                break
                end
            end
        end
        if group then
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
            self.displayDomInfoNode:addChild(button)
            button:setAnchorPoint(0, 0.5)
            button:onClicked(function()
                if fixChild then
                    return
                end
                gk.log("fold container %s", node.__info.id)
                node.__info._flod = not node.__info._flod
                gk.event:post("displayDomTree")
            end)
            x = x + 11
        end

        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(cc.c3b(200, 200, 200))
        if fixChild or not gk.util:isGlobalVisible(node) then
            label:setOpacity(100)
        end
        --        local button = gk.ZoomButton.new(label)
        --        button:setScale(scale)
        --        self.displayDomInfoNode:addChild(button)
        --        button:setAnchorPoint(0, 0.5)
        --        button:setPosition(x, y)
        label:setScale(scale)
        self.displayDomInfoNode:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        --        button:onClicked(function()
        --            if fixChild then
        --                return
        --            end
        --            gk.event:post("displayNode", node)
        --            gk.event:post("displayDomTree")
        --        end)
        -- select
        if self.parent.displayingNode == node then
            gk.util:drawNodeRect(label, nil)
        end
        -- drag button
        if not fixChild then
            label:setTag(1)
            content = string.trim(content)
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
                    gk.log("choose node %s", content)
                    local nd = self.parent.scene.layer[content]
                    if nd then
                        gk.event:post("displayNode", nd)
                    end
                    gk.event:post("displayDomTree")
                    return true
                else
                    return false
                end
            end, cc.Handler.EVENT_TOUCH_BEGAN)
            listener:registerScriptHandler(function(touch, event)
                local location = touch:getLocation()
                local p = self:convertToNodeSpace(location)
                if not self.draggingNode then
                    local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
                    local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
                    label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
                    label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
                    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                    label:setTextColor(cc.c3b(200, 200, 200))
                    label:setPosition(x, y)
                    label:setAnchorPoint(0, 0.5)
                    label:setScale(scale)
                    self:addChild(label)
                    self.draggingNode = label
                end
                self.draggingNode:setPosition(cc.pAdd(cc.p(x, y), cc.pSub(p, self:convertToNodeSpace(self._touchBegainLocation))))

                -- find dest container
                if self.sortedChildren == nil then
                    self:sortChildrenOfSceneGraphPriority(self.displayDomInfoNode, true)
                end
                local children = self.sortedChildren
                for i = #children, 1, -1 do
                    local node = children[i]
                    local s = node:getContentSize()
                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    local p = node:convertToNodeSpace(location)
                    if cc.rectContainsPoint(rect, p) then
                        if self._containerNode ~= node and node.content ~= content then
                            self._containerNode = node
                            gk.log("find container node %s", self._containerNode.content)
                            local nd = self.parent.scene.layer[self._containerNode.content]
                            if nd then
                                gk.event:post("displayNode", nd)
                            end
                        end
                        break
                    end
                end
            end, cc.Handler.EVENT_TOUCH_MOVED)
            listener:registerScriptHandler(function(touch, event)
                if self._containerNode then
                    local container = self.parent.scene.layer[self._containerNode.content]
                    local node = self.parent.scene.layer[content]
                    if node and container then
                        node:retain()
                        node:removeFromParent()
                        local p = cc.p(0, 0)
                        local sx, sy = gk.util:getGlobalScale(self._containerNode)
                        if sx ~= 1 or sy ~= 1 then
                            node.__info.scaleX, node.__info.scaleY = 1, 1
                            node.__info.scaleXY = { x = "1", y = "1" }
                        else
                            node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale"
                            node.__info.scaleXY = { x = "$xScale", y = "$yScale" }
                        end
                        local scaleX = generator:parseValue(node, node.__info.scaleXY.x)
                        local scaleY = generator:parseValue(node, node.__info.scaleXY.y)
                        node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
                        container:addChild(node)
                        node:release()
                        gk.log("move node to %.2f, %.2f", node.__info.x, node.__info.y)
                    end
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
                self.sortedChildren = nil
            end, cc.Handler.EVENT_TOUCH_CANCELLED)
            cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
        end
        return button
    end
    local whiteSpace = ""
    for i = 1, layer do
        whiteSpace = whiteSpace .. " "
    end
    createButton(whiteSpace .. (fixChild and tolua.type(node) or node.__info.id), leftX + 11 * layer, topY - stepY * self.domDepth)
    self.domDepth = self.domDepth + 1
    layer = layer + 1
    if fixChild or not node.__info._flod then
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

function panel:displayOthers(keys)
    local size = self:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local stepY = 20
    local createButton = function(content, x, y)
        local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
        label:setTextColor(cc.c3b(200, 200, 200))
        label:setDimensions(10 / scale, 10 / scale)
        label:setContentSize(10 / scale, 10 / scale)
        local button = gk.ZoomButton.new(label)
        button:setScale(scale * 0.6, scale)
        self.displayDomInfoNode:addChild(button)
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
        self.displayDomInfoNode:addChild(button)
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

return panel