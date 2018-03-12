--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

gk.Scene = import(".Scene")
-- root containers
gk.Layer = import(".Layer")
gk.Dialog = import(".Dialog")
gk.TableViewCell = import(".TableViewCell")
gk.Widget = import(".Widget")
-- gk custom nodes
gk.Button = import(".Button")
gk.EditBox = import(".EditBox")
gk.SelectBox = import(".SelectBox")
gk.ZoomButton = import(".ZoomButton")
gk.ToggleButton = import(".ToggleButton")
gk.SpriteButton = import(".SpriteButton")
gk.CheckBox = import(".CheckBox")
-- gk draw nodes
gk.DrawNodeCircle = import(".DrawNodeCircle")
gk.CubicBezierNode = import(".CubicBezierNode")
gk.QuadBezierNode = import(".QuadBezierNode")
gk.DrawPolygon = import(".DrawPolygon")
gk.DrawCardinalSpline = import(".DrawCardinalSpline")
gk.DrawPoint = import(".DrawPoint")
gk.DrawLine = import(".DrawLine")
-- root containers
gk.injector:ctor_method_swizz(gk.Layer, "ctor")
gk.injector:ctor_method_swizz(gk.Dialog, "ctor")
gk.injector:ctor_method_swizz(gk.TableViewCell, "ctor")
gk.injector:widget_ctor_method_swizz(gk.Widget, "ctor")

----------------------------------------- create sprite  -------------------------------------------------

-- name : sprite name or spriteFrame name
local function create_sprite(name)
    if not name or name == "" then
        return cc.Sprite:create(gk.resource.defaultSprite)
    end
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
    if spriteFrame then
        return cc.Sprite:createWithSpriteFrame(spriteFrame), true
    end
    local texture = cc.Director:getInstance():getTextureCache():addImage(gk.resource.textureDir .. name)
    if texture then
        return cc.Sprite:createWithTexture(texture), true
    end
    -- absolute path
    texture = cc.Director:getInstance():getTextureCache():addImage(name)
    if texture then
        return cc.Sprite:createWithTexture(texture), true
    end
    gk.log("gk.create_sprite(%s) file not found, use default sprite!", name)
    texture = cc.Director:getInstance():getTextureCache():addImage(gk.resource.textureDir .. gk.resource.defaultSprite)
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
-- TODO: file exist
local function isTTF(fontFile)
    return string.lower(tostring(fontFile)):ends(".ttf")
end

local function isBMFont(fontFile)
    return string.lower(tostring(fontFile)):ends(".fnt")
end

local function isCharMap(fontFile)
    return string.lower(tostring(fontFile)):ends(".png")
end

local function isSystemFont(fontFile)
    return not isTTF(fontFile) and not isBMFont(fontFile) and not isCharMap(fontFile)
end

gk.isTTF = isTTF
gk.isBMFont = isBMFont
gk.isCharMap = isCharMap
gk.isSystemFont = isSystemFont

local function create_label_local(info)
    local fontFile = info.fontFile or {}
    local lan = info.lan or gk.resource:getCurrentLan()
    local fontFile = fontFile[lan]
    if fontFile == nil then
        fontFile = gk.resource:getDefaultFont(lan)
    end
    local file = gk.resource:getFontFile(fontFile)
    local label
    -- TODO: createWithCharMap
    if isTTF(fontFile) then
        label = cc.Label:createWithTTF(info.string, file, info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    elseif isBMFont(fontFile) then
        label = cc.Label:createWithBMFont(file, info.string, cc.TEXT_ALIGNMENT_LEFT)
        if label then
            label:setBMFontSize(info.fontSize)
        end
    elseif isCharMap(fontFile) then
        label = cc.Label:createWithCharMap(gk.create_sprite(file):getTexture(), info.itemWidth or 20, info.itemHeight or 40, 0x30)
        if label then
            label:setString(info.string or "")
        end
    end
    if not label then
        label = cc.Label:createWithSystemFont(info.string, "Arial", info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        --        info.fontFile[lan] = label:getSystemFontName()
--        gk.log("warning! create_label use system font %s, string = \"%s\", fontFile = %s", fontFile[lan], info.string, file)
    end
    return label
end

gk.create_label_local = create_label_local

--- [Editor use only, no localization info]
local function create_label(string, fontFile, fontSize, c3b)
    local label
    -- TODO: createWithCharMap
    if isTTF(fontFile) then
        label = cc.Label:createWithTTF(string, fontFile, fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        if c3b then
            label:setTextColor(c3b)
        end
    elseif isBMFont(fontFile) then
        label = cc.Label:createWithBMFont(fontFile, string, cc.TEXT_ALIGNMENT_LEFT)
        label:setBMFontSize(fontSize)
        if c3b then
            label:setColor(c3b)
        end
        -- TODO
        --    elseif isCharMap(fontFile) then
        --        label = cc.Label:createWithCharMap(gk.create_sprite(fontFile):getTexture(), info.itemWidth or 20, info.itemHeight or 40, 30)
        --        label:setString(string or "")
    else
        label = cc.Label:createWithSystemFont(string, fontFile or gk.theme.font_sys, fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
        if c3b then
            label:setColor(c3b)
        end
    end
    return label
end

gk.create_label = create_label

-- for all kinds of label
local function set_label_color(label, c3b)
    local config = label:getTTFConfig()
    if config.fontFilePath ~= "" then
        -- TTF
        label:setTextColor(c3b)
    elseif label:getBMFontFilePath() ~= "" then
        -- BMFont
        label:setColor(c3b)
    else
        -- Sys
        label:setColor(c3b)
    end
end

gk.set_label_color = set_label_color

--- [Editor use only, for EditBox and SelectBox]
local function __nextFocusNode(x, y, root)
    local all = {}
    local function focusNodes(node)
        if node then
            --            if node ~= current and node.focusable and node.enabled then
            if (node:getPositionX() ~= x or node:getPositionY() ~= y) and node.focusable and node.enabled then
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

    --    local root = gk.util:getRootNode(current)
    focusNodes(root)
    if #all > 0 then
        table.sort(all, function(a, b)
            if b:getPositionY() == y and b:getPositionX() < x then
                return true
            end
            if a:getPositionY() == y and a:getPositionX() < x then
                return false
            end
            if b:getPositionY() == y and a:getPositionY() == y then
                return a:getPositionX() < b:getPositionX()
            end

            if b:getPositionY() > y then
                if a:getPositionY() <= y then
                    return true
                end
            elseif b:getPositionY() == y then
                if a:getPositionY() > y then
                    return false
                end
            elseif b:getPositionY() < y then
                if a:getPositionY() > y then
                    return false
                end
            end
            return (a:getPositionY() == b:getPositionY() and a:getPositionX() < b:getPositionX() or a:getPositionY() > b:getPositionY())
        end)

        -- test draw
        --        for i = 1, #all do
        --            gk.util:drawLabelOnNode(all[i], tostring(i))
        --        end
        if #all > 0 then
            return all[1]
        end
    end

    return nil
end

gk.__nextFocusNode = __nextFocusNode

