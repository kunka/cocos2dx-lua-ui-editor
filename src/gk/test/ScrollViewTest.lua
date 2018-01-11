--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/1/25
-- Time: 下午7:25
-- To change this template use File | Settings | File Templates.
--

local ScrollViewTest = class("ScrollViewTest", gk.Layer)

function ScrollViewTest:ctor()
    ScrollViewTest.super.ctor(self)
    gk.util:drawNode(self.scrollView1)
    gk.util:drawNode(self.label1, cc.c4f(0.5, 1, 0.5, 1))
end

function ScrollViewTest:onScrollViewDidScroll()
    local offset = self.scrollView1:getContentOffset()
    gk.log(offset.y)
end

return ScrollViewTest