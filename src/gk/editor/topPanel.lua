--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午5:59
-- To change this template use File | Settings | File Templates.
--

local generator = import(".generator")
local panel = {}

function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width, gk.display.topHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(0, winSize.height - gk.display.topHeight)

    local size = self:getContentSize()
    -- winSize
    local fontSize = 10 * 4
    local fontName = "gk/res/font/Consolas.ttf"
    local scale = 0.25
    local topY = size.height - 15 - 15
    local leftX = 10
    local leftX2 = 50
    local stepX = 50
    local stepY = 25
    local leftX_widget = 10
    local inputWidth1 = 80
    local createLabel = function(content, x, y)
        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        label:setScale(scale)
        label:setTextColor(cc.c3b(189, 189, 189))
        self:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback)
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
        local label = cc.Label:createWithTTF(content, fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
        self:addChild(node)
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
        self:addChild(node)
        node:setAnchorPoint(0, 0.5)
        node:addEventListener(function(sender, eventType)
            callback(eventType)
        end)
        return node
    end
    local size = self:getContentSize()
    local createLine = function(x)
        gk.util:drawLineOnNode(self, cc.p(x, 10), cc.p(x, size.height - 10), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1))
    end
    local createSelectBox = function(items, index, x, y, width, callback)
        local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
        local label = cc.Label:createWithTTF("", fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setDisplayLabel(label)
        node:onCreatePopupLabel(function()
            local label = cc.Label:createWithTTF("", fontName, fontSize)
            label:setTextColor(cc.c3b(0, 0, 0))
            return label
        end)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
        self:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:setPosition(x, y)
        node:onSelectChanged(callback)
        return node
    end

    createLine(gk.display.leftWidth)
    createLine(gk.display.leftWidth + gk.display.winSize().width)

    local yIndex = 0
    -- device size
    createLabel("Device", leftX, topY - yIndex * stepY)
    local items = gk.display.deviceSizesDesc
    local sizeItems = gk.display.deviceSizes
    local index = cc.UserDefault:getInstance():getIntegerForKey("deviceSizeIndex")
    local node = createSelectBox(items, index, leftX2, topY - yIndex * stepY, inputWidth1, function(index)
        local size = sizeItems[index]
        cc.UserDefault:getInstance():setIntegerForKey("deviceSizeIndex", index)
        cc.UserDefault:getInstance():flush()
        -- set editor win size
        size.width = size.width + gk.display.leftWidth + gk.display.rightWidth
        size.height = size.height + gk.display.topHeight + gk.display.bottomHeight
        local director = cc.Director:getInstance()
        local view = director:getOpenGLView()
        view:setFrameSize(size.width, size.height)
        gk.log("set OpenGLView size(%.1f,%.1f)", size.width, winSize.height)
        gk.util:restartGame(1)
    end)
    yIndex = yIndex + 1

    -- Language
    createLabel("Lans", leftX, topY - yIndex * stepY)
    local items = gk.resource.lans
    local index = table.indexof(gk.resource.lans, gk.resource:getCurrentLan())
    local node = createSelectBox(items, index, leftX2, topY - yIndex * stepY, inputWidth1, function(index)
        local lan = items[index]
        gk.resource:setCurrentLan(lan)
        gk.util:restartGame(1)
    end)
    yIndex = yIndex + 1

    -- right
    local rightX = gk.display.leftWidth + gk.display.winSize().width + leftX
    local rightX2 = rightX + leftX2 - leftX + 30
    local yIndex = 0
    -- bg
    createLabel("Background", rightX, topY - yIndex * stepY)
    local items = { "BLACK", "WHITE", "GRAY" }
    local colors = { cc.c4f(0, 0, 0, 1), cc.c4f(1, 1, 1, 1), cc.c4f(0.66, 0.66, 0.66, 1) }
    local index = cc.UserDefault:getInstance():getIntegerForKey("colorIndex", 1)
    local node = createSelectBox(items, index, rightX2, topY - yIndex * stepY, inputWidth1, function(index)
        local color = colors[index]
        local root = gk.util:getRootNode(self)
        gk.util:drawNodeBg(root, color, -89)
        cc.UserDefault:getInstance():setIntegerForKey("colorIndex", index)
        cc.UserDefault:getInstance():flush()
    end)
    yIndex = yIndex + 1
    local color = colors[index]
    self:runAction(cc.CallFunc:create(function()
        local root = gk.util:getRootNode(self)
        if root then
            gk.util:drawNodeBg(root, color, -89)
        end
    end))

    -- widgets
    self.widgets = {
        { type = "cc.Node", },
        { type = "cc.Sprite", file = "?", },
        { type = "cc.Label", },
        { type = "ZoomButton", file = "?", },
        { type = "cc.Layer", },
        { type = "cc.LayerColor", },
        { type = "cc.ScrollView" },
        { type = "cc.TableView" },
    }
    -- self define widget
    local keys = table.keys(gk.resource.genNodes)
    table.sort(keys, function(k1, k2) return k1 < k2 end)
    for _, key in ipairs(keys) do
        local nodeInfo = gk.resource.genNodes[key]
        if nodeInfo.clazz.isWidget then
            table.insert(self.widgets, { type = nodeInfo.clazz.__cname, isWidget = 1 })
        end
    end

    local winSize = cc.Director:getInstance():getWinSize()
    for i = 1, #self.widgets do
        local node = gk.create_sprite(self.widgets[i].file)
        node.type = self.widgets[i].type
        node:setScale(0.32)
        local originPos = cc.p(gk.display.leftWidth + leftX_widget + node:getScale() * node:getContentSize().width / 2 + stepX * (i - 1), size.height / 2)
        originPos.y = originPos.y + 8
        node:setPosition(originPos)
        self:addChild(node)

        local names = string.split(self.widgets[i].type, ".")
        local label = cc.Label:createWithSystemFont(names[#names], fontName, 8 * 4)
        label:setScale(scale)
        label:setTextColor(cc.c3b(189, 189, 189))
        self:addChild(label)
        label:setAnchorPoint(0.5, 0.5)
        label:setPosition(originPos.x, originPos.y - 35)

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            self._touchBegainLocation = cc.p(location)
            local s = node:getContentSize()
            local rect = { x = 0, y = 0, width = s.width, height = s.height }
            local p = node:convertToNodeSpace(location)
            self._containerNode = nil
            if cc.rectContainsPoint(rect, p) then
                local type = self.widgets[i].type
                gk.log("choose node %s", type)
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
            if not self.draggingNode then
                local node = gk.create_sprite(self.widgets[i].file)
                node:setPosition(originPos)
                node:setScale(gk.display.minScale())
                self:addChild(node)
                self.draggingNode = node
            end
            self.draggingNode:setPosition(cc.pAdd(originPos, cc.pSub(p, self:convertToNodeSpace(self._touchBegainLocation))))

            -- find dest container
            if self.parent.sortedChildren == nil then
                self.parent:sortChildrenOfSceneGraphPriority(self.parent.scene.layer, true)
            end
            local children = self.parent.sortedChildren
            for i = #children, 1, -1 do
                local node = children[i]
                if node and (not (node.__info and node.__info.lock == 1)) and (not (node.__info and node.__info.isWidget == 1)) then
                    local s = node:getContentSize()
                    local rect = { x = 0, y = 0, width = s.width, height = s.height }
                    local p = node:convertToNodeSpace(location)
                    if gk.util:isGlobalVisible(node) and cc.rectContainsPoint(rect, p) then
                        local type = node.__cname and node.__cname or tolua.type(node)
                        if self._containerNode ~= node then
                            self._containerNode = node
                            gk.log("find container node %s, id = %s", type, node.__info.id)
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
                local p = cc.pAdd(originPos, cc.pSub(p, self:convertToNodeSpace(self._touchBegainLocation)))
                p = self._containerNode:convertToNodeSpace(self:convertToWorldSpace(p))
                if cc.rectContainsPoint(rect, p) then
                    local node
                    local widget = self.widgets[i]
                    local info = clone(widget)
                    local type = widget.type
                    node = generator:createNode(info, nil, self.parent.scene.layer)
                    if node then
                        self.parent:rescaleNode(node, self._containerNode)
                        local scaleX = generator:parseValue("scaleX", node, node.__info.scaleXY.x)
                        local scaleY = generator:parseValue("scaleY", node, node.__info.scaleXY.y)
                        if type == "cc.Layer" then
                            node.__info.x, node.__info.y = 0, 0
                        else
                            node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
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
                    gk.log("cancel put node, not inside of container node")
                end
            else
                gk.log("cancel put node, no container node")
            end
            if self.draggingNode then
                self.draggingNode:removeFromParent()
                self.draggingNode = nil
            end
            self.parent.sortedChildren = nil
        end, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(function(touch, event)
            if self.draggingNode then
                self.draggingNode:removeFromParent()
                self.draggingNode = nil
            end
        end, cc.Handler.EVENT_TOUCH_CANCELLED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end

    return self
end

return panel