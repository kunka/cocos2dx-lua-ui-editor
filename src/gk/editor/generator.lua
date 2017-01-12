--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 17/1/10
-- Time: 下午3:25
-- To change this template use File | Settings | File Templates.
--

local generator = {}

function generator.serialize(node)
    local root = {}
    root.id = node.__info.id
    root.type = node.__info.type
    root.x = node.__info.x --cc.p(math.shrink(node:getPositionX(), 1), math.shrink(node:getPositionY(), 1))
    root.y = node.__info.y --cc.p(math.shrink(node:getPositionX(), 1), math.shrink(node:getPositionY(), 1))
    root.scaleX, root.scaleY = node.__info.scaleX, node.__info.scaleY
    --math.shrink(node:getScaleX(), 3), math.shrink(node:getScaleY(), 3)
    root.file = node.__info.file
    root.ap = node.__info.ap --node:getAnchorPoint()
    root.rotation = node.__info.rotation --node:getRotation()
    root.opacity = node.__info.opacity --node:getOpacity()

    local children = node:getChildren()
    for i = 1, #children do
        local child = children[i]
        if child and child.__id then
            root.children = root.children and root.children or {}
            local info = generator.serialize(child)
            table.insert(root.children, info)
        end
    end
    return root
end

function generator.deserialize(info, rootNode, rootTable)
    if rootNode then
        rootNode.__info = info
        --        if rootNode.__id ~= info.id then
        --            gk.log("deserialize error, not the same type!")
        --        end
    end
    local node = generator.createNode(info, rootNode, rootTable)
    if node and info.children then
        for i = 1, #info.children do
            local child = info.children[i]
            if child and child.id then
                local c = generator.deserialize(child, nil, rootTable)
                if c then
                    node:addChild(c)
                end
            end
        end
    end
    return node
end

function generator.createNode(info, rootNode, rootTable)
--    info = clone(info)
    info = generator.wrap(info)
    local node
    if rootNode then
        node = rootNode
        node.__id = info.id
    else
        if info.type then
            if info.type == "cc.Sprite" then
                node = gk.create_sprite(info)
                generator.spriteid = generator.spriteid and generator.spriteid + 1 or 1
                if info.id then
                    node.__id = info.id
                else
                    node.__id = string.format("sprite%d", generator.spriteid)
                end
            elseif info.type == "ZoomButton" then
                node = gk.create_button(info)
                generator.buttonid = generator.buttonid and generator.buttonid + 1 or 1
                if info.id then
                    node.__id = info.id
                else
                    node.__id = string.format("button%d", generator.buttonid)
                end
            elseif info.type == "cc.Layer" then
                node = cc.Layer:create()
                generator.layerid = generator.layerid and generator.layerid + 1 or 1
                if info.id then
                    node.__id = info.id
                else
                    node.__id = string.format("layer%d", generator.layerid)
                end
            end
        else
            gk.log("createNode error, cannot find type to create node, type = %s!", info.type)
            return nil
        end
    end
    generator.updateNode(node, info, rootTable, false)
    return node
end

function generator.updateNode(node, info, rootTable, sync)
    if info.x and info.y then
        node:setPosition(cc.p(info.x, info.y))
    end
    if info.rotation then
        node:setRotation(info.rotation)
    end
    if info.scaleX then
        if type(info.scaleX) == "number" then
            node:setScaleX(info.scaleX)
        else
            node:setScaleX(gk.display[info.scaleX])
        end
    end
    if info.scaleY then
        if type(info.scaleY) == "number" then
            node:setScaleY(info.scaleY)
        else
            node:setScaleY(gk.display[info.scaleY])
        end
    end
    if info.ap then
        node:setAnchorPoint(info.ap)
    end
    if info.opacity then
        node:setOpacity(info.opacity)
    end
    -- file
    if info.type == "cc.Sprite" then
        node:setTexture(CREATE_SPRITE(info.file):getTexture())
    elseif info.type == "ZoomButton" then
        node.node:setTexture(CREATE_SPRITE(info.file):getTexture())
    end

    node.__info = info
    if rootTable then
        local pre = rootTable[node.__id]
        if not pre then
            gk.log("index %s", node.__id)
        elseif node.__id ~= info.id then
            rootTable[node.__id] = nil
            node.__id = info.id
            rootTable[node.__id] = node
            gk.log("reindex %s", node.__id)
        end
    end
    if sync then
        gk.event:post("sync")
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

function generator.wrap(info, name)
    local default = {
        __index = function(_, key)
            local var = generator.default()[key]
            if var then
                return var
            end
            if key == "id" then
                return nil
            end
            error(string.format("try get undefine property %s", key))
        end,
        __newindex = function(_, name, value)
        end,
    }
    setmetatable(info, default)
    return info
end

gk.event:subscribe(generator, "onNodePropertyChanged", function(node, methodName, ...)
    local args = { ... }
    generator.switch = generator.switch or switch {
        ["setOpacity"] = function()
            node.__info[methodName] = args[2]
        end,
        ["setPosition"] = function()
            if #args == 2 then
                node.__info.x = args[2].x
                node.__info.y = args[2].y
            elseif #args == 3 then
                node.__info.x = args[2]
                node.__info.y = args[3]
            end
        end,
    }
end)

return generator