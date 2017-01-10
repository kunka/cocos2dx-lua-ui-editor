--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local id2button = {}
local protos = require("demo.gen.button")

local function create_button(id)
    local proto = id2button.id2proto(id)
    local button = gk.ZoomButton.new(CREATE_SPRITE(proto.file))
    button.__id = id
    button:setPosition(proto.pos)
    button:setScale(proto.scale)
    return button
end

gk.create_button = create_button

function id2button.default()
    return {
        file = "?",
        pos = gk.display.scaleXY(gk.display.width / 2, gk.display.height / 2),
        scale = gk.display.minScale,
    }
end

function id2button.id2proto(id)
    local proto = protos[id]
    if not proto then
        proto = {}
        local default = {
            __index = function(_, key)
                local defaultProto = id2button.default()
                local var = defaultProto[key]
                if var then
                    return var
                end
                error(string.format("try get undefine property %s", key))
            end
        }
        setmetatable(proto, default)
    end
    return proto
end

return id2button