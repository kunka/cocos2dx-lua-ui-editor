--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/19/17
-- Time: 13:41
-- To change this template use File | Settings | File Templates.
--

local config = {}

----------------------------- support node list -----------------------------------
config.supportNodes = {
    -- cc nodes
    { _type = "cc.Node", },
    { _type = "cc.Sprite", },
    { _type = "ccui.Scale9Sprite", capInsets = cc.rect(0, 0, 0, 0), },
    { _type = "cc.Label", string = "label", fontSize = 18, },
    { _type = "ccui.EditBox", normalSprite = "gk/res/texture/edit_box_bg.png", selectedSprite = "gk/res/texture/edit_box_bg.png", disabledSprite = "gk/res/texture/edit_box_bg.png", capInsets = cc.rect(20, 20, 20, 20), width = 200, height = 45, },
    { _type = "cc.Layer", width = "$fill", height = "$fill", },
    { _type = "cc.LayerColor", width = "$fill", height = "$fill", color = cc.c4b(153, 153, 153, 255), },
    { _type = "cc.LayerGradient", width = "$fill", height = "$fill", startColor = cc.c4b(0, 0, 0, 255), endColor = cc.c4b(255, 255, 255, 255), },
    { _type = "cc.ScrollView", _fold = true, width = 200, height = 500, viewSize = cc.size(200, 300), },
    { _type = "cc.TableView", _fold = true, width = 200, height = 500, viewSize = cc.size(200, 300), },
    { _type = "cc.ClippingNode" },
    { _type = "cc.ClippingRectangleNode", clippingRegion = cc.rect(0, 0, 100, 100), },
    { _type = "cc.ProgressTimer", sprite = { file = "", _type = "cc.Sprite", _voidContent = true, _lock = 1 }, },
    { _type = "cc.TMXTiledMap", tmx = "gk/res/data/default.tmx", },
    { _type = "cc.ParticleSystemQuad", particle = "gk/res/particle/Galaxy.plist", },
    -- gk nodes
    { _type = "ZoomButton", },
    { _type = "SpriteButton", normalSprite = "gk/res/texture/btn_bg.png" },
    { _type = "ToggleButton", },
    { _type = "CheckBox", normalSprite = "gk/res/texture/check_box_normal.png", selectedSprite = "gk/res/texture/check_box_selected.png" },
}

function config:registerSupportNode(info)
    table.insert(config.supportNodes, info)
end

----------------------------- node creator -----------------------------------

config.nodeCreator = {
    ["cc.Node"] = function(info, rootTable)
        local node = cc.Node:create()
        info._id = info._id or config:genID("node", rootTable)
        return node
    end,
    ["cc.Sprite"] = function(info, rootTable)
        local node = gk.create_sprite(info.file)
        info._id = info._id or config:genID("sprite", rootTable)
        return node
    end,
    ["ccui.Scale9Sprite"] = function(info, rootTable)
        local node = gk.create_scale9_sprite(info.file, info.capInsets)
        info._id = info._id or config:genID("scale9Sprite", rootTable)
        return node
    end,
    ["cc.Label"] = function(info, rootTable)
        local node = gk.create_label_local(info)
        info._id = info._id or config:genID("label", rootTable)
        return node
    end,
    ["ccui.EditBox"] = function(info, rootTable)
        local node = ccui.EditBox:create(cc.size(info.width, info.height),
            gk.create_scale9_sprite(info.normalSprite, info.capInsets),
            gk.create_scale9_sprite(info.selectedSprite, info.capInsets),
            gk.create_scale9_sprite(info.disabledSprite, info.capInsets))
        info._id = info._id or config:genID("editBox", rootTable)
        return node
    end,
    ["cc.Layer"] = function(info, rootTable)
        local node = cc.Layer:create()
        info._id = info._id or config:genID("layer", rootTable)
        return node
    end,
    ["cc.LayerColor"] = function(info, rootTable)
        local node = cc.LayerColor:create(info.color or cc.c4b(255, 255, 255, 255))
        info._id = info._id or config:genID("layerColor", rootTable)
        return node
    end,
    ["cc.LayerGradient"] = function(info, rootTable)
        local node = cc.LayerGradient:create(info.startColor, info.endColor)
        info._id = info._id or config:genID("layerGradient", rootTable)
        return node
    end,
    ["cc.ScrollView"] = function(info, rootTable)
        local node = cc.ScrollView:create(cc.size(info.width, info.height))
        node:setDelegate()
        info._id = info._id or config:genID("scrollView", rootTable)
        return node
    end,
    ["cc.TableView"] = function(info, rootTable)
        local node = cc.TableView:create(cc.size(info.width, info.height))
        node:setDelegate()
        info._id = info._id or config:genID("tableView", rootTable)
        return node
    end,
    ["cc.ClippingNode"] = function(info, rootTable)
        -- Add an useless node
        local node = cc.ClippingNode:create(cc.Node:create())
        info._id = info._id or config:genID("clippingNode", rootTable)
        return node
    end,
    ["cc.ClippingRectangleNode"] = function(info, rootTable)
        local node = cc.ClippingRectangleNode:create(info.clippingRegion)
        info._id = info._id or config:genID("clippingRectNode", rootTable)
        return node
    end,
    ["cc.ProgressTimer"] = function(info, rootTable)
        -- TODO:compitiable with old "children", "id", "type", remove this after upgrade all
        local spriteInfo = info.sprite or info._sprite
        if spriteInfo then
            -- create content sprite first
            if spriteInfo.id then
                spriteInfo._id = spriteInfo.id
            end
            if spriteInfo.children then
                spriteInfo._children = spriteInfo.children
            end
            if spriteInfo.type then
                spriteInfo._type = spriteInfo.type
            end
            local sprite = gk.generator:createNode(spriteInfo, nil, rootTable)
            -- create ProgressTimer
            sprite.__info._lock = 0
            local node = cc.ProgressTimer:create(sprite)
            info._id = info._id or config:genID("progressTimer", rootTable)
            sprite.__info._id = info._id .. "_sprite"
            return node
        end
        return nil
    end,
    ["cc.TMXTiledMap"] = function(info, rootTable)
        if info.tmx then
            local node = cc.TMXTiledMap:create(info.tmx)
            info._id = info._id or config:genID("tmxTiledMap", rootTable)
            return node
        end
        return nil
    end,
    ["cc.ParticleSystemQuad"] = function(info, rootTable)
        if info.particle and info.particle ~= "" then
            local node = cc.ParticleSystemQuad:create(info.particle)
            info._id = info._id or config:genID("particleSystemQuad", rootTable)
            return node
        elseif info.totalParticles and info.totalParticles > 0 then
            local node = cc.ParticleSystemQuad:createWithTotalParticles(info.totalParticles)
            info._id = info._id or config:genID("particleSystemQuad", rootTable)
            return node
        end
        return nil
    end,
    --------------------------- gk nodes   ---------------------------
    ["ZoomButton"] = function(info, rootTable)
        local node = gk.ZoomButton:create()
        info._id = info._id or config:genID("button", rootTable)
        return node
    end,
    ["SpriteButton"] = function(info, rootTable)
        local node = gk.SpriteButton.new(info.normalSprite, info.selectedSprite, info.disabledSprite, info.capInsets)
        info._id = info._id or config:genID("button", rootTable)
        return node
    end,
    ["ToggleButton"] = function(info, rootTable)
        local node = gk.ToggleButton.new()
        info._id = info._id or config:genID("button", rootTable)
        return node
    end,
    ["CheckBox"] = function(info, rootTable)
        local node = gk.CheckBox:create(info.normalSprite, info.selectedSprite, info.disabledSprite, info.capInsets)
        info._id = info._id or config:genID("checkBox", rootTable)
        return node
    end,
    --------------------------- Custom widgets   ---------------------------
    ["widget"] = function(info, rootTable)
        -- compitiable
        local node = gk.injector:inflateNode(info.type or info._type, info.__self)
        node.__ignore = false
        -- copy info
        local keys = table.keys(node.__info.__self)
        for _, key in ipairs(keys) do
            if info.__self[key] == nil then
                info.__self[key] = node.__info.__self[key]
            end
        end
        info._id = info._id or config:genID(info._type, rootTable)
        info._lock = 0
        info._fold = true
        return node
    end,
}

