--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 18/12/2017
-- Time: 19:00
-- To change this template use File | Settings | File Templates.
--

local ErrorReportDialog = class("ErrorReportDialog", gk.Dialog)

function ErrorReportDialog:ctor()
    ErrorReportDialog.super.ctor(self)
    --    self.dialogBg.bg:setSpriteFrame(gk.create_sprite_frame("fuYong/tancDishen.png"), self.dialogBg.bg:getCapInsets())
    --    self:addMaskLayer()
    --    self:animateOut()
    --    self.dialogBg.titleLabel:setString(gk.resource:getString("g.help"))
    --    self.dialogBg.closeBtn:onClicked(function()
    --        self:pop()
    --    end)
end

function ErrorReportDialog:setTitle(title)
    self.dialogBg.titleLabel:setString(title)
    return self
end

function ErrorReportDialog:setContent(content)
    self.contentLabel:setString(content)
    return self
end

return ErrorReportDialog