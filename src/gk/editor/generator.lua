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
                -- filter def value, except widget
                if (not (node.class and node.class._isWidget)) and ((type(def) == "table" and gk.util:table_eq(def, ret)) or tostring(def) == tostring(ret)) then
                    info[k] = nil
                else
                    info[k] = clone(ret)
                end
            else
                info[k] = clone(ret)
            end
        end
    end
    if gk.util:instanceof(node, "Button") or (gk.util:instanceof(node, "cc.Sprite") and not gk.util:instanceof(node, "ccui.Scale9Sprite")) then
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
            if child and child.__info and child.__info.id then
                if _isWidget and child.__rootTable == node then
                    -- ignore widget child
                else
                    info.children = info.children or {}
                    local c = self:deflate(child)
                    c.parentId = info.id
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
    if node and children then
        for i = 1, #children do
            local child = children[i]
            if child then
                local c = self:inflate(child, nil, rootTable)
                if c then
                    node:addChild(c)
                    -- update width/height($fill)
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
        local creator = self.nodeCreator[info._isWidget and "widget" or info.type]
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
        local id = info.id
        if id then
            local index = 1
            while rootTable[id] do
                id = info.id .. "_" .. tostring(index)
                index = index + 1
            end
            info.id = id
            rootTable[info.id] = node
        end
        node.__rootTable = rootTable
    end

    -- force set value
    for k, v in pairs(info.__self) do
        info[k] = v
    end
    return node
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
                    local node = rootTable and rootTable[proxy["id"]] or nil
                    return node and self.config:getDefaultValue(node, key) or nil
                else
                    return var
                end
            end
            --                        gk.log("get %s,%s", key, var)
            return var
        end,
        __newindex = function(_, key, value)
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
                            proxy[key] = value
                            gk.event:post("postSync")
                            gk.event:post("displayDomTree", true)
                        end
                    end
                else
                    gk.log("error set invalid id %s", value)
                end
                return
            end
            local node = rootTable and rootTable[proxy["id"]] or nil
            if node then
                proxy[key] = value
                self.config:setValue(node, key, value)
                gk.event:post("postSync")
                if key == "_lock" then
                    gk.event:post("displayDomTree", true)
                end
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
    ["ccui.Scale9Sprite"] = function(info, rootTable)
        local node = gk.create_scale9_sprite(info.file, info.capInsets)
        info.id = info.id or generator:genID("scale9Sprite", rootTable)
        return node
    end,
    ["ZoomButton"] = function(info, rootTable)
        local node = gk.ZoomButton.new()
        info.id = info.id or generator:genID("button", rootTable)
        return node
    end,
    ["SpriteButton"] = function(info, rootTable)
        local node = gk.SpriteButton.new(info.normalSprite, info.selectedSprite, info.disabledSprite)
        info.id = info.id or generator:genID("button", rootTable)
        return node
    end,
    ["ToggleButton"] = function(info, rootTable)
        local node = gk.ToggleButton.new()
        info.id = info.id or generator:genID("button", rootTable)
        return node
    end,
    ["ccui.CheckBox"] = function(info, rootTable)
        local node = ccui.CheckBox:create(info.backGround, info.cross)
        info.id = info.id or generator:genID("checkBox", rootTable)
        return node
    end,
    ["ccui.EditBox"] = function(info, rootTable)
        local node = ccui.EditBox:create(cc.size(info.width, info.height),
            gk.create_scale9_sprite(info.normalSprite, info.capInsets),
            gk.create_scale9_sprite(info.selectedSprite, info.capInsets),
            gk.create_scale9_sprite(info.disabledSprite, info.capInsets))
        info.id = info.id or generator:genID("editBox", rootTable)
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
        node:setDelegate()
        info.id = info.id or generator:genID("scrollView", rootTable)
        return node
    end,
    ["cc.TableView"] = function(info, rootTable)
        local node = cc.TableView:create(cc.size(info.width, info.height))
        node:setDelegate()
        info.id = info.id or generator:genID("tableView", rootTable)
        return node
    end,
    ["cc.ClippingNode"] = function(info, rootTable)
        -- Add an useless node
        local node = cc.ClippingNode:create(cc.Node:create())
        info.id = info.id or generator:genID("clippingNode", rootTable)
        return node
    end,
    ["cc.ClippingRectangleNode"] = function(info, rootTable)
        -- Add an useless node
        local node = cc.ClippingRectangleNode:create(info.clippingRegion)
        info.id = info.id or generator:genID("clippingRectNode", rootTable)
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
        local clazz = gk.resource:require(info.type)
        local node = clazz:create()
        local type = info.type
        local names = string.split(type, ".")
        local names = string.split(names[1], "/")
        type = names[#names]
        type = string.lower(type:sub(1, 1)) .. type:sub(2, type:len())
        -- copy info
        local keys = table.keys(node.__info.__self)
        for _, key in ipairs(keys) do
            if not info.__self[key] then
                info.__self[key] = node.__info.__self[key]
            end
        end
        info.id = info.id or generator:genID(type, rootTable)
        info._lock = 0
        return node
    end,
}

function generator:genID(type, rootTable)
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

function generator:updateSize(node, property)
    local children = node:getChildren()
    for i = 1, #children do
        local child = children[i]
        if child and child.__info then
            -- update width/height($fill)
            --            child.__info[property] = self.nodeGetFuncs[property](child)
            --            self:updateSize(child, property)
            child.__info[property] = child.__info[property]
            self:updateSize(child, property)
        end
    end
end

return generator