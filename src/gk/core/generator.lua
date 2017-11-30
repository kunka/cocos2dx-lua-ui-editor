--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/10
-- Time: 下午3:25
-- To change this template use File | Settings | File Templates.
--

local generator = {}

function generator:deflate(node)
    local info = {}

    -- add edit properties
    for k, ret in pairs(node.__info.__self) do
        if k ~= "children" and gk.editorConfig.editableProps[k] ~= nil then
            -- use %x to replace table
            if k == "color" or k == "textColor" or k == "effectColor" then
                local var = string.format("%02x%02x%02x", cc.clampf(ret.r, 0, 255), cc.clampf(ret.g, 0, 255), cc.clampf(ret.b, 0, 255))
                if ret.a then
                    var = var .. string.format("%02x", cc.clampf(ret.a, 0, 255))
                end
                if var == "ffffff" or var == "ffffffff" then
                    info[k] = nil
                else
                    info[k] = var
                end
            else
                local def = gk.editorConfig.defValues[k]
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
    return info
end

function generator:inflate(info, rootNode, rootTable)
    local children = info.children
    local node = self:createNode(info, rootNode, rootTable)
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
        local creator = gk.editorConfig.nodeCreator[info._isWidget and "widget" or info.type]
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
            local id = gk.editorConfig:genID(node.__info.type, rootTable)
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
        if v and (k == "color" or k == "textColor" or k == "effectColor") then
            info[k] = info[k]
        else
            info[k] = v
        end
    end
    return node
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
            gk.editorConfig:setValue(node, key, value)
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
        if var and (key == "color" or key == "textColor" or key == "effectColor") and type(var) == "string" then
            -- use %x to replace table
            local v = {}
            v.r = tonumber("0x" .. string.sub(var, 1, 2))
            v.g = tonumber("0x" .. string.sub(var, 3, 4))
            v.b = tonumber("0x" .. string.sub(var, 5, 6))
            if string.len(var) == 8 then
                v.a = tonumber("0x" .. string.sub(var, 7, 8))
            end
            proxy[key] = v
            return v
        end
        if var == nil then
            local node = rootTable and rootTable[proxy["id"]] or nil
            return node and gk.editorConfig:getValue(node, key) or nil
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

function generator:parseValue(key, node, input, ...)
    local v = self:parseMacroFunc(node, input)
    if v then
        v = v(key, node, ...)
    end
    return v or input
end

function generator:parseX(node, x, scaleX)
    local x = self:parseValue("x", node, x)
    x = tonumber(scaleX) == 1 and x or self:parseValue("scaleX", node, scaleX, x)
    return x
end

function generator:parseY(node, y, scaleY)
    local y = self:parseValue("y", node, y)
    y = tonumber(scaleY) == 1 and y or self:parseValue("scaleY", node, scaleY, y)
    return y
end

function generator:parseXRvs(node, x, scaleX)
    local x = self:parseValue("x", node, x)
    x = tonumber(scaleX) == 1 and x or self:parseValue("scaleX", node, scaleX .. "Rvs", x)
    return x
end

function generator:parseYRvs(node, y, scaleY)
    local y = self:parseValue("y", node, y)
    y = tonumber(scaleY) == 1 and y or self:parseValue("scaleY", node, scaleY .. "Rvs", y)
    return y
end

function generator:parseMacroFunc(node, input)
    if type(input) == "string" and string.len(input) > 1 and input:sub(1, 1) == "$" then
        local macro = input:sub(2, #input)
        -- global preset get func
        local func = gk.editorConfig.macroFuncs[macro]
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
function generator:modifyByInput(node, property, input, valueType, notPostChanged)
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
            gk.event:post("executeCmd", "CHANGE_PROP", {
                id = node.__info.id,
                key = property,
                from = ori_value,
                parentId = node.__info.parentId,
            })
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