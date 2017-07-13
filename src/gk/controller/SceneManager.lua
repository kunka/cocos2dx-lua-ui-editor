--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local SceneManager = {}
SceneManager.sceneStack = gk.List.new()

-- Use as scene
function SceneManager:createScene(layerName, ...)
    -- init scene at first, need create edit panel on edit mode
    local scene = gk.Scene:create(layerName)
    local clazz = gk.resource:require(layerName)
    if clazz then
        local layer
        local status, _ = xpcall(function(...)
            gk.profile:start("SceneManager:createScene")
            layer = clazz:create(...)
            gk.profile:stop("SceneManager:createScene", layerName)
        end, function(msg)
            local msg = debug.traceback(msg, 3)
            gk.util:reportError(msg)
        end)
        if status then
            scene:addChild(layer)
            scene.layer = layer
            return scene, true
        else
            gk.log("SceneManager:createScene error, create layer --> %s failed", layerName)
            return scene, false
        end
    else
        gk.log("SceneManager:createScene error, create layer class --> %s failed", layerName)
        return scene, false
    end
end

-- layerName:must inherit from Layer
function SceneManager:push(layerName, ...)
    gk.log("SceneManager:push --> %s", layerName)
    local scene, ret = self:createScene(layerName, ...)
    return self:pushScene(scene), ret
end

function SceneManager:pushScene(scene)
    local director = cc.Director:getInstance()
    director:pushScene(scene)
    self.sceneStack:pushRight(scene)
    self:printSceneStack()
    return scene
end

function SceneManager:replace(layerName, ...)
    gk.log("SceneManager:replace --> %s", layerName)
    local scene, ret = self:createScene(layerName, ...)
    return self:replaceScene(scene), ret
end

function SceneManager:replaceScene(scene)
    local director = cc.Director:getInstance()
    director:replaceScene(scene)
    if self.sceneStack:size() >= 1 then
        self.sceneStack:popRight()
    end
    self.sceneStack:pushRight(scene)
    self:printSceneStack()
    return scene
end

function SceneManager:pop()
    gk.log("SceneManager:pop")
    local director = cc.Director:getInstance()
    if #self.sceneStack == 1 then
        if self.endCallback then
            self.endCallback()
            return
        end
    end
    director:popScene()
    self.sceneStack:popRight()
    self:printSceneStack()
end

function SceneManager:getRunningScene()
    return self.sceneStack:size() >= 1 and self.sceneStack:right() or nil
end

function SceneManager:popToRootScene()
    gk.log("SceneManager:popToRootScene")
    cc.Director:getInstance():popToRootScene()
    while self.sceneStack:size() > 1 do
        self.sceneStack:popRight()
    end
end

function SceneManager:showDialog(dialogType, ...)
    local scene = SceneManager:getRunningScene()
    if scene and scene.layer and scene.layer.showDialogNode then
        return scene.layer:showDialog(dialogType)
    else
        gk.log("SceneManager:showDialogNode error, cannot find root layer")
        return nil
    end
end

function SceneManager:showDialogNode(dialogNode)
    local scene = SceneManager:getRunningScene()
    if scene and scene.layer and scene.layer.showDialogNode then
        return scene.layer:showDialogNode(dialogNode)
    else
        gk.log("SceneManager:showDialogNode error, cannot find root layer")
        return nil
    end
end

local function printDialogStack(layer, indent)
    if layer.dialogsStack then
        for i = 1, #layer.dialogsStack do
            local d = layer.dialogsStack[i]
            if d.__dialogType then
                gk.log(indent .. "[" .. d.__dialogType .. "]")
                printDialogStack(d, indent .. indent)
            end
        end
    end
end

function SceneManager:printSceneStack()
    gk.log("\n*********************** SceneStack ***********************")
    for i = self.sceneStack.first, self.sceneStack.last do
        local s = self.sceneStack[i]
        gk.log(s.__sceneType or "unknown SceneType")
        if s.layer then
            printDialogStack(s.layer, "  ")
        end
    end
    gk.log("*********************** SceneStack ***********************\n")
end

return SceneManager