--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/10
-- Time: 下午3:25
-- To change this template use File | Settings | File Templates.
--

local generator = {}
local config = require("gk.editor.config")
generator.config = config

function generator:deflate(node)
    local info = {}

    -- add edit properties
    for k, ret in pairs(node.__info.__self) do
        if k ~= "children" and generator.config.editableProps[k] ~= nil then
            local def = config.defValues[k]
            if def then
                -- filter def value, except widget which save all values
                local isWidget = node.class and node.class._isWidget
                if (not isWidget) and ((type(def) == "table" and gk.util:table_eq(def, ret)) or tostring(def) == tostring(ret)) then
                    info[k] = nil
                else
                    info[k] = clone(ret)
                end
            else
                -- patch
                if ret and k == "capInsets" then
                    ret.x = math.shrink(ret.x, 3)
                    ret.y = math.shrink(ret.y, 3)
                    ret.width = math.shrink(ret.width, 3)
                    ret.height = math.shrink(ret.height, 3)
                end
                info[k] = clone(ret)
            end
        end
    end
    if (gk.util:instanceof(node, "Button") and not gk.util:instanceof(node, "SpriteButton")) or (gk.util:instanceof(node, "cc.Sprite") and not gk.util:instanceof(node, "ccui.Scale9Sprite")) then
        info["width"] = nil
        info["height"] = nil
        info["scaleSize"] = nil
    end

    if not gk.util:instanceof(node, "cc.TableView") then
        -- and not node.__info._isWidget then
        -- rescan children
        node:sortAllChildren()
        local children = node:getChildren()
        if gk.util:instanceof(node, "cc.ScrollView") then
            children = node:getContainer():getChildren()
        end
        local _isWidget = node.__info._isWidget
        for i = 1, #children do
            local child = children[i]
            if child and child.__info and child.__info.id and not gk.util:isDebugNode(child) then
                if child.__ignore or (_isWidget and child.__rootTable == node) then
                    -- ignore widget child
                else
                    info.children = info.children or {}
                    local c = self:deflate(child)
                    --                    c.parentId = info.id
                    table.insert(info.children, c)
                end
            end
        end
    end

    if info.children and #info.children == 0 then
        info.children = nil
    end

    if gk.util:instanceof(node, "cc.ProgressTimer") then
        local sprite = node:getSprite()
        if sprite then
            info.sprite = self:deflate(sprite)
        end
    end
    local obj = node:getPhysicsBody()
    if obj then
        info.physicsBody = self:deflatePhysicsObj(obj)
    end

    return info
end

function generator:deflatePhysicsObj(obj)
    local info = {}
    -- add edit properties
    for k, ret in pairs(obj.__info.__self) do
        if generator.config.editableProps[k] ~= nil then
            local def = config.defValues[k]
            if def then
                -- filter def value, except widget which save all values
                if ((type(def) == "table" and gk.util:table_eq(def, ret)) or tostring(def) == tostring(ret)) then
                    info[k] = nil
                else
                    info[k] = clone(ret)
                end
            else
                info[k] = clone(ret)
            end
        end
    end

    if tolua.type(obj) == "cc.PhysicsBody" then
        local shapes = obj:getShapes()
        for i = 1, #shapes do
            local child = shapes[i]
            if child and child.__info then
                info.shapes = info.shapes or {}
                local c = self:deflatePhysicsObj(child)
                table.insert(info.shapes, c)
            end
        end
        if #shapes == 0 then
            info.shapes = nil
        end
    end
    return info
end

function generator:resetIds(info)
    info.id = nil
    if info.children then
        for i = 1, #info.children do
            local child = info.children[i]
            if child then
                self:resetIds(child)
            end
        end
    end
end

