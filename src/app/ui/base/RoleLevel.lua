--
-- Author: shimin
-- Date: 2016-06-15 16:47:35
--
local RoleLevel = class("RoleLevel", require("app.ui.base.BaseWidget"))

local bindArr = {

	["Sprite_1"] = {zorder = 0,  varname = "m_LevelLabel0"}, ---
	["Sprite_2"] = {zorder = 1,  varname = "m_LevelLabel2"}, ---
    ["Sprite_3"] = {zorder = 2,  varname = "m_LevelLabel1"},--
}

function RoleLevel:ctor()
	self.super:ctor()
	self:widgetResourceBind("ui/level.csb", bindArr)
	self:clearData()
end

function RoleLevel:init(resourceNode)
	self.m_iLevel = 0
	msfunc.resoueceBinding(self,resourceNode,bindArr)
end

function RoleLevel:setData(iLevel)
	self:clearData()
 	if iLevel == nil then
 		return
 	end
 	self.m_iLevel = iLevel
	self.m_LevelLabel2:setTexture(string.format("ui/common/grade/%d/%d.png", math.floor(iLevel / 20),math.floor(iLevel / 10)))
	self.m_LevelLabel1:setTexture(string.format("ui/common/grade/%d/%d.png", math.floor(iLevel / 20),math.floor(iLevel % 10)))
end

function RoleLevel:clearData()
	 self.m_iLevel = 0
end

function RoleLevel:getData()
	return self.m_iLevel
end

return RoleLevel