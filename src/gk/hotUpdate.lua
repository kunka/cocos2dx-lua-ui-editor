--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/31/17
-- Time: 14:04
-- To change this template use File | Settings | File Templates.
--

local hotUpdate = {}

-- this file cannot be hot updated
-- must init this in main.lua before require any other modules
-- use for instance run on mac, or hot update on other platform
function hotUpdate:init(originVersion)
    local DOC_ROOT = cc.FileUtils:getInstance():getWritablePath()

    local curVersion = cc.UserDefault:getInstance():getStringForKey("gk_currentVersion")
    if curVersion == "" then
        curVersion = originVersion
    end
    local ret = self:compareVersion(curVersion, originVersion)
    if ret == 1 then
        -- current is bigger than origin, use hot update
        print(string.format("curVersion = %s is big than originVersion = %s, use hot update", curVersion, originVersion))
        if not cc.FileUtils:getInstance():isDirectoryExist(DOC_ROOT .. curVersion .. "/") then
            print(string.format("hot update dir not exist = %s, need redownload hotupdate", DOC_ROOT .. curVersion .. "/"))
            cc.UserDefault:getInstance():setStringForKey("gk_currentVersion", originVersion)
            cc.UserDefault:getInstance():flush()
        else
            -- hot update search path
            cc.FileUtils:getInstance():setSearchPaths({})
            cc.FileUtils:getInstance():addSearchPath(DOC_ROOT .. curVersion .. "/src/")
            cc.FileUtils:getInstance():addSearchPath(DOC_ROOT .. curVersion .. "/res/")
            cc.FileUtils:getInstance():addSearchPath("src/")
            cc.FileUtils:getInstance():addSearchPath("res/")
        end
    elseif ret == -1 then
        -- big version, remove old files
        print(string.format("big version = %s, remove old version = %s", originVersion, curVersion))
        self:removeOldVersion(curVersion)
        cc.UserDefault:getInstance():setStringForKey("gk_currentVersion", originVersion)
        cc.UserDefault:getInstance():flush()
    else
        -- equal, do nothing
        print(string.format("same version = %s, no hotupdate", curVersion))
        cc.UserDefault:getInstance():setStringForKey("gk_currentVersion", curVersion)
        cc.UserDefault:getInstance():flush()
    end
end

-- return 1:version1 > version2
-- return 0:version1 == version2
-- return -1:version1 < version2
function hotUpdate:compareVersion(version1, version2)
    if version1 == version2 then
        return 0
    end
    local function split(input, delimiter)
        input = tostring(input)
        delimiter = tostring(delimiter)
        if (delimiter == '') then return false end
        local pos, arr = 0, {}
        -- for each divider found
        for st, sp in function() return string.find(input, delimiter, pos, true) end do
            table.insert(arr, string.sub(input, pos, st - 1))
            pos = sp + 1
        end
        table.insert(arr, string.sub(input, pos))
        return arr
    end

    local v1 = split(version1, ".")
    local v2 = split(version2, ".")
    local len = math.min(#v1, #v2)
    for i = 1, len do
        if tonumber(v1[i]) > tonumber(v2[i]) then
            return 1
        elseif tonumber(v1[i]) < tonumber(v2[i]) then
            return -1
        end
    end
    if #v1 == #v2 then
        return 0
    else
        return #v1 > #v2 and 1 or -1
    end
end

function hotUpdate:removeOldVersion(oldVersion)
    if oldVersion ~= "" then
        local DOC_ROOT = cc.FileUtils:getInstance():getWritablePath()
        local dir = DOC_ROOT .. oldVersion .. "/"
        print("removeOldVersion = " .. dir)
        cc.FileUtils:getInstance():removeDirectory(dir)
    end
end

function hotUpdate:updateToNewVersion(newVersion)
    print(string.format("update to newVersion = %s", newVersion))
    cc.UserDefault:getInstance():setStringForKey("gk_currentVersion", newVersion)
    cc.UserDefault:getInstance():flush()
    local DOC_ROOT = cc.FileUtils:getInstance():getWritablePath()
    cc.FileUtils:getInstance():setSearchPaths({})
    cc.FileUtils:getInstance():addSearchPath(DOC_ROOT .. newVersion .. "/src/")
    cc.FileUtils:getInstance():addSearchPath(DOC_ROOT .. newVersion .. "/res/")
    cc.FileUtils:getInstance():addSearchPath("src/")
    cc.FileUtils:getInstance():addSearchPath("res/")
end

function hotUpdate:reset()
    print(string.format("hotUpdate reset"))
    cc.UserDefault:getInstance():setStringForKey("gk_currentVersion", "")
    cc.UserDefault:getInstance():flush()
    cc.FileUtils:getInstance():setSearchPaths({})
    cc.FileUtils:getInstance():addSearchPath("src/")
    cc.FileUtils:getInstance():addSearchPath("res/")
end

return hotUpdate