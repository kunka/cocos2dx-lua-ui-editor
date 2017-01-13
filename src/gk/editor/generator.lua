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

    info.x = info.x or math.shrink(node:getPositionX(), 3)
    info.y = info.y or math.shrink(node:getPositionY(), 3)
    info.scaleX = info.scaleX or math.shrink(node:getScaleX(), 3)
    info.scaleY = info.scaleY or math.shrink(node:getScaleY(), 3)
    info.type = node.__cname or tolua.type(node)
    info.ap = info.ap or node:getAnchorPoint()
    info.rotation = info.rotation or node:getRotation()
    info.opacity = info.opacity or node:getOpacity()

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
        if info.type == "cc.Sprite" then
            node = gk.create_sprite(info)
            generator.spriteid = generator.spriteid and generator.spriteid + 1 or 1
            info.id = info.id or string.format("sprite%d", generator.spriteid)
            gk.log("createNode %s", info.id)
        elseif info.type == "ZoomButton" then
            node = gk.create_button(info)
            generator.buttonid = generator.buttonid and generator.buttonid + 1 or 1
            info.id = info.id or string.format("button%d", generator.buttonid)
            gk.log("createNode %s", info.id)
        elseif info.type == "cc.Layer" then
            node = cc.Layer:create()
            generator.layerid = generator.layerid and generator.layerid + 1 or 1
            info.id = info.id or string.format("layer%d", generator.layerid)
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
    for k, v in pairs(info.__self) do
        info[k] = nil
        info[k] = v
    end
    return node
end

function generator.default()
    generator._default = generator._default and generator._default or {
        file = "?",
        rotation = 0,
        opacity = 255,
        ap = { x = 0.5, y = 0.5 },
        x = gk.display.scaleX(gk.display.width / 2),
        y = gk.display.scaleY(gk.display.height / 2),
        scaleX = gk.display.minScale,
        scaleY = gk.display.minScale,
    }
    return generator._default
end

function generator.wrap(info, rootTable)
    local proxy = info
    info = {}
    local mt = {
        __index = function(_, key)
            --            gk.log("get %s", key)
            if key == "__self" then
                return proxy
            end
            return proxy[key] or generator.default()[key]
        end,
        __newindex = function(_, key, value)
            if proxy[key] == value then
                return
            end
            proxy[key] = value
            generator.infoChangedSwitch = generator.infoChangedSwitch or switch {
                ["opacity"] = function(node, value)
                    node:setOpacity(value)
                end,
                ["x"] = function(node, value)
                    node:setPositionX(value)
                end,
                ["y"] = function(node, value)
                    node:setPositionY(value)
                end,
                ["scaleX"] = function(node, value)
                    node:setScaleX(value)
                end,
                ["scaleY"] = function(node, value)
                    node:setScaleY(value)
                end,
                ["ap"] = function(node, value)
                    node:setAnchorPoint(value)
                end,
                ["rotation"] = function(node, value)
                    node:setRotation(value)
                end,
            }
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
                --                generator.infoChangedSwitch:case(key, node, v)
                local func = generator.nodeFuncs[key]
                if func then
                    func(node, v)
                    gk.event:post("postSync")
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
    if string.len(input) > 0 and input:sub(1, 1) == "$" then
        local macro = input:sub(2, #input)
        print(macro)
        -- contains
        if generator.macroFuncs[macro] then
            strValue = input
        end
    else
        numValue = tonumber(input)
    end
    if strValue then
        node.__info[property] = strValue
    elseif numValue then
        node.__info[property] = numValue
    end
    gk.log("modify(%s)\'s property(%s) with value(%s)", node.__info.id, property, input)
    return tostring(node.__info[property])
end

generator.macroFuncs = {
    minScale = function()
        return gk.display.minScale
    end,
    maxScale = function()
        return gk.display.maxScale
    end,
    xScale = function()
        return gk.display.xScale
    end,
    yScale = function()
        return gk.display.yScale
    end
}

generator.nodeFuncs = {
    x = function(node, ...)
        node["setPositionX"](node, ...)
    end,
    y = function(node, ...)
        node["setPositionY"](node, ...)
    end,
    scaleX = function(node, ...)
        node["setScaleX"](node, ...)
    end,
    scaleY = function(node, ...)
        node["setScaleY"](node, ...)
    end,
    rotation = function(node, ...)
        node["setRotation"](node, ...)
    end,
    opacity = function(node, ...)
        node["setOpacity"](node, ...)
    end,
}

return generator