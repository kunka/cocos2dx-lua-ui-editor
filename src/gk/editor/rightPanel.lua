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
    local topY = size.height - 12
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
        node:setPosition(x, y)
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
        node:onSelectChanged(callback)
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
        editBox:setInput(generator:modify(node, "id", input, "string"))
    end)
    yIndex = yIndex + 1
    local isRoot = gk.util:getRootNode(node) == node
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
        createLabel("ScaleXY", leftX, topY - stepY * yIndex)
        createLabel("X", leftX2, topY - stepY * yIndex)
        local scaleXs = { "1", "$xScale", "$minScale", "$maxScale" }
        createSelectBox(scaleXs, table.indexof(scaleXs, tostring(node.__info.scaleXY.x)), leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "scaleXY.x", scaleXs[index], "string")
        end)
        createLabel("Y", leftX3, topY - stepY * yIndex)
        local scaleYs = { "1", "$yScale", "$minScale", "$maxScale" }
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
    if not iskindof(node, "cc.Layer") then
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
    end
    if not iskindof(node, "cc.Label") then
        -- size
        createLabel("Size", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(node.__info.width or string.format("%.2f", node:getContentSize().width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(node.__info.height or string.format("%.2f", node:getContentSize().height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    -- color
    createLabel("Color", leftX, topY - stepY * yIndex)
    createLabel("R", leftX2, topY - stepY * yIndex)
    createInput(string.format("%d", node.__info.color.r), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator:modify(node, "color.r", input, "number"))
    end)
    createLabel("G", leftX4_1, topY - stepY * yIndex)
    createInput(string.format("%d", node.__info.color.g), leftX4_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator:modify(node, "color.g", input, "number"))
    end)
    createLabel("B", leftX5_1, topY - stepY * yIndex)
    createInput(string.format("%d", node.__info.color.b), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
        editBox:setInput(generator:modify(node, "color.b", input, "number"))
    end)
    yIndex = yIndex + 1
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
    if iskindof(node, "cc.Sprite") or node.__info.type == "ZoomButton" then
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        -- file
        createLabel("File", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.file), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator:modify(node, "file", input, "string"))
        end)
        yIndex = yIndex + 1
    end
    if iskindof(node, "cc.Label") then
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        -- string
        createLabel("String", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.string), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator:modify(node, "string", input, "string"))
        end)
        yIndex = yIndex + 1
        -- font file
        createLabel("FontFile", leftX, topY - stepY * yIndex)
        local lan = gk.resource:getCurrentLan()
        createInput(tostring(node.__info.fontFile[lan]), leftX2_1, topY - stepY * yIndex, inputWidth1, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontFile." .. lan, input, "string"))
        end)
        yIndex = yIndex + 1
        -- font size
        createLabel("FontSize", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.fontSize), leftX2_1, topY - stepY * yIndex, inputWidth3, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontSize", input, "number"))
        end)
        -- lineHeight
        if node.__info.lineHeight then
            createLabel("LineHeight", leftX4_1, topY - stepY * yIndex)
            createInput(tostring(node.__info.lineHeight), leftX5_2, topY - stepY * yIndex, inputWidth3, function(editBox, input)
                editBox:setInput(generator:modify(node, "lineHeight", input, "number"))
            end)
        end
        yIndex = yIndex + 1
        -- dimensions
        createLabel("Dimensions", leftX, topY - stepY * yIndex)
        createLabel("W", leftX2, topY - stepY * yIndex)
        createInput(string.format("%.2f", node.__info.width), leftX2_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX3, topY - stepY * yIndex)
        createInput(string.format("%.2f", node.__info.height), leftX3_1, topY - stepY * yIndex, inputWidth2, function(editBox, input)
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
        -- overflow
        createLabel("Overflow", leftX, topY - stepY * yIndex)
        local overflows = { "NONE", "CLAMP", "SHRINK", "RESIZE_HEIGHT" }
        createSelectBox(overflows, node.__info.overflow + 1, leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "overflow", index - 1, "number")
        end)
        yIndex = yIndex + 1
    end
    if iskindof(node, "cc.ScrollView") then
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
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
        -- Direction
        createLabel("Direction", leftX, topY - stepY * yIndex)
        local overflows = { "HORIZONTAL", "VERTICAL", "BOTH" }
        createSelectBox(overflows, node.__info.direction + 1, leftX2_1, topY - stepY * yIndex, inputWidth2, function(index)
            generator:modify(node, "direction", index - 1, "number")
        end)
        yIndex = yIndex + 1
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
    end

    -- visible
    createLabel("Visible", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.visible == 0, leftX2_1, topY - stepY * yIndex, function(selected)
        generator:modify(node, "visible", selected, "number")
    end)
    yIndex = yIndex + 1
end

return panel