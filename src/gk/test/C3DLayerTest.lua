--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 23/11/2017
-- Time: 19:10
-- To change this template use File | Settings | File Templates.
--

local C3DLayerTest = class("C3DLayerTest", gk.Layer)

function C3DLayerTest:ctor()
    C3DLayerTest.super.ctor(self)
    --    cc.Director:getInstance():setDepthTest(true)
end

function C3DLayerTest:createSkyBox()
    --create and set our custom shader
    local shader = cc.GLProgram:createWithFilenames("3d/cube_map.vert", "3d/cube_map.frag")
    local state = cc.GLProgramState:create(shader)
    --create the second texture for cylinder
    local textureCube = cc.TextureCube:create("3d/skybox/left.jpg", "3d/skybox/right.jpg",
        "3d/skybox/top.jpg", "3d/skybox/bottom.jpg",
        "3d/skybox/front.jpg", "3d/skybox/back.jpg")
    --set texture parameters
    local tRepeatParams = { magFilter = gl.LINEAR, minFilter = gl.LINEAR, wrapS = gl.MIRRORED_REPEAT, wrapT = gl.MIRRORED_REPEAT }
    textureCube:setTexParameters(tRepeatParams)
    --pass the texture sampler to our custom shader
    state:setUniformTexture("u_cubeTex", textureCube)

    --add skybox
    local skyBox = cc.Skybox:create()
    skyBox:setCameraMask(cc.CameraFlag.USER1)
    skyBox:setTexture(textureCube)
    self:addChild(skyBox)

    local winSize = gk.display:winSize()
    local zeye = cc.Director:getInstance():getZEye()
    local camera = cc.Camera:createPerspective(60, winSize.width / winSize.height, 10, zeye + winSize.height / 2)
    local eye = cc.vec3(0, 0, 50)
    --    local center = cc.vec3(winSize.width / 2, winSize.height / 2, 0.0)
    --    local up = cc.vec3(0.0, 1.0, 0.0)
    camera:setPosition3D(eye)
    --    camera:lookAt(center, up)
    camera:setCameraFlag(cc.CameraFlag.USER1)
    self:addChild(camera)
end

function C3DLayerTest:onEnter()
    C3DLayerTest.super.onEnter(self)

    self:createSkyBox()
    self.label1:setPositionZ(-244)

    local scene = cc.Director:getInstance():getRunningScene()
    local defaultCamera = scene:getDefaultCamera()

    local winSize = gk.display:winSize()
    local zeye = cc.Director:getInstance():getZEye()
    local camera = cc.Camera:createPerspective(60, winSize.width / winSize.height, 10, zeye + winSize.height / 2)
    local eye = cc.vec3(winSize.width / 2, winSize.height / 2.0, zeye)
    local center = cc.vec3(winSize.width / 2, winSize.height / 2, 0.0)
    local up = cc.vec3(0.0, 1.0, 0.0)
    camera:setPosition3D(eye)
    dump(eye)
    dump(center)
    gk.log("maxZ = %f", eye.z - 10)
    gk.log("minZ = %f", eye.z - (zeye + winSize.height / 2))
    camera:lookAt(center, up)

    camera:setCameraFlag(cc.CameraFlag.USER2)
    --    camera:lookAt(cc.vec3(0.0, 0.0, 0.0), cc.vec3(0.0, 1.0, 0.0))
    self:addChild(camera)
    camera:setDepth(1)

    local size = self:getContentSize()
    local sprite = cc.Sprite3D:create("3d/girl.c3b")
    sprite:setRotation3D({ x = 0, y = 0, z = 0 })
    sprite:setPosition3D(cc.vec3(size.width * 3 / 4, size.height / 2, 10))
    --    self:addChild(sprite)
    self:addChild(sprite)
    sprite:setCameraMask(cc.CameraFlag.USER2)

    local animation = cc.Animation3D:create("3d/girl.c3b", "Take 001")
    if nil ~= animation then
        local animate = cc.Animate3D:create(animation)
        sprite:runAction(cc.RepeatForever:create(animate))
    end

    local sprite = cc.Sprite3D:create("3d/orc.c3b")
    sprite:setScale(3)
    sprite:setRotation3D({ x = 0, y = 180, z = 0 })
    sprite:setPosition3D(cc.vec3(size.width / 2, 50, 10))
    self:addChild(sprite)
    sprite:setCameraMask(cc.CameraFlag.USER2)
    local animation = cc.Animation3D:create("3d/orc.c3b")
    local animate = cc.Animate3D:create(animation)
    local repeatAction = cc.RepeatForever:create(animate)
    sprite:runAction(repeatAction)

    local sprite = cc.Sprite3D:create("3d/boss.c3b")
    sprite:setScale(3)
    sprite:setRotation3D({ x = 0, y = 180, z = 0 })
    sprite:setPosition3D(cc.vec3(size.width / 2, size.height - 50, 10))
    self:addChild(sprite)
    sprite:setCameraMask(cc.CameraFlag.USER2)
end

return C3DLayerTest