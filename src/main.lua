print("main(notice:only main.lua cannot be reloaded when running!)")

-- init default search path
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)
local orignPackage = package.path

local function clearModules()
    print("clearModules")
    local __g = _G
    setmetatable(__g, {})

    package.path = orignPackage

    local whitelist = {
        ["string"] = true,
        ["io"] = true,
        ["pb"] = true,
        ["bit"] = true,
        ["os"] = true,
        ["debug"] = true,
        ["table"] = true,
        ["math"] = true,
        ["package"] = true,
        ["coroutine"] = true,
        ["pack"] = true,
        ["jit"] = true,
        ["jit.util"] = true,
        ["jit.opt"] = true,
        ["main"] = true,
        ["lfs"] = true,
    }

    for p, _ in pairs(package.loaded) do
        if not whitelist[p] then
            package.loaded[p] = nil
        end
    end
end

-- if don't need instance-run on Android, set it to nil
local android_package_name = "com.gk.demo"
local instanceRun = require("gk.instanceRun")
local platform = cc.Application:getInstance():getTargetPlatform()
local MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME = instanceRun:init(platform, android_package_name)

function startGame(mode)
    return require("init"):startGame(mode, MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME)
end

function restartGame(mode)
    print("restartGame")
    clearModules()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == 2 then
        startGame(mode)
    else
        startGame(0)
    end
end

-- 0: release mode
-- 1: edit mode
local platform = cc.Application:getInstance():getTargetPlatform()
if platform == 2 then
    --mac
    startGame(1)
else
    startGame(0)
end