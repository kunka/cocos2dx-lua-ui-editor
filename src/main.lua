if jit and jit.status() then
    -- turn jit off, use interpreter mode, that's faster on Android
    jit.off()
    jit.flush()
end
print("main(main.lua gk/hotUpdate.lua gk/instanceRun version.lua cannot be reloaded when running!)")

-- init default search path
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)
-- keep orign package path
local orignPackagePath = package.path

local function clearModules()
    print("clearModules")
    local __g = _G
    setmetatable(__g, {})

    package.path = orignPackagePath

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
        ["lfs"] = true,
        ["main"] = true,
        ["gk.instanceRun"] = true,
        ["version"] = true,
    }

    for p, _ in pairs(package.loaded) do
        if not whitelist[p] then
            print (p)
            package.loaded[p] = nil
        end
    end
end

print(string.format("package.path = \"%s\"", package.path))
local searchPath = cc.FileUtils:getInstance():getSearchPaths()
print("app search paths:")
for _, v in ipairs(searchPath) do
    print(string.format("searchPath:\"%s\"", v))
end

local function initInstanceRun(android_package_name)
    local instanceRun = require("gk.instanceRun")
    instanceRun:init(android_package_name)
end

local function initHotUpdate()
    local hotUpdate = require("gk.hotUpdate")
    local codeVersion = require("version")
    hotUpdate:init(codeVersion)
end

local function startGame(mode)
    return require("init"):startGame(mode)
end

-- will be called in some other place to restart game
function restartGame(mode)
    print("restartGame")
    clearModules()
    startGame(mode)
end

-- 0: release mode
-- 1: edit mode
if cc.Application:getInstance():getTargetPlatform() == 2 then
    --- mac default run with edit mode with instance run enabled
    initInstanceRun() -- instance run on Mac, with ui editor
    startGame(1)
    -- initHotUpdate() -- enable hot update on Mac
    -- startGame(0)
else
    -- initInstanceRun("com.demo.gk) -- instance run on Android, disabled this before publish
    initHotUpdate() -- enable hot update on Android
    startGame(0)
end
