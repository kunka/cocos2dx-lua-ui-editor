--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/18/17
-- Time: 15:34
-- To change this template use File | Settings | File Templates.
--

local config = {}
config.opening = false

function config:openConfigDialog()
    if self.opening and self.dialog then
        self.dialog:pop()
        return
    end
    local dialog = gk.Dialog:create()
    if gk.SceneManager:showDialogNode(dialog) then
        dialog.__dialogType = "ConfigDialog"
        dialog:animateOut()
        dialog:addMaskLayer()
        self.dialog = dialog
        self:addKeys()
        self.opening = true
        dialog.onPopCallback = function()
            self.opening = false
        end
        dialog.onCleanupCallback_ = function()
            self.opening = false
        end
        self:addRestartButton()
    else
        -- open fail
        self.dialog = nil
    end
end

function config:registerBool(key, defaultValue, desc)
    self.boolKeys = self.boolKeys or {}
    table.insert(self.boolKeys, { key = key, desc = desc })
    self[key] = cc.UserDefault:getInstance():getBoolForKey(key, defaultValue)
end

function config:registerSelectVars(key, defaultValue, items, desc)
    self.selectVarKeys = self.selectVarKeys or {}
    table.insert(self.selectVarKeys, { key = key, defaultValue = defaultValue, items = items, desc = desc })
    local index = cc.UserDefault:getInstance():getIntegerForKey(key, 0)
    if index == 0 or index > #items then
        self[key] = defaultValue
    else
        self[key] = items[index]
    end
end

function config:registerButton(key, desc, callback)
    self.buttonKeys = self.buttonKeys or {}
    table.insert(self.buttonKeys, { key = key, desc = desc, callback = callback })
end

function config:dump()
    gk.log("# gk.config #")
    if self.boolKeys then
        for _, key in ipairs(self.boolKeys) do
            gk.log("# %s = %s", key.key, self[key.key])
        end
    end
    if self.buttonKeys then
        for _, key in ipairs(self.buttonKeys) do
            gk.log("# %s", key.key)
        end
    end
    if self.selectVarKeys then
        for _, key in ipairs(self.selectVarKeys) do
            if type(self[key.key]) == "number" then
                gk.log("# %s = %s", key.key, self[key.key])
            else
                gk.log("# %s = \"%s\"", key.key, self[key.key])
            end
        end
    end
    gk.log("# gk.config #")
end

local fontSize = 20
local fontName = gk.theme.font_fnt

function config:createLabel(content, x, y, isTitle)
    local label = gk.create_label(content, fontName, fontSize)
    label:setScale(gk.display:minScale())
    gk.set_label_color(label, isTitle and cc.c3b(152, 206, 0) or gk.theme.config.fontColorNormal)
    self.dialog:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setPosition(x, y)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    return label
end

function config:createCheckBox(selected, x, y, callback)
    local node = gk.CheckBox:create("gk/res/texture/check_box_normal.png", "gk/res/texture/check_box_selected.png")
    node:setPosition(x, y)
    node:setScale(gk.display:minScale() * 0.6)
    node:setSelected(selected)
    self.dialog:addChild(node)
    node:setAnchorPoint(0, 0.5)
    node:onSelectChanged(function(_, selected)
        callback(selected)
    end)
    node:setAnchorPoint(cc.p(1, 0.5))
    return node
end

function config:createSelectBox(items, index, x, y, width, callback, defValue)
    index = index or 1
    local node = gk.SelectBox:create(cc.size(width, 35), items, index)
    node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
    local fontSize = 16
    local label = gk.create_label("", fontName, fontSize)
    gk.set_label_color(label, cc.c3b(0, 0, 0))
    node:setMarginLeft(5)
    node:setMarginRight(22)
    node:setMarginTop(4)
    node:setDisplayLabel(label)
    node:onCreatePopupLabel(function()
        return gk.create_label("", fontName, fontSize)
    end)
    self.dialog:addChild(node)
    node:setScale(gk.display:minScale())
    node:setAnchorPoint(0, 0.5)
    node:setPosition(x, y)
    node:onSelectChanged(function(index)
        callback(index)
    end)

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
    node:addChild(button, 1)
    button:setAnchorPoint(1, 0.5)
    button:onClicked(function()
        if node.enabled then
            node:openPopup()
        end
    end)
    return node
