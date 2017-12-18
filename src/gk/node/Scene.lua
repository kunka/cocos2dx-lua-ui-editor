--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/4/8
-- Time: 上午11:22
-- To change this template use File | Settings | File Templates.
--

-- for wrap node
local Scene = class("Scene", function()
    return cc.Scene:create()
end)

function Scene:ctor(sceneType)
    self.__sceneType = sceneType
    if gk.displayRuntimeVersion then
        local version = ""
        local curVersion = cc.UserDefault:getInstance():getStringForKey("gk_currentVersion", "")
        if curVersion ~= "" then
            version = version .. curVersion
        end
        local sid = SERVER_ID or ""
        if sid ~= "" then
            version = version .. "/s" .. sid
        end
        local rv = gk:getRuntimeVersion()
        if rv and rv ~= "" then
            if version ~= "" then
                version = version .. "/" .. rv
            else
                version = rv
            end
        end
        local label = gk.create_label(version, "Arial", 15)
        gk.set_label_color(label, cc.c3b(230, 230, 230))
        local node = cc.Node:create()
        node:setContentSize(cc.size(120, 30))
        label:setAnchorPoint(cc.p(1, 0))
        label:setPosition(cc.p(120 - 3, 2))
        node:addChild(label)
        local button = gk.ZoomButton.new(node)
        label:setTag(gk.util.tags.versionTag)
        self:addChild(button, 9999999)
        button:setAnchorPoint(cc.p(1, 0))
        button:setScale(gk.display:minScale())
        button:setPosition((gk.display.leftWidth or 0) + (gk.display.extWidth / 2 or 0) + (gk.display.iPhoneXExtWidth / 2 or 0) + gk.display:scaleX(gk.display:designSize().width - 1), gk.display.bottomHeight or 0)
        button:onClicked(function()
            gk.config:openConfigDialog()
        end)
    end

    if gk.display:iPhoneX() and gk.mode == gk.MODE_RELEASE and cc.Application:getInstance():getTargetPlatform() == 2 then
        local overlay = gk.create_sprite("gk/res/texture/ipx.png")
        self:addChild(overlay, 9999999)
        overlay:setColor(cc.c3b(26, 26, 26))
        overlay:setScale(self:getContentSize().width / overlay:getContentSize().width)
        overlay:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
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