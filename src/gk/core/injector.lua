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
                    node:setContentSize(gk.display:winSize())
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

function injector:inflateNode(path, ...)
    local clazz = gk.resource:require(path)
    if clazz then
        local node = clazz:create(...)
        node.__ingore = true
        return node
    else
        return nil
    end
end

function injector:onNodeCreate(node)
    if node and not node.__info and node.__cname then
        -- root container node
        local path = gk.resource:getGenNodePath(node.__cname)
        if not path then
            return
        end
        gk.profile:start("injector:createNode")
        local status, info = pcall(require, path)
        if status then
            -- must clone values
            info = clone(info)
            gk.log("inflate node with file %s", path)
            gk.generator:inflate(info, node, node)
            node.__info.x, node.__info.y = gk.display.leftWidth, gk.display.bottomHeight
            node.__info.scaleXY = { x = "1", y = "1" }
            if not (node.class and node.class._isWidget) and not gk.util:instanceof(node, "TableViewCell") then
                node.__info.width, node.__info.height = "$fill", "$fill"
            end
        else
            if gk.mode == gk.MODE_EDIT then
                -- init first time
                gk.log("inflate node first time %s ", path)
                node.__info = gk.generator:wrap({ type = node.__cname, width = "$fill", height = "$fill" }, node)
                node.__info.id = gk.generator:genID(node.__cname, node)
                node[node.__info.id] = node
                node.__info.x, node.__info.y = gk.display.leftWidth, gk.display.bottomHeight
                node.__info.width, node.__info.height = "$fill", "$fill"
                node.__info.scaleXY = { x = "1", y = "1" }
                self:sync(node)
            end
        end
        gk.profile:stop("injector:createNode", node.__cname)
        if gk.mode == gk.MODE_EDIT then
            --            if node.class and not node.class._isWidget then
            --                gk.util:drawNode(node, cc.c4f(120, 200 / 255, 0, 1))
            --            end
            node:runAction(cc.CallFunc:create(function()
                if not gk.util:instanceof(node, "TableViewCell") then
                    gk.event:post("displayNode", node)
                end
                gk.event:post("displayDomTree")
            end))
        end
    end
end

function injector:sync(node)
    if CFG_SCAN_NODES and node and gk.resource.genNodes[node.__cname] then
        -- root container node
        local generator = require("gk.editor.generator")
        local nd = node or self.scene.layer
        gk.log("start sync %s", nd.__info.id)
        local info = generator:deflate(nd)
        local path = gk.resource:getGenNodeFullPath(nd.__cname)
        local table2lua = require("gk.tools.table2lua")
        if gk.exception then
            gk.log(table2lua.encode_pretty(info))
            gk.log("[Warning!] exception occured! please fix it then flush to file!")
        else
            gk.log("sync to file: " .. path .. (io.writefile(path, table2lua.encode_pretty(info)) and " success!" or " failed!!!"))
        end
    end
end

return injector
