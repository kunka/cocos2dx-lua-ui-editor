--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local display = {}

local displayScale = 0.4--0.56--0.4
display.deviceSizes = {
    cc.size(1280 * displayScale, 720 * displayScale),
    cc.size(1280 * displayScale, 853 * displayScale),
    cc.size(1280 * displayScale, 960 * displayScale),
    cc.size(1280 * displayScale, 1280 * displayScale),
    cc.size(720 * displayScale, 1280 * displayScale),
}

display.deviceSizesDesc = {
    "1280x720(16:9)",
    "1280x853(1.5:1)",
    "1280x960(4:3)",
    "1280x1280(1:1)",
    "720x1280(9:16)",
}

function display:initWithDesignSize(size)
    if gk.mode == gk.MODE_EDIT then
        display.topHeight = 80
        display.leftWidth = 210
        display.rightWidth = 210
        display.bottomHeight = 20
    else
        display.topHeight = 0
        display.leftWidth = 0
        display.rightWidth = 0
        display.bottomHeight = 0
    end
    -- set editor win size
    local s = display.deviceSizes[cc.UserDefault:getInstance():getIntegerForKey("deviceSizeIndex", 1)]
    local winSize = {}
    winSize.width = s.width + display.leftWidth + display.rightWidth
    winSize.height = s.height + display.topHeight + display.bottomHeight
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setFrameSize(winSize.width, winSize.height)
    gk.log("set OpenGLView size(%.1f,%.1f)", winSize.width, winSize.height)

    local winSize = cc.Director:getInstance():getWinSize()
    gk.log("display init with winSize(%.1f,%.1f)", winSize.width, winSize.height)
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
    gk.log("display.init designSize(%.1f,%.1f), winSize(%.1f,%.1f), xScale(%.4f), yScale(%.4f), minScale(%.4f), maxScale(%.4f)",
        size.width, size.height, display.winSize().width, display.winSize().height,
        display.xScale(), display.yScale(), display.minScale(), display.maxScale())
end

function display:addEditorPanel(scene)
    gk.log("display:addEditorPanel")
    local panel = require("gk.editor.panel")
    scene:addChild(panel.create(scene), 9999999)
end

return display