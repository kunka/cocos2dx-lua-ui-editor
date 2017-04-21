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
        local data = self:getData()

        local popTopMargin = 18 * gk.display.minScale()
        local popBottomMargin = 12 * gk.display.minScale()
        local textLeftMargin = 45 * gk.display.minScale()
        local textRightMargin = 30 * gk.display.minScale()
        local textTopMargin = 25 * gk.display.minScale()
        local textBottomMargin = 25 * gk.display.minScale()
        local timeMarginH = 10 * gk.display.minScale()
        local timeMarginV = 8 * gk.display.minScale()

        -- size model
        local cell = gk.injector:inflateNode("test/TableCell1")
        local function numberOfCellsInTableView(table)
            return #data
        end

        local function cellSizeForTable(table, idx)
            local dt = data[idx + 1]
            if not dt.labelHeight then
                if dt.type == "Member" then
                    if cell.label_left then
                        cell.label_left:setString(dt.content)
                        dt.height = popTopMargin + popBottomMargin + textTopMargin + textBottomMargin + cell.label_left:getContentSize().height * gk.display.minScale()
                    end
                elseif dt.type == "Me" then
                    if cell.label_right then
                        cell.label_right:setString(dt.content)
                        dt.height = popTopMargin + popBottomMargin + textTopMargin + textBottomMargin + cell.label_right:getContentSize().height * gk.display.minScale()
                    end
                elseif dt.type == "Time" then
                    if cell.desc then
                        cell.desc:setString(dt.content)
                        dt.height = timeMarginV * 2 + cell.desc:getContentSize().height * gk.display.minScale()
                    end
                end
            end
            return gk.display.winSize().width, dt.height
        end

        local function tableCellAtIndex(table, idx)
            local dt = data[idx + 1]
            local cell = table:dequeueCell()
            if nil == cell then
                --                gk.log("tableCellAtIndex idx = %d, create new", idx)
                cell = gk.injector:inflateNode("test/TableCell1")
            else
                --                gk.log("tableCellAtIndex idx = %d, reuse", idx)
            end
            if cell then
                cell["Member"]:setVisible(false)
                cell["Me"]:setVisible(false)
                cell["Time"]:setVisible(false)
                cell[dt.type]:setVisible(true)
                if dt.type == "Member" then
                    if cell.label_left then
                        cell.label_left:setString(dt.content)
                        local pos = cc.p(cell.label_left:getPosition())
                        cell.label_left:setPosition(cc.p(pos.x, dt.height - popTopMargin - textTopMargin))
                        local pos = cc.p(cell.avatar_left:getPosition())
                        cell.avatar_left:setPosition(cc.p(pos.x, dt.height - popTopMargin))

                        local size = cell.label_left:getContentSize()
                        cell.pop_left:setContentSize(size.width + (textLeftMargin + textRightMargin) / gk.display.minScale(), size.height - popTopMargin +
                                (textTopMargin + textBottomMargin) / gk.display.minScale()) --60
                        --                        gk.util:drawNode(cell.pop_left)
                        --                        gk.util:drawNodeBounds(cell.label_left)
                        local pos = cc.p(cell.pop_left:getPosition())
                        cell.pop_left:setPosition(cc.p(pos.x, dt.height - popTopMargin))
                    end
                elseif dt.type == "Me" then
                    if cell.label_right then
                        cell.label_right:setString(dt.content)
                        local pos = cc.p(cell.avatar_right:getPosition())
                        cell.avatar_right:setPosition(cc.p(pos.x, dt.height - popTopMargin))

                        local size = cell.label_right:getContentSize()
                        cell.pop_right:setContentSize(size.width + (textLeftMargin + textRightMargin) / gk.display.minScale(), size.height -
                                popTopMargin +
                                (textTopMargin + textBottomMargin) / gk.display.minScale())
                        --                        gk.util:drawNode(cell.avatar_right)
                        --                        gk.util:drawNodeBounds(cell.label_right)
                        local pos = cc.p(cell.pop_right:getPosition())
                        cell.pop_right:setPosition(cc.p(pos.x, dt.height - popTopMargin))

                        cell.label_right:setPosition(cc.p(pos.x - size.width * gk.display.minScale() - textLeftMargin, dt.height - popTopMargin - textTopMargin))
                    end
                elseif dt.type == "Time" then
                    if cell.desc then
                        cell.desc:setString(dt.content)
                        local pos = cc.p(cell.desc:getPosition())
                        cell.desc:setPosition(cc.p(pos.x, dt.height / 2))
                        local size = cell.desc:getContentSize()
                        --                        gk.util:drawNodeBounds(cell.desc)
                        cell.bg_time:setContentSize(size.width + (timeMarginH * 2) / gk.display.minScale(), size.height + timeMarginV * 2 / gk.display.minScale())
                        cell.bg_time:setPosition(cc.p(pos.x, dt.height / 2))
                    end
                end
            end
            return cell
        end

        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:reloadData()
    end
