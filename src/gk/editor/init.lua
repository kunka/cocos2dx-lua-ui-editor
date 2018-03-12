--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/19/17
-- Time: 14:37
-- To change this template use File | Settings | File Templates.
--

gk.theme = import(".theme")
gk.editorConfig = import(".editorConfig")
gk.editorPanel = import(".editorPanel")
----------------------------- 3d -----------------------------------
import(".config3d"):register(gk.editorConfig)

-- attach editor panel to editing scene
gk.editorPanel.attachToScene = function(_, scene)
    gk.log("attach editorPanel to Scene")
    scene:addChild(gk.editorPanel.create(scene), 9999999, -99999)
    local c4b = gk.theme.config.backgroundColor
    gk.util:drawNodeBg(scene, gk.util:c4b2c4f(c4b), -89)
end

gk.editorPanel.getPanel = function(_, scene)
    return scene:getChildByTag(-99999)
end
