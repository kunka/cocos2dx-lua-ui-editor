--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/12/17
-- Time: 13:53
-- To change this template use File | Settings | File Templates.
--

local profile = {}

function profile:start(key, ...)
    if self.onStart then
        self.onStart(key, ...)
    end
end

function profile:stop(key, ...)
    if self.onStop then
        self.onStop(key, ...)
    end
end

return profile
