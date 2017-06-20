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
        gk.util:drawLineOnNode(self, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -999)
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

local onLabelInputChanged = function(node, label, input)
    local isMacro = true
    repeat
        local v = generator:parseMacroFunc(node, input)
        if v then
            break
        end
        v = generator:parseCustomMacroFunc(node, input)
        if v then
            break
        end
        if type(input) == "string" then
            if gk.isTTF(input) or gk.isBMFont(input) then
                break
            end
            local lower = input:lower()
            if lower:ends(".png") or lower:ends(".jpg") or lower:ends(".jpeg") then
                local _, find = gk.create_sprite(input)
                if find then
                    break
                end
            elseif lower:ends(".plist") then
                if cc.FileUtils:getInstance():isFileExist(input) then
                    break
                end
            end
            if string.len(input) > 0 and input:sub(1, 1) == "@" then
                v = gk.resource:getString(input:sub(2, #input))
                if v ~= "undefined" then
                    break
                end
            end
        end
        if gk.audio:isValidEvent(input) then
            break
        end
        isMacro = false
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

function panel:createInput(content, x, y, width, callback, defValue, lines)
    lines = lines or 1
    local node = gk.EditBox:create(cc.size(width / scale, 16 / scale * lines))
    node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 20, 20, 20)))
    local label = cc.Label:createWithTTF(content, fontName, fontSize)
    label:setTextColor(cc.c3b(0, 0, 0))
    node:setInputLabel(label)
    local contentSize = node:getContentSize()
    label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2 - 5))
    label:setDimensions(contentSize.width - 15, contentSize.height)
    self.displayInfoNode:addChild(node)
    node:setScale(scale)
    node:onEditEnded(function(...)
        callback(...)
    end)
    node:onInputChanged(function(_, input)
        onLabelInputChanged(self.displayingNode, label, input)
        onValueChanged(node.bg, defValue, input)
    end)
    onLabelInputChanged(self.displayingNode, label, content)
    onValueChanged(node.bg, defValue, content)
    node:setAnchorPoint(0, 1)
    node:setPosition(x, y + 16 / 2)
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
        onLabelInputChanged(self.displayingNode, label, input)
        onValueChanged(node.bg, defValue, input)
    end)
    onLabelInputChanged(self.displayingNode, label, content)
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
    label:setTextColor(cc.c3b(0x33, 0x33, 166))
    label:setRotation(90)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    local button = gk.ZoomButton.new(label)
    button:setScale(1, 0.8)
    button:setPosition(contentSize.width - 15, contentSize.height / 2)
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
        onLabelInputChanged(self.displayingNode, label, items[index])
        onValueChanged(node.bg, defValue, items[index])
        --            label:setTextColor(getMacroColor(items[index]))
    end)
    onLabelInputChanged(self.displayingNode, label, items[index])
    onValueChanged(node.bg, defValue, items[index])
    --        label:setTextColor(getMacroColor(items[index]))
    node.isEnabled = not self.disabled

    local contentSize = node:getContentSize()
    local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
    label:setTextColor(cc.c3b(0x33, 0x33, 166))
    label:setRotation(90)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    local button = gk.ZoomButton.new(label)
    button:setScale(1, 0.8)
    button:setPosition(contentSize.width - 15, contentSize.height / 2)
    node:addChild(button, 999)
    button:setAnchorPoint(1, 0.5)
    button:onClicked(function()
        if node.isEnabled then
            node:openPopup()
        end
    end)
    return node
end

