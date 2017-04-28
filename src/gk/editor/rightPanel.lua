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

    if not node.__info then
        return
    end
    self.displayInfoNode = cc.Node:create()
    self:addChild(self.displayInfoNode)
    local size = self:getContentSize()

    local fontSize = 10 * 4
    local fontName = "gk/res/font/Consolas.ttf"
    local scale = 0.25
    local topY = size.height - 20
    local stepY = 25
    -- "X" width
    local gapX = 20
    -- margin left
    local leftX = 15
    -- input middle 1 left x
    local leftX_input_1 = 90
    -- input width
    local inputLong = size.width - leftX - leftX_input_1
    local inputMiddle = (inputLong - gapX) / 2
    local inputShort = (inputLong - gapX * 2) / 3
    -- "X" left x
    local leftX_input_1_left = leftX_input_1 - gapX / 2
    local leftX3_0 = 110 + 20
    -- input middle 2 left x
    local leftX_input_2 = leftX_input_1 + inputMiddle + gapX
    local leftX_input_2_left = leftX_input_2 - gapX / 2
    -- input middle 2 left x
    local leftX_input_short_2 = leftX_input_1 + inputShort + gapX
    local leftX_input_short_2_left = leftX_input_short_2 - gapX / 2
    local leftX_input_short_3 = leftX_input_1 + inputShort * 2 + gapX * 2
    local leftX_input_short_3_left = leftX_input_short_3 - gapX / 2
    local checkbox_right = size.width - leftX

    local disabled = node.__rootTable and node.__rootTable.__info and node.__rootTable.__info.isWidget == 0

    local onLabelInputChanged = function(label, input)
        local isMacro = true
        repeat
            local v = generator:parseMacroFunc(node, input)
            if v then
                --                isMacro = true
                break
            end
            v = generator:parseCustomMacroFunc(node, input)
            if v then
                --                isMacro = true
                break
            end
            if type(input) == "string" then
                if gk.isTTF(input) or gk.isBMFont(input) then
                    --                return cc.c3b(45, 35, 255)
                    --                    isMacro = true
                    break
                end
                local lower = input:lower()
                if lower:ends(".png") or lower:ends(".jpg") or lower:ends(".jpeg") then
                    local _, find = gk.create_sprite(input)
                    if find then
                        --                        isMacro = true
                        break
                        --                    return cc.c3b(45, 35, 255)
                    end
                end
                if string.len(input) > 0 and input:sub(1, 1) == "@" then
                    v = gk.resource:getString(input:sub(2, #input))
                else
                    v = gk.resource:getString(input)
                end
                if v ~= "undefined" then
                    --                    isMacro = true
                    break
                end
                --            return v ~= "undefined" and cc.c3b(45, 35, 255) or cc.c3b(0, 0, 0)
            end
            --            if v ~= nil then
            --- -                isMacro = true
            -- break
            -- end
            isMacro = false
            --        return v ~= nil and cc.c3b(45, 35, 255) or cc.c3b(0, 0, 0)
        until true
        label:setTextColor(isMacro and cc.c3b(45, 35, 255) or cc.c3b(0, 0, 0))
        if isMacro then
            label:enableBold()
            label:enableItalics()
        else
            if label:getLabelEffectType() == 5 then
                label:disableEffect(5)
            end
            if label:getLabelEffectType() == 6 then
                label:disableEffect(6)
            end
        end
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
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        return label
    end
    local createInput = function(content, x, y, width, callback)
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 20, 20, 20)))
        local label = cc.Label:createWithTTF(content, fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 15, contentSize.height)
        self.displayInfoNode:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:onEditEnded(function(...)
            callback(...)
        end)
        node:onInputChanged(function(_, input)
            onLabelInputChanged(label, input)
            --            label:setTextColor(getMacroColor(input))
        end)
        --        label:setTextColor(getMacroColor(content))
        onLabelInputChanged(label, content)
        node:setPosition(x, y)
        node.enabled = not disabled
        return node
    end
    local createSelectBox = function(items, index, x, y, width, callback)
        local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 20, 20, 20)))
        local label = cc.Label:createWithTTF("", fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setDisplayLabel(label)
        node:onCreatePopupLabel(function()
            local label = cc.Label:createWithTTF("", fontName, fontSize)
            --            label:setTextColor(cc.c3b(0, 0, 0))
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
            onLabelInputChanged(label, items[index])
            --            label:setTextColor(getMacroColor(items[index]))
        end)
        onLabelInputChanged(label, items[index])
        --        label:setTextColor(getMacroColor(items[index]))
        node.enabled = not disabled
        return node
    end

    local createCheckBox = function(selected, x, y, callback)
        local node = ccui.CheckBox:create("gk/res/texture/check_box_normal.png", "gk/res/texture/check_box_selected.png")
        node:setPosition(x, y)
        node:setScale(scale)
        node:setSelected(selected)
        self.displayInfoNode:addChild(node)
        node:setAnchorPoint(0, 0.5)
        node:addEventListener(function(sender, eventType)
            callback(eventType)
        end)
        node:setAnchorPoint(cc.p(1, 0.5))
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
    createInput(node.__info.id, leftX_input_1, topY, inputLong, function(editBox, input)
        editBox:setInput(generator:modify(node, "id", input, "string"))
    end)
    yIndex = yIndex + 1
    -- lock
    createLabel("Lock", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.lock == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "lock", selected, "number")
    end)
    -- widget
    if node.__info.isWidget == 0 then
        local w = createLabel("Widget", leftX_input_short_2, topY - stepY * yIndex)
        local h = createCheckBox(node.__info.isWidget == 0, checkbox_right, topY - stepY * yIndex, function(selected)
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
    local voidContent = node.__info and node.__info.voidContent
    -- not root
    if not isRoot then
        -- position
        local ps = {}
        local nps = {}
        ps[1] = createLabel("Position", leftX, topY - stepY * yIndex)
        ps[2] = createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        ps[3] = createInput(tostring(node.__info.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "x", input, "number"))
        end)
        ps[4] = createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        ps[5] = createInput(tostring(node.__info.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "y", input, "number"))
        end)
        yIndex = yIndex + 1
        -- ScaleXY
        createLabel("ScalePos", leftX, topY - stepY * yIndex)
        createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        local scaleXs = { "1", "$scaleX", "$scaleRT", "$scaleLT" }
        createSelectBox(scaleXs, table.indexof(scaleXs, tostring(node.__info.scaleXY.x)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleXY.x", scaleXs[index], "string")
        end)
        createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        local scaleYs = { "1", "$scaleY", "$scaleTP", "$scaleBT" }
        createSelectBox(scaleYs, table.indexof(scaleYs, tostring(node.__info.scaleXY.y)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleXY.y", scaleYs[index], "string")
        end)
        yIndex = yIndex + 1
        -- NormalizedPosition
        --        nps[1] = createLabel("NPosition", leftX, topY - stepY * yIndex)
        --        nps[2] = createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        --        nps[3] = createInput(tostring(node.__info.np.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "np.x", input, "number"))
        --        end)
        --        nps[4] = createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        --        nps[5] = createInput(tostring(node.__info.np.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
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
    createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
    createInput(tostring(node.__info.anchor.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        editBox:setInput(generator:modify(node, "anchor.x", input, "number"))
    end)
    createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
    createInput(tostring(node.__info.anchor.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        editBox:setInput(generator:modify(node, "anchor.y", input, "number"))
    end)
    yIndex = yIndex + 1
    -- ignoreAnchor
    createLabel("IgnoreAnchorPoint", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.ignoreAnchor == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "ignoreAnchor", selected, "number")
    end)
    yIndex = yIndex + 1
    if not isLabel and not isTableView then
        -- size
        createLabel("Size", leftX, topY - stepY * yIndex)
        createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        local w = createInput(node.__info.width or string.format("%.2f", node:getContentSize().width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        local h = createInput(node.__info.height or string.format("%.2f", node:getContentSize().height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
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
            createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
            local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
            createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleSize.w)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, "scaleSize.w", scaleWs[index], "string")
            end)
            createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
            local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
            createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleSize.h)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, "scaleSize.h", scaleHs[index], "string")
            end)
            yIndex = yIndex + 1
        end
    end
    if not isScrollView then
        -- scale
        createLabel("Scale", leftX, topY - stepY * yIndex)
        createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.scaleX), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleX", input, "number"))
        end)
        createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.scaleY), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleY", input, "number"))
        end)
        yIndex = yIndex + 1
        -- skew
        createLabel("Skew", leftX, topY - stepY * yIndex)
        createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.skewX), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "skewX", input, "number"))
        end)
        createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.skewY), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "skewY", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    if (isLabel or isSprite or isZoomButton) and not isLayerColor then
        -- color
        createLabel("Color3B", leftX, topY - stepY * yIndex)
        createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.color.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.r", input, "number"))
        end)
        createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.color.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.g", input, "number"))
        end)
        createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.color.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.b", input, "number"))
        end)
        yIndex = yIndex + 1
        -- TODO LayerColor at once
    end

    if not isScrollView then
        -- rotation
        createLabel("Rotation", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.rotation), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "rotation", input, "number"))
        end)
        -- opacity
        createLabel("Opacity", leftX_input_short_2, topY - stepY * yIndex)
        createInput(tostring(node.__info.opacity), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "opacity", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    -- localZOrder
    createLabel("LocalZOrder", leftX, topY - stepY * yIndex)
    createInput(tostring(node.__info.localZOrder), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
        editBox:setInput(generator:modify(node, "localZOrder", input, "number"))
    end)
    createLabel("Tag", leftX_input_short_2, topY - stepY * yIndex)
    createInput(tostring(node.__info.tag), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
        editBox:setInput(generator:modify(node, "tag", input, "number"))
    end)
    yIndex = yIndex + 1
    -- cascadeOpacityEnabled
    createLabel("CascadeOpacityEnabled", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.cascadeOpacityEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "cascadeOpacityEnabled", selected, "number")
    end)
    yIndex = yIndex + 1
    -- cascadeColorEnabled
    createLabel("CascadeColorEnabled", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.cascadeColorEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "cascadeColorEnabled", selected, "number")
    end)
    yIndex = yIndex + 1
    -- visible
    createLabel("Visible", leftX, topY - stepY * yIndex)
    createCheckBox(node.__info.visible == 0, checkbox_right, topY - stepY * yIndex, function(selected)
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
            createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.r", input, "number"))
            end)
            createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.g", input, "number"))
            end)
            createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.b", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("A", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.color.a), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.a", input, "number"))
            end)
            yIndex = yIndex + 1
        end

        if isLayerGradient then
            -- startColor
            createLabel("StartColor", leftX, topY - stepY * yIndex)
            createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.startColor.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.r", input, "number"))
            end)
            createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.startColor.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.g", input, "number"))
            end)
            createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.startColor.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.b", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("StartOpacity", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.startOpacity), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startOpacity", input, "number"))
            end)
            yIndex = yIndex + 1
            -- endColor4B
            createLabel("EndColor", leftX, topY - stepY * yIndex)
            createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.endColor.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.r", input, "number"))
            end)
            createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.endColor.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.g", input, "number"))
            end)
            createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.endColor.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.b", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("EndOpacity", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.endOpacity), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endOpacity", input, "number"))
            end)
            yIndex = yIndex + 1
            -- Vector
            createLabel("Vector", leftX, topY - stepY * yIndex)
            createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.vector.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "vector.x", input, "number"))
            end)
            createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.vector.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "vector.y", input, "number"))
            end)
            yIndex = yIndex + 1
            -- isCompressedInterpolation
            createLabel("IsCompressedInterpolation", leftX, topY - stepY * yIndex)
            createCheckBox(node.__info.isCompressedInterpolation == 0, checkbox_right, topY - stepY * yIndex, function(selected)
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
            createSelectBox(clicks, table.indexof(clicks, tostring(node.__info.onClicked)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
                generator:modify(node, "onClicked", clicks[index], "string")
            end)
            yIndex = yIndex + 1
        end
        -- sprite file
        createLabel("Sprite", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.file), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "file", input, "string"))
        end)
        yIndex = yIndex + 1
    end

    if isSprite then
        -- blendFunc
        createLabel("blendFunc", leftX, topY - stepY * yIndex)
        createLabel("S", leftX_input_1_left, topY - stepY * yIndex)
        local FUNCS = { "ZERO", "ONE", "SRC_COLOR", "ONE_MINUS_SRC_COLOR", "SRC_ALPHA", "ONE_MINUS_SRC_ALPHA", "DST_ALPHA", "ONE_MINUS_DST_ALPHA", "DST_COLOR", "ONE_MINUS_DST_COLOR" }
        local getIndex = function(value)
            for i, key in ipairs(FUNCS) do
                if gl[key] == value then
                    return i
                end
            end
        end
        createSelectBox(FUNCS, getIndex(node.__info.blendFunc.src), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "blendFunc.src", gl[FUNCS[index]], "number")
        end)
        yIndex = yIndex + 1
        createLabel("D", leftX_input_1_left, topY - stepY * yIndex)
        createSelectBox(FUNCS, getIndex(node.__info.blendFunc.dst), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "blendFunc.dst", gl[FUNCS[index]], "number")
        end)
        yIndex = yIndex + 1
        -- flippedX
        createLabel("FippedX", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.flippedX == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedX", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    if isZoomButton then
        -- zoomScale
        createLabel("ZoomScale", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.zoomScale), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "zoomScale", input, "number"))
        end)
        yIndex = yIndex + 1
        -- enabled
        createLabel("Enabled", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enabled == 0, leftX_input_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enabled", selected, "number")
        end)
        yIndex = yIndex + 1
    end
    --------------------------- cc.Label   ---------------------------
    if isLabel then
        local lan = gk.resource:getCurrentLan()
        local fontFile = node.__info.fontFile[lan]
        local isTTF = gk.isTTF(fontFile)
        local isBMFont = gk.isBMFont(fontFile)
        local isSystemFont = not isTTF and not isBMFont
        createLabel(string.format("Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")), leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6

        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        -- font file
        createLabel("FontFile", leftX, topY - stepY * yIndex)
        createInput(isSystemFont and tostring(node:getSystemFontName()) or tostring(node.__info.fontFile[lan]), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontFile." .. lan, input, "string"))
            gk.event:post("displayNode", node)
            -- TODO recreate label at once
        end)
        yIndex = yIndex + 1
        --        if isSystemFont then
        --            -- systemFontName
        --            createLabel("SysFontName", leftX, topY - stepY * yIndex)
        --            createInput(tostring(node:getSystemFontName()), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
        --                editBox:setInput(generator:modify(node, "fontFile." .. lan, input, "string"))
        --            end)
        --            yIndex = yIndex + 1
        --        end
        -- string
        createLabel("String", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.string), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "string", input, "string"))
        end)
        yIndex = yIndex + 1
        -- overflow
        -- System font only support Overflow::NONE and Overflow::RESIZE_HEIGHT.
        createLabel("Overflow", leftX, topY - stepY * yIndex)
        local overflows = { "NONE", "CLAMP", "SHRINK", "RESIZE_HEIGHT" }
        local values = { 0, 1, 2, 3 }
        if isSystemFont then
            overflows = { "NONE", "RESIZE_HEIGHT" }
            values = { 0, 3 }
        end
        createSelectBox(overflows, table.indexof(values, node.__info.overflow), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "overflow", values[index], "number")
        end)
        yIndex = yIndex + 1
        -- dimensions
        createLabel("Dimensions", leftX, topY - stepY * yIndex)
        createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- alignment
        createLabel("Alignment", leftX, topY - stepY * yIndex)
        createLabel("H", leftX_input_1_left, topY - stepY * yIndex)
        local hAligns = { "LEFT", "CENTER", "RIGHT" }
        createSelectBox(hAligns, node.__info.hAlign + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "hAlign", index - 1, "number")
        end)
        createLabel("V", leftX_input_2_left, topY - stepY * yIndex)
        local vAligns = { "TOP", "CENTER", "BOTTOM" }
        createSelectBox(vAligns, node.__info.vAlign + 1, leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "vAlign", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- maxLineWidth
        --        if node.__info.maxLineWidth then
        --            createLabel("MaxLineWidth", leftX, topY - stepY * yIndex)
        --            createInput(tostring(node.__info.maxLineWidth), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --                editBox:setInput(generator:modify(node, "maxLineWidth", input, "number"))
        --            end)
        --            yIndex = yIndex + 1
        --        end
        -- lineHeight, Not support system font.
        if not isSystemFont and node.__info.lineHeight then
            createLabel("LineHeight", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.lineHeight), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "lineHeight", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        -- font size
        createLabel("FontSize", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.fontSize), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontSize", input, "number"))
        end)
        yIndex = yIndex + 1
        if not isSystemFont and node.__info.lineHeight then
            --additionalKerning
            createLabel("AdditionalKerning", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.additionalKerning), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "additionalKerning", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        if not isBMFont then
            -- color
            createLabel("TextColor4B", leftX, topY - stepY * yIndex)
            createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.textColor.r), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.r", input, "number"))
            end)
            createLabel("G", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.textColor.g), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.g", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("B", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.textColor.b), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.b", input, "number"))
            end)
            createLabel("A", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.textColor.a), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.a", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        if not isSystemFont then
            -- enableWrap
            createLabel("EnableWrap", leftX, topY - stepY * yIndex)
            createCheckBox(node.__info.enableWrap == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "enableWrap", selected, "number")
            end)
            yIndex = yIndex + 1
        end
        -- lineBreakWithoutSpace
        createLabel("LineBreakWithoutSpace", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.lineBreakWithoutSpace == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "lineBreakWithoutSpace", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableShadow
        createLabel("enableShadow", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enableShadow == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableShadow", selected, "number")
            gk.event:post("displayNode", node)
        end)
        yIndex = yIndex + 1
        if node.__info.enableShadow == 0 and node.__info.shadow then
            -- shadowColor
            createLabel("Color4B", leftX, topY - stepY * yIndex)
            createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.r), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.r", input, "number"))
            end)
            createLabel("G", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.g), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.g", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("B", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.b), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.b", input, "number"))
            end)
            createLabel("A", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.a), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.a", input, "number"))
            end)
            yIndex = yIndex + 1
            -- offset
            createLabel("Offset", leftX, topY - stepY * yIndex)
            createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.w), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.w", input, "number"))
            end)
            createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.h), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.h", input, "number"))
            end)
            yIndex = yIndex + 1
            -- blurRadius
            createLabel("BlurRadius", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.shadow.radius), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.radius", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        if isTTF then
            -- enableGlow
            createLabel("enableGlow", leftX, topY - stepY * yIndex)
            createCheckBox(node.__info.enableGlow == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "enableGlow", selected, "number")
                gk.event:post("displayNode", node)
            end)
            yIndex = yIndex + 1
        end
        if isTTF then
            -- enableOutline
            local lb = createLabel("enableOutline", leftX, topY - stepY * yIndex)
            local cb = createCheckBox(node.__info.enableOutline == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "enableOutline", selected, "number")
                gk.event:post("displayNode", node)
            end)
            yIndex = yIndex + 1
        end
        if (node.__info.enableOutline == 0 and (isTTF or isSystemFont)) or (node.__info.enableGlow == 0 and isTTF) then
            -- shadowColor
            createLabel("Color4B", leftX, topY - stepY * yIndex)
            createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.effectColor.r), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.r", input, "number"))
            end)
            createLabel("G", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.effectColor.g), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.g", input, "number"))
            end)
            yIndex = yIndex + 1
            createLabel("B", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.effectColor.b), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.b", input, "number"))
            end)
            createLabel("A", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.effectColor.a), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.a", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        if isTTF and node.__info.enableOutline == 0 then
            -- outlineSize
            createLabel("OutlineSize", leftX, topY - stepY * yIndex)
            createInput(tostring(node.__info.outlineSize), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "outlineSize", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        -- enableItalics
        createLabel("enableItalics", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enableItalics == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableItalics", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableBold
        createLabel("enableBold", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enableBold == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableBold", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableUnderline
        createLabel("enableUnderline", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enableUnderline == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableUnderline", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableStrikethrough
        createLabel("enableStrikethrough", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.enableStrikethrough == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableStrikethrough", selected, "number")
        end)
        yIndex = yIndex + 1
        -- clipMarginEnabled
        --        createLabel("ClipMarginEnabled", leftX, topY - stepY * yIndex)
        --        createCheckBox(node.__info.clipMarginEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        --            generator:modify(node, "clipMarginEnabled", selected, "number")
        --        end)
        --        yIndex = yIndex + 1
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
        createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.viewSize.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "viewSize.width", input, "number"))
        end)
        createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.viewSize.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "viewSize.height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- ScaleSize
        createLabel("ScaleSize", leftX, topY - stepY * yIndex)
        createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        local scaleWs = { "1", "$scaleX", "$minScale", "$maxScale" }
        createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleSize.w)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleSize.w", scaleWs[index], "string")
        end)
        createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        local scaleHs = { "1", "$scaleY", "$minScale", "$maxScale" }
        createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleSize.h)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleSize.h", scaleHs[index], "string")
        end)
        yIndex = yIndex + 1
        -- Direction
        createLabel("Direction", leftX, topY - stepY * yIndex)
        local directions = { "HORIZONTAL", "VERTICAL", "BOTH" }
        createSelectBox(directions, node.__info.direction + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "direction", index - 1, "number")
        end)
        yIndex = yIndex + 1
        if isTableView then
            -- verticalFillOrder
            createLabel("FillOrder", leftX, topY - stepY * yIndex)
            local verticalFillOrders = { "TOP_DOWN", "BOTTOM_UP" }
            createSelectBox(verticalFillOrders, node.__info.verticalFillOrder + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, "verticalFillOrder", index - 1, "number")
            end)
            yIndex = yIndex + 1
        end
        -- ClipToBD
        createLabel("ClipToBD", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.clipToBD == 0, leftX_input_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "clipToBD", selected, "number")
        end)
        -- Bounceable
        createLabel("Bounceable", leftX3_0, topY - stepY * yIndex)
        createCheckBox(node.__info.bounceable == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "bounceable", selected, "number")
        end)
        yIndex = yIndex + 1
        -- touchEnabled
        createLabel("Enabled", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.touchEnabled == 0, leftX_input_1, topY - stepY * yIndex, function(selected)
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
        createCheckBox(node.__info.swallowTouchEvent == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "swallowTouchEvent", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableKeyPad
        local w = createLabel("EnableKeyPad", leftX, topY - stepY * yIndex)
        local h = createCheckBox(node.__info.enableKeyPad == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableKeyPad", selected, "number")
        end)
        yIndex = yIndex + 1
        -- popOnBack
        createLabel("PopOnBack", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.popOnBack == 0, checkbox_right, topY - stepY * yIndex, function(selected)
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
        --        createInput(tostring(node.__info.stencil), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "stencil", input, "string"))
        --        end)
        --        yIndex = yIndex + 1
        -- alphaThreshold
        createLabel("AlphaThreshold", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.alphaThreshold), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "alphaThreshold", input, "number"))
        end)
        yIndex = yIndex + 1
        -- inverted
        createLabel("Inverted", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.inverted == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "inverted", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    local isProgressTimer = iskindof(node, "cc.ProgressTimer")
    if isProgressTimer then
        createLabel("ProgressTimer", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        -- barType
        createLabel("BarType", leftX, topY - stepY * yIndex)
        local types = { "RADIAL", "BAR" }
        createSelectBox(types, node.__info.barType + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "barType", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- reverseDirection
        createLabel("RreverseDirection", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.reverseDirection == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "reverseDirection", selected, "number")
        end)
        yIndex = yIndex + 1
        -- percentage
        createLabel("Percentage", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.percentage), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "percentage", input, "number"))
        end)
        yIndex = yIndex + 1
        -- midpoint
        createLabel("Midpoint", leftX, topY - stepY * yIndex)
        createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.midpoint.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "midpoint.x", input, "number"))
        end)
        createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.midpoint.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "midpoint.y", input, "number"))
        end)
        yIndex = yIndex + 1
        if node.__info.barType == 1 then
            -- barChangeRate
            createLabel("ChangeRate", leftX, topY - stepY * yIndex)
            createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.barChangeRate.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "barChangeRate.x", input, "number"))
            end)
            createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
            createInput(tostring(node.__info.barChangeRate.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "barChangeRate.y", input, "number"))
            end)
            yIndex = yIndex + 1
        end
    end

    local isProgressTimer = iskindof(node, "ccui.Scale9Sprite")
    if isProgressTimer then
        createLabel("Scale9Sprite", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        -- sprite file
        createLabel("Sprite", leftX, topY - stepY * yIndex)
        createInput(tostring(node.__info.file), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "file", input, "string"))
        end)
        yIndex = yIndex + 1
        -- CapInsets
        createLabel("CapInsets", leftX, topY - stepY * yIndex)
        createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.capInsets.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.x", input, "number"))
        end)
        createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.capInsets.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.y", input, "number"))
        end)
        yIndex = yIndex + 1
        createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.capInsets.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.width", input, "number"))
        end)
        createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.capInsets.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- RenderingType
        createLabel("RenderingType", leftX, topY - stepY * yIndex)
        local types = { "SIMPLE", "SLICE" }
        createSelectBox(types, node.__info.renderingType + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "renderingType", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- state
        createLabel("State", leftX, topY - stepY * yIndex)
        local types = { "NORMAL", "GRAY" }
        createSelectBox(types, node.__info.state + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "state", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- flippedX
        createLabel("FippedX", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.flippedX == 0, leftX_input_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedX", selected, "number")
        end)
        -- flippedY
        createLabel("FippedY", leftX_input_short_2, topY - stepY * yIndex)
        createCheckBox(node.__info.flippedY == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedY", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    local isClippingRectangleNode = iskindof(node, "cc.ClippingRectangleNode")
    if isClippingRectangleNode then
        createLabel("ClippingRectangleNode", leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.6
        yIndex = yIndex + 0.2
        createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        -- ClippingRegion
        createLabel("ClipRegion", leftX, topY - stepY * yIndex)
        createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.clippingRegion.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.x", input, "number"))
        end)
        createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.clippingRegion.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.y", input, "number"))
        end)
        yIndex = yIndex + 1
        createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.clippingRegion.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.width", input, "number"))
        end)
        createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        createInput(tostring(node.__info.clippingRegion.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- clippingEnabled
        createLabel("ClippingEnabled", leftX, topY - stepY * yIndex)
        createCheckBox(node.__info.clippingEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "clippingEnabled", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    self.displayInfoNode:setContentSize(cc.size(gk.display.height(), stepY * yIndex + gk.display.bottomHeight + 5))
    if disabled then
        self.displayInfoNode:setOpacity(150)
        gk.util:setRecursiveCascadeOpacityEnabled(self.displayInfoNode, true)
    end

    if (self.lastDisplayNodeId == node.__info.id or self.lastDisplayNodeType == node.__info.type) and self.lastDisplayInfoOffset then
        local y = self.lastDisplayInfoOffset.y
        y = cc.clampf(y, 0, self.displayInfoNode:getContentSize().height - self:getContentSize().height)
        self.lastDisplayInfoOffset.y = y
        self.displayInfoNode:setPosition(self.lastDisplayInfoOffset)
    else
        self.lastDisplayInfoOffset = cc.p(0, 0)
    end
    self.lastDisplayNodeId = node.__info.id
    self.lastDisplayNodeType = node.__info.type
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
                self.lastDisplayInfoOffset = cc.p(x, y)
            end
        end
    end, cc.Handler.EVENT_MOUSE_SCROLL)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return panel