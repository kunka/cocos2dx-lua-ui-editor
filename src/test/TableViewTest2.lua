--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 17/2/7
-- Time: 下午2:49
-- To change this template use File | Settings | File Templates.
--

local TableViewTest2 = class("TableViewTest2", gk.Layer)

function TableViewTest2:ctor()
    TableViewTest2.super.ctor(self)
    if self.tableView1 then
        local tableView = self.tableView1

        local cellWidth, cellHeight = 1260 * gk.display.xScale(), 100 * gk.display.minScale()
        local bgHeight = (100 - 10) * gk.display.minScale()
        local function numberOfCellsInTableView(table)
            return 10
        end

        local function cellSizeForTable(table, idx)
            return cellWidth, cellHeight
        end

        local function tableCellAtIndex(table, idx)
            local cell = table:dequeueCell()
            local str = tostring(idx) .. ". create tableCell by code"
            if nil == cell then
                cell = cc.TableViewCell:new()
                local layerColor = cc.LayerColor:create(cc.c4b(102, 101, 155, 255), cellWidth, bgHeight)
                cell:addChild(layerColor)

                local label = gk.create_label({ fontFile = { en = "font/Consolas.ttf" }, fontSize = 32, string = str })
                cell:addChild(label)
                label:setScale(gk.display.minScale())
                label:setTag(1)
                label:setAnchorPoint(cc.p(0, 0.5))
                label:setPosition(25 * gk.display.xScale(), bgHeight / 2)
            else
                local label = cell:getChildByTag(1)
                label:setString(str)
            end

            return cell
        end

        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
    end
end

return TableViewTest2