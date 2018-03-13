--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/24/17
-- Time: 15:54
-- To change this template use File | Settings | File Templates.
--

local DialogTest = class("DialogTest", gk.Layer)

function DialogTest:ctor()
    DialogTest.super.ctor(self)

    local dialog = self:showDialog("gk.test.dialog.Dialog1")
    dialog.popupBg1.label1:setString("Dialog can be added into Layer or Dialog.\nClick confirm to add Dialog in Dialog.\nClick cancel to pop.")
    dialog.onPopCallback = function()
        gk.log("on pop")
    end
end

return DialogTest