--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk.display = import(".display")
import(".util")
gk.Scene = import(".Scene")
gk.Layer = import(".Layer")
gk.Button = import(".Button")
gk.ZoomButton = import(".ZoomButton")

----------------------------------------- create sprite  -------------------------------------------------

-- name : sprite name or spriteFrame name
local function CREATE_SPRITE(name)
    name = name and name or ""
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name)
    if spriteFrame then
        return cc.Sprite:createWithSpriteFrame(spriteFrame)
    else
        local texture = cc.Director:getInstance():getTextureCache():addImage(name)
        if texture then
            return cc.Sprite:createWithTexture(texture)
        end
    end
    gk.log("CREATE_SPRITE(%s) file not found, use default sprite!", name)
    return cc.Sprite:create(gk.config.defaultSprite)
end

-- name : sprite name or spriteFrame name
local function CREATE_SPRITE_FRAME(name)
    return CREATE_SPRITE(name):getSpriteFrame()
end

-- name : sprite name or spriteFrame name
local function CREATE_SCALE9_SPRITE(name, capInsets)
    local sprite = ccui.Scale9Sprite:createWithSpriteFrame(CREATE_SPRITE_FRAME(name))
    if capInsets then
        sprite:setCapInsets(capInsets)
    end
    return sprite
end

gk.exports.CREATE_SPRITE = CREATE_SPRITE
gk.exports.CREATE_SPRITE_FRAME = CREATE_SPRITE_FRAME
gk.exports.CREATE_SCALE9_SPRITE = CREATE_SCALE9_SPRITE

----------------------------------------- create button  -------------------------------------------------

-- node : contentNode
local function CREATE_ZOOM_BUTTON(node)
    local ZoomButton = require("gk.node.ZoomButton")
    return ZoomButton.new(node)
end

----------------------------------------- create label  -------------------------------------------------
local function CREATE_LABEL(id)
    local id2label = require("gk.core.id2label")
    return id2label:createLabel(id)
end
