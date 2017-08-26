--
-- Author: shimin
-- Date: 2016-05-23 19:23:06
--

local TradeGrid = class("TradeGrid", require("app.ui.base.BaseWidget"))

local bindArr = {
	["Image_1"] = {zorder = 0,  varname = "m_BGImage", touchEvent = "touchEvent"}, ---背景
	["m_NameText"] = {zorder = 1,  varname = "m_NameText"},--卡片图片
	["m_PropsBg"] = {zorder = 2,  varname = "m_PropsBg"},--卡片图片
    --["m_GridImage"] = {zorder = 3,  varname = "m_GridImage", touchEvent = "touchGoodsEvent"},--卡片图片
    ["m_GridImage"] = {zorder = 3,  varname = "m_GridImage",},--卡片图片
    ["m_StarImage"] = {zorder = 4,  varname = "m_StarImage"},--星级
	["m_MoneyBg"] = {zorder = 5,  varname = "m_MoneyBg"},--点券
    ["m_MoneyType"] = {zorder = 6,  varname = "m_MoneyType"},--点券   
    ["m_PriceText"] = {zorder = 7,  varname = "m_PriceText"},--总价   
    ["m_SelectedBG"] = {zorder = 8,  varname = "m_SelectedBG"},--总价
    ["m_CostText"] = { varname = "m_CostText" ,zorder = 5}, --消耗
 }

function TradeGrid:ctor()
	self.super:ctor()
	self.m_GridData = nil
	self.m_bSelected = false
	self:widgetResourceBind("ui/trade_grid.csb", bindArr)
	self:setContentSize(self.m_SelectedBG:getContentSize())			
end

function TradeGrid:init(resourceNode)
	
end

function TradeGrid:setData(gridData,index,isloaderImage)
	self:clearData()
 	self.m_GridData = nil
 	if gridData == nil then
 		return
 	end
 	self.m_GridData = gridData 	
 	if isloaderImage == nil then
 		self:loaderImage()
 	end
end

function TradeGrid:loaderImage()
	if self.m_BGImage == nil then	 
		self:clearData()
	end
	if self.m_GridData ~= nil then
		self.m_MoneyType:setVisible(true)
		self.m_MoneyType:setScale(0.8)
		if self.m_GridData.m_iTradeMoney == 0 then
			self.m_MoneyType:setTexture("ui/common/coin1.png")
		else
			self.m_MoneyType:setTexture("ui/common/coin2.png")
		end

	 	self:updatePrice(self.m_GridData.m_iTradeMoney)
	 	self:updatePrice(self.m_GridData.m_iTradeCoin)
	 	self:updateGridInfo()
	end
end

function TradeGrid:updateGridInfo()
	if self.m_GridData.m_stPropsInfo ~= nil then 					--道具用m_iPropsID来识别
 		local data = msconfig:getPropsByID(self.m_GridData.m_stPropsInfo.m_iPropsID)
 		if data ~= nil then
 			self.m_NameText:setString("")
			self.m_GridImage:loadTexture(string.format("image/props/0x%08x.png", data.m_iIcon))
		else
			self.m_GridImage:loadTexture(string.format("image/props/0x%08x.png", self.m_GridData.m_stPropsInfo.m_iPropsID))
		end
		self.m_GridImage:setVisible(true)
		self:updateCount(self.m_GridData.m_stPropsInfo.m_iPropsCount)
		self.m_PropsBg:setVisible(true)
		 
	elseif self.m_GridData.m_stCardInfo ~= nil then 				--装备用m_iItemID来识别
		local data = msconfig:getCardData(self.m_GridData.m_stCardInfo.m_iCardID)
 		if data ~= nil then
 			self.m_NameText:setString("")
			self.m_GridImage:loadTexture(string.format("image/card/0x%08x.png", self.m_GridData.m_stCardInfo.m_iCardID))
		else
			print(string.format("没有这个卡片 = 0x%08x", self.m_GridData.m_stCardInfo.m_iCardID))
		end
		self.m_GridImage:setVisible(true)
		self:setStar(self.m_GridData.m_stCardInfo.m_nLevel)
		self:updateCount(1)
		self:updateCost()
	 
	end
