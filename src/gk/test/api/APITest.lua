--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 5/19/17
-- Time: 14:57
-- To change this template use File | Settings | File Templates.
--

local APITest = class("APITest", gk.Layer)

function APITest:ctor()
    APITest.super.ctor(self)

    gk.log("cc.iskindof test: \"Dialog\" <== \"Layer\" <== \"cc.Layer\" <== \"cc.Node\"")
    local Dialog = gk.Dialog
    local dialog = gk.Dialog.new()
    local Layer = gk.Layer
    local layer = gk.Layer.new()
    local class_iskindof = function(class, type)
        gk.log("Class:Dialog iskindof %s = %s", type, iskindof(class, type))
    end
    local instanceof = function(obj, type)
        gk.log("Instance:dialog iskindof %s = %s", type, iskindof(obj, type))
    end
    class_iskindof(Dialog, "Dialog")
    class_iskindof(Dialog, "Layer")
    class_iskindof(Dialog, "cc.Layer")
    class_iskindof(Dialog, "cc.Node")
    --    -- cc.iskindof will crash ...
    --    instanceof(dialog, "Dialog")
    --    instanceof(dialog, "Layer")
    --    instanceof(dialog, "cc.Layer")
    --    instanceof(dialog, "cc.Node")

    gk.log("gk.util test: \"Dialog\" <== \"Layer\" <== \"cc.Layer\" <== \"cc.Node\"")
    local class_iskindof = function(class, type)
        gk.log("Class:Dialog gk.util:iskindof %s = %s", type, gk.util:iskindof(class, type))
    end
    local instanceof = function(obj, type)
        gk.log("Instance:dialog gk.util:instanceof %s = %s", type, gk.util:instanceof(obj, type))
    end
    class_iskindof(Dialog, "Dialog")
    class_iskindof(Dialog, "Layer")
    class_iskindof(Dialog, "cc.Layer")
    class_iskindof(Dialog, "cc.Node")

    instanceof(dialog, "Dialog")
    instanceof(dialog, "Layer")
    instanceof(dialog, "cc.Layer")
    instanceof(dialog, "cc.Node")

    local class_iskindof = function(class, type)
        gk.log("Class:Layer gk.util:iskindof %s = %s", type, gk.util:iskindof(class, type))
    end
    local instanceof = function(obj, type)
        gk.log("Instance:layer gk.util:instanceof %s = %s", type, gk.util:instanceof(obj, type))
    end
    class_iskindof(Layer, "Dialog")
    class_iskindof(Layer, "Layer")
    class_iskindof(Layer, "cc.Layer")
    class_iskindof(Layer, "cc.Node")

    instanceof(layer, "Dialog")
    instanceof(layer, "Layer")
    instanceof(layer, "cc.Layer")
    instanceof(layer, "cc.Node")
end

return APITest