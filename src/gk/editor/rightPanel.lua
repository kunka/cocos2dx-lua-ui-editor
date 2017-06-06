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
    self.displayInfoNode = cc.Node:create()
    self:addChild(self.displayInfoNode)

    self:handleEvent()
    return self
end

function panel:undisplayNode()
    self.displayInfoNode:removeAllChildren()
end

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
                if v ~= "undefined" then
                    --                    isMacro = true
                    break
                end
            end
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

local onValueChanged = function(bg, defaultValue, value)
    bg:setColor(tostring(defaultValue) == tostring(value) and cc.c3b(156, 156, 156) or cc.c3b(255, 255, 255))
end

local fontSize = 10 * 4
local fontName = "gk/res/font/Consolas.ttf"
local scale = 0.25

function panel:createLabel(content, x, y, isTitle)
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

function panel:createCheckBox(selected, x, y, callback)
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
    node:setTouchEnabled(not self.disabled)
    return node
end

function panel:createInput(content, x, y, width, callback, defValue)
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
        onValueChanged(node.bg, defValue, input)
    end)
    onLabelInputChanged(label, content)
    onValueChanged(node.bg, defValue, content)
    node:setPosition(x, y)
    node.isEnabled = not self.disabled
    return node
end

function panel:createSelectAndInput(content, items, index, x, y, width, callback, defValue)
    local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
    node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 20, 20, 20)))
    local label = cc.Label:createWithTTF(content, fontName, fontSize)
    label:setTextColor(cc.c3b(0, 0, 0))
    node:setInputLabel(label)
    local contentSize = node:getContentSize()
    local btnWidth = 12 / scale
    label:setPosition(cc.p(contentSize.width / 2 - btnWidth / 2, contentSize.height / 2 - 5))
    label:setDimensions(contentSize.width - 15 - btnWidth, contentSize.height)
    self.displayInfoNode:addChild(node)
    node:setScale(scale)
    node:setAnchorPoint(0, 0.5)
    node:onEditEnded(function(...)
        callback(...)
    end)
    node:onInputChanged(function(_, input)
        onLabelInputChanged(label, input)
        onValueChanged(node.bg, defValue, input)
    end)
    onLabelInputChanged(label, content)
    onValueChanged(node.bg, defValue, content)
    node:setPosition(x, y)
    node.isEnabled = not self.disabled
    local input = node

    local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
    local label = cc.Label:createWithTTF("", fontName, fontSize)
    label:setOpacity(0)
    node:setDisplayLabel(label)
    node:onCreatePopupLabel(function()
        local label = cc.Label:createWithTTF("", fontName, fontSize)
        return label
    end)

    local contentSize = node:getContentSize()
    local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
    label:setTextColor(cc.c3b(45, 35, 255))
    label:setRotation(90)
    label:setDimensions(10 / scale, 10 / scale)
    local button = gk.ZoomButton.new(label)
    button:setScale(-1.2, 0.7)
    button:setPosition(contentSize.width - btnWidth, contentSize.height / 2 - 3)
    node:addChild(button, 999)
    button:setAnchorPoint(1, 0.5)
    button:onClicked(function()
        if node.isEnabled then
            node:openPopup()
        end
    end)
    self.displayInfoNode:addChild(node)
    node:setScale(scale)
    node:setAnchorPoint(0, 0.5)
    node:setPosition(x, y)
    node:onSelectChanged(function(index)
        callback(input, items[index])
    end)
    node.isEnabled = not self.disabled
    return input
end

function panel:createSelectBox(items, index, x, y, width, callback, defValue)
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
        onValueChanged(node.bg, defValue, items[index])
        --            label:setTextColor(getMacroColor(items[index]))
    end)
    onLabelInputChanged(label, items[index])
    onValueChanged(node.bg, defValue, items[index])
    --        label:setTextColor(getMacroColor(items[index]))
    node.isEnabled = not self.disabled
    return node
end