end

function TableViewTest1:getData()
    return {
        { type = "Time", content = "00:00 AM" },
        { type = "Member", content = "DDFNN bBBDsfsdfn lsdfsn,Dsfsdfn lsdfsn,, Dsfsdfn lsdfsn,vnxc,nn,, Dsfsdfn lsdfsn,vnxc,nn,, Dsfsdfn lsdfsn,vnxc,nvoisefn,cvnxckv ::>" },
        { type = "Time", content = "10:00 AM" },
        { type = "Me", content = "Er, Er" },
        { type = "Member", content = "Fei nlla c" },
        { type = "Time", content = "11:30 AM" },
        { type = "Me", content = "?" },
        { type = "Me", content = "Er, XX.... elnsndf sd lsdfsn,Dsfsdfn lsdfsn,, Dsf, lsdfsn,Dsfsdfn lsdfsn,, Dsffc :)!" },
        { type = "Member", content = "FFee exxxxx" },
        { type = "Time", content = "Your message could not be sent due to local laws, regulations, and politicies." },
        { type = "Me", content = "Er, Er????" },
        { type = "Member", content = "Dig sd ??????" },
        { type = "Time", content = "1:30 PM" },
        { type = "Me", content = "Er2, Er2" },
        { type = "Me", content = "Er, Er!!!!NNNNN WEE !!!" },
        { type = "Member", content = "Er, Er!!!!NNNNN WEE !!!" },
        { type = "Member", content = "Egexxxxx" },
        { type = "Time", content = "13:12" },
        { type = "Me", content = "Er, Er????" },
        { type = "Member", content = "Live ??????" },
        { type = "Time", content = "11:30" },

        { type = "Member", content = "DDFNN bBBDsfsdfn lsdfsn,Dsfsdfn lsdfsn,, Dsfsdfn lsdfsn,vnxc,nn,, Dsfsdfn lsdfsn,vnxc,nn,, Dsfsdfn lsdfsn,vnxc,nvoisefn,cvnxckv ::>" },
        { type = "Time", content = "10:00 AM" },
        { type = "Me", content = "Er, Er" },
        { type = "Member", content = "Fei nlla c" },
        { type = "Time", content = "11:30 AM" },
        { type = "Me", content = "?" },
        { type = "Me", content = "Er, XX.... elnsndf sd lsdfsn,Dsfsdfn lsdfsn,, Dsf, lsdfsn,Dsfsdfn lsdfsn,, Dsffc :)!" },
        { type = "Member", content = "FFee exxxxx" },
        { type = "Time", content = "Your message could not be sent due to local laws, regulations, and politicies." },
        { type = "Me", content = "Er, Er????" },
        { type = "Member", content = "Dig sd ??????" },
        { type = "Time", content = "1:30 PM" },
        { type = "Me", content = "Er2, Er2" },
        { type = "Me", content = "Er, Er!!!!NNNNN WEE !!!" },
        { type = "Member", content = "Er, Er!!!!NNNNN WEE !!!" },
        { type = "Member", content = "Egexxxxx" },
        { type = "Time", content = "13:12" },
        { type = "Me", content = "Er, Er????" },
        { type = "Member", content = "Live ??????" },
        { type = "Time", content = "11:30" },
    }
end

return TableViewTest1