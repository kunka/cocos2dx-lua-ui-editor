--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local id2button = {}

local function create_button(info)
    local info = id2button.id2proto(info)
    local button = gk.ZoomButton.new(CREATE_SPRITE(info.file))
    return button
end

gk.create_button = create_button

function id2button.default()
    id2button._default = id2button._default and id2button._default or {
        file = "?",
        pos = gk.display.scaleXY(gk.display.width / 2, gk.display.height / 2),
        scaleX = gk.display.minScale,
        scaleY = gk.display.minScale,
    }
    return id2button._default
end

function id2button.id2proto(info)
    local proto = {}
    local default = {
        __index = function(_, key)
            local var = info[key] or id2button.default()[key]
            if var then
                return var
            end
            if key == "id" then
                proto.id = string.format("sprite%d", id2button.id and id2button.id + 1 or 1)
                return proto.id
            end
            error(string.format("try get undefine property %s", key))
        end
    }
    setmetatable(proto, default)
    return proto
end

return id2button