--
-- Created by IntelliJ IDEA.
-- User: Kunkka Huang
-- Date: 17/1/18
-- Time: 下午6:08
-- To change this template use File | Settings | File Templates.
--

local panel = {}

function panel.create(parent)
    local winSize = cc.Director:getInstance():getWinSize()
    local self = cc.LayerColor:create(gk.theme.config.backgroundColor, winSize.width - gk.display.leftWidth - gk.display.rightWidth, gk.display.bottomHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(gk.display.leftWidth, 0)

    local scale = 0.25
    local fontSize = 40
    local scale = 0.25
    local topY = gk.display.bottomHeight - 35
    local leftX = 12
    local inputWidth1 = 140
    local inputWidth2 = 400
    local stepY = 25
    local leftX2 = 100 + leftX
    local leftX3 = leftX2 + inputWidth1 + 20
    local leftX4 = leftX3 + 100

    -- size label
    local fontName = gk.theme.font_fnt
    local content = string.format("designSize(%.0fx%.0f) ScreenSize(%.0fx%.0f) accuWinSize(%.0fx%.0f) xScale(%.2f) yScale(%.2f) minScale(%.2f)",
        gk.display.width(), gk.display.height(), gk.display:winSize().width, gk.display:winSize().height, gk.display:accuWinSize().width, gk.display:accuWinSize().height, gk.display:xScale(), gk.display:yScale(), gk.display:minScale())
    local label = gk.create_label(content, fontName, fontSize)
    label:setScale(scale)
    local height = 20
    label:setDimensions(self:getContentSize().width / 0.2, height / 0.2)
    label:setOverflow(2)
    gk.set_label_color(label, gk.theme.config.fontColorNormal)
    self:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setPosition(leftX, gk.display.bottomHeight - height / 2)

    local createLabel = function(content, x, y)
        local label = gk.create_label(content, fontName, fontSize)
        label:setScale(scale)
        gk.set_label_color(label, gk.theme.config.fontColorNormal)
        self:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback, defValue, lines)
        lines = lines or 1
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale * lines))
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
        local label = gk.create_label(content, gk.theme.font_ttf, fontSize)
        gk.set_label_color(label, cc.c3b(0, 0, 0))
        node:setInputLabel(label)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 15, contentSize.height)
        self:addChild(node)
        node:setScale(scale)
        node:onEditEnded(function(...)
            callback(...)
        end)
        node:setAnchorPoint(0, 1)
        node:setPosition(x, y + 16 / 2)
        node.enabled = not self.disabled
        return node
    end
    local createSelectBox = function(items, index, x, y, width, callback)
        local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edit_box_bg.png", cc.rect(20, 20, 20, 20)))
        local label = gk.create_label("", fontName, fontSize)
        gk.set_label_color(label, cc.c3b(0, 0, 0))
        node:setMarginLeft(5)
        node:setMarginRight(22)
        node:setMarginTop(4)
        node:setDisplayLabel(label)
        node:onCreatePopupLabel(function()
            local label = gk.create_label("", fontName, fontSize)
            gk.set_label_color(label, cc.c3b(0, 0, 0))
            return label
        end)
        self:addChild(node)
        node:setScale(scale)
        node:setAnchorPoint(0, 0.5)
        node:setPosition(x, y)
        node:onSelectChanged(callback)
        return node
    end

    local yIndex = 0
    createLabel("Android SDK Path", leftX, topY - stepY * yIndex)
    local sdk = cc.UserDefault:getInstance():getStringForKey("gk_android_sdk_location")
    local onValueChanged = function(editBox, input)
        if input == "" then
            return false
        end
        local adb = input .. "/platform-tools/adb"
        local handle = io.popen(adb .. " version")
        local ret = handle:read("*a")
        handle:close()
        --        local correct = os.execute(adb .. " version") == 0
        local correct = ret and #ret > 0
        if editBox then
            gk.set_label_color(editBox.label, correct and cc.c3b(45, 35, 255) or cc.c3b(0, 0, 0))
        end
        return correct
    end
    local editBox = createInput(sdk, leftX2, topY - stepY * yIndex, inputWidth2, function(editBox, input)
        local correct = onValueChanged(editBox, input)
        if correct then
            cc.UserDefault:getInstance():setStringForKey("gk_android_sdk_location", input)
            cc.UserDefault:getInstance():flush()
        end
    end)
    editBox:onInputChanged(function(_, input)
        onValueChanged(editBox, input)
    end)
    onValueChanged(editBox, sdk)
    yIndex = yIndex + 1

    createLabel("Default Activity", leftX, topY - stepY * yIndex)
    local var = cc.UserDefault:getInstance():getStringForKey("gk_android_default_activity", "org.cocos2dx.lua.AppActivity")
    createInput(var, leftX2, topY - stepY * yIndex, inputWidth1, function(editBox, input)
        cc.UserDefault:getInstance():setStringForKey("gk_android_default_activity", input)
        cc.UserDefault:getInstance():flush()
    end)

    -- devices
    createLabel("Android Devices", leftX3, topY - yIndex * stepY)
    local items = { "-" }
    local selectBox = createSelectBox(items, 1, leftX4, topY - yIndex * stepY, inputWidth1, function(index)
    end)
    selectBox:setCascadeOpacityEnabled(true)
    selectBox.enabled = #items == 1
    selectBox:setOpacity(#items == 1 and 150 or 255)

    -- check devieces
    local checkDevices = function()
        local sdk = cc.UserDefault:getInstance():getStringForKey("gk_android_sdk_location")
        if onValueChanged(nil, sdk) then
            local devices = {}
            local adb = sdk .. "/platform-tools/adb"
            local handle = io.popen(adb .. " devices -l")
            local result = handle:read("*a")
            handle:close()
            if result and result:find("model:") then
                local id = result:sub(result:find("attached") + 9, result:find("attached") + 9 + 7)
                local name = result:sub(result:find("model:") + 6, result:find("device:") - 2)
                table.insert(devices, { id = id, name = name })
                --                dump(devices)
                return devices
            end
        end
        return {}
    end
    self.hasDevices = false
    local scanDevices = function()
        if not selectBox.popup then
            local devices = checkDevices()
            local items = { "-" }
            for _, v in pairs(devices) do
                table.insert(items, v.name)
            end
            selectBox:setItems(items)
            if (selectBox.selectIndex == 0 or selectBox.selectIndex == 1) and #items > 1 then
                selectBox:setSelectIndex(2)
            else
                selectBox:setSelectIndex(1)
            end
            selectBox.enabled = #items == 1
            selectBox:setOpacity(#items == 1 and 150 or 255)
            local hasDevices = #items > 1
            if self.hasDevices and not hasDevices then
                print("no phone connected")
            elseif not self.hasDevices and hasDevices then
                print("new phone connected -> " .. items[2])
            end
            self.hasDevices = hasDevices
        end
    end
    scanDevices()
    selectBox:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        scanDevices()
    end))))
    yIndex = yIndex + 1

    self.logOn = false
    createLabel("LogCat", leftX4 + inputWidth1 - 60, topY - stepY * yIndex)
    local icon = gk.create_sprite("gk/res/texture/icon_android.png")
    local button = gk.ZoomButton.new(icon)
    self:addChild(button)
    button:setScale(scale * 0.8)
    button:setPosition(leftX4 + inputWidth1, topY - yIndex * stepY)
    button:setAnchorPoint(1, 0.5)
    button:onClicked(function()
        self.logOn = not self.logOn
        local program = cc.GLProgramState:getOrCreateWithGLProgramName(self.logOn and "ShaderPositionTextureColor_noMVP" or "ShaderUIGrayScale")
        if program then
            icon:setGLProgramState(program)
        end
        if self.logOn then
            print("turn logcat on, tag = cocos2d")
            gk.util:stopActionByTagSafe(self, -991)
            local sdk = cc.UserDefault:getInstance():getStringForKey("gk_android_sdk_location")
            if not onValueChanged(nil, sdk) then
                gk.log("must set valid sdk location")
                return
            end
            local action = self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                local devices = checkDevices()
                if #devices == 0 then
                    return
                end
                local adb = sdk .. "/platform-tools/adb"
                local handle = io.popen(adb .. " logcat -d | grep cocos2d")
                local result = handle:read("*a"):trim()
                if result ~= "" then
                    print(result)
                end
                handle:close()
                local handle = io.popen(adb .. " logcat -c")
                handle:close()
            end))))
            action:setTag(-991)
        else
            print("turn logcat off")
            gk.util:stopActionByTagSafe(self, -991)
        end
    end)
    local program = cc.GLProgramState:getOrCreateWithGLProgramName(self.logOn and "ShaderPositionTextureColor_noMVP" or "ShaderUIGrayScale")
    if program then
        icon:setGLProgramState(program)
    end

    createLabel("Clean", leftX, topY - stepY * yIndex)
    local label = gk.create_label("↻", fontName, fontSize + 20)
    gk.set_label_color(label, cc.c3b(50, 255, 50))
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setDimensions(60 / scale, 20 / scale)
    local node = cc.Node:create()
    node:setContentSize(60 / scale, 16 / scale)
    node:addChild(label)
    label:enableBold()
    label:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2 - 4)
    local button = gk.ZoomButton.new(node)
    button:setScale(scale * 0.8, scale)
    button:setPosition(leftX2, topY - yIndex * stepY)
    self:addChild(button)
    gk.util:drawNodeBg(node, cc.c4f(0.5, 0.5, 0.5, 1), -2)
    button:setAnchorPoint(0, 0.5)
    button:onClicked(function()
        gk.set_label_color(label, cc.c3b(166, 166, 166))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            gk.set_label_color(label, cc.c3b(50, 255, 50))
            local instanceRun = require("gk.instanceRun")
            local MAC_ROOT = instanceRun.MAC_ROOT
            local ANDROID_ROOT = instanceRun.ANDROID_ROOT
            local ANDROID_PACKAGE_NAME = instanceRun.ANDROID_PACKAGE_NAME
            local defaultActivity = cc.UserDefault:getInstance():getStringForKey("gk_android_default_activity", "org.cocos2dx.lua.AppActivity")
            if ANDROID_PACKAGE_NAME == "" then
                gk.log("must set packageName")
                return
            end
            if not ANDROID_ROOT or ANDROID_ROOT == "/" then
                gk.log("must set ANDROID_ROOT")
                return
            end
            local sdk = cc.UserDefault:getInstance():getStringForKey("gk_android_sdk_location")
            if not onValueChanged(nil, sdk) then
                gk.log("must set valid sdk location")
                return
            end
            gk.log("----------------------------------")
            gk.log("Cleaning ......")
            --            local dir = MAC_ROOT .. "gen"
            --            gk.log("remove dir %s", dir)
            --            cc.FileUtils:getInstance():removeDirectory(dir)
            local adb = sdk .. "/platform-tools/adb"
            gk.log("remove dir %s", ANDROID_ROOT)
            local handle = io.popen(adb .. " shell rm -rf " .. ANDROID_ROOT)
            local result = handle:read("*a")
            handle:close()
            gk.log("Clean finished!")
        end)))
    end)

    createLabel("Deploy", leftX3, topY - stepY * yIndex)
    local label = gk.create_label("▶", fontName, fontSize + 10)
    gk.set_label_color(label, cc.c3b(50, 255, 50))
    label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setDimensions(60 / scale, 20 / scale)
    local node = cc.Node:create()
    node:setContentSize(60 / scale, 16 / scale)
    node:addChild(label)
    label:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2 - 4)
    local button = gk.ZoomButton.new(node)
    button:setScale(scale * 0.8, scale)
    button:setPosition(leftX4, topY - yIndex * stepY)
    self:addChild(button)
    gk.util:drawNodeBg(node, cc.c4f(0.5, 0.5, 0.5, 1), -2)
    button:setAnchorPoint(0, 0.5)
    button:onClicked(function()
        local instanceRun = require("gk.instanceRun")
        local ANDROID_PACKAGE_NAME = instanceRun.ANDROID_PACKAGE_NAME
        if ANDROID_PACKAGE_NAME == "" then
            gk.log("must set packageName")
            return
        end
        local defaultActivity = cc.UserDefault:getInstance():getStringForKey("gk_android_default_activity", "org.cocos2dx.lua.AppActivity")
        if defaultActivity == "" then
            gk.log("must set defaultActivity")
            return
        end
        local sdk = cc.UserDefault:getInstance():getStringForKey("gk_android_sdk_location")
        if not onValueChanged(nil, sdk) then
            gk.log("must set valid sdk location")
            return
        end

        gk.log("----------------------------------")
        gk.log("Deploying to Android device ......")
        gk:increaseRuntimeVersion()
        local scene = gk.SceneManager:getRunningScene()
        if scene and scene.layer then
            local label = scene:getChildByTag(gk.util.tags.versionTag)
            if label then
                label:setString(gk:getRuntimeVersion())
            end
        end
        gk.set_label_color(label, cc.c3b(166, 166, 166))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            gk.set_label_color(label, cc.c3b(50, 255, 50))
            local dir = gk.editorConfig.ANDROID_ROOT or "/"
            local adb = sdk .. "/platform-tools/adb"
            local handle = io.popen(gk.editorConfig.MAC_ROOT .. "src/gk/script/push.py " .. gk.editorConfig.MAC_ROOT .. " " .. adb .. " " .. packageName .. " " .. defaultActivity .. " " .. dir)
            local result = handle:read("*a")
            print(result)
            handle:close()
            gk.log("Finished!")
            gk.log("----------------------------------")
        end)))
    end)

    yIndex = yIndex + 1
    self:handleEvent()
    return self
end

function panel:handleEvent()
    -- swallow touches
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event)
        if gk.util:hitTest(self, touch) then
            return true
        end
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

return panel