--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local util = {}
function util.layer_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            local vars = { ... }
            local count = #vars
            if count <= 2 then
                node:setContentSize(gk.display.winSize())
            end
            gk.event:post("onNodeCreate", node)
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

util.layer_method_swizz(cc.Layer, "create")
util.layer_method_swizz(cc.LayerColor, "create")

function util.scene_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            gk.display.addEditorPanel(node)
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

util.scene_method_swizz(cc.Scene, "create")

function util.sprite_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            gk.event:post("onNodeCreate", node)
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

util.sprite_method_swizz(cc.Sprite, "create")
util.sprite_method_swizz(cc.Sprite, "createWithSpriteFrame")
util.sprite_method_swizz(cc.Sprite, "createWithTexture")

function util.node_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            gk.event:post("onNodeCreate", node)
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

util.node_method_swizz(cc.Node, "create")
util.node_method_swizz(cc.Label, "createWithSystemFont")
util.node_method_swizz(cc.Label, "createWithTTF")
util.node_method_swizz(cc.Label, "createWithBMFont")