end

function TradeGrid:clearData()
	if self.m_GridImage ~= nil then
		self.m_GridImage:setVisible(false)
		self.m_StarImage:setVisible(false)
		self.m_SelectedBG:setVisible(false)
		self.m_MoneyBg:setVisible(false)
	 	self.m_NameText:setString("")
		self.m_PriceText:setString("")
		self.m_PropsBg:setVisible(false)
		self.m_MoneyType:setVisible(false)
	end
end

function TradeGrid:updatePrice(iPrice)
	if iPrice ~= 0 then
		if iPrice > 10000 then
			self.m_PriceText:setString(string.format("%0.1f万",iPrice / 10000))
		else
			self.m_PriceText:setString(iPrice)
		end
 		self.m_MoneyBg:setVisible(true)
		self.m_PriceText:setVisible(true)
 	end
end

function TradeGrid:updateCount(nPropsCount)
	--if true then return end
	local text = nil
	if nPropsCount ~= nil and nPropsCount > 1 then
		local str = string.format("x%d", nPropsCount)
		if text == nil then
			text = cc.Label:createWithBMFont("ui/fonts/font_grid_num.fnt", str)
			text:setHorizontalAlignment(2)
			text:setVerticalAlignment(2)
			--text:setColor(cc.c3b(0xff, 0xff, 0xff))
			--text:enableOutline(cc.c4b(0x0f, 0x0f, 0x0f, 0xcc), 1)
			text:setAnchorPoint(cc.p(1, 0))
			text:setPosition(self.m_PropsBg:getPositionX()+ 40, self.m_PropsBg:getPositionY() - 32)
			text:addTo(self,4)
		else
			text:setString(str)
			text:setVisible(true)
		end
	elseif text ~= nil then
		text:setVisible(false)
	end
end 

function TradeGrid:updateCost()
	local cardInfo = self.m_GridData.m_stCardInfo
	local iFireCost, iUpFireCost = msconfig:getCardCost(cardInfo.m_iCardID)
	local text = nil
	if iFireCost > 0 then
		local szCost = iFireCost .. (iUpFireCost > 0 and "+" or "")
		if text == nil then
			text = cc.Label:createWithBMFont("ui/fonts/font_grid_num.fnt", szCost)
			text:setHorizontalAlignment(2)
			text:setVerticalAlignment(2)
			text:setAnchorPoint(cc.p(1, 0))
			text:setPosition(113, 2)
			text:addTo(self.m_GridImage, 5)
		else
			text:setString(szCost)
			text:setVisible(true)
		end
	elseif text ~= nil then
		text:setVisible(false)
	end 
end

function TradeGrid:getData()
	return self.m_GridData
end

function TradeGrid:setCost(iCost)
end

function TradeGrid:setStar(iStar)
	if iStar == nil then
		self.m_StarImage:setVisible(false)
		return 
	end
	if iStar ~= 0 and iStar <= ms.max_star_level then
		self.m_iStar = iStar
		self.m_StarImage:setTexture(string.format("image/star/%d.png", iStar))
		self.m_StarImage:setVisible(true)
	end
	
end

function TradeGrid:setSelectStatus(bSelected)
	self.m_bSelected = bSelected
	if self.m_SelectedBG then
		self.m_SelectedBG:setVisible(bSelected)
	end
end

function TradeGrid:getSelectStatus()
	return self.m_bSelected
end

function TradeGrid:touchEvent(sender, eventType)
	self.super:onTouchEvent(self, eventType)
  --   if eventType == 2 then 
		-- audio.playSound(audio_file.menu_up,false)
  --   end
end

function TradeGrid:setImageTouchEnabled(enable)
	self.m_BGImage:setTouchEnabled(enable)
end
return TradeGrid