--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 18/12/2017
-- Time: 18:56
-- To change this template use File | Settings | File Templates.
--

local ErrorReporter = {}

local lastReportTime
function ErrorReporter:reportException(detail)
    if true then
        local now = os.time()
        if lastReportTime == nil or now - lastReportTime > 1 then
            lastReportTime = now
            gk.log("------------------------------[ErrorReporter]------------------------------\n\nErrorReporter:\n%s\n\n------------------------------[ErrorReporter]------------------------------", detail)
            gk.errorOccurs = true
            if DEBUG ~= 0 then
                gk.scheduler:performWithDelayGlobal(function()
                    local Dialog, _ = gk.resource:require("gk.layout.ErrorReportDialog")
                    local dialog = Dialog:create()
                    dialog:setContent(detail)
                    dialog.closeBtn:onClicked(function()
                        gk.util:restartGame()
                    end)
                    dialog:setPosition(cc.p(gk.display.leftWidth + gk.display.extWidth / 2, gk.display.bottomHeight))
                    cc.Director:getInstance():getRunningScene():addChild(dialog, 999999999)
                end, 0.2)
            end
        end
    end
end

return ErrorReporter