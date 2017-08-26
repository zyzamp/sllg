
SceneMgr = SceneMgr or {
}


function SceneMgr:showScene(iType)
	if iType == sgll.sceneType.town then
		display.replaceScene(require("app.scene.TownScene").new(), "fade", 0.6, display.COLOR_WHITE)
	elseif iType == sgll.sceneType.battle then
	end
end

