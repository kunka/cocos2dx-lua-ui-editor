--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 6/12/17
-- Time: 16:52
-- To change this template use File | Settings | File Templates.
--

local audio = {}

local engine = cc.SimpleAudioEngine:getInstance()
function audio:init()
    self.audios = {}
end

function audio:registerEvent(sid, path, tag)
    self.audios[sid] = { path = path, tag = tag }
end

function audio:isValidEvent(sid)
    return self.audios[sid]
end

function audio:preloadEffect(sid)
    local s = self.audios[sid]
    if s then
        engine:preloadEffect(s.path)
    end
end

function audio:unloadEffect(sid)
    local s = self.audios[sid]
    if s then
        engine:unloadEffect(s.path)
    end
end

function audio:preloadEffectByTag(tag)
    -- TODO
end

function audio:unloadEffectByTag(tag)
    -- TODO
end

function audio:preloadMusic(sid)
    local s = self.audios[sid]
    if s then
        engine:preloadMusic(s.path)
    end
end

function audio:playEffect(sid, isLoop)
    local s = self.audios[sid]
    if s then
        engine:playEffect(s.path, isLoop)
    end
end

function audio:playMusic(sid, isLoop)
    local s = self.audios[sid]
    if s then
        engine:playMusic(s.path, isLoop)
    end
end

return audio