--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/15
-- Time: 下午10:27
-- To change this template use File | Settings | File Templates.
--

local FinanceHud = class("FinanceHud", gk.Layer)
FinanceHud._isWidget = true

function FinanceHud:ctor()
    FinanceHud.super.ctor(self)
end

return FinanceHud