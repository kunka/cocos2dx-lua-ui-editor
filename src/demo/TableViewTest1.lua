--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/1/25
-- Time: 下午5:28
-- To change this template use File | Settings | File Templates.
--

local TableViewTest1 = class("TableViewTest1", gk.Layer)

function TableViewTest1:ctor()
    TableViewTest1.super.ctor(self)
    if self.tableView1 then
        local tableView = self.tableView1

        local cell = gk.injector:inflateNode("TableCell1")
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
                cell = gk.injector:inflateNode("TableCell1")
            end
            if cell and cell.label1 then
                local str = tostring(idx) .. ". gen tableCell"
                cell.label1:setString(str)
            end
            return cell
        end

        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
    end
end

return TableViewTest1