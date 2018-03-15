--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/20
-- Time: 上午9:43
-- To change this template use File | Settings | File Templates.
--

local MainLayer = class("MainLayer", gk.Layer)

function MainLayer:ctor()
    MainLayer.super.ctor(self)
    -- calculate height
    local height = (gk.display:designSize().height * gk.display:yScale() - 112 * 2 * gk.display:minScale()) / gk.display:xScale()
    self.tableView1:setViewSize(cc.size(self.tableView1:getViewSize().width, height))
    self:setDataSource()
end

function MainLayer:cellNumsOfTableView()
    return #self:getDataSource()
end

function MainLayer:cellSizeForTable(table, idx)
    if not self.cellSize then
        -- get cell size
        local cell = gk.injector:inflateNode("demoapp.ChatCell")
        self.cellSize = cell:getContentSize()
    end
    return self.cellSize.width, self.cellSize.height
end

function MainLayer:cellAtIndex(table, idx)
    local cell = table:dequeueCell()

    if nil == cell then
        cell = gk.injector:inflateNode("demoapp.ChatCell")
    end
    cell:setScale(1)
    cell.nickName:setString(tostring(idx))
    return cell
end

function MainLayer:getDataSource()
    return self.data or {}
end

function MainLayer:setDataSource()
    self.data = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
    self.tableView1:reloadData()
end

return MainLayer