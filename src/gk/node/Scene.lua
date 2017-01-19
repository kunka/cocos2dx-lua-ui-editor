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

function Scene:ctor(layerName)
    gk.log("Scene(%s:ctor)", layerName)
    self.sceneType = layerName
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