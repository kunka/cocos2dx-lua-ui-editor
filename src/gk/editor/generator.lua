--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 17/1/10
-- Time: 下午3:25
-- To change this template use File | Settings | File Templates.
--

local generator = {}

function generator.deflate(node)
    -- copy
    node.__info.__self.children = {}
    local info = clone(node.__info.__self)

    -- force set value
    for k, func in pairs(generator.nodeGetFuncs) do
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
            local c = generator.deflate(child)
            table.insert(info.children, c)
        end
    end
    return info
end

function generator.inflate(info, rootNode, rootTable)
    if rootNode then
        --        rootNode.__info = info
        --        if rootNode.__id ~= info.id then
        --            gk.log("inflate error, not the same type!")
        --        end
    end
    local node = generator.createNode(info, rootNode, rootTable)
    if node and info.children then
        for i = 1, #info.children do
            local child = info.children[i]
            if child and child.id then
                local c = generator.inflate(child, nil, rootTable)
                if c then
                    node:addChild(c)
                end
            end
        end
    end
    return node
end

function generator.createNode(info, rootNode, rootTable)
    info = generator.wrap(info, rootTable)
    local node
    if rootNode then
        node = rootNode
    else
        local creator = generator.nodeCreator[info.type]
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
    --    for k, v in pairs(info.__self) do
    --        info[k] = nil
    --        info[k] = v
    --    end
    -- force set value
    for k, func in pairs(generator.nodeGetFuncs) do
        local ret = func(node)
        if ret then
            info[k] = ret
        end
    end
    return node
end

function generator.default()
    generator._default = generator._default and generator._default or {
        file = "",
        rotation = 0,
        opacity = 255,
        string = "label",
        fontFile = "gk/res/font/Consolas.ttf",
        fontSize = "32",
    }
    return generator._default
end

function generator.wrap(info, rootTable)
    local proxy = info
    info = {}
    local mt = {
        __index = function(_, key)
            if key == "__self" then
                return proxy
            end
            return proxy[key] or generator.default()[key]
        end,
        __newindex = function(_, key, value)
            proxy[key] = value
            --            gk.log("set %s,%s", key, tostring(value))
            local node = rootTable and rootTable[proxy["id"]] or nil
            if node and value then
                local input = tostring(value)
                local macro = input:sub(2, #input)
                local v = generator.macroFuncs[macro]
                if v then
                    v = v()
                end
                v = v or value
                local func = generator.nodeSetFuncs[key]
                if func then
                    func(node, v)
                    gk.event:post("postSync")
                    --                elseif key ~= "id" and key ~= "children" and key ~= "type" then
                    --                    error(string.format("cannot find node func to set property %s", key))
                end
            end
        end,
    }
    setmetatable(info, mt)
    return info
end

function generator.modify(node, property, input)
    local strValue
    local numValue
    if node.__info.type == "cc.Label" then
        strValue = input
    else
        if string.len(input) > 0 and input:sub(1, 1) == "$" then
            local macro = input:sub(2, #input)
            -- contains
            if generator.macroFuncs[macro] then
                strValue = input
            end
        else
            numValue = tonumber(input)
        end
    end
    if strValue then
        node.__info[property] = strValue
    elseif numValue then
        node.__info[property] = numValue
    end
    gk.log("modify(%s)\'s property(%s) with value(%s)", node.__info.id, property, input)
    return tostring(node.__info[property])
end


generator.nodeCreator = {
    ["cc.Sprite"] = function(info, rootTable)
        local node = CREATE_SPRITE(info.file)
        info.id = info.id or generator.genID("sprite", rootTable)
        return node
    end,
    ["ZoomButton"] = function(info, rootTable)
        local node = gk.ZoomButton.new(CREATE_SPRITE(info.file))
        info.id = info.id or generator.genID("button", rootTable)
        return node
    end,
    ["cc.Layer"] = function(info, rootTable)
        local node = cc.Layer:create()
        info.id = info.id or generator.genID("layer", rootTable)
        return node
    end,
    ["cc.Label"] = function(info, rootTable)
        local node = gk.create_label(info)
        info.id = info.id or generator.genID("label", rootTable)
        return node
    end,
}

function generator.genID(type, rootTable)
    --    generator.genIDTable = generator.genIDTable or {}
    --    if not generator.genIDTable[type] then
    --        generator.genIDTable[type] = 1
    --    end
    --    local index = generator.genIDTable[type]
    --    while true do
    --        if rootTable[string.format("%s%d", type, index)] == nil then
    --            generator.genIDTable[type] = index
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
    x = function(node, ...)
        node:setPositionX(...)
    end,
    y = function(node, ...)
        node:setPositionY(...)
    end,
    scaleX = function(node, ...)
        node:setScaleX(...)
    end,
    scaleY = function(node, ...)
        node:setScaleY(...)
    end,
    anchorX = function(node, anchorX)
        local ap = node:getAnchorPoint()
        node:setAnchorPoint(cc.p(anchorX, ap.y))
    end,
    anchorY = function(node, anchorY)
        local ap = node:getAnchorPoint()
        node:setAnchorPoint(cc.p(ap.x, anchorY))
    end,
    width = function(node, width)
        if node.__info.type == "cc.Label" then
            node:setWidth(width)
        else
            local size = node:getContentSize()
            size.width = width
            node:setContentSize(size)
        end
    end,
    height = function(node, height)
        if node.__info.type == "cc.Label" then
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
    string = function(node, string)
        node:setString(string)
    end,
    hAlign = function(node, align)
        node:setHorizontalAlignment(align)
    end,
    vAlign = function(node, align)
        node:setVerticalAlignment(align)
    end,
    overflow = function(node, var)
        node:setOverflow(var)
    end,
    lineHeight = function(node, var)
        node:setLineHeight(var)
    end,
}

generator.nodeGetFuncs = {
    id = function(node)
        return node.__info.id
    end,
    type = function(node)
        return node.__cname or tolua.type(node)
    end,
    anchorX = function(node)
        return node.__info.anchorX or node:getAnchorPoint().x
    end,
    anchorY = function(node)
        return node.__info.anchorY or node:getAnchorPoint().y
    end,
    x = function(node)
        return node.__info.x or math.shrink(node:getPositionX(), 1)
    end,
    y = function(node)
        return node.__info.y or math.shrink(node:getPositionY(), 1)
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
        if node.__info.type == "cc.Label" then
            return node.__info.width or node:getWidth()
        elseif node.__info.type == "cc.Layer" then
            return node.__info.width or node:getContentSize().width
        else
            return node:getContentSize().width
        end
    end,
    height = function(node)
        if node.__info.type == "cc.Label" then
            return node.__info.height or node:getHeight()
        elseif node.__info.type == "cc.Layer" then
            return node.__info.height or node:getContentSize().height
        else
            return node:getContentSize().height
        end
    end,
    string = function(node)
        return node.__info.type == "cc.Label" and (node.__info.string or node:getString())
    end,
    hAlign = function(node)
        return node.__info.type == "cc.Label" and (node.__info.hAlign or node:getHorizontalAlignment())
    end,
    vAlign = function(node)
        return node.__info.type == "cc.Label" and (node.__info.vAlign or node:getVerticalAlignment())
    end,
    overflow = function(node)
        return node.__info.type == "cc.Label" and (node.__info.overflow or node:getOverflow())
    end,
    lineHeight = function(node)
        return node.__info.type == "cc.Label" and (node.__info.lineHeight or node:getLineHeight())
    end,
}

return generator