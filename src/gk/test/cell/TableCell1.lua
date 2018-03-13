--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/7
-- Time: 上午9:29
-- To change this template use File | Settings | File Templates.
--

local TableCell1 = class("TableCell1", gk.TableViewCell)

local popMaxWidth = 300
local popMinHeight = 80
local popVerticalMargin = 10

local textLeftMargin = 26
local textRightMargin = 15
local textVerticalMargin = 20

-- must have a __cname and ctor to be injected
function TableCell1:ctor()
    TableCell1.super.ctor(self)

    if gk.mode ~= gk.MODE_RELEASE then
        --                self:setData({ type = "Member", content = "Hello" })
        --                        self:setData({ type = "Member", content = "If schools are mandated to be gun free zones, violence and danger are given an open invitation to enter. Almost all school shootings are in gun free zones. Cowards will only go where there is no deterrent!" })
        --                        self:setData({ type = "Me", content = "Hello" })
        self:setData({ type = "Me", content = "I say this as a former Secretary of State and as an American: the Russians are still coming. Our intelligence professionals are imploring Trump to act. Will he continue to ignore & surrender, or protect our country?" })
        --                self:setData({ type = "Time", content = "20:00" })
        --                self:setData({ type = "Time", content = "Yesterday 18:45" })
    end
end

function TableCell1:setData(dt)
    if dt.type == "Member" then
        self.Time:hide()
        self.Me:hide()
        self.Member:show()
        self.label_left:setDimensions(0, 0)
        self.label_left:setString(dt.content)
        local size = self.label_left:getContentSize()
        if size.width > popMaxWidth - textLeftMargin - textRightMargin then
            self.label_left:setDimensions(popMaxWidth - textLeftMargin - textRightMargin, 0)
            size = self.label_left:getContentSize()
        end
        local popWidth = math.min(popMaxWidth, size.width + textLeftMargin + textRightMargin)
        local popHeight = math.max(popMinHeight, size.height + textVerticalMargin * 2)
        self.pop_left:setContentSize(cc.size(popWidth, popHeight))
        self.cellHeight = popVerticalMargin * 2 + popHeight
        self.Member:setContentSize(cc.size(self:getContentSize().width, self.cellHeight))
        self.avatar_left:setPositionY(self.cellHeight - popVerticalMargin)
        self.pop_left:setPositionY(self.cellHeight - popVerticalMargin)
        self.label_left:setPositionY(self.pop_left:getContentSize().height / 2)
    elseif dt.type == "Me" then
        self.Member:hide()
        self.Time:hide()
        self.Me:show()
        self.label_right:setDimensions(0, 0)
        self.label_right:setString(dt.content)
        local size = self.label_right:getContentSize()
        if size.width > popMaxWidth - textLeftMargin - textRightMargin then
            self.label_right:setDimensions(popMaxWidth - textLeftMargin - textRightMargin, 0)
            size = self.label_right:getContentSize()
        end
        local popWidth = math.min(popMaxWidth, size.width + textLeftMargin + textRightMargin)
        local popHeight = math.max(popMinHeight, size.height + textVerticalMargin * 2)
        self.pop_right:setContentSize(cc.size(popWidth, popHeight))
        self.cellHeight = popVerticalMargin * 2 + popHeight
        self.Me:setContentSize(cc.size(self:getContentSize().width, self.cellHeight))
        self.avatar_right:setPositionY(self.cellHeight - popVerticalMargin)
        self.pop_right:setPositionY(self.cellHeight - popVerticalMargin)
        self.label_right:setPositionX(self.pop_right:getContentSize().width - textLeftMargin)
        self.label_right:setPositionY(self.pop_right:getContentSize().height / 2)
    elseif dt.type == "Time" then
        self.Member:hide()
        self.Me:hide()
        self.Time:show()
        self.desc:setString(dt.content)
        local size = self.desc:getContentSize()
        local margin = 18
        size.width = size.width + margin
        size.height = size.height + margin
        self.bg_time:setContentSize(size)
        self.desc:setPosition(size.width / 2, size.height / 2)
        self.cellHeight = self.Time:getContentSize().height
    end

    self:setContentSize(cc.size(self:getContentSize().width, self.cellHeight))
end

return TableCell1