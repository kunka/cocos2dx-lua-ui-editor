--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/1/25
-- Time: 下午5:28
-- To change this template use File | Settings | File Templates.
--

local TableViewTest = class("TableViewTest", gk.Layer)

local popTopMargin = 18 * gk.display:minScale()
local popBottomMargin = 12 * gk.display:minScale()
local textLeftMargin = 45 * gk.display:minScale()
local textRightMargin = 30 * gk.display:minScale()
local textTopMargin = 15 * gk.display:minScale()
local textBottomMargin = 25 * gk.display:minScale()
local timeMarginH = 10 * gk.display:minScale()
local timeMarginV = 8 * gk.display:minScale()

function TableViewTest:ctor()
    TableViewTest.super.ctor(self)
    self:setData()
    self.tableView1:reloadData()
end

function TableViewTest:cellNumForTable(table)
    return #self:getData()
end

function TableViewTest:cellSizeForTable(table, idx)
    local dt = self:getData()[idx + 1]
    -- size model
    self.cellModel = self.cellModel or gk.injector:inflateNode("test.cell.TableCell1")
    if not dt.height then
        if dt.type == "Member" then
            self.cellModel.label_left:setString(dt.content)
            dt.height = popTopMargin + popBottomMargin + textTopMargin + textBottomMargin + self.cellModel.label_left:getContentSize().height * gk.display:minScale()
        elseif dt.type == "Me" then
            self.cellModel.label_right:setString(dt.content)
            dt.height = popTopMargin + popBottomMargin + textTopMargin + textBottomMargin + self.cellModel.label_right:getContentSize().height * gk.display:minScale()
        elseif dt.type == "Time" then
            self.cellModel.desc:setString(dt.content)
            dt.height = timeMarginV * 2 + self.cellModel.desc:getContentSize().height * gk.display:minScale()
        end
    end
    return gk.display:winSize().width, dt.height
end

function TableViewTest:cellAtIndex(table, idx)
    local dt = self:getData()[idx + 1]
    local cell = table:dequeueCell()
    if nil == cell then
        cell = gk.injector:inflateNode("test.cell.TableCell1")
    end
    if cell then
        cell.Member:setVisible(false)
        cell.Me:setVisible(false)
        cell.Time:setVisible(false)
        cell[dt.type]:setVisible(true)
        if dt.type == "Member" then
            cell.label_left:setString(dt.content)
            local pos = cc.p(cell.label_left:getPosition())
            cell.label_left:setPosition(cc.p(pos.x, dt.height - popTopMargin - textTopMargin))
            local pos = cc.p(cell.avatar_left:getPosition())
            cell.avatar_left:setPosition(cc.p(pos.x, dt.height - popTopMargin))

            local size = cell.label_left:getContentSize()
            cell.pop_left:setContentSize(size.width + (textLeftMargin + textRightMargin) / gk.display:minScale(), size.height - popTopMargin +
                    (textTopMargin + textBottomMargin) / gk.display:minScale()) --60
            --                        gk.util:drawNode(cell.pop_left)
            --                        gk.util:drawNodeBounds(cell.label_left)
            local pos = cc.p(cell.pop_left:getPosition())
            cell.pop_left:setPosition(cc.p(pos.x, dt.height - popTopMargin))
        elseif dt.type == "Me" then
            cell.label_right:setString(dt.content)
            local pos = cc.p(cell.avatar_right:getPosition())
            cell.avatar_right:setPosition(cc.p(pos.x, dt.height - popTopMargin))

            local size = cell.label_right:getContentSize()
            cell.pop_right:setContentSize(size.width + (textLeftMargin + textRightMargin) / gk.display:minScale(), size.height -
                    popTopMargin + (textTopMargin + textBottomMargin) / gk.display:minScale())
            --                        gk.util:drawNode(cell.avatar_right)
            --                        gk.util:drawNodeBounds(cell.label_right)
            local pos = cc.p(cell.pop_right:getPosition())
            cell.pop_right:setPosition(cc.p(pos.x, dt.height - popTopMargin))

            cell.label_right:setPosition(cc.p(pos.x - size.width * gk.display:minScale() - textLeftMargin, dt.height - popTopMargin - textTopMargin))
        elseif dt.type == "Time" then
            cell.desc:setString(dt.content)
            local pos = cc.p(cell.desc:getPosition())
            cell.desc:setPosition(cc.p(pos.x, dt.height / 2))
            local size = cell.desc:getContentSize()
            --                        gk.util:drawNodeBounds(cell.desc)
            cell.bg_time:setContentSize(size.width + (timeMarginH * 2) / gk.display:minScale(), size.height + timeMarginV * 2 / gk.display:minScale())
            cell.bg_time:setPosition(cc.p(pos.x, dt.height / 2))
        end
    end
    return cell
end

function TableViewTest:getData()
    return self.data or {}
end

function TableViewTest:setData()
    self.data = {
        { type = "Time", content = "00:00 AM" },
        { type = "Member", content = "Additive blending is the type of blending we do when we add different colors together and add the result." },
        { type = "Time", content = "10:00 AM" },
        { type = "Me", content = "Hello!" },
        { type = "Member", content = "Fell well" },
        { type = "Time", content = "11:30 AM" },
        { type = "Me", content = "?" },
        { type = "Me", content = "This is the way that our vision works together with light and this is how we can perceive millions of different colors on our monitors" },
        { type = "Member", content = "Free" },
        { type = "Time", content = "Your message could not be sent due to local laws, regulations, and politicies." },
        { type = "Me", content = "Oops" },
        { type = "Member", content = "xx" },
        { type = "Time", content = "1:30 PM" },
        { type = "Me", content = "Er" },
        { type = "Me", content = "OMG" },
        { type = "Member", content = "Do not!" },
        { type = "Member", content = "Ege" },
        { type = "Time", content = "13:12" },
        { type = "Me", content = "?" },
        { type = "Member", content = "Live" },
        { type = "Time", content = "11:30" },
    }
end

return TableViewTest