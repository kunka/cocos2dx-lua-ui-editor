--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/21/17
-- Time: 13:52
-- To change this template use File | Settings | File Templates.
--

local Dialog1 = class("Dialog1", gk.Dialog)

function Dialog1:ctor()
    Dialog1.super.ctor(self)
end

function Dialog1:onCancelClicked()
    self:pop()
end

function Dialog1:onConfirmClicked()
    self:showDialog("gk.test.dialog.Dialog1")
end

return Dialog1