function panel:createLine(y)
    y = y + 12
    gk.util:drawLineOnNode(self.displayInfoNode, cc.p(10, y), cc.p(self.contentSize.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
end

function panel:displayNode(node)
    self:undisplayNode()
    if not node.__info then
        return
    end
    local size = self:getContentSize()
    self.contentSize = size
    self.disabled = node.__rootTable and node.__rootTable.__info and node.__rootTable.__info._isWidget

    local topY = size.height - 20
    local stepY = 25
    -- "X" width
    local gapX = 20
    -- margin left
    local leftX = 15
    -- input middle 1 left x
    local leftX_input_1 = 100
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

    local isLabel = gk.util:instanceof(node, "cc.Label")
    local isSprite = gk.util:instanceof(node, "cc.Sprite")
    local isZoomButton = gk.util:instanceof(node, "ZoomButton")
    local isSpriteButton = gk.util:instanceof(node, "SpriteButton")
    local isToggleButton = gk.util:instanceof(node, "ToggleButton")
    local isButton = gk.util:instanceof(node, "Button")
    local isLayer = gk.util:instanceof(node, "cc.Layer")
    local isLayerColor = gk.util:instanceof(node, "cc.LayerColor")
    local isLayerGradient = gk.util:instanceof(node, "cc.LayerGradient")
    local isScrollView = gk.util:instanceof(node, "cc.ScrollView")
    local isTableView = gk.util:instanceof(node, "cc.TableView")
    local isScale9Sprite = gk.util:instanceof(node, "ccui.Scale9Sprite")
    local isCheckBox = gk.util:instanceof(node, "ccui.CheckBox")
    local isEditBox = gk.util:instanceof(node, "ccui.EditBox")
    local isClippingRectangleNode = gk.util:instanceof(node, "cc.ClippingRectangleNode")
    local isProgressTimer = gk.util:instanceof(node, "cc.ProgressTimer")
    local isClippingNode = gk.util:instanceof(node, "cc.ClippingNode")
    local isgkLayer = gk.util:instanceof(node, "Layer")
    local isgkDialog = gk.util:instanceof(node, "Dialog")
    local isRootNode = self.parent.scene.layer == node
    local _voidContent = node.__info and node.__info._voidContent

    local yIndex = 0
    local function createTitle(title)
        local label = self:createLabel(title, leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.8
        self:createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        return label
    end

    --------------------------- ID   ---------------------------
    -- id
    self:createLabel("ID", leftX, topY)
    self:createInput(node.__info.id, leftX_input_1, topY, inputLong, function(editBox, input)
        editBox:setInput(generator:modify(node, "id", input, "string"))
    end)
    yIndex = yIndex + 1
    if self.parent._containerNode == node or self.parent.leftPanel._containerNode then
        -- only display id when dragging
        return
    end
    -- _lock
    self:createLabel("Lock", leftX, topY - stepY * yIndex)
    self:createCheckBox(node.__info._lock == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "_lock", selected, "number")
    end)
    yIndex = yIndex + 1

    --------------------------- cc.Node   ---------------------------
    createTitle("Node")

    -- position
    if not isRootNode then
        self:createLabel("Position", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "x", input, "number"))
        end, 0)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "y", input, "number"))
        end, 0)
        yIndex = yIndex + 1
        -- ScaleXY
        self:createLabel("ScalePos", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        local scaleXs = { "1", "$scaleX", "$minScale", "$maxScale", "$scaleRT", "$scaleLT" }
        self:createSelectBox(scaleXs, table.indexof(scaleXs, tostring(node.__info.scaleXY.x)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleXY.x", scaleXs[index], "string")
        end, generator.config.defValues["scaleXY"].x)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        local scaleYs = { "1", "$scaleY", "$minScale", "$maxScale", "$scaleTP", "$scaleBT" }
        self:createSelectBox(scaleYs, table.indexof(scaleYs, tostring(node.__info.scaleXY.y)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleXY.y", scaleYs[index], "string")
        end, generator.config.defValues["scaleXY"].y)
        yIndex = yIndex + 1
    end
    -- anchor
    self:createLabel("AnchorPoint", leftX, topY - stepY * yIndex)
    self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
    self:createInput(tostring(node.__info.anchor.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        editBox:setInput(generator:modify(node, "anchor.x", input, "number"))
    end, generator.config.defValues["anchor"].x)
    self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
    self:createInput(tostring(node.__info.anchor.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        editBox:setInput(generator:modify(node, "anchor.y", input, "number"))
    end, generator.config.defValues["anchor"].y)
    yIndex = yIndex + 1
    -- ignoreAnchor
    self:createLabel("IgnoreAnchorPoint", leftX, topY - stepY * yIndex)
    self:createCheckBox(node.__info.ignoreAnchor == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "ignoreAnchor", selected, "number")
    end)
    yIndex = yIndex + 1
    -- size
    if not isLabel and not isTableView then
        self:createLabel("ContentSize", leftX, topY - stepY * yIndex)
        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        local w = self:createInput(node.__info.width, leftX_input_1, topY - stepY *
                yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end)
        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        local h = self:createInput(node.__info.height, leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "height", input, "number"))
        end)
        yIndex = yIndex + 1
        if (isSprite and not isScale9Sprite) or isButton then
            w:setOpacity(150)
            w:setCascadeOpacityEnabled(true)
            w.isEnabled = false
            h:setOpacity(150)
            h:setCascadeOpacityEnabled(true)
            h.isEnabled = false
        end
        if not isSprite then
            -- ScaleSize
            self:createLabel("ScaleSize", leftX, topY - stepY * yIndex)
            self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
            local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
            self:createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleSize.w)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, "scaleSize.w", scaleWs[index], "string")
            end, 1)
            self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
            local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
            self:createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleSize.h)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, "scaleSize.h", scaleHs[index], "string")
            end, 1)
            yIndex = yIndex + 1
        end
    end
    if not isScrollView then
        -- scale
        self:createLabel("Scale", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.scaleX), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleX", input, "number"))
        end, generator.config.defValues["scaleX"])
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.scaleY), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleY", input, "number"))
        end, generator.config.defValues["scaleY"])
        yIndex = yIndex + 1
        -- skew
        self:createLabel("Skew", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.skewX), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "skewX", input, "number"))
        end, generator.config.defValues["skewX"])
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.skewY), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "skewY", input, "number"))
        end, generator.config.defValues["skewY"])
        yIndex = yIndex + 1
    end
    if (isLabel or isSprite or isZoomButton or isSpriteButton) and not isLayerColor then
        -- color3B
        self:createLabel("Color3B", leftX, topY - stepY * yIndex)
        self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.color.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.r", input, "number"))
        end, 255)
        self:createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.color.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.g", input, "number"))
        end, 255)
        self:createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.color.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "color.b", input, "number"))
        end, 255)
        yIndex = yIndex + 1
        -- TODO LayerColor at once
    end

    if not isScrollView then
        -- rotation
        self:createLabel("Rotation", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.rotation), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "rotation", input, "number"))
        end, generator.config.defValues["rotation"])
        -- opacity
        self:createLabel("Opacity", leftX_input_short_2, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.opacity), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(generator:modify(node, "opacity", input, "number"))
        end, generator.config.defValues["opacity"])
        yIndex = yIndex + 1
    end
    -- localZOrder
    self:createLabel("LocalZOrder", leftX, topY - stepY * yIndex)
    self:createInput(tostring(node.__info.localZOrder), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
        editBox:setInput(generator:modify(node, "localZOrder", input, "number"))
    end, generator.config.defValues["localZOrder"])
    -- tag
    self:createLabel("Tag", leftX_input_short_2, topY - stepY * yIndex)
    self:createInput(tostring(node.__info.tag), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
        editBox:setInput(generator:modify(node, "tag", input, "number"))
    end, generator.config.defValues["tag"])
    yIndex = yIndex + 1
    -- cascadeOpacityEnabled
    self:createLabel("CascadeOpacityEnabled", leftX, topY - stepY * yIndex)
    self:createCheckBox(node.__info.cascadeOpacityEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "cascadeOpacityEnabled", selected, "number")
    end)
    yIndex = yIndex + 1
    -- cascadeColorEnabled
    self:createLabel("CascadeColorEnabled", leftX, topY - stepY * yIndex)
    self:createCheckBox(node.__info.cascadeColorEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "cascadeColorEnabled", selected, "number")
    end)
    yIndex = yIndex + 1
    -- visible
    self:createLabel("Visible", leftX, topY - stepY * yIndex)
    self:createCheckBox(node.__info.visible == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        generator:modify(node, "visible", selected, "number")
    end)
    yIndex = yIndex + 1

    --------------------------- cc.LayerColor   ---------------------------
    if isLayerColor then
        createTitle(isLayerGradient and "LayerGradient" or "LayerColor")

        if not isLayerGradient then
            -- color
            self:createLabel("Color3B", leftX, topY - stepY * yIndex)
            self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.color.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.r", input, "number"))
            end, 255)
            self:createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.color.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.g", input, "number"))
            end, 255)
            self:createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.color.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.b", input, "number"))
            end, 255)
            yIndex = yIndex + 1
            -- use opacity instead of this!
            self:createLabel("A", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.color.a), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "color.a", input, "number"))
            end, 255)
            yIndex = yIndex + 1
        end

        if isLayerGradient then
            -- startColor
            self:createLabel("StartColor", leftX, topY - stepY * yIndex)
            self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.startColor.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.r", input, "number"))
            end)
            self:createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.startColor.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.g", input, "number"))
            end)
            self:createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.startColor.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startColor.b", input, "number"))
            end)
            yIndex = yIndex + 1
            self:createLabel("StartOpacity", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.startOpacity), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "startOpacity", input, "number"))
            end, 255)
            yIndex = yIndex + 1
            -- endColor4B
            self:createLabel("EndColor", leftX, topY - stepY * yIndex)
            self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.endColor.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.r", input, "number"))
            end)
            self:createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.endColor.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.g", input, "number"))
            end)
            self:createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.endColor.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endColor.b", input, "number"))
            end)
            yIndex = yIndex + 1
            self:createLabel("EndOpacity", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.endOpacity), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
                editBox:setInput(generator:modify(node, "endOpacity", input, "number"))
            end, 255)
            yIndex = yIndex + 1
            -- Vector
            self:createLabel("Vector", leftX, topY - stepY * yIndex)
            self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.vector.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "vector.x", input, "number"))
            end)
            self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.vector.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "vector.y", input, "number"))
            end)
            yIndex = yIndex + 1
            -- CompressedInterpolation
            self:createLabel("CompressedInterpolation", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.compressedInterpolation == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "compressedInterpolation", selected, "number")
            end)
            yIndex = yIndex + 1
        end
    end

    --------------------------- cc.Sprite, ZoomButton   ---------------------------
    if isEditBox then
        createTitle("EditBox")
    end
    if isScale9Sprite then
        createTitle("Scale9Sprite")
    end
    if isSprite and not isScale9Sprite then
        createTitle("Sprite")
    end
    if isSprite then
        -- sprite file
        self:createLabel("Sprite", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.file), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "file", input, "string"))
        end)
        yIndex = yIndex + 1
    end
    if isZoomButton or isSpriteButton then
        if isSpriteButton then
            createTitle("SpriteButton")
        else
            if isToggleButton then
                createTitle("ToggleButton(Tag:1~n continuous)")
            elseif isZoomButton then
                createTitle("ZoomButton")
            end
        end

        if isToggleButton then
            -- event
            self:createLabel("SelectedTag", leftX, topY - stepY * yIndex)
            local tags = { 0 }
            -- search tag
            local children = node:getChildren()
            for i = 1, #children do
                local child = children[i]
                if child and child.__info and child.__info.id then
                    if child.__info.tag ~= -1 then
                        if not table.indexof(tags, child.__info.tag) then
                            table.insert(tags, child.__info.tag)
                        end
                    end
                end
            end
            self:createSelectBox(tags, table.indexof(tags, node.__info.selectedTag), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
                generator:modify(node, "selectedTag", tags[index], "number")
            end, 1)
            yIndex = yIndex + 1
            -- onSelectedTagChanged event
            self:createLabel("onSelectTagChanged", leftX, topY - stepY * yIndex)
            local funcs = { "-" }
            for key, value in pairs(self.parent.scene.layer.class) do
                if type(value) == "function" and key:sub(1, 2) == "on" then
                    table.insert(funcs, "&" .. key)
                end
            end
            self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info.onSelectedTagChanged)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
                generator:modify(node, "onSelectedTagChanged", funcs[index], "string")
            end, "-")
            yIndex = yIndex + 1
        end

        -- click event
        self:createLabel("onClicked", leftX, topY - stepY * yIndex)
        local funcs = { "-" }
        -- search click callback format like "onXXX"
        -- TODO: super class's click function
        for key, value in pairs(self.parent.scene.layer.class) do
            --                if type(value) == "function" and key:sub(1, 2) == "on" and key:sub(key:len() - 6, key:len()) == "Clicked" then
            if type(value) == "function" and key:sub(1, 2) == "on" then
                table.insert(funcs, "&" .. key)
            end
        end
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info.onClicked)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "onClicked", funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1

        -- onSelectChanged event
        self:createLabel("onSelectChanged", leftX, topY - stepY * yIndex)
        local funcs = { "-" }
        for key, value in pairs(self.parent.scene.layer.class) do
            if type(value) == "function" and key:sub(1, 2) == "on" then
                table.insert(funcs, "&" .. key)
            end
        end
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info.onSelectChanged)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "onSelectChanged", funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1

        -- onDisableChanged event
        self:createLabel("onEnableChanged", leftX, topY - stepY * yIndex)
        local funcs = { "-" }
        for key, value in pairs(self.parent.scene.layer.class) do
            if type(value) == "function" and key:sub(1, 2) == "on" then
                table.insert(funcs, "&" .. key)
            end
        end
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info.onEnableChanged)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "onEnableChanged", funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1

        -- onLongPressed event
        self:createLabel("onLongPressed", leftX, topY - stepY * yIndex)
        local funcs = { "-" }
        for key, value in pairs(self.parent.scene.layer.class) do
            if type(value) == "function" and key:sub(1, 2) == "on" then
                table.insert(funcs, "&" .. key)
            end
        end
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info.onLongPressed)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "onLongPressed", funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1

        --        -- centerRect
        --        self:createLabel("CenterRect", leftX, topY - stepY * yIndex)
        --        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        --        self:createInput(tostring(node.__info.centerRect.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "centerRect.x", input, "number"))
        --        end)
        --        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        --        self:createInput(tostring(node.__info.centerRect.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "centerRect.y", input, "number"))
        --        end)
        --        yIndex = yIndex + 1
        --        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        --        self:createInput(tostring(node.__info.centerRect.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "centerRect.width", input, "number"))
        --        end)
        --        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        --        self:createInput(tostring(node.__info.centerRect.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "centerRect.height", input, "number"))
        --        end)
        --        yIndex = yIndex + 1
    end

    if isEditBox then
        -- string
        self:createLabel("PlaceHolder", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.placeHolder), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "placeHolder", input, "string"))
        end, "")
        yIndex = yIndex + 1
    end

    if isSpriteButton or isEditBox then
        -- normalSprite file
        self:createLabel("NormalSprite", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.normalSprite), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "normalSprite", input, "string"))
        end)
        yIndex = yIndex + 1
        -- selectedSprite file
        self:createLabel("SelectSprite", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.selectedSprite), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "selectedSprite", input, "string"))
        end)
        yIndex = yIndex + 1
        -- disabledSprite file
        self:createLabel("DisableSprite", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.disabledSprite), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "disabledSprite", input, "string"))
        end)
        yIndex = yIndex + 1
    end

    if isSprite and not isScale9Sprite then
        -- blendFunc
        self:createLabel("blendFunc", leftX, topY - stepY * yIndex)
        self:createLabel("S", leftX_input_1_left, topY - stepY * yIndex)
        local FUNCS = { "ZERO", "ONE", "SRC_COLOR", "ONE_MINUS_SRC_COLOR", "SRC_ALPHA", "ONE_MINUS_SRC_ALPHA", "DST_ALPHA", "ONE_MINUS_DST_ALPHA", "DST_COLOR", "ONE_MINUS_DST_COLOR" }
        local getIndex = function(value)
            for i, key in ipairs(FUNCS) do
                if gl[key] == value then
                    return i
                end
            end
        end
        self:createSelectBox(FUNCS, getIndex(node.__info.blendFunc.src), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "blendFunc.src", gl[FUNCS[index]], "number")
        end, "ONE")
        yIndex = yIndex + 1
        self:createLabel("D", leftX_input_1_left, topY - stepY * yIndex)
        self:createSelectBox(FUNCS, getIndex(node.__info.blendFunc.dst), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "blendFunc.dst", gl[FUNCS[index]], "number")
        end, "ONE_MINUS_SRC_ALPHA")
        yIndex = yIndex + 1
        -- flippedX
        self:createLabel("FlippedX", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.flippedX == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedX", selected, "number")
        end)
        yIndex = yIndex + 1
    end
    if isScale9Sprite or isEditBox then
        -- CapInsets
        self:createLabel("CapInsets", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(math.round(node.__info.capInsets.x)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.x", input, "number"))
        end)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(math.round(node.__info.capInsets.y)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.y", input, "number"))
        end)
        yIndex = yIndex + 1
        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(math.round(node.__info.capInsets.width)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.width", input, "number"))
        end)
        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(math.round(node.__info.capInsets.height)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "capInsets.height", input, "number"))
        end)
        yIndex = yIndex + 1
    end
    if isScale9Sprite then
        -- RenderingType
        self:createLabel("RenderingType", leftX, topY - stepY * yIndex)
        local types = { "SIMPLE", "SLICE" }
        self:createSelectBox(types, node.__info.renderingType + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "renderingType", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- state
        self:createLabel("State", leftX, topY - stepY * yIndex)
        local types = { "NORMAL", "GRAY" }
        self:createSelectBox(types, node.__info.state + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "state", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- flippedX
        self:createLabel("FippedX", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.flippedX == 0, leftX_input_1, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedX", selected, "number")
        end)
        -- flippedY
        self:createLabel("FippedY", leftX_input_short_2, topY - stepY * yIndex)
        self:createCheckBox(node.__info.flippedY == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "flippedY", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    if isZoomButton or isSpriteButton then
        if isZoomButton then
            -- zoomScale
            self:createLabel("ZoomScale", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.zoomScale), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "zoomScale", input, "number"))
            end)
            yIndex = yIndex + 1
            -- ZoomEnabled
            self:createLabel("ZoomEnabled", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.zoomEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "zoomEnabled", selected, "number")
            end)
            yIndex = yIndex + 1
        end
        if isToggleButton then
            -- AutoToggle
            self:createLabel("AutoToggle", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.autoToggle == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "autoToggle", selected, "number")
            end)
            yIndex = yIndex + 1
        end
        -- enabled
        self:createLabel("Enabled", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.enabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enabled", selected, "number")
        end)
        yIndex = yIndex + 1
    end
    if isCheckBox then
        createTitle("CheckBox")
        -- Selected
        self:createLabel("Selected", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.selected == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "selected", selected, "number")
        end)
        yIndex = yIndex + 1
        self:createLabel("BackGround", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.backGround), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "backGround", input, "string"))
        end)
        yIndex = yIndex + 1
        self:createLabel("Cross", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.cross), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "cross", input, "string"))
        end)
        yIndex = yIndex + 1
    end
    --------------------------- cc.Label   ---------------------------
    if isLabel then
        local items = gk.resource.lans
        for _, lan in ipairs(items) do
            if lan ~= gk.resource:getCurrentLan() then
                --            local lan = gk.resource:getCurrentLan()
                local fontFile = node.__info.fontFile[lan]
                local isTTF = gk.isTTF(fontFile)
                local isBMFont = gk.isBMFont(fontFile)
                local isSystemFont = not isTTF and not isBMFont
                --            createTitle(string.format("Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")))
                local label = createTitle(string.format("Label_%s(%s)", lan, isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")))
                label:setOpacity(150)
                -- font file
                local label = self:createLabel("FontFile", leftX, topY - stepY * yIndex)
                label:setOpacity(150)
                local fonts = clone(gk.resource.fontFiles)
                local font = isSystemFont and tostring(node:getSystemFontName()) or tostring(node.__info.fontFile[lan])
                if not table.indexof(fonts, font) then
                    table.insert(fonts, font)
                end
                self:createSelectAndInput(font, fonts, table.indexof(fonts, font),
                    leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
                        editBox:setInput(generator:modify(node, "fontFile." .. lan, input, "string"))
                        gk.event:post("displayNode", node)
                    end)
                yIndex = yIndex + 1
            end
        end

        local lan = gk.resource:getCurrentLan()
        local fontFile = node.__info.fontFile[lan]
        local isTTF = gk.isTTF(fontFile)
        local isBMFont = gk.isBMFont(fontFile)
        local isSystemFont = not isTTF and not isBMFont
        createTitle(string.format("Label_%s(%s)", lan, isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")))
        -- font file
        self:createLabel("FontFile", leftX, topY - stepY * yIndex)
        local fonts = clone(gk.resource.fontFiles)
        local font = isSystemFont and tostring(node:getSystemFontName()) or tostring(node.__info.fontFile[lan])
        if not table.indexof(fonts, font) then
            table.insert(fonts, font)
        end
        self:createSelectAndInput(font, fonts, table.indexof(fonts, font),
            leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
                editBox:setInput(generator:modify(node, "fontFile." .. lan, input, "string"))
                gk.event:post("displayNode", node)
            end)
        yIndex = yIndex + 1

        -- string
        self:createLabel("String", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.string), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, "string", input, "string"))
        end, "")
        yIndex = yIndex + 1
        -- overflow
        -- System font only support Overflow::NONE and Overflow::RESIZE_HEIGHT.
        self:createLabel("Overflow", leftX, topY - stepY * yIndex)
        local overflows = { "NONE", "CLAMP", "SHRINK", "RESIZE_HEIGHT" }
        local values = { 0, 1, 2, 3 }
        if isSystemFont then
            overflows = { "NONE", "RESIZE_HEIGHT" }
            values = { 0, 3 }
        end
        self:createSelectBox(overflows, table.indexof(values, node.__info.overflow), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "overflow", values[index], "number")
        end, "NONE")
        yIndex = yIndex + 1
        -- dimensions
        self:createLabel("Dimensions", leftX, topY - stepY * yIndex)
        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "width", input, "number"))
        end, 0)
        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "height", input, "number"))
        end, 0)
        yIndex = yIndex + 1
        -- alignment
        self:createLabel("Alignment", leftX, topY - stepY * yIndex)
        self:createLabel("H", leftX_input_1_left, topY - stepY * yIndex)
        local hAligns = { "LEFT", "CENTER", "RIGHT" }
        self:createSelectBox(hAligns, node.__info.hAlign + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "hAlign", index - 1, "number")
        end, "LEFT")
        self:createLabel("V", leftX_input_2_left, topY - stepY * yIndex)
        local vAligns = { "TOP", "CENTER", "BOTTOM" }
        self:createSelectBox(vAligns, node.__info.vAlign + 1, leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "vAlign", index - 1, "number")
        end, "TOP")
        yIndex = yIndex + 1
        -- maxLineWidth
        --        if node.__info.maxLineWidth then
        --            self:createLabel("MaxLineWidth", leftX, topY - stepY * yIndex)
        --            self:createInput(tostring(node.__info.maxLineWidth), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --                editBox:setInput(generator:modify(node, "maxLineWidth", input, "number"))
        --            end)
        --            yIndex = yIndex + 1
        --        end
        -- lineHeight, Not support system font.
        if not isSystemFont and node.__info.lineHeight then
            self:createLabel("LineHeight", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.lineHeight), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "lineHeight", input, "number"))
            end, -1)
            yIndex = yIndex + 1
        end
        -- font size
        self:createLabel("FontSize", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.fontSize), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "fontSize", input, "number"))
        end)
        yIndex = yIndex + 1
        if not isSystemFont and node.__info.lineHeight then
            --additionalKerning
            self:createLabel("AdditionalKerning", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.additionalKerning), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "additionalKerning", input, "number"))
            end, 0)
            yIndex = yIndex + 1
        end
        if not isBMFont and node.__info.textColor then
            -- color
            self:createLabel("TextColor4B", leftX, topY - stepY * yIndex)
            self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.textColor.r), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.r", input, "number"))
            end, 255)
            self:createLabel("G", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.textColor.g), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.g", input, "number"))
            end, 255)
            yIndex = yIndex + 1
            self:createLabel("B", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.textColor.b), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.b", input, "number"))
            end, 255)
            self:createLabel("A", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.textColor.a), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "textColor.a", input, "number"))
            end, 255)
            yIndex = yIndex + 1
        end
        if not isSystemFont then
            -- enableWrap
            self:createLabel("EnableWrap", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.enableWrap == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "enableWrap", selected, "number")
            end)
            yIndex = yIndex + 1
        end
        -- lineBreakWithoutSpace
        self:createLabel("LineBreakWithoutSpace", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.lineBreakWithoutSpace == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "lineBreakWithoutSpace", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableShadow
        self:createLabel("enableShadow", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.enableShadow == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableShadow", selected, "number")
            gk.event:post("displayNode", node)
        end)
        yIndex = yIndex + 1
        if node.__info.enableShadow == 0 and node.__info.shadow then
            -- shadowColor
            self:createLabel("Color4B", leftX, topY - stepY * yIndex)
            self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.r), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.r", input, "number"))
            end, 0)
            self:createLabel("G", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.g), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.g", input, "number"))
            end, 0)
            yIndex = yIndex + 1
            self:createLabel("B", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.b), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.b", input, "number"))
            end, 0)
            self:createLabel("A", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.a), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.a", input, "number"))
            end, 0)
            yIndex = yIndex + 1
            -- offset
            self:createLabel("Offset", leftX, topY - stepY * yIndex)
            self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.w), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.w", input, "number"))
            end, 0)
            self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.h), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.h", input, "number"))
            end, 0)
            yIndex = yIndex + 1
            -- blurRadius
            self:createLabel("BlurRadius", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.shadow.radius), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "shadow.radius", input, "number"))
            end, 0)
            yIndex = yIndex + 1
        end
        if isTTF then
            -- enableGlow
            self:createLabel("enableGlow", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.enableGlow == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "enableGlow", selected, "number")
                gk.event:post("displayNode", node)
            end)
            yIndex = yIndex + 1
        end
        if isTTF then
            -- enableOutline
            local lb = self:createLabel("enableOutline", leftX, topY - stepY * yIndex)
            local cb = self:createCheckBox(node.__info.enableOutline == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "enableOutline", selected, "number")
                gk.event:post("displayNode", node)
            end)
            yIndex = yIndex + 1
        end
        if (node.__info.enableOutline == 0 and (isTTF or isSystemFont)) or (node.__info.enableGlow == 0 and isTTF) then
            -- shadowColor
            self:createLabel("Color4B", leftX, topY - stepY * yIndex)
            self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.effectColor.r), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.r", input, "number"))
            end)
            self:createLabel("G", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.effectColor.g), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.g", input, "number"))
            end)
            yIndex = yIndex + 1
            self:createLabel("B", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.effectColor.b), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.b", input, "number"))
            end)
            self:createLabel("A", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.effectColor.a), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "effectColor.a", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        if isTTF and node.__info.enableOutline == 0 then
            -- outlineSize
            self:createLabel("OutlineSize", leftX, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.outlineSize), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "outlineSize", input, "number"))
            end)
            yIndex = yIndex + 1
        end
        -- enableItalics
        self:createLabel("enableItalics", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.enableItalics == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableItalics", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableBold
        self:createLabel("enableBold", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.enableBold == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableBold", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableUnderline
        self:createLabel("enableUnderline", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.enableUnderline == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableUnderline", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableStrikethrough
        self:createLabel("enableStrikethrough", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.enableStrikethrough == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableStrikethrough", selected, "number")
        end)
        yIndex = yIndex + 1
        -- clipMarginEnabled
        --        self:createLabel("ClipMarginEnabled", leftX, topY - stepY * yIndex)
        --        self:createCheckBox(node.__info.clipMarginEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
        --            generator:modify(node, "clipMarginEnabled", selected, "number")
        --        end)
        --        yIndex = yIndex + 1
    end

    --------------------------- cc.ScrollView, cc.TableView  ---------------------------
    if isScrollView then
        createTitle(isTableView and "TableView" or "ScrollView")

        -- viewSize
        self:createLabel("ViewSize", leftX, topY - stepY * yIndex)
        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.viewSize.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "viewSize.width", input, "number"))
        end)
        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.viewSize.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "viewSize.height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- scaleViewSize
        self:createLabel("ScaleViewSize", leftX, topY - stepY * yIndex)
        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
        self:createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleViewSize.w)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleViewSize.w", scaleWs[index], "string")
        end, "1")
        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
        self:createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleViewSize.h)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "scaleViewSize.h", scaleHs[index], "string")
        end, "1")
        yIndex = yIndex + 1
        -- Direction
        self:createLabel("Direction", leftX, topY - stepY * yIndex)
        local directions = { "HORIZONTAL", "VERTICAL", "BOTH" }
        self:createSelectBox(directions, node.__info.direction + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "direction", index - 1, "number")
        end, "BOTH")
        yIndex = yIndex + 1
        if isTableView then
            -- verticalFillOrder
            self:createLabel("FillOrder", leftX, topY - stepY * yIndex)
            local verticalFillOrders = { "TOP_DOWN", "BOTTOM_UP" }
            self:createSelectBox(verticalFillOrders, node.__info.verticalFillOrder + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, "verticalFillOrder", index - 1, "number")
            end)
            yIndex = yIndex + 1
        end
        self:createLabel("ContentOff", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        local w = self:createInput(node.__info.contentOffset.x, leftX_input_1, topY - stepY *
                yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "contentOffset.x", input, "number"))
        end)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        local h = self:createInput(node.__info.contentOffset.y, leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "contentOffset.y", input, "number"))
        end)
        yIndex = yIndex + 1
        -- ScaleOffset
        self:createLabel("ScaleOffset", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
        self:createSelectBox(scaleWs, table.indexof(scaleWs, tostring(node.__info.scaleOffset.x)), leftX_input_1, topY - stepY * yIndex, inputMiddle,
            function(index)
                generator:modify(node, "scaleOffset.x", scaleWs[index], "string")
            end, 1)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
        self:createSelectBox(scaleHs, table.indexof(scaleHs, tostring(node.__info.scaleOffset.y)), leftX_input_2, topY - stepY * yIndex, inputMiddle,
            function(index)
                generator:modify(node, "scaleOffset.y", scaleHs[index], "string")
            end, 1)
        yIndex = yIndex + 1

        -- ClipToBD
        self:createLabel("ClipToBD", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.clipToBD == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "clipToBD", selected, "number")
        end)
        yIndex = yIndex + 1
        -- Bounceable
        self:createLabel("Bounceable", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.bounceable == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "bounceable", selected, "number")
        end)
        yIndex = yIndex + 1
        -- touchEnabled
        self:createLabel("Enabled", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.touchEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "touchEnabled", selected, "number")
        end)
        yIndex = yIndex + 1
        -- scroll event
        self:createLabel("DidScroll", leftX, topY - stepY * yIndex)
        local funcs = { "-" }
        for key, value in pairs(self.parent.scene.layer.class) do
            if type(value) == "function" and key:sub(1, 2) == "on" then
                table.insert(funcs, "&" .. key)
            end
        end
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info.didScroll)), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, "didScroll", funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1
    end

    --------------------------- cc.Layer   ---------------------------
    if isLayer and not isLayerColor and not isScrollView then
        if isgkDialog then
            createTitle("gkDialog")
        elseif isgkLayer then
            createTitle("gkLayer")
        else
            createTitle("Layer")
        end
    end

    if isgkLayer or isgkDialog then
        -- touchEnabled
        self:createLabel("TouchEnabled", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.touchEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "touchEnabled", selected, "number")
        end)
        yIndex = yIndex + 1
        -- swallowTouches
        self:createLabel("SwallowTouches", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.swallowTouches == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "swallowTouches", selected, "number")
        end)
        yIndex = yIndex + 1
        -- enableKeyPad
        local w = self:createLabel("EnableKeyPad", leftX, topY - stepY * yIndex)
        local h = self:createCheckBox(node.__info.enableKeyPad == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "enableKeyPad", selected, "number")
        end)
        yIndex = yIndex + 1
        -- popOnBack
        self:createLabel("PopOnBack", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.popOnBack == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "popOnBack", selected, "number")
        end)
        yIndex = yIndex + 1
        if isgkDialog then
            self:createLabel("PopOnTouchInsideBg", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.popOnTouchInsideBg == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "popOnTouchInsideBg", selected, "number")
            end)
            yIndex = yIndex + 1
            self:createLabel("PopOnTouchOutsideBg", leftX, topY - stepY * yIndex)
            self:createCheckBox(node.__info.popOnTouchOutsideBg == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                generator:modify(node, "popOnTouchOutsideBg", selected, "number")
            end)
            yIndex = yIndex + 1
        end
    end

    if isClippingNode then
        createTitle("ClippingNode")
        --        -- stencil
        --        self:createLabel("StencilID", leftX, topY - stepY * yIndex)
        --        self:createInput(tostring(node.__info.stencil), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --            editBox:setInput(generator:modify(node, "stencil", input, "string"))
        --        end)
        --        yIndex = yIndex + 1
        -- alphaThreshold
        self:createLabel("AlphaThreshold", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.alphaThreshold), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "alphaThreshold", input, "number"))
        end)
        yIndex = yIndex + 1
        -- inverted
        self:createLabel("Inverted", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.inverted == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "inverted", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    if isProgressTimer then
        createTitle("ProgressTimer")
        -- reverseDirection
        self:createLabel("RreverseDirection", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.reverseDirection == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "reverseDirection", selected, "number")
        end)
        yIndex = yIndex + 1
        -- barType
        self:createLabel("BarType", leftX, topY - stepY * yIndex)
        local types = { "RADIAL", "BAR" }
        self:createSelectBox(types, node.__info.barType + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, "barType", index - 1, "number")
        end)
        yIndex = yIndex + 1
        -- percentage
        self:createLabel("Percentage", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.percentage), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "percentage", input, "number"))
        end)
        yIndex = yIndex + 1
        -- midpoint
        self:createLabel("Midpoint", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.midpoint.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "midpoint.x", input, "number"))
        end)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.midpoint.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "midpoint.y", input, "number"))
        end)
        yIndex = yIndex + 1
        if node.__info.barType == 1 then
            -- barChangeRate
            self:createLabel("ChangeRate", leftX, topY - stepY * yIndex)
            self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.barChangeRate.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "barChangeRate.x", input, "number"))
            end)
            self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
            self:createInput(tostring(node.__info.barChangeRate.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, "barChangeRate.y", input, "number"))
            end)
            yIndex = yIndex + 1
        end
    end

    if isClippingRectangleNode then
        createTitle("ClippingRectangleNode")
        -- ClippingRegion
        self:createLabel("ClipRegion", leftX, topY - stepY * yIndex)
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.clippingRegion.x), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.x", input, "number"))
        end)
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.clippingRegion.y), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.y", input, "number"))
        end)
        yIndex = yIndex + 1
        self:createLabel("W", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.clippingRegion.width), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.width", input, "number"))
        end)
        self:createLabel("H", leftX_input_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.clippingRegion.height), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "clippingRegion.height", input, "number"))
        end)
        yIndex = yIndex + 1
        -- clippingEnabled
        self:createLabel("ClippingEnabled", leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info.clippingEnabled == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, "clippingEnabled", selected, "number")
        end)
        yIndex = yIndex + 1
    end

    -- custom ext node
    for i = 1, #self.parent.exNodeDisplayer do
        local ext = self.parent.exNodeDisplayer[i]
        if node.__info.type == ext:type() or gk.util:instanceof(node, ext:type()) then
            createTitle(ext:title())
            local stringProps = ext:stringProps()
            if stringProps then
                for i = 1, #stringProps do
                    local prop = stringProps[i]
                    local key = prop:key()
                    self:createLabel(prop:title(), leftX, topY - stepY * yIndex)
                    self:createInput(tostring(node.__info[key]), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
                        editBox:setInput(generator:modify(node, key, input, "string"))
                    end)
                    yIndex = yIndex + 1
                end
            end
            local boolProps = ext:boolProps()
            if boolProps then
                for i = 1, #boolProps do
                    local prop = boolProps[i]
                    local key = prop:key()
                    self:createLabel(prop:title(), leftX, topY - stepY * yIndex)
                    self:createCheckBox(node.__info[key] == 0, checkbox_right, topY - stepY * yIndex, function(selected)
                        generator:modify(node, key, selected, "number")
                    end)
                    yIndex = yIndex + 1
                end
            end
        end
    end

    self.displayInfoNode:setContentSize(cc.size(gk.display.height(), stepY * yIndex + 20))
    if self.disabled then
        self.displayInfoNode:setOpacity(150)
        gk.util:setRecursiveCascadeOpacityEnabled(self.displayInfoNode, true)
    end

    -- keep last scroll offset
    if (self.lastDisplayNodeId == node.__info.id or self.lastDisplayNodeType == node.__info.type) and self.lastDisplayInfoOffset then
        local y = self.lastDisplayInfoOffset.y
        y = cc.clampf(y, 0, self.displayInfoNode:getContentSize().height - self:getContentSize().height)
        self.lastDisplayInfoOffset.y = y
        self.displayInfoNode:setPosition(self.lastDisplayInfoOffset)
    else
        self.lastDisplayInfoOffset = cc.p(0, 0)
        self.displayInfoNode:setPosition(self.lastDisplayInfoOffset)
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