--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/30/17
-- Time: 16:14
-- To change this template use File | Settings | File Templates.
--

-- instance run on Mac or Android platform
local instanceRun = {}

-- must init this in main.lua before require any other modules
function instanceRun:init(androidPackageName)
    androidPackageName = androidPackageName or ""
    local MAC_ROOT = ""
    local ANDROID_PACKAGE_NAME = androidPackageName
    local ANDROID_ROOT = "/sdcard/" .. androidPackageName .. "/"

    local platform = cc.Application:getInstance():getTargetPlatform()
    -- mac use local search path for restart instantly
    if platform == 2 then
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        MAC_ROOT = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        print(string.format("initInstanceRun on Mac, MAC_ROOT = \"%s\"", MAC_ROOT))
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(MAC_ROOT .. "src/")
        cc.FileUtils:getInstance():addSearchPath(MAC_ROOT .. "res/")
        cc.FileUtils:getInstance():addSearchPath(MAC_ROOT)
    elseif platform == 3 and androidPackageName ~= "" then
        print(string.format("Android package name  = \"%s\"", ANDROID_PACKAGE_NAME))
        print(string.format("initInstanceRun on Android, ANDROID_ROOT = \"%s\"", ANDROID_ROOT))
        if not cc.FileUtils:getInstance():isDirectoryExist(ANDROID_PACKAGE_NAME) then
            cc.FileUtils:getInstance():createDirectory(ANDROID_PACKAGE_NAME)
        end
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(ANDROID_ROOT .. "src/")
        cc.FileUtils:getInstance():addSearchPath(ANDROID_ROOT .. "res/")
        cc.FileUtils:getInstance():addSearchPath(ANDROID_ROOT)
        cc.FileUtils:getInstance():addSearchPath("src/")
        cc.FileUtils:getInstance():addSearchPath("res/")
    end

    self.MAC_ROOT = MAC_ROOT
    self.ANDROID_ROOT = ANDROID_ROOT
    self.ANDROID_PACKAGE_NAME = ANDROID_PACKAGE_NAME
end

return instanceRun