--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/30/17
-- Time: 16:14
-- To change this template use File | Settings | File Templates.
--

local instanceRun = {}

-- must init this in main.lua before require any other modules
function instanceRun:init(platform, androidPackageName)
    androidPackageName = androidPackageName or ""
    local MAC_ROOT = ""
    local ANDROID_PACKAGE_NAME = androidPackageName
    local ANDROID_ROOT = "/sdcard/" .. androidPackageName .. "/"
    print("android root = \"" .. ANDROID_PACKAGE_NAME .. "\"")

    -- mac use local search path for restart instantly
    if platform == 2 then
        print("initInstanceRun on macos???")
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        MAC_ROOT = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        print("mac root = \"" .. MAC_ROOT .. "\"")
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(MAC_ROOT .. "src/")
        cc.FileUtils:getInstance():addSearchPath(MAC_ROOT .. "res/")
        cc.FileUtils:getInstance():addSearchPath(MAC_ROOT)
    elseif platform == 3 and androidPackageName ~= "" then
        print("initInstanceRun on android")
        if not cc.FileUtils:getInstance():isDirectoryExist(ANDROID_PACKAGE_NAME) then
            cc.FileUtils:getInstance():createDirectory(ANDROID_PACKAGE_NAME)
        end
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(ANDROID_PACKAGE_NAME .. "src/")
        cc.FileUtils:getInstance():addSearchPath(ANDROID_PACKAGE_NAME .. "res/")
        cc.FileUtils:getInstance():addSearchPath("src/")
        cc.FileUtils:getInstance():addSearchPath("res/")
        cc.FileUtils:getInstance():addSearchPath(ANDROID_PACKAGE_NAME)
    end

    return MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME
end

return instanceRun