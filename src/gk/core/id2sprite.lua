--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local id2sprite = {}

local function create_sprite(info)
--    local info = id2sprite.id2proto(info)
    local sprite = CREATE_SPRITE(info.file)
    sprite.file = info.file
    return sprite
end

gk.create_sprite = create_sprite

function id2sprite.default()
    id2sprite._default = id2sprite._default and id2sprite._default or {
        file = "?",
        ap = { x = 0.5, y = 0.5 },
        rotation = 0,
        pos = gk.display.scaleXY(gk.display.width / 2, gk.display.height / 2),
        scaleX = gk.display.minScale,
        scaleY = gk.display.minScale,
    }
    return id2sprite._default
end

function id2sprite.id2proto(info)
    local default = {
        __index = function(_, key)
            local var = id2sprite.default()[key]
            if var then
                return var
            end
            error(string.format("try get undefine property %s", key))
        end
    }
    setmetatable(info, default)
    return info
end

return id2sprite