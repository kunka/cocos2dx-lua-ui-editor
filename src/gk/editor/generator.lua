--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/10
-- Time: 下午3:25
-- To change this template use File | Settings | File Templates.
--

local generator = {}

function generator:deflate(node)
    -- copy
    node.__info.__self.children = {}
    local info = node.__info.__self

    -- force set value
    for k, func in pairs(self.nodeGetFuncs) do
        local ret = func(node)
        if ret then
            info[k] = ret
        end
    end

    if not iskindof(node, "cc.TableView") and not info.isWidget then
        -- rescan children
        node:sortAllChildren()
        local children = node:getChildren()
        if iskindof(node, "cc.ScrollView") then
            children = node:getContainer():getChildren()
        end
        for i = 1, #children do
            local child = children[i]
            if child and child.__info and child.__info.id then
                info.children = info.children or {}
                local c = self:deflate(child)
                c.parentId = info.id
                table.insert(info.children, c)
            end
        end
    end

    if iskindof(node, "cc.ProgressTimer") then
        local sprite = node:getSprite()
        if sprite then
            info.sprite = self:deflate(sprite)
        end
    end

    -- filter useless properties
    --    local keys = table.keys(info)
    --    for _, key in ipairs(keys) do
    --        if string.len(key) > 0 and key:sub(1, 1) == "_" then
    --            info[key] = nil
    --        end
    --    end
    return info
end

function generator:inflate(info, rootNode, rootTable)
    local node = self:createNode(info, rootNode, rootTable)
    if node and info.children then
        for i = 1, #info.children do
            local child = info.children[i]
            if child and child.id then
                local c = self:inflate(child, nil, rootTable)
                if c then
                    node:addChild(c)
                    -- set width/height($fill)
                    c.__info.width = self.nodeGetFuncs["width"](c)
                    c.__info.height = self.nodeGetFuncs["height"](c)
                end
            end
        end
    end
    return node
end

function generator:createNode(info, rootNode, rootTable)
    info = self:wrap(info, rootTable)
    local node
    if rootNode then
        node = rootNode
    else
        local creator = self.nodeCreator[info.isWidget and "widget" or info.type]
        if creator then
            node = creator(info, rootTable)
            gk.log("createNode %s", info.id)
        else
            gk.log("createNode error, cannot find type to create node, type = %s!", info.type)
            return nil
        end
    end

    node.__info = info
    -- index node
    if rootTable then
        -- warning: duplicated id
        local id = info.id
        local index = 1
        while rootTable[id] do
            id = info.id .. "_" .. tostring(index)
            index = index + 1
        end
        info.id = id
        rootTable[info.id] = node
        node.__rootTable = rootTable
    end
    -- force set value
    for k, func in pairs(self.nodeGetFuncs) do
        local ret = func(node)
        if ret then
            info[k] = ret
        end
    end
    return node
end

function generator:default(type, key)
    if not self._default then
        self._default = {}
        --------------------------- root container   ---------------------------
        self._default["Dialog"] = {
            width = "$fill",
            height = "$fill",
        }
        self._default["Layer"] = {
            width = "$fill",
            height = "$fill",
        }
        self._default["cc.TableViewCell"] = {
            width = "$fill",
            height = "50",
        }
        --------------------------- content node   ---------------------------
        self._default["cc.Node"] = {
            lock = 0,
            file = "",
            scaleXY = { x = 1, y = 1 },
            scaleSize = { w = 1, h = 1 },
        }
        self._default["cc.Label"] = {
            string = "label",
            fontFile = {},
            fontSize = "32",
        }
        self._default["cc.Layer"] = {
            width = "$win.w",
            height = "$win.h",
        }
        self._default["cc.LayerColor"] = {
            width = "$win.w",
            height = "$win.h",
            color = cc.c4b(153, 153, 153, 255),
        }
        self._default["cc.ScrollView"] = {
            width = 100,
            height = 150,
            _flod = true,
        }
        self._default["cc.TableView"] = {
            width = 100,
            height = 150,
            _flod = true,
        }
        self._default["cc.LayerGradient"] = {
            width = "$win.w",
            height = "$win.h",
            startColor = cc.c4b(0, 0, 0, 255),
            endColor = cc.c4b(255, 255, 255, 255),
        }
        self._default["cc.ProgressTimer"] = {
            sprite = { file = "", type = "cc.Sprite", voidContent = true, lock = 1 },
        }
    end
    return (self._default[type] and self._default[type][key]) or self._default["cc.Node"][key]
