--
-- Author: shimin
-- Date: 2016-05-05 15:42:25
--
local CardGrid = class("CardGrid", require("app.ui.base.BaseWidget"))

local bindArr = {
	["m_BGImage"] = {zorder = 0}, ---背景
	["m_GridImage"] = {zorder = 1},--卡片图片
	["m_Translate1Bg"] = {zorder = 2}, --一转背景
	["m_Translate2Bg"] = {zorder = 2}, --二转背景
    ["m_StarImage"] = {zorder = 3},--星级
    ["m_CostText"] = {zorder = 4}, --消耗
    ["m_BindedBG"] = {zorder = 5}, --绑定
    ["m_PVPCardBG"] = {zorder = 6},--PVP卡片 
    ["m_ComposeStatusBG"] = {zorder = 7},--合成状态   
    ["m_TasteBG"] = {zorder = 8},--体验卡

    ["m_NewFlagBG"] = {zorder = 9},--新 标记
    ["m_OpenLevelText"] = {zorder = 10}, --pvp老鼠开启等级
    ["m_SelectedBG"] = {zorder = 15},--选中
}

function CardGrid:ctor(bBg)
	self.super:ctor()
	if bBg == nil or bBg then
		self.m_BGImage = cc.Sprite:create("ui/common/card_bg.png")
		self.m_BGImage:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_BGImage:setPosition(self.m_BGImage:getContentSize().width/2, self.m_BGImage:getContentSize().height/2)
		self.m_BGImage:addTo(self, bindArr['m_BGImage'].zorder)
		self:setContentSize(self.m_BGImage:getContentSize())
	end
end

function CardGrid:init()
	self.m_GridData = nil
	self.m_iStar = nil
	self:addEvent()
end

function CardGrid:clearData()
	self:setGridImage(0)
	self:setStar(0)
	self:setCost(-1)
	self:setBindBG(false)
	self:setPVPCardBG(false)
	self:setCardComposeStatus(false)
	self:setSelectStatus(false, false)
	self:setNewFlag(false)
	self:setPvpOpenLevel(-1)
	self:removeEvent()
	self:removeEffect()
	self.m_GridData = nil
	if self.m_TasteBG ~= nil then
		self.m_TasteBG:setVisible(false)
	end

	self:setCardTranslateLevel(nil)
end

function CardGrid:setData(cardData,index,isLoaderImage)
	self:clearData()
	self:init()
 	if cardData == nil then
 		return
 	end
 	self.m_GridData = cardData
 	if isLoaderImage == nil then
		self:loaderImage()
	end
end

function CardGrid:loaderImage()
	if self.m_GridData ~= nil then
		self:setGridImage(self.m_GridData.m_iCardID)
		self:updateCost()
		self:setStar(0)
		self:setCardTranslateLevel(self.m_GridData)
		
		if self.m_GridData.m_nLevel ~= nil then
			self:setStar(self.m_GridData.m_nLevel)
		end
		
		if self.m_GridData.m_byBind ~= nil and self.m_GridData.m_byBind ~= 0 then
			self:setBindBG(true)
		end
		
		if self.m_GridData.m_szUniqueID ~= nil and msglobal:checkIsPvpCard(self.m_GridData.m_szUniqueID) == true then
			self:setPVPCardBG(true)
		end

		if self.m_GridData.m_iExpiredTime ~= nil  then
			self:setTaste(self.m_GridData.m_iExpiredTime)
		end
	end
end

function CardGrid:setGridImage(iCardID)
	if iCardID == 0 then
		if self.m_GridImage ~= nil then
			self.m_GridImage:setVisible(false)
		end
	else
		local szPath
		if iCardID < 0 then
			szPath = "ui/common/lock.png"
		else
			szPath = string.format("image/card/0x%08x.png", iCardID)
		end
		if self.m_GridImage == nil then
			self.m_GridImage = cc.Sprite:create(szPath)
			if self.m_GridImage ~= nil then
				self.m_GridImage:setAnchorPoint(cc.p(0.5, 0.5))
				self.m_GridImage:setPosition(58, 36)
				self.m_GridImage:addTo(self, bindArr['m_GridImage'].zorder)
			end
		else
			self.m_GridImage:setVisible(true)
			self.m_GridImage:setTexture(szPath)
		end
	end
