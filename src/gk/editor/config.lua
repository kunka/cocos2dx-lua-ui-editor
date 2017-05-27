--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/19/17
-- Time: 13:41
-- To change this template use File | Settings | File Templates.
--

local config = {}

config.supportNodes = {
    { type = "cc.Node", },
    { type = "cc.Sprite", },
    { type = "ccui.Scale9Sprite", },
    { type = "cc.Label", },
    { type = "ZoomButton", },
    { type = "SpriteButton", },
    { type = "ToggleButton", },
    { type = "ccui.CheckBox", backGround = "gk/res/texture/check_box_normal.png", cross = "gk/res/texture/check_box_selected.png" },
    { type = "cc.Layer", },
    { type = "cc.LayerColor", },
    { type = "cc.LayerGradient", },
    { type = "cc.ScrollView" },
    { type = "cc.TableView" },
    { type = "cc.ClippingNode" },
    { type = "cc.ClippingRectangleNode" },
    { type = "cc.ProgressTimer" },
}

-- not save to minimize gen file size
config.defValues = {
    scaleX = "1",
    scaleY = "1",
    skewX = 0,
    skewY = 0,
    rotation = 0,
    opacity = 255,
    anchor = { x = 0.5, y = 0.5 },
    scaleXY = { x = "1", y = "1" },
    scaleSize = { w = "1", h = "1" },
    localZOrder = 0,
    tag = -1,
    visible = 0,
    cascadeOpacityEnabled = 1,
    cascadeColorEnabled = 1,
    --    centerRect = cc.rect(0, 0, 0, 0),

    -- scrollView
    bounceable = 0,
    clipToBD = 0,
    direction = 2,
    touchEnabled = 0,
    -- label
    additionalKerning = 0,
    enableBold = 1,
    enableGlow = 1,
    enableItalics = 1,
    enableOutline = 1,
    enableShadow = 1,
    enableStrikethrough = 1,
    enableUnderline = 1,
    vAlign = 0,
    hAlign = 0,
    lineHeight = -1,
    overflow = 0,
    outlineSize = 0,
    enableWrap = 0,
    lineBreakWithoutSpace = 1,
    shadow = {
        a = 0,
        b = 0,
        g = 0,
        h = 0,
        r = 0,
        radius = 0,
        w = 0
    },
    textColor = {
        a = 255,
        b = 255,
        g = 255,
        r = 255,
    },
    effectColor = {
        a = 255,
        b = 0,
        g = 0,
        r = 0
    },
    onClicked = "-",
    onSelectChanged = "-",
    onEnableChanged = "-",
    onLongPressed = "-",
    onSelectedTagChanged = "-",
}

config.defaultProps =
{
    --------------------------- root container   ---------------------------
    Dialog = {
        width = "$fill",
        height = "$fill",
    },
    Layer = {
        width = "$fill",
        height = "$fill",
        scaleSize = { w = "1", h = "1" },
    },
    ["cc.TableViewCell"] = {
        width = "$fill",
        height = "50",
    },
    --------------------------- content node   ---------------------------
    ["cc.Node"] = {
        lock = 1,
        file = "",
        scaleXY = { x = "1", y = "1" },
        scaleSize = { w = "1", h = "1" },
        anchor = { x = 0.5, y = 0.5 },
    },
    ["cc.Label"] = {
        string = "label",
        fontFile = {},
        fontSize = 32,
        defaultSysFont = "Helvetica",
    },
    ["cc.LayerColor"] = {
        width = "$win.w",
        height = "$win.h",
        color = cc.c4b(153, 153, 153, 255),
        scaleSize = { w = "1", h = "1" },
    },
    ["cc.ScrollView"] = {
        width = 100,
        height = 150,
        _flod = true,
        viewSize = cc.size(100, 100),
    },
    ["cc.TableView"] = {
        width = 100,
        height = 150,
        _flod = true,
        viewSize = cc.size(100, 100),
    },
    ClippingRectangleNode = {
        clippingRegion = cc.rect(0, 0, 100, 100),
    },
    ["cc.LayerGradient"] = {
        width = "$win.w",
        height = "$win.h",
        startColor = cc.c4b(0, 0, 0, 255),
        endColor = cc.c4b(255, 255, 255, 255),
        scaleSize = { w = "1", h = "1" },
    },
    ["cc.ProgressTimer"] = {
        sprite = { file = "", type = "cc.Sprite", voidContent = true, lock = 1 },
    },
}

function config:default(type, key)
    -- value copy
    return (self.defaultProps[type] and clone(self.defaultProps[type][key])) or clone(self.defaultProps["cc.Node"][key])
end

config.macroFuncs = {
    -- Scale
    minScale = function() return gk.display:minScale() end,
    maxScale = function() return gk.display:maxScale() end,
    xScale = function() return gk.display:xScale() end,
    yScale = function() return gk.display:yScale() end,
    scaleX = function(key, node, ...) return gk.display:scaleX(...) end,
    scaleY = function(key, node, ...) return gk.display:scaleY(...) end,
    scaleXRvs = function(key, node, ...) return gk.display:scaleXRvs(...) end,
    scaleYRvs = function(key, node, ...) return gk.display:scaleYRvs(...) end,
    scaleTP = function(key, node, ...) return gk.display:scaleTP(...) end,
    scaleBT = function(key, node, ...) return gk.display:scaleBT(...) end,
    scaleLT = function(key, node, ...) return gk.display:scaleLT(...) end,
    scaleRT = function(key, node, ...) return gk.display:scaleRT(...) end,
    ["win.w"] = function() return gk.display:winSize().width end,
    ["win.h"] = function() return gk.display:winSize().height end,
    -- contentSize, ViewSize
    fill = function(key, node)
        local parent = node:getParent()
        if not parent and node.__info and node.__info.parentId and node.__rootTable then
            parent = node.__rootTable[node.__info.parentId]
        end
        return parent and parent:getContentSize()[key] or gk.display:winSize()[key]
        --        if parent and parent.__info and parent.__info[key] then
        --            return parent.__info[key]
        --        end
        --        return parent and parent:getContentSize()[key] or gk.display:winSize()[key]
    end,
}

return config