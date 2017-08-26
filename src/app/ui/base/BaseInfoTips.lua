--
-- Author: shijimin
-- Date: 2016-08-31 12:34:54
--
local BaseInfoTips = class("BaseInfoTips", require("app.ui.BaseDialog"))

local bindArr = {
  	["Image_1"] = {varname = "m_TipBg"},--
	["Text_1"] = {varname = "m_TipDescText"}, ---
    ["Button_1"] = {varname = "m_CloseBtn", touchEvent = "closeEvent"},--关闭按钮
    ["Button_2"] = {varname = "m_SureBtn"},--关闭按钮
    ["Button_3"] = {varname = "m_CancelBtn"},--关闭按钮
}

local bindMenuArr = {

}

function BaseInfoTips:ctor()
	self.super.ctor(self)
    self:bindByFile("ui/base_info_tip.csb", bindArr)
	self:bindByNode(self.m_TipBg, bindArr)
    self:init()
end

function BaseInfoTips:init()
	self:setContentSize(self.m_TipBg:getContentSize())
	self.m_TipBg:setTouchEnabled(true)
	self.m_SureBtn:setVisible(false)
	self.m_CancelBtn:setVisible(false)
    self.m_CloseBtn:setVisible(false)
	self.m_TipDescText:setString("")
	self.m_TipDescText:getVirtualRenderer():setMaxLineWidth(300)
end
 
function BaseInfoTips:setModeTip(data)
	self.m_SureBtn:setVisible(false)
	self.m_CancelBtn:setVisible(false)
    self.m_CloseBtn:setVisible(false)
	self.m_TipBg:setScale(0.1)
    self.m_TipBg:runAction(cc.ScaleTo:create(0.1, 1))
	self.m_TipDescText:setString(data)
end

function BaseInfoTips:addCallBackFunc(callBack, closeCallBack)
	if callBack == nil then
		self.m_CloseBtn:setVisible(true)
		if closeCallBack ~= nil then
			self.m_CloseCallBackFunc = closeCallBack
		end
	else
		self.m_SureBtn:setVisible(true)
		self.m_SureBtn:addTouchEventListener(handler(self, self.onSureEvent))
		self.m_SuerCallBackFunc = callBack
		self.m_CancelBtn:setVisible(true)
		self.m_CancelBtn:addTouchEventListener(handler(self, self.closeEvent))
		self.m_CloseCallBackFunc = closeCallBack
	end
end

function BaseInfoTips:onSureEvent(sender, eventType)
  	if eventType == 2 then
		if self.m_SuerCallBackFunc ~= nil then
			self.m_SuerCallBackFunc(sender, eventType)
		end
	    TipsMgr:hideAllTip()
	end
end

function BaseInfoTips:closeEvent(sender, eventType)
  	if eventType == 2 then 
		if self.m_CloseCallBackFunc ~= nil then
			self.m_CloseCallBackFunc(sender, eventType)
		end
        TipsMgr:hideAllTip()
	end
end

return BaseInfoTips