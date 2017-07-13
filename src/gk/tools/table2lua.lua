--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/11
-- Time: 上午10:10
-- To change this template use File | Settings | File Templates.
--

local LuaTable = {
    _VERSION = 'LuaTable v1.0.1 2016/08/27',
    _AUTHOR = 'RamiLego4Game',
    _URL = 'https://gist.github.com/RamiLego4Game/f656f5c1a118f77c3b7a08f4c65efaaf',
    _DESCRIPTION = 'A library that converts tables to Lua code that can be saved',
    _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2016 Rami Sabbagh

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

--[[A library that converts tables to Lua code that can be saved.
Since it uses Lua to save the data, It's able to save functions ! by dumping them, But they won't be readable, only loadable, unless if you decompile them.
And moreover you can do some hand written tables with smart data generation..
The bad thing that it's less secure (you are running code) .., So load the files using this Library to sandbox the files

usage:
luacode (string) = LuaTable.encode(<variable>,[funcBehave],[standalone])
luacode (string) = LuaTable.encode_pretty(<variable>,[funcBehave],[standalone])
variable = LuaTable.decode(<luacode>,[smart])

  variable (list above):
  Supported types: nil,boolean,string,number,table,function,userdata

  funcBehave (string or nil):
  "dump" to dump the functions so they can be loaded again, But not recomended.
  "name" to use tostring on the function, I guess it's useless, unless if it's used to debug something like the _G var.
  "skip" (default) to skip the functions and not include them in the table.

  standalone (boolean or nil):
  If this is true, the result code will include a function called c (short for combine) used to combine arrays with tables (to save file lenght).
  Enable this to make the result code run without using this library.

  luacode (string):
  The code made with LuaTable library.

  smart (boolean or nil):
  To give the table code the access to some usefull gloabl libraries (like math, string, ..[list above]).

example:
  local LuaTable = require("LuaTable")
  love.filesystem.write("TestTable.lua",LuaTable.encode({test=true}))
  local TableCode = love.filesystem.read("TestTable.lua")
  local TabelData = LuaTable.decode(TableCode)

list of available global vars for the table (Changable down):
  Normal: pairs, ipairs, c (combine function)
  Smart: pairs, ipairs, string, table, bit, math, c (combine function), love.math (if library is used in love with love.math enabled)

note: all Userdata variables can't be dumped so they will be ignored.
]]

--[[Changelog:

2016/08/07 V1.0.1: All Credit goes to ivan [In Love2D forums] for this update
1. Fixed a problem in LuaTable.isArray that causes arrays with gaps to encode as normal table.
2. Improved LuaTable.encode_string to use string.format instead of multiline string.

2016/08/26 V1.0.0: First Public Release

]]

local function combine(t1, t2) for k, v in pairs(t2) do t1[k] = v end return t1 end

--Config--
local prettyTabbing = "\t"

--Change the global vars here--
local normalGVars = { pairs = pairs, ipairs = ipairs, c = combine } --Used when smart argument is false or nil
local smartGVars = { pairs = pairs, ipairs = ipairs, string = string, table = table, bit = bit, math = math, c = combine } --Used when smart argument is true
if love and love.math then smartGVars.love = { math = love.math } end

--Library code starts here--

function LuaTable.encode(var, funcBehave, standalone)
    if not (type(funcBehave) == "string" or type(funcBehave) == "nil") then return error("Bad argument #2 to 'LuaTable.encode' (string/nil expected, got" .. type(funcBehave) .. ")") end
    if not (type(standalone) == "boolean" or type(standalone) == "nil") then return error("Bad argument #3 to 'LuaTable.encode' (boolean/nil expected, got" .. type(funcBehave) .. ")") end
    local code = "return "
    if standalone then code = "local function c(t1,t2) for k,v in pairs(t2) do t1[k] = v end return t1 end\n" .. code end
    local vx = "nil" if LuaTable["encode_" .. type(var)] then vx = LuaTable["encode_" .. type(var)](var) else print("[LuaTable] Warning, LuaTable doesn't support " .. type(var)) end
    code = code .. vx
    return code
end

function LuaTable.encode_pretty(var, funcBehave, standalone)
    if not (type(funcBehave) == "string" or type(funcBehave) == "nil") then return error("Bad argument #2 to 'LuaTable.encode_pretty' (string/nil expected, got" .. type(funcBehave) .. ")") end
    if not (type(standalone) == "boolean" or type(standalone) == "nil") then return error("Bad argument #3 to 'LuaTable.encode_pretty' (boolean/nil expected, got" .. type(funcBehave) .. ")") end
    local code = "return "
    if standalone then code = "local function c(t1,t2)\n   for k,v in pairs(t2) do\n      t1[k] = v\n   end\n   return t1\nend\n\n" .. code end
    local vx = "nil" if LuaTable["encode_" .. type(var)] then vx = LuaTable["encode_" .. type(var)](var, prettyTabbing, funcBehave) else print("[LuaTable] Warning, LuaTable doesn't support " .. type(var)) end
    code = code .. vx
    return code
end

function LuaTable.decode(codeString, smart)
    if not (type(codeString) == "string") then return error("Bad argument #1 to 'LuaTable.decode' (string expected, got" .. type(codeString) .. ")") end
    if not (type(smart) == "boolean" or type(smart) == "nil") then return error("Bad argument #2 to 'LuaTable.decode' (boolean/nil expected, got" .. type(smart) .. ")") end
    local function combine(t1, t2) for k, v in pairs(t2) do t1[k] = v end return t1 end

    local codeFunc = loadstring(code)
    if smart then setfenv(codeFunc, smartGVars) else setfenv(codeFunc, normalGVars) end
    return codeFunc()
end

function LuaTable.isArray(tabl)
    local n = 0
    for _ in pairs(tabl) do
        n = n + 1
    end
    return #tabl == n
end

--[[Here you can add your own variable types.
Array is a numeric table.]]

function LuaTable.encode_array(table, pretty, funcBehave)
    local s = "{"
    for i = 1, #table do
        if pretty then
            local vx = "nil" if LuaTable["encode_" .. type(table[i])] then vx = LuaTable["encode_" .. type(table[i])](table[i], pretty .. "   ", funcBehave) else print("[LuaTable] Warning, LuaTable doesn't support " .. type(var)) end
            if i == 1 then
                s = s .. pretty .. vx
            else
                s = s .. ",\n" .. pretty .. vx
            end
        else
            local vx = "nil" if LuaTable["encode_" .. type(table[i])] then vx = LuaTable["encode_" .. type(table[i])](table[i], nil, funcBehave) else print("[LuaTable] Warning, LuaTable doesn't support " .. type(var)) end
            if i == 1 then
                s = s .. vx
            else
                s = s .. "," .. vx
            end
        end
    end
    return s .. "}"
end

function LuaTable.encode_table(tbl, pretty, funcBehave)
    if LuaTable.isArray(tbl) then return LuaTable.encode_array(tbl, pretty) end
    local nums, first = {}, true
    local s = "{"
    local keys = {}
    for k, v in pairs(tbl) do
        keys[#keys + 1] = k
    end
    if pretty then
        -- sort table
        table.sort(keys, function(k1, k2)
            local t1, t2 = type(tbl[k1]) == "table", type(tbl[k2]) == "table"
            if (t1 and t2) then
                return #tbl[k1] < #tbl[k2] or (#tbl[k1] == #tbl[k2] and k1 < k2)
            elseif (not t1 and not t2) then
                return k1 < k2
            else
                return t2
            end
        end)
    end
    for _, k in ipairs(keys) do
        local v = tbl[k]
        --        for k,v in pairs(table) do
        local key = tostring(k)
        if key:find("/") or key:find("%.") then
            key = "[\"" .. key .. "\"]"
        end
        if pretty then
            local vx = "nil" if LuaTable["encode_" .. type(v)] then vx = LuaTable["encode_" .. type(v)](v, pretty .. "   ", funcBehave) else print("[LuaTable] Warning, LuaTable doesn't support " .. type(var)) end
            if type(k) == "number" then
                nums[k] = v
            elseif first then
                s = s .. "\n" .. pretty .. key .. " = " .. vx
                first = false
            else
                s = s .. ",\n" .. pretty .. key .. " = " .. vx
            end
        else
            local vx = "nil" if LuaTable["encode_" .. type(v)] then vx = LuaTable["encode_" .. type(v)](v, nil, funcBehave) else print("[LuaTable] Warning, LuaTable doesn't support " .. type(var)) end
            if type(k) == "number" then
                nums[k] = v
            elseif first then
                s = s .. key .. "=" .. vx
                first = false
            else
                s = s .. "," .. key .. "=" .. vx
            end
        end
    end
    if #nums > 0 then
        if pretty then
            s = "c(" .. s .. "}," .. LuaTable.encode_array(nums, pretty .. "   ") .. ")"
        else
            s = "c(" .. s .. "}," .. LuaTable.encode_array(nums) .. ")"
        end
    else
        s = s .. "}"
    end
    return s
end

function LuaTable.encode_function(func, pretty, funcBehave)
    local fmode = funcBehave or "skip"
    if fmode == "dump" then return string.dump(func)
    elseif fmode == "name" then return '"' .. tostring(func) .. '"'
    else return "nil"
    end
end

function LuaTable.encode_userdata(ud, pretty, funcBehave)
    if funcBehave and (funcBehave == "name" or funcBehave == "dump") then return '"' .. tostring(ud) .. '"' else return "nil" end
end

function LuaTable.encode_nil()
    return "nil"
end

function LuaTable.encode_string(str)
    return string.format("%q", str)
end

function LuaTable.encode_number(number)
    return tostring(number)
end

function LuaTable.encode_boolean(boolean)
    if boolean then
        return "true"
    else
        return "false"
    end
end

return LuaTable