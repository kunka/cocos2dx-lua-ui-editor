--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/4/8
-- Time: 上午11:22
-- To change this template use File | Settings | File Templates.
--

local Scene = class("Scene", function()
    return cc.Scene:create()
end)

function Scene:ctor(sceneType)
    self.__sceneType = sceneType
    if gk.displayRuntimeVersion then
        local version = gk:getRuntimeVersion()
        local fontName = gk.theme.font_fnt
        local curVersion = cc.UserDefault:getInstance():getStringForKey("gk_curVersion")
        if curVersion ~= "" then
            version = curVersion .. "/" .. version
        end
        local label = gk.create_label(version, fontName, 12)
        gk.set_label_color(label, cc.c3b(230, 230, 230))
        local button = gk.ZoomButton.new(label)
        label:setTag(gk.util.tags.versionTag)
        self:addChild(button, 9999999)
        button:setAnchorPoint(cc.p(1, 0))
        button:setScale(gk.display:minScale())
        button:setPosition((gk.display.leftWidth or 0) + (gk.display.extWidth / 2 or 0) + gk.display:scaleX(gk.display:designSize().width - 1), gk.display.bottomHeight or 0)
        button:onClicked(function()
            gk.config:openConfigDialog()
        end)
    end
end

function Scene:showDialog(dialogName, ...)
    if self.layer then
        self.layer:showDialog(dialogName, ...)
    else
        gk.log("%s:showDialog error, cannot find layer --> %s", self.layerName, dialogName)
    end
end

function Scene:showDialogNode(dialogNode)
    if self.layer then
        self.layer:showDialogNode(dialogNode)
    else
        gk.log("%s:showDialogNode error, cannot find layer", self.layerName)
    end
end

return Scene