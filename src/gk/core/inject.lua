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
            if gk.MODE == 1 then
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

inject:layer_method_swizz(cc.Layer, "create")
inject:layer_method_swizz(cc.LayerColor, "create")

function inject:scene_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            if gk.MODE == 1 then
                gk.display:addEditorPanel(node)
            end
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

inject:scene_method_swizz(cc.Scene, "create")

function inject:sprite_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            if gk.MODE == 1 then
                gk.event:post("onNodeCreate", node)
            end
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

inject:sprite_method_swizz(cc.Sprite, "create")
inject:sprite_method_swizz(cc.Sprite, "createWithSpriteFrame")
inject:sprite_method_swizz(cc.Sprite, "createWithTexture")

function inject:node_method_swizz(type, methodName)
    if not type[methodName .. "__swizzed"] then
        local meta = getmetatable(type)
        local method = meta[methodName]
        local __method = function(...)
            local node = method(...)
            if gk.MODE == 1 then
                gk.event:post("onNodeCreate", node)
            end
            return node
        end
        meta[methodName] = __method
        type[methodName .. "__swizzed"] = true
    end
end

inject:node_method_swizz(cc.Node, "create")
inject:node_method_swizz(cc.Label, "createWithSystemFont")
inject:node_method_swizz(cc.Label, "createWithTTF")
inject:node_method_swizz(cc.Label, "createWithBMFont")

return inject
