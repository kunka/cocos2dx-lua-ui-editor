--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk.Scene = import(".Scene")
gk.Layer = import(".Layer")
gk.Dialog = import(".Dialog")
gk.Button = import(".Button")
gk.EditBox = import(".EditBox")
gk.SelectBox = import(".SelectBox")
gk.ZoomButton = import(".ZoomButton")

----------------------------------------- create sprite  -------------------------------------------------

-- name : sprite name or spriteFrame name
local function create_sprite(name)
    name = name or ""
    if name == "" then
        return cc.Sprite:create(gk.config.defaultSprite)
    end
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(gk.resource.atlasRelativePath .. name)
    if spriteFrame then
        return cc.Sprite:createWithSpriteFrame(spriteFrame)
    end
    -- absolute path
    spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrameByName(name)
    if spriteFrame then
        return cc.Sprite:createWithSpriteFrame(spriteFrame)
    end
    local texture = cc.Director:getInstance():getTextureCache():addImage(gk.resource.textureRelativePath .. name)
    if texture then
        return cc.Sprite:createWithTexture(texture)
    end
    -- absolute path
    texture = cc.Director:getInstance():getTextureCache():addImage(name)
    if texture then
        return cc.Sprite:createWithTexture(texture)
    end
    gk.log("gk.create_sprite(%s) file not found, use default sprite!", name)
    texture = cc.Director:getInstance():getTextureCache():addImage(gk.resource.textureRelativePath .. gk.config.defaultSprite)
    if texture then
        return cc.Sprite:createWithTexture(texture)
    end
    -- absolute path
    return cc.Sprite:create(gk.config.defaultSprite)
    -- even god cannot save u here!
end

-- name : sprite name or spriteFrame name
local function create_sprite_frame(name)
    return gk.create_sprite(name):getSpriteFrame()
end

-- name : sprite name or spriteFrame name
local function create_scale9_sprite(name, capInsets)
    local sprite = ccui.Scale9Sprite:createWithSpriteFrame(create_sprite_frame(name))
    if capInsets then
        sprite:setCapInsets(capInsets)
    end
    return sprite
end

gk.create_sprite = create_sprite
gk.create_sprite_frame = create_sprite_frame
gk.create_scale9_sprite = create_scale9_sprite

----------------------------------------- create label  -------------------------------------------------
local function isTTF(fontFile)
    return string.lower(tostring(fontFile)):ends(".ttf")
end

local function isBMFont(fontFile)
    return string.lower(tostring(fontFile)):ends(".fnt")
end

local function isSystemFont(fontFile)
    return not isTTF(fontFile) and not isBMFont(fontFile)
end

gk.isTTF = isTTF
gk.isBMFont = isBMFont
gk.isSystemFont = isSystemFont

local function create_label(info)
    local lan = gk.resource:getLan()
    local fontFile = info.fontFile[lan]
    local label
    if isTTF(fontFile) then
        label = cc.Label:createWithTTF(info.string, fontFile, info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    elseif isBMFont(fontFile) then
        label = cc.Label:createWithBMFont(fontFile, info.string, cc.TEXT_ALIGNMENT_LEFT)
        label:setBMFontSize(info.fontSize)
    else
        -- TODO: createWithCharMap
        label = cc.Label:createWithSystemFont(info.string, fontFile, info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    end
    return label
end

gk.create_label = create_label