end

function CardGrid:setBindBG(bShow)
	if bShow then
		if self.m_BindedBG == nil then 	
			self.m_BindedBG = cc.Sprite:create("ui/common/bind.png")
			self.m_BindedBG:setAnchorPoint(cc.p(1, 1))
			self.m_BindedBG:setPosition(116, 70)
			self.m_BindedBG:addTo(self, bindArr['m_BindedBG'].zorder)
		else
			self.m_BindedBG:setVisible(true)
		end
	elseif self.m_BindedBG ~= nil then
		self.m_BindedBG:setVisible(false)
	end
end

function CardGrid:setCardTranslateLevel(cardData)
	if self.m_Translate1Bg then self.m_Translate1Bg:setVisible(false) end
	if self.m_Translate2Bg then self.m_Translate2Bg:setVisible(false) end
	if cardData == nil then return end

	local iLevel = msconfig:getCardTranslateLevel(cardData.m_iCardID)
	if iLevel == 1 then
		if self.m_Translate1Bg == nil then
			self.m_Translate1Bg = cc.Sprite:create("ui/common/translate_1.png")
			self.m_Translate1Bg:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_Translate1Bg:setPosition(self.m_BGImage:getPosition())
			self.m_Translate1Bg:addTo(self, bindArr["m_Translate1Bg"].zorder)
		end
		self.m_Translate1Bg:setVisible(true)
	elseif iLevel == 2 then
		if self.m_Translate2Bg == nil then
			self.m_Translate2Bg = cc.Sprite:create("ui/common/translate_2.png")
			self.m_Translate2Bg:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_Translate2Bg:setPosition(self.m_BGImage:getPosition())
			self.m_Translate2Bg:addTo(self, bindArr["m_Translate2Bg"].zorder)
		end
		self.m_Translate2Bg:setVisible(true)
	end
end

function CardGrid:setPVPCardBG(bShow)
	if bShow then
		if self.m_PVPCardBG == nil then 	
			self.m_PVPCardBG = cc.Sprite:create("ui/common/pvp.png")
			self.m_PVPCardBG:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_PVPCardBG:setPosition(22, 61)
			self.m_PVPCardBG:addTo(self, bindArr['m_PVPCardBG'].zorder)
		else
			self.m_PVPCardBG:setVisible(true)
		end
	elseif self.m_PVPCardBG ~= nil then
		self.m_PVPCardBG:setVisible(false)
	end
end

function CardGrid:updateCost()
	if self.m_iStar == nil then
		self.m_iStar = 0
	end
	local iFireCost, iUpFireCost = msconfig:getCardCost(self.m_GridData.m_iCardID)
	if iFireCost ~= nil then
		self:setCost(iFireCost, iUpFireCost ~= nil and iUpFireCost > 0)
	end
end

function CardGrid:getData()
	return self.m_GridData
end

function CardGrid:setCost(iCost, bAdd)
	local text = self.m_CostText
	if iCost > 0 then
		local szCost = iCost .. (bAdd and "+" or "")
		if text == nil then
			text = cc.Label:createWithBMFont("ui/fonts/font_grid_num.fnt", szCost)
			text:setHorizontalAlignment(2)
			text:setVerticalAlignment(2)
			--text:setColor(cc.c3b(0xff, 0xff, 0xff))
			--text:enableOutline(cc.c4b(0x0f, 0x0f, 0x0f, 0xcc), 1)
			text:setAnchorPoint(cc.p(1, 0))
			text:setPosition(113, 6)
			text:addTo(self, bindArr['m_CostText'].zorder)
			self.m_CostText = text
		else
			text:setString(szCost)
			text:setVisible(true)
		end
	elseif text ~= nil then
		text:setVisible(false)
	end
end

