--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local display = {}

display.deviceSizes = {
    { size = cc.size(720, 1280), desc = "720x1280(9:16)" },
    { size = cc.size(1280, 720), desc = "1280x720(16:9)" },
    { size = cc.size(1280, 960), desc = "1280x960(4:3 iPad)" },
    { size = cc.size(2436, 1125), desc = "2436x1125(iPhoneX)" },
}

-- register custom device size
function display:registerCustomDeviceSize(size, desc)
    table.insert(self.deviceSizes, { size = cc.size(size.width, size.height), desc = desc })
end

function display:iPhoneX()
    local winSize = self:accuWinSize() --cc.Director:getInstance():getWinSize()
    return math.floor(100 * winSize.width / winSize.height) == 216
end

-- new resolution policy "UNIVERSAL"
cc.ResolutionPolicy.UNIVERSAL = 5
display.supportResolutionPolicyDesc = { "UNIVERSAL", "FIXED_HEIGHT", "FIXED_WIDTH" }
display.supportResolutionPolicy = { cc.ResolutionPolicy.UNIVERSAL, cc.ResolutionPolicy.FIXED_HEIGHT, cc.ResolutionPolicy.FIXED_WIDTH }
function display:initWithDesignSize(size, resolutionPolicy)
    table.sort(gk.display.deviceSizes, function(s1, s2)
        return s1.size.width / s1.size.height < s2.size.width / s2.size.height
    end)

    self.resolutionPolicy = resolutionPolicy or self.supportResolutionPolicy[cc.UserDefault:getInstance():getIntegerForKey("gk_resolutionPolicy", 1)]
    self.resolutionPolicyDesc = self.supportResolutionPolicyDesc[table.indexof(self.supportResolutionPolicy, self.resolutionPolicy)]
    local leftMargin = 250
    local topMargin = 100
    local rightMargin = 280
    local bottomMargin = 100
    if gk.mode ~= gk.MODE_RELEASE then
        self.leftWidth = leftMargin
        self.topHeight = topMargin
        self.rightWidth = rightMargin
        self.bottomHeight = bottomMargin
    else
        self.topHeight = 0
        self.leftWidth = 0
        self.rightWidth = 0
        self.bottomHeight = 0
    end
    self.extWidth = 0
    self.iPhoneXExtWidth = 0

    -- set editor win size
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 then
        -- fix deviceSizes, avoid out of screen
        local maxGLViewSize = cc.size(1400, 840)
        local minDesignWinWidth = 570
        for _, s in ipairs(self.deviceSizes) do
            local rateX = (maxGLViewSize.width - leftMargin - rightMargin) / s.size.width
            local rateY = (maxGLViewSize.height - topMargin - bottomMargin) / s.size.height
            local rate = math.min(rateX, rateY)
            s.size.width = s.size.width * rate
            s.size.height = s.size.height * rate
        end
        local s = self.deviceSizes[cc.UserDefault:getInstance():getIntegerForKey("gk_deviceSizeIndex", 1)].size
        if s.width < minDesignWinWidth and gk.mode ~= gk.MODE_RELEASE then
            self.extWidth = minDesignWinWidth - s.width
        end

        local winSize = {}
        winSize.width = s.width + self.leftWidth + self.rightWidth + self.extWidth
        winSize.height = s.height + self.topHeight + self.bottomHeight
        local director = cc.Director:getInstance()
        local view = director:getOpenGLView()
        view:setFrameSize(winSize.width, winSize.height)
        view:setDesignResolutionSize(winSize.width, winSize.height, 0)
        gk.log("set OpenGLView size(%.1f,%.1f)", winSize.width, winSize.height)
        view:setViewName("!!!") -- not implemented :(
    end

    local winSize = cc.Director:getInstance():getWinSize()
    gk.log("display init with winSize(%.1f,%.1f), resolutionPolicy = %s", winSize.width, winSize.height, self.resolutionPolicyDesc)
    self.accuWinSize = function()
        return cc.size(winSize.width - self.leftWidth - self.rightWidth - self.extWidth, winSize.height - self.topHeight - self.bottomHeight)
    end
    self.width = function() return size.width end
    self.height = function() return size.height end
    local xScale, yScale = self:accuWinSize().width / self.width(), self:accuWinSize().height / self.height()
    if self:iPhoneX() then
        self.iPhoneXExtWidth = self:accuWinSize().width * (132 * 2) / 2436
        xScale = self:accuWinSize().width * (2436 - 132 * 2) / 2436 / self.width()
    end
    self.winSize = function()
        return cc.size(winSize.width - self.leftWidth - self.rightWidth - self.extWidth - self.iPhoneXExtWidth, winSize.height - self.topHeight - self.bottomHeight)
    end
    self.scaleiPX = function()
        return self:accuWinSize().width / self.width()
    end
    local minScale, maxScale = math.min(xScale, yScale), math.max(xScale, yScale)
    if self.resolutionPolicy == cc.ResolutionPolicy.FIXED_WIDTH then
        self.xScale = function() return xScale end
        self.yScale = function() return xScale end
        self.minScale = function() return xScale end
        self.maxScale = function() return xScale end
        self.scaleX = function(_, x)
            return x * xScale
        end
        self.scaleY = function(_, y)
            return xScale * y + (self:winSize().height - self.height() * xScale) / 2
        end
        self.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(xScale * x, xScale * y + (self:winSize().height - self.height() * xScale) / 2)
        end
        self.scaleXRvs = function(_, x)
            return x / xScale
        end
        self.scaleYRvs = function(_, y)
            return (y - (self:winSize().height - self.height() * xScale) / 2) / xScale
        end
        self.scaleXYRvs = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(x / xScale, (y - (self:winSize().height - self.height() * xScale) / 2) / xScale)
        end
        self.scaleTP = function(_, y)
            return xScale * y + (self:winSize().height - self.height() * xScale)
        end
        self.scaleBT = function(_, y)
            return xScale * y
        end
        self.scaleLT = self.scaleX
        self.scaleRT = self.scaleX
    elseif self.resolutionPolicy == cc.ResolutionPolicy.FIXED_HEIGHT then
        self.xScale = function() return yScale end
        self.yScale = function() return yScale end
        self.minScale = function() return yScale end
        self.maxScale = function() return yScale end
        self.scaleX = function(_, x)
            return x * yScale + (self:winSize().width - self.width() * yScale) / 2
        end
        self.scaleY = function(_, y)
            return yScale * y
        end
        self.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(x * yScale + (self:winSize().width - self.width() * yScale) / 2, yScale * y)
        end
        self.scaleXRvs = function(_, x)
            return (x - (self:winSize().width - self.width() * yScale) / 2) / yScale
        end
        self.scaleYRvs = function(_, y)
            return y / yScale
        end
        self.scaleXYRvs = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p((x - (self:winSize().width - self.width() * yScale) / 2) / yScale, y / yScale)
        end
        self.scaleLT = function(_, x)
            return x * yScale
        end
        self.scaleRT = function(_, x)
            return x * yScale + (self:winSize().width - self.width() * yScale)
        end
        self.scaleTP = self.scaleY
        self.scaleBT = self.scaleY
    elseif self.resolutionPolicy == cc.ResolutionPolicy.UNIVERSAL then
        self.xScale = function() return xScale end
        self.yScale = function() return yScale end
        self.minScale = function() return minScale end
        self.maxScale = function() return maxScale end
        self.scaleX = function(_, x)
            return x * xScale
        end
        self.scaleY = function(_, y)
            return y * yScale
        end
        self.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(xScale * x, yScale * y)
        end
        self.scaleXRvs = function(_, x)
            return x / xScale
        end
        self.scaleYRvs = function(_, y)
            return y / yScale
        end
        self.scaleXYRvs = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(x / xScale, y / yScale)
        end
        self.scaleLT = self.scaleX
        self.scaleRT = self.scaleX
        self.scaleTP = self.scaleY
        self.scaleBT = self.scaleY
    else
        -- not supported
        gk.log("display init with not supported resolutionPolicy")
        self.xScale = function() return minScale end
        self.yScale = function() return minScale end
        self.minScale = function() return minScale end
        self.maxScale = function() return minScale end
        self.scaleX = function(_, x)
            return x * xScale
        end
        self.scaleY = function(_, y)
            return y * yScale
        end
        self.scaleXY = function(_, pos, posY)
            local y = posY and posY or pos.y
            local x = posY and pos or pos.x
            return cc.p(xScale * x, yScale * y)
        end
        self.scaleLT = self.scaleX
        self.scaleRT = self.scaleX
        self.scaleTP = self.scaleY
        self.scaleBT = self.scaleY
    end

    self.designSize = function() return size end

    gk.log("display.init designSize(%.1f,%.1f), winSize(%.1f,%.1f), accuWinSize(%.1f,%.1f), xScale(%.4f), yScale(%.4f), minScale(%.4f), maxScale(%.4f)",
        size.width, size.height, self:winSize().width, self:winSize().height, self:accuWinSize().width, self:accuWinSize().height,
        self:xScale(), self:yScale(), self:minScale(), self:maxScale())
    gk.log("display.scaleiPX = %.2f", self.scaleiPX())
end

return display