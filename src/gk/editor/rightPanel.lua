--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午5:48
-- To change this template use File | Settings | File Templates.
--

local generator = import(".generator")
local panel = {}

function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), gk.display.rightWidth, winSize.height - gk.display.topHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(winSize.width - gk.display.rightWidth, 0)

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
end

function panel:displayNode(node)
    panel:undisplayNode()

    self.displayInfoNode = cc.Node:create()
    self:addChild(self.displayInfoNode)
    local size = self:getContentSize()

    local fontSize = 10 * 4
    local fontName = "gk/res/font/Consolas.ttf"
    local scale = 0.25
    local topY = size.height - 20
    local leftX = 10
    local leftX2 = 70
    local leftX2_1 = 80
    local leftX3 = 135
    local leftX3_0 = 110
    local leftX3_1 = 145
    local leftX4_1 = 110 + 2.5
    local leftX4_2 = 120 + 2.5
    local leftX5_1 = 155
    local leftX5_2 = 165
    local leftX5_3 = 175
    local stepY = 25
    local stepX = 40
    local inputMax = 110
    local inputWidth1 = 65
    local inputWidth2 = 45
    local inputWidth3 = 25

    local disabled = node.__rootTable and node.__rootTable.__info and node.__rootTable.__info.isWidget == 0

    local getMacroColor = function(content)
        local v = generator:parseMacroFunc(node, content)
        if not v then
            v = generator:parseCustomMacroFunc(node, content)
        end
        return v ~= nil and cc.c3b(0xFF, 0x00, 0x33) or cc.c3b(0, 0, 0)
    end

    local createLabel = function(content, x, y, isTitle)
        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        label:setScale(scale)
        label:setTextColor(isTitle and cc.c3b(152, 206, 0) or cc.c3b(189, 189, 189))
        if isTitle then
        end
        self.displayInfoNode:addChild(label)
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
        self.displayInfoNode:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:onEditEnded(function(...)
            callback(...)
        end)
        node:onInputChanged(function(_, input)
            label:setTextColor(getMacroColor(input))
        end)
        label:setTextColor(getMacroColor(content))
        node:setPosition(x, y)
        node.enabled = not disabled
        return node
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
        self.displayInfoNode:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:setPosition(x, y)
        node:onSelectChanged(function(index)
            callback(index)
            label:setTextColor(getMacroColor(items[index]))
        end)
        label:setTextColor(getMacroColor(items[index]))
        node.enabled = not disabled
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
        node:setTouchEnabled(not disabled)
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

    local isLabel = iskindof(node, "cc.Label")
    local isSprite = iskindof(node, "cc.Sprite")
    local isZoomButton = node.__info.type == "ZoomButton"
    local isLayer = iskindof(node, "cc.Layer")
    local isLayerColor = iskindof(node, "cc.LayerColor")
    local isLayerGradient = iskindof(node, "cc.LayerGradient")
    local isScrollView = iskindof(node, "cc.ScrollView")
    local isTableView = iskindof(node, "cc.TableView")

    local yIndex = 0
    --------------------------- ID   ---------------------------
    -- id
    createLabel("ID", leftX, topY)
    createInput(node.__info.id, leftX2_1, topY, inputMax, function(editBox, input)
        editBox:setInput(generator:modify(node, "id", input, "string"))
    end)
    yIndex = yIndex + 1
    -- lock
    createLabel("Lock", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.lock == 1, leftX2_1, topY - stepY * yIndex, function(selected)
        generator:modify(node, "lock", 1 - selected, "number")
    end)
    -- widget
    if node.__info.isWidget == 0 then
        local w = createLabel("Widget", leftX4_2, topY - stepY * yIndex)
        local h = createCheckBox(node.__info.isWidget == 0, leftX5_3, topY - stepY * yIndex, function(selected)
            --        generator:modify(node, "isWidget", 1 - selected, "number")
        end)
        w:setOpacity(150)
        w:setCascadeOpacityEnabled(true)
        w.enabled = false
        h:setOpacity(150)
        h:setCascadeOpacityEnabled(true)
        h:setTouchEnabled(false)
    end
    yIndex = yIndex + 1
    --------------------------- cc.Node   ---------------------------
    createLabel("Node", leftX, topY - stepY * yIndex, true)
    yIndex = yIndex + 0.6
    yIndex = yIndex + 0.2
    createLine(topY - stepY * yIndex)
    yIndex = yIndex + 0.2

    local isRoot = self.parent.scene.layer == node
    -- not root
    if not isRoot then
        -- position
        local ps = {}
        local nps = {}
        ps[1] = createLabel("Position", leftX, topY - stepY * yIndex)
        ps[2] = createLabel("X", leftX2, topY - stepY * yIndex)
        ps[3] = createInput(tostring(node.__info.x), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "x", input, "number"))
        end)
        ps[4] = createLabel("Y", leftX3, topY - stepY * yIndex)
        ps[5] = createInput(tostring(node.__info.y), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "y", input, "number"))
        end)
        yIndex = yIndex + 1
        -- ScaleXY
        createLabel("ScalePos", leftX, topY - stepY * yIndex)
        createLabel("X", leftX2, topY - stepY * yIndex)
        local scaleXs = { "0.5", "1", "$xScale", "$minScale", "$maxScale" }
        createSelectBox(scaleXs, table.indexof(scaleXs, tostring(node.__info.scaleXY.x)), leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "scaleXY.x", scaleXs[index], "string")
        end)
        createLabel("Y", leftX3, topY - stepY * yIndex)
        local scaleYs = { "0.5", "1", "$yScale", "$minScale", "$maxScale" }
        createSelectBox(scaleYs, table.indexof(scaleYs, tostring(node.__info.scaleXY.y)), leftX3_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "scaleXY.y", scaleYs[index], "string")
        end)
        yIndex = yIndex + 1
        -- NormalizedPosition
        --        nps[1] = createLabel("NPosition", leftX, topY - stepY * yIndex)
        --        nps[2] = createLabel("X", leftX2, topY - stepY * yIndex)
        --        nps[3] = createInput(tostring(node.__info.np.x), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "np.x", input, "number"))
        --        end)
        --        nps[4] = createLabel("Y", leftX3, topY - stepY * yIndex)
        --        nps[5] = createInput(tostring(node.__info.np.y), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "np.y", input, "number"))
        --        end)
        --        yIndex = yIndex + 1

        --        local setOpacitys = function(nodes, nodes2)
        --            for i = 1, #nodes do
        --                nodes[i]:setOpacity(150)
        --                nodes[i]:setCascadeOpacityEnabled(true)
        --            end
        --            for i = 1, #nodes2 do
        --                nodes2[i]:setOpacity(255)
        --            end
        --        end
        --        ps[3]:onEditBegan(function()
        --            setOpacitys(nps, ps)
        --        end)
        --        ps[5]:onEditBegan(function()
        --            setOpacitys(nps, ps)
        --        end)
        --        nps[3]:onEditBegan(function()
        --            setOpacitys(ps, nps)
        --        end)
        --        nps[5]:onEditBegan(function()
        --            setOpacitys(ps, nps)
        --        end)
    end
    -- anchor
    createLabel("Anchor", leftX, topY - stepY * yIndex)
    createLabel("X", leftX2, topY - stepY * yIndex)
    createInput(tostring(node.__info.anchor.x), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(generator:modify(node, "anchor.x", input, "number"))
    end)
    createLabel("Y", leftX3, topY - stepY * yIndex)
    createInput(tostring(node.__info.anchor.y), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        editBox:setInput(generator:modify(node, "anchor.y", input, "number"))
    end)
    yIndex = yIndex + 1
    -- ignoreAnchor
    createLabel("IgnoreAnchorPoint", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.ignoreAnchor == 0, leftX5_3, topY - stepY * yIndex, function(selected)
        generator:modify(node, "ignoreAnchor", selected, "number")
    end)
    yIndex = yIndex + 1
    if not isLabel and not isTableView then
        -- size
        createLabel("Size", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        local w = createInput(node.__info.width or string.format("%.2f", node:getContentSize().width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        local h = createInput(node.__info.height or string.format("%.2f", node:getContentSize().height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
        if isSprite then
            w:setOpacity(150)
            w:setCascadeOpacityEnabled(true)
            w.enabled = false
            h:setOpacity(150)
            h:setCascadeOpacityEnabled(true)
            h.enabled = false
        end
        if not isSprite then
            -- ScaleSize
            createLabel("ScaleSize", leftX, topY - stepY * yIndex)
            createLabel("W", leftX2, topY - stepY * yIndex)
            local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
            createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleSize.w)), leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
                generator:modify(node, "scaleSize.w", scaleWs[index], "string")
            end)
            createLabel("H", leftX3, topY - stepY * yIndex)
            local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
            createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleSize.h)), leftX3_1, topY - stepY * yIndex, inputWidth2, function(index)
                generator:modify(node, "scaleSize.h", scaleHs[index], "string")
            end)
            yIndex = yIndex + 1
        end
    end
    if not isScrollView then
        -- scale
        createLabel("Scale", leftX, topY - stepY * yIndex)
        createLabel("X", leftX2, topY - stepY * yIndex)
        createInput(tostring(node.__info.scaleX), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleX", input, "number"))
        end)
        createLabel("Y", leftX3, topY - stepY * yIndex)
        createInput(tostring(node.__info.scaleY), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleY", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    if (isLabel or isSprite) and not isLayerColor then
        -- color
        createLabel("Color3B", leftX, topY - stepY * yIndex)
        createLabel("R", leftX2, topY - stepY * yIndex)
        createInput(tostring(node.__info.color.r), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.r", input, "number"))
        end)
        createLabel("G", leftX4_1, topY - stepY * yIndex)
        createInput(tostring(node.__info.color.g), leftX4_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.g", input, "number"))
        end)
        createLabel("B", leftX5_1, topY - stepY * yIndex)
        createInput(tostring(node.__info.color.b), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.b", input, "number"))
        end)
        yIndex = yIndex + 1
    end

    if not isScrollView then
        -- rotation
        createLabel("Rotation", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.rotation), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "rotation", input, "number"))
        end)
        -- opacity
        createLabel("Opacity", leftX4_2, topY - stepY * yIndex)
        createInput(tostring(node.__info.opacity), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "opacity", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    -- localZOrder
    createLabel("ZOrder", leftX, topY - stepY * yIndex)
    createInput(tostring(node.__info.localZOrder), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator:modify(node, "localZOrder", input, "number"))
    end)
    -- visible
    createLabel("Visible", leftX4_2, topY - stepY * yIndex)
    createCheckBox(node.__info.visible == 0, leftX5_3, topY - stepY * yIndex, function(selected)
        generator:modify(node, "visible", selected, "number")
    end)
    yIndex = yIndex + 1

    --------------------------- cc.LayerColor   ---------------------------
    if isLayerColor then
        createLabel(isLayerGradient and "LayerGradient" or "LayerColor", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2

        if not isLayerGradient then
            -- color
            createLabel("Color4B", leftX, topY - stepY * yIndex)
            createLabel("R", leftX2, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.r), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.r", input, "number"))
            end)
            createLabel("G", leftX4_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.g), leftX4_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.g", input, "number"))
            end)
            createLabel("B", leftX5_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.b), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.b", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("A", leftX2, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.a), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.a", input, "number"))
            end)
            yIndex = yIndex + 1
        end

        if isLayerGradient then
            -- startColor
            createLabel("StartColor", leftX, topY - stepY * yIndex)
            createLabel("R", leftX2, topY - stepY * yIndex)
            createInput(tostring(node.__info.startColor.r), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.r", input, "number"))
            end)
            createLabel("G", leftX4_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.startColor.g), leftX4_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.g", input, "number"))
            end)
            createLabel("B", leftX5_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.startColor.b), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.b", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("StartOpacity", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.startOpacity), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "startOpacity", input, "number"))
            end)
            yIndex = yIndex + 1
            -- endColor4B
            createLabel("EndColor", leftX, topY - stepY * yIndex)
            createLabel("R", leftX2, topY - stepY * yIndex)
            createInput(tostring(node.__info.endColor.r), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.r", input, "number"))
            end)
            createLabel("G", leftX4_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.endColor.g), leftX4_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.g", input, "number"))
            end)
            createLabel("B", leftX5_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.endColor.b), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.b", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("EndOpacity", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.endOpacity), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "endOpacity", input, "number"))
            end)
            yIndex = yIndex + 1
            -- Vector
            createLabel("Vector", leftX, topY - stepY * yIndex)
            createLabel("X", leftX2, topY - stepY * yIndex)
            createInput(tostring(node.__info.vector.x), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
                editBox:setInput(generator:modify(node, "vector.x", input, "number"))
            end)
            createLabel("Y", leftX3, topY - stepY * yIndex)
            createInput(tostring(node.__info.vector.y), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
                editBox:setInput(generator:modify(node, "vector.y", input, "number"))
            end)
            yIndex = yIndex + 1
            -- isCompressedInterpolation
            createLabel("IsCompressedInterpolation", leftX, topY - stepY * yIndex)
            createCheckBox(node.__info.isCompressedInterpolation == 0, leftX5_3, topY - stepY * yIndex, function(selected)
                generator:modify(node, "isCompressedInterpolation", selected, "number")
            end)
            yIndex = yIndex + 1
        end
    end

    --------------------------- cc.Sprite, ZoomButton   ---------------------------
    if isSprite or isZoomButton then
        createLabel(isSprite and "Sprite" or "ZoomButton", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6

        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2

        if isZoomButton then
            -- click event
            createLabel("onClicked", leftX, topY - stepY * yIndex)
            local clicks = { "-" }
            -- search click callback format like "onXXXClicked"
            -- TODO: super class's click function
            for key, value in pairs(self.parent.scene.layer.class) do
                if type(value) == "function" and key:sub(1, 2) == "on" and key:sub(key:len() - 6, key:len()) == "Clicked" then
                    table.insert(clicks, "&" .. key)
                end
            end
            createSelectBox(clicks, table.indexof(clicks, tostring(node.__info.onClicked)), leftX2_1, topY - stepY * yIndex, inputMax, function(index)
                generator:modify(node, "onClicked", clicks[index], "string")
            end)
            yIndex = yIndex + 1
        end
        -- sprite file
        createLabel("Sprite", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.file), leftX2_1, topY - stepY * yIndex, inputMax, function(editBox, input)
            editBox:setInput(generator:modify(node, "file", input, "string"))
        end)
        yIndex = yIndex + 1
    end

    if isSprite then
        -- flippedX
        createLabel("FippedX", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.flippedX == 0, leftX2_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedX", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    if isZoomButton then
        -- zoomScale
        createLabel("ZoomScale", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.zoomScale), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator:modify(node, "zoomScale", input, "number"))
        end)
        yIndex = yIndex + 1
        -- enabled
        createLabel("Enabled", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enabled == 0, leftX2_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enabled", selected, "number")
        end)
        yIndex = yIndex + 1
    end
    --------------------------- cc.Label   ---------------------------
    if isLabel then
        createLabel("Label", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6

        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        -- string
        createLabel("String", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.string), leftX2_1, topY - stepY * yIndex, inputMax, function(editBox, input)
            editBox:setInput(generator:modify(node, "string", input, "string"))
        end)
        yIndex = yIndex + 1
        -- font file
        createLabel("FontFile", leftX, topY - stepY * yIndex)
        local lan = gk.resource:getCurrentLan()
        createInput(tostring(node.__info.fontFile[lan]), leftX2_1, topY - stepY * yIndex, inputMax, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontFile." .. lan, input, "string"))
        end)
        yIndex = yIndex + 1
        -- overflow
        createLabel("Overflow", leftX, topY - stepY * yIndex)
        local overflows = { "NONE", "CLAMP", "SHRINK", "RESIZE_HEIGHT" }
        createSelectBox(overflows, node.__info.overflow + 1, leftX2_1, topY - stepY * yIndex, inputMax, function(index)
            generator:modify(node, "overflow", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- dimensions
        createLabel("Dimensions", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(tostring(node.__info.width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(tostring(node.__info.height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- alignment
        createLabel("Alignment", leftX, topY - stepY * yIndex)
        createLabel("H", leftX2, topY - stepY * yIndex)
        local hAligns = { "LEFT", "CENTER", "RIGHT" }
        createSelectBox(hAligns, node.__info.hAlign + 1, leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "hAlign", index - 1, "number")
        end)
        createLabel("V", leftX3, topY - stepY * yIndex)
        local vAligns = { "TOP", "CENTER", "BOTTOM" }
        createSelectBox(vAligns, node.__info.vAlign + 1, leftX3_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "vAlign", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- lineHeight
        if node.__info.lineHeight then
            createLabel("LineHeight", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.lineHeight), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
                editBox:setInput(generator:modify(node, "lineHeight", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        -- font size
        createLabel("FontSize", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.fontSize), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontSize", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    --------------------------- cc.ScrollView, cc.TableView  ---------------------------
    if isScrollView then
        createLabel(isTableView and "TableView" or "ScrollView", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2

        -- viewSize
        createLabel("ViewSize", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(tostring(node.__info.viewSize.width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "viewSize.width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(tostring(node.__info.viewSize.height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "viewSize.height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- ScaleSize
        createLabel("ScaleSize", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
        createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleSize.w)), leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "scaleSize.w", scaleWs[index], "string")
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
        createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleSize.h)), leftX3_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "scaleSize.h", scaleHs[index], "string")
        end)
        yIndex = yIndex + 1
        -- Direction
        createLabel("Direction", leftX, topY - stepY * yIndex)
        local directions = { "HORIZONTAL", "VERTICAL", "BOTH" }
        createSelectBox(directions, node.__info.direction + 1, leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "direction", index - 1, "number")
        end)
        yIndex = yIndex + 1
        if isTableView then
            -- verticalFillOrder
            createLabel("FillOrder", leftX, topY - stepY * yIndex)
            local verticalFillOrders = { "TOP_DOWN", "BOTTOM_UP" }
            createSelectBox(verticalFillOrders, node.__info.verticalFillOrder + 1, leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
                generator:modify(node, "verticalFillOrder", index - 1, "number")
            end)
            yIndex = yIndex + 1
        end
        -- ClipToBD
        createLabel("ClipToBD", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.clipToBD == 0, leftX2_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "clipToBD", selected, "number")
        end)
        -- Bounceable
        createLabel("Bounceable", leftX3_0, topY - stepY * yIndex)
        createCheckBox(node.__info.bounceable == 0, leftX5_3, topY - stepY * yIndex, function(selected)
            generator:modify(node, "bounceable", selected, "number")
        end)
        yIndex = yIndex + 1
        -- touchEnabled
        createLabel("Enabled", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.touchEnabled == 0, leftX2_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "touchEnabled", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    --------------------------- cc.Layer   ---------------------------
    if isLayer and not isLayerColor and not isScrollView then
        createLabel("Layer", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
    end

    local isgkLayer = iskindof(node.class, "Layer")
    local isDialog = iskindof(node.class, "Dialog")
    if isgkLayer or isDialog then
        -- swallowTouchEvent
        createLabel("SwallowTouchEvent", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.swallowTouchEvent == 0, leftX5_3, topY - stepY * yIndex, function(selected)
            generator:modify(node, "swallowTouchEvent", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableKeyPad
        local w = createLabel("EnableKeyPad", leftX, topY - stepY * yIndex)
        local h = createCheckBox(node.__info.enableKeyPad == 0, leftX5_3, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableKeyPad", selected, "number")
        end)
        yIndex = yIndex + 1
        -- popOnBack
        createLabel("PopOnBack", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.popOnBack == 0, leftX5_3, topY - stepY * yIndex, function(selected)
            generator:modify(node, "popOnBack", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    local isClippingNode = iskindof(node, "cc.ClippingNode")
    if isClippingNode then
        createLabel("ClippingNode", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        --        -- stencil
        --        createLabel("StencilID", leftX, topY - stepY * yIndex)
        --        createInput(tostring(node.__info.stencil), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "stencil", input, "string"))
        --        end)
        --        yIndex = yIndex + 1
        -- alphaThreshold
        createLabel("AlphaThreshold", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.alphaThreshold), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "alphaThreshold", input, "number"))
        end)
        yIndex = yIndex + 1
        -- inverted
        createLabel("Inverted", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.inverted == 0, leftX5_3, topY - stepY * yIndex, function(selected)
            generator:modify(node, "inverted", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    self.displayInfoNode:setContentSize(cc.size(gk.display.height(), stepY * yIndex + gk.display.bottomHeight + 5))
    if disabled then
        self.displayInfoNode:setOpacity(150)
        gk.util:setRecursiveCascadeOpacityEnabled(self.displayInfoNode, true)
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