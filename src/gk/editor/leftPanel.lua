--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 17/1/18
-- Time: 下午6:03
-- To change this template use File | Settings | File Templates.
--

local panel = {}

function panel:create(panel)
    self.parent = panel
    local winSize = cc.Director:getInstance():getWinSize()
    local layerColor = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), gk.display.leftWidth, winSize.height - gk.display.topHeight)
    layerColor:setPosition(0, 0)
    self.panel = layerColor
    return layerColor
end

function panel:undisplayNode()
    if self.displayDomInfoNode then
        self.displayDomInfoNode:removeFromParent()
        self.displayDomInfoNode = nil
    end
end

function panel:displayDomTree(rootLayer)
    if rootLayer then
        self:undisplayNode()
        self.displayDomInfoNode = cc.Node:create()
        self.panel:addChild(self.displayDomInfoNode)
        self.domDepth = 0
        self:displayDomNode(rootLayer, 0)
        local size = self.panel:getContentSize()
        local createLine = function(y)
            gk.util:drawLineOnNode(self.displayDomInfoNode, cc.p(10, y), cc.p(size.width - 10, y), cc.c4f(102 / 255, 102 / 255, 102 / 255, 1), -2)
        end
        createLine(size.height)
    end
end

function panel:displayDomNode(node, layer)
    local size = self.panel:getContentSize()
    local fontSize = 11 * 4
    local fontName = "Consolas"
    local scale = 0.25
    local topY = size.height - 15
    local leftX = 10
    local stepY = 20
    local stepX = 40
    local createButton = function(content, x, y)
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
    createButton(whiteSpace .. node.__info.id, leftX, topY - stepY * self.domDepth)
    self.domDepth = self.domDepth + 1
    layer = layer + 1
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

return panel