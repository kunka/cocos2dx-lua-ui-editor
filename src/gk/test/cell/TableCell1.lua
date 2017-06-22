--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/7
-- Time: 上午9:29
-- To change this template use File | Settings | File Templates.
--

local TableCell1 = class("TableCell1", gk.TableViewCell)

-- must have a __cname and ctor to be injected
function TableCell1:ctor()
    TableCell1.super.ctor(self)
end

return TableCell1