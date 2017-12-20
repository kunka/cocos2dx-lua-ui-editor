--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 20/12/2017
-- Time: 14:51
-- To change this template use File | Settings | File Templates.
--

local FSMTest = class("FSMTest", gk.Layer)

function FSMTest:ctor()
    FSMTest.super.ctor(self)

    local fsm = gk.injector:inflateFSM("gk.test.fsm.GameFSM")
    fsm.onStart = function()
        gk.log("onStart")
    end
    fsm.onPause = function()
        gk.log("onPause")
    end
    fsm.onResume = function()
        gk.log("onResume")
    end
    fsm.onWin = function()
        gk.log("onWin")
    end
    fsm.onLose = function()
        gk.log("onLose")
    end
    fsm.onReset = function()
        gk.log("onReset")
    end

    gk.log(fsm:getState())
    gk.log(fsm:is("INIT"))
    gk.log(fsm:win())
    gk.log(fsm:start())
    gk.log(fsm:pause())
    gk.log(fsm:resume())
    gk.log(fsm:win())
    gk.log(fsm:reset())
    gk.log(fsm:start())
    gk.log(fsm:lose())
end

return FSMTest