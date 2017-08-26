require("config")
require("cocos.init")
require("framework.init")

require("app.macro.GlobalEnum")
require("app.mgr.SceneMgr")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self:init()
end

function MyApp:init()
end

function MyApp:run()		
	SceneMgr:showScene(sgll.sceneType.town)
end

return MyApp
