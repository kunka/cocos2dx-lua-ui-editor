--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local function log(format, ...)
    local vars = { ... }
    local string = string.format(format, ...)
    print(string)
end

gk.log = log
