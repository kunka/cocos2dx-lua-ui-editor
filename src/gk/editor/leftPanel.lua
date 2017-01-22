--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午6:03
-- To change this template use File | Settings | File Templates.
--

local panel = {}

function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), gk.display.leftWidth, winSize.height - gk.display.topHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(0, 0)
    return self
end

function panel:undisplayNode()
    if self.displayDomInfoNode then
        self.displayDomInfoNode:removeFromParent()
        self.displayDomInfoNode = nil
    end
end

function panel:displayDomTree(rootLayer)
    if rootLayer then
        -- current layout
        self:undisplayNode()
        self.displayDomInfoNode = cc.Node:create()
        self:addChild(self.displayDomInfoNode)
        self.domDepth = 0
        self:displayDomNode(rootLayer, 0)
        local size = self:getContentSize()
        local createLine = function(y)
            gk.util:drawLineOnNode(self.displayDomInfoNode, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
        end
        createLine(size.height)

        -- other layout
        local keys = table.keys(gk.resource.genNodes)
        table.removebyvalue(keys, rootLayer.__cname)
        self:displayOthers(keys)
    end
end

function panel:displayDomNode(node, layer)
    local size = self:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local stepY = 20
    local stepX = 40
    local createButton = function(content, x, y)
        local group = false
        local children = node:getChildren()
        if children then
            for i = 1, #children do
                local child = children[i]
                if child and child.__info and child.__info.id then
                    group = true
                    break
                end
            end
        end
        if group then
            local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
            label:setTextColor(cc.c3b(200, 200, 200))
            if not node.__info._flod then
                label:setRotation(90)
            end
            label:setDimensions(10 / scale, 10 / scale)
            label:setContentSize(10 / scale, 10 / scale)
            local button = gk.ZoomButton.new(label)
            if not node.__info._flod then
                button:setScale(scale, scale * 0.6)
                button:setPosition(x - 3, y)
            else
                button:setScale(scale * 0.6, scale)
                button:setPosition(x + 1, y)
            end
            self.displayDomInfoNode:addChild(button)
            button:setAnchorPoint(0, 0.5)
            button:onClicked(function()
                gk.log("fold container %s", node.__info.id)
                node.__info._flod = not node.__info._flod
                gk.event:post("displayDomTree")
            end)
            x = x + 11
        end

        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(cc.c3b(200, 200, 200))
        if not gk.util:isGlobalVisible(node) then
            label:setOpacity(100)
        end
        local button = gk.ZoomButton.new(label)
        button:setScale(scale)
        self.displayDomInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x, y)
        button:onClicked(function()
            gk.event:post("displayNode", node)
            gk.event:post("displayDomTree")
        end)
        -- select
        if self.parent.displayingNode == node then
            gk.util:drawNodeRect(button, nil)
        end
        return button
    end
    local whiteSpace = ""
    for i = 1, layer do
        whiteSpace = whiteSpace .. " "
    end
    createButton(whiteSpace .. node.__info.id, leftX + 11 * layer, topY - stepY * self.domDepth)
    self.domDepth = self.domDepth + 1
    layer = layer + 1
    if not node.__info._flod then
        local children = node:getChildren()
        if children then
            for i = 1, #children do
                local child = children[i]
                if child and child.__info and child.__info.id then
                    self:displayDomNode(child, layer)
                end
            end
        end
    end
end

function panel:displayOthers(keys)
    local size = self:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local stepY = 20
    local createButton = function(content, x, y)
        local label = cc.Label:createWithSystemFont("▶", fontName, fontSize)
        label:setTextColor(cc.c3b(200, 200, 200))
        label:setDimensions(10 / scale, 10 / scale)
        label:setContentSize(10 / scale, 10 / scale)
        local button = gk.ZoomButton.new(label)
        button:setScale(scale * 0.6, scale)
        self.displayDomInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x + 1, y)
        button:onClicked(function()
            gk.event:post("unfoldRootLayout", content)
        end)
        x = x + 11

        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        local contentSize = cc.size(gk.display.leftWidth / scale, 20 / scale)
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        label:setDimensions(contentSize.width - 2 * leftX / scale, contentSize.height)
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(cc.c3b(200, 200, 200))
        local button = gk.ZoomButton.new(label)
        button:setScale(scale)
        self.displayDomInfoNode:addChild(button)
        button:setAnchorPoint(0, 0.5)
        button:setPosition(x, y)
        button:onClicked(function()
            gk.log("post changeRootLayout")
            gk.event:post("changeRootLayout", content)
        end)
        return button
    end
    for _, key in ipairs(keys) do
        createButton(key, leftX, topY - stepY * self.domDepth)
        self.domDepth = self.domDepth + 1
    end
end

return panel