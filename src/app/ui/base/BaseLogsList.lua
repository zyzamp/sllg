
local BaseLogsList = class("BaseLogsList", require("app.ui.BaseDialog"))

local bindArr = {
 	["Image_1"] = {varname = "m_LogsBg"},
 	["Button_1"] = {varname = "m_CloseBtn", touchEvent = "onCloseEvent"},
 }

function BaseLogsList:ctor()
	self.super:ctor()
	self:bindByFile("ui/logs_list.csb", bindArr)
end

function BaseLogsList:initScroll(size, posX, posY)
	local scroll = self.m_LogsListScroll
	if scroll == nil then
		scroll = ccui.ListView:create()
	    scroll:setAnchorPoint(cc.p(0.5, 0.5))
	    scroll:setDirection(ccui.ScrollViewDir.vertical)
	    scroll:setBounceEnabled(true) 
	    self:addChild(scroll)
	    self.m_LogsListScroll = scroll
		self:setMask(-1)
	end
	self.m_LogsBg:setPosition(cc.p(posX, posY))
	self.m_LogsBg:setContentSize(size)
    self.m_CloseBtn:setPosition(posX + size.width / 2, posY + size.height / 2)
    scroll:setPosition(self.m_LogsBg:getPosition())
    scroll:setContentSize(cc.size(size.width - 30, size.height - 30))
end

function BaseLogsList:clear()
	local scroll = self.m_LogsListScroll
	if scroll ~= nil then
		scroll:removeAllItems()
	end
end

function BaseLogsList:addLog(str, iColor, bIsRich)
	if iColor == nil then
		iColor = 30
	end

	local scroll = self.m_LogsListScroll
	if scroll ~= nil then
		if bIsRich then
			local text = LabelFactoryMgr:getRichText(str, 20, cc.size(scroll:getContentSize().width - 10, 26), iColor)
			scroll:pushBackCustomItem(text)
		else
			local color = ms.color[iColor]
			local text = ccui.Text:create(str, "ui/fonts/FZY4JW.TTF", 22)
			text:setTextColor(cc.c4b(color[1], color[2], color[3], 0xff))
			local renderer = text:getVirtualRenderer()
		    renderer:setMaxLineWidth(scroll:getContentSize().width - 10)
		    renderer:setLineBreakWithoutSpace(true)
			scroll:pushBackCustomItem(text)
		end
	end
end

function BaseLogsList:jumpToBottom()
	local scroll = self.m_LogsListScroll
	if scroll ~= nil then
		scroll:jumpToBottom()
	end
end

function BaseLogsList:addCloseCllBack(func)
	self.m_closeCallBackFunc = func
end

function BaseLogsList:onCloseEvent(sender, eventType)
	if eventType == 2 then
		if self.m_closeCallBackFunc ~= nil then
			self.m_closeCallBackFunc()
		end
		self:removeFromParent(true)
	end
end

return BaseLogsList