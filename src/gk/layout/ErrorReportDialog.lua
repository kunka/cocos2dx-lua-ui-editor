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
    self:addMaskLayer()
    self:animateOut()
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