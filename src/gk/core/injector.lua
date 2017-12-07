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
            if gk.mode ~= gk.MODE_RELEASE then
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
            if gk.mode ~= gk.MODE_RELEASE then
                gk.editorPanel:attachToScene(node)
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
            if gk.mode ~= gk.MODE_RELEASE then
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

-- for root containers
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
        -- ignore by editor
        node.__ignore = true
        return node
    else
        gk.log("inflateNode %s error, return nil", path)
        return nil
    end
end

function injector:onNodeCreate(node)
    if node and not node.__info and node.__cname then
        -- root container node
        local path = gk.resource:getGenNodePath(node.__cname)
        if not path then
            gk.log("onNodeCreate %s error, cannot find gen node path", node.__cname)
            return
        end
        if gk.mode ~= gk.MODE_RELEASE then
            -- reload package
            package.loaded[path] = nil
        end
        gk.profile:start("injector:createNode")
        self:registerCustomProp(node)
        local status, info = pcall(require, path)
        if status then
            -- must clone values
            info = clone(info)
            --            gk.log("inflate node with file %s", path)
            gk.generator:inflate(info, node, node)
            local isWidget = node.class and node.class._isWidget
            if not isWidget and not gk.util:instanceof(node, "TableViewCell") then
                node.__info.width, node.__info.height = "$fill", "$fill"
            end
        else
            if gk.mode == gk.MODE_EDIT then
                -- init first time
                gk.log("inflate node first time %s ", path)
                node.__info = gk.generator:wrap({ type = node.__cname, width = "$fill", height = "$fill" }, node)
                node.__info._id = gk.editorConfig:genID(node.__cname, node)
                node[node.__info._id] = node
                node.__info.width, node.__info.height = "$fill", "$fill"
                self:sync(node)
            end
        end
        gk.profile:stop("injector:createNode", node.__cname)
    end
end

function injector:sync(node)
    if CFG_SCAN_NODES and node and gk.resource.genNodes[node.__cname] then
        -- root container node
        local nd = node or self.scene.layer
        gk.log("start sync %s", nd.__info._id)
        local info = gk.generator:deflate(nd)
        local path = gk.resource:getGenNodeFullPath(nd.__cname)
        local table2lua = require("gk.tools.table2lua")
        if gk.errorOccurs then
            gk.log(table2lua.encode_pretty(info))
            gk.log("[Warning!] exception occured! please fix it then flush to file!")
        else
            gk.log("sync to file: " .. path .. (io.writefile(path, table2lua.encode_pretty(info)) and " success!" or " failed!!!"))
        end
    end
end

function injector:registerCustomProp(node)
    node.registerCustomProp = function(_, prop, propType, default)
        if gk.mode ~= gk.MODE_RELEASE then
            local tp = node.__cname
            -- check getter and setter
            --        local getter = "get" .. string.upper(prop:sub(1, 1)) .. prop:sub(2, prop:len())
            --        local setter = "set" .. string.upper(prop:sub(1, 1)) .. prop:sub(2, prop:len())
            --        if type(node[getter]) ~= "function" or type(node[setter]) ~= "function" then
            --            gk.util:reportError(string.format("registerCustomProp %s-%s error, getter or setter not found", tp, prop))
            --            return
            --        end
            if propType == "number" then
                --                gk.editorConfig:registerCustomFloatProp(tp, prop)
                local tbl = gk.exNodeDisplayer[tp]
                if not tbl then
                    tbl = { _type = tp, }
                    gk.editorConfig:registerDisplayProps(tbl)
                end
                local numProps = tbl.numProps or {}
                local notFound = true
                for _, p in ipairs(numProps) do
                    if p.key == prop then
                        notFound = false
                        break
                    end
                end
                if notFound then
                    table.insert(numProps, { key = prop, default = default })
                    tbl.numProps = numProps
                end
            end
        end
    end
end

return injector
