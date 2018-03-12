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
    local glProgram = cc.GLProgram:createWithFilenames(vPath, fPath)
    if glProgram then
        local ps = string.split(fPath, "/")
        local key = string.split(ps[#ps], ".")[1]
        gk.log("addGLProgram -> %s, fPath = %s", key, fPath)
        cc.GLProgramCache:getInstance():addGLProgram(glProgram, key)
        self.cachedGLPrograms[key] = { shader = glProgram, vPath = vPath, fPath = fPath }
    end
end

function shader:getCachedGLProgram(key)
    return cc.GLProgramCache:getInstance():getGLProgram(key)
    --    return self.cachedGLPrograms[key] and self.cachedGLPrograms[key].shader or nil
end

function shader:reloadOnRenderRecreated()
    if not self.recreateListener then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        local customListener = cc.EventListenerCustom:create("event_renderer_recreated", function(event)
            gk.log("reload shader onRenderRecreated")
            if self.cachedGLPrograms then
                for _, info in pairs(self.cachedGLPrograms) do
                    local shader = info.shader
                    shader:reset()
                    shader:initWithFilenames(info.vPath, info.fPath)
                    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
                    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
                    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORD)
                    shader:link()
                    shader:updateUniforms()
                end
            end
        end)

        eventDispatcher:addEventListenerWithFixedPriority(customListener, -1)
        self.recreateListener = customListener
    end
end

function shader:removeRecreateListener()
    if self.recreateListener then
        local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
        eventDispatcher:removeEventListener(self.recreateListener)
        self.recreateListener = nil
    end
end

function shader:getDefaultShader()
    return cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
end

function shader:getDefaultMvpShader()
    return cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_MVP")
end

return shader
