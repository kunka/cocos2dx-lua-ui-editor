--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午5:59
-- To change this template use File | Settings | File Templates.
--

local generator = import(".generator")
local panel = {}

function panel:create(parent)
    self.parent = parent
    local winSize = cc.Director:getInstance():getWinSize()
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width, gk.display.topHeight)
    layerColor:setPosition(0, winSize.height - gk.display.topHeight)
    self.panel = layerColor

    local size = self.panel:getContentSize()
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
        self.panel:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback)
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
        node:setScale9SpriteBg(CREATE_SCALE9_SPRITE("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
        local label = cc.Label:createWithTTF(content, fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
        self.panel:addChild(node)
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
        self.panel:addChild(node)
        node:setAnchorPoint(0, 0.5)
        node:addEventListener(function(sender, eventType)
            callback(eventType)
        end)
        return node
    end
    local size = self.panel:getContentSize()
    local createLine = function(x)
        gk.util:drawLineOnNode(self.panel, cc.p(x, 10), cc.p(x, size.height - 10), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1))
    end
    local createSelectBox = function(items, index, x, y, width, callback)
        local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
        node:setScale9SpriteBg(CREATE_SCALE9_SPRITE("gk/res/texture/edbox_bg.png", cc.rect(20, 8, 10, 5)))
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
        self.panel:addChild(node)
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
        gk.util:restartGame()
    end)
    yIndex = yIndex + 1

    -- Language
    createLabel("Lanuage", leftX, topY - yIndex * stepY)
    local items = gk.resource.lans
    local index = table.indexof(gk.resource.lans, gk.resource:getLan())
    local node = createSelectBox(items, index, leftX2, topY - yIndex * stepY, inputWidth1, function(index)
        local lan = items[index]
        gk.resource:setLan(lan)
        gk.util:restartGame()
    end)
    yIndex = yIndex + 1

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
        local originPos = cc.p(gk.display.leftWidth + leftX_widget + node:getScale() * node:getContentSize().width / 2 + stepX * (i - 1), size.height / 2)
        node:setPosition(originPos)
        self.panel:addChild(node)

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
                gk.event:post("undisplayNode")
                gk.event:post("displayNode", node)
                return true
            else
                return false
            end
        end, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(function(touch, event)
            local location = touch:getLocation()
            local p = self.panel:convertToNodeSpace(location)
            if not self.draggingNode then
                local node = CREATE_SPRITE(self.widgets[i].file)
                node:setPosition(originPos)
                node:setScale(gk.display.minScale())
                self.panel:addChild(node)
                self.draggingNode = node
            end
            self.draggingNode:setPosition(cc.pAdd(originPos, cc.pSub(p, self.panel:convertToNodeSpace(self._touchBegainLocation))))

            -- find dest container
            if self.parent.sortedChildren == nil then
                self.parent:sortChildrenOfSceneGraphPriority(self.parent.scene.layer, true)
            end
            local children = self.parent.sortedChildren
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
                local s = self.parent.scene.layer:getContentSize()
                local rect = { x = 0, y = 0, width = s.width, height = s.height }
                --            local p = self.scene.layer:convertTouchToNodeSpace(touch)
                local location = touch:getLocation()
                local p = self.panel:convertToNodeSpace(location)
                local p = cc.pAdd(originPos, cc.pSub(p, self.panel:convertToNodeSpace(self._touchBegainLocation)))
                p = self._containerNode:convertToNodeSpace(self.panel:convertToWorldSpace(p))
                --            local p = self.scene.layer:convertToNodeSpace(cc.pSub(location, self._touchBegainLocation))
                if cc.rectContainsPoint(rect, p) then
                    local type = self.widgets[i].type
                    local info = clone(self.widgets[i])
                    local node = generator.createNode(info, nil, self.parent.scene.layer)
                    if node then
                        if tolua.type(node) ~= "cc.Layer" then
                            local sx, sy = gk.util.getGlobalScale(self._containerNode)
                            if sx ~= 1 or sy ~= 1 then
                                node.__info.scaleX, node.__info.scaleY = 1, 1
                            else
                                node.__info.scaleX, node.__info.scaleY = "$minScale", "$minScale"
                                node.__info.scaleXY = { x = "$xScale", y = "$yScale" }
                            end
                        else
                            --                            gk.util:drawNodeRect(node, cc.c4f(1, 200 / 255, 0, 1), -2)
                        end
                        local scaleX = generator.parseValue(node.__info.scaleXY.x)
                        local scaleY = generator.parseValue(node.__info.scaleXY.y)
                        node.__info.x, node.__info.y = math.round(p.x / scaleX), math.round(p.y / scaleY)
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

    return layerColor
end

return panel