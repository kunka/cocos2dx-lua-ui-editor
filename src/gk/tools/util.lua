--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local util = {}

----------------------------------------- switch function  -------------------------------------------------
-- function to simulate a switch
local function switch(t)
    t.case = function(self, x, ...)
        local f = self[x] or self.default
        if f then
            if type(f) == "function" then
                return f(...)
            else
                error("case " .. tostring(x) .. " not a function")
            end
        end
        return nil
    end

    return t
end

gk.exports.switch = switch

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function string.ends(String, End)
    return End == '' or string.sub(String, -string.len(End)) == End
end

function math.shrink(f, bit)
    if bit >= 1 and bit <= 6 then
        local e = 1 / math.pow(10, bit + 1)
        local v = math.pow(10, bit)
        return math.round((f + e) * v) / v
    elseif bit == 0.5 then
        return math.floor(f * 2) / 2
    elseif bit == 0 then
        return math.round(f)
    else
        return f
    end
end

function math.equal(f1, f2, bit)
    return math.shrink(f1, bit) == math.shrink(f2, bit)
end

function string.replaceChar(str, index, char)
    if index >= 1 and index <= str:len() then
        str = index == 1 and char .. str:sub(2, str:len()) or (str:sub(1, index - 1) .. char .. str:sub(index + 1, str:len()))
    end
    return str
end

-- insert before the indexinit
function string.insertChar(str, index, char)
    if index >= 1 and index <= str:len() + 1 then
        str = index == 1 and char .. str or (str:sub(1, index - 1) .. char .. str:sub(index, str:len()))
    end
    return str
end

-- insert char at index
function string.deleteChar(str, index)
    if index >= 1 and index <= str:len() then
        str = index == 1 and str:sub(2, str:len()) or (str:sub(1, index - 1) .. str:sub(index + 1, str:len()))
    end
    return str
end

string.toHex = function(s)
    return string.gsub(s, "(.)", function(x) return string.format("%02X", string.byte(x)) end)
end

----------------------------------------- restart game  -------------------------------------------------
util.onRestartGameCallbacks = util.onRestartGameCallbacks or {}
function util:registerOnRestartGameCallback(callback)
    table.insert(self.onRestartGameCallbacks, callback)
end

util.beforeRestartGameCallbacks = util.beforeRestartGameCallbacks or {}
function util:registerBeforeRestartGameCallback(callback)
    table.insert(self.beforeRestartGameCallbacks, callback)
end

function util:registerRestartGameCallback(callback)
    util.restartGameCallback = callback
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_MAC and not util.restartLayer then
        gk.log("init:registerRestartGameCallback")
        util.restartLayer = cc.Layer:create()
        util.restartLayer:retain()

        local function onKeyReleased(keyCode, event)
            if gk.focusNode then
                return
            end
            local key = cc.KeyCodeKey[keyCode + 1]
            --            gk.log("RestartLayer: onKeypad %s", key)
            if key == "KEY_F1" then
                -- debug mode, restart with current editing node
                util:restartGame(1)
            elseif key == "KEY_F2" then
                -- release mode, restart with cureent entry
                util:restartGame(2)
            elseif key == "KEY_F3" then
                -- release mode, restart with default entry
                util:restartGame(0)
            end
        end

        local listener = cc.EventListenerKeyboard:create()
        listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, util.restartLayer)
        util.restartLayer:resume()
    end
end

function util:restartGame(mode)
    gk.log("===================================================================")
    gk.log("=====================    restart game    ==========================")
    gk.log("===================================================================")
    if self.restartLayer then
        self.restartLayer:release()
        self.restartLayer = nil
    end

    gk.event:post("syncNow")
    gk.event:init()
    gk:increaseRuntimeVersion()
    gk.scheduler:unscheduleAll()
    for _, callback in ipairs(self.beforeRestartGameCallbacks) do
        callback()
    end
    self.beforeRestartGameCallbacks = {}
    local scene = cc.Scene:create()
    cc.Director:getInstance():popToRootScene()
    cc.Director:getInstance():replaceScene(scene)
    scene:runAction(cc.CallFunc:create(function()
        gk.log("removeResBeforeRestartGame")
        for _, callback in ipairs(self.onRestartGameCallbacks) do
            callback()
        end
        self.onRestartGameCallbacks = {}
        gk.log("collect: lua mem -> %.2fMB", collectgarbage("count") / 1024)
        collectgarbage("collect")
        gk.log("after collect: lua mem -> %.2fMB", collectgarbage("count") / 1024)
        if self.restartGameCallback then
            self.restartGameCallback(mode)
        end
    end))
