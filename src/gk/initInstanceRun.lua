--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/30/17
-- Time: 16:14
-- To change this template use File | Settings | File Templates.
--

-- must init this in main.lua before require any other modules
initInstanceRun = function(platform, packageName)
    ANDROID_PACKAGE_NAME = packageName
    local path = "/sdcard/" .. packageName .. "/"
    print("android root = \"" .. path .. "\"")
    ANDROID_ROOT = path

    -- use local search path for restart instantly
    if platform == 2 then
        print("initInstanceRun on macos")
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        print("mac root = \"" .. path .. "\"")
        MAC_ROOT = path
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(path .. "src/")
        cc.FileUtils:getInstance():addSearchPath(path .. "res/")
        cc.FileUtils:getInstance():addSearchPath(path)
    elseif platform == 3 then
        print("initInstanceRun on android")
        --        local path = cc.FileUtils:getInstance():getWritablePath()
        local path = "/sdcard/" .. packageName .. "/"
        if not cc.FileUtils:getInstance():isDirectoryExist(path) then
            cc.FileUtils:getInstance():createDirectory(path)
        end
        print("android root = \"" .. path .. "\"")
        ANDROID_ROOT = path
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(path .. "src/")
        cc.FileUtils:getInstance():addSearchPath(path .. "res/")
        cc.FileUtils:getInstance():addSearchPath("src/")
        cc.FileUtils:getInstance():addSearchPath("res/")
        cc.FileUtils:getInstance():addSearchPath(path)
    end
end