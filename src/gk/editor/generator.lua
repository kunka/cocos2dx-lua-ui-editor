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
    root.pos = cc.p(math.floor(node:getPositionX()), math.floor(node:getPositionY()))

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

function generator._serialize(node)
    local info = {}
    info.id = node.__id
    info.pos = cc.p(math.floor(node:getPositionX()), math.floor(node:getPositionY()))
    return info
end

function generator.deserialize(info)
end

return generator