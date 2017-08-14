--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/31/17
-- Time: 14:04
-- To change this template use File | Settings | File Templates.
--

local hotUpdate = {}

-- must init this in main.lua before require any other modules
function hotUpdate:init(originVersion)
    local DOC_ROOT = cc.FileUtils:getInstance():getWritablePath()

    local curVersion = cc.UserDefault:getInstance():getStringForKey("gk_curVersion")
    if curVersion == "" then
        curVersion = originVersion
    else
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

        local origin = split(originVersion, ".")
        local current = split(curVersion, ".")
        if #origin ~= #current then
            curVersion = originVersion
        else
            for i = 1, #origin do
                if tonumber(current[i]) > tonumber(origin[i]) then
                    print(string.format("curVersion = %s is big than originVersion = %s, use new", curVersion, originVersion))
                    break
                elseif tonumber(current[i]) < tonumber(origin[i]) then
                    -- big version, remove old files
                    print(string.format("big version = %s, remove old version = %s", originVersion, curVersion))
                    self:removeOldVersion(curVersion)
                    curVersion = originVersion
                    cc.UserDefault:getInstance():setStringForKey("gk_curVersion", curVersion)
                    cc.UserDefault:getInstance():flush()
                    break
                end
            end
        end
    end
    if not cc.FileUtils:getInstance():isDirectoryExist(DOC_ROOT .. curVersion) then
        -- not exist
        print(string.format("new version dir not exist = %s, need redownload hotupdate", DOC_ROOT .. curVersion))
        cc.UserDefault:getInstance():setStringForKey("gk_curVersion", originVersion)
        cc.UserDefault:getInstance():flush()
        return
    end
    cc.UserDefault:getInstance():setStringForKey("gk_curVersion", curVersion)
    cc.UserDefault:getInstance():flush()
    if curVersion == originVersion then
        -- equal
        print(string.format("same version = %s, no hotupdate", curVersion))
        return
    end

    cc.FileUtils:getInstance():setSearchPaths({})
    cc.FileUtils:getInstance():addSearchPath(DOC_ROOT .. curVersion .. "/src/")
    cc.FileUtils:getInstance():addSearchPath(DOC_ROOT .. curVersion .. "/res/")
    cc.FileUtils:getInstance():addSearchPath("src/")
    cc.FileUtils:getInstance():addSearchPath("res/")
    return DOC_ROOT
end

function hotUpdate:removeOldVersion(oldVersion)
    local DOC_ROOT = cc.FileUtils:getInstance():getWritablePath()
    print("removeOldVersion = " .. DOC_ROOT .. oldVersion)
    cc.FileUtils:getInstance():removeDirectory(DOC_ROOT .. oldVersion)
end

function hotUpdate:updateToNewVersion(newVersion)
    print(string.format("update newVersion = %s", newVersion))
    cc.UserDefault:getInstance():setStringForKey("gk_curVersion", newVersion)
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
    cc.UserDefault:getInstance():setStringForKey("gk_curVersion", "")
    cc.UserDefault:getInstance():flush()
    cc.FileUtils:getInstance():setSearchPaths({})
    cc.FileUtils:getInstance():addSearchPath("src/")
    cc.FileUtils:getInstance():addSearchPath("res/")
end

return hotUpdate