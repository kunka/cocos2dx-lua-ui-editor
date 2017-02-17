--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local inject = {}

function inject:layer_method_swizz(type, methodName)
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

function inject:scene_method_swizz(type, methodName)
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

function inject:node_method_swizz(type, methodName)
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

inject:scene_method_swizz(cc.Scene, "create")
inject:layer_method_swizz(cc.Layer, "create")
inject:layer_method_swizz(cc.LayerColor, "create")
inject:node_method_swizz(cc.Sprite, "create")
inject:node_method_swizz(cc.Sprite, "createWithSpriteFrame")
inject:node_method_swizz(cc.Sprite, "createWithTexture")
inject:node_method_swizz(cc.Node, "create")
inject:node_method_swizz(cc.Label, "createWithSystemFont")
inject:node_method_swizz(cc.Label, "createWithTTF")
inject:node_method_swizz(cc.Label, "createWithBMFont")

function inject:ctor_method_swizz(type, methodName)
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

function inject:init()
    gk.event:subscribe(self, "onNodeCreate", function(node)
        self:initLayer(node)
    end)
end

function inject:inflateNode(cname)
    local clazz = require(gk.resource.genNodes[cname].path)
    local node = clazz:create()
    return node
end

function inject:initLayer(layer)
    if layer and gk.resource.genNodes[layer.__cname] and not layer.__info then
        local generator = require("gk.editor.generator")
        local file = gk.resource.genPath .. "_" .. layer.__cname:lower()
        local status, info = pcall(require, file)
        if status then
            gk.log("initLayer with file %s", file)
            layer.__info = generator:wrap({ type = layer.__cname }, layer)
            --            layer.__info.id = "root"
            generator:inflate(info, layer, layer)
            layer.__info.x, layer.__info.y = gk.display.leftWidth, gk.display.bottomHeight
            local clazz = require(gk.resource.genNodes[layer.__cname].path)
            local isLayer = iskindof(clazz, "Layer") or iskindof(clazz, "Dialog")
            if isLayer then
                layer.__info.width = gk.display.winSize().width
                layer.__info.height = gk.display.winSize().height
            end
            --            if iskindof(layer, "cc.TableViewCell") then
            --            layer.__info.lock = 1
            --            end
            --            dump(info)
        else
            -- init first time
            gk.log("initLayer first time %s ", file)
            layer.__info = generator:wrap({ type = layer.__cname }, layer)
            layer.__info.id = layer.__cname
            layer[layer.__info.id] = layer
            layer.__info.x, layer.__info.y = gk.display.leftWidth, gk.display.bottomHeight
            --            if iskindof(layer, "cc.TableViewCell") then
            --            layer.__info.lock = 1
            --            end
            self:sync(layer)
        end
        if gk.mode == gk.MODE_EDIT then
            gk.event:post("displayDomTree", layer)
            layer:runAction(cc.CallFunc:create(function()
                gk.event:post("displayNode", layer)
                gk.event:post("displayDomTree")
            end))
        end
    end
end

function inject:sync(node)
    if node and gk.resource.genNodes[node.__cname] then
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

return inject
