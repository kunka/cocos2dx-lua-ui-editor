--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午5:59
-- To change this template use File | Settings | File Templates.
--

local panel = {}

function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(gk.theme.config.backgroundColor, winSize.width, gk.display.topHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(0, winSize.height - gk.display.topHeight)

    if self.displayInfoNode then
        self.displayInfoNode:removeFromParent()
    end
    self.displayInfoNode = cc.Node:create()
    --    self:addChild(self.displayInfoNode)

    local size = self:getContentSize()
    -- winSize
    local fontSize = 10 * 4
    local fontName = gk.theme.font_fnt
    local scale = 0.25
    local topY = size.height - 25
    local leftX = 15
    local inputWidth1 = 120
    local leftX2 = gk.display.leftWidth - inputWidth1 - leftX
    local leftX_input_2 = 100
    local inputWidth2 = gk.display.rightWidth - leftX - leftX_input_2
    --    local stepX = 64 --51
    local stepX = 10
    local stepY = 25
    local leftX_widget = 15 --10
    local createLabel = function(content, x, y)
        local label = gk.create_label(content, fontName, fontSize)
        label:setScale(scale)
        gk.set_label_color(label, gk.theme.config.fontColorNormal)
        self:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback, lines)
        lines = lines or 1
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale * lines))
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
        local label = gk.create_label(content, gk.theme.font_ttf, fontSize)
        gk.set_label_color(label, cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
        self:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 1)
        node:onEditEnded(function(...)
            callback(...)
        end)
        node:setPosition(x, y + 16 / 2)
        return node
    end

    local size = self:getContentSize()
    local createLine = function(x)
        gk.util:drawLineOnNode(self, cc.p(x, 10), cc.p(x, size.height - 10), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1))
    end
    local createSelectBox = function(items, index, x, y, width, callback)
        local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
        local label = gk.create_label("", fontName, fontSize)
        gk.set_label_color(label, cc.c3b(0, 0, 0))
        node:setMarginLeft(5)
        node:setMarginRight(22)
        node:setMarginTop(4)
        node:setDisplayLabel(label)
        node:onCreatePopupLabel(function()
            local label = gk.create_label("", fontName, fontSize)
            gk.set_label_color(label, cc.c3b(0, 0, 0))
            return label
        end)
        self:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:setPosition(x, y)
        node:onSelectChanged(callback)
        return node
    end

    createLine(gk.display.leftWidth)
    createLine(gk.display.leftWidth + gk.display:accuWinSize().width + gk.display.extWidth)

    local yIndex = 0
    -- device size
    createLabel("ScreenSize", leftX, topY - yIndex * stepY)
    local items = {}
    local descs = {}
    for _, s in ipairs(gk.display.deviceSizes) do
        table.insert(items, s.size)
        table.insert(descs, s.desc)
    end
    --    local items = gk.display.deviceSizesDesc
    --    local sizeItems = gk.display.deviceSizes
    local index = cc.UserDefault:getInstance():getIntegerForKey("gk_deviceSizeIndex")
    local node = createSelectBox(descs, index, leftX2, topY - yIndex * stepY, inputWidth1, function(index)
        local size = items[index]
        cc.UserDefault:getInstance():setIntegerForKey("gk_deviceSizeIndex", index)
        cc.UserDefault:getInstance():flush()
        -- set editor win size
        size.width = size.width + gk.display.leftWidth + gk.display.rightWidth
        size.height = size.height + gk.display.topHeight + gk.display.bottomHeight
        local director = cc.Director:getInstance()
        local view = director:getOpenGLView()
        view:setFrameSize(size.width, size.height)
        view:setDesignResolutionSize(size.width, size.height, 0)
        gk.log("set OpenGLView size(%.1f,%.1f)", size.width, winSize.height)
        gk.util:restartGame(gk.mode)
    end)
    --    node.enabled = false
    --    node:setOpacity(150)
    --    node:setCascadeOpacityEnabled(true)
    yIndex = yIndex + 1

    -- ResolutionPolicy
    createLabel("ResolutionPolicy", leftX, topY - yIndex * stepY)
    local items = gk.display.supportResolutionPolicyDesc
    local values = gk.display.supportResolutionPolicy
    local index = cc.UserDefault:getInstance():getIntegerForKey("gk_resolutionPolicy", 1)
    local node = createSelectBox(items, index, leftX2, topY - yIndex * stepY, inputWidth1, function(index)
        local value = gk.display.supportResolutionPolicy[index]
        cc.UserDefault:getInstance():setIntegerForKey("gk_resolutionPolicy", index)
        cc.UserDefault:getInstance():flush()
        gk.util:restartGame(gk.mode)
    end)
    yIndex = yIndex + 1

    -- Language
    createLabel("Languages", leftX, topY - yIndex * stepY)
    local items = gk.resource.lans
    local index = table.indexof(gk.resource.lans, gk.resource:getCurrentLan())
    local node = createSelectBox(items, index, leftX2, topY - yIndex * stepY, inputWidth1, function(index)
        local lan = items[index]
        gk.util:registerOnRestartGameCallback(function()
            gk.resource:setCurrentLan(lan)
        end)
        gk.util:restartGame(gk.mode)
    end)
    yIndex = yIndex + 1

    -- right
    local rightX = gk.display.leftWidth + gk.display:accuWinSize().width + leftX + gk.display.extWidth
    local rightX2 = size.width - inputWidth1 - leftX
    local rightX3 = rightX + 100 - leftX
    local yIndex = 0
    -- bg
    createLabel("Theme", rightX, topY - yIndex * stepY)
    local themes = table.keys(gk.theme.configs)
    local index = table.indexof(themes, gk.theme.themeName)
    local node = createSelectBox(themes, index, rightX3, topY - yIndex * stepY, inputWidth2, function(index)
        local themeName = themes[index]
        gk.theme:setTheme(themeName)
    end)
    yIndex = yIndex + 1
    -- string
    createLabel("Query String", rightX, topY - stepY * (yIndex + 0.2))
    local editBox = createInput("", rightX3, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(input)
    end, 1.6)
    editBox:setAutoCompleteFunc(gk.resource.autoCompleteFunc)
    editBox:onCreatePopupLabel(function()
        return gk.create_label("", gk.theme.font_sys, fontSize)
    end)

    -- content node
    local iconScale = 0.32
    local width = leftX_widget
    -- clipping rect
    local clippingRect = cc.rect(gk.display.leftWidth, 0, gk.display:accuWinSize().width + gk.display.extWidth, self:getContentSize().height)
    self.clippingNode = cc.ClippingRectangleNode:create(clippingRect)
    self:addChild(self.clippingNode)

    -- cc nodes and gk nodes and ex nodes
    self.widgets = {}
    if gk.resource.isDisplayInternalNodes then
        self.widgets = clone(gk.editorConfig.supportNodes)
    else
        for _, node in ipairs(gk.editorConfig.supportNodes) do
            if not node._internal then
                table.insert(self.widgets, node)
            end
        end
    end
    for _, node in ipairs(self.widgets) do
        if node._type:find("%.") == nil then
            node._isGKNode = true
        end
    end
    -- self pre defined widget
    local keys = table.keys(gk.resource.genNodes)
    local total = clone(gk.resource.genNodes)
    if gk.resource.isDisplayInternalNodes then
        table.merge(total, gk.resource.genNodesInternal)
    end
    local keys = table.keys(total)
    table.sort(keys, function(k1, k2) return k1 < k2 end)
    for _, key in ipairs(keys) do
        local nodeInfo = gk.resource:getGenNode(key)
        if nodeInfo.isWidget then
            table.insert(self.widgets, { _type = nodeInfo.path, cname = nodeInfo.cname, displayName = nodeInfo.genSrcPath .. key, _isWidget = 0 })
        end
    end

    local winSize = cc.Director:getInstance():getWinSize()
    for i = 1, #self.widgets do
        local typeInfo = self.widgets[i]
        local node = gk.create_sprite(typeInfo.file or "gk/res/texture/icon_cocos.png")
        gk.util:addMouseMoveEffect(node)
        node._type = typeInfo._type
        node:setScale(iconScale)
        self.displayInfoNode:addChild(node)

        local label = gk.create_label(typeInfo._isWidget and typeInfo.cname or typeInfo._type, fontName, fontSize)
        label:setScale(scale)
        gk.set_label_color(label, gk.theme.config.fontColorNormal)
        self.displayInfoNode:addChild(label)
        label:setAnchorPoint(0.5, 0.5)
        --        label:setPosition(originPos.x, originPos.y - 40)
        if typeInfo._isWidget then
            label:setColor(cc.c3b(0xEE, 0x99, 0xEE))
        elseif typeInfo._isGKNode then
            label:setColor(cc.c3b(0x33, 0x66, 0xEE))
        end
        local itemWidth = label:getContentSize().width * scale
        itemWidth = math.ceil(itemWidth / 10) * 10
        width = width + itemWidth + stepX
        node:setPosition(cc.p(width - stepX / 2 - itemWidth / 2, size.height / 2 + 8))
        label:setPosition(cc.p(width - stepX / 2 - itemWidth / 2, 8 + 8))
        --        gk.util:drawNodeBounds(label)
        local originPos = cc.p(width - stepX / 2 - itemWidth / 2, size.height / 2 + 8)
        if i < #self.widgets then
            gk.util:drawSegmentOnNode(self.displayInfoNode, cc.p(width, size.height - 25), cc.p(width, 15), 5, cc.c4f(0x99 / 255, 0xcc / 255, 0 / 255,
                0.2), 1000 + i)
        end
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            self._touchBegainLocation = cc.p(location)
            local p0 = self:convertToNodeSpace(location)
            if not cc.rectContainsPoint(clippingRect, p0) then
                return false
            end
            local s = node:getContentSize()
            local rect = { x = 0, y = 0, width = s.width, height = s.height }
            local p = node:convertToNodeSpace(location)
            self._containerNode = nil
            if cc.rectContainsPoint(rect, p) then
                local _type = typeInfo._type
                gk.log("choose node %s", _type)
                gk.event:post("undisplayNode")
                gk.event:post("displayNode", node)
                return true
            else
                return false
            end
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local p = self:convertToNodeSpace(location)
            local pos = cc.p(originPos.x + self.displayInfoNode:getPositionX(), originPos.y)
            if not self.draggingNode then
                local node = gk.create_sprite(typeInfo.file or "gk/res/texture/icon_cocos.png")
                node:setPosition(pos)
                node:setScale(iconScale) -- gk.display:minScale())
                self:addChild(node)
                self.draggingNode = node
                cc.Director:getInstance():setDepthTest(true)
                node:setPositionZ(1)
            end
            self.draggingNode:setPosition(cc.pAdd(pos, cc.pSub(p, self:convertToNodeSpace(self._touchBegainLocation))))

            -- find dest container
            if self.parent.sortedChildren == nil then
                self.parent:sortChildrenOfSceneGraphPriority(self.parent.scene.layer, true)
            end
            local children = self.parent.sortedChildren
            for i = #children, 1, -1 do
                local node = children[i]
                local canBeContainer = false
                repeat
                    if not node or (node.__rootTable and node.__rootTable ~= self.parent.scene.layer) then
                        -- widget
                        break
                    end
                    if node.__info then
                        if node.__info._lock == 0 then -- or node.__info._isWidget then
                        break
                        end
                    end
                    if gk.util:isAncestorsType(node, "cc.TableView") then
                        break
                    end
                    canBeContainer = true
                until true
                if canBeContainer then
                    local s = node:getContentSize()
                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    local p = node:convertToNodeSpace(location)
                    if gk.util:isAncestorsVisible(node) and cc.rectContainsPoint(rect, p) then
                        if self._containerNode ~= node then
                            self._containerNode = node
                            local _type = node.__cname and node.__cname or tolua.type(node)
                            gk.log("find container node %s, id = %s", _type, node.__info._id)
                            gk.event:post("displayNode", node)
                        end
                        break
                    end
                end
            end
        end, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(function(touch, event)
            if self._containerNode then
                local s = self._containerNode:getContentSize()
                local rect = { x = 0, y = 0, width = s.width, height = s.height }
                local location = touch:getLocation()
                local p = self:convertToNodeSpace(location)
                p = cc.pAdd(cc.p(originPos.x + self.displayInfoNode:getPositionX(), originPos.y), cc.pSub(p, self:convertToNodeSpace(self._touchBegainLocation)))
                p = self._containerNode:convertToNodeSpace(self:convertToWorldSpace(p))
                if cc.rectContainsPoint(rect, p) then
                    local node
                    local widget = typeInfo
                    local info = clone(widget)
                    local _type = widget._type
                    node = gk.generator:createNode(info, nil, self.parent.scene.layer)
                    if node.__info._isWidget then
                        node.__info._lock = 0
                        node.__info._fold = true
                    end
                    if node then
                        self.parent:rescaleNode(node, self._containerNode)
                        if _type == "cc.Layer" then
                            node.__info.x, node.__info.y = 0, 0
                        else
                            local x = math.round(gk.generator:parseXRvs(node, p.x, node.__info.scaleXY.x))
                            local y = math.round(gk.generator:parseYRvs(node, p.y, node.__info.scaleXY.y))
                            node.__info.x, node.__info.y = x, y
                        end
                        self._containerNode:addChild(node)
                        gk.log("add new node %s, id = %s, pos = %.1f,%.1f", _type, node.__info._id, p.x, p.y)
                        gk.event:post("executeCmd", "ADD", {
                            id = node.__info._id,
                            panel = self.parent,
                        })
                        gk.event:post("postSync")
                        gk.event:post("displayNode", node)
                        gk.event:post("displayDomTree")
                    else
                        gk.log("cannot create node %s", _type)
                    end
                else
                    gk.log("cancel put node, not inside of container node")
                end
            else
                gk.log("cancel put node, no container node")
            end
            if self.draggingNode then
                self.draggingNode:removeFromParent()
                self.draggingNode = nil
                cc.Director:getInstance():setDepthTest(false)
            end
            self.parent.sortedChildren = nil
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function(touch, event)
            if self.draggingNode then
                self.draggingNode:removeFromParent()
                self.draggingNode = nil
                cc.Director:getInstance():setDepthTest(false)
            end
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end

    width = width
    self.displayInfoNode:setContentSize(cc.size(width, self:getContentSize().height))
    self.displayInfoNode:setAnchorPoint(cc.p(0, 0))
    self.displayInfoNode:setPosition(cc.p(gk.display.leftWidth, 0))
    --    gk.util:drawNodeBounds(self.displayInfoNode)
    self.clippingNode:addChild(self.displayInfoNode)

    self:handleEvent()

    return self
end

function panel:handleEvent()
    local listener = cc.EventListenerMouse:create()
    listener:registerScriptHandler(function(touch, event)
        local location = touch:getLocationInView()
        local s = self:getContentSize()
        local rect = { x = gk.display.leftWidth, y = 0, width = gk.display:accuWinSize().width + gk.display.extWidth, height = s.height }
        local touchP = self:convertToNodeSpace(cc.p(location.x, location.y))
        if cc.rectContainsPoint(rect, touchP) then
            if self.displayInfoNode:getContentSize().width > gk.display:accuWinSize().width then
                local scrollX = touch:getScrollX()
                -- mouse cannot scroll horizontal
                local scrollY = 0
                if scrollX < 50 then
                    scrollY = touch:getScrollY()
                end
                local x, y = self.displayInfoNode:getPosition()
                x = x + scrollX * 10 + scrollY * 10
                x = cc.clampf(x, gk.display.leftWidth - (self.displayInfoNode:getContentSize().width - gk.display:accuWinSize().width), gk.display.leftWidth)
                self.displayInfoNode:setPosition(x, y)
                self.lastDisplayInfoOffset = cc.p(x, y)

                if not self.scrollBar then
                    self.scrollBar = cc.LayerColor:create(cc.c3b(102, 102, 102), 0, 0)
                    self.scrollBar:setPositionY(2)
                    self:addChild(self.scrollBar)
                end
                local barSize = gk.display:accuWinSize().width * gk.display:accuWinSize().width / self.displayInfoNode:getContentSize().width
                self.scrollBar:setContentSize(cc.size(barSize, 1.5))
                x = x - gk.display.leftWidth
                self.scrollBar:setPositionX(-x / self.displayInfoNode:getContentSize().width * gk.display:accuWinSize().width + gk.display.leftWidth)
                self.scrollBar:stopAllActions()
                self.scrollBar:setOpacity(255)
                self.scrollBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.FadeOut:create(0.5)))
            end
        end
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return panel