function CardGrid:setStar(iStar)
	if iStar ~= nil and 0 < iStar and iStar <= ms.max_star_level then
		local szPath = string.format("image/star/%d.png", iStar)
		if self.m_StarImage == nil then 	
			self.m_StarImage = cc.Sprite:create(szPath)
			self.m_StarImage:setAnchorPoint(cc.p(0, 0))
			self.m_StarImage:setPosition(0, 0)
			self.m_StarImage:addTo(self, bindArr['m_StarImage'].zorder)
		else
			self.m_StarImage:setVisible(true)
			self.m_StarImage:setTexture(szPath)
		end
	elseif self.m_StarImage ~= nil then
		self.m_StarImage:setVisible(false)
	end
end

function CardGrid:setSelectStatus(bSelected, bColor)
	if bSelected then
		if self.m_SelectedBG == nil then 	
			self.m_SelectedBG = cc.Sprite:create("ui/common/selected_bg.png")
			self.m_SelectedBG:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_SelectedBG:setPosition(57, 36)
			self.m_SelectedBG:addTo(self, bindArr['m_SelectedBG'].zorder)
		else
			self.m_SelectedBG:setVisible(true)
		end
	elseif self.m_SelectedBG ~= nil then
		self.m_SelectedBG:setVisible(false)
	end
	if self.m_GridImage ~= nil then
		if bColor == true then
			self.m_GridImage:setColor(cc.c3b(100,100,100))
		else
			self.m_GridImage:setColor(cc.c3b(255,255,255))
		end
	end
end

function CardGrid:getSelectStatus()
	return self.m_SelectedBG ~= nil and self.m_SelectedBG:isVisible()
end

function CardGrid:setSelect(bSelected)
	if bSelected then
		if self.m_SelectedBG == nil then 	
			self.m_SelectedBG = cc.Sprite:create("ui/common/selected_bg.png")
			self.m_SelectedBG:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_SelectedBG:setPosition(57, 36)
			self.m_SelectedBG:addTo(self, bindArr['m_SelectedBG'].zorder)
		else
			self.m_SelectedBG:setVisible(true)
		end
	elseif self.m_SelectedBG ~= nil then
		self.m_SelectedBG:setVisible(false)
	end
end

function CardGrid:setColor(bColor)
	if self.m_GridImage ~= nil then
		if bColor == true then
			self.m_GridImage:setColor(cc.c3b(100,100,100))
		else
			self.m_GridImage:setColor(cc.c3b(255,255,255))
		end
	end
end

function CardGrid:setCardComposeStatus(bComposeStatus)
	if bComposeStatus then
		if self.m_ComposeStatusBG == nil then 	

			self.m_ComposeStatusBG = cc.Sprite:create("ui/common/tip.png")
			self.m_ComposeStatusBG:setAnchorPoint(cc.p(1, 1))
			self.m_ComposeStatusBG:setPosition(116, 70)
			self.m_ComposeStatusBG:addTo(self, bindArr['m_ComposeStatusBG'].zorder)
		else
			self.m_ComposeStatusBG:setVisible(true)
		end
	elseif self.m_ComposeStatusBG ~= nil then
		self.m_ComposeStatusBG:setVisible(false)
	end
	if self.m_GridImage ~= nil then
		if bComposeStatus then
			self.m_GridImage:setColor(cc.c3b(255,255,255))
		else			
			self.m_GridImage:setColor(cc.c3b(100,100,100))
		end
	end
end

function CardGrid:getCardComposeStatus()
	return self.m_ComposeStatusBG ~= nil and self.m_ComposeStatusBG:isVisible()
end

function CardGrid:setNewFlag(flag)
	if flag then 
		if self.m_NewFlagBG == nil then
			self.m_NewFlagBG = cc.Sprite:create("ui/common/new.png")
			self.m_NewFlagBG:setAnchorPoint(cc.p(0, 1))
			self.m_NewFlagBG:setPosition(0, self.m_BGImage:getContentSize().height)
			self.m_NewFlagBG:addTo(self, bindArr["m_NewFlagBG"].zorder)
		end
		self.m_NewFlagBG:setVisible(true)
	elseif self.m_NewFlagBG ~= nil then
		self.m_NewFlagBG:setVisible(false)
	end
end

