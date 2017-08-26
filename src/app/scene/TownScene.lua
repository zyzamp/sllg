

local TownScene = class("TownScene", function()
    return display.newScene("TownScene")
end)

function TownScene:ctor()
	--加载图片
	local image = ccui.ImageView:create("res/bg1.png")

	image:setAnchorPoint(cc.p(0.5, 0.5))
	image:setPosition(cc.p(display.cx, display.cy))
	image:addTo(self)
end

function TownScene:onEnter()

end

return TownScene