function panel:createLine(y)
    y = y + 12
    gk.util:drawLineOnNode(self.displayInfoNode, cc.p(10, y), cc.p(self.contentSize.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -999)
end

function panel:displayNode(node)
    self:undisplayNode()
    if not node.__info then
        return
    end
    local size = self:getContentSize()
    self.contentSize = size
    self.disabled = node.__rootTable and node.__rootTable.__info and node.__rootTable.__info._isWidget
    self.displayingNode = node

    local topY = size.height - 20
    local stepY = 25
    local gapX = 20 -- "X" width
    local leftX = 15 -- margin left
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
    local isCheckBox = gk.util:instanceof(node, "CheckBox")
    local isEditBox = gk.util:instanceof(node, "ccui.EditBox")
    local isClippingRectangleNode = gk.util:instanceof(node, "cc.ClippingRectangleNode")
    local isProgressTimer = gk.util:instanceof(node, "cc.ProgressTimer")
    local isClippingNode = gk.util:instanceof(node, "cc.ClippingNode")
    local isTmxTiledMap = gk.util:instanceof(node, "cc.TMXTiledMap")
    local isParticleSystemQuad = gk.util:instanceof(node, "cc.ParticleSystemQuad")
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

    local function createInputLong(title, key, type, default)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info[key]), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(generator:modify(node, key, input, type))
        end, default)
        yIndex = yIndex + 1
    end

    local function createInputMiddle(title, l, r, lkey, rkey, type, ldefault, rdefault)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        local linput, rinput
        if lkey then
            local lkeys = string.split(lkey, ".")
            local lvar = #lkeys == 1 and node.__info[lkey] or node.__info[lkeys[1]][lkeys[2]]
            self:createLabel(l, leftX_input_1_left, topY - stepY * yIndex)
            linput = self:createInput(tostring(lvar), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, lkey, input, type))
            end, ldefault)
        end
        if rkey then
            local rkeys = string.split(rkey, ".")
            local rvar = #rkeys == 1 and node.__info[rkey] or node.__info[rkeys[1]][rkeys[2]]
            self:createLabel(r, leftX_input_2_left, topY - stepY * yIndex)
            rinput = self:createInput(tostring(rvar), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
                editBox:setInput(generator:modify(node, rkey, input, type))
            end, rdefault)
        end
        yIndex = yIndex + 1
        return linput, rinput
    end

    local function createSelectBox(title, l, r, lkey, rkey, lvars, rvars, type, ldefault, rdefault)
        local lkeys = string.split(lkey, ".")
        local lvar = #lkeys == 1 and node.__info[lkey] or node.__info[lkeys[1]][lkeys[2]]
        self:createLabel(title, leftX, topY - stepY * yIndex)
        self:createLabel(l, leftX_input_1_left, topY - stepY * yIndex)
        self:createSelectBox(lvars, table.indexof(lvars, tostring(lvar)), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            generator:modify(node, lkey, lvars[index], type)
        end, ldefault)
        if rkey then
            local rkeys = string.split(rkey, ".")
            local rvar = #rkeys == 1 and node.__info[rkey] or node.__info[rkeys[1]][rkeys[2]]
            self:createLabel(r, leftX_input_2_left, topY - stepY * yIndex)
            self:createSelectBox(rvars, table.indexof(rvars, tostring(rvar)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
                generator:modify(node, rkey, rvars[index], type)
            end, rdefault)
        end
        yIndex = yIndex + 1
    end

    local function createSelectBoxLong(title, vars, key, type, default, callback)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        self:createSelectBox(vars, node.__info[key] + 1, leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, key, index - 1, type)
            if callback then
                callback()
            end
        end, default)
        yIndex = yIndex + 1
    end

    local function createCheckBox(title, key, callback)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        self:createCheckBox(node.__info[key] == 0, checkbox_right, topY - stepY * yIndex, function(selected)
            generator:modify(node, key, selected, "number")
            if callback then
                callback()
            end
        end)
        yIndex = yIndex + 1
    end

    local function createFunc(title, key, prefix)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        local funcs = { "-" }
        local len = #prefix
        for key, value in pairs(self.parent.scene.layer.class) do
            if type(value) == "function" and #key > len and key:sub(1, len) == prefix then
                table.insert(funcs, "&" .. key)
            end
        end
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info[key])), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            generator:modify(node, key, funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1
    end

    --------------------------- ID   ---------------------------
    createInputLong("ID", "id", "string")
    if self.parent._containerNode == node or self.parent.leftPanel._containerNode then
        -- only display id when dragging
        return
    end
    createCheckBox("Lock", "_lock")
    --------------------------- cc.Node   ---------------------------
    createTitle("cc.Node")

    -- position
    if not isRootNode then
        createInputMiddle("Position", "X", "Y", "x", "y", "number", 0, 0)
        local scaleXs = { "1", "$scaleX", "$minScale", "$maxScale", "$scaleRT", "$scaleLT" }
        local scaleYs = { "1", "$scaleY", "$minScale", "$maxScale", "$scaleTP", "$scaleBT" }
        createSelectBox("ScalePos", "X", "Y", "scaleXY.x", "scaleXY.y", scaleXs, scaleYs, "string",
            generator.config.defValues["scaleXY"].x, generator.config.defValues["scaleXY"].y)
    end
    createInputMiddle("AnchorPoint", "X", "Y", "anchor.x", "anchor.y", "number")
    createCheckBox("IgnoreAnchorPoint", "ignoreAnchor")
    -- size
    if not isLabel and not isTableView then
        local w, h = createInputMiddle("ContentSize", "W", "H", "width", "height", "number")
        if (isSprite and not isScale9Sprite) or isButton then
            w:setOpacity(150)
            w:setCascadeOpacityEnabled(true)
            w.isEnabled = false
            h:setOpacity(150)
            h:setCascadeOpacityEnabled(true)
            h.isEnabled = false
        end
        if not isSprite then
            local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
            local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
            createSelectBox("ScaleSize", "W", "H", "scaleSize.w", "scaleSize.h", scaleWs, scaleHs, "string", 1, 1)
        end
    end
    if not isScrollView then
        -- scale
        self:createLabel("Scale", leftX, topY - stepY * yIndex)
        local scales = { "1", "$xScale", "$yScale", "$minScale", "$maxScale" }
        local s = tostring(node.__info.scaleX)
        if not table.indexof(scales, s) then
            table.insert(scales, s)
        end
        self:createLabel("X", leftX_input_1_left, topY - stepY * yIndex)
        self:createSelectAndInput(s, scales, table.indexof(scales, s), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleX", input, "number"))
        end, generator.config.defValues["scaleX"])
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        local scales = { "1", "$xScale", "$yScale", "$minScale", "$maxScale" }
        local s = tostring(node.__info.scaleY)
        if not table.indexof(scales, s) then
            table.insert(scales, s)
        end
        self:createSelectAndInput(s, scales, table.indexof(scales, s), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(generator:modify(node, "scaleY", input, "number"))
        end, generator.config.defValues["scaleY"])
        yIndex = yIndex + 1

        createInputMiddle("Skew", "X", "Y", "skewX", "skewY", "number", generator.config.defValues["skewX"], generator.config.defValues["skewY"])
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
    createCheckBox("CascadeOpacityEnabled", "cascadeOpacityEnabled")
    createCheckBox("CascadeColorEnabled", "cascadeColorEnabled")
    createCheckBox("Visible", "visible")

    --------------------------- cc.LayerColor   ---------------------------
    if isLayerColor then
        createTitle(isLayerGradient and "cc.LayerGradient" or "cc.LayerColor")

        if not isLayerGradient then
            -- use opacity instead of a!
            createInputMiddle("Color4B", "R", "G", "color.r", "color.g", "number", 255, 255)
            createInputMiddle("", "B", "A", "color.b", "color.a", "number", 255, 255)
        end

        if isLayerGradient then
            createInputMiddle("StartColor", "R", "G", "startColor.r", "startColor.g", "number", 255, 255)
            createInputMiddle("", "B", "A", "startColor.b", "startOpacity", "number", 255, 255)
            createInputMiddle("EndColor", "R", "G", "endColor.r", "endColor.g", "number", 255, 255)
            createInputMiddle("", "B", "A", "endColor.b", "endOpacity", "number", 255, 255)
            createInputMiddle("Vector", "X", "Y", "vector.x", "vector.y", "number")
            createCheckBox("CompressedInterpolation", "compressedInterpolation")
        end
    end

    --------------------------- cc.Sprite, ZoomButton   ---------------------------
    if isEditBox then
        createTitle("ccui.EditBox")
    end
    if isScale9Sprite then
        createTitle("ccui.Scale9Sprite")
    end
    if isSprite and not isScale9Sprite then
        createTitle("cc.Sprite")
    end
    if isSprite then
        createInputLong("Sprite", "file", "string")
    end
    if isZoomButton or isSpriteButton then
        if isSpriteButton then
            createTitle("gk.SpriteButton")
        else
            if isToggleButton then
                createTitle("gk.ToggleButton(Tag:1~n continuous)")
            elseif isZoomButton then
                createTitle("gk.ZoomButton")
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
            createFunc("onSelectTagChanged", "onSelectTagChanged", "on")
        end

        -- TODO: super class's click function
        createFunc("onClicked", "onClicked", "on")
        createFunc("onSelectChanged", "onSelectChanged", "on")
        createFunc("onEnableChanged", "onEnableChanged", "on")
        createFunc("onLongPressed", "onLongPressed", "on")
    end

    if isEditBox then
        createInputLong("PlaceHolder", "placeHolder", "string")
    end

    if isSpriteButton or isEditBox then
        createInputLong("NormalSprite", "normalSprite", "string", "")
        createInputLong("SelectSprite", "selectSprite", "string", "")
        createInputLong("DisableSprite", "disableSprite", "string", "")
    end

    if node.setBlendFunc and type(node.setBlendFunc) == "function" then
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
    end
    if isScale9Sprite or isEditBox then
        createInputMiddle("CapInsets", "X", "Y", "capInsets.x", "capInsets.y", "number")
        createInputMiddle("", "W", "H", "capInsets.width", "capInsets.height", "number")
    end
    if isScale9Sprite then
        local types = { "SIMPLE", "SLICE" }
        createSelectBoxLong("RenderingType", types, "renderingType", "number", "SLICE")
        local types = { "NORMAL", "GRAY" }
        createSelectBoxLong("State", types, "state", "number", "NORMAL")
    end
    if isSprite then
        createCheckBox("FlippedX", "flippedX")
        if isScale9Sprite then
            createCheckBox("FlippedY", "flippedY")
        end
    end

    if isZoomButton or isSpriteButton then
        if isZoomButton then
            createInputLong("ZoomScale", "zoomScale", "number")
            createCheckBox("ZoomEnabled", "zoomEnabled")
        end
        if isToggleButton then
            createCheckBox("AutoToggle", "autoToggle")
        end
        createCheckBox("Enabled", "enabled")
        createInputLong("ClickedSid", "clickedSid", "string", "")
    end
    if isCheckBox then
        createTitle("gk.CheckBox")
        createCheckBox("Selected", "selected")
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
                local label = createTitle(string.format("cc.Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")))
                label:setOpacity(150)
                -- font file
                local label = self:createLabel("FontFile_" .. lan, leftX, topY - stepY * yIndex)
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
        createTitle(string.format("cc.Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")))
        -- font file
        self:createLabel("FontFile_" .. lan, leftX, topY - stepY * yIndex)
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
        end, "", 1.6)
        yIndex = yIndex + 1.4
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
        createInputMiddle("Dimensions", "W", "H", "width", "height", "number", 0, 0)
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
            createInputMiddle("LineHeight", "", "", nil, "lineHeight", "number", 0, -1)
        end
        createInputMiddle("FontSize", "", "", nil, "fontSize", "number")
        if not isSystemFont and node.__info.lineHeight then
            createInputMiddle("AdditionalKerning", "", "", nil, "additionalKerning", "number", 0, 0)
        end
        if not isBMFont and node.__info.textColor then
            createInputMiddle("TextColor4B", "R", "G", "textColor.r", "textColor.g", "number", 255, 255)
            createInputMiddle("", "B", "A", "textColor.b", "textColor.a", "number", 255, 255)
        end
        if not isSystemFont then
            createCheckBox("EnableWrap", "enableWrap")
        end
        createCheckBox("LineBreakWithoutSpace", "lineBreakWithoutSpace")
        createCheckBox("EnableShadow", "enableShadow", function()
            gk.event:post("displayNode", node)
        end)
        if node.__info.enableShadow == 0 and node.__info.shadow then
            createInputMiddle("TextColor4B", "R", "G", "shadow.r", "shadow.g", "number", 0, 0)
            createInputMiddle("", "B", "A", "shadow.b", "shadow.a", "number", 0, 0)
            createInputMiddle("Offset", "W", "H", "shadow.w", "shadow.h", "number", 0, 0)
            createInputMiddle("BlurRadius", "", "", "shadow.radius", nil, "number", 0, 0)
        end
        if isTTF then
            createCheckBox("EnableGlow", "enableGlow")
        end
        if isTTF then
            createCheckBox("EnableOutline", "enableOutline", function()
                gk.event:post("displayNode", node)
            end)
        end
        if (node.__info.enableOutline == 0 and (isTTF or isSystemFont)) or (node.__info.enableGlow == 0 and isTTF) then
            createInputMiddle("Color4B", "R", "G", "effectColor.r", "effectColor.g", "number", 0, 0)
            createInputMiddle("", "B", "A", "effectColor.b", "effectColor.a", "number", 0, 255)
        end
        if isTTF and node.__info.enableOutline == 0 then
            createInputMiddle("OutlineSize", "", "", "outlineSize", nil, "number", 0, 0)
        end
        createCheckBox("EnableItalics", "enableItalics")
        createCheckBox("EnableBold", "enableBold")
        createCheckBox("EnableUnderline", "enableUnderline")
        createCheckBox("EnableStrikethrough", "enableStrikethrough")
    end

    --------------------------- cc.ScrollView, cc.TableView  ---------------------------
    if isScrollView then
        createTitle(isTableView and "cc.TableView" or "cc.ScrollView")
        createInputMiddle("ViewSize", "W", "H", "viewSize.width", "viewSize.height", "number")
        local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
        local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
        createSelectBox("ScaleViewSize", "W", "H", "scaleViewSize.x", "scaleViewSize.y", scaleWs, scaleHs, "string", "1", "1")
        local directions = { "HORIZONTAL", "VERTICAL", "BOTH" }
        createSelectBoxLong("Direction", directions, "direction", "number", "BOTH")
        if isTableView then
            local orders = { "TOP_DOWN", "BOTTOM_UP" }
            createSelectBoxLong("VerticalFillOrder", orders, "verticalFillOrder", "number", "BOTTOM_UP")
        end
        if not isTableView then
            createInputMiddle("ContentOffset", "X", "Y", "contentOffset.x", "contentOffset.y", "number", 0, 0)
            local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
            local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
            createSelectBox("ScaleOffset", "X", "Y", "scaleOffset.x", "scaleOffset.y", scaleWs, scaleHs, "string", "1", "1")
        end

        createCheckBox("ClipToBD", "clipToBD")
        createCheckBox("Bounceable", "bounceable")
        createCheckBox("Enabled", "touchEnabled")
        if isTableView then
            createFunc("NumOfCells", "cellNums", "cell")
            createFunc("CellSizeForIndex", "cellSizeForIndex", "cell")
            createFunc("CellAtIndex", "cellAtIndex", "cell")
            createFunc("CellTouched", "cellTouched", "cell")
        end
        createFunc("DidScroll", "didScroll", "on")
    end

    --------------------------- cc.Layer   ---------------------------
    if isLayer and not isLayerColor and not isScrollView then
        if isgkDialog then
            createTitle("gk.Dialog")
        elseif isgkLayer then
            createTitle("gk.Layer")
        else
            createTitle("cc.Layer")
        end
    end

    if isgkLayer or isgkDialog then
        createCheckBox("TouchEnabled", "touchEnabled")
        createCheckBox("SwallowTouches", "swallowTouches")
        createCheckBox("EnableKeyPad", "enableKeyPad")
        createCheckBox("PopOnBack", "popOnBack")
        if isgkDialog then
            createCheckBox("PopOnTouchInsideBg", "popOnTouchInsideBg")
            createCheckBox("PopOnTouchOutsideBg", "popOnTouchOutsideBg")
        end
    end

    if isClippingNode then
        createTitle("cc.ClippingNode")
        createInputLong("AlphaThreshold", "alphaThreshold", "number")
        createCheckBox("Inverted", "inverted")
    end

    if isProgressTimer then
        createTitle("cc.ProgressTimer")
        createCheckBox("RreverseDirection", "reverseDirection")
        local types = { "RADIAL", "BAR" }
        createSelectBoxLong("BarType", types, "barType", "number", "RADIAL", function()
            gk.event:post("displayNode", node)
        end)
        createInputLong("Percentage", "percentage", "number", 0)
        createInputMiddle("Midpoint", "X", "Y", "midpoint.x", "midpoint.y", "number", 0.5, 0.5)
        if node.__info.barType == 1 then
            createInputMiddle("ChangeRate", "X", "Y", "barChangeRate.x", "barChangeRate.y", "number")
        end
    end
    if isClippingRectangleNode then
        createTitle("cc.ClippingRectangleNode")
        createInputMiddle("ClipRegion", "X", "Y", "clippingRegion.x", "clippingRegion.y", "number")
        createInputMiddle("", "W", "H", "clippingRegion.width", "clippingRegion.height", "number")
        createCheckBox("ClippingEnabled", "clippingEnabled")
    end
    if isTmxTiledMap then
        createTitle("cc.TMXTiledMap")
        createInputLong("TMXFile", "tmx", "string")
    end
    if isParticleSystemQuad then
        createTitle("cc.ParticleSystemQuad")
        createInputLong("ParticleFile", "particle", "string")
        createInputLong("TotalParticles", "totalParticles", "string")
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
                    createInputLong(prop:title(), prop:key(), "string", prop.default and prop:default())
                end
            end
            local numProps = ext:numProps()
            if numProps then
                for i = 1, #numProps do
                    local prop = numProps[i]
                    createInputLong(prop:title(), prop:key(), "number", prop.default and prop:default())
                end
            end
            local boolProps = ext:boolProps()
            if boolProps then
                for i = 1, #boolProps do
                    local prop = boolProps[i]
                    createCheckBox(prop:title(), prop:key())
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