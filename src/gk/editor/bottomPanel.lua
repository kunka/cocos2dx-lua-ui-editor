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
    local self = cc.LayerColor:create(cc.c4b(71, 71, 71, 255), winSize.width - gk.display.leftWidth - gk.display.rightWidth, gk.display.bottomHeight)
    setmetatableindex(self, panel)
    self.parent = parent
    self:setPosition(gk.display.leftWidth, 0)

    local scale = 0.25
    local fontSize = 40
    local scale = 0.25
    local topY = gk.display.bottomHeight - 32
    local leftX = 0
    local inputWidth1 = 140
    local inputWidth2 = 400
    local stepY = 25
    local leftX2 = 100 + leftX
    local leftX3 = leftX2 + inputWidth1 + 20
    local leftX4 = leftX3 + 100
    --    local leftX5 = leftX2 + inputWidth2 + 20
    --    local leftX6 = leftX5 + 120

    -- size label
    local fontName = "gk/res/font/Consolas.ttf"
    local content = string.format("designSize(%.0fx%.0f) winSize(%.0fx%.0f) xScale(%.2f) yScale(%.2f) minScale(%.2f)",
        gk.display.width(), gk.display.height(), gk.display:winSize().width, gk.display:winSize().height, gk.display:xScale(), gk.display:yScale(), gk.display:minScale())
    local label = cc.Label:createWithTTF(content, fontName, fontSize)
    label:setScale(scale)
    local height = 20
    label:setDimensions(self:getContentSize().width / 0.2, height / 0.2)
    label:setOverflow(2)
    label:setTextColor(cc.c3b(200, 200, 200))
    self:addChild(label)
    label:setAnchorPoint(0, 0.5)
    label:setVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    label:setPosition(0, gk.display.bottomHeight - height / 2)

    local createLabel = function(content, x, y)
        local label = cc.Label:createWithSystemFont(content, fontName, fontSize)
        label:setScale(scale)
        label:setTextColor(cc.c3b(189, 189, 189))
        self:addChild(label)
        label:setAnchorPoint(0, 0.5)
        label:setPosition(x, y)
        return label
    end
    local createInput = function(content, x, y, width, callback, defValue, lines)
        lines = lines or 1
        local node = gk.EditBox:create(cc.size(width / scale, 16 / scale * lines))
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 20, 20, 20)))
        local label = cc.Label:createWithTTF(content, fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
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
        node.isEnabled = not self.disabled
        return node
    end
    local createSelectBox = function(items, index, x, y, width, callback)
        local node = gk.SelectBox:create(cc.size(width / scale, 16 / scale), items, index)
        node:setScale9SpriteBg(gk.create_scale9_sprite("gk/res/texture/edbox_bg.png", cc.rect(20, 20, 20, 20)))
        local label = cc.Label:createWithTTF("", fontName, fontSize)
        label:setTextColor(cc.c3b(0, 0, 0))
        node:setDisplayLabel(label)
        node:onCreatePopupLabel(function()
            local label = cc.Label:createWithTTF("", fontName, fontSize)
            label:setTextColor(cc.c3b(0, 0, 0))
            return label
        end)
        local contentSize = node:getContentSize()
        label:setPosition(cc.p(contentSize.width / 2 - 5, contentSize.height / 2 - 5))
        label:setDimensions(contentSize.width - 25, contentSize.height)
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
        local adb = input .. "/platform-tools/adb"
        local handle = io.popen(adb .. " version")
        local ret = handle:read("*a")
        handle:close()
        --        local correct = os.execute(adb .. " version") == 0
        local correct = ret and #ret > 0
        if editBox then
            editBox.label:setTextColor(correct and cc.c3b(45, 35, 255) or cc.c3b(0, 0, 0))
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

    --    createLabel("Package Name", leftX5, topY - stepY * yIndex)
    --    local var = ANDROID_PACKAGE_NAME or "" -- cc.UserDefault:getInstance():getStringForKey("gk_android_package_name", "ANDROID_PACKAGE_NAME")
    --    local input = createInput(var, leftX6, topY - stepY * yIndex, inputWidth1, function(editBox, input)
    --        --        cc.UserDefault:getInstance():setStringForKey("gk_android_package_name", input)
    --        --        cc.UserDefault:getInstance():flush()
    --    end)
    --    input:setOpacity(150)
    --    input:setCascadeOpacityEnabled(true)
    --    input.isEnabled = false
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
            if result:find("model:") then
                local id = result:sub(result:find("attached") + 9, result:find("attached") + 9 + 7)
                local name = result:sub(result:find("model:") + 6, result:find("device:") - 2)
                table.insert(devices, { id = id, name = name })
                --                dump(devices)
                return devices
            end
        end
        return {}
    end
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
        end
    end
    scanDevices()
    selectBox:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
        scanDevices()
    end))))

    yIndex = yIndex + 1
    createLabel("Clean & Deploy", leftX, topY - stepY * yIndex)
    local label = cc.Label:createWithSystemFont("↻", fontName, fontSize + 20)
    label:setTextColor(cc.c3b(50, 255, 50))
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
    gk.util:drawNodeBg(node, cc.c4f(0.5, 0.5, 0.5, 0.5), -2)
    button:setAnchorPoint(0, 0.5)
    button:onClicked(function()
        label:setTextColor(cc.c3b(166, 166, 166))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            label:setTextColor(cc.c3b(50, 255, 50))
            local packageName = ANDROID_PACKAGE_NAME or ""
            local defaultActivity = cc.UserDefault:getInstance():getStringForKey("gk_android_default_activity", "org.cocos2dx.lua.AppActivity")
            if packageName == "" then
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
            local dir = MAC_ROOT .. "gen"
            cc.FileUtils:getInstance():removeDirectory(dir)
            cc.FileUtils:getInstance():removeDirectory(ANDROID_ROOT)
--            local adb = sdk .. "/platform-tools/adb"
--            local handle = io.popen(adb .. " shell rm -rf " .. ANDROID_ROOT)
--            local result = handle:read("*a")
--            print(result)
--            handle:close()
            gk.log("Clean finished!")
            gk.log("Deploying to Android device ......")
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
                -- deploy
                local dir = ANDROID_ROOT or "/"
                local adb = sdk .. "/platform-tools/adb"
                local handle = io.popen(MAC_ROOT .. "src/gk/script/push.py " .. MAC_ROOT .. " " .. adb .. " " .. packageName .. " " .. defaultActivity .. " " .. dir)
                local result = handle:read("*a")
                print(result)
                handle:close()
                gk.log("Finished!")
            end)))
        end)))
    end)

    createLabel("Fast Deploy", leftX3, topY - stepY * yIndex)
    local label = cc.Label:createWithSystemFont("▶", fontName, fontSize + 10)
    label:setTextColor(cc.c3b(50, 255, 50))
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
    gk.util:drawNodeBg(node, cc.c4f(0.5, 0.5, 0.5, 0.5), -2)
    button:setAnchorPoint(0, 0.5)
    button:onClicked(function()
        local packageName = ANDROID_PACKAGE_NAME or ""
        local defaultActivity = cc.UserDefault:getInstance():getStringForKey("gk_android_default_activity", "org.cocos2dx.lua.AppActivity")
        if packageName == "" then
            gk.log("must set packageName")
            return
        end
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
        label:setTextColor(cc.c3b(166, 166, 166))
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            label:setTextColor(cc.c3b(50, 255, 50))
            local dir = ANDROID_ROOT or "/"
            local adb = sdk .. "/platform-tools/adb"
            local handle = io.popen(MAC_ROOT .. "src/gk/script/push.py " .. MAC_ROOT .. " " .. adb .. " " .. packageName .. " " .. defaultActivity .. " " .. dir)
            local result = handle:read("*a")
            print(result)
            handle:close()
            gk.log("Finished!")
            gk.log("----------------------------------")
        end)))
    end)
    yIndex = yIndex + 1

    return self
end

return panel