end

function config:addKeys()
    local size = self.dialog:getContentSize()
    local topY = size.height - 40 * gk.display:minScale()
    local stepY = 50 * gk.display:minScale()
    local gapX = 20 * gk.display:minScale() -- "X" width
    local leftX = 20 * gk.display:minScale() -- margin left
    -- input width
    local inputLong = 200
    local keyWidth = 200 * gk.display:minScale()
    local checkBoxWidth = 24 * gk.display:minScale()
    local selectBox_left = leftX + keyWidth
    local checkbox_left = selectBox_left + inputLong * gk.display:minScale()
    local desc_left = checkbox_left + checkBoxWidth + gapX

    local yIndex = 0
    local function createCheckBox(key, desc)
        self:createLabel(key, leftX, topY - stepY * yIndex)
        self:createCheckBox(self[key], checkbox_left, topY - stepY * yIndex, function(selected)
            self[key] = selected
            gk.log("gk.config set %s = %s", key, self[key])
            cc.UserDefault:getInstance():setBoolForKey(key, selected)
            cc.UserDefault:getInstance():flush()
        end)
        self:createLabel("// " .. desc, desc_left, topY - stepY * yIndex)
        yIndex = yIndex + 1
    end

    local function createSelectBoxLong(key, vars, type, default, desc)
        self:createLabel(key, leftX, topY - stepY * yIndex)
        self:createSelectBox(vars, table.indexof(vars, self[key]), selectBox_left, topY - stepY * yIndex, inputLong, function(index)
            self[key] = vars[index]
            gk.log("gk.config set %s = %s", key, tostring(self[key]))
            cc.UserDefault:getInstance():setIntegerForKey(key, index)
            cc.UserDefault:getInstance():flush()
        end, default)
        self:createLabel("// " .. desc, desc_left, topY - stepY * yIndex)
        yIndex = yIndex + 1
    end

    local function createButton(key, desc, callback)
        self:createLabel(key, leftX, topY - stepY * yIndex)
        local label = gk.create_label(key, fontName, fontSize)
        gk.set_label_color(label, cc.c3b(0x99, 0xcc, 0x00))
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setDimensions(inputLong, 35)
        label:setContentSize(inputLong, 35)
        label:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2 - 4)
        local button = gk.ZoomButton.new(label)
        button:setScale(gk.display:minScale())
        button:setPosition(selectBox_left, topY - stepY * yIndex)
        gk.util:drawNodeBg(button, cc.c4f(0.5, 0.5, 0.5, 1), -2)
        self.dialog:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:onClicked(function()
            if gk.mode ~= gk.MODE_EDIT then
                callback()
            end
        end)
        self:createLabel("// " .. desc, desc_left, topY - stepY * yIndex)
    end

    if self.boolKeys then
        for _, key in ipairs(self.boolKeys) do
            createCheckBox(key.key, key.desc)
        end
    end

    if self.selectVarKeys then
        for _, key in ipairs(self.selectVarKeys) do
            createSelectBoxLong(key.key, key.items, "string", key.defaultValue, key.desc)
        end
    end

    if self.buttonKeys then
        for _, key in ipairs(self.buttonKeys) do
            createButton(key.key, key.desc, key.callback)
        end
    end
end

function config:addRestartButton()
    local fontSize = 30
    local label = gk.create_label("↻", fontName, fontSize)
    gk.set_label_color(label, cc.c3b(50, 255, 50))
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setDimensions(200, 50)
    label:enableBold()
    label:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
    local button = gk.ZoomButton.new(label)
    button:setScale(gk.display:minScale())
    button:setPosition(self.dialog:getContentSize().width / 2, 60 * gk.display:minScale())
    self.dialog:addChild(button)
    gk.util:drawNodeBg(button, cc.c4f(0.5, 0.5, 0.5, 1), -2)
    button:onClicked(function()
        gk.set_label_color(label, cc.c3b(166, 166, 166))
        button:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            gk.set_label_color(label, cc.c3b(50, 255, 50))
            gk.util:restartGame(gk.mode)
        end)))
    end)
end

return config
