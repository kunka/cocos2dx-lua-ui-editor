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
gk.TableViewCell = import(".TableViewCell")

gk.injector:ctor_method_swizz(gk.Layer, "ctor")
gk.injector:ctor_method_swizz(gk.Dialog, "ctor")

----------------------------------------- create sprite  -------------------------------------------------

-- name : sprite name or spriteFrame name
local function create_sprite(name)
    name = name or ""
    if name == "" then
        return cc.Sprite:create(gk.resource.defaultSprite)
    end
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
    if spriteFrame then
        return cc.Sprite:createWithSpriteFrame(spriteFrame)
    end
    -- absolute path
    spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
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
    texture = cc.Director:getInstance():getTextureCache():addImage(gk.resource.textureRelativePath .. gk.resource.defaultSprite)
    if texture then
        return cc.Sprite:createWithTexture(texture)
    end
    -- absolute path
    return cc.Sprite:create(gk.resource.defaultSprite)
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
    local lan = gk.resource:getCurrentLan()
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
    if not label then
        gk.log("warning! create_label return nil, use default system font, string= %s, fontFile = %s", info.string, fontFile)
        label = cc.Label:createWithSystemFont(info.string, "Arial", info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    end
    return label
end

gk.create_label = create_label

local function nextFocusNode(current)
    local all = {}
    local function focusNodes(node)
        if node then
            if node ~= current and node.focusable and node.enabled then
                table.insert(all, node)
            end
            -- test draw
            if node.focusable then
                gk.util:clearDrawLabel(node)
            end
            local children = node:getChildren()
            for i = 1, #children do
                focusNodes(children[i])
            end
        end
    end

    local root = gk.util:getRootNode(current)
    focusNodes(root)
    if #all > 0 then
        table.sort(all, function(a, b)
            if b:getPositionY() == current:getPositionY() and b:getPositionX() < current:getPositionX() then
                return true
            end
            if a:getPositionY() == current:getPositionY() and a:getPositionX() < current:getPositionX() then
                return false
            end
            if b:getPositionY() == current:getPositionY() and a:getPositionY() == current:getPositionY() then
                return a:getPositionX() < b:getPositionX()
            end

            if b:getPositionY() > current:getPositionY() then
                if a:getPositionY() <= current:getPositionY() then
                    return true
                end
            elseif b:getPositionY() == current:getPositionY() then
                if a:getPositionY() > current:getPositionY() then
                    return false
                end
            elseif b:getPositionY() < current:getPositionY() then
                if a:getPositionY() > current:getPositionY() then
                    return false
                end
            end
            return (a:getPositionY() == b:getPositionY() and a:getPositionX() < b:getPositionX() or a:getPositionY() > b:getPositionY())
        end)

        -- test draw
        for i = 1, #all do
            gk.util:drawLabelOnNode(all[i], tostring(i))
        end
        if #all > 0 then
            return all[1]
        end
    end

    return nil
end

gk.nextFocusNode = nextFocusNode

