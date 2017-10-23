--
-- Created by IntelliJ IDEA.
-- User: Kunkka
-- Date: 7/20/17
-- Time: 09:37
-- To change this template use File | Settings | File Templates.
--

DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

--- TODO fix io.popen crash error when run by XCode
--- [LUA ERROR] [string "gk/controller/resource.lua"]:158: Interrupted system call
-- scan editable nodes on mac, if you run by XCode, disabled it, just run app in runtime/mac/<youapp>.app
CFG_SCAN_NODES = true