function generator:inflate(info, rootNode, rootTable)
    local children = info.children
    local node = self:createNode(info, rootNode, rootTable)
    if info.physicsBody then
        self:createPhysicObject(info.physicsBody, node, rootTable)
        if info.physicsBody.shapes then
            for _, s in ipairs(info.physicsBody.shapes) do
                self:createPhysicObject(s, node, rootTable)
            end
        end
    end
    if node and children then
        for _, child in ipairs(children) do
            local c = self:inflate(child, nil, rootTable)
            if c then
                node:addChild(c)
                -- update width/height($fill)
                self:updateNodeSize(c, "width")
                self:updateNodeSize(c, "height")
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
        local creator = config.nodeCreator[info._isWidget and "widget" or info.type]
        if creator then
            node = creator(info, rootTable)
            --            gk.log("createNode %s,%s", node, info.id)
            if not node then
                local msg = gk.log("createNode error, return nil, type = %s", info.type)
                gk.util:reportError(msg)
                return nil
            end
        else
            local msg = gk.log("createNode error, cannot find type to create node, type = %s!", info.type)
            gk.util:reportError(msg)
            return nil
        end
    end

    node.__info = info
    -- index node
    if rootTable then
        -- warning: duplicated id
        if rootTable[info.id] then
            local id = generator:genID(node.__info.type, rootTable)
            local pre = info.id
            local otherNode = rootTable[info.id]
            info.id = id
            -- restore
            rootTable[pre] = otherNode
        end
        rootTable[info.id] = node
        node.__rootTable = rootTable
    end

    -- force set value
    for k, v in pairs(info.__self) do
        info[k] = v
    end
    return node
end

function generator:createPhysicObject(info, node, rootTable)
    local obj
    local creator = self.physicsCreator[info.type]
    if creator then
        obj = creator(info, node, rootTable)
        if not obj then
            local msg = gk.log("createPhysicObject error, return nil, type = %s", info.type)
            gk.util:reportError(msg)
            return nil
        end
    else
        local msg = gk.log("createPhysicObject error, cannot find type to create obj, type = %s!", info.type)
        gk.util:reportError(msg)
        return nil
    end
    info = self:wrapPhysics(info, obj)
    obj.__info = info
    -- index node
    if rootTable then
        -- warning: duplicated id
        if rootTable[info.id] then
            local id = generator:genID(node.__info.type, rootTable)
            local pre = info.id
            local otherNode = rootTable[info.id]
            info.id = id
            -- restore
            rootTable[pre] = otherNode
        end
        rootTable[info.id] = obj
    end

    -- force set value
    for k, v in pairs(info.__self) do
        info[k] = v
    end
    return obj
end

function generator:setProp(proxy, key, value, info, rootTable)
    --            gk.log("set %s,%s", key, tostring(value))
    if key == "id" then
        local b = string.len(value) > 0 and string.byte(value:sub(1, 1)) or -1
        if (b >= 65 and b <= 90) or (b >= 97 and b <= 122) or b == 95 then
            value = string.trim(value)
            if rootTable[value] == nil then
                local node = rootTable and rootTable[proxy["id"]] or nil
                if node then
                    -- clear old
                    rootTable[proxy["id"]] = nil
                    -- change id
                    rootTable[value] = node
                    proxy[key] = value
                    --                            gk.log("change id %s,%s", key, tostring(value))
                    node.__rootTable = rootTable
                    gk.event:post("postSync")
                    gk.event:post("displayDomTree", true)
                    gk.event:post("displayNode", node)
                else
                    -- new id
                    proxy[key] = value
                    gk.event:post("postSync")
                    gk.event:post("displayDomTree", true)
                end
            else
                -- gk.log("error set duplicate id %s", value)
            end
        else
            gk.log("error set invalid id %s", value)
        end
    else
        local node = rootTable and rootTable[proxy["id"]] or nil
        if node then
            local pre = proxy[key]
            proxy[key] = value
            self.config:setValue(node, key, value)
            if pre ~= value then
                gk.event:post("postSync")
            end
        end
    end
end

function generator:getProp(proxy, key, info, rootTable)
    local var
    if key == "__self" then
        var = proxy
    else
        var = proxy[key]
        if var == nil then
            local node = rootTable and rootTable[proxy["id"]] or nil
            return node and self.config:getValue(node, key) or nil
        else
            return var
        end
    end
    --                        gk.log("get %s,%s", key, var)
    return var
end

function generator:wrap(info, rootTable)
    local proxy = info
    info = {}
    local mt = {
        __index = function(_, key)
            return self:getProp(proxy, key, info, rootTable)
        end,
        __newindex = function(_, key, value)
            self:setProp(proxy, key, value, info, rootTable)
        end,
    }
    setmetatable(info, mt)
    return info
end

function generator:wrapPhysics(info, node)
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
                    return self.config:getValue(node, key) or nil
                else
                    return var
                end
            end
            --                        gk.log("get %s,%s", key, var)
            return var
        end,
        __newindex = function(_, key, value)
            --            gk.log("set %s,%s", key, tostring(value))
            local pre = proxy[key]
            proxy[key] = value
            self.config:setValue(node, key, value)
            if pre ~= value then
                gk.event:post("postSync")
            end
        end,
    }
    setmetatable(info, mt)
    return info
