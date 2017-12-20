--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 19/12/2017
-- Time: 21:28
-- To change this template use File | Settings | File Templates.
--

local GameFSM = class("GameFSM", gk.FSMEditor)

function GameFSM:ctor(...)
    GameFSM.super.ctor(self, ...)
end

return GameFSM