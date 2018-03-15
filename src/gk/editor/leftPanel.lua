--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午6:03
-- To change this template use File | Settings | File Templates.
--

local panel = {}

local marginTop = 15
local leftX = 10
local stepY = 20
local stepX = 11
local fontSize = 11 * 4
--local fontName = "Consolas"
local fontName = gk.theme.font_fnt
local scale = 0.25
function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(gk.theme.config.backgroundColor, gk.display.leftWidth, winSize.height - gk.display.topHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(0, 0)

    local size = self:getContentSize()
    local createLine = function(y)
        gk.util:drawLineOnNode(self, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
    end
    createLine(size.height - 0.5)

    self.displayInfoNode = cc.Node:create()
    self:addChild(self.displayInfoNode)

    self:handleEvent()

    return self
end

function panel:undisplayNode()
    -- do not remove cached node
    local children = self.displayInfoNode:getChildren()
    for _, child in ipairs(children) do
        if child:getTag() ~= 0 then
            self.displayInfoNode:removeChild(child)
        end
    end
    self.draggingNode = nil
    self.sortedChildren = nil
    self._containerNode = nil
    self.selectedNode = nil
end

function panel:displayDomTree(rootLayer, force, notForceUnfold)
    if rootLayer and rootLayer.__info then
        if gk.mode == gk.MODE_RELEASE_CURRENT then
            self:displaySceneStack(rootLayer)
            return
        end
        if not force and self.lastDisplayingNode and self.parent.displayingNode == self.lastDisplayingNode and self.parent.displayingNode.__info._id == self.lastDisplayingNode.__info._id then
            return
        end
        local forceUnfold = not notForceUnfold
        --        gk.log("displayDomTree %s, %s", rootLayer.__info._id, forceUnfold)
        --        gk.profile:start("displayDomTree")
        self.lastDisplayingNode = self.parent.displayingNode
        -- current layout
        self:undisplayNode()
        self.domDepth = 0
        self.displayingDomDepth = -1
        self.foldDomDepth = -1
        self.lastDisplayingPos = self.lastDisplayingPos or cc.p(0, 0)
        self.cachedOthers = self.cachedOthers or {}
        for _, v in pairs(self.cachedOthers) do
            v.button1:hide()
            v.button2:hide()
        end

        -- scan layouts
        if not self.domTree then
            local total = clone(gk.resource.genNodes)
            if gk.resource.isDisplayInternalNodes then
                table.merge(total, gk.resource.genNodesInternal)
            end
            local keys = table.keys(total)
            table.sort(keys, function(k1, k2)
                local dir1, dir2 = gk.resource:getGenNode(k1).genSrcPath, gk.resource:getGenNode(k2).genSrcPath
                if dir1 == dir2 then
                    return k1 < k2
                else
                    local len1, len2 = #dir1:split("/"), #dir2:split("/")
                    if len1 == len2 then
                        return dir1 < dir2
                    else
                        return len1 > len2
                    end
                end
            end)
            self.domTree = { _children = {}, _fold = false }
            for _, key in ipairs(keys) do
                local value = gk.resource:getGenNode(key)
                local displayName = value.genSrcPath:starts(gk.resource.genSrcPath) and value.genSrcPath:sub(gk.resource.genSrcPath:len() + 1) .. key or value.path
                local ks = string.split(displayName, "/")
                local parent = self.domTree
                for i = 1, #ks - 1 do
                    local group = ks[i]
                    if not parent[group] then
                        local fold = cc.UserDefault:getInstance():getBoolForKey("gkdom_" .. group)
                        parent[group] = { _children = {}, _fold = fold }
                    end
                    parent = parent[group]
                end
                local var = ks[#ks]
                table.insert(parent._children, var)
            end
        end

        local value = gk.resource:getGenNode(rootLayer.__cname)
        local displayingPath = value.genSrcPath:starts(gk.resource.genSrcPath) and value.genSrcPath:sub(gk.resource.genSrcPath:len() + 1) .. rootLayer.__cname or value.genSrcPath

        self.displayDom = self.displayDom or function(rootLayer, dom, layer, forceUnfold)
            local keys = table.keys(dom)
            table.sort(keys)
            for _, key in ipairs(keys) do
                if key ~= "_fold" and key ~= "_children" then
                    if forceUnfold and dom[key]._fold and string.find(displayingPath, key .. "/") then
                        -- force unfold
                        dom[key]._fold = false
                    end
                    self:displayGroup(key, layer, nil, dom[key])
                    if not dom[key]._fold then
                        self.displayDom(rootLayer, dom[key], layer + 1, forceUnfold)
                    end
                end
            end
            for _, child in ipairs(dom._children) do
                local value = gk.resource:getGenNode(child)
                local displayName = child --value.genSrcPath:starts(gk.resource.genSrcPath) and value.genSrcPath:sub(gk.resource.genSrcPath:len() + 1) .. child or value.genSrcPath
                if child == rootLayer.__cname then
                    cc.UserDefault:getInstance():setStringForKey(gk.lastLaunchEntryKey, value.path)
                    cc.UserDefault:getInstance():flush()
                    self:displayDomNode(rootLayer, layer, displayName)
                else
                    self:displayOthers(child, layer, displayName)
                end
            end
        end
        self.displayDom(rootLayer, self.domTree, 0, forceUnfold)

        self.displayInfoNode:setContentSize(cc.size(gk.display.leftWidth, stepY * self.domDepth + 20))
        -- scroll to displaying node
        if self.displayingDomDepth ~= -1 and forceUnfold then
            --            gk.log("displayingDomDepth = %d", self.displayingDomDepth)
            local size = self.displayInfoNode:getContentSize()
            if size.height > self:getContentSize().height then
                local topY = size.height - marginTop
                local offsetY = topY - (stepY * self.displayingDomDepth + gk.display.bottomHeight)
                local y = size.height - offsetY - self:getContentSize().height / 2
                y = cc.clampf(y, 0, size.height - self:getContentSize().height)
                local dt = 0.2 + 0.2 * math.abs(self.lastDisplayingPos.y - y) / 150
                if dt > 0.5 then
                    dt = 0.5
                end
                if self.lastDisplayingPos.y ~= 0 then
                    self.displayInfoNode:runAction(cc.EaseInOut:create(cc.MoveTo:create(dt, cc.p(0, y)), 2))
                else
                    self.displayInfoNode:setPositionY(y)
                end
                self.lastDisplayingPos = cc.p(0, y)
            end
        elseif (not forceUnfold) or (self.displayingDomDepth ~= -1 and self.foldDomDepth and self.foldDomDepth > self.displayingDomDepth) then
            -- fold node below displaying node
            self.displayInfoNode:setPosition(self.lastDisplayingPos)
        end
        --        gk.profile:stop("displayDomTree")
    end
end

function panel:createButton(content, x, y, displayName, fixChild, node, widgetParent)
    local realNode = node
    local group = false
    local children = node:getChildren()
    if children then
        for i = 1, #children do
            local child = children[i]
            if child and tolua.type(child) ~= "cc.DrawNode" and child:getTag() ~= -99 then --and child.__info and child.__info._id then
            group = true
            break
            end
        end
    end
    local lock = node.__info and node.__info._lock == 0
    if group then
        local label = gk.create_label("▶", fontName, fontSize, gk.theme.config.fontColorNormal)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        if fixChild or not node.__info._fold then
            label:setRotation(90)
        end
        if lock or widgetParent then
            label:setOpacity(150)
        end
        label:setDimensions(16 / scale, 16 / scale)
        label:setContentSize(16 / scale, 16 / scale)
        local button = gk.ZoomButton.new(label)
        if fixChild or not node.__info._fold then
            button:setScale(scale, scale * 0.8)
            button:setPosition(x - 5, y)
        else
            button:setScale(scale * 0.8, scale)
            button:setPosition(x - 2, y)
        end
        self.displayInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:onClicked(function()
            if fixChild then
                return
            end
            node.__info._fold = not node.__info._fold
            gk.event:post("displayNode", node)
            gk.event:post("displayDomTree", true, true)
        end)
        x = x + 11
    end
    if lock then
        local label = gk.create_label("🔒", "Consolas", fontSize, gk.theme.config.fontColorNormal)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setDimensions(16 / scale, 16 / scale)
        label:setContentSize(16 / scale, 16 / scale)
        gk.set_label_color(label, cc.c3b(0x99, 0x99, 0x99))
        label:setScale(scale)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x - 4, y)
        label:setOpacity(150)
        self.displayInfoNode:addChild(label)
        x = x + 11
    end

    local string = string.format("%s(%d", displayName and displayName or (fixChild and "*" .. content or content), node:getLocalZOrder())
    local label = gk.create_label(string, fontName, fontSize)
    local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
    label:setDimensions(contentSize.width - x / scale, contentSize.height)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    gk.set_label_color(label, cc.c3b(0x99, 0xcc, 0x00))
    local visible = gk.util:isAncestorsVisible(node)
    local isWidget = (node.__info and node.__info._isWidget)
    if isWidget then
        gk.set_label_color(label, cc.c3b(0xFF, 0x88, 0xFF))
    end
    if fixChild or widgetParent or not visible or lock then
        if not isWidget then
            gk.set_label_color(label, gk.theme.config.fontColorNormal)
        end
        label:setOpacity(150)
    end
    local cur = widgetParent and widgetParent[content] or self.parent.scene.layer[content]
    if cur and cur == self.parent.draggingNode then
        gk.set_label_color(label, cc.c3b(0xFF, 0x00, 0x00))
    end
    label:setScale(scale)
    self.displayInfoNode:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setPosition(x, y)
    gk.util:addMouseMoveEffect(label)
    -- select
    if self.parent.displayingNode == node then
        self.displayingDomDepth = self.domDepth
        --            label:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
        gk.util:drawNodeBg(label, cc.c4f(0.5, 0.5, 0.5, 0.5), -2)
        --            end)))
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
            self._containerNode = nil
            local location = touch:getLocation()
            self._touchBegainLocation = cc.p(location)
            if gk.util:hitTest(self, touch) and not self.draggingNode and gk.util:hitTest(node, touch) then
                gk.log("dom:choose node %s", content)
                local nd = widgetParent and widgetParent[content] or self.parent.scene.layer[content]
                nd = nd or realNode
                local _voidContent = realNode.__info and realNode.__info._voidContent
                if nd or _voidContent then
                    if self.selectedNode ~= node then
                        if self.selectedNode then
                            gk.util:clearDrawNode(self.selectedNode, -2)
                        end
                    end
                    self.selectedNode = node
                    gk.util:drawNodeBg(node, cc.c4f(0.5, 0.5, 0.5, 0.5), -2)
                    gk.event:post("displayNode", nd)
                end
                if _voidContent or widgetParent then
                    gk.log("[Warning] cannot modify _voidContent or widget's children")
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
                local label = gk.create_label(content, fontName, fontSize)
                local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
                label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
                label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
                gk.set_label_color(label, gk.theme.config.fontColorNormal)
                label:setAnchorPoint(0, 0.5)
                label:setScale(scale)
                self.displayInfoNode:addChild(label)
                self.draggingNode = label
            end
            local dragPos = cc.pAdd(cc.p(x, y), cc.pSub(p, self.displayInfoNode:convertToNodeSpace(self._touchBegainLocation)))
            dragPos.x = dragPos.x - self.displayInfoNode:getPositionX()
            dragPos.y = dragPos.y - self.displayInfoNode:getPositionY()
            self.draggingNode:setPosition(dragPos)

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
            self.lastContainerNode = self._containerNode
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
                        if nd1 == nd2 or nd1:getParent() == nd2 or gk.util:isAncestorOf(nd2, nd1) then
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
                        if self.lastContainerNode ~= self._containerNode then
                            local nd = self.parent.scene.layer[self._containerNode.content]
                            if nd then
                                gk.event:post("displayNode", nd, true)
                            end
                            self.lastContainerNode = self._containerNode
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
                        local parent = node:getParent()
                        local p = cc.p(node:getPosition())
                        p = container:convertToNodeSpace(node:getParent():convertToWorldSpace(p))
                        local sx = clone(node.__info.scaleX)
                        local sy = clone(node.__info.scaleY)
                        local sxy = clone(node.__info.scaleXY)
                        gk.event:post("executeCmd", "CHANGE_CONTAINER", {
                            id = node.__info._id,
                            fromPid = node.__info.parentId,
                            toPid = container.__info._id,
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
                        self.parent:rescaleNode(node, container)
                        local x = math.round(gk.generator:parseXRvs(node, p.x, node.__info.scaleXY.x))
                        local y = math.round(gk.generator:parseYRvs(node, p.y, node.__info.scaleXY.y))
                        node.__info.x, node.__info.y = x, y
                        node:removeFromParentAndCleanup(false)
                        container:addChild(node)
                        node:release()
                        gk.log("dom:change node container, new pos = %.2f, %.2f", node.__info.x, node.__info.y)
                        gk.event:post("displayDomTree", true)
                        gk.event:post("displayNode", node)
                        gk.event:post("postSync")
                        self.mode = 0
                    end
                elseif self.mode == 1 then
                    -- reorder mode
                    local bro = self.parent.scene.layer[self._containerNode.content]
                    local node = self.parent.scene.layer[content]
                    if node and bro and (node:getParent() == bro:getParent() or node:getParent() == bro) then
                        -- gen ordersBefore
                        gk.event:post("executeCmd", "REORDER", {
                            parentId = node.__info.parentId,
                        })

                        if node:getParent() == bro then
                            -- put in the first place
                            local parent = node:getParent()
                            parent:sortAllChildren()
                            local children = parent:getChildren()
                            -- local child = children[1]
                            for i = 1, #children do
                                local child = children[i]
                                if child.__info then
                                    if child ~= node then
                                        local z1, z2 = child:getLocalZOrder(), node:getLocalZOrder()
                                        if z2 > z1 then
                                            -- demotion
                                            z2 = z1
                                        end
                                        parent:reorderChild(node, z2)
                                        for i = 1, #children do
                                            local c = children[i]
                                            if c and c.__info then
                                                if c:getLocalZOrder() == z1 and node ~= c then
                                                    parent:reorderChild(c, z1)
                                                end
                                            end
                                        end
                                        node.__info.localZOrder = z2
                                        gk.log("dom:reorder node %s before %s", node.__info._id, child.__info._id)
                                    end
                                    break
                                end
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
                            gk.log("dom:reorder node %s after %s", node.__info._id, bro.__info._id)
                        end
                        gk.event:post("displayDomTree", true)
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

function panel:displayDomNode(node, layer, displayName, widgetParent)
    if tolua.type(node) == "cc.DrawNode" or gk.util:isDebugNode(node) then
        return
    end
    local fixChild = node.__info == nil or node.__ignore
    local size = self:getContentSize()
    local topY = size.height - marginTop

    local title = fixChild and tolua.type(node) or node.__info._id
    if node.__ignore then
        title = node.__info._type
    end
    self:createButton(title, leftX + stepX * layer, topY - stepY * self.domDepth, displayName, fixChild, node, widgetParent)
    self.domDepth = self.domDepth + 1
    layer = layer + 1
    local preWidgetParent = widgetParent
    local widgetParent = widgetParent
    if (node.__info and node.__info._isWidget) then
        widgetParent = node
    end

    if node.__info and node.__info._fold and node ~= self.lastDisplayingNode and gk.util:isAncestorOf(node, self.lastDisplayingNode) then
        -- force unfold
        node.__info._fold = false
    end

    if fixChild or not node.__info._fold then
        if tolua.type(node) == "cc.TMXLayer" or node.__ignore then
            return
        end
        node:sortAllChildren()
        local children = node:getChildren()
        if children then
            for _, child in ipairs(children) do
                --and child.__info and child.__info._id then
                if child.__rootTable == widgetParent then
                    self:displayDomNode(child, layer, nil, widgetParent)
                elseif child.__rootTable == preWidgetParent then
                    self:displayDomNode(child, layer, nil, preWidgetParent)
                else
                    self:displayDomNode(child, layer, nil, nil)
                end
            end
        end
    end

    if gk.util:instanceof(node, "cc.ProgressTimer") then
        local sprite = node:getSprite()
        self:displayDomNode(sprite, layer)
    end
end

function panel:createButtonOthers(content, x, y, displayName)
    -- cache others, do not recreate
    self.cachedOthers = self.cachedOthers or {}
    if self.cachedOthers[content] then
        local button1 = self.cachedOthers[content].button1
        local button2 = self.cachedOthers[content].button2
        button1:setPosition(x, y - 1)
        button2:setPosition(x, y)
        button1:onClicked(function()
            gk.event:post("unfoldRootLayout", content)
        end)
        button2:onClicked(function()
            gk.log("post changeRootLayout")
            gk.event:post("changeRootLayout", content)
        end)
        button1:show()
        button2:show()
    else
        local label = gk.create_label("◉", fontName, fontSize - 5, gk.theme.config.fontColorNormal)
        label:setDimensions(12 / scale, 20 / scale)
        label:setContentSize(12 / scale, 20 / scale)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        local button = gk.ZoomButton.new(label)
        button:setScale(scale, scale)
        self.displayInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x, y - 1)
        button:onClicked(function()
            gk.event:post("unfoldRootLayout", content)
        end)
        button.noneMouseMoveEffect = true
        local button1 = button

        local label = gk.create_label("  " .. (displayName and displayName or content), fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        label:setDimensions(contentSize.width - x / scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        gk.set_label_color(label, gk.theme.config.fontColorNormal)
        local button = gk.ZoomButton.new(label)
        button:setScale(scale)
        self.displayInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x, y)
        button:onClicked(function()
            gk.log("post changeRootLayout")
            gk.event:post("changeRootLayout", content)
        end)

        button1:setTag(0)
        button:setTag(0)
        self.cachedOthers[content] = { button1 = button1, button2 = button }
    end
end

function panel:displayOthers(key, layer, displayName)
    local size = self:getContentSize()
    local topY = size.height - marginTop

    self:createButtonOthers(key, leftX + stepX * layer, topY - stepY * self.domDepth, displayName)
    self.domDepth = self.domDepth + 1
end

function panel:createButtonGroup(content, x, y, displayName, domItem)
    local label = gk.create_label("❑", fontName, fontSize + 5, cc.c3b(180, 120, 75))
    label:setDimensions(12 / scale, 20 / scale)
    label:setContentSize(12 / scale, 20 / scale)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    local button = gk.ZoomButton.new(label)
    button:setScale(scale, scale)
    self.displayInfoNode:addChild(button)
    button:setAnchorPoint(0, 0.5)
    button:setPosition(x, y - 1)
    button:onClicked(function()
        domItem._fold = not domItem._fold
        self.foldDomDepth = self.domDepth
        gk.event:post("displayDomTree", true, true)
        cc.UserDefault:getInstance():setBoolForKey("gkdom_" .. content, domItem._fold)
        cc.UserDefault:getInstance():flush()
    end)
    button.noneMouseMoveEffect = true

    local label = gk.create_label("  " .. (displayName and displayName or content), fontName, fontSize)
    local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
    label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
    label:setDimensions(contentSize.width - x / scale, contentSize.height)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    gk.set_label_color(label, cc.c3b(180, 120, 75))
    local button = gk.ZoomButton.new(label)
    button:setScale(scale)
    self.displayInfoNode:addChild(button)
    button:setAnchorPoint(0, 0.5)
    button:setPosition(x, y)
    button:onClicked(function()
        domItem._fold = not domItem._fold
        self.foldDomDepth = self.domDepth
        gk.event:post("displayDomTree", true, true)
        cc.UserDefault:getInstance():setBoolForKey("gkdom_" .. content, domItem._fold)
        cc.UserDefault:getInstance():flush()
    end)
    return button
end

function panel:displayGroup(key, layer, displayName, domItem)
    local size = self:getContentSize()
    local topY = size.height - marginTop

    self:createButtonGroup(key, leftX + stepX * layer, topY - stepY * self.domDepth, key or displayName, domItem)
    self.domDepth = self.domDepth + 1
end

function panel:createTitle(content, x, y, type, layerDepth)
    local string = type == "Dialog" and string.format("[%s]", content) or content
    for i = 0, layerDepth do
        string = " " .. string
    end
    local label = gk.create_label(string, fontName, fontSize)
    local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
    label:setDimensions(contentSize.width - x / scale, contentSize.height)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    if type == "Title" then
        gk.set_label_color(label, cc.c3b(180, 120, 75))
    else
        gk.set_label_color(label, cc.c3b(0x99, 0xcc, 0x00))
    end
    label:setScale(scale)
    self.displayInfoNode:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setPosition(x, y)
    label:setTag(1)
    gk.util:addMouseMoveEffect(label)
    return label
end

function panel:displaySceneStack(rootLayer)
    self:undisplayNode()
    self.domDepth = 0
    local layerDepth = 0
    local size = self:getContentSize()
    local topY = size.height - marginTop
    self:createTitle("************ SceneStack ************", leftX, topY - stepY * self.domDepth, "Title", layerDepth)
    self.domDepth = self.domDepth + 1
    for i = gk.SceneManager.sceneStack.first, gk.SceneManager.sceneStack.last do
        local s = gk.SceneManager.sceneStack[i]
        local st = s.__sceneType or "unknown SceneType"
        self:createTitle(st, leftX, topY - stepY * self.domDepth, "Layer", layerDepth)
        self.domDepth = self.domDepth + 1
        if s.layer then
            self:displayDialogStack(s.layer, layerDepth + 1)
        end
    end
    self.domDepth = self.domDepth + 1
end

function panel:displayDialogStack(layer, layerDepth)
    local size = self:getContentSize()
    local topY = size.height - marginTop
    if layer.dialogsStack then
        for i = 1, #layer.dialogsStack do
            local d = layer.dialogsStack[i]
            self:createTitle(d.__dialogType or "unknown DialogType", leftX, topY - stepY * self.domDepth, "Dialog", layerDepth)
            self.domDepth = self.domDepth + 1
            self:displayDialogStack(d, layerDepth + 1)
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
        if self.displayInfoNode and gk.util:touchInNode(self, location) then
            if self.displayInfoNode:getContentSize().height > self:getContentSize().height then
                local scrollY = touch:getScrollY()
                local x, y = self.displayInfoNode:getPosition()
                y = y + scrollY * 10
                y = cc.clampf(y, 0, self.displayInfoNode:getContentSize().height - self:getContentSize().height)
                self.displayInfoNode:setPosition(x, y)
                self.lastDisplayingPos = cc.p(self.displayInfoNode:getPosition())

                if not self.scrollBar then
                    self.scrollBar = cc.LayerColor:create(cc.c3b(102, 102, 102), 0, 0)
                    self.scrollBar:setPositionX(self:getContentSize().width - 4)
                    self:addChild(self.scrollBar)
                end
                local barSize = self:getContentSize().height * self:getContentSize().height / self.displayInfoNode:getContentSize().height
                local scrollLen = self.displayInfoNode:getContentSize().height - self:getContentSize().height
                self.scrollBar:setContentSize(cc.size(1.5, barSize))
                -- [0, scrollLen] <--> [self:getContentSize().height-barSize, 0]
                self.scrollBar:setPositionY((1 - y / scrollLen) * (self:getContentSize().height - barSize))
                self.scrollBar:stopAllActions()
                self.scrollBar:setOpacity(255)
                self.scrollBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end
        end
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    -- swallow touches
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        if gk.util:hitTest(self, touch) then
            return true
        end
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return panel