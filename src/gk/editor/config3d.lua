--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 24/11/2017
-- Time: 22:11
-- To change this template use File | Settings | File Templates.
--

local config3D = {}

function config3D:register(config)
    config:registerPlaneProp("_is3d", false)
    config:registerEditableProp("z", function(_) return 0 end,
        function(node, var) node:setPositionZ(var) end)
    config:registerFloatProp("scaleZ")
    config:registerProp("rotation3D")
    --    config:registerProp("rotationQuat") -- no getter??? are u kidding me!
    --    config:registerEditableProp("rotateX", function(_) return 0 end,
    --        function(node, var) node:setRotation(cc.vec3(var, node.__info.rotateY, node.__info.rotateZ)) end)
    --    config:registerEditableProp("rotateY", function(_) return 0 end,
    --        function(node, var) node:setRotation(cc.vec3(node.__info.rotateX, var, node.__info.rotateZ)) end)
    --    config:registerEditableProp("rotateZ", function(node) return 0 end,
    --        function(node, var) node:setRotation(cc.vec3(node.__info.rotateX, node.__info.rotateY, var)) end)

    ----------------------------- cc.Sprite3D -----------------------------------
    config:registerSupportNode({ _type = "cc.Sprite3D", modelPath = "gk/res/3d/orc.c3b", _is3d = true })
    config:registerPlaneProp("modelPath")
    config:registerDisplayProps({
        _type = "cc.Sprite3D",
        stringProps = {
            { key = "modelPath" },
        },
        --            boolProps = {},
    })
    config:registerNodeCreator("cc.Sprite3D", function(info, rootTable)
        local node = cc.Sprite3D:create(info.modelPath)
        info._id = info._id or config:genID("sprite3D", rootTable)
        return node
    end)
end

return config3D