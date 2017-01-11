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
    root.id = node.__id
    root.pos = cc.p(math.shrink(node:getPositionX(), 1), math.shrink(node:getPositionY(), 1))
    root.scaleX, root.scaleY = math.shrink(node:getScaleX(), 3), math.shrink(node:getScaleY(), 3)
    root.type = node.__cname
    if not root.type then
        root.type = tolua.type(node)
    end

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

function generator.deserialize(info, rootNode)
    if rootNode then
        if rootNode.__id ~= info.id then
            gk.log("deserialize error, not the same type!")
        end
    end
    local node = generator.createNode(info, rootNode)
    if node and info.children then
        for i = 1, #info.children do
            local child = info.children[i]
            if child and child.id then
                local c = generator.deserialize(child)
                if c then
                    node:addChild(c)
                end
            end
        end
    end
    return node
end

function generator.createNode(info, rootNode)
    local node
    if rootNode then
        node = rootNode
        node.__id = info.id
    else
        --        if info.__canme then
        --            local clazz = require("demo." .. info.__cname)
        --            if clazz then
        --                node = clazz:create()
        --            else
        --                gk.log("createNode error, cannot find class to create node, class = %s!", info.__cname)
        --                return nil
        --            end
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
    if info.pos then
        node:setPosition(info.pos)
    end
    if info.scaleX then
        node:setScaleX(info.scaleX)
    end
    if info.scaleY then
        node:setScaleY(info.scaleY)
    end
    return node
end

return generator