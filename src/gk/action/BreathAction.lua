--
-- Created by localelliJ IDEA.
-- User: Kunkka
-- Date: 7/19/17
-- Time: 10:55
-- To change this template use File | Settings | File Templates.
--

local BreathAction = class("BreathAction")

function BreathAction:ctor(actionInterval)
    assert(gk.util:instanceof(actionInterval, "cc.ActionInterval"), "must use cc.ActionInterval!")
    self.actionInterval = actionInterval
    self.duration = self.actionInterval:getDuration()
    self._elapsed = 0
end

function BreathAction:start(target)
    self.actionInterval:retain()
    self.actionInterval:startWithTarget(target)
    self.scheduler = gk.scheduler:scheduleUpdateGlobal(function(delta)
        self:step(delta)
        if self._elapsed >= self.duration then
            self._elapsed = 0
        end
    end)
end

function BreathAction:stop()
    self.actionInterval:release()
    gk.scheduler:unscheduleGlobal(self.scheduler)
end

function BreathAction:step(delta)
    self._elapsed = self._elapsed + delta
    local updateDt = math.max(0, math.min(1, self._elapsed / self.duration))
    self:update(updateDt)
end

function BreathAction:update(time)
    self.actionInterval:update(self:getInterpolation(time))
end

function BreathAction:getInterpolation(input)
    local x = 6 * input
    local k = 1.0 / 3
    local t = 6
    local n = 1
    local PI = 3.1416
    local output = 0

    if (x >= ((n - 1) * t) and x < ((n - (1 - k)) * t)) then
        output = (0.5 * math.sin((PI / (k * t)) * ((x - k * t / 2) - (n - 1) * t)) + 0.5)
    elseif (x >= (n - (1 - k)) * t and x < n * t) then
        output = math.pow((0.5 * math.sin((PI / ((1 - k) * t)) * ((x - (3 - k) * t / 2) - (n - 1) * t)) + 0.5), 2)
    end
    return output
end

return BreathAction