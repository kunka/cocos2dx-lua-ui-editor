local scheduler = {}
local director = cc.Director:getInstance()
local sharedScheduler = director:getScheduler()

function scheduler:scheduleScriptFunc(listener, interval, pause)
    local handle = sharedScheduler:scheduleScriptFunc(listener, interval, pause)
    self:_getScheduleIds()[handle] = true
    return handle
end

function scheduler:scheduleUpdateGlobal(listener)
    local handle = sharedScheduler:scheduleScriptFunc(listener, 0, false)
    self:_getScheduleIds()[handle] = true
    return handle
end

function scheduler:scheduleGlobal(listener, interval)
    local handle = sharedScheduler:scheduleScriptFunc(listener, 0, false)
    self:_getScheduleIds()[handle] = true
    return handle
end

function scheduler:unscheduleGlobal(handle)
    sharedScheduler:unscheduleScriptEntry(handle)
    self:_getScheduleIds()[handle] = nil
end

function scheduler:unscheduleScriptEntry(handle)
    sharedScheduler:unscheduleScriptEntry(handle)
    self:_getScheduleIds()[handle] = nil
end

function scheduler:performWithDelayGlobal(listener, time)
    local handle
    handle = sharedScheduler:scheduleScriptFunc(function()
        self:unscheduleGlobal(handle)
        listener()
    end, time, false)
    self:_getScheduleIds()[handle] = true
    return handle
end

function scheduler:_getScheduleIds()
    self.scheduleIds = self.scheduleIds or {}
    return self.scheduleIds
end

function scheduler:unscheduleAll()
    for scheduleId, _ in pairs(self:_getScheduleIds()) do
        sharedScheduler:unscheduleScriptEntry(scheduleId)
    end
    self.scheduleIds = {}
end

return scheduler

