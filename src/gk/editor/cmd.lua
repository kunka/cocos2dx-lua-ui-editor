--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/17/17
-- Time: 10:23
-- To change this template use File | Settings | File Templates.
--

local cmd = {}

cmd.MODIFY_ID = "MODIFY_ID"
cmd.MOVE = "MOVE"
cmd.CHANGE_PROP = "CHANGE_PROP"
cmd.ADD = "ADD"
cmd.DELETE = "DELETE"
cmd.CHANGE_CONTAINER = "CHANGE_CONTAINER"
cmd.REORDER = "REORDER"

local function getNode(rootLayer, id)
    local node = rootLayer[id]
    if not node then
        gk.log("cmd:getNode() error, cannot find node, id = %s", id)
    end
    return node
end

cmd.actions = {
    MODIFY_ID = {
        execute = function(rootLayer, params)
            gk.log("[execute:MODIFY_ID] from %s to %s", params.oldId, params.curId)
        end,
        undo = function(rootLayer, params)
            local node = getNode(rootLayer, params.curId)
            node.__info._id = params.oldId
            gk.log("[undo:MODIFY_ID] from %s to %s", params.curId, params.oldId)
        end
    },
    MOVE = {
        execute = function(rootLayer, params)
            local node = getNode(rootLayer, params.id)
            node.__info.x, node.__info.y = params.to.x, params.to.y
            gk.log("[execute:MOVE] move node %s to %.2f, %.2f", node.__info._id, node.__info.x, node.__info.y)
        end,
        undo = function(rootLayer, params)
            local node = getNode(rootLayer, params.id)
            node.__info.x, node.__info.y = params.from.x, params.from.y
            gk.log("[undo:MOVE] move node %s to %.2f, %.2f", node.__info._id, node.__info.x, node.__info.y)
        end
    },
    CHANGE_PROP = {
        execute = function(rootLayer, params)
            local node = getNode(rootLayer, params.id)
            gk.log("[execute:CHANGE_PROP] %s %s", node.__info._id, params.key)
            if params.key == "localZOrder" then
                local parent = getNode(rootLayer, params.parentId)
                params.ordersBefore = cmd:genOrders(parent)
            end
        end,
        undo = function(rootLayer, params)
            local node = getNode(rootLayer, params.id)
            node.__info[params.key] = params.from
            gk.log("[undo:CHANGE_PROP] %s %s", node.__info._id, params.key)
            gk.event:post("postSync")
            gk.event:post("displayNode", node)
            if params.ordersBefore then
                cmd:applyOrders(rootLayer, params.ordersBefore)
                gk.event:post("displayDomTree", true)
            end
        end
    },
    ADD = {
        execute = function(rootLayer, params)
            gk.log("[execute:ADD]")
        end,
        undo = function(rootLayer, params)
            gk.log("[undo:ADD]")
            local node = getNode(rootLayer, params.id)
            params.panel:deleteNode(node)
        end
    },
    DELETE = {
        execute = function(rootLayer, params)
            gk.log("[execute:DELETE] %s, parentId = %s", params.info._id, params.parentId)
            local parent = getNode(rootLayer, params.parentId)
            params.ordersBefore = cmd:genOrders(parent)
        end,
        undo = function(rootLayer, params)
            local parent = getNode(rootLayer, params.parentId)
            local node = gk.generator:inflate(params.info, nil, rootLayer)
            if node and parent then
                parent:addChild(node)
                cmd:applyOrders(rootLayer, params.ordersBefore)
                gk.log("[undo:DELETE] node %s", node.__info._id)
                gk.event:post("postSync")
                gk.event:post("displayNode", node)
                gk.event:post("displayDomTree")
            else
                gk.log("[undo:DELETE] error, create node or parent is nil, parentId = %s", params.parentId)
                gk.util:dump(params.info)
            end
        end
    },
    CHANGE_CONTAINER = {
        execute = function(rootLayer, params)
            gk.log("[execute:CHANGE_CONTAINER] %s, from %s to %s", params.id, params.fromPid, params.toPid)
            local parent = getNode(rootLayer, params.fromPid)
            params.ordersBefore = cmd:genOrders(parent)
        end,
        undo = function(rootLayer, params)
            local node = getNode(rootLayer, params.id)
            local parent = getNode(rootLayer, params.fromPid)
            if node and parent then
                node:retain()
                -- button child
                local pt = node:getParent()
                if pt and pt.__info and gk.util:instanceof(pt, "Button") and pt:getContentNode() == node then
                    pt:setContentNode(nil)
                end
                node:removeFromParent()
                parent:addChild(node)
                cmd:applyOrders(rootLayer, params.ordersBefore)
                node.__info.scaleX = params.sx
                node.__info.scaleY = params.sy
                node.__info.scaleXY = params.sxy
                node.__info.x, node.__info.y = params.fromPos.x, params.fromPos.y
                node:release()
                gk.log("[undo:CHANGE_CONTAINER] node %s, to %s", node.__info._id, params.fromPid)
                gk.event:post("postSync")
                gk.event:post("displayNode", node)
                gk.event:post("displayDomTree", true)
            else
                gk.log("[undo:CHANGE_CONTAINER] error, cannot find node or parent, id = %s, parentId = %s", params.id, params.fromPid)
                gk.util:dump(params)
            end
        end
    },
    REORDER = {
        execute = function(rootLayer, params)
            gk.log("[execute:REORDER]")
            local parent = getNode(rootLayer, params.parentId)
            params.ordersBefore = cmd:genOrders(parent)
        end,
        undo = function(rootLayer, params)
            cmd:applyOrders(rootLayer, params.ordersBefore)
            gk.log("[undo:REORDER]")
            gk.event:post("postSync")
            gk.event:post("displayDomTree", true)
        end
    },
}

