require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self:init()
end

function MyApp:init()
end

function MyApp:run()		
	display.replaceScene(require("app.MainScene").new(), "fade", 0.6, display.COLOR_WHITE)
end

return MyApp
