--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/1/25
-- Time: 下午5:28
-- To change this template use File | Settings | File Templates.
--

local TableViewTest = class("TableViewTest", gk.Layer)

function TableViewTest:ctor()
    TableViewTest.super.ctor(self)
    -- let height fill screen
    local height = gk.display:designSize().height / gk.display:minScale() * gk.display:yScale()
    self.layerColor1:setContentSize(cc.size(self.layerColor1:getContentSize().width, height))
    self.tableView1:setViewSize(cc.size(self.tableView1:getViewSize().width, height))
    self:setData()
    self.tableView1:reloadData()
end

function TableViewTest:cellNumForTable(table)
    return #self:getData()
end

function TableViewTest:cellSizeForTable(table, idx)
    local dt = self:getData()[idx + 1]
    -- use size model to calculate cell height dynamically
    if not dt.height then
        self.cellModel = self.cellModel or gk.injector:inflateNode("gk.test.cell.TableCell1")
        self.cellModel:setData(dt)
        dt.height = self.cellModel.cellHeight
        dt.width = self.cellModel:getContentSize().width
    end
    return dt.width, dt.height
end

function TableViewTest:cellAtIndex(table, idx)
    local dt = self:getData()[idx + 1]
    local cell = table:dequeueCell()
    if nil == cell then
        cell = gk.injector:inflateNode("gk.test.cell.TableCell1")
    end
    cell:setData(dt)
    return cell
end

function TableViewTest:getData()
    return self.data or {}
end

function TableViewTest:setData()
    self.data = {
        { type = "Time", content = "00:00 AM" },
        { type = "Me", content = "Hello!" },
        { type = "Member", content = "Fell well" },
        { type = "Member", content = "Additive blending is the type of blending we do when we add different colors together and add the result." },
        { type = "Time", content = "11:30 AM" },
        { type = "Me", content = "This is the way that our vision works together with light and this is how we can perceive millions of different colors on our monitors." },
        { type = "Member", content = "Free" },
        { type = "Me", content = "Oops" },
        { type = "Member", content = "I say this as a former Secretary of State and as an American: the Russians are still coming. Our intelligence professionals are imploring Trump to act. Will he continue to ignore & surrender, or protect our country?" },
        { type = "Time", content = "1:30 PM" },
        { type = "Me", content = "OMG" },
        { type = "Member", content = "If schools are mandated to be gun free zones, violence and danger are given an open invitation to enter. Almost all school shootings are in gun free zones. Cowards will only go where there is no deterrent!" },
        { type = "Time", content = "13:12" },
        { type = "Me", content = "Will be making a decision soon on the appointment of new Chief Economic Advisor. Many people wanting the job - will choose wisely!" },
        { type = "Time", content = "11:30" },
        { type = "Member", content = "The United States has an $800 Billion Dollar Yearly Trade Deficit because of our “very stupid” trade deals and policies. Our jobs and wealth are being given to other countries that have taken advantage of us for years. They laugh at what fools our leaders have been. No more!" },
    }
end

return TableViewTest