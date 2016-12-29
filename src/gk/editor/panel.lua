local panel = {}

function panel:create()
    local winSize = cc.Director:getInstance():getWinSize()
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 100, 100), winSize.width / 4, winSize.height)
    layerColor:setPosition(winSize.width * 3 / 4, 0)
    return layerColor
end

return panel