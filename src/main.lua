print("main")

--初始化搜索路径
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():setPopupNotify(false)

local function nativeHotUpdateInit()
    print("nativeHotUpdateInit")
    local app = cc.Application:getInstance()
    local target = app:getTargetPlatform()
    if target == 2 then
        -- mac 使用本地资源路径
        local filepath = "../../../../../"
        cc.FileUtils:getInstance():setSearchPaths({})
        cc.FileUtils:getInstance():addSearchPath(filepath .. "src/")
        cc.FileUtils:getInstance():addSearchPath(filepath .. "res/")
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

