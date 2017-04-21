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
    if self.tableView1 then
        local tableView = self.tableView1

        local cell = gk.injector:inflateNode("demoapp/ChatCell")
        local cellWidth, cellHeight = cell:getContentSize().width, cell:getContentSize().height
        local function numberOfCellsInTableView(table)
            return 10
        end

        local function cellSizeForTable(table, idx)
            return cellWidth, cellHeight
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            if nil == cell then
                cell = gk.injector:inflateNode("demoapp/ChatCell")
            end
            --            if cell and cell.label1 then
            --                local str = tostring(idx) .. ". gen tableCell"
            --                cell.label1:setString(str)
            --            end
            return cell
        end

        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
    end
end

return MainLayer