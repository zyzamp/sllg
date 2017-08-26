--
-- Author: shimin
-- Date: 2016-05-23 23:00:18
--
local PriceGrid = class("PriceGrid", require("app.ui.base.BaseWidget"))

local bindArr = {
	["CheckBox_1"] = {zorder = 0,  varname = "m_CheckBox", touchEvent = "touchEvent"}, --- 
    ["Text_1"] = {zorder = 1,  varname = "m_PriceText"},--单价
}

function PriceGrid:ctor()
	self.super:ctor()
	self:widgetResourceBind("ui/price_grid.csb", bindArr)
	self:setContentSize(self.m_CheckBox:getContentSize())
	self.m_iPrice = 0
	self:clearData()
end

function PriceGrid:init(resourceNode)
end
 
function PriceGrid:setData(iPrice)
	self.m_iPrice = iPrice
	if self.m_iPrice ~= nil then
		if self.m_iPrice / 10000 > 1 then
			self.m_PriceText:setString(math.round(iPrice / 10000)..language_ch.cn_305)
		else
			self.m_PriceText:setString(iPrice)	
		end
	end
end

function PriceGrid:clearData()
	self.m_iPrice = 0
	--self:setEnableStatus(true)
end

function PriceGrid:getData()
	return self.m_iPrice
end

function PriceGrid:setSelectStatus(bSelected)
	self.m_CheckBox:setSelected(bSelected)
	--self.m_CheckBox:setBright(bEnableed)
end

function PriceGrid:getSelectStatus()
	return self.m_CheckBox:isSelected()
end

function PriceGrid:touchEvent(sender, eventType)
	self.super:onTouchEvent(self, eventType)
    if eventType == 2 then 
    	audio.playSound(audio_file.button)
    end
end

function PriceGrid:removeEvent()
	 
end

return PriceGrid