end

function util:registerOnErrorCallback(callback)
    self.onErrorCallback = callback
end

function util:reportError(msg)
    if util.onErrorCallback then
        util.onErrorCallback(msg)
    end
end

util.tags = util.tags and util.tags or {
    drawTag = 0xFFF0,
    drawParentTag = 0xFFF1,
    labelTag = 0xFFF2,
    boundsTag = 0xFFF3,
    coordinateTag = 0xFFF4,
    versionTag = 0xFFF5,
    buttonOverlayTag = 0xFFF6,
    dialogTag = 0xFFF7,
}

function util:isDebugNode(node)
    local tag = node and node:getTag() or -1
    return tag >= 0xFFF0 --table.indexof(table.values(util.tags), tag)
end

function util:isDebugTag(tag)
    return tag and tag >= 0xFFF0
    --    return table.indexof(table.values(util.tags), tag)
end

function util:clearDrawNode(node, tag)
    if node then
        local tg = tag or util.tags.drawTag
        local draw = node:getChildByTag(tg)
        if self:instanceof(node, "cc.ScrollView") then
            return
            --        draw = node:getContainer():getChildByTag(tg)
        end
        if draw then
            draw:clear()
            draw:stopAllActions()
        end
        -- parent
        if node:getParent() then
            node = node:getParent()
            local tg = tag or util.tags.drawParentTag
            local draw = node:getChildByTag(tg)
            if self:instanceof(node, "cc.ScrollView") then
                draw = node:getContainer():getChildByTag(tg)
            end
            local draw = node:getChildByTag(tg)
            if draw then
                draw:clear()
                draw:stopAllActions()
            end
        end
    end
end

function util:clearDrawLabel(node, tag)
    local tg = tag or util.tags.labelTag
    local label = node:getChildByTag(tg)
    if label then
        label:setString("")
    end
end

