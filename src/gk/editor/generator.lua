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

    -- rescan children
    local children = node:getChildren()
    for i = 1, #children do
        local child = children[i]
        if child and child.__info and child.__info.id then
            info.children = info.children or {}
            local c = self:deflate(child)
            table.insert(info.children, c)
        end
    end

    -- filter useless properties
    local keys = table.keys(info)
    for _, key in ipairs(keys) do
        if string.len(key) > 0 and key:sub(1, 1) == "_" then
            info[key] = nil
        end
    end
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
        local creator = self.nodeCreator[info.type]
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
        rootTable[info.id] = node
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

function generator:default()
    self._default = self._default and self._default or {
        file = "",
        string = "label",
        fontFile = {
            en = "gk/res/font/Consolas.ttf",
            cn = "gk/res/font/msyh.ttf",
        },
        fontSize = "32",
        scaleXY = { x = 1, y = 1 },
    }
    return self._default
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
                var = proxy[key] or self:default()[key]
            end
            --            gk.log("get %s,%s", key, var)
            return var
        end,
        __newindex = function(_, key, value)
            --            gk.log("set %s,%s", key, tostring(value))
            if key == "id" and string.len(value) > 0 then
                local b = string.byte(value:sub(1, 1))
                if (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or b == 95 then
                    if rootTable[value] == nil then
                        local node = rootTable and rootTable[proxy["id"]] or nil
                        if node then
                            -- change id
                            rootTable[value] = node
                            proxy[key] = value
                            gk.event:post("postSync")
                            gk.event:post("displayDomTree")
                        else
                            proxy[key] = value
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
                local v = self:parseValue(value)
                local func = self.nodeSetFuncs[key]
                if func then
                    func(node, v)
                    gk.event:post("postSync")
                    gk.event:post("displayDomTree")
                    --                elseif key ~= "id" and key ~= "children" and key ~= "type" then
                    --                    error(string.format("cannot find node func to set property %s", key))
                end
            end
        end,
    }
    setmetatable(info, mt)
    return info
end

function generator:parseValue(input)
    local v
    if type(input) == "string" and string.len(input) > 1 then
        local macro = input:sub(2, #input)
        v = self.macroFuncs[macro]
        if v then
            v = v()
        end
    end
    return v or input
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
        if string.len(input) > 0 and input:sub(1, 1) == "$" then
            local macro = input:sub(2, #input)
            -- contains
            if self.macroFuncs[macro] then
                value = input
            end
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
    ["cc.Label"] = function(info, rootTable)
        local node = gk.create_label(info)
        info.id = info.id or generator:genID("label", rootTable)
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
    minScale = gk.display.minScale,
    maxScale = gk.display.maxScale,
    xScale = gk.display.xScale,
    yScale = gk.display.yScale,
}

generator.nodeSetFuncs = {
    --------------------------- cc.Node   ---------------------------
    x = function(node, x)
        local scaleX = generator:parseValue(node.__info.scaleXY.x)
        node:setPositionX(x * scaleX)
    end,
    y = function(node, y)
        local scaleY = generator:parseValue(node.__info.scaleXY.y)
        node:setPositionY(y * scaleY)
    end,
    scaleXY = function(node, var)
        local scaleX = generator:parseValue(var.x)
        local scaleY = generator:parseValue(var.y)
        local x, y = node.__info.x, node.__info.y
        node:setPosition(cc.p(x * scaleX, y * scaleY))
    end,
    scaleX = function(node, ...)
        node:setScaleX(...)
    end,
    scaleY = function(node, ...)
        node:setScaleY(...)
    end,
    anchor = function(node, anchor)
        node:setAnchorPoint(anchor)
    end,
    width = function(node, width)
        if iskindof(node, "cc.Label") then
            node:setWidth(width)
        else
            local size = node:getContentSize()
            size.width = width
            node:setContentSize(size)
        end
    end,
    height = function(node, height)
        if iskindof(node, "cc.Label") then
            node:setHeight(height)
        else
            local size = node:getContentSize()
            size.height = height
            node:setContentSize(size)
        end
    end,
    rotation = function(node, ...)
        node:setRotation(...)
    end,
    opacity = function(node, ...)
        node:setOpacity(...)
    end,
    color = function(node, var)
        node:setColor(var)
    end,
    visible = function(node, var)
        node:setVisible(var == 0)
    end,
    --------------------------- cc.Label   ---------------------------
    string = function(node, string)
        local value = string
        if string.len(string) > 0 and string:sub(1, 1) == "@" then
            local key = string:sub(2, #string)
            value = gk.resource.stringGetter(key, gk.resource:getCurrentLan())
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
        gk.log("set fontFile_%s %s", lan, font)
        --        node:setLineHeight(...)
    end,
    --    np = function(node, var)
    --        node:setNormalizedPosition(var)
    --    end,
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
        return node.__info.x or math.shrink(node:getPositionX() / generator:parseValue(node.__info.scaleXY.x), 1)
    end,
    y = function(node)
        return node.__info.y or math.shrink(node:getPositionY() / generator:parseValue(node.__info.scaleXY.y), 1)
    end,
    anchor = function(node)
        return node.__info.anchor or node:getAnchorPoint()
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
        elseif iskindof(node, "cc.Layer") then
            return node.__info.width or node:getContentSize().width
        else
            return node:getContentSize().width
        end
    end,
    height = function(node)
        if iskindof(node, "cc.Label") then
            return node.__info.height or node:getHeight()
        elseif iskindof(node, "cc.Layer") then
            return node.__info.height or node:getContentSize().height
        else
            return node:getContentSize().height
        end
    end,
    color = function(node)
        return node.__info.color or node:getColor()
    end,
    visible = function(node)
        return node.__info.visible or (node:isVisible() and 0 or 1)
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
        return iskindof(node, "cc.Label") and (node.__info.lineHeight or node:getLineHeight())
    end,
    fontFile = function(node)
        return iskindof(node, "cc.Label") and (node.__info.fontFile)
    end,
    --    np = function(node)
    --        return node.__info.np or node:getNormalizedPosition()
    --    end,
}

return generator