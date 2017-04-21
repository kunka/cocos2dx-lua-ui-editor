print("main(notice:only main.lua cannot be reloaded when running!)")

-- init default search path
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)

-- use local search path for restart instantly
local function nativeHotUpdateInit(platform)
    if platform == 2 then
        print("nativeHotUpdateInit on macos")
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        print("mac project root = \"" .. path .. "\"")
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(path .. "src/")
        cc.FileUtils:getInstance():addSearchPath(path .. "res/")
        local searchPath = cc.FileUtils:getInstance():getSearchPaths()
        print("mac app search paths:")
        for _, v in ipairs(searchPath) do
            print("searchPath:\"" .. v .. "\"")
        end
    end
end

local function clearModules()
    print("clearModules")
    local __g = _G
    setmetatable(__g, {})

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

local function getAppEntry()
    return require("init")
end

function restartGame(mode)
    print("restartGame")
    clearModules()
    getAppEntry():startGame(mode)
end

local platform = cc.Application:getInstance():getTargetPlatform()
if platform == 2 then
    nativeHotUpdateInit(platform)
    getAppEntry():startGame(1)
else
    getAppEntry():startGame(0)
end