function CardGrid:getNewFlag()
	return self.m_NewFlagBG and self.m_NewFlagBG:isVisible() 
end

function CardGrid:setPvpOpenLevel(iLevel)
	if iLevel > 0 then
		local szDesc = ""
		local pvpInfo = msconfig:getPvpInfoByLevel(iLevel)
		if pvpInfo ~= nil then szDesc = pvpInfo.m_szName.."解锁" end
		if self.m_OpenLevelText == nil then
			self.m_OpenLevelText = cc.Label:createWithTTF(szDesc, "ui/fonts/FZY4JW.TTF", 18)
			self.m_OpenLevelText:setTextColor(cc.c4b(0xff, 0xff, 0x00, 255))
			self.m_OpenLevelText:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_OpenLevelText:setPosition(self.m_BGImage:getPosition())
			self.m_OpenLevelText:addTo(self, bindArr["m_OpenLevelText"].zorder)
		end
		self.m_OpenLevelText:setString(szDesc)
	elseif self.m_OpenLevelText ~= nil then
		self.m_OpenLevelText:setString("")
	end
end

function CardGrid:setTaste(iExpiredTime)
	if iExpiredTime ~= 0 then
		if self.m_TasteBG == nil then
			self.m_TasteBG = cc.Sprite:create("ui/common/taste.png")
			self.m_TasteBG:setAnchorPoint(cc.p(0, 1))
			self.m_TasteBG:setPosition(2, self.m_GridImage:getContentSize().height +4)
			self.m_TasteBG:addTo(self, bindArr['m_TasteBG'].zorder)
		else
			self.m_TasteBG:setVisible(true)
		end
	else
		if self.m_TasteBG ~= nil then
			self.m_TasteBG:setVisible(false)
		end
	end
end

function CardGrid:touchEvent(sender, eventType)
	if self.m_BaseListCallBackFunc ~= nil then
		self.super:onTouchEvent(self, eventType)
		if eventType == ccui.TouchEventType.began then
			self:performWithDelay(handler(self,self.updateGridTip),2)
			return true
		end
		if eventType == ccui.TouchEventType.moved then 
		    TipsMgr:removeDescTip(self,nil)
		end
	    if eventType == ccui.TouchEventType.ended then 
	    	audio.playSound(audio_file.menu_up,false)
	    	if self.m_bShowDescTip ~= nil and self.m_bShowDescTip == true then
	    		self.m_bShowDescTip = false
		    	TipsMgr:removeDescTip(self,nil)
		    end
	    end
	else
		if eventType == 2 then
			FloatTipsMgr:setCardTipsData(self.m_GridData)
		end
	end
    self:stopAllActions()
end

function CardGrid:updateGridTip(sender)
	if self.m_GridData ~= nil then
		local data = msconfig:getCardData(self.m_GridData.m_iCardID)
		if data ~= nil then
			local arrDesc = string.split(data.m_szDesc, "|")
			if table.getn(arrDesc) > 0 then
				self.m_bShowDescTip = true
				TipsMgr:addDescTip(arrDesc[1],self:getWorldPosition(), self:getContentSize())
			end
		end
		self:stopAllActions()
	end
end

function CardGrid:playEffect()
	local effect = self.m_Effect 
	if effect == nil then
		effect = require("app.component.EffectPlayer").new("qianghua", "root")
		effect:addActionEventListener(function(sender, event) if event.type == 7 then self:removeEffect() end end)
		effect:playAction("IDLE1", 1)
		effect:setPosition(58, 36)
		self:addChild(effect, 99)
		self.m_Effect = effect
	end
end

function CardGrid:removeEffect()
	local effect = self.m_Effect 
	if effect ~= nil then
		effect:removeSelf()
		self.m_Effect  = nil
	end
end

function CardGrid:setImageTouchEnabled(enable)
	self:setTouchEnabled(enable)
end

function CardGrid:addEvent()
	self:addTouchEventListener(handler(self,self.touchEvent))
	self:setTouchEnabled(true)
end

function CardGrid:removeEvent()
	self:setTouchEnabled(false)
	self:removeTouchEvent()
end

return CardGrid