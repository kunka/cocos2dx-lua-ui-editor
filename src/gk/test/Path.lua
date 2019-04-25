--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 2019/1/23
-- Time: 15:41
-- To change this template use File | Settings | File Templates.
--

--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/3/1
-- Time: 下午9:26
-- To change this template use File | Settings | File Templates.
--

local Path = class("Path", gk.Layer)

function Path:ctor()
    Path.super.ctor(self)


    self:run()
end

function Path:run()
    self.sprite1:setPosition(cc.p(0, 0))
    local x0 = 0
    local y0 = 0
    local x3 = math.random(-720, 720)
    local y3 = math.random(-720, 720)
    local x1, y1, x2, y2
    if (x3 > x0 and y3 >= y0) then
        -- q1
        x1 = x0 + (x3 - x0) / 3
        x2 = x0 + (x3 - x0) / 3 * 2
        y1 = math.max(-(x3 - x0), y3 + 80)
        y2 = (y1 + y3) / 2
    elseif (x3 < x0 and y3 >= y0) then
        -- q2
        x1 = x0 + (x3 - x0) / 3
        x2 = x0 + (x3 - x0) / 3 * 2
        y1 = math.max(-(x3 - x0), y3 + 80)
        y2 = (y1 + y3) / 2
    elseif (x3 < x0 and y3 <= y0) then
        -- q3
        x1 = x0 + (x3 - x0) / 3
        x2 = x0 + (x3 - x0) / 3 * 2
        y1 = y0 + 100
        y2 = (y1 + y3) / 2
    elseif (x3 > x0 and y3 <= y0) then
        -- q4
        x1 = x0 + (x3 - x0) / 3
        x2 = x0 + (x3 - x0) / 3 * 2
        y1 = y0 + 100
        y2 = (y1 + y0) / 2
    elseif (x0 == x3) then
        if (y3 > y0) then
            -- vertical up
            x1 = x0 - 100
            x2 = x0 - 50
            y1 = y3 + 100
            y2 = y3 + 50
        else
            -- vertical down
            x1 = x0 - 100
            x2 = x0 - 50
            y1 = y0 + 100
            y2 = y0 + (y3 - y0) / 2
        end
    end
    self.cubicBezierNode:setMovablePoints(cc.p(x1, y1), 2)
    self.cubicBezierNode:setMovablePoints(cc.p(x2, y2), 3)
    self.cubicBezierNode:setMovablePoints(cc.p(x3, y3), 4)
    gk.util:drawNode(self.cubicBezierNode)
    gk.log("(%d,%d) (%d,%d)(%d,%d) (%d,%d)", x0, y0, x1, y1, x2, y2, x3, y3)
    self.sprite1:runAction(cc.Sequence:create(cc.BezierTo:create(0.8, { cc.p(x1, y1), cc.p(x2, y2), cc.p(x3, y3) }),
        cc.DelayTime:create(0.3), cc.CallFunc:create(function()
            self:run()
        end)))
end

return Path