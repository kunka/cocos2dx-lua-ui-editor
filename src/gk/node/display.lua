--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local display = {}

display.topHeight = 80
display.leftWidth = 140
display.rightWidth = 180
display.bottomHeight = 20
function display.initWithDesignSize(size)
    local winSize = cc.Director:getInstance():getWinSize()
    display.winSize = function() return cc.size(winSize.width - display.leftWidth - display.rightWidth, winSize.height - display.topHeight - display.bottomHeight) end
    display.width = function() return size.width end
    display.height = function() return size.height end
    display.xScale = function() return display.winSize().width / display.width() end
    display.yScale = function() return display.winSize().height / display.height() end
    display.minScale = function() return math.min(display.xScale(), display.yScale()) end
    display.maxScale = function() return math.max(display.xScale(), display.yScale()) end
    display.scaleMin = function(pos, posY)
        local y = posY and posY or pos.y
        local x = posY and pos or pos.x
        local p = cc.p(display.minScale() * x, display.minScale() * y)
        return p
    end
    display.scaleX = function(x)
        return x * display.xScale()
    end
    display.scaleY = function(y)
        return y * display.yScale()
    end
    display.scaleXY = function(pos, posY)
        local y = posY and posY or pos.y
        local x = posY and pos or pos.x
        local p = cc.p(display.xScale() * x, display.yScale() * y)
        return p
    end
    gk.log("display.init designSize(%.1f,%.1f), winSize(%.1f,%.1f), xScale(%.1f), yScale(%.1f), minScale(%.1f), maxScale(%.1f)",
        size.width, size.height, display.winSize().width, display.winSize().height,
        display.xScale(), display.yScale(), display.minScale(), display.maxScale())
end

function display.addEditorPanel(scene)
    gk.log("display.addEditorPanel")
    local panel = require("gk.editor.panel")
    scene:addChild(panel:create(scene), 9999999)
end

return display