--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/7
-- Time: 下午12:35
-- To change this template use File | Settings | File Templates.
--

local TableViewCell = class("TableViewCell", function()
    return cc.TableViewCell:create()
end)

-- must have a __cname and ctor to be injected
function TableViewCell:ctor()
end

return TableViewCell