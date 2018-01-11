--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 19/12/2017
-- Time: 18:06
-- To change this template use File | Settings | File Templates.
--

local FSMEditor = class("FSMEditor", gk.Layer)

function FSMEditor:ctor(...)
    FSMEditor.super.ctor(self, ...)
    if gk.mode == gk.MODE_EDIT then
        self:scheduleUpdate(function(delta)
            self:update(delta)
        end)
    end
end

function FSMEditor:onEnter()
    FSMEditor.super.onEnter(self)
    self:update(0)
    if gk.mode == gk.MODE_RELEASE_CURRENT then
        if self.__path then
            self.fsm = gk.injector:inflateFSM(self.__path)
            self:updateDisplay()
            for k, v in pairs(self.trans) do
                v.button1:onClicked(function()
                    self.fsm[v.action]()
                    self:updateDisplay()
                end)
            end
        end
    end
end

function FSMEditor:updateDisplay()
    for k, v in pairs(self.states) do
        v:setSelected(self.fsm:is(k))
    end
    for k, v in pairs(self.trans) do
        if v.from == self.fsm:getState() then
            local to = self.fsm:can(v.action)
            if to and to == v.to then
                v:setTransabled(true)
            else
                v:setTransabled(false)
            end
        else
            v:setTransabled(false)
        end
    end
end

function FSMEditor:update(delta)
    self.states = {}
    self.trans = {}
    local children = self:getChildren()
    for i = 1, #children do
        local child = children[i]
        if gk.util:instanceof(child, "FSMNode") then
            self.states[child.state] = child
        elseif gk.util:instanceof(child, "FSMTransNode") then
            table.insert(self.trans, child)
        end
    end
    for k, tran in pairs(self.trans) do
        local from = self.states[tran.from]
        local to = self.states[tran.to]
        if from and to then
            local p1, p2 = self:getLine(from, to)
            p1 = from:convertToWorldSpace(p1)
            tran.quadBezierNode1:setOrigin(tran.quadBezierNode1:convertToNodeSpace(p1))
            p2 = to:convertToWorldSpace(p2)
            tran.quadBezierNode1:setMovablePoints(tran.quadBezierNode1:convertToNodeSpace(p2), 3)
        end
    end
end

function FSMEditor:getLine(from, to)
    local p1 = cc.p(from:getPosition())
    local p2 = cc.p(to:getPosition())
    local dt = cc.pSub(p2, p1)
    local idx1, idx2 = 1, 1
    --   2
    --1     3
    --   4
    if dt.x > 0 then
        if dt.y > 0 then
            --  B
            --A
            if math.abs(dt.x) > math.abs(dt.y) then
                idx1, idx2 = 3, 1
            else
                idx1, idx2 = 3, 4
            end
        else
            --A
            --  B
            if math.abs(dt.x) > math.abs(dt.y) then
                idx1, idx2 = 3, 1
            else
                idx1, idx2 = 3, 2
            end
        end
    else
        if dt.y > 0 then
            --B
            --  A
            if math.abs(dt.x) > math.abs(dt.y) then
                idx1, idx2 = 1, 3
            else
                idx1, idx2 = 1, 4
            end
        else
            --  A
            --B
            if math.abs(dt.x) > math.abs(dt.y) then
                idx1, idx2 = 1, 3
            else
                idx1, idx2 = 4, 3
            end
        end
    end

    local size = from:getContentSize()
    p1 = cc.p(size.width / 2, size.height / 2)
    p2 = cc.p(size.width / 2, size.height / 2)
    if math.mod(idx1, 2) == 1 then
        p1.x = p1.x + (idx1 - 2) * size.width / 2
    else
        p1.y = p1.y + (3 - idx1) * size.height / 2
    end
    if math.mod(idx2, 2) == 1 then
        p2.x = p2.x + (idx2 - 2) * size.width / 2
    else
        p2.y = p2.y + (3 - idx2) * size.height / 2
    end
    return p1, p2
end

return FSMEditor