end

function generator:wrap(info, rootTable)
    local proxy = info
    info = {}
    local mt = {
        __index = function(_, key)
            local var
            if key == "__self" then
                var = proxy
            else
                var = proxy[key]
                if var == nil then
                    return self:default(info.type, key)
                else
                    return var
                end
            end
            --                        gk.log("get %s,%s", key, var)
            return var
        end,
        __newindex = function(_, key, value)
            --            gk.log("set %s,%s", key, tostring(value))
            if key == "id" and string.len(value) > 0 then
                local b = string.byte(value:sub(1, 1))
                if (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or b == 95 then
                    value = string.trim(value)
                    if rootTable[value] == nil then
                        local node = rootTable and rootTable[proxy["id"]] or nil
                        if node then
                            -- change id
                            rootTable[value] = node
                            proxy[key] = value
                            node.__rootTable = rootTable
                            gk.event:post("postSync")
                            gk.event:post("displayDomTree")
                            gk.event:post("displayNode", node)
                        else
                            proxy[key] = value
                            gk.event:post("postSync")
                            gk.event:post("displayDomTree")
                        end
                    end
                else
                    gk.log("error set invalid id %s", value)
                end
                return
            end
            proxy[key] = value
            local node = rootTable and rootTable[proxy["id"]] or nil
            if node and value then
                local v = self:parseValue(key, node, value)
                local func = self.nodeSetFuncs[key]
                if func then
                    func(node, v)
                    gk.event:post("postSync")
                    gk.event:post("displayDomTree")
                    gk.event:post("displayNode", node)
                    --                elseif key ~= "id" and key ~= "children" and key ~= "type" then
                    --                    error(string.format("cannot find node func to set property %s", key))
                    return
                end
            end
            gk.event:post("postSync")
            gk.event:post("displayDomTree")
            if node then
                gk.event:post("displayNode", node)
            end
        end,
    }
    setmetatable(info, mt)
    return info
end

function generator:parseValue(key, node, input)
    local v = generator:parseMacroFunc(node, input)
    if v then
        v = v(key, node)
    end
    return v or input
end

function generator:parseMacroFunc(node, input)
    if type(input) == "string" and string.len(input) > 1 and input:sub(1, 1) == "$" then
        local macro = input:sub(2, #input)
        -- global preset get func
        local func = self.macroFuncs[macro]
        if func then
            return func, macro
        end
    end
    return nil, nil
end

function generator:parseCustomMacroFunc(node, input)
    if type(input) == "string" and string.len(input) > 1 and input:sub(1, 1) == "&" then
        local macro = input:sub(2, #input)
        -- custom defined set func
        if node and node.__rootTable then
            local func = node.__rootTable[macro]
            if func and type(func) == "function" then
                return func, macro
            end
        end
    end
    return nil, nil
end

function generator:modify(node, property, input, valueType)
    local props = string.split(property, ".")
    local prop1, prop2
    if #props == 2 then
        prop1 = props[1]
        prop2 = props[2]
    else
        prop1 = property
    end
    local value
    if type(input) == "number" and valueType == "number" then
        value = tonumber(input)
    elseif type(input) == "string" then
        local v = generator:parseMacroFunc(node, input)
        if v then
            value = input
        elseif valueType == "string" then
            value = input
        elseif valueType == "number" then
            value = tonumber(input)
        end
    end
    if value then
        if prop2 then
            local p = node.__info[prop1]
            if p then
                p[prop2] = value
                node.__info[prop1] = p
            end
        else
            node.__info[prop1] = value
        end
    end
    gk.log("modify(%s)\'s property(%s) with value(%s)", node.__info.id, property, input)
    if prop2 then
        return tostring(node.__info[prop1][prop2])
    else
        return tostring(node.__info[prop1])
    end
end

generator.nodeCreator = {
    ["cc.Node"] = function(info, rootTable)
        local node = cc.Node:create()
        info.id = info.id or generator:genID("node", rootTable)
        return node
    end,
    ["cc.Sprite"] = function(info, rootTable)
        local node = gk.create_sprite(info.file)
        info.id = info.id or generator:genID("sprite", rootTable)
        return node
    end,
    ["ZoomButton"] = function(info, rootTable)
        local node = gk.ZoomButton.new(gk.create_sprite(info.file))
        info.id = info.id or generator:genID("button", rootTable)
        return node
    end,
    ["cc.Layer"] = function(info, rootTable)
        local node = cc.Layer:create()
        info.id = info.id or generator:genID("layer", rootTable)
        return node
    end,
    ["cc.LayerColor"] = function(info, rootTable)
        local node = cc.LayerColor:create(info.color)
        info.id = info.id or generator:genID("layerColor", rootTable)
        return node
    end,
    ["cc.LayerGradient"] = function(info, rootTable)
        local node = cc.LayerGradient:create(info.startColor, info.endColor)
        info.id = info.id or generator:genID("layerGradient", rootTable)
        return node
    end,
    ["cc.Label"] = function(info, rootTable)
        local node = gk.create_label(info)
        info.id = info.id or generator:genID("label", rootTable)
        return node
    end,
    ["cc.ScrollView"] = function(info, rootTable)
        local node = cc.ScrollView:create(cc.size(info.width, info.height))
        info.id = info.id or generator:genID("scrollView", rootTable)
        return node
    end,
    ["cc.TableView"] = function(info, rootTable)
        local node = cc.TableView:create(cc.size(info.width, info.height))
        info.id = info.id or generator:genID("tableView", rootTable)
        return node
    end,
    ["cc.ClippingNode"] = function(info, rootTable)
        -- Add an useless node
        local node = cc.ClippingNode:create(cc.Node:create())
        info.id = info.id or generator:genID("clippingNode", rootTable)
        return node
    end,
    ["cc.ProgressTimer"] = function(info, rootTable)
        if info.sprite then
            -- create content sprite first
            local sprite = generator:createNode(clone(info.sprite), nil, rootTable)
            -- create ProgressTimer
            local node = cc.ProgressTimer:create(sprite)
            info.id = info.id or generator:genID("progressTimer", rootTable)
            sprite.__info.id = info.id .. "_sprite"
            return node
        end
        return nil
    end,
    --------------------------- Custom widgets   ---------------------------
    ["widget"] = function(info, rootTable)
        local clazz, path = gk.resource:require(info.type)
        local node = clazz:create()
        local type = info.type
        local type = string.lower(type:sub(1, 1)) .. type:sub(2, type:len())
        -- copy info
        local keys = table.keys(node.__info.__self)
        for _, key in ipairs(keys) do
            if not info.__self[key] then
                info.__self[key] = node.__info.__self[key]
            end
        end
        info.id = generator:genID(type, rootTable)
        info.lock = 1
        return node
    end,
}

function generator:genID(type, rootTable)
    --    generator:genIDTable = generator:genIDTable or {}
    --    if not generator:genIDTable[type] then
    --        generator:genIDTable[type] = 1
    --    end
    --    local index = generator:genIDTable[type]
    --    while true do
    --        if rootTable[string.format("%s%d", type, index)] == nil then
    --            generator:genIDTable[type] = index
    --            break
    --        else
    --            index = index + 1
    --        end
    --    end
    --    return string.format("%s%d", type, index)
    local index = 1
    while true do
        if rootTable[string.format("%s%d", type, index)] == nil then
            break
        else
            index = index + 1
        end
    end
    return string.format("%s%d", type, index)
end

generator.macroFuncs = {
    -- Scale
    minScale = gk.display.minScale,
    maxScale = gk.display.maxScale,
    xScale = gk.display.xScale,
    yScale = gk.display.yScale,
    ["win.w"] = function() return gk.display.winSize().width end,
    ["win.h"] = function() return gk.display.winSize().height end,
    -- contentSize, ViewSize
    fill = function(key, node)
        local parent = node:getParent()
        if not parent and node.__info and node.__info.parentId and node.__rootTable then
            parent = node.__rootTable[node.__info.parentId]
        end
        return parent and parent:getContentSize()[key] or gk.display.winSize()[key]
    end,
}

generator.nodeSetFuncs = {
    --------------------------- cc.Node   ---------------------------
    x = function(node, x)
        local scaleX = generator:parseValue("x", node, node.__info.scaleXY.x)
        local x = math.shrink(x * scaleX, 0.5)
        node:setPositionX(x)
    end,
    y = function(node, y)
        local scaleY = generator:parseValue("y", node, node.__info.scaleXY.y)
        local y = math.shrink(y * scaleY, 0.5)
        node:setPositionY(y)
    end,
    scaleXY = function(node, var)
        local scaleX = generator:parseValue("scaleX", node, var.x)
        local scaleY = generator:parseValue("scaleY", node, var.y)
        --        local x, y = node.__info.x, node.__info.y
        local x = generator:parseValue("x", node, node.__info.x)
        local y = generator:parseValue("y", node, node.__info.y)
        node:setPosition(cc.p(x * scaleX, y * scaleY))
    end,
    scaleX = function(node, ...)
        node:setScaleX(...)
    end,
    scaleY = function(node, ...)
        node:setScaleY(...)
    end,
    anchor = function(node, var)
        node:setAnchorPoint(var)
    end,
    ignoreAnchor = function(node, var)
        node:ignoreAnchorPointForPosition(var == 0)
    end,
    width = function(node, var)
        local width = generator:parseValue("width", node, var)
        local ss = node.__info.scaleSize
        local scaleW = generator:parseValue("scaleW", node, ss.w)
        width = width * scaleW
        if iskindof(node, "cc.Label") then
            node:setWidth(width)
        else
            local size = node:getContentSize()
            size.width = width
            node:setContentSize(size)
        end
    end,
    height = function(node, var)
        local height = generator:parseValue("height", node, var)
        local ss = node.__info.scaleSize
        local scaleH = generator:parseValue("scaleH", node, ss.h)
        height = height * scaleH
        if iskindof(node, "cc.Label") then
            node:setHeight(height)
        else
            local size = node:getContentSize()
            size.height = height
            node:setContentSize(size)
        end
    end,
    scaleSize = function(node, var)
        if iskindof(node, "cc.ScrollView") then
            local vs = node.__info.viewSize
            local w = generator:parseValue("width", node, vs.width)
            local h = generator:parseValue("height", node, vs.height)
            local scaleW = generator:parseValue("scaleW", node, var.w)
            local scaleH = generator:parseValue("scaleH", node, var.h)
            node:setViewSize(cc.size(w * scaleW, h * scaleH))
            if iskindof(node, "cc.TableView") then
                node:reloadData()
            end
        else
            local w = generator:parseValue("width", node, node.__info.width)
            local h = generator:parseValue("height", node, node.__info.height)
            local scaleW = generator:parseValue("scaleW", node, var.w)
            local scaleH = generator:parseValue("scaleH", node, var.h)
            local size = cc.size(w * scaleW, h * scaleH)
            if iskindof(node, "cc.Label") then
                node:setDimensions(size)
            else
                node:setContentSize(size)
            end
        end
    end,
    rotation = function(node, ...)
        node:setRotation(...)
    end,
    opacity = function(node, ...)
        node:setOpacity(...)
    end,
    visible = function(node, var)
        node:setVisible(var == 0)
    end,
    localZOrder = function(node, var)
        node:setLocalZOrder(var)
    end,
    --------------------------- cc.Sprite cc.Label cc.LayerColor cc.LayerGradient   ---------------------------
    color = function(node, var)
        if iskindof(node, "cc.LayerColor") then
            -- LayerColor has no setColor interface
        else
            node:setColor(var)
        end
    end,
    --------------------------- cc.LayerGradient   ---------------------------
    startColor = function(node, var)
        node:setStartColor(var)
    end,
    endColor = function(node, var)
        node:setEndColor(var)
    end,
    startOpacity = function(node, var)
        node:setStartOpacity(var)
    end,
    endOpacity = function(node, var)
        node:setEndOpacity(var)
    end,
    vector = function(node, var)
        node:setVector(var)
    end,
    isCompressedInterpolation = function(node, var)
        node:setCompressedInterpolation(var == 0)
    end,
    --------------------------- cc.Sprite Button   ---------------------------
    file = function(node, var)
        -- TODO: iskind of bug
        --        if iskindof(node, "Button") then
        if node.__info.type == "ZoomButton" then
            node.contentNode:setSpriteFrame(gk.create_sprite_frame(var))
            node:setContentNode(node.contentNode)
            node.__info.width = nil
            node.__info.height = nil
        else
            node:setSpriteFrame(gk.create_sprite_frame(var))
        end
    end,
    flippedX = function(node, var)
        node:setFlippedX(var == 0)
    end,
    --------------------------- ZoomButton   ---------------------------
    zoomScale = function(node, var)
        node:setZoomScale(var)
    end,
    onClicked = function(node, var)
        local func, macro = generator:parseCustomMacroFunc(node, var)
        if func then
            node:onClicked(function(...)
                gk.log("[%s] %s", node.__rootTable.__cname, macro)
                func(node.__rootTable, ...)
            end)
        end
    end,
    enabled = function(node, var)
        node:setEnabled(var == 0)
    end,
    --------------------------- cc.Label   ---------------------------
    string = function(node, string)
        local value = string
        if string.len(string) > 0 and string:sub(1, 1) == "@" then
            local key = string:sub(2, #string)
            value = gk.resource:getString(key)
        end
        node:setString(value)
    end,
    hAlign = function(node, ...)
        node:setHorizontalAlignment(...)
    end,
    vAlign = function(node, ...)
        node:setVerticalAlignment(...)
    end,
    overflow = function(node, ...)
        node:setOverflow(...)
    end,
    lineHeight = function(node, ...)
        if not gk.isSystemFont(node.__info.fontFile[gk.resource:getCurrentLan()]) then
            node:setLineHeight(...)
        end
    end,
    fontFile = function(node, var)
        -- recreate node
        local lan = gk.resource:getCurrentLan()
        local font = var[lan]
        --        gk.log("set fontFile_%s %s", lan, font)
        --        node:setLineHeight(...)
    end,
    --    np = function( node, var)
    --        node:setNormalizedPosition(var)
    --    end,
    --------------------------- cc.ScrollView   ---------------------------
    viewSize = function(node, var)
        local w = generator:parseValue("width", node, var.width)
        local h = generator:parseValue("height", node, var.height)
        local ss = node.__info.scaleSize
        local scaleW = generator:parseValue("scaleW", node, ss.w)
        local scaleH = generator:parseValue("scaleH", node, ss.h)
        node:setViewSize(cc.size(w * scaleW, h * scaleH))
        if iskindof(node, "cc.TableView") then
            node:reloadData()
        end
    end,
    direction = function(node, ...)
        node:setDirection(...)
    end,
    bounceable = function(node, var)
        node:setBounceable(var == 0)
    end,
    clipToBD = function(node, var)
        node:setClippingToBounds(var == 0)
    end,
    touchEnabled = function(node, var)
        node:setTouchEnabled(var == 0)
    end,
    --------------------------- cc.TableView   ---------------------------
    verticalFillOrder = function(node, var)
        node:setVerticalFillOrder(var)
    end,
    --------------------------- Layer   ---------------------------
    swallowTouchEvent = function(node, var)
        node.swallowTouchEvent = var == 0
    end,
    enableKeyPad = function(node, var)
        node.enableKeyPad = var == 0
    end,
    popOnBack = function(node, var)
        node.popOnBack = var == 0
    end,
    --------------------------- cc.ClippingNode   ---------------------------
    inverted = function(node, var)
        node:setInverted(var == 0)
    end,
    alphaThreshold = function(node, ...)
        node:setAlphaThreshold(...)
    end,
    --------------------------- cc.ProgressTimer   ---------------------------
    barType = function(node, ...)
        node:setType(...)
    end,
    percentage = function(node, ...)
        node:setPercentage(...)
    end,
    reverseDirection = function(node, var)
        node:setReverseDirection(var == 0)
    end,
    midpoint = function(node, ...)
        node:setMidpoint(...)
    end,
    barChangeRate = function(node, ...)
        node:setBarChangeRate(...)
    end,
}

generator.nodeGetFuncs = {
    id = function(node)
        return node.__info.id
    end,
    type = function(node)
        return node.__cname or tolua.type(node)
    end,
    --------------------------- cc.Node   ---------------------------
    x = function(node)
        return node.__info.x or math.shrink(node:getPositionX() / generator:parseValue("x", node, node.__info.scaleXY.x), 0.5)
    end,
    y = function(node)
        return node.__info.y or math.shrink(node:getPositionY() / generator:parseValue("y", node, node.__info.scaleXY.y), 0.5)
    end,
    anchor = function(node)
        return node.__info.anchor or node:getAnchorPoint()
    end,
    ignoreAnchor = function(node)
        return node.__info.ignoreAnchor or (node:isIgnoreAnchorPointForPosition() and 0 or 1)
    end,
    scaleX = function(node)
        return node.__info.scaleX or math.shrink(node:getScaleX(), 3)
    end,
    scaleY = function(node)
        return node.__info.scaleY or math.shrink(node:getScaleY(), 3)
    end,
    rotation = function(node)
        return node.__info.rotation or math.shrink(node:getRotation(), 2)
    end,
    opacity = function(node)
        return node.__info.opacity or node:getOpacity()
    end,
    width = function(node)
        if iskindof(node, "cc.Label") then
            return node.__info.width or node:getWidth()
        elseif iskindof(node, "cc.Sprite") then
            return node:getContentSize().width
        elseif iskindof(node, "cc.Layer") then
            return node.__info.width or node:getContentSize().width
        elseif iskindof(node, "cc.ScrollView") then
            return node.__info.width or node:getViewSize().width
        else
            return node.__info.width or node:getContentSize().width
        end
    end,
    height = function(node)
        if iskindof(node, "cc.Label") then
            return node.__info.height or node:getHeight()
        elseif iskindof(node, "cc.Sprite") then
            return node:getContentSize().height
        elseif iskindof(node, "cc.Layer") then
            return node.__info.height or node:getContentSize().height
        elseif iskindof(node, "cc.ScrollView") then
            return node.__info.height or node:getViewSize().height
        else
            return node.__info.height or node:getContentSize().height
        end
    end,
    visible = function(node)
        return node.__info.visible or (node:isVisible() and 0 or 1)
    end,
    localZOrder = function(node, var)
        return node.__info.localZOrder or node:getLocalZOrder()
    end,
    --------------------------- cc.Sprite cc.Label cc.LayerColor cc.LayerGradient   ---------------------------
    color = function(node)
        if iskindof(node, "cc.LayerColor") then
            return node.__info.color
        else
            return node.__info.color or node:getColor()
        end
    end,
    --------------------------- cc.LayerGradient   ---------------------------
    startColor = function(node)
        return (node.__info.type == "cc.LayerGradient" and (node.__info.startColor or node:getStartColor()))
    end,
    endColor = function(node)
        return (node.__info.type == "cc.LayerGradient" and (node.__info.endColor or node:getEndColor()))
    end,
    startOpacity = function(node)
        return (node.__info.type == "cc.LayerGradient" and (node.__info.startOpacity or node:getStartOpacity()))
    end,
    endOpacity = function(node)
        return (node.__info.type == "cc.LayerGradient" and (node.__info.endOpacity or node:getEndOpacity()))
    end,
    vector = function(node)
        return (node.__info.type == "cc.LayerGradient" and (node.__info.vector or node:getVector()))
    end,
    isCompressedInterpolation = function(node)
        return (node.__info.type == "cc.LayerGradient" and (node.__info.isCompressedInterpolation or (node:isCompressedInterpolation() and 0 or 1)))
    end,
    --------------------------- cc.Sprite   ---------------------------
    file = function(node)
        return (node.__info.type == "cc.Sprite" and node.__info.file)
    end,
    flippedX = function(node)
        return (node.__info.type == "cc.Sprite" and (node.__info.flippedX or (node:isFlippedX() and 0 or 1)))
    end,
    --------------------------- ZoomButton   ---------------------------
    zoomScale = function(node)
        return (node.__info.type == "ZoomButton") and (node.__info.zoomScale or node:getZoomScale())
    end,
    onClicked = function(node)
        return (node.__info.type == "ZoomButton") and (node.__info.onClicked or "-")
    end,
    enabled = function(node)
        return (node.__info.type == "ZoomButton") and (node.__info.enabled or (node.enabled and 0 or 1))
    end,
    --------------------------- cc.Label   ---------------------------
    string = function(node)
        return iskindof(node, "cc.Label") and (node.__info.string or node:getString())
    end,
    hAlign = function(node)
        return iskindof(node, "cc.Label") and (node.__info.hAlign or node:getHorizontalAlignment())
    end,
    vAlign = function(node)
        return iskindof(node, "cc.Label") and (node.__info.vAlign or node:getVerticalAlignment())
    end,
    overflow = function(node)
        return iskindof(node, "cc.Label") and (node.__info.overflow or node:getOverflow())
    end,
    lineHeight = function(node)
        return iskindof(node, "cc.Label") and (node.__info.lineHeight)
    end,
    fontFile = function(node)
        return iskindof(node, "cc.Label") and (node.__info.fontFile)
    end,
    --    np = function(node)
    --        return node.__info.np or node:getNormalizedPosition()
    --    end,
    --------------------------- cc.ScrollView   ---------------------------
    viewSize = function(node)
        return iskindof(node, "cc.ScrollView") and (node.__info.viewSize or node:getViewSize())
    end,
    direction = function(node)
        return iskindof(node, "cc.ScrollView") and (node.__info.direction or node:getDirection())
    end,
    visible = function(node)
        return node.__info.visible or (node:isVisible() and 0 or 1)
    end,
    clipToBD = function(node)
        return iskindof(node, "cc.ScrollView") and (node.__info.clipToBD or (node:isClippingToBounds() and 0 or 1))
    end,
    bounceable = function(node)
        return iskindof(node, "cc.ScrollView") and (node.__info.bounceable or (node:isBounceable() and 0 or 1))
    end,
    touchEnabled = function(node)
        return iskindof(node, "cc.ScrollView") and (node.__info.touchEnabled or (node:isTouchEnabled() and 0 or 1))
    end,
    --------------------------- cc.TableView   ---------------------------
    verticalFillOrder = function(node)
        return iskindof(node, "cc.TableView") and (node.__info.verticalFillOrder or node:getVerticalFillOrder())
    end,
    --------------------------- Layer   ---------------------------
    swallowTouchEvent = function(node, var)
        return iskindof(node.class, "Layer") and (node.__info.swallowTouchEvent or (node.swallowTouchEvent and 0 or 1))
    end,
    enableKeyPad = function(node, var)
        return iskindof(node.class, "Layer") and (node.__info.enableKeyPad or (node.enableKeyPad and 0 or 1))
    end,
    popOnBack = function(node, var)
        return iskindof(node.class, "Layer") and (node.__info.popOnBack or (node.popOnBack and 0 or 1))
    end,
    --------------------------- cc.ClippingNode   ---------------------------
    inverted = function(node, var)
        return iskindof(node, "cc.ClippingNode") and (node.__info.inverted or (node:isInverted() and 0 or 1))
    end,
    alphaThreshold = function(node)
        return iskindof(node, "cc.ClippingNode") and (node.__info.alphaThreshold or node:getAlphaThreshold())
    end,
    --------------------------- cc.ProgressTimer   ---------------------------
    barType = function(node)
        return iskindof(node, "cc.ProgressTimer") and (node.__info.barType or node:getType())
    end,
    percentage = function(node)
        return iskindof(node, "cc.ProgressTimer") and (node.__info.percentage or node:getPercentage())
    end,
    reverseDirection = function(node, var)
        return iskindof(node, "cc.ProgressTimer") and (node.__info.reverseDirection or (node:isReverseDirection() and 0 or 1))
    end,
    midpoint = function(node)
        return iskindof(node, "cc.ProgressTimer") and (node.__info.midpoint or node:getMidpoint())
    end,
    barChangeRate = function(node)
        return iskindof(node, "cc.ProgressTimer") and (node.__info.barChangeRate or node:getBarChangeRate())
    end,
}

return generator