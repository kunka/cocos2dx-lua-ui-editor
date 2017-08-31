--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 11/08/2017
-- Time: 15:42
-- To change this template use File | Settings | File Templates.
--

local CubicBezierNode = class("CubicBezierNode", function()
    return cc.Node:create()
end)

function CubicBezierNode:ctor()
    self.child = cc.DrawNode:create()
    self:addChild(self.child)
    self.origin = cc.p(0, 0)
    self.destination = { { c1 = cc.p(0, 0), c2 = cc.p(0, 0), dst = cc.p(100, 0) } }
    self.segments = 10
    self.lineWidth = 1
    self.curvesNum = 1
    self.c4f = cc.c4f(0, 1, 0, 1)

    local genGetterAndSetter = function(node, propName)
        local getter = "get" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
        local setter = "set" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
        node[getter] = function(_)
            return node[propName]
        end
        node[setter] = function(_, var)
            if node[propName] ~= var then
                node[propName] = var
                self:draw()
            end
        end
    end
    genGetterAndSetter(self, "origin")
    genGetterAndSetter(self, "control1")
    genGetterAndSetter(self, "control2")
    genGetterAndSetter(self, "control3")
    genGetterAndSetter(self, "destination")
    genGetterAndSetter(self, "segments")
    genGetterAndSetter(self, "c4f")
end

function CubicBezierNode:getLineWidth()
    return self.lineWidth
end

function CubicBezierNode:setLineWidth(lineWidth)
    self.lineWidth = lineWidth
end

function CubicBezierNode:getCurvesNum()
    return self.curvesNum
end

function CubicBezierNode:setCurvesNum(curvesNum)
    self.curvesNum = curvesNum
    while #self.destination < self.curvesNum do
        table.insert(self.destination, { c1 = cc.p(0, 0), c2 = cc.p(0, 0), dst = cc.p(100, 0) })
    end
end

function CubicBezierNode:draw()
    self.child:clear()
    self.child:setLineWidth(self.lineWidth)
    if gk.mode == gk.MODE_EDIT then
        self.child:drawPoint(self.origin, 5, cc.c4f(1, 0, 0, 1))
        for _, dst in ipairs(self.destination) do
            self.child:drawPoint(dst.c1, 5, cc.c4f(1, 1, 0, 1))
            self.child:drawPoint(dst.c2, 5, cc.c4f(1, 1, 0, 1))
            self.child:drawPoint(dst.dst, 5, cc.c4f(1, 0, 0, 1))
        end
        --        self.child:drawPoint(self.control1, 5, cc.c4f(1, 1, 0, 1))
        --        self.child:drawPoint(self.control2, 5, cc.c4f(1, 1, 0, 1))
        --        self.child:drawPoint(self.destination, 5, cc.c4f(1, 0, 0, 1))
    end
    --    self.child:drawCubicBezier(self.origin, self.control1, self.control2, self.destination, self.segments, self.c4f)
    --    self.child:drawCubicBezier(self.destination, self.control3, self.control4, self.origin, self.segments, self.c4f)
    local origin = self.origin
    for i, dst in ipairs(self.destination) do
        if i > self.curvesNum then
            return
        end
        self.child:drawCubicBezier(origin, dst.c1, dst.c2, dst.dst, self.segments, self.c4f)
        origin = dst.dst
    end
end

return CubicBezierNode