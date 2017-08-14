--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local display = {}

display.deviceSizes = {
    { size = cc.size(1280, 720), desc = "1280x720(16:9)" },
    { size = cc.size(1280, 960), desc = "1280x960(4:3)" },
    { size = cc.size(720, 1280), desc = "720x1280(9:16)" },
}

-- register custom device size
function display:registerCustomDeviceSize(size, desc)
    table.insert(display.deviceSizes, { size = cc.size(size.width, size.height), desc = desc })
end

-- new resolution policy
cc.ResolutionPolicy.UNIVERSAL = 5
display.supportResolutionPolicyDesc = { "UNIVERSAL", "FIXED_HEIGHT", "FIXED_WIDTH" }
display.supportResolutionPolicy = { cc.ResolutionPolicy.UNIVERSAL, cc.ResolutionPolicy.FIXED_HEIGHT, cc.ResolutionPolicy.FIXED_WIDTH }
function display:initWithDesignSize(size, resolutionPolicy)
    table.sort(gk.display.deviceSizes, function(s1, s2)
        return s1.size.width / s1.size.height < s2.size.width / s2.size.height
    end)

    display.resolutionPolicy = resolutionPolicy or display.supportResolutionPolicy[cc.UserDefault:getInstance():getIntegerForKey("gk_resolutionPolicy", 1)]
    display.resolutionPolicyDesc = display.supportResolutionPolicyDesc[table.indexof(display.supportResolutionPolicy, display.resolutionPolicy)]
    local leftMargin = 250
    local topMargin = 100
    local rightMargin = 280
    local bottomMargin = 100
    if gk.mode == gk.MODE_EDIT then
        display.leftWidth = leftMargin
        display.topHeight = topMargin
        display.rightWidth = rightMargin
        display.bottomHeight = bottomMargin
    else
        display.topHeight = 0
        display.leftWidth = 0
        display.rightWidth = 0
        display.bottomHeight = 0
    end
    display.extWidth = 0

    -- set editor win size
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 then
        -- fix deviceSizes, avoid out of screen
        local maxGLViewSize = cc.size(1400, 840)
        local minDesignWinWidth = 500
        for _, s in ipairs(display.deviceSizes) do
            local rateX = (maxGLViewSize.width - leftMargin - rightMargin) / s.size.width
            local rateY = (maxGLViewSize.height - topMargin - bottomMargin) / s.size.height
            local rate = math.min(rateX, rateY)
            s.size.width = s.size.width * rate
            s.size.height = s.size.height * rate
        end
        local s = display.deviceSizes[cc.UserDefault:getInstance():getIntegerForKey("gk_deviceSizeIndex", 1)].size
        if s.width < minDesignWinWidth and gk.mode == gk.MODE_EDIT then
            display.extWidth = minDesignWinWidth - s.width
        end

        local winSize = {}
        winSize.width = s.width + display.leftWidth + display.rightWidth + display.extWidth
        winSize.height = s.height + display.topHeight + display.bottomHeight
        local director = cc.Director:getInstance()
        local view = director:getOpenGLView()
        view:setFrameSize(winSize.width, winSize.height)
        view:setDesignResolutionSize(winSize.width, winSize.height, 0)
        gk.log("set OpenGLView size(%.1f,%.1f)", winSize.width, winSize.height)
        view:setViewName("!!!") -- not implemented :(
    end

    local winSize = cc.Director:getInstance():getWinSize()
    gk.log("display init with winSize(%.1f,%.1f), resolutionPolicy = %s", winSize.width, winSize.height, display.resolutionPolicyDesc)
    display.winSize = function() return cc.size(winSize.width - display.leftWidth - display.rightWidth - display.extWidth, winSize.height - display.topHeight
            - display.bottomHeight)
    end
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
    local c4b = gk.theme.config.backgroundColor
    gk.util:drawNodeBg(scene, gk.util:c4b2c4f(c4b), -89)
end

return display