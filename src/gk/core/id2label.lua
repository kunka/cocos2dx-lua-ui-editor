--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

local id2label = {}

local function create_label(info)
    if info.labelType == "ttf" then
    elseif info.labelType == "bmfont" then
    else
        info.labelType = "systemfont"
    end
    dump(info)
    local lan = gk.resource:getLan()
    local label = cc.Label:createWithTTF(info.string, info.fontFile[lan], info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc
    .VERTICAL_TEXT_ALIGNMENT_CENTER)
    --    local label = cc.Label:createWithSystemFont(info.string, info.fontFile, info.fontSize, cc.size(0, 0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    return label
end

gk.create_label = create_label

return id2label