function config:registerNodeCreator(type, creator)
    config.nodeCreator[type] = creator
end

function config:registerGKNodeCreator(type, alias)
    config.nodeCreator[type] = function(info, rootTable)
        local node = gk[type].new()
        info._id = info._id or config:genID(type, rootTable)
        return node
    end
end

function config:genID(type, rootTable)
    local names = string.split(type, ".")
    local names = string.split(names[1], "/")
    type = names[#names]
    local tp = string.lower(type:sub(1, 1)) .. type:sub(2, type:len())

    local index = 1
    while true do
        if rootTable[string.format("%s%d", tp, index)] == nil then
            break
        else
            index = index + 1
        end
    end
    return string.format("%s%d", tp, index)
end

----------------------------- default values not gen -----------------------------------

-- default values and never modified properties will not be saved, minimize gen file size
config.defValues = {
    _isWidget = false,
    _voidContent = false,
    _lock = 1,
    _fold = false,
    x = 0,
    y = 0,
    scaleX = "1",
    scaleY = "1",
    skewX = 0,
    skewY = 0,
    rotation = 0,
    opacity = 255,
    scaleXY = { x = "1", y = "1" },
    scaleSize = { w = "1", h = "1" },
    scaleViewSize = { w = "1", h = "1" },
    scaleOffset = { x = "1", y = "1" },
    localZOrder = 0,
    tag = -1,
    visible = 0,
    cascadeOpacityEnabled = 1,
    cascadeColorEnabled = 1,
    clickedSid = "",
    -- centerRect = cc.rect(0, 0, 0, 0),
    -- Layer
    swallowTouches = 0,
    touchEnabled = 0,
    enableKeyPad = 0,
    popOnBack = 0,
    -- Dialog
    popOnTouchOutsideBg = 1,
    popOnTouchInsideBg = 1,
    -- cc.LayerGradient
    compressedInterpolation = 0,
    GLProgram = "ShaderPositionTextureColor_noMVP",
    selectedGLProgram = "ShaderPositionTextureColor_noMVP",
    disabledGLProgram = "ShaderPositionTextureColor_noMVP",
    -- scrollView
    bounceable = 0,
    clipToBD = 0,
    direction = 2,
    -- touchEnabled = 0,
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
    shadow = { a = 0, b = 0, g = 0, h = 0, r = 0, radius = 0, w = 0 },
    textColor = { a = 255, b = 255, g = 255, r = 255, },
    effectColor = { a = 255, b = 0, g = 0, r = 0 },
    onClicked = "-",
    onSelectChanged = "-",
    onEnableChanged = "-",
    onLongPressed = "-",
    onSelectedTagChanged = "-",
}

----------------------------- macro funcs -----------------------------------

config.macroFuncs = {
    minScale = function(key, node, var) return (var or 1) * gk.display:minScale() end,
    maxScale = function(key, node, var) return (var or 1) * gk.display:maxScale() end,
    xScale = function() return gk.display:xScale() end,
    yScale = function() return gk.display:yScale() end,
    scaleX = function(key, node, ...) return gk.display:scaleX(...) end,
    scaleY = function(key, node, ...) return gk.display:scaleY(...) end,
    scaleiPX = function(key, node, ...) return gk.display:scaleiPX(...) end,
    scaleXRvs = function(key, node, ...) return gk.display:scaleXRvs(...) end, -- iPhoneX scale
    scaleYRvs = function(key, node, ...) return gk.display:scaleYRvs(...) end,
    scaleTP = function(key, node, ...) return gk.display:scaleTP(...) end,
    scaleBT = function(key, node, ...) return gk.display:scaleBT(...) end,
    scaleLT = function(key, node, ...) return gk.display:scaleLT(...) end,
    scaleRT = function(key, node, ...) return gk.display:scaleRT(...) end,
    ["win.w"] = function() return gk.display:winSize().width end,
    ["win.h"] = function() return gk.display:winSize().height end,
    ["accuWin.w"] = function() return gk.display:accuWinSize().width end, -- iPhoneX width
    ["accuWin.h"] = function() return gk.display:accuWinSize().height end, -- iPhoneX height
    -- contentSize, ViewSize(fill-parent)
    fill = function(key, node)
        local parent
        if node.__info and node.__rootTable then
            parent = node.__rootTable[node.__info.parentId]
        end
        if not parent then
            parent = node:getParent()
        end
        return parent and parent:getContentSize()[key] or gk.display:winSize()[key]
    end,
}

----------------------------- custom editable props -----------------------------------

-- custom properties
config.editableProps = {
    _type = {
        getter = function(node) return node.__cname or tolua.type(node) end,
    },
    parentId = {
        getter = function(node)
            local parent = node:getParent()
            while parent do
                if parent.__info then
                    return parent.__info._id
                end
                parent = parent:getParent()
            end
            return ""
        end,
    },
    -- cc.Node
    x = {
        getter = function(node) return 0 end,
        setter = function(node, x)
            local x = gk.generator:parseX(node, x, node.__info.scaleXY.x)
            node:setPositionX(x)
        end
    },
    y = {
        getter = function(node) return 0 end,
        setter = function(node, y)
            local y = gk.generator:parseY(node, y, node.__info.scaleXY.y)
            node:setPositionY(y)
        end
    },
    scaleXY = {
        getter = function(_) return { x = "1", y = "1" } end,
        setter = function(node, var)
            local x = gk.generator:parseX(node, node.__info.x, var.x)
            local y = gk.generator:parseY(node, node.__info.y, var.y)
            node:setPosition(x, y)
        end
    },
    width = {
        getter = function(node)
            if gk.util:instanceof(node, "cc.Label") then
                return node:getWidth()
            else
                return node:getContentSize().width
            end
        end,
        setter = function(node, var)
            if (gk.util:instanceof(node, "Button") and not gk.util:instanceof(node, "SpriteButton")) or (gk.util:instanceof(node, "cc.Sprite") and not gk.util:instanceof(node, "ccui.Scale9Sprite"))
                    or gk.util:instanceof(node, "TableView") then
                return
            end
            local width = gk.generator:parseValue("width", node, var)
            local ss = node.__info.scaleSize
            local scaleW = gk.generator:parseValue("w", node, ss.w)
            width = width * scaleW
            if gk.util:instanceof(node, "cc.Label") then
                node:setWidth(width)
            else
                local size = node:getContentSize()
                size.width = width
                node:setContentSize(size)
            end
            gk.generator:updateChildSize(node, "width")
        end
    },
    height = {
        getter = function(node)
            if gk.util:instanceof(node, "cc.Label") then
                return node:getHeight()
            else
                return node:getContentSize().height
            end
        end,
        setter = function(node, var)
            if (gk.util:instanceof(node, "Button") and not gk.util:instanceof(node, "SpriteButton")) or (gk.util:instanceof(node, "cc.Sprite") and not gk.util:instanceof(node, "ccui.Scale9Sprite")) or gk.util:instanceof(node, "TableView") then
                return
            end
            if gk.util:instanceof(node, "cc.Label") and node.__info.overflow == 3 then
                return
            end
            local height = gk.generator:parseValue("height", node, var)
            local ss = node.__info.scaleSize
            local scaleH = gk.generator:parseValue("h", node, ss.h)
            height = height * scaleH
            if gk.util:instanceof(node, "cc.Label") then
                node:setHeight(height)
            else
                local size = node:getContentSize()
                size.height = height
                node:setContentSize(size)
            end
            gk.generator:updateChildSize(node, "height")
        end
    },
    scaleSize = {
        getter = function(_) return { w = "1", h = "1" } end,
        setter = function(node, var)
            if gk.util:instanceof(node, "Button") or (gk.util:instanceof(node, "cc.Sprite") and not gk.util:instanceof(node, "ccui.Scale9Sprite")) or gk.util:instanceof(node, "TableView") then
                return
            end
            local w = gk.generator:parseValue("width", node, node.__info.width)
            local h = gk.generator:parseValue("height", node, node.__info.height)
            if not w or not h then
                return
            end
            local scaleW = gk.generator:parseValue("w", node, var.w)
            local scaleH = gk.generator:parseValue("h", node, var.h)
            local size = cc.size(w * scaleW, h * scaleH)
            if gk.util:instanceof(node, "cc.Label") then
                node:setDimensions(size.width, size.height)
            else
                node:setContentSize(size)
            end
            gk.generator:updateChildSize(node, "width")
            gk.generator:updateChildSize(node, "height")
        end
    },
    -- cc.Sprite
    file = {
        getter = function(_) return "" end,
        setter = function(node, var)
            if gk.util:instanceof(node, "ccui.Scale9Sprite") then
                local sf = gk.create_sprite_frame(var)
                if not node.__info.capInsets or node.__info.capInsets.width == 0 or node.__info.capInsets.height == 0 then
                    local rect = sf:getRect()
                    node.__info.capInsets = cc.rect(math.shrink(rect.width / 3, 3), math.shrink(rect.height / 3, 3), math.shrink(rect.width / 3, 3), math.shrink(rect.height / 3, 3))
                end
                node:setSpriteFrame(sf, node.__info.capInsets)
                -- need refresh size ...
                node.__info.width, node.__info.height = node.__info.width, node.__info.height
                --                gk.event:post("displayNode", node)
            else
                node:setSpriteFrame(gk.create_sprite_frame(var))
            end
        end
    },
    -- cc.Label
    string = {
        getter = function(node) return node:getString() end,
        setter = function(node, var)
            local value = var
            if value:len() > 0 and value:sub(1, 1) == "@" then
                value = gk.resource:getString(value:sub(2, #value))
            end
            node:setString(value)
        end
    },
    -- ccui.EditBox
    text = {
        getter = function(node) return node:getText() end,
        setter = function(node, var)
            local value = var
            if value:len() > 0 and value:sub(1, 1) == "@" then
                value = gk.resource:getString(value:sub(2, #value))
            end
            node:setText(value)
        end
    },
    placeHolder = {
        getter = function(node) return node:getPlaceHolder() end,
        setter = function(node, var)
            local value = var
            if value:len() > 0 and value:sub(1, 1) == "@" then
                value = gk.resource:getString(value:sub(2, #value))
            end
            node:setPlaceHolder(value)
        end
    },
    lineHeight = {
        getter = function(node) return -1 end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if not gk.isSystemFont(fontFile) and not gk.isCharMap(fontFile) then
                if var > 0 then
                    node:setLineHeight(var)
                end
            end
        end
    },
    fontFile = {
        getter = function(node) return {} end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = var[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            --            gk.log("set fontFile_%s %s", lan, fontFile)
            if gk.isTTF(fontFile) then
                local config = node:getTTFConfig()
                config.fontFilePath = gk.resource:getFontFile(fontFile)
                config.fontSize = node.__info.fontSize
                node:setTTFConfig(config)
            elseif gk.isBMFont(fontFile) then
                node:setBMFontFilePath(gk.resource:getFontFile(fontFile), cc.p(0, 0), node.__info.fontSize)
            elseif gk.isCharMap(fontFile) then
                node:setCharMap(gk.create_sprite(gk.resource:getFontFile(fontFile)):getTexture(), node.__info.itemWidth, node.__info.itemHeight, node.__info.startChar)
            else
                node:setSystemFontName(fontFile)
                node:setSystemFontSize(node.__info.fontSize)
            end
        end
    },
    itemWidth = {
        getter = function(node) return 0 end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if gk.isCharMap(fontFile) then
                node:setCharMap(gk.create_sprite(gk.resource:getFontFile(fontFile)):getTexture(), var, node.__info.itemHeight, node.__info.startChar)
            end
        end,
    },
    itemHeight = {
        getter = function(node) return 0 end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if gk.isCharMap(fontFile) then
                node:setCharMap(gk.create_sprite(gk.resource:getFontFile(fontFile)):getTexture(), node.__info.itemWidth, var, node.__info.startChar)
            end
        end,
    },
    startChar = {
        getter = function(node) return 0 end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if gk.isCharMap(fontFile) then
                node:setCharMap(gk.create_sprite(gk.resource:getFontFile(fontFile)):getTexture(), node.__info.itemWidth, node.__info.itemHeight, var)
            end
        end,
    },
    fontSize = {
        getter = function(node)
            if gk.util:instanceof(node, "ccui.EditBox") then
                return node:getFontSize()
            else
                return 18
            end
        end,
        setter = function(node, var)
            if gk.util:instanceof(node, "ccui.EditBox") then
                node:setFontSize(var)
                return
            end
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if gk.isTTF(fontFile) then
                local config = node:getTTFConfig()
                config.fontSize = var
                node:setTTFConfig(config)
            elseif gk.isBMFont(fontFile) then
                node:setBMFontSize(var)
            elseif gk.isCharMap(fontFile) then
                -- do nothing
            else
                node:setSystemFontSize(var)
            end
        end
    },
    lineSpacing = {
        getter = function(node) return 0 end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if not gk.isSystemFont(fontFile) then
                node:setLineSpacing(var)
            end
        end,
    },
    textColor = {
        getter = function(node)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            return not gk.isBMFont(fontFile) and not gk.isCharMap(fontFile) and not gk.isCharMap(fontFile) and node:getTextColor()
        end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if not gk.isBMFont(fontFile) and not gk.isCharMap(fontFile) then
                node:setTextColor(var)
            else
                -- bmfont not support textcolor
                node:setColor(var)
            end
        end
    },
    additionalKerning = {
        getter = function(node)
            --            return not gk.isSystemFont(node.__info.fontFile[gk.resource:getCurrentLan()]) and node:getAdditionalKerning()
            return 0
        end,
        setter = function(node, var)
            local lan = gk.resource:getCurrentLan()
            local fontFile = node.__info.fontFile[lan]
            if fontFile == nil then
                fontFile = gk.resource:getDefaultFont(lan)
            end
            if gk.isTTF(fontFile) then
                node:setAdditionalKerning(var)
            elseif gk.isBMFont(fontFile) then
                node:setAdditionalKerning(var)
            elseif gk.isCharMap(fontFile) then
                node:setAdditionalKerning(var)
            else
                -- not support
            end
        end
    },
    enableWrap = {
        getter = function(node) return node:isWrapEnabled() and 0 or 1 end,
        setter = function(node, var) node:enableWrap(var == 0) end
    },
    lineBreakWithoutSpace = {
        getter = function(node) return false end,
        setter = function(node, var) node:setLineBreakWithoutSpace(var == 0) end
    },
    enableShadow = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                local shadow = node.__info.shadow
                if shadow then
                    node:enableShadow(cc.c4b(shadow.r, shadow.g, shadow.b, shadow.a), cc.size(shadow.w, shadow.h), shadow.radius)
                end
            else
                node:disableEffect(cc.LabelEffect.SHADOW)
            end
        end
    },
    shadow = {
        getter = function(node)
            local color = node:getShadowColor()
            local size = node:getShadowOffset()
            local radius = node:getShadowBlurRadius()
            return { r = color.r * 255, g = color.g * 255, b = color.b * 255, a = color.a * 255, w = size.width, h = size.height, radius = radius }
        end,
        setter = function(node, var)
            if node.__info.enableShadow == 0 then
                node:enableShadow(cc.c4b(var.r, var.g, var.b, var.a), cc.size(var.w, var.h), var.radius)
            end
        end
    },
    enableOutline = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                node.__info.enableGlow = 1
                node:enableOutline(node.__info.effectColor, node.__info.outlineSize)
            else
                node:disableEffect(cc.LabelEffect.OUTLINE)
            end
        end
    },
    enableGlow = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                node.__info.enableOutline = 1
                node:enableGlow(node.__info.effectColor)
            else
                node:disableEffect(cc.LabelEffect.GLOW)
            end
        end
    },
    outlineSize = {
        getter = function(node) return node:getOutlineSize() end,
        setter = function(node, var)
            if node.__info.enableOutline == 0 then
                node:enableOutline(node.__info.effectColor, var)
            end
        end
    },
    effectColor = {
        getter = function(node)
            local color = node:getEffectColor()
            return { r = color.r * 255, g = color.g * 255, b = color.b * 255, a = color.a * 255 }
        end,
        setter = function(node, var)
            if node.__info.enableOutline == 0 then
                local outlineSize = node.__info.outlineSize
                node:enableOutline(var, outlineSize)
            elseif node.__info.enableGlow == 0 then
                node:enableGlow(var)
            end
        end
    },
    enableItalics = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                node:enableItalics()
            else
                node:disableEffect(4)
            end
        end
    },
    enableBold = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                node:enableBold()
            else
                node:disableEffect(5)
            end
        end
    },
    enableUnderline = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                node:enableUnderline()
            else
                node:disableEffect(6)
            end
        end
    },
    enableStrikethrough = {
        getter = function(node) return false end,
        setter = function(node, var)
            if var == 0 then
                node:enableStrikethrough()
            else
                node:disableEffect(7)
            end
        end
    },
    -- cc.ScrollView
    viewSize = {
        getter = function(node) return node:getViewSize() end,
        setter = function(node, var)
            local w = gk.generator:parseValue("width", node, var.width)
            local h = gk.generator:parseValue("height", node, var.height)
            local ss = node.__info.scaleViewSize
            local scaleW = gk.generator:parseValue("w", node, ss.w)
            local scaleH = gk.generator:parseValue("h", node, ss.h)
            node:setViewSize(cc.size(w * scaleW, h * scaleH))
            if gk.util:instanceof(node, "cc.TableView") then
                node:reloadData()
            end
        end
    },
    scaleViewSize = {
        getter = function(_) return { w = "1", h = "1" } end,
        setter = function(node, var)
            local vs = node.__info.viewSize
            local w = gk.generator:parseValue("width", node, vs.width)
            local h = gk.generator:parseValue("height", node, vs.height)
            if not w or not h then
                return
            end
            local scaleW = gk.generator:parseValue("w", node, var.w)
            local scaleH = gk.generator:parseValue("h", node, var.h)
            node:setViewSize(cc.size(w * scaleW, h * scaleH))
            if gk.util:instanceof(node, "cc.TableView") then
                node:reloadData()
            end
        end
    },
    -- ccui.Scale9Sprite, ccui.EditBox, SpriteButton
    capInsets = {
        getter = function(_) return cc.rect(0, 0, 0, 0) end,
        setter = function(node, var)
            if gk.util:instanceof(node, "ccui.Scale9Sprite") or gk.util:instanceof(node, "SpriteButton") then
                node:setCapInsets(var)
            end
        end
    },
    -- ccui.EditBox, SpriteButton, CheckBox
    normalSprite = {
        getter = function(_) return "" end,
        setter = function(node, var)
            if gk.util:instanceof(node, "SpriteButton") then
                node:setNormalSprite(var)
            end
        end
    },
    selectedSprite = {
        getter = function(_) return "" end,
        setter = function(node, var)
            if gk.util:instanceof(node, "SpriteButton") then
                node:setSelectedSprite(var)
            end
        end
    },
    disabledSprite = {
        getter = function(_) return "" end,
        setter = function(node, var)
            if gk.util:instanceof(node, "SpriteButton") then
                node:setDisabledSprite(var)
            end
        end
    },
    -- cc.ScrollView
    contentOffset = {
        getter = function(node) return node:getContentOffset() end,
        setter = function(node, var)
            local w = gk.generator:parseValue("x", node, var.x)
            local h = gk.generator:parseValue("y", node, var.y)
            local ss = node.__info.scaleOffset
            local scaleW = gk.generator:parseValue("x", node, ss.x)
            local scaleH = gk.generator:parseValue("y", node, ss.y)
            local offset = cc.p(w * scaleW, h * scaleH)
            node:setContentOffset(offset)
        end
    },
    scaleOffset = {
        getter = function(_) return { x = "1", y = "1" } end,
        setter = function(node, var)
            local ss = node.__info.contentOffset
            local w = gk.generator:parseValue("x", node, ss.x)
            local h = gk.generator:parseValue("y", node, ss.y)
            local scaleW = gk.generator:parseValue("x", node, var.x)
            local scaleH = gk.generator:parseValue("y", node, var.y)
            local offset = cc.p(w * scaleW, h * scaleH)
            node:setContentOffset(offset)
        end
    },
    -- cc.ParticleSystemQuad
    displayFrame = {
        getter = function(_) return "" end,
        setter = function(node, var)
            if var and var ~= "" then
                node:setDisplayFrame(gk.create_sprite_frame(var))
            end
        end
    },
    autoRemoveOnFinish = {
        getter = function(node) return node:isAutoRemoveOnFinish() end,
        setter = function(node, var)
            if gk.mode ~= gk.MODE_EDIT then
                node:setAutoRemoveOnFinish(var == 0)
            end
        end
    },
    -- GLProgram(shader)
    GLProgram = {
        getter = function(node) return "ShaderPositionTextureColor_noMVP" end,
        setter = function(node, var)
            if var and var ~= "" then
                local program = cc.GLProgramState:getOrCreateWithGLProgramName(var)
                if program then
                    node:setGLProgramState(program)
                else
                    gk.log("error, getOrCreateWithGLProgramName --> %s, return nil", var)
                end
            end
        end
    },
}

function config:registerEditableProp(key, getter, setter)
    if self.editableProps[key] then
        gk.log("[Warning]config:register prop, key repeated %s", key)
    end
    config.editableProps[key] = { getter = getter, setter = setter }
end

function config:registerPropByType(type, key, alias, onlyGetter)
    local alias = alias or (string.upper(key:sub(1, 1)) .. key:sub(2, key:len()))
    self:registerEditableProp(type and (type .. "." .. key) or key,
        function(node) return node["get" .. alias](node) end,
        function(node, var)
            local v = gk.generator:parseValue(key, node, var)
            if not onlyGetter then
                node["set" .. alias](node, v)
            end
        end)
end

-- no getter and setter props
function config:registerPlaneProp(key, default)
    self:registerEditableProp(key, function(node) return default end, function(node, var) end)
end

function config:registerProp(key, alias, onlyGetter)
    self:registerPropByType(nil, key, alias, onlyGetter)
end

function config:registerFloatPropByType(type, key, alias, onlyGetter)
    local alias = alias or (string.upper(key:sub(1, 1)) .. key:sub(2, key:len()))
    self:registerEditableProp(type and (type .. "." .. key) or key, function(node) return node["get" .. alias] and math.shrink(node["get" .. alias](node), 3) or nil end,
        function(node, var)
            local v = gk.generator:parseValue(key, node, var)
            if not onlyGetter then
                node["set" .. alias](node, tonumber(v))
            end
        end)
end

function config:registerFloatProp(key, alias, onlyGetter)
    self:registerFloatPropByType(nil, key, alias, onlyGetter)
end

function config:registerBoolProp(key, alias, onlyGetter)
    local alias = alias or (string.upper(key:sub(1, 1)) .. key:sub(2, key:len()))
    self:registerEditableProp(key, function(node) return node["is" .. alias](node) and 0 or 1 end,
        function(node, var)
            if not onlyGetter then
                node["set" .. alias](node, var == 0)
            end
        end)
end

function config:registerFuncProp(key)
    self:registerEditableProp(key, function(node) return "-" end,
        function(node, var)
            local func, macro = gk.generator:parseCustomMacroFunc(node, var)
            if func then
                node[key](node, function(...)
                    gk.log("[%s] %s", node.__rootTable.__cname, macro)
                    func(node.__rootTable, ...)
                end)
            end
        end)
end

function config:registerScriptHandler(key, handler)
    self:registerEditableProp(key, function(node) return "-" end,
        function(node, var)
            local func, macro = gk.generator:parseCustomMacroFunc(node, var)
            if func then
                node:registerScriptHandler(function(...)
                    if gk.mode == gk.MODE_EDIT and key == "cellTouched" then
                        return
                    end
                    return func(node.__rootTable, ...)
                end, handler)
            end
        end)
end

-- when node.__info[key] not exist, get default value by this
function config:getValue(node, key)
    local prop
    if key == "_type" then
        prop = config.editableProps[key]
    else
        prop = config.editableProps[node.__info._type .. "." .. key] or config.editableProps[key]
    end
    if prop then
        -- must clone value
        return clone(prop.getter(node))
    end
    -- some props do not have getter
    if self.customProps[key] then
        --                gk.log("no setter found for %s - %s", node.__info._type, key)
        -- custom prop, try find out the setter
        local names = string.split(key, "_")
        local key = #names == 2 and names[2] or key
        local alias = string.upper(key:sub(1, 1)) .. key:sub(2, key:len())
        local getter = "get" .. alias
        if type(node[getter]) == "function" then
            -- delay execute custom prop
            return node[getter](node)
        else
            return node[key]
        end
    elseif not key:starts("_") then
        gk.log("[Error] config:getValue, not registered prop, type = %s, prop = %s", node and node.__info._type or "?", key)
    end
    return nil
end

function config:setValue(node, key, value)
    local prop = config.editableProps[node.__info._type .. "." .. key] or config.editableProps[key]
    if prop and prop.setter then
        prop.setter(node, value)
    else
        -- some props do not have setter
        if self.customProps[key] then
            local names = string.split(key, "_")
            local key = #names == 2 and names[2] or key
            local alias = string.upper(key:sub(1, 1)) .. key:sub(2, key:len())
            local setter = "set" .. alias
            if type(node[setter]) == "function" then
                node[setter](node, value)
            else
                node[key] = value
            end
        elseif not key:starts("_") then
            gk.log("[Error] config:setValue, not registered prop, type = %s, prop = %s", node and node.__info._type or "?", key)
        end
    end
end

config.customProps = {}
function config:registerDisplayProps(displayer, prop)
    gk.exNodeDisplayer[displayer._type] = displayer
    if prop then
        self.customProps[prop] = true
    end
end

----------------------------- properties for Editor -----------------------------------

config:registerPlaneProp("_id", "")
config:registerPlaneProp("_isWidget", false)
config:registerPlaneProp("_voidContent", false)
config:registerPlaneProp("_lock", 1)
config:registerPlaneProp("_fold", false)

-- cc.Node
config:registerProp("anchor", "AnchorPoint")
config:registerBoolProp("ignoreAnchor", "IgnoreAnchorPointForPosition")
config:registerFloatProp("scaleX")
config:registerFloatProp("scaleY")
config:registerFloatProp("skewX")
config:registerFloatProp("skewY")
config:registerFloatProp("rotation")
config:registerProp("opacity")
config:registerProp("localZOrder")
config:registerProp("tag")
config:registerProp("color")
config:registerBoolProp("cascadeOpacityEnabled")
config:registerBoolProp("cascadeColorEnabled")
config:registerBoolProp("visible")

-- cc.Sprite
config:registerProp("blendFunc")
-- cc.Sprite, ccui.Scale9Sprite
config:registerBoolProp("flippedX")
-- ccui.Scale9Sprite
config:registerBoolProp("flippedY")
config:registerProp("renderingType")
config:registerProp("state")
config:registerBoolProp("gravityEnabled")

-- cc.Layer, cc.Dialog, cc.ScrollView
config:registerBoolProp("touchEnabled")
-- cc.Dialog
config:registerBoolProp("popOnTouchOutsideBg")
config:registerBoolProp("popOnTouchInsideBg")
-- cc.LayerGradient
config:registerProp("startColor")
config:registerProp("endColor")
config:registerProp("startOpacity")
config:registerProp("endOpacity")
config:registerProp("vector")
config:registerBoolProp("compressedInterpolation")

-- cc.Label
config:registerProp("hAlign", "HorizontalAlignment")
config:registerProp("vAlign", "VerticalAlignment")
config:registerProp("overflow")

-- cc.ScrollView, cc.TableView
config:registerProp("direction")
config:registerBoolProp("clipToBD", "ClippingToBounds")
config:registerBoolProp("bounceable")
config:registerScriptHandler("didScroll", cc.SCROLLVIEW_SCRIPT_SCROLL)

-- cc.TableView
config:registerProp("verticalFillOrder")
config:registerScriptHandler("cellNums", cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
config:registerScriptHandler("cellSizeForIndex", cc.TABLECELL_SIZE_FOR_INDEX)
config:registerScriptHandler("cellAtIndex", cc.TABLECELL_SIZE_AT_INDEX)
config:registerScriptHandler("cellTouched", cc.TABLECELL_TOUCHED)

-- cc.ClippingNode
config:registerBoolProp("inverted")
config:registerProp("alphaThreshold")
config:registerDisplayProps({
    _type = "cc.ClippingNode",
    numProps = {
        { key = "alphaThreshold", default = 0 },
    },
    boolProps = { { key = "inverted" }, }
})

-- cc.ClippingRectangleNode
config:registerProp("clippingRegion")
config:registerBoolProp("clippingEnabled")
config:registerDisplayProps({
    _type = "cc.ClippingRectangleNode",
    pairProps = {
        {
            titles = { "ClipRegion", "X", "Y" },
            keys = { "clippingRegion.x", "clippingRegion.y" },
        },
        {
            titles = { "", "W", "H" },
            keys = { "clippingRegion.width", "clippingRegion.height" },
        },
    },
    boolProps = { { key = "clippingEnabled" }, }
})

-- cc.ProgressTimer
config:registerProp("barType", "Type")
config:registerProp("percentage")
config:registerBoolProp("reverseDirection")
config:registerProp("midpoint")
config:registerProp("barChangeRate")

-- ccui.EditBox
config:registerProp("fontName")
config:registerFloatProp("placeholderFontSize")
config:registerProp("fontColor")
config:registerProp("placeholderFontColor")
config:registerFloatProp("maxLength")
config:registerProp("textHAlign", "TextHorizontalAlignment")
config:registerProp("inputMode")
config:registerProp("inputFlag")
config:registerProp("returnType")

-- cc.TMXTiledMap
config:registerPlaneProp("tmx")
config:registerDisplayProps({
    _type = "cc.TMXTiledMap",
    stringProps = { { key = "tmx", title = "TMXFile" }, },
})

-- cc.ParticleSystemQuad
config:registerPlaneProp("particle")
config:registerProp("totalParticles")
config:registerProp("gravity")
config:registerBoolProp("blendAdditive")
config:registerFloatProp("duration")
config:registerProp("emitterMode")
config:registerProp("positionType")
config:registerFloatProp("speed")
config:registerFloatProp("speedVar")
config:registerFloatProp("tangentialAccel")
config:registerFloatProp("tangentialAccelVar")
config:registerFloatProp("radialAccel")
config:registerFloatProp("radialAccelVar")
--config:registerBoolProp("rotationIsDir")
config:registerFloatProp("startRadius")
config:registerFloatProp("startRadiusVar")
config:registerFloatProp("endRadius")
config:registerFloatProp("endRadiusVar")
config:registerFloatProp("rotatePerSecond")
config:registerFloatProp("rotatePerSecondVar")
config:registerProp("sourcePosition")
config:registerProp("posVar")
config:registerFloatProp("life")
config:registerFloatProp("lifeVar")
config:registerFloatProp("angle")
config:registerFloatProp("angleVar")
config:registerFloatProp("startSize")
config:registerFloatProp("startSizeVar")
config:registerFloatProp("endSize")
config:registerFloatProp("endSizeVar")
--config:registerProp("startColor")
config:registerProp("startColorVar")
--config:registerProp("endColor")
config:registerProp("endColorVar")
config:registerFloatProp("startSpin")
config:registerFloatProp("startSpinVar")
config:registerFloatProp("endSpin")
config:registerFloatProp("endSpinVar")
config:registerFloatProp("emissionRate")

-- gk.Button
config:registerFuncProp("onClicked")
config:registerFuncProp("onSelectChanged")
config:registerFuncProp("onEnableChanged")
config:registerFuncProp("onLongPressed")
config:registerBoolProp("enabled")
config:registerProp("clickedSid")
config:registerProp("selectedGLProgram")
config:registerProp("disabledGLProgram")
--config:registerBoolProp("cascadeGLProgramEnabled")

-- gk.ZoomButton
config:registerProp("zoomScale")
config:registerBoolProp("zoomEnabled")
-- gk.SpriteButton
config:registerProp("selectMode")
-- gk.ToggleButton
config:registerFuncProp("onSelectedTagChanged")
config:registerProp("selectedTag")
config:registerBoolProp("autoToggle")
-- gk.CheckBox
config:registerBoolProp("selected")

-- gk.Layer, gk.Dialog
config:registerBoolProp("swallowTouches")
config:registerBoolProp("enableKeyPad")
config:registerBoolProp("popOnBack")
config:registerProp("atlas")
config:registerBoolProp("autoRemoveAtlas")

----------------------------- hint valus for Editor -----------------------------------

config.hintColor3Bs = {}
function config:registerHintColor3B(c3b, desc)
    table.insert(self.hintColor3Bs, { c3b = c3b, desc = desc })
end

config.hintPositions = {}
function config:registerHintPosition(pos)
    table.insert(self.hintPositions, pos)
end

config.hintContentSizes = {}
function config:registerHintContentSize(size)
    table.insert(self.hintContentSizes, size)
end

config.hintFontSizes = {}
function config:registerHintFontSize(size)
    table.insert(self.hintFontSizes, size)
end

config:registerHintColor3B(cc.c3b(255, 255, 255), "White")
config:registerHintColor3B(cc.c3b(0, 0, 0), "Black")
config:registerHintContentSize({ width = "$fill", height = "$fill" })
config:registerHintContentSize({ width = "$win.w", height = "$win.h" })
config:registerHintContentSize({ width = "$accuWin.w", height = "$accuWin.h" })
config:registerHintContentSize({ width = 0, height = 0 })
config:registerHintFontSize(18)

------------------------------- ext: draw node -------------------------------

-- gk.DrawNode
config:registerFloatProp("lineWidth")
config:registerProp("c4f")
config:registerDisplayProps({
    title = "gk.DrawNode",
    _type = "DrawNode",
    numProps = {
        { key = "lineWidth", default = 1 },
    },
    pairProps = {
        {
            titles = { "Color4f", "R", "G" },
            keys = { "c4f.r", "c4f.g" },
            defaults = { 1, 1 },
        },
        {
            titles = { "", "B", "A" },
            keys = { "c4f.b", "c4f.a" },
            defaults = { 1, 1 },
        },
    },
})

-- gk.CubicBezierNode
config:registerSupportNode({ _type = "CubicBezierNode", _internal = true })
config:registerGKNodeCreator("CubicBezierNode")
config:registerProp("origin")
config:registerProp("destination")
config:registerFloatProp("segments")
config:registerFloatProp("curvesNum")

-- gk.QuadBezierNode
config:registerSupportNode({ _type = "QuadBezierNode", _internal = true })
config:registerGKNodeCreator("QuadBezierNode")

-- gk.DrawPoint
config:registerSupportNode({ _type = "DrawPoint", _internal = true })
config:registerGKNodeCreator("DrawPoint")
config:registerProp("pointSize")
config:registerBoolProp("dot")
config:registerDisplayProps({
    _type = "DrawPoint",
    title = "gk.DrawPoint",
    numProps = {
        { key = "pointSize" },
    },
    boolProps = {
        { key = "dot" },
    },
})

-- gk.DrawLine
config:registerSupportNode({ _type = "DrawLine", _internal = true })
config:registerGKNodeCreator("DrawLine")
config:registerProp("from")
config:registerProp("to")
config:registerProp("radius")
config:registerBoolProp("segment")
config:registerDisplayProps({
    _type = "DrawLine",
    title = "gk.DrawLine",
    pairProps = {
        {
            titles = { "From", "X", "Y" },
            keys = { "from.x", "from.y" },
            defaults = { 0, 0 },
        },
        {
            titles = { "To", "X", "Y" },
            keys = { "to.x", "to.y" },
            defaults = { 0, 0 },
        },
    },
    numProps = { { key = "radius" }, },
    boolProps = { { key = "segment" }, },
})

-- gk.DrawNodeCircle
config:registerSupportNode({ _type = "DrawNodeCircle", _internal = true })
config:registerGKNodeCreator("DrawNodeCircle")
--config:registerProp("radius")
--config:registerProp("angle")
config:registerBoolProp("solid")
config:registerBoolProp("drawLineToCenter")
config:registerDisplayProps({
    _type = "DrawNodeCircle",
    title = "gk.DrawNodeCircle",
    numProps = {
        { key = "radius" },
        { key = "angle", default = 0 },
    },
    boolProps = {
        { key = "solid" },
        { key = "drawLineToCenter" },
    },
})

-- gk.DrawPolygon
config:registerSupportNode({ _type = "DrawPolygon", _internal = true })
config:registerGKNodeCreator("DrawPolygon")
config:registerFloatProp("borderWidth")
config:registerProp("fillColor")
config:registerProp("points")
config:registerFloatProp("pointsNum")
--config:registerPropByType("DrawPolygon", "points")
--config:registerFloatPropByType("DrawPolygon", "pointsNum")
config:registerDisplayProps({
    _type = "DrawPolygon",
    title = "gk.DrawPolygon",
    numProps = {
        { key = "borderWidth", default = 1 },
    },
    pairProps = {
        {
            titles = { "FillColor", "R", "G" },
            keys = { "fillColor.r", "fillColor.g" },
            defaults = { 1, 1 },
        },
        {
            titles = { "", "B", "A" },
            keys = { "fillColor.b", "fillColor.a" },
            defaults = { 1, 1 },
        },
    },
    arrayProps = {
        { key = "points", numProp = { key = "pointsNum", default = 4 }, titles = { "P%d", "X", "Y" }, keys = { "points.%d.x", "points.%d.y" }, },
    },
})

-- gk.DrawCardinalSpline
config:registerSupportNode({ _type = "DrawCardinalSpline", _internal = true })
config:registerGKNodeCreator("DrawCardinalSpline")
config:registerFloatProp("tension")
--config:registerFloatProp("segments")
config:registerPropByType("DrawCardinalSpline", "points")
config:registerFloatPropByType("DrawCardinalSpline", "pointsNum")
config:registerDisplayProps({
    _type = "DrawCardinalSpline",
    title = "gk.DrawCardinalSpline",
    numProps = {
        { key = "tension", default = 0.5 },
        { key = "segments" },
    },
    arrayProps = {
        { key = "points", numProp = { key = "pointsNum", default = 4 }, titles = { "P%d", "X", "Y" }, keys = { "points.%d.x", "points.%d.y" }, },
    },
})

return config