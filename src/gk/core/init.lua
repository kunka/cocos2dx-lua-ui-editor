--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 16/12/29
-- Time: 上午10:12
-- To change this template use File | Settings | File Templates.

import(".List")
import(".log")
gk.event = import(".event")
gk.event:init()
gk.audio = import(".audio")
gk.audio:init()
gk.injector = import(".injector")
gk.injector:init()
gk.display = import(".display")
gk.generator = import(".generator")

----------------------------------- runtime version for mac editor --------------------------------------------

if cc.Application:getInstance():getTargetPlatform() ~= 2 then
    -- runtime version is valid only on mac and edit mode
    gk.runtimeVersion = ""
end

-- xx.xx.xx.xx
gk.getRuntimeVersion = function()
    if gk.runtimeVersion then
        return gk.runtimeVersion
    end
    local version
    if cc.Application:getInstance():getTargetPlatform() == 2 then
        local path = cc.FileUtils:getInstance():fullPathForFilename("gk/core/runtimeversion.lua")
        if path and path ~= "" then
            package.loaded[path] = nil
            local status, result = pcall(require, path)
            if status then
                gk.runtimeVersion = result.version
                return result.version
            else
                local table2lua = require("gk.tools.table2lua")
                if not gk.errorOccurs then
                    io.writefile(path, table2lua.encode_pretty({ version }))
                end
            end
        else
            local path = cc.FileUtils:getInstance():fullPathForFilename("gk/core/init.lua")
            local pos = string.find(path, "/init.lua")
            if pos then
                path = path:sub(1, pos - 1) .. "/runtimeversion.lua"
                local table2lua = require("gk.tools.table2lua")
                if not gk.errorOccurs then
                    io.writefile(path, table2lua.encode_pretty({ version = "0.0.0.0" }))
                end
            end
        end
    end
    return "0.0.0.0"
end

gk.increaseRuntimeVersion = function()
    if cc.Application:getInstance():getTargetPlatform() == 2 then
        local version = gk:getRuntimeVersion()
        local vs = string.split(version, ".")
        vs[#vs] = tostring(tonumber(vs[#vs]) + 1)
        version = table.concat(vs, ".")
        gk.runtimeVersion = version
        local table2lua = require("gk.tools.table2lua")
        if not gk.errorOccurs then
            local path = cc.FileUtils:getInstance():fullPathForFilename("gk/core/runtimeversion.lua")
            io.writefile(path, table2lua.encode_pretty({ version = version }))
        end
    end
end