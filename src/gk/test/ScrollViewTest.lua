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
    if self.scrollView1 then
        --        self.scrollView1:setContentSize(cc.size(200 * gk.display:xScale(), 600 * gk.display:yScale()))
    end
end

function ScrollViewTest:onScrollViewDidScroll()
    local offset = self.scrollView1:getContentOffset()
    gk.log(offset.y)
end

return ScrollViewTest