--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local injector = {}

function injector:layer_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            if gk.mode == gk.MODE_EDIT then
                local vars = { ... }
                local count = #vars
                if count <= 2 then
                    node:setContentSize(gk.display.winSize())
                end
                gk.event:post("onNodeCreate", node)
            end
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

function injector:scene_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            if gk.mode == gk.MODE_EDIT then
                gk.display:addEditorPanel(node)
            end
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

function injector:node_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            if gk.mode == gk.MODE_EDIT then
                gk.event:post("onNodeCreate", node)
            end
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

injector:scene_method_swizz(cc.Scene, "create")
injector:layer_method_swizz(cc.Layer, "create")
injector:layer_method_swizz(cc.LayerColor, "create")
injector:layer_method_swizz(cc.LayerGradient, "create")
injector:node_method_swizz(cc.Sprite, "create")
injector:node_method_swizz(cc.Sprite, "createWithSpriteFrame")
injector:node_method_swizz(cc.Sprite, "createWithTexture")
injector:node_method_swizz(cc.Scale9Sprite, "createWithSpriteFrame")
injector:node_method_swizz(cc.Node, "create")
injector:node_method_swizz(cc.Label, "createWithSystemFont")
injector:node_method_swizz(cc.Label, "createWithTTF")
injector:node_method_swizz(cc.Label, "createWithBMFont")
injector:node_method_swizz(cc.ClippingNode, "create")

function injector:ctor_method_swizz(type, methodName)
    if not type["__" .. methodName .. "__swizzed"] then
        local method = type[methodName]
        local __method = function(node, ...)
            method(node, ...)
            gk.event:post("onNodeCreate", node)
        end
        type[methodName] = __method
        type["__" .. methodName .. "__swizzed"] = true
    end
end

function injector:init()
    gk.event:subscribe(self, "onNodeCreate", function(node)
        self:onNodeCreate(node)
    end)
end

function injector:inflateNode(cname)
    local clazz = require(gk.resource.genNodes[cname].path)
    local node = clazz:create()
    return node
end

function injector:onNodeCreate(node)
    if node and gk.resource.genNodes[node.__cname] and not node.__info then
        -- root container node
        local generator = require("gk.editor.generator")
        local file = gk.resource.genPath .. "_" .. node.__cname:lower()
        local status, info = pcall(require, file)
        if status then
            gk.log("initRootContainer with file %s", file)
            node.__info = generator:wrap({ type = node.__cname }, node)
            generator:inflate(info, node, node)
            node.__info.x, node.__info.y = gk.display.leftWidth, gk.display.bottomHeight
        else
            -- init first time
            gk.log("initRootContainer first time %s ", file)
            node.__info = generator:wrap({ type = node.__cname }, node)
            node.__info.id = node.__cname
            node[node.__info.id] = node
            node.__info.x, node.__info.y = gk.display.leftWidth, gk.display.bottomHeight
            local clazz = require(gk.resource.genNodes[node.__cname].path)
            local isLayer = iskindof(clazz, "Layer") or iskindof(clazz, "Dialog")
            if isLayer then
                node.__info.width = generator:default("Layer", "width")
                node.__info.height = generator:default("Layer", "height")
            end
            if iskindof(node, "cc.TableViewCell") then
                node.__info.width = generator:default("cc.TableViewCell", "width")
                node.__info.height = generator:default("cc.TableViewCell", "height")
            end
            self:sync(node)
        end
        if gk.mode == gk.MODE_EDIT then
            gk.event:post("displayDomTree", node)
            node:runAction(cc.CallFunc:create(function()
                gk.event:post("displayNode", node)
                gk.event:post("displayDomTree")
            end))
        end
    end
end

function injector:sync(node)
    if node and gk.resource.genNodes[node.__cname] then
        -- root container node
        local generator = require("gk.editor.generator")
        local nd = node or self.scene.layer
        gk.log("start sync %s", nd.__info.id)
        local info = generator:deflate(nd)
        local table2lua = require("gk.tools.table2lua")
        local file = gk.resource.genPath .. "_" .. nd.__cname:lower() .. ".lua"
        gk.log("sync to file: " .. file)
        --    gk.log(table2lua.encode_pretty(info))
        io.writefile(file, table2lua.encode_pretty(info))
    end
end

return injector
