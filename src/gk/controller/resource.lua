--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/12
-- Time: 下午4:09
-- To change this template use File | Settings | File Templates.
--

local resource = {}
resource.textureRelativePath = ""
resource.atlasRelativePath = ""

function resource:setTextureRelativePath(path)
    resource.textureRelativePath = path
    gk.log("resource.setTextureRelativePath %s", path)
end

function resource:setAtlasRelativePath(path)
    resource.atlasRelativePath = path
    gk.log("resource.setAtlasPath %s", path)
end

return resource