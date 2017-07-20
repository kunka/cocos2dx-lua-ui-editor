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

    -- patch
    info["parentId"] = nil

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
                if child.__ingore or (_isWidget and child.__rootTable == node) then
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
                return
            end
            local node = rootTable and rootTable[proxy["id"]] or nil
            if node then
                local pre = proxy[key]
                proxy[key] = value
                self.config:setValue(node, key, value)
                if pre ~= value then
                    gk.event:post("postSync")
                    if key == "_lock" then
                        gk.event:post("displayDomTree", true)
                    end
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

-- for editor use
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
        local v = self:parseMacroFunc(node, input)
        if v then
            value = input
        elseif valueType == "string" then
            value = input
        elseif valueType == "number" then
            value = tonumber(input)
            if value == nil then
                gk.log("modify \"%s\" need number value, error input = \"%s\"", property, input)
                if prop2 then
                    return node.__info[prop1][prop2]
                else
                    return node.__info[prop1]
                end
            end
        end
    end
    local cur_value
    if value then
        if prop2 then
            local p = node.__info[prop1]
            if p then
                cur_value = clone(p)
                cur_value[prop2] = value
            end
        else
            cur_value = value
        end
    end
    self:modifyValue(node, prop1, cur_value)
    if prop2 then
        return tostring(node.__info[prop1][prop2])
    else
        return tostring(node.__info[prop1])
    end
end

-- for editor use
function generator:modifyValue(node, property, value)
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
            gk.event:post("displayNode", node)
            gk.event:post("postSync")
            if property == "visible" or property == "localZOrder" then
                gk.event:post("displayDomTree", true)
            end
        end
        node.__info[property] = cur_value
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
        local node = gk.SpriteButton.new(info.normalSprite, info.selectedSprite, info.disabledSprite, info.capInsets)
        info.id = info.id or generator:genID("button", rootTable)
        return node
    end,
    ["ToggleButton"] = function(info, rootTable)
        local node = gk.ToggleButton.new()
        info.id = info.id or generator:genID("button", rootTable)
        return node
    end,
    ["CheckBox"] = function(info, rootTable)
        local node = gk.CheckBox:create(info.normalSprite, info.selectedSprite, info.disabledSprite)
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
    --    ["ccui.Layout"] = function(info, rootTable)
    --        local node = ccui.Layout:create()
    --        info.id = info.id or generator:genID("layout", rootTable)
    --        return node
    --    end,
    ["cc.Label"] = function(info, rootTable)
        local node = gk.create_label_local(info)
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
            local sprite = generator:createNode(info.sprite, nil, rootTable)
            -- create ProgressTimer
            sprite.__info._lock = 0
            local node = cc.ProgressTimer:create(sprite)
            info.id = info.id or generator:genID("progressTimer", rootTable)
            sprite.__info.id = info.id .. "_sprite"
            return node
        end
        return nil
    end,
    ["cc.TMXTiledMap"] = function(info, rootTable)
        if info.tmx then
            local node = cc.TMXTiledMap:create(info.tmx)
            info.id = info.id or generator:genID("tmxTiledMap", rootTable)
            return node
        end
        return nil
    end,
    ["cc.ParticleSystemQuad"] = function(info, rootTable)
        if info.particle and info.particle ~= "" then
            local node = cc.ParticleSystemQuad:create(info.particle)
            info.id = info.id or generator:genID("particleSystemQuad", rootTable)
            return node
        elseif info.totalParticles and info.totalParticles > 0 then
            local node = cc.ParticleSystemQuad:createWithTotalParticles(info.totalParticles)
            info.id = info.id or generator:genID("particleSystemQuad", rootTable)
            return node
        end
        return nil
    end,
    --------------------------- Custom widgets   ---------------------------
    ["widget"] = function(info, rootTable)
        local node = gk.injector:inflateNode(info.type)
        node.__ingore = false
        -- copy info
        local keys = table.keys(node.__info.__self)
        for _, key in ipairs(keys) do
            if info.__self[key] == nil then
                info.__self[key] = node.__info.__self[key]
            end
        end
        info.id = info.id or generator:genID(info.type, rootTable)
        info._lock = 0
        return node
    end,
}

function generator:genID(type, rootTable)
    local names = string.split(type, ".")
    local names = string.split(names[1], "/")
    type = names[#names]
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