function util:drawNode(node, c4f, tag)
    local tg = tag or util.tags.drawTag
    local draw = node:getChildByTag(tg)
    if self:instanceof(node, "cc.ScrollView") then
        draw = node:getContainer():getChildByTag(tg)
    end
    if draw then
        draw:clear()
    else
        draw = cc.DrawNode:create()
        if self:instanceof(node, "cc.ScrollView") then
            node:add(draw, -1, tg)
        else
            node:add(draw, 99999, tg)
        end
        draw:setPosition(cc.p(0, 0))
    end
    local sx, sy = util:getGlobalScale(node)

    local size = node:getContentSize()
    -- bounds
    draw:drawRect(cc.p(0.5, 0.5),
        cc.p(0.5, size.height - 0.5),
        cc.p(size.width - 0.5, size.height - 0.5),
        cc.p(size.width - 0.5, 0.5), c4f and c4f or cc.c4f(1, 0.5, 1, 1))

    -- anchor point
    local p = node:getAnchorPoint()
    p.x = p.x * size.width
    p.y = p.y * size.height
    if node:isIgnoreAnchorPointForPosition() then
        p.x, p.y = 0, 0
    end
    draw:drawDot(p, sx ~= 0 and 1 / sx or 1, cc.c4f(1, 0, 0, 1))

    if self:instanceof(node, "cc.ScrollView") then
        -- bg
        local p1 = cc.p(0, 0)
        local p2 = cc.p(size.width, size.height)
        draw:drawSolidRect(p1, p2, cc.c4f(0.68, 0.68, 0.68, 0.1))
    end
    if self:instanceof(node, "cc.ClippingRectangleNode") then
        -- clipping rect
        local rect = node:getClippingRegion()
        draw:drawRect(cc.p(rect.x + 0.5, rect.y + 0.5),
            cc.p(rect.x + rect.width - 0.5, rect.y + 0.5),
            cc.p(rect.x + rect.width - 0.5, rect.y + rect.height - 0.5),
            cc.p(rect.x + 0.5, rect.y + rect.height - 0.5), c4f and c4f or cc.c4f(155 / 255, 0, 0, 1))
    end
    if self:instanceof(node, "ccui.Scale9Sprite") then
        -- capInsets
        local rect = node:getCapInsets()
        local sprite = node:getSprite()
        local originSize = sprite:getSpriteFrame():getOriginalSize()
        local size = node:getContentSize()
        rect.y = originSize.height - rect.y - rect.height
        rect.width = size.width - (originSize.width - rect.width)
        rect.height = size.height - (originSize.height - rect.height)
        self:drawSegmentRectOnNode(node, rect, 5, cc.c4f(1, 0, 0.5, 0.5), tg)
    end
    if self:instanceof(node, "DrawNode") and type(node.getMovablePoints) == "function" then
        local ps = node:getMovablePoints()
        for _, p in ipairs(ps) do
            draw:drawPoint(p, 5, cc.c4f(1, 1, 0, 1))
            draw:drawCircle(p, 10, 360, 50, false, c4f or cc.c4f(1, 1, 0, 0.2))
        end
    end

    -- refresh draw, only in test mode
    if DEBUG and not tag then
        draw:stopAllActions()
        draw:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            util:drawNode(node, c4f)
        end)))
    end

    -- draw parent
    local tg = tag or util.tags.drawParentTag
    if node:getParent() then
        self:drawNodeBounds(node:getParent(), cc.c4f(0, 0, 255 / 255, 0.1), util.tags.drawParentTag)
    end

    return draw
end

function util:drawNodeBounds(node, c4f, tg)
    local tg = tg or util.tags.boundsTag
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        if self:instanceof(node, "cc.ScrollView") then
            node:add(draw, -1, tg)
        else
            if tg == util.tags.drawParentTag then
                node:add(draw, -1, tg)
            else
                node:add(draw, 9999, tg)
            end
        end
        draw:setPosition(cc.p(0, 0))
    end
    draw:clear()

    local size = node:getContentSize()
    -- bounds
    draw:drawRect(cc.p(0.5, 0.5),
        cc.p(0.5, size.height - 0.5),
        cc.p(size.width - 0.5, size.height - 0.5),
        cc.p(size.width - 0.5, 0.5), c4f and c4f or cc.c4f(0, 155 / 255, 1, 1))

    return draw
end

function util:drawLabelOnNode(node, content, fontSize, pos, c3b, tag)
    local tg = tag or util.tags.labelTag
    local label = node:getChildByTag(tg)
    if self:instanceof(node, "cc.ScrollView") then
        label = node:getContainer():getChildByTag(tg)
    end
    if not label then
        label = gk.create_label(content, gk.theme.font_font, fontSize and fontSize or 12)
        node:add(label, 999, tg)
    else
        label:setString(content)
    end
    local size = node:getContentSize()
    label:setPosition(pos and pos or cc.p(size.width, size.height))
    gk.set_label_color(label, c3b and c3b or cc.c3b(0, 255, 0))
    local sx, sy = util:getGlobalScale(node)
    label:setScale(1 / sx)
end

function util:drawLineOnNode(node, p1, p2, c4f, tg)
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, 999, tg)
        draw:setPosition(cc.p(0, 0))
    end
    c4f = c4f or cc.c4f(1, 0, 1, 1)
    draw:drawLine(p1, p2, c4f)
    return draw
end