function cmd:create(maxSize)
    cmd.cmdQueue = gk.List.new()
    self.maxSize = maxSize or 50
    return self
end

function cmd:execute(name, rootLayer, params)
    -- execute
    local action = self.actions[name]
    if action then
        action.execute(rootLayer, params)
    end

    -- push to queue
    if self.cmdQueue:size() >= self.maxSize then
        self.cmdQueue:popLeft()
    end
    self.cmdQueue:pushRight({
        name = name,
        rootLayer = rootLayer,
        params = params,
    })
    --    for i = self.cmdQueue.first, self.cmdQueue.last do
    --        local c = self.cmdQueue[i]
    --        gk.log("[" .. c.name .. "]")
    --    end
end

function cmd:undo()
    -- pop
    if self.cmdQueue:size() >= 1 then
        local cmd = self.cmdQueue:popRight()
        -- undo
        local action = self.actions[cmd.name]
        if action then
            action.undo(cmd.rootLayer, cmd.params)
        end
        --        for i = self.cmdQueue.first, self.cmdQueue.last do
        --            local c = self.cmdQueue[i]
        --            gk.log("[" .. c.name .. "]")
        --        end
    else
        gk.log("cmd:undo cmdQueue is empty!")
    end
end

function cmd:genOrders(parent)
    local orders = {}
    parent:sortAllChildren()
    local children = parent:getChildren()
    for i = 1, #children do
        local child = children[i]
        if child.__info then
            table.insert(orders, { id = child.__info._id, zOrder = child:getLocalZOrder() })
        end
    end
    return orders
end

function cmd:applyOrders(rootLayer, oerders)
    for i = 1, #oerders do
        local id = oerders[i].id
        local zOrder = oerders[i].zOrder
        local child = rootLayer[id]
        if child then
            child:setLocalZOrder(zOrder)
            child:getParent():reorderChild(child, zOrder)
        else
            gk.log("[applyOrders] error, cannot find node, id = %s", id)
        end
    end
end

return cmd