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
    self.seOn = cc.UserDefault:getInstance():getBoolForKey("gk_seOn", true)
    self.bgmOn = cc.UserDefault:getInstance():getBoolForKey("gk_bgmOn", true)
end

function audio:isSeOn()
    return self.seOn
end

function audio:isBgmOn()
    return self.bgmOn
end

function audio:setSeOn(var)
    if self.seOn ~= var then
        self.seOn = var
        cc.UserDefault:getInstance():setBoolForKey("gk_seOn", var)
        cc.UserDefault:getInstance():flush()
    end
end

function audio:setBgmOn(var)
    if self.bgmOn ~= var then
        self.bgmOn = var
        cc.UserDefault:getInstance():setBoolForKey("gk_bgmOn", var)
        cc.UserDefault:getInstance():flush()
        if not var then
            self:stopMusic()
        else
            self:playMusic(self.music, self.loop)
        end
    end
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
    if self.seOn then
        local s = self.audios[sid]
        if s then
            engine:playEffect(s.path, isLoop)
        end
    end
end

function audio:playMusic(sid, isLoop)
    if self.bgmOn then
        local s = self.audios[sid]
        if s then
            engine:playMusic(s.path, isLoop)
        end
    end
    self.music = sid
    self.loop = isLoop
end

function audio:stopMusic(releaseData)
    cc.SimpleAudioEngine:getInstance():stopMusic(releaseData)
end

return audio