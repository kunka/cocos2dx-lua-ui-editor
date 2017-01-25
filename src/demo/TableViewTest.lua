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
    if self.tableView1 then
        local tableView = self.tableView1

        local cellWidth, cellHeight = 940 * gk.display.xScale(), 100 * gk.display.minScale()
        local bgHeight = (100 - 10) * gk.display.minScale()
        local function numberOfCellsInTableView(table)
            return 10
        end

        local function cellSizeForTable(table, idx)
            return cellWidth, cellHeight
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            if nil == cell then
                cell = cc.TableViewCell:new()
                local layerColor = cc.LayerColor:create(cc.c4b(102, 101, 155, 255), cellWidth, bgHeight)
                cell:addChild(layerColor)

                local label = cc.Label:createWithSystemFont(tostring(idx), "Consolas", 12, cc.size(0, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
                cell:addChild(label)
                label:setTag(1)
                label:setPosition(25 * gk.display.xScale(), bgHeight / 2)
            else
                local label = cell:getChildByTag(1)
                label:setString(tostring(idx))
            end

            return cell
        end

        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
    end
end

return TableViewTest