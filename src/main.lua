print("main")

-- init default search path
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)

local function nativeHotUpdateInit()
    print("nativeHotUpdateInit")
    local app = cc.Application:getInstance()
    local target = app:getTargetPlatform()
    if target == 2 then
        -- mac app use local search path for restart instantly
        local path = cc.FileUtils:getInstance():fullPathForFilename("src/main.lua")
        path = string.sub(path, 1, string.find(path, "runtime/mac") - 1)
        print("mac project path = " .. path)
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(path .. "src/")
        cc.FileUtils:getInstance():addSearchPath(path .. "res/")
        local searchPath = cc.FileUtils:getInstance():getSearchPaths()
        print("mac search path:")
        for i, v in ipairs(searchPath) do
            print(v)
        end
    end
end

local function clearModules()
    print("clearModules")
    local __g = _G
    setmetatable(__g, {})

    -- 白名单 main是无法重新加载的，也无法加载
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

function restartGame()
    print("restartGame")
    clearModules()
    require("init").startGame()
end

nativeHotUpdateInit()
require("init").startGame()

