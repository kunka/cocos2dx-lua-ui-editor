--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local function log(format, ...)
    local string = string.format(format, ...)
    print(string)
    return string
end

gk.log = log
