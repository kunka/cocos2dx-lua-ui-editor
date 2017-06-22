--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 4/27/17
-- Time: 14:14
-- To change this template use File | Settings | File Templates.
--

local ScreenAdaptTest = class("ScreenAdaptTest", gk.Layer)

function ScreenAdaptTest:ctor()
    ScreenAdaptTest.super.ctor(self)
    gk.log("\nScreenAdaptTest:")
    local designSize = gk.display:designSize()
    local winSize = gk.display:winSize()
    gk.log("designSize: %f,%f", designSize.width, designSize.height)
    gk.log("winSize: %f,%f", winSize.width, winSize.height)
    gk.log("xScale: %f", gk.display:xScale())
    gk.log("yScale: %f", gk.display:yScale())
    gk.log("minScale: %f", gk.display:minScale())
    gk.log("maxScale: %f", gk.display:maxScale())
    local ret = gk.display:scaleXY(designSize.width, designSize.height)
    gk.log("scaleXY(%f,%f) = %f,%f", designSize.width, designSize.height, ret.x, ret.y)
    local ret = gk.display:scaleXYRvs(winSize.width, winSize.height)
    gk.log("scaleXRvs(%f,%f) = %f,%f", winSize.width, winSize.height, ret.x, ret.y)
    gk.log("scaleX(%f) = %f", designSize.width, gk.display:scaleX(designSize.width))
    gk.log("scaleY(%f) = %f", designSize.height, gk.display:scaleY(designSize.height))
    gk.log("ScreenAdaptTest:\n")
end

return ScreenAdaptTest