--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/5/17
-- Time: 10:28
-- To change this template use File | Settings | File Templates.
--

local Widget = class("Widget", function()
    return cc.Node:create()
end)
Widget._isWidget = true

-- must have a __cname and ctor to be injected
function Widget:ctor()
    self:enableNodeEvents()
end

function Widget:registerCustomProp(...)
    gk.injector:registerCustomProp(self, ...)
end

return Widget