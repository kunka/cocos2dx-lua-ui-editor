--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/14/17
-- Time: 14:09
-- To change this template use File | Settings | File Templates.
--

local theme = {}

--- fonts
theme.font_ttf = "gk/res/font/Consolas.ttf" -- for editBox
theme.font_fnt = "gk/res/font/Consolas.fnt" -- for display

--- colors
theme.configs = {
    DRAK_GRAY = {
        backgroundColor = cc.c4b(71, 71, 71, 255),
    },
    LIGHT_WHITE = {
        backgroundColor = cc.c4b(242, 242, 242, 255),
    },
}
theme.themeName = cc.UserDefault:getInstance():getStringForKey("gk_themeName", "DRAK_GRAY")

function theme:setTheme(themeName)
    if self.themeName ~= themeName and self.configs[themeName] then
        self.themeName = themeName
        cc.UserDefault:getInstance():setStringForKey("gk_themeName", self.themeName)
        cc.UserDefault:getInstance():flush()
        gk.util:restartGame(gk.mode)
    end
end

function theme:getBackgroundColor()
    local config = self.configs[self.themeName]
    if not config then
        config = self.configs["DRAK_GRAY"]
    end
    return config.backgroundColor
end

return theme