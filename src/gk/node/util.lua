--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local function replace_layer_create(type)
    local meta = getmetatable(type)
    local create = meta.create
    local __create = function(...)
        local node = create(...)
        local vars = { ... }
        local count = #vars
        if count <= 2 then
            node:setContentSize(gk.display.winSize)
        end
        return node
    end
    meta.create = __create
end

replace_layer_create(cc.Layer)
replace_layer_create(cc.LayerColor)

local function replace_scene_create(type)
    local meta = getmetatable(type)
    local create = meta.create
    local __create = function(...)
        local node = create(...)
        gk.display.addEditorPanel(node)
        return node
    end
    meta.create = __create
end

replace_scene_create(cc.Scene)

--local function replace_sprite_create(type)
--    local meta = getmetatable(type)
--    local create = meta.create
--    local __create = function(...)
--        local node = create(...)
--        node:setScale(gk.display.minScale)
--        return node
--    end
--    meta.create = __create
--end
--
--replace_sprite_create(cc.Sprite)

--local meta = getmetatable(cc.Sprite)
--local meta = getmetatable(cc.LayerColor)
--dump(meta)
--director:getWinSize()