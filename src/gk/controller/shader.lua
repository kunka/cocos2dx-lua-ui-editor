--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/21/17
-- Time: 16:15
-- To change this template use File | Settings | File Templates.
--

local shader = {}

shader.cachedGLPrograms = {}
function shader:addGLProgram(vPath, fPath)
    self.cachedGLPrograms = self.cachedGLPrograms or {}
    local glProgram = cc.GLProgram:createWithFilenames(vPath, fPath)
    if glProgram then
        local ps = string.split(fPath, "/")
        local key = string.split(ps[#ps], ".")[1]
        gk.log("addGLProgram -> %s, fPath = %s", key, fPath)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
        self.cachedGLPrograms[key] = glProgram
    end
end

function shader:getCachedGLProgram(key)
    return self.cachedGLPrograms[key]
end

return shader