end

function generator:parseValue(key, node, input, ...)
    local v = generator:parseMacroFunc(node, input)
    if v then
        v = v(key, node, ...)
    end
    return v or input
end

function generator:parseX(node, x, scaleX)
    local x = generator:parseValue("x", node, x)
    x = tonumber(scaleX) == 1 and x or generator:parseValue("scaleX", node, scaleX, x)
    return x
end

function generator:parseY(node, y, scaleY)
    local y = generator:parseValue("y", node, y)
    y = tonumber(scaleY) == 1 and y or generator:parseValue("scaleY", node, scaleY, y)
    return y
end

function generator:parseXRvs(node, x, scaleX)
    local x = generator:parseValue("x", node, x)
    x = tonumber(scaleX) == 1 and x or generator:parseValue("scaleX", node, scaleX .. "Rvs", x)
    return x
end

function generator:parseYRvs(node, y, scaleY)
    local y = generator:parseValue("y", node, y)
    y = tonumber(scaleY) == 1 and y or generator:parseValue("scaleY", node, scaleY .. "Rvs", y)
    return y
end

function generator:parseMacroFunc(node, input)
    if type(input) == "string" and string.len(input) > 1 and input:sub(1, 1) == "$" then
        local macro = input:sub(2, #input)
        -- global preset get func
        local func = self.config.macroFuncs[macro]
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

-- for editor use
function generator:modify(node, property, input, valueType, notPostChanged)
    local props = string.split(property, ".")
    local prop1, prop2
    if #props == 2 then
        prop1 = props[1]
        prop2 = props[2]
    elseif #props > 2 then
        prop1 = props[1]
        --        createInputMiddle("Control1", "X", "Y", "destination." .. i .. ".c1.x", "destination[" .. i .. "].c1.y", "number")
    else
        prop1 = property
    end
    local value
    if valueType == "boolean" then
        value = input
    else
        if type(input) == "number" and valueType == "number" then
            value = tonumber(input)
        elseif type(input) == "string" then
            local v = self:parseMacroFunc(node, input)
            if v then
                value = input
            elseif valueType == "string" then
                value = input
            elseif valueType == "number" then
                value = tonumber(input)
                if value == nil then
                    gk.log("modify \"%s\" need number value, error input = \"%s\"", property, input)
                    if #props == 2 then
                        return node.__info[prop1][prop2]
                    elseif #props > 2 then
                        local var = node.__info[props[1]]
                        for i = 2, #props do
                            var = var[tonumber(props[i]) and tonumber(props[i]) or props[i]]
                        end
                        return var
                    else
                        return node.__info[prop1]
                    end
                end
            end
        end
    end
    local cur_value
    if value ~= nil then
        if #props == 2 then
            local p = node.__info[prop1]
            if p then
                cur_value = clone(p)
                cur_value[prop2] = value
            end
        elseif #props > 2 then
            local var = node.__info[props[1]]
            cur_value = clone(var)
            var = cur_value
            for i = 2, #props - 1 do
                var = var[tonumber(props[i]) and tonumber(props[i]) or props[i]]
            end
            var[tonumber(props[#props]) and tonumber(props[#props]) or props[#props]] = value
        else
            cur_value = value
        end
    end
    self:modifyValue(node, prop1, cur_value, notPostChanged)
    if #props == 2 then
        return tostring(node.__info[prop1][prop2])
    elseif #props > 2 then
        local var = node.__info[props[1]]
        for i = 2, #props do
            var = var[tonumber(props[i]) and tonumber(props[i]) or props[i]]
        end
        return var
    else
        return tostring(node.__info[prop1])
    end
end

-- for editor use
function generator:modifyValue(node, property, value, notPostChanged)
    if property == "id" then
        local ori_value = node.__info[property]
        node.__info[property] = value
        local cur_value = node.__info[property]
        if ori_value ~= cur_value then
            gk.event:post("executeCmd", "MODIFY_ID", {
                oldId = ori_value,
                curId = cur_value,
            })
        end
    else
        local ori_value = clone(node.__info[property])
        local cur_value = value
        if ori_value ~= cur_value and not (type(ori_value) == "table" and gk.util:table_eq(ori_value, cur_value)) then
            if not (node.__info and node.__info._isPhysics) then

                gk.event:post("executeCmd", "CHANGE_PROP", {
                    id = node.__info.id,
                    key = property,
                    from = ori_value,
                    parentId = node.__info.parentId,
                })
            end
            if not notPostChanged then
                gk.event:post("displayNode", node)
                gk.event:post("postSync")
            end
            if property == "visible" or property == "localZOrder" then
                gk.event:post("displayDomTree", true)
            end
        end
        node.__info[property] = cur_value
    end
end

generator.physicsCreator = {
    ["cc.PhysicsBody"] = function(info, node, rootTable)
        if node:getPhysicsBody() ~= nil then
            gk.log("node(%s) already has a physicsBody", node.__info.id)
            return nil
        end
        local obj = cc.PhysicsBody:create()
        node:setPhysicsBody(obj)
        info.id = info.id or config:genID("body", rootTable)
        return obj
    end,
    ["cc.PhysicsShapeCircle"] = function(info, node, rootTable)
        if node:getPhysicsBody() == nil then
            gk.log("node(%s) must create a physicsBody first!", node.__info.id)
            return nil
        end
        local obj = cc.PhysicsShapeCircle:create(info.radius, { density = info.density, restitution = info.restitution, friction = info.friction }, info.offset)
        node:getPhysicsBody():addShape(obj)
        info.id = info.id or config:genID("shapeCircle", rootTable)
        return obj
    end,
    ["cc.PhysicsShapePolygon"] = function(info, node, rootTable)
        if node:getPhysicsBody() == nil then
            gk.log("node(%s) must create a physicsBody first!", node.__info.id)
            return nil
        end
        local obj = cc.PhysicsShapePolygon:create(info.points, { density = info.density, restitution = info.restitution, friction = info.friction }, info.offset)
        node:getPhysicsBody():addShape(obj)
        info.id = info.id or config:genID("shapePolygon", rootTable)
        return obj
    end,
    ["cc.PhysicsShapeBox"] = function(info, node, rootTable)
        if node:getPhysicsBody() == nil then
            gk.log("node(%s) must create a physicsBody first!", node.__info.id)
            return nil
        end
        local obj = cc.PhysicsShapeBox:create(info.size, { density = info.density, restitution = info.restitution, friction = info.friction }, info.offset,
            info.radius)
        node:getPhysicsBody():addShape(obj)
        info.id = info.id or config:genID("shapeBox", rootTable)
        return obj
    end,
    ["cc.PhysicsShapeEdgeSegment"] = function(info, node, rootTable)
        if node:getPhysicsBody() == nil then
            gk.log("node(%s) must create a physicsBody first!", node.__info.id)
            return nil
        end
        local obj = cc.PhysicsShapeEdgeSegment:create(info.pointA, info.pointB, {
            density = info.density,
            restitution = info.restitution,
            friction = info.friction
        }, info.border)
        node:getPhysicsBody():addShape(obj)
        info.id = info.id or config:genID("shapeEdgeSegment", rootTable)
        return obj
    end,
    ["cc.PhysicsShapeEdgeBox"] = function(info, node, rootTable)
        if node:getPhysicsBody() == nil then
            gk.log("node(%s) must create a physicsBody first!", node.__info.id)
            return nil
        end
        local obj = cc.PhysicsShapeEdgeBox:create(info.size, { density = info.density, restitution = info.restitution, friction = info.friction }, info.border, info.offset)
        node:getPhysicsBody():addShape(obj)
        info.id = info.id or config:genID("shapeEdgeBox", rootTable)
        return obj
    end,
}


function generator:updateNodeSize(node, property)
    if node and node.__info then
        local p = node.__info[property]
        if type(p) == "string" and p == "$fill" then
            node.__info[property] = p
            self:updateChildSize(node, property)
        end
        self:updateNodeViewSize(node)
    end
end

function generator:updateChildSize(node, property)
    local children = node:getChildren()
    for _, child in ipairs(children) do
        if child and child.__info then
            local p = child.__info[property]
            if type(p) == "string" and p == "$fill" then
                -- update width/height($fill)
                child.__info[property] = p
                self:updateChildSize(child, property)
            end
            self:updateNodeViewSize(child)
        end
    end
end

function generator:updateNodeViewSize(node)
    if node and node.__info and gk.util:instanceof(node, "cc.ScrollView") then
        node.__info.viewSize = node.__info.viewSize
    end
end

return generator