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
    local self = cc.LayerColor:create(gk.theme.config.backgroundColor, gk.display.rightWidth, winSize.height - gk.display.topHeight)
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
            gk.audio:playEffect(input)
            break
        end
        if gk.shader:getCachedGLProgram(input) then
            break
        end

        isMacro = false
    until true
    gk.set_label_color(label, isMacro and cc.c3b(45, 35, 255) or cc.c3b(0, 0, 0))
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
local fontName = gk.theme.font_fnt
local scale = 0.25

function panel:createLabel(content, x, y, isTitle)
    local label = gk.create_label(content, fontName, fontSize)
    label:setScale(scale)
    gk.set_label_color(label, isTitle and cc.c3b(152, 206, 0) or gk.theme.config.fontColorNormal)
    self.displayInfoNode:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setPosition(x, y)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    return label
end

function panel:createCheckBox(selected, x, y, callback)
    local node = gk.CheckBox:create("gk/res/texture/check_box_normal.png", "gk/res/texture/check_box_selected.png")
    node:setPosition(x, y)
    node:setScale(scale * 1.2)
    node:setSelected(selected)
    self.displayInfoNode:addChild(node)
    node:setAnchorPoint(0, 0.5)
    node:onSelectChanged(function(_, selected)
        callback(selected)
    end)
    node:setAnchorPoint(cc.p(1, 0.5))
    node.enabled = not self.disabled
    return node
end

function panel:createInput(content, x, y, width, callback, defValue, lines)
    lines = lines or 1
    local node = gk.EditBox:create(cc.size(width / scale, 16 / scale * lines))
    node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
    local label = gk.create_label(content, gk.theme.font_ttf, fontSize)
    gk.set_label_color(label, cc.c3b(0, 0, 0))
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
    node.enabled = not self.disabled
    return node
end

function panel:createSelectAndInput(content, items, index, x, y, width, callback, defValue)
    index = index or 1
    local node = gk.EditBox:create(cc.size(width / scale, 16 / scale))
    node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
    local label = gk.create_label(content, "gk/res/font/Consolas.ttf", fontSize)
    gk.set_label_color(label, cc.c3b(0, 0, 0))
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
    node.enabled = not self.disabled
    local input = node

    local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
    local label = gk.create_label("", fontName, fontSize)
    label:setOpacity(0)
    node:setDisplayLabel(label)
    node:onCreatePopupLabel(function()
        local label = gk.create_label("", fontName, fontSize)
        return label
    end)
    node.enabled = not self.disabled

    local contentSize = node:getContentSize()
    local label = gk.create_label("▶", fontName, fontSize)
    gk.set_label_color(label, cc.c3b(0x33, 0x33, 166))
    label:setRotation(90)
    label:setDimensions(contentSize.height, contentSize.height)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setScale(0.8, 1)
    local button = gk.ZoomButton.new(label)
    button:setPosition(contentSize.width, contentSize.height / 2)
    node:addChild(button, 999)
    button:setAnchorPoint(1, 0.5)
    button:onClicked(function()
        if node.enabled then
            node:openPopup()
        end
    end)
    button.enabled = not self.disabled
    self.displayInfoNode:addChild(node)
    node:setScale(scale)
    node:setAnchorPoint(0, 0.5)
    node:setPosition(x, y)
    node:onSelectChanged(function(index)
        callback(input, items[index])
    end)
    node.enabled = not self.disabled
    return input
end

function panel:createSelectBox(items, index, x, y, width, callback, defValue)
    index = index or 1
    local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
    node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
    local label = gk.create_label("", gk.theme.font_sys, fontSize)
    gk.set_label_color(label, cc.c3b(0, 0, 0))
    node:setMarginLeft(5)
    node:setMarginRight(22)
    node:setMarginTop(4)
    node:setDisplayLabel(label)
    node:onCreatePopupLabel(function()
        return gk.create_label("", gk.theme.font_sys, fontSize)
    end)
    self.displayInfoNode:addChild(node)
    node:setScale(scale)
    node:setAnchorPoint(0, 0.5)
    node:setPosition(x, y)
    node:onSelectChanged(function(index)
        callback(index)
        onLabelInputChanged(self.displayingNode, label, items[index])
        onValueChanged(node.bg, defValue, items[index])
    end)
    onLabelInputChanged(self.displayingNode, label, items[index])
    onValueChanged(node.bg, defValue, items[index])
    node.enabled = not self.disabled

    local contentSize = node:getContentSize()
    local label = gk.create_label("▶", fontName, fontSize)
    gk.set_label_color(label, cc.c3b(0x33, 0x33, 166))
    label:setRotation(90)
    label:setDimensions(contentSize.height, contentSize.height)
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setScale(0.8, 1)
    local button = gk.ZoomButton.new(label)
    button:setPosition(contentSize.width, contentSize.height / 2)
    node:addChild(button, 999)
    button:setAnchorPoint(1, 0.5)
    button:onClicked(function()
        if node.enabled then
            node:openPopup()
        end
    end)
    button.enabled = not self.disabled
    return node
end

function panel:createHintSelectBox(items, index, x, y, width, callback, defValue)
    local hint_width = 16
    local box = self:createSelectBox(items, index, x, y, width, callback, defValue)
    box.bg:hide()
    box.label:hide()
    box.bg:setContentSize(cc.size(hint_width / scale, box.bg:getContentSize().height))
    box.bgButton:setContentNode(box.bg)
    box.bgButton:setPositionX(box:getContentSize().width)
    box.bgButton:setAnchorPoint(1, 0.5)
    box.noneMouseMoveEffect = true
    box.focusable = false
    return box
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
    local isButton = gk.util:instanceof(node, "Button")
    local isZoomButton = gk.util:instanceof(node, "ZoomButton")
    local isSpriteButton = gk.util:instanceof(node, "SpriteButton")
    local isToggleButton = gk.util:instanceof(node, "ToggleButton")
    local isLayer = gk.util:instanceof(node, "cc.Layer")
    local isLayerColor = gk.util:instanceof(node, "cc.LayerColor")
    local isLayerGradient = gk.util:instanceof(node, "cc.LayerGradient")
    local isScrollView = gk.util:instanceof(node, "cc.ScrollView")
    local isTableView = gk.util:instanceof(node, "cc.TableView")
    local isScale9Sprite = gk.util:instanceof(node, "ccui.Scale9Sprite")
    local isCheckBox = gk.util:instanceof(node, "CheckBox")
    local isDrawNode = gk.util:instanceof(node, "DrawNode")
    local isCubicBezierNode = gk.util:instanceof(node, "CubicBezierNode")
    local isDrawPolygon = gk.util:instanceof(node, "DrawPolygon")
    local isEditBox = gk.util:instanceof(node, "ccui.EditBox")
    local isClippingRectangleNode = gk.util:instanceof(node, "cc.ClippingRectangleNode")
    local isProgressTimer = gk.util:instanceof(node, "cc.ProgressTimer")
    local isClippingNode = gk.util:instanceof(node, "cc.ClippingNode")
    local isTmxTiledMap = gk.util:instanceof(node, "cc.TMXTiledMap")
    local isParticleSystemQuad = gk.util:instanceof(node, "cc.ParticleSystemQuad")
    local isLayout = gk.util:instanceof(node, "ccui.Layout")
    local isgkLayer = gk.util:instanceof(node, "Layer")
    local isgkDialog = gk.util:instanceof(node, "Dialog")
    local isWidget = gk.util:instanceof(node, "Widget")
    local isTableViewCell = gk.util:instanceof(node, "TableViewCell")

    local isRootNode = false --self.parent.scene.layer == node

    local yIndex = 0
    local function createTitle(title)
        local label = self:createLabel(title, leftX, topY - stepY * yIndex, true)
        yIndex = yIndex + 0.8
        self:createLine(topY - stepY * yIndex)
        yIndex = yIndex + 0.2
        return label
    end

    local function createInputLong(title, key, tp, default, height)
        if not title then
            title = string.upper(key:sub(1, 1)) .. key:sub(2, key:len())
        end
        local var = node.__info[key]
        if type(tp) == "number" then
            var = math.shrink(var, 3)
        end
        self:createLabel(title, leftX, topY - stepY * yIndex)
        local editBox = self:createInput(tostring(var), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input, isNumVar)
            editBox:setInput(self:modify(node, key, input, tp, isNumVar))
            if key == "clickedSid" and gk.audio:isValidEvent(input) then
                gk.audio:playEffect(input)
            end
        end, default, height)
        yIndex = yIndex + 1
        return editBox
    end

    local function createInputMiddle(title, l, r, lkey, rkey, tp, ldefault, rdefault)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        local linput, rinput
        if lkey then
            local lkeys = string.split(lkey, ".")
            local lvar = #lkeys == 1 and node.__info[lkey] or node.__info[lkeys[1]][lkeys[2]]
            if #lkeys > 2 then
                local var = node.__info[lkeys[1]]
                for i = 2, #lkeys do
                    var = var[tonumber(lkeys[i]) and tonumber(lkeys[i]) or lkeys[i]]
                end
                lvar = var
            end
            if type(lvar) == "number" then
                lvar = math.shrink(lvar, 3)
            end
            self:createLabel(l, leftX_input_1_left, topY - stepY * yIndex)
            linput = self:createInput(tostring(lvar), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input, isNumVar)
                editBox:setInput(self:modify(node, lkey, input, tp, isNumVar))
            end, ldefault)
        end
        if rkey then
            local rkeys = string.split(rkey, ".")
            local rvar = #rkeys == 1 and node.__info[rkey] or node.__info[rkeys[1]][rkeys[2]]
            if #rkeys > 2 then
                local var = node.__info[rkeys[1]]
                for i = 2, #rkeys do
                    var = var[tonumber(rkeys[i]) and tonumber(rkeys[i]) or rkeys[i]]
                end
                rvar = var
            end
            if type(rvar) == "number" then
                rvar = math.shrink(rvar, 3)
            end
            self:createLabel(r, leftX_input_2_left, topY - stepY * yIndex)
            rinput = self:createInput(tostring(rvar), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input, isNumVar)
                editBox:setInput(self:modify(node, rkey, input, tp, isNumVar))
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
            self:modify(node, lkey, lvars[index], type)
        end, ldefault)
        if rkey then
            local rkeys = string.split(rkey, ".")
            local rvar = #rkeys == 1 and node.__info[rkey] or node.__info[rkeys[1]][rkeys[2]]
            self:createLabel(r, leftX_input_2_left, topY - stepY * yIndex)
            self:createSelectBox(rvars, table.indexof(rvars, tostring(rvar)), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
                self:modify(node, rkey, rvars[index], type)
            end, rdefault)
        end
        yIndex = yIndex + 1
    end

    local function createSelectBoxLong(title, vars, key, type, default, callback)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        self:createSelectBox(vars, type == "number" and (node.__info[key] + 1) or table.indexof(vars, node.__info[key]), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            self:modify(node, key, type == "number" and (index - 1) or vars[index], type)
            if callback then
                callback()
            end
        end, default)
        yIndex = yIndex + 1
    end

    local function createCheckBox(title, key, callback, isbool)
        self:createLabel(title, leftX, topY - stepY * yIndex)
        local select
        if isbool then
            select = node.__info[key]
        else
            select = node.__info[key] == 0
        end
        self:createCheckBox(select, checkbox_right, topY - stepY * yIndex, function(selected)
            if isbool then
                self:modify(node, key, selected, "boolean")
            else
                self:modify(node, key, selected and 0 or 1, "number")
            end
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
        table.sort(funcs)
        self:createSelectBox(funcs, table.indexof(funcs, tostring(node.__info[key])), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            self:modify(node, key, funcs[index], "string")
        end, "-")
        yIndex = yIndex + 1
    end


    --------------------------- ID   ---------------------------
    createInputLong("ID", "id", "string")
    if self.parent._containerNode == node or self.parent.leftPanel._containerNode then
        -- only display id when dragging
        return
    end
    createCheckBox("Lock(KEY_L)", "_lock", function()
        gk.event:post("displayDomTree", true)
    end)
    createCheckBox("Fold(KEY_F)", "_fold", function()
        gk.event:post("displayDomTree", true)
    end, true)
    --------------------------- cc.Node   ---------------------------
    createTitle("cc.Node")
    -- position
    if not isRootNode then
        createInputMiddle("Position", "X", "Y", "x", "y", "number", 0, 0)
        local vars = {}
        local index = 0
        local pos = cc.p(node.__info.x, node.__info.y)
        local ps = {}
        for i, p in ipairs(gk.generator.config.hintPositions) do
            table.insert(ps, { p = clone(p), desc = p.x .. ", " .. p.y })
        end

        local size
        if node == self.parent.scene.layer then
            size = gk.display:designSize()
        else
            local sx, sy = gk.util:getGlobalScale(node:getParent())
            if sx ~= 1 or sy ~= 1 or gk.util:instanceof(self.parent.scene.layer, "Widget") or gk.util:instanceof(self.parent.scene.layer, "TableViewCell") then
                if node:getParent() ~= nil then
                    size = node:getParent():getContentSize()
                else
                    size = cc.size(0,0)
                end
            else
                size = gk.display:designSize()
            end
        end
        local p = cc.p(size.width / 2, size.height / 2)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (CENTER)" })
        local p = cc.p(0, size.height)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (TOP_LEFT)" })
        local p = cc.p(size.width, size.height)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (TOP_RIGHT)" })
        local p = cc.p(0, 0)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (BOTOOM_LEFT)" })
        local p = cc.p(size.width, 0)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (BOTOOM_RIGHT)" })
        local p = cc.p(size.width / 2, pos.y)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (HORIZONTAL_CENTER)" })
        local p = cc.p(pos.x, size.height / 2)
        table.insert(ps, { p = p, desc = p.x .. ", " .. p.y .. " (VERTICAL_CENTER)" })

        for i, p in ipairs(ps) do
            vars[i] = p.desc
            if index == 0 and gk.util:table_eq(pos, p.p) then
                index = i
            end
        end
        self:createHintSelectBox(vars, index, leftX_input_1, topY - stepY * (yIndex - 1), inputLong, function(index)
            self:modifyValue(node, "x", ps[index].p.x)
            self:modifyValue(node, "y", ps[index].p.y)
        end)
    end

    local scaleXs = { "1", "$scaleX", "$minScale", "$maxScale", "$scaleRT", "$scaleLT" }
    local scaleYs = { "1", "$scaleY", "$minScale", "$maxScale", "$scaleTP", "$scaleBT" }
    createSelectBox("ScalePos", "X", "Y", "scaleXY.x", "scaleXY.y", scaleXs, scaleYs, "string",
        generator.config.defValues["scaleXY"].x, generator.config.defValues["scaleXY"].y)

    createInputMiddle("AnchorPoint", "X", "Y", "anchor.x", "anchor.y", "number")
    local vars = {
        cc.p(0, 0), cc.p(0, 1), cc.p(1, 0), cc.p(1, 1), cc.p(0.5, 0.5),
        cc.p(0.5, 0), cc.p(0.5, 1), cc.p(0, 0.5), cc.p(1, 0.5)
    }
    local anchor = node.__info.anchor
    local index = 0
    local vs = {}
    for i, a in ipairs(vars) do
        vs[i] = a.x .. ", " .. a.y
        if index == 0 and gk.util:table_eq(a, anchor) then
            index = i
        end
    end
    self:createHintSelectBox(vs, index, leftX_input_1, topY - stepY * (yIndex - 1), inputLong, function(index)
        self:modifyValue(node, "anchor", vars[index])
    end)

    createCheckBox("IgnoreAnchorPoint", "ignoreAnchor")
    -- size
    if not isLabel and not isTableView then
        local w, h = createInputMiddle("ContentSize", "W", "H", "width", "height", "number")

        local vars = {}
        local index = 0
        local size = cc.size(node.__info.width, node.__info.height)
        table.sort(gk.generator.config.hintContentSizes, function(s1, s2)
            if type(s1.width) == "string" then return true
            elseif type(s2.width) == "string" then return false
            else return s1.width < s2.width or (s1.width == s2.width and s1.height < s2.height)
            end
        end)
        for i, s in ipairs(gk.generator.config.hintContentSizes) do
            vars[i] = s.width .. ", " .. s.height
            if index == 0 and gk.util:table_eq(size, s) then
                index = i
            end
        end
        local box = self:createHintSelectBox(vars, index, leftX_input_1, topY - stepY * (yIndex - 1), inputLong, function(index)
            local size = gk.generator.config.hintContentSizes[index]
            self:modifyValue(node, "width", size.width)
            self:modifyValue(node, "height", size.height)
        end)
        if (isSprite and not isScale9Sprite) or (isButton and not isSpriteButton) then
            w:setOpacity(150)
            w:setCascadeOpacityEnabled(true)
            w.enabled = false
            h:setOpacity(150)
            h:setCascadeOpacityEnabled(true)
            h.enabled = false
            box:hide()
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
            editBox:setInput(self:modify(node, "scaleX", input, "number"))
        end, generator.config.defValues["scaleX"])
        self:createLabel("Y", leftX_input_2_left, topY - stepY * yIndex)
        local scales = { "1", "$xScale", "$yScale", "$minScale", "$maxScale" }
        local s = tostring(node.__info.scaleY)
        if not table.indexof(scales, s) then
            table.insert(scales, s)
        end
        self:createSelectAndInput(s, scales, table.indexof(scales, s), leftX_input_2, topY - stepY * yIndex, inputMiddle, function(editBox, input)
            editBox:setInput(self:modify(node, "scaleY", input, "number"))
        end, generator.config.defValues["scaleY"])
        yIndex = yIndex + 1

        createInputMiddle("Skew", "X", "Y", "skewX", "skewY", "number", generator.config.defValues["skewX"], generator.config.defValues["skewY"])
    end
    if (isLabel or isSprite or isZoomButton or isSpriteButton) and not isLayerColor then
        -- color3B
        self:createLabel("Color3B", leftX, topY - stepY * yIndex)
        self:createLabel("R", leftX_input_1_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.color.r), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(self:modify(node, "color.r", input, "number"))
        end, 255)
        self:createLabel("G", leftX_input_short_2_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.color.g), leftX_input_short_2, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(self:modify(node, "color.g", input, "number"))
        end, 255)
        self:createLabel("B", leftX_input_short_3_left, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.color.b), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(self:modify(node, "color.b", input, "number"))
        end, 255)
        yIndex = yIndex + 1
        local vars = {}
        local index = 0
        local color = node.__info.color
        table.sort(gk.generator.config.hintColor3Bs, function(s1, s2)
            return s1.c3b.r < s2.c3b.r or (s1.c3b.r == s2.c3b.r and s1.c3b.g < s2.c3b.g) or (s1.c3b.r == s2.c3b.r and s1.c3b.g == s2.c3b.g and s1.c3b.b < s2.c3b.b)
        end)
        for i, var in ipairs(gk.generator.config.hintColor3Bs) do
            local c3b = var.c3b
            vars[i] = c3b.r .. "," .. c3b.g .. "," .. c3b.b .. (string.format("(#%02x%02x%02x)%s", c3b.r, c3b.g, c3b.b, var.desc or ""))
            if index == 0 and gk.util:table_eq(c3b, color) then
                index = i
            end
        end
        self:createHintSelectBox(vars, index, leftX_input_1, topY - stepY * (yIndex - 1), inputLong, function(index)
            self:modifyValue(node, "color", gk.generator.config.hintColor3Bs[index].c3b)
        end)
    end

    if not isScrollView then
        -- rotation
        self:createLabel("Rotation", leftX, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.rotation), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(self:modify(node, "rotation", input, "number"))
        end, generator.config.defValues["rotation"])
        -- opacity
        self:createLabel("Opacity", leftX_input_short_2, topY - stepY * yIndex)
        self:createInput(tostring(node.__info.opacity), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
            editBox:setInput(self:modify(node, "opacity", input, "number"))
        end, generator.config.defValues["opacity"])
        yIndex = yIndex + 1
    end
    -- localZOrder
    self:createLabel("LocalZOrder", leftX, topY - stepY * yIndex)
    self:createInput(tostring(node.__info.localZOrder), leftX_input_1, topY - stepY * yIndex, inputShort, function(editBox, input)
        editBox:setInput(self:modify(node, "localZOrder", input, "number"))
    end, generator.config.defValues["localZOrder"])
    -- tag
    self:createLabel("Tag", leftX_input_short_2, topY - stepY * yIndex)
    self:createInput(tostring(node.__info.tag), leftX_input_short_3, topY - stepY * yIndex, inputShort, function(editBox, input)
        editBox:setInput(self:modify(node, "tag", input, "number"))
    end, generator.config.defValues["tag"])
    yIndex = yIndex + 1
    createCheckBox("CascadeOpacityEnabled", "cascadeOpacityEnabled")
    createCheckBox("CascadeColorEnabled", "cascadeColorEnabled")
    createCheckBox("Visible(KEY_V)", "visible")

    --------------------------- ccui.Layout   ---------------------------
    -- if isLayout then
    -- createTitle("ccui.Layout")
    -- local types = { "ABSOLUTE", "VERTICAL", "HORIZONTAL", "RELATIVE" }
    -- createSelectBoxLong("LayoutType", types, "layoutType", "number", "ABSOLUTE")
    -- end

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
        createInputLong("Sprite", "file", "string", "")
        --        if not isScale9Sprite then
        --            createInputMiddle("CenterRect", "X", "Y", "centerRect.x", "centerRect.y", "number", 0, 0)
        --            createInputMiddle("", "W", "H", "centerRect.width", "centerRect.height", "number", 0, 0)
        --        end
    end
    local shaders = { "ShaderPositionTextureColor_noMVP", "ShaderUIGrayScale", }
    for k, v in pairs(gk.shader.cachedGLPrograms) do
        table.insert(shaders, k)
    end
    if isButton then
        createTitle("gk.Button")
        -- TODO: super class's click function
        createFunc("onClicked", "onClicked", "on")
        createFunc("onSelectedChanged", "onSelectChanged", "on")
        createFunc("onEnableChanged", "onEnableChanged", "on")
        createFunc("onLongPressed", "onLongPressed", "on")
        createCheckBox("Enabled", "enabled")
        createInputLong("ClickSoundId", "clickedSid", "string", "")
        createSelectBoxLong("SelectedGLPgm", shaders, "selectedGLProgram", "string", "ShaderPositionTextureColor_noMVP")
        createSelectBoxLong("DisabledGLPgm", shaders, "disabledGLProgram", "string", "ShaderPositionTextureColor_noMVP")
        createCheckBox("CascadeGLProgramEnabled", "cascadeGLProgramEnabled")
    end
    if isZoomButton then
        createTitle("gk.ZoomButton")
        createInputLong("ZoomScale", "zoomScale", "number")
        createCheckBox("ZoomEnabled", "zoomEnabled")
    end
    if isSpriteButton then
        createTitle("gk.SpriteButton")
    end
    if isSpriteButton or isEditBox then
        createInputLong("NormalSprite", "normalSprite", "string", "")
        createInputLong("SelectedSprite", "selectedSprite", "string", "")
        createInputLong("DisabledSprite", "disabledSprite", "string", "")
    end
    if isScale9Sprite or isEditBox or isSpriteButton then
        createInputMiddle("CapInsets", "X", "Y", "capInsets.x", "capInsets.y", "number")
        createInputMiddle("", "W", "H", "capInsets.width", "capInsets.height", "number")
        if isSpriteButton then
            local selectModes = { "REPLACE", "OVERLAY" }
            createSelectBoxLong("SelectMode", selectModes, "selectMode", "number", "REPLACE")
        end
    end
    if isCheckBox then
        createTitle("gk.CheckBox")
        createCheckBox("Selected", "selected")
    end

    if isToggleButton then
        createTitle("gk.ToggleButton(Tag:1~n continuous)")
        createCheckBox("AutoToggle", "autoToggle")
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
            self:modify(node, "selectedTag", tags[index], "number")
        end, 1)
        yIndex = yIndex + 1
        createFunc("onSelectTagChanged", "onSelectedTagChanged", "on")
    end

    local createHintFontSize = function(key)
        local vars = {}
        local index = 0
        local size = node.__info[key]
        for i, s in ipairs(gk.generator.config.hintFontSizes) do
            vars[i] = "" .. s
            if size == s then
                index = i
            end
        end
        self:createHintSelectBox(vars, index, leftX_input_2, topY - stepY * (yIndex - 1), inputMiddle, function(index)
            self:modifyValue(node, key, gk.generator.config.hintFontSizes[index])
        end)
    end

    if isEditBox then
        createInputLong("FontName", "fontName", "string")
        local editBox = createInputLong("Text", "text", "string", "", 1.6)
        editBox:setAutoCompleteFunc(gk.resource.autoCompleteFunc)
        editBox:onCreatePopupLabel(function()
            return gk.create_label("", gk.theme.font_sys, fontSize)
        end)
        yIndex = yIndex + 0.4
        local editBox = createInputLong("Placeholder", "placeHolder", "string", "", 1.6)
        editBox:setAutoCompleteFunc(gk.resource.autoCompleteFunc)
        editBox:onCreatePopupLabel(function()
            return gk.create_label("", gk.theme.font_sys, fontSize)
        end)
        yIndex = yIndex + 0.4

        createInputMiddle("FontColor", "R", "G", "fontColor.r", "fontColor.g", "number", 255, 255)
        createInputMiddle("", "B", "A", "fontColor.b", "fontColor.a", "number", 255, 255)
        createInputMiddle("PHFontColor", "R", "G", "placeholderFontColor.r", "placeholderFontColor.g", "number", 166, 166)
        createInputMiddle("", "B", "A", "placeholderFontColor.b", "placeholderFontColor.a", "number", 166, 255)
        createInputMiddle("FontSize", "", "", nil, "fontSize", "number")
        createHintFontSize("fontSize")
        createInputMiddle("PlaceholderFontSize", "", "", nil, "placeholderFontSize", "number")
        createHintFontSize("placeholderFontSize")
        createInputMiddle("MaxLength", "", "", nil, "maxLength", "number", -1, -1)
        local hAligns = { "LEFT", "CENTER", "RIGHT" }
        createSelectBoxLong("HAlignment", hAligns, "textHAlign", "number", "LEFT")
        local modes = { "ANY", "EMAIL_ADDRESS", "NUMERIC", "PHONE_NUMBER", "URL", "DECIMAL", "SINGLE_LINE" }
        createSelectBoxLong("InputMode", modes, "inputMode", "number", "ANY")
        local modes = { "PASSWORD", "SENSITIVE", "INITIAL_CAPS_WORD", "INITIAL_CAPS_SENTENCE", "INITIAL_CAPS_ALL_CHARACTER", "LOWERCASE_ALL_CHARACTERS" }
        createSelectBoxLong("InputFlag", modes, "inputFlag", "number", "INITIAL_CAPS_ALL_CHARACTER")
        local modes = { "DEFAULT", "DONE", "SEND", "SEARCH", "GO", "NEXT" }
        createSelectBoxLong("ReturnType", modes, "returnType", "number", "DEFAULT")
    end

    -- blendFunc
    if node.setBlendFunc and type(node.setBlendFunc) == "function" then
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
            self:modify(node, "blendFunc.src", gl[FUNCS[index]], "number")
        end, "ONE")
        yIndex = yIndex + 1
        self:createLabel("D", leftX_input_1_left, topY - stepY * yIndex)
        self:createSelectBox(FUNCS, getIndex(node.__info.blendFunc.dst), leftX_input_1, topY - stepY * yIndex, inputLong, function(index)
            self:modify(node, "blendFunc.dst", gl[FUNCS[index]], "number")
        end, "ONE_MINUS_SRC_ALPHA")
        yIndex = yIndex + 1
    end
    if isScale9Sprite then
        local types = { "SIMPLE", "SLICE" }
        createSelectBoxLong("RenderingType", types, "renderingType", "number", "SLICE")
        local types = { "NORMAL", "GRAY" }
        createSelectBoxLong("State", types, "state", "number", "NORMAL")
    end
    if isSprite then
        createCheckBox("FlippedX", "flippedX")
        createCheckBox("FlippedY", "flippedY")
        createSelectBoxLong("GLProgram", shaders, "GLProgram", "string", "ShaderPositionTextureColor_noMVP")
    end

    --------------------------- cc.Label   ---------------------------
    if isLabel then
        local lan = gk.resource:getCurrentLan()
        local fontFile = node.__info.fontFile[lan]
        if fontFile == nil then
            fontFile = gk.resource:getDefaultFont(lan)
        end
        local isTTF = gk.isTTF(fontFile)
        local isBMFont = gk.isBMFont(fontFile)
        local isCharMap = gk.isCharMap(fontFile)
        local isSystemFont = not isTTF and not isBMFont and not isCharMap
        createTitle(string.format("cc.Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or (isCharMap and "CharMap" or "SystemFont"))))
        -- font file
        self:createLabel("FontFile_" .. lan, leftX, topY - stepY * yIndex)
        local fonts = clone(gk.resource.fontFiles)
        local font = isSystemFont and tostring(node:getSystemFontName()) or tostring(fontFile)
        if not table.indexof(fonts, font) then
            table.insert(fonts, font)
        end
        self:createSelectAndInput(font, fonts, table.indexof(fonts, font),
            leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
                editBox:setInput(self:modify(node, "fontFile." .. lan, input, "string"))
                gk.event:post("displayNode", node)
            end)
        yIndex = yIndex + 1

        -- string
        self:createLabel("String", leftX, topY - stepY * yIndex)
        local editBox = self:createInput(tostring(node.__info.string), leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
            editBox:setInput(self:modify(node, "string", input, "string"))
        end, "", 1.6)
        editBox:setAutoCompleteFunc(gk.resource.autoCompleteFunc)
        editBox:onCreatePopupLabel(function()
            return gk.create_label("", gk.theme.font_sys, fontSize)
        end)

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
            self:modify(node, "overflow", values[index], "number")
        end, "NONE")
        yIndex = yIndex + 1
        createInputMiddle("Dimensions", "W", "H", "width", "height", "number", 0, 0)
        -- alignment
        self:createLabel("Alignment", leftX, topY - stepY * yIndex)
        self:createLabel("H", leftX_input_1_left, topY - stepY * yIndex)
        local hAligns = { "LEFT", "CENTER", "RIGHT" }
        self:createSelectBox(hAligns, node.__info.hAlign + 1, leftX_input_1, topY - stepY * yIndex, inputMiddle, function(index)
            self:modify(node, "hAlign", index - 1, "number")
        end, "LEFT")
        self:createLabel("V", leftX_input_2_left, topY - stepY * yIndex)
        local vAligns = { "TOP", "CENTER", "BOTTOM" }
        self:createSelectBox(vAligns, node.__info.vAlign + 1, leftX_input_2, topY - stepY * yIndex, inputMiddle, function(index)
            self:modify(node, "vAlign", index - 1, "number")
        end, "TOP")
        yIndex = yIndex + 1
        -- maxLineWidth
        --        if node.__info.maxLineWidth then
        --            self:createLabel("MaxLineWidth", leftX, topY - stepY * yIndex)
        --            self:createInput(tostring(node.__info.maxLineWidth), leftX_input_1, topY - stepY * yIndex, inputMiddle, function(editBox, input)
        --                editBox:setInput(self:modify(node, "maxLineWidth", input, "number"))
        --            end)
        --            yIndex = yIndex + 1
        --        end
        -- lineHeight, Not support system font.
        if not isSystemFont and node.__info.lineHeight then
            createInputMiddle("LineHeight", "", "", nil, "lineHeight", "number", 0, -1)
        end
        if not isCharMap then
            createInputMiddle("FontSize", "", "", nil, "fontSize", "number")
            createHintFontSize("fontSize")
        end
        if not isSystemFont and node.__info.lineHeight then
            createInputMiddle("AdditionalKerning", "", "", nil, "additionalKerning", "number", 0, 0)
        end
        if not isSystemFont then
            createInputMiddle("LineSpacing", "", "", nil, "lineSpacing", "number", 0, 0)
        end
        if not isBMFont and not isCharMap and node.__info.textColor then
            createInputMiddle("TextColor4B", "R", "G", "textColor.r", "textColor.g", "number", 255, 255)
            createInputMiddle("", "B", "A", "textColor.b", "textColor.a", "number", 255, 255)
        end
        if isCharMap then
            createInputMiddle("ItemSize", "W", "H", "itemWidth", "itemHeight", "number", 0, 0)
            createInputMiddle("StartChar", "", "", nil, "startChar", "number")
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

        local items = gk.resource.lans
        for _, lan in ipairs(items) do
            if lan ~= gk.resource:getCurrentLan() then
                --            local lan = gk.resource:getCurrentLan()
                local fontFile = node.__info.fontFile[lan]
                if fontFile == nil then
                    fontFile = gk.resource:getDefaultFont(lan)
                end
                local isTTF = gk.isTTF(fontFile)
                local isBMFont = gk.isBMFont(fontFile)
                local isCharMap = gk.isCharMap(fontFile)
                local isSystemFont = not isTTF and not isBMFont and not isCharMap
                --            createTitle(string.format("Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or "SystemFont")))
                local label = createTitle(string.format("cc.Label(%s)", isTTF and "TTF" or (isBMFont and "BMFont" or (isCharMap and "CharMap" or "SystemFont"))))
                label:setOpacity(150)
                -- font file
                local label = self:createLabel("FontFile_" .. lan, leftX, topY - stepY * yIndex)
                label:setOpacity(150)
                local fonts = clone(gk.resource.fontFiles)
                local font = isSystemFont and tostring(node:getSystemFontName()) or tostring(fontFile)
                if not table.indexof(fonts, font) then
                    table.insert(fonts, font)
                end
                self:createSelectAndInput(font, fonts, table.indexof(fonts, font),
                    leftX_input_1, topY - stepY * yIndex, inputLong, function(editBox, input)
                        editBox:setInput(self:modify(node, "fontFile." .. lan, input, "string"))
                        gk.event:post("displayNode", node)
                    end)
                yIndex = yIndex + 1
            end
        end
    end

    --------------------------- cc.ScrollView, cc.TableView  ---------------------------
    if isScrollView then
        createTitle(isTableView and "cc.TableView" or "cc.ScrollView")
        createInputMiddle("ViewSize", "W", "H", "viewSize.width", "viewSize.height", "number")
        local scaleWs = { "1", "$xScale", "$minScale", "$maxScale" }
        local scaleHs = { "1", "$yScale", "$minScale", "$maxScale" }
        createSelectBox("ScaleViewSize", "W", "H", "scaleViewSize.w", "scaleViewSize.h", scaleWs, scaleHs, "string", "1", "1")
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
    if isWidget then
        createTitle("gk.Widget(" .. node.__info.type .. ")")
        self:createLabel("-", leftX, topY - stepY * yIndex)
        yIndex = yIndex + 1
    end
    if isTableViewCell then
        createTitle("gk.TableViewCell")
        self:createLabel("-", leftX, topY - stepY * yIndex)
        yIndex = yIndex + 1
    end
    --------------------------- cc.Layer   ---------------------------
    if isLayer and not isScrollView then
        createTitle("cc.Layer")
        self:createLabel("-", leftX, topY - stepY * yIndex)
        yIndex = yIndex + 1
    end

    if isLayerColor and not isLayerGradient then
        createTitle("cc.LayerColor")
        -- use opacity instead of a!
        createInputMiddle("Color4B", "R", "G", "color.r", "color.g", "number", 255, 255)
        createInputMiddle("", "B", "A", "color.b", "color.a", "number", 255, 255)
    end
    if isLayerGradient then
        createTitle("cc.LayerGradient")
        createInputMiddle("StartColor", "R", "G", "startColor.r", "startColor.g", "number", 255, 255)
        createInputMiddle("", "B", "A", "startColor.b", "startOpacity", "number", 255, 255)
        createInputMiddle("EndColor", "R", "G", "endColor.r", "endColor.g", "number", 255, 255)
        createInputMiddle("", "B", "A", "endColor.b", "endOpacity", "number", 255, 255)
        createInputMiddle("Vector", "X", "Y", "vector.x", "vector.y", "number")
        createCheckBox("CompressedInterpolation", "compressedInterpolation")
    end
    if isgkLayer then
        createTitle("gk.Layer")
        createCheckBox("TouchEnabled", "touchEnabled")
        createCheckBox("SwallowTouches", "swallowTouches")
        createCheckBox("EnableKeyPad", "enableKeyPad")
        createCheckBox("PopOnBack", "popOnBack")
        createInputLong("Atlas", "atlas", "string")
        createCheckBox("AutoRemoveAtlas", "autoRemoveAtlas")
    end
    if isgkDialog then
        createTitle("gk.Dialog")
        createCheckBox("PopOnTouchInsideBg", "popOnTouchInsideBg")
        createCheckBox("PopOnTouchOutsideBg", "popOnTouchOutsideBg")
    end

    --------------------------- other nodes   ---------------------------
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
            createInputMiddle("BarChangeRate", "X", "Y", "barChangeRate.x", "barChangeRate.y", "number")
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
        createInputLong("PlistFile", "particle", "string", "")
        createInputLong("TotalParticles", "totalParticles", "number")
        createInputLong("DisplayFrame", "displayFrame", "string", "")
        createInputLong("Duration", "duration", "number", -1)
        createCheckBox("AutoRemoveOnFinish(ReleaseMode)", "autoRemoveOnFinish")
        createInputMiddle("Gravity", "X", "Y", "gravity.x", "gravity.y", "number", 0, 0)
        createCheckBox("BlendAdditive", "blendAdditive")
        local types = { "GRAVITY", "RADIUS" }
        createSelectBoxLong("EmitterMode", types, "emitterMode", "number", "GRAVITY")
        local types = { "FREE", "RELATIVE", "GROUPED" }
        createSelectBoxLong("PositionType", types, "positionType", "number", "FREE")
        createInputLong(nil, "speed", "number", 0)
        createInputLong(nil, "speedVar", "number", 0)
        createInputLong(nil, "tangentialAccel", "number", 0)
        createInputLong(nil, "tangentialAccelVar", "number", 0)
        createInputLong(nil, "radialAccel", "number", 0)
        createInputLong(nil, "radialAccelVar", "number", 0)
        --        createInputLong(nil, "rotationIsDir", "number", 0)
        --        createCheckBox("RotationIsDir", "rotationIsDir")
        if node.__info.emitterMode == cc.PARTICLE_MODE_RADIUS then
            createInputLong(nil, "startRadius", "number", 0)
            createInputLong(nil, "startRadiusVar", "number", 0)
            createInputLong(nil, "endRadius", "number", 0)
            createInputLong(nil, "endRadiusVar", "number", 0)
            createInputLong(nil, "rotatePerSecond", "number", 0)
            createInputLong(nil, "rotatePerSecondVar", "number", 0)
        end
        createInputMiddle("SourcePosition", "X", "Y", "sourcePosition.x", "sourcePosition.y", "number", 0, 0)
        createInputMiddle("PosVar", "X", "Y", "posVar.x", "posVar.y", "number", 0, 0)
        createInputLong(nil, "life", "number", 0)
        createInputLong(nil, "lifeVar", "number", 0)
        createInputLong(nil, "angle", "number", 0)
        createInputLong(nil, "angleVar", "number", 0)
        createInputLong(nil, "startSize", "number", 0)
        createInputLong(nil, "startSizeVar", "number", 0)
        createInputLong(nil, "endSize", "number", 0)
        createInputLong(nil, "endSizeVar", "number", 0)
        createInputMiddle("StartColor4F", "R", "G", "startColor.r", "startColor.g", "number", 0, 0)
        createInputMiddle("", "B", "A", "startColor.b", "startColor.a", "number", 0, 0)
        createInputMiddle("StartColorVar4F", "R", "G", "startColorVar.r", "startColorVar.g", "number", 0, 0)
        createInputMiddle("", "B", "A", "startColorVar.b", "startColorVar.a", "number", 0, 0)
        createInputMiddle("EndColor4F", "R", "G", "endColor.r", "endColor.g", "number", 0, 0)
        createInputMiddle("", "B", "A", "endColor.b", "endColor.a", "number", 0, 0)
        createInputMiddle("EndColorVar4F", "R", "G", "endColorVar.r", "endColorVar.g", "number", 0, 0)
        createInputMiddle("", "B", "A", "endColorVar.b", "endColorVar.a", "number", 0, 0)
        createInputLong(nil, "startSpin", "number", 0)
        createInputLong(nil, "startSpinVar", "number", 0)
        createInputLong(nil, "endSpin", "number", 0)
        createInputLong(nil, "endSpinVar", "number", 0)
        createInputLong(nil, "emissionRate", "number", 0)
    end

    --------------------------- custom node displayer   ---------------------------
    local getTitle = function(prop)
        if not prop.title then
            local key = prop.key
            return string.upper(key:sub(1, 1)) .. key:sub(2, key:len())
        end
        return prop.title
    end
    for i = 1, #gk.exNodeDisplayer do
        local ext = gk.exNodeDisplayer[i]
        if node.__info.type == ext.type or gk.util:instanceof(node, ext.type) then
            createTitle(ext.title or ext.type)
            local stringProps = ext.stringProps
            if stringProps then
                for i = 1, #stringProps do
                    local prop = stringProps[i]
                    createInputLong(getTitle(prop), prop.key, "string", prop.default)
                end
            end
            local numProps = ext.numProps
            if numProps then
                for i = 1, #numProps do
                    local prop = numProps[i]
                    createInputLong(getTitle(prop), prop.key, "number", prop.default)
                end
            end
            local pairProps = ext.pairProps
            if pairProps then
                for i = 1, #pairProps do
                    local prop = pairProps[i]
                    createInputMiddle(prop.titles[1], prop.titles[2], prop.titles[3], prop.keys[1], prop.keys[2], "number", prop.defaults and prop.defaults[1], prop.defaults and prop.defaults[2])
                end
            end
            local selectProps = ext.selectProps
            if selectProps then
                for i = 1, #selectProps do
                    local prop = selectProps[i]
                    createSelectBoxLong(getTitle(prop), prop.selects, prop.key, prop.type, prop.default)
                end
            end
            local arrayProps = ext.arrayProps
            if arrayProps then
                for i = 1, #arrayProps do
                    local prop = arrayProps[i]
                    local numprop = prop.numProp
                    createInputLong(getTitle(numprop), numprop.key, "number", numprop.default)
                    for j = 1, node.__info[numprop.key] do
                        createInputMiddle(string.format(prop.titles[1], j), prop.titles[2], prop.titles[3], string.format(prop.keys[1], j), string.format(prop.keys[2], j), "number")
                    end
                end
            end
            local boolProps = ext.boolProps
            if boolProps then
                for i = 1, #boolProps do
                    local prop = boolProps[i]
                    createCheckBox(getTitle(prop), prop.key)
                end
            end
        end
    end

    --------------------------- draw nodes   ---------------------------
    if isCubicBezierNode then
        createTitle("gk.CubicBezierNode")
        createInputMiddle("Segments", "", "", "segments", nil, "number")
        createInputMiddle("CurvesNum", "", "", "curvesNum", nil, "number")
        createInputMiddle("Origin", "X", "Y", "origin.x", "origin.y", "number")
        for i = 1, node.__info.curvesNum do
            createInputMiddle("C" .. (i * 2 - 1), "X", "Y", "destination." .. i .. ".c1.x", "destination." .. i .. ".c1.y", "number")
            createInputMiddle("C" .. (i * 2), "X", "Y", "destination." .. i .. ".c2.x", "destination." .. i .. ".c2.y", "number")
            createInputMiddle("P" .. i, "X", "Y", "destination." .. i .. ".dst.x", "destination." .. i .. ".dst.y", "number")
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

function panel:modify(node, property, input, valueType, notPostChanged)
    local var = generator:modify(node, property, input, valueType, notPostChanged)
    for _, nd in ipairs(self.parent.multiSelectNodes) do
        if node ~= nd and nd.__info.type == node.__info.type then
            generator:modify(nd, property, input, valueType, notPostChanged)
        end
    end
    gk.event:post("displayNode", node)
end

function panel:modifyValue(node, property, value, notPostChanged)
    local var = generator:modifyValue(node, property, value, notPostChanged)
    for _, nd in ipairs(self.parent.multiSelectNodes) do
        if node ~= nd and nd.__info.type == node.__info.type then
            generator:modifyValue(nd, property, value, notPostChanged)
        end
    end
    gk.event:post("displayNode", node)
end

return panel