function util:drawSegmentRectOnNode(node, rect, radius, c4f, tg)
    self:drawSegmentOnNode(node, cc.p(rect.x, rect.y), cc.p(rect.x + rect.width, rect.y), radius, c4f, tg)
    self:drawSegmentOnNode(node, cc.p(rect.x + rect.width, rect.y), cc.p(rect.x + rect.width, rect.y + rect.height), radius, c4f, tg)
    self:drawSegmentOnNode(node, cc.p(rect.x + rect.width, rect.y + rect.height), cc.p(rect.x, rect.y + rect.height), radius, c4f, tg)
    self:drawSegmentOnNode(node, cc.p(rect.x, rect.y + rect.height), cc.p(rect.x, rect.y), radius, c4f, tg)
end

function util:drawSegmentOnNode(node, p1, p2, radius, c4f, tg)
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, 999, tg)
        draw:setPosition(cc.p(0, 0))
    end
    local dis = cc.pGetDistance(p1, p2)
    local count = math.round(dis / radius)
    for i = 1, count, 2 do
        local pa = cc.pAdd(p1, cc.pMul(cc.pSub(p2, p1), (i - 1) / count))
        local pb = cc.pAdd(p1, cc.pMul(cc.pSub(p2, p1), i / count))
        draw:drawLine(pa, pb, c4f)
    end
    return draw
end

function util:drawDotOnNode(node, p, c4f, tg)
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, 999, tg)
        draw:setPosition(cc.p(0, 0))
    end
    local sx, sy = util:getGlobalScale(node)
    draw:drawDot(p, sx ~= 0 and 1.5 / sx or 1.5, c4f or cc.c4f(1, 0, 0, 1))
    return draw
end

function util:drawRectOnNode(node, p1, p2, p3, p4, c4f, tg)
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, 999, tg)
        draw:setPosition(cc.p(0, 0))
    end
    draw:drawRect(p1, p2, p3, p4, c4f or cc.c4f(1, 0, 0, 0.2))
    return draw
end

function util:drawSolidRectOnNode(node, p1, p2, c4f, tg)
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, 999, tg)
        draw:setPosition(cc.p(0, 0))
    end
    draw:drawSolidRect(p1, p2, c4f or cc.c4f(1, 0, 0, 0.2))
    return draw
end

function util:drawCircleOnNode(node, p, radius, c4f, tg)
    local tg = tg or self.tags.drawTag
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, 999, tg)
        draw:setPosition(cc.p(0, 0))
    end
    draw:drawCircle(p, radius, 360, 50, false, c4f or cc.c4f(1, 0, 0, 0.2))
    return draw
end

function util:drawNodeBg(node, c4f, tg)
    local draw
    if tg then
        draw = node:getChildByTag(tg)
    end
    if not draw then
        draw = cc.DrawNode:create()
        node:add(draw, -1, tg)
        draw:setPosition(cc.p(0, 0))
    end
    draw:clear()
    local size = node:getContentSize()
    draw:drawSolidRect(cc.p(0, 0), cc.p(size.width, size.height), c4f or cc.c4f(1, 1, 1, 1))
    return draw
end

function util:getGlobalScale(node)
    local scaleX, scaleY = 1, 1
    local c = node
    while c ~= nil do
        scaleX = scaleX * c:getScaleX()
        scaleY = scaleY * c:getScaleY()
        c = c:getParent()
    end
    return scaleX, scaleY
end

function util:hitTest(node, touch)
    local s = node:getContentSize()
    if gk.util:instanceof(node, "cc.ScrollView") then
        s = node:getViewSize()
    end
    local rect = { x = 0, y = 0, width = s.width, height = s.height }
    local touchP = node:convertTouchToNodeSpace(touch)
    return cc.rectContainsPoint(rect, touchP)
end

function util:stopActionByTagSafe(node, tag)
    if node then
        local action = node:getActionByTag(tag)
        if action then
            node:stopAction(action)
        end
    end
end

function util:isAncestorsVisible(node)
    local c = node
    while c ~= nil do
        if not c:isVisible() then
            return false
        end
        c = c:getParent()
    end
    return true
end

function util:isAncestorsType(node, type)
    local c = node
    while c ~= nil do
        if self:instanceof(c, type) then
            return true
        end
        c = c:getParent()
    end
    return false
end

function util:isAncestorsIgnore(node)
    local c = node
    while c ~= nil do
        if c.__ignore then
            return true
        end
        c = c:getParent()
    end
    return false
end

function util:getRootNode(node)
    local c = node:getParent()
    local root
    while c ~= nil do
        root = c
        c = c:getParent()
    end
    return root
end

function util:isAncestorOf(ancestor, child)
    local c = child
    while c ~= nil do
        if c == ancestor then
            return true
        end
        c = c:getParent()
    end
    return false
end

function util:touchInNode(node, globalPoint)
    local s = node:getContentSize()
    local rect = { x = 0, y = 0, width = s.width, height = s.height }
    local p = node:convertToNodeSpace(globalPoint)
    return cc.rectContainsPoint(rect, p)
end

function util:setRecursiveCascadeOpacityEnabled(node, enabled)
    node:setCascadeOpacityEnabled(enabled)
    local children = node:getChildren()
    for _, c in pairs(children) do
        util:setRecursiveCascadeOpacityEnabled(c, enabled)
    end
end

function util:setRecursiveCascadeColorEnabled(node, enabled)
    node:setCascadeColorEnabled(enabled)
    local children = node:getChildren()
    for _, c in pairs(children) do
        util:setRecursiveCascadeColorEnabled(c, enabled)
    end
end

function util:table_eq(table1, table2)
    local avoid_loops = {}
    local function recurse(t1, t2)
        -- compare value types
        if type(t1) ~= type(t2) then return false end
        -- Base case: compare simple values
        if type(t1) ~= "table" then return t1 == t2 end
        -- Now, on to tables.
        -- First, let's avoid looping forever.
        if avoid_loops[t1] then return avoid_loops[t1] == t2 end
        avoid_loops[t1] = t2
        -- Copy keys from t2
        local t2keys = {}
        local t2tablekeys = {}
        for k, _ in pairs(t2) do
            if type(k) == "table" then table.insert(t2tablekeys, k) end
            t2keys[k] = true
        end
        -- Let's iterate keys from t1
        for k1, v1 in pairs(t1) do
            local v2 = t2[k1]
            if type(k1) == "table" then
                -- if key is a table, we need to find an equivalent one.
                local ok = false
                for i, tk in ipairs(t2tablekeys) do
                    if table_eq(k1, tk) and recurse(v1, t2[tk]) then
                        table.remove(t2tablekeys, i)
                        t2keys[tk] = nil
                        ok = true
                        break
                    end
                end
                if not ok then return false end
            else
                -- t1 has a key which t2 doesn't have, fail.
                if v2 == nil then return false end
                t2keys[k1] = nil
                if not recurse(v1, v2) then return false end
            end
        end
        -- if t2 has a key which t1 doesn't have, fail.
        if next(t2keys) then return false end
        return true
    end

    return recurse(table1, table2)
end

----------------------------------------- table -------------------------------------------------
local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k
    end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b) return order(t, a, b)
        end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function formatString(str, len)
    local s = string.format("%s", str)
    while string.len(s) < len do
        s = s .. " "
    end
    return s
end

function util:tbl2string(obj)
    if obj and type(obj) == "table" then
        local log = "{\n"
        for k, v in spairs(obj) do
            if type(v) == "table" and v ~= obj then
                --            log = log .. k .. " : " .. tbl2string(v) .. ",\n"
                if table.nums(v) < 10 then
                    log = log .. formatString(k, 18) .. " : \n" .. util:tbl2string(v) .. ",\n"
                else
                    log = log .. k .. " :     " .. "{?}" .. "\n"
                end
            end
            if type(v) ~= "function" and type(v) ~= "table" and type(v) ~= "userdata" then
                log = log .. formatString(k, 18) .. " : " .. tostring(v) .. "\n"
            end
        end
        log = log .. "}"
        return log
    else
        return tostring(obj)
    end
end

local iskindof_
iskindof_ = function(cls, name)
    local __index = rawget(cls, "__index")
    if type(__index) == "table" and rawget(__index, "__cname") == name then return true end

    if rawget(cls, "__cname") == name then return true end
    -- fix crash
    if not __index then return false end
    if type(__index) == "function" then return false end
    -- fix crash
    local __supers = rawget(__index, "__supers")
    if not __supers then return false end
    for _, super in ipairs(__supers) do
        if iskindof_(super, name) then return true end
    end
    return false
end

function util:iskindof(classObj, classname)
    if type(classObj) == "table" then
        if classObj.__cname == classname then
            return true
        else
            local mt = getmetatable(classObj)
            if mt then
                return iskindof_(mt, classname)
            end
        end
    else
        return false
    end
end

function util:instanceof(obj, classname)
    local t = type(obj)
    if t ~= "table" and t ~= "userdata" then return false end
    if obj.class and self:iskindof(obj.class, classname) then
        return true
    end

    local mt
    if t == "userdata" then
        if tolua.iskindof(obj, classname) then return true end
        mt = tolua.getpeer(obj)
    else
        mt = getmetatable(obj)
    end
    if mt then
        return iskindof_(mt, classname)
    end
    return false
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function util:dump(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 4 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    gk.log("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, dump_value_(description), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result + 1] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent .. "    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result + 1] = string.format("%s}", indent)
            end
        end
    end

    dump_(value, description, "  ", 1)

    for i, line in ipairs(result) do
        gk.log(line)
    end
end

function util:floatEql(f1, f2)
    local EPSILON = 0.00001
    return ((f1 - EPSILON) < f2) and (f2 < (f1 + EPSILON))
end

function util:pointEql(p1, p2)
    return self:floatEql(p1.x, p2.x) and self:floatEql(p1.y, p2.y)
end

function util:getBoundingBoxToScreen(node)
    local p = node:convertToWorldSpace(cc.p(0, 0))
    local bb = node:getContentSize()
    local sx, sy = util:getGlobalScale(node)
    bb.width = bb.width * sx
    bb.height = bb.height * sy
    return cc.rect(p.x, p.y, bb.width, bb.height)
end

function util:c4b2c4f(c4b)
    return cc.c4f(c4b.r / 255, c4b.g / 255, c4b.b / 255, c4b.a / 255)
end

function util:addMouseMoveEffect(node, c4f)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC and gk.mode ~= gk.MODE_RELEASE then
        local listener = cc.EventListenerMouse:create()
        listener:registerScriptHandler(function(touch, event)
            if not node.noneMouseMoveEffect then
                local location = touch:getLocationInView()
                if gk.util:touchInNode(node, location) then
                    if not node.isFocus then
                        gk.util:drawNodeBounds(node, c4f or cc.c4f(1, 0.5, 0.5, 0.7), self.tags.boundsTag)
                    end
                else
                    gk.util:clearDrawNode(node, self.tags.boundsTag)
                end
            end
        end, cc.Handler.EVENT_MOUSE_MOVE)
        node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end
end

-- set 1 at pos, (pos = 1~32)
function util:setBit1(int32, pos)
    return bit.bor(int32, bit.lshift(1, pos - 1))
end

-- set 0 at pos
function util:setBit0(int32, pos)
    return bit.band(int32, 0xFFFFFFFF - bit.lshift(1, pos - 1))
end

-- is 1 at pos
function util:isBit1(int32, pos)
    int32 = int32 or 0
    local var = bit.lshift(1, pos - 1)
    return bit.band(int32, var) == var
end

function util:alignNodes(node1, node2, gapX, centerX)
    centerX = centerX or 0
    local w1 = node1:getContentSize().width * node1:getScaleX()
    local w2 = node2:getContentSize().width * node2:getScaleX()
    node1:setAnchorPoint(0.5, node1:getAnchorPoint().y)
    node2:setAnchorPoint(0.5, node1:getAnchorPoint().y)
    local w = w1 + w2 + gapX
    node1:setPositionX(centerX + w1 / 2 - w / 2)
    node2:setPositionX(centerX + w / 2 - w2 / 2)
end

return util