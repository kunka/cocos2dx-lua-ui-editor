--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/4/11
-- Time: 下午2:09
-- To change this template use File | Settings | File Templates.
--

local List = class("List")

function List:ctor()
    self.first = 0
    self.last = -1
end

function List:pushLeft(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
end

function List:pushRight(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
end

function List:popLeft()
    local first = self.first
    if first > self.last then error("list is empty") end
    local value = self[first]
    self[first] = nil -- to allow garbage collection
    self.first = first + 1
    return value
end

function List:popRight()
    local last = self.last
    if self.first > last then error("list is empty") end
    local value = self[last]
    self[last] = nil -- to allow garbage collection
    self.last = last - 1
    return value
end

function List:left()
    local first = self.first
    if first > self.last then error("list is empty") end
    local value = self[first]
    return value
end

function List:right()
    local last = self.last
    if self.first > last then error("list is empty") end
    local value = self[last]
    return value
end

function List:size()
    return self.last - self.first + 1
end

gk.List = List