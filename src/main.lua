if jit and jit.status() then
    -- turn jit off, use interpreter mode, that's faster on Android
    jit.off()
    jit.flush()
end
print("main(notice:main.lua gk/hotUpdate.lua version.lua cannot be reloaded when running!)")

-- init default search path
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)
-- keep orign package path
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
print(package.path)
local searchPath = cc.FileUtils:getInstance():getSearchPaths()
print("app search paths:")
for _, v in ipairs(searchPath) do
    print("searchPath:\"" .. v .. "\"")
end

local platform = cc.Application:getInstance():getTargetPlatform()

local MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME
function initInstanceRun()
    local android_package_name = "com.demo.gk"
    local instanceRun = require("gk.instanceRun")
    MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME = instanceRun:init(platform, android_package_name)
end

function initHotUpdate()
    local hotUpdate = require("gk.hotUpdate")
    local codeVersion = require("version")
    hotUpdate:init(codeVersion)
end

function startGame(mode)
    return require("init"):startGame(mode, MAC_ROOT, ANDROID_ROOT, ANDROID_PACKAGE_NAME)
end

function restartGame(mode)
    print("restartGame")
    clearModules()
    if platform == 2 then
        startGame(mode)
    else
        startGame(0)
    end
end

-- 0: release mode
-- 1: edit mode
if platform == 2 then
    --- mac default run with edit mode with instance run enabled
    initInstanceRun()
    startGame(1)
    -- initHotUpdate()
    -- startGame(0)
else
    -- initInstanceRun() -- instance run on Android, disabled this before publish
    initHotUpdate()
    startGame(0)
end
