--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local display = {}

local displayScale = 0.55
display.deviceSizes = {
    cc.size(1280 * displayScale, 640 * displayScale),
    cc.size(1280 * displayScale, 720 * displayScale),
    cc.size(1280 * displayScale, 853 * displayScale),
    cc.size(1280 * displayScale, 960 * displayScale),
    cc.size(1280 * displayScale, 1280 * displayScale),
    cc.size(720 * displayScale, 1280 * displayScale),
}

display.deviceSizesDesc = {
    "1280x640(2:1)",
    "1280x720(16:9)",
    "1280x853(1.5:1)",
    "1280x960(4:3)",
    "1280x1280(1:1)",
    "720x1280(9:16)",
}

-- new resolution policy
cc.ResolutionPolicy.UNIVERSAL = 5
display.supportResolutionPolicyDesc = { "UNIVERSAL", "FIXED_HEIGHT", "FIXED_WIDTH" }
display.supportResolutionPolicy = { cc.ResolutionPolicy.UNIVERSAL, cc.ResolutionPolicy.FIXED_HEIGHT, cc.ResolutionPolicy.FIXED_WIDTH }
function display:initWithDesignSize(size, resolutionPolicy)
    display.resolutionPolicy = resolutionPolicy or display.supportResolutionPolicy[cc.UserDefault:getInstance():getIntegerForKey("gk_resolutionPolicy", 1)]
    display.resolutionPolicyDesc = display.supportResolutionPolicyDesc[table.indexof(display.supportResolutionPolicy, display.resolutionPolicy)]
    if gk.mode == gk.MODE_EDIT then
        display.topHeight = 100
        display.leftWidth = 240
        display.rightWidth = 240
        display.bottomHeight = 100
    else
        display.topHeight = 0
        display.leftWidth = 0
        display.rightWidth = 0
        display.bottomHeight = 0
    end
    -- set editor win size
    local s = display.deviceSizes[cc.UserDefault:getInstance():getIntegerForKey("gk_deviceSizeIndex", 1)]
    local winSize = {}
    winSize.width = s.width + display.leftWidth + display.rightWidth
    winSize.height = s.height + display.topHeight + display.bottomHeight
    local director = cc.Director:getInstance()
    local view = director:getOpenGLView()
    view:setFrameSize(winSize.width, winSize.height)
    view:setDesignResolutionSize(winSize.width, winSize.height, 0)
    gk.log("set OpenGLView size(%.1f,%.1f)", winSize.width, winSize.height)
    view:setViewName("!!!") -- not implemented :(

    local winSize = cc.Director:getInstance():getWinSize()
    gk.log("display init with winSize(%.1f,%.1f), resolutionPolicy = %s", winSize.width, winSize.height, display.resolutionPolicyDesc)
    display.winSize = function() return cc.size(winSize.width - display.leftWidth - display.rightWidth, winSize.height - display.topHeight - display.bottomHeight) end
    display.width = function() return size.width end
    display.height = function() return size.height end
    local xScale, yScale = display:winSize().width / display.width(), display:winSize().height / display.height()
    local minScale, maxScale = math.min(xScale, yScale), math.max(xScale, yScale)
    if display.resolutionPolicy == cc.ResolutionPolicy.FIXED_WIDTH then
        display.xScale = function() return xScale end
        display.yScale = function() return xScale end
        display.minScale = function() return xScale end
        display.maxScale = function() return xScale end
        display.scaleX = function(_, x)
            return x * xScale
        end
        display.scaleY = function(_, y)
            return xScale * y + (display:winSize().height - display.height() * xScale) / 2
        end
        display.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(xScale * x, xScale * y + (display:winSize().height - display.height() * xScale) / 2)
        end
        display.scaleXRvs = function(_, x)
            return x / xScale
        end
        display.scaleYRvs = function(_, y)
            return (y - (display:winSize().height - display.height() * xScale) / 2) / xScale
        end
        display.scaleXYRvs = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(x / xScale, (y - (display:winSize().height - display.height() * xScale) / 2) / xScale)
        end
        display.scaleTP = function(_, y)
            return xScale * y + (display:winSize().height - display.height() * xScale)
        end
        display.scaleBT = function(_, y)
            return xScale * y
        end
        display.scaleLT = display.scaleX
        display.scaleRT = display.scaleX
    elseif display.resolutionPolicy == cc.ResolutionPolicy.FIXED_HEIGHT then
        display.xScale = function() return yScale end
        display.yScale = function() return yScale end
        display.minScale = function() return yScale end
        display.maxScale = function() return yScale end
        display.scaleX = function(_, x)
            return x * yScale + (display:winSize().width - display.width() * yScale) / 2
        end
        display.scaleY = function(_, y)
            return yScale * y
        end
        display.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(x * yScale + (display:winSize().width - display.width() * yScale) / 2, yScale * y)
        end
        display.scaleXRvs = function(_, x)
            return (x - (display:winSize().width - display.width() * yScale) / 2) / yScale
        end
        display.scaleYRvs = function(_, y)
            return y / yScale
        end
        display.scaleXYRvs = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p((x - (display:winSize().width - display.width() * yScale) / 2) / yScale, y / yScale)
        end
        display.scaleLT = function(_, x)
            return x * yScale
        end
        display.scaleRT = function(_, x)
            return x * yScale + (display:winSize().width - display.width() * yScale)
        end
        display.scaleTP = display.scaleY
        display.scaleBT = display.scaleY
    elseif display.resolutionPolicy == cc.ResolutionPolicy.UNIVERSAL then
        display.xScale = function() return xScale end
        display.yScale = function() return yScale end
        display.minScale = function() return minScale end
        display.maxScale = function() return maxScale end
        display.scaleX = function(_, x)
            return x * xScale
        end
        display.scaleY = function(_, y)
            return y * yScale
        end
        display.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(xScale * x, yScale * y)
        end
        display.scaleXRvs = function(_, x)
            return x / xScale
        end
        display.scaleYRvs = function(_, y)
            return y / yScale
        end
        display.scaleXYRvs = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(x / xScale, y / yScale)
        end
        display.scaleLT = display.scaleX
        display.scaleRT = display.scaleX
        display.scaleTP = display.scaleY
        display.scaleBT = display.scaleY
    else
        -- not supported
        gk.log("display init with not supported resolutionPolicy")
        display.xScale = function() return minScale end
        display.yScale = function() return minScale end
        display.minScale = function() return minScale end
        display.maxScale = function() return minScale end
        display.scaleX = function(_, x)
            return x * xScale
        end
        display.scaleY = function(_, y)
            return y * yScale
        end
        display.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(xScale * x, yScale * y)
        end
        display.scaleLT = display.scaleX
        display.scaleRT = display.scaleX
        display.scaleTP = display.scaleY
        display.scaleBT = display.scaleY
    end

    -- actual content size
    display.contentSize = function() return cc.size(display:xScale() * display.width(), display:yScale() * display.height()) end
    display.designSize = function() return size end

    gk.log("display.init designSize(%.1f,%.1f), winSize(%.1f,%.1f), xScale(%.4f), yScale(%.4f), minScale(%.4f), maxScale(%.4f)",
        size.width, size.height, display:winSize().width, display:winSize().height,
        display:xScale(), display:yScale(), display:minScale(), display:maxScale())
end

function display:addEditorPanel(scene)
    gk.log("display:addEditorPanel")
    local panel = require("gk.editor.panel")
    scene:addChild(panel.create(scene), 9999999)
end

return display