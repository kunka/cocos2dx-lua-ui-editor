--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 12/08/2017
-- Time: 23:29
-- To change this template use File | Settings | File Templates.
--

local Layer = import(".Layer")
local PhysicsLayer = class("PhysicsLayer", Layer)
PhysicsLayer._isPhysics = true

function PhysicsLayer:ctor(physicsWorld, ...)
    self.physicsWorld = physicsWorld
    local genGetterAndSetter = function(propName)
        local getter = "get" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
        local setter = "set" .. string.upper(propName:sub(1, 1)) .. propName:sub(2, propName:len())
        self[getter] = function(_)
            return self.physicsWorld[getter](self.physicsWorld)
        end
        self[setter] = function(_, var)
            if self[getter] ~= var then
                self.physicsWorld[setter](self.physicsWorld, var)
            end
        end
    end
    genGetterAndSetter("gravity")
    genGetterAndSetter("speed")
    genGetterAndSetter("substeps")
    genGetterAndSetter("updateRate")
    genGetterAndSetter("fixedUpdateRate")
    self.isAutoStep = function()
        return self.physicsWorld:isAutoStep()
    end
    self.setAutoStep = function(_, autoStep)
        self.physicsWorld:setAutoStep(autoStep)
    end
    -- map vars
    local selects = { "DEBUGDRAW_NONE", "DEBUGDRAW_SHAPE", "DEBUGDRAW_JOINT", "DEBUGDRAW_CONTACT", "DEBUGDRAW_ALL" }
    local vars = { 0, 1, 2, 4, 7 }
    self.getDebugDrawMask = function()
        local mask = self.physicsWorld:getDebugDrawMask()
        return selects[table.indexof(vars, mask)]
    end
    self.setDebugDrawMask = function(_, mask)
        self.physicsWorld:setDebugDrawMask(vars[table.indexof(selects, mask)])
    end

    PhysicsLayer.super.ctor(self, ...)
end

return PhysicsLayer
