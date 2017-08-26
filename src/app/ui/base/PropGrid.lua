--
-- Author: shimin
-- Date: 2016-05-05 15:42:35
--
local PropGrid = class("PropGrid", require("app.ui.base.BaseWidget"))

local bindArr = {
	["m_BGImage"] = {zorder = 0}, ---背景 touchEvent  nodeTouchEvent
    ["m_GridImage"] = {zorder = 1},--道具图片
    ["m_CountText"] = {zorder = 2}, --数量
    ["m_BindedBG"] = {zorder = 3}, --绑定
    ["m_SelectedBG"] = {zorder = 15},--选中
    ["m_StarImage"] = {zorder = 4},--星级
    
    ["m_GemImage1"] = {zorder = 6},--星级
    ["m_GemImage2"] = {zorder = 7},--星级
    ["m_GemImage3"] = {zorder = 8},--星级
    ["m_RedPoint"] = {zorder = 9},--星级
    ["m_IsEquipImage"] = {zorder = 5},--是否穿戴在身上(只有装备)
    ["m_TasteBG"] = {zorder = 9},--合成状态
    ["m_ProbabilityBG"] = {zorder = 1},--概率底
    ["m_ProbabilityText"] = {zorder = 2}, --概率
    ["m_NewFlagBG"] = {zorder = 10},--新 标记
}

function PropGrid:ctor()
	self.super:ctor()
	if self.m_BGImage == nil then
		self.m_BGImage = cc.Sprite:create("ui/common/prop_bg.png")
		self.m_BGImage:setAnchorPoint(cc.p(0.5, 0.5))
		self.m_BGImage:setPosition(36.67, 36.67)
		self.m_BGImage:addTo(self, bindArr['m_BGImage'].zorder)
		self:setContentSize(self.m_BGImage:getContentSize())

		self:addEvent()
	end
end

function PropGrid:init()
	self.m_GridData = nil
	self.m_iPropID = nil
	self.m_iTipsSubType = nil	
end

function PropGrid:clearData()
	self:updateCount(-1)
	self:setSelectStatus(false, false)
	self:setGridImage(0)
	self:setBindStatus(false)
	self:setNewFlag(false)
	self:setStar(0)
	--self:removeEvent()
	self.m_GridData = nil
	self:setEquipImage()
	for i = 1 ,3 do
		if self["m_GemImage"..i] ~= nil then
			self["m_GemImage"..i]:setVisible(false)
		end
	end
	if self.m_TasteBG ~= nil then
		self.m_TasteBG:setVisible(false)
	end
	if self.m_RedPoint ~= nil then
		self.m_RedPoint:removeSelf()
		self.m_RedPoint = nil
	end

	if self.m_ProbabilityBG ~= nil then
		self.m_ProbabilityBG:removeSelf()
		self.m_ProbabilityBG = nil
	end
end

function PropGrid:setData(gridData,index,isLoaderImage)
	self:clearData()
	self:init()
 	if gridData == nil then 
 		return 
 	end 	
	--self:addEvent()
 
 	self.m_GridData = gridData
 	if isLoaderImage == nil then
		self:loaderImage()
 	end
end

function PropGrid:getData()
	return self.m_GridData
end

function PropGrid:loaderImage()	 
	if self.m_GridData ~= nil and self.m_GridData.m_iPropsID ~= nil then 					--道具用m_iPropsID来识别
 		if isLoaderImage == nil then
			self:setGridImage(self.m_GridData.m_iPropsID)
		end
		if self.m_GridData.m_iPropsID > 0x11000000 and self.m_GridData.m_iPropsID < 0x12000000 then --卡片
			self:setStar(self.m_GridData.m_iPropsCount)
		elseif self.m_GridData.m_iPropsID > 0 then
			self:updateCount(self.m_GridData.m_iPropsCount)
			self:updateBindStatus()
			self:setStar(msglobal:getPropsStar(self.m_GridData.m_iPropsID))
			local props = msconfig:getPropsByID(self.m_GridData.m_iPropsID)
			local vtGiftData = msconfig:getGiftContentByID(self.m_GridData.m_iPropsID)
			if props ~= nil and props.m_iType == ms.propsType.props and (props.m_iSubType == ms.propsSubType.taste or #vtGiftData == 1 )then
				if vtGiftData ~= nil and #vtGiftData > 0 then
					for i,data in ipairs(vtGiftData) do 
						if data.m_iType == ms.giftPackageType.card then
							
							local stStr = data.m_arrParam[2]
							if stStr ~= nil then 
								self:setStar(tonumber(stStr))
							end
							local strTime = data.m_arrParam[4]
							if strTime ~= nil then
								self:setTaste(tonumber(strTime))
							end
							if data.m_arrParam[6] == nil then
								self:setGridImage(tonumber(data.m_arrParam[1]))
								self:updateCount(0)
							end							
							break
						end
					end
				end			
			end
		end
	elseif self.m_GridData ~= nil and self.m_GridData.m_iItemID ~= nil then 				--装备用m_iItemID来识别
		local data = msconfig:getEquipmentByID(self.m_GridData.m_iItemID)
 		if data ~= nil and isLoaderImage == nil then
			self:setGridImage(data.m_iItemID, true)
			self:setEquipGem(data)
		else
			print(string.format("加载的时候找不到这个装备ID = 0x%08x", self.m_GridData.m_iItemID))
		end
		self:updateBindStatus()
		self:setEquipImage()
	end
	self:updateProbability()
end

function PropGrid:setTaste(iExpiredTime)
	if iExpiredTime ~= 0 then
		if self.m_TasteBG == nil then
			self.m_TasteBG = cc.Sprite:create("ui/common/taste.png")
			self.m_TasteBG:setAnchorPoint(cc.p(0, 1))
			self.m_TasteBG:setPosition(2, self.m_GridImage:getContentSize().height + 3)
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


function PropGrid:setEquipGem(equip)
	if self.m_GridData~= nil and self.m_GridData.m_iItemID ~= nil then
		if self.m_GridData.m_aiGemID ~= nil then
			if equip.m_iPos == ms.equipType.main_gun or equip.m_iPos == ms.equipType.vice_gun or equip.m_iPos == ms.equipType.supper_gun then
				for i ,iGemID in ipairs(self.m_GridData.m_aiGemID) do 
					local m_GemImage = self["m_GemImage"..i]
					if m_GemImage == nil then
						m_GemImage = cc.Sprite:create("ui/common/kong1.png")
						m_GemImage:setAnchorPoint(cc.p(0.5, 0.5))
						m_GemImage:setPosition(13 + i * 15, 15)
						m_GemImage:addTo(self, bindArr["m_GemImage"..i].zorder)
						self["m_GemImage"..i] = m_GemImage
					end
					if iGemID == 1 then
						m_GemImage:setTexture("ui/common/kong1.png")
						m_GemImage:setVisible(true)
					elseif iGemID > 1 then
						m_GemImage:setTexture("ui/common/kong2.png")
						m_GemImage:setVisible(true)
					else
						m_GemImage:setVisible(false)
					end
				end
			end
		end
	end
end

function PropGrid:setGridImage(iPropsID, isEquip)
	if not isEquip then
		self.m_iPropID = iPropsID
	end
	if iPropsID == 0 then
		if self.m_GridImage ~= nil then
			self.m_GridImage:setVisible(false)
		end
	else
		local szPath
		if iPropsID < 0 then
			szPath = "ui/common/lock.png"
		else			
	 		local iconID = iPropsID
	 		if not isEquip then
		 		local data = msconfig:getPropsByID(iPropsID)
		 		if data ~= nil then
					iconID = data.m_iIcon
				end
			end
			if iPropsID > 0x11000000 and iPropsID < 0x12000000 then  --卡片
				iconID = iPropsID
			end
			szPath = string.format("image/props/0x%08x.png", iconID)
		end
		if self.m_GridImage == nil then
			self.m_GridImage = cc.Sprite:create(szPath)
			if self.m_GridImage ~= nil then
				self.m_GridImage:setAnchorPoint(cc.p(0.5, 0.5))
				self.m_GridImage:setPosition(36.67, 36.67)
				self.m_GridImage:addTo(self, bindArr['m_GridImage'].zorder)
			end
		else
			self.m_GridImage:setVisible(true)
			self.m_GridImage:setTexture(szPath)
		end
	end
end

function PropGrid:setStar(iStar)
	if iStar == nil or iStar <= 0 then
		if self.m_StarImage ~= nil then
			self.m_StarImage:removeSelf()
			self.m_StarImage = nil
		end
	elseif iStar <= ms.max_star_level then
		if self.m_StarImage == nil then
			self.m_StarImage = cc.Sprite:create()
			self.m_StarImage:setAnchorPoint(cc.p(0, 0))
			self.m_StarImage:setPosition(0, 0)
			self.m_StarImage:addTo(self, 3)
		end
		self.m_StarImage:setTexture(string.format("image/star/%d.png", iStar))
	end
end

function PropGrid:setRadPoint(isGift)
	if isGift == false then
		if self.m_RedPoint ~= nil then
			self.m_RedPoint:removeSelf()
			self.m_RedPoint = nil
		end
	else 
		if self.m_RedPoint == nil then
			self.m_RedPoint = cc.Sprite:create()
			self.m_RedPoint:setAnchorPoint(cc.p(0, 0))
			self.m_RedPoint:setPosition(0, 0)
			self.m_RedPoint:addTo(self, 3)
		end
		self.m_RedPoint:setTexture("ui/common/tip.png")
	end
end

--bShowZero 数量为0的时候也显示
function PropGrid:updateCount(nPropsCount, bRed, bShowZero)
	--if true then return end
	local text = self.m_CountText
	if nPropsCount ~= nil and (nPropsCount > 0 or (bShowZero and nPropsCount == 0)) then
		--数值礼包直接显示里面数值的数量
		if self.m_GridData and self.m_GridData.m_iPropsID ~= nil then
			local iCount = msconfig:getPropsContentCount(self.m_GridData.m_iPropsID)
			nPropsCount = nPropsCount * iCount
		end
		
		local str = string.format("x%d", nPropsCount)
		if nPropsCount >= 10000 then --超过一万就显示 w
			str = string.format("x%dw", math.floor(nPropsCount / 10000))
		end
		if text == nil then
			text = cc.Label:createWithBMFont("ui/fonts/font_grid_num.fnt", str)
			text:setHorizontalAlignment(2)
			text:setVerticalAlignment(2)
			if bRed ~= nil and bRed == true then
				text:setColor(cc.c3b(0xff, 0x00, 0x00))
			end
			--text:enableOutline(cc.c4b(0x0f, 0x0f, 0x0f, 0xcc), 1)
			text:setAnchorPoint(cc.p(1, 0))
			text:setPosition(75, 6)
			text:addTo(self, bindArr['m_CountText'].zorder)
			self.m_CountText = text
		else
			text:setString(str)
			text:setVisible(true)
		end
	elseif text ~= nil then
		text:setVisible(false)
	end
end

function PropGrid:updateProbability()
	local text = self.m_ProbabilityText
	if self.m_GridData ~= nil and self.m_GridData.m_iProbability ~= nil and self.m_GridData.m_iProbability > 0 then
		local str = string.format("%.2f%%",self.m_GridData.m_iProbability / 100)
		if text == nil then
			text = cc.Label:createWithTTF(str, "ui/fonts/FZY4JW.TTF", 20)
			--text:setHorizontalAlignment(2)
			--text:setVerticalAlignment(2)
			text:setAnchorPoint(cc.p(0.5, 0.5))
			text:setPosition(37, 82)
			text:setColor(cc.c3b(0xef, 0xe1, 0xb0)) --efe1b0
			--text:enableOutline(cc.c4b(0x0f, 0x0F, 0x0f, 0x9a), 1)
			text:addTo(self, bindArr['m_ProbabilityText'].zorder)
			self.m_ProbabilityText = text
		end
		text:setString(str)
		text:setVisible(true)

		--底
		if self.m_ProbabilityBG == nil then
			self.m_ProbabilityBG = cc.Sprite:create("ui/bag/wenzidi.png")
			self.m_ProbabilityBG:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_ProbabilityBG:setPosition(cc.p(text:getPositionX(), text:getPositionY() + 2))
			self.m_ProbabilityBG:addTo(self, bindArr["m_ProbabilityBG"].zorder)
		end
	else
		if text ~= nil then
			text:setVisible(false)
		end
		--底
		if self.m_ProbabilityBG ~= nil then
			self.m_ProbabilityBG:removeSelf()
			self.m_ProbabilityBG = nil
		end
	end
end

function PropGrid:setEquipImage()
	if self.m_GridData ~= nil and self.m_GridData.m_iItemID ~= nil then
		if msglobal:checkIsEquip(self.m_GridData.m_szUniqueID) then --已穿戴
			if self.m_IsEquipImage == nil then
				self.m_IsEquipImage = cc.Sprite:create("ui/common/equip.png")
				self.m_IsEquipImage:setAnchorPoint(cc.p(0, 0))
				self.m_IsEquipImage:setPosition(0, 48)
				self.m_IsEquipImage:addTo(self, bindArr["m_IsEquipImage"].zorder)
			end
			self.m_IsEquipImage:setVisible(true)
			return
		end
	end
	if self.m_IsEquipImage ~= nil then
		self.m_IsEquipImage:setVisible(false)
	end
end

function PropGrid:updateBindStatus()
	if self.m_GridData ~= nil then
		if self.m_GridData.m_iPropsID == 0x12700010 then
			self:setBindStatus(true)
			return
		end
		local spicesData = msconfig:getComposeSpicesData(self.m_GridData.m_iPropsID)
		if (spicesData ~= nil and spicesData.m_byBind ~= 0) then
			self:setBindStatus(true)
			return
		end	
		local assistantData = msconfig:getAssistantData(self.m_GridData.m_iPropsID)
		if (assistantData ~= nil and assistantData.m_byBind ~= 0) then
			self:setBindStatus(true)
			return
		end
		local dirllData = msconfig:getDirllDataByID(self.m_GridData.m_iPropsID)
		if (dirllData ~= nil and dirllData.m_byBind ~= 0) then
			self:setBindStatus(true)
			return
		end
		local awlData = msconfig:getAwlDataByID(self.m_GridData.m_iPropsID)
			if (awlData ~= nil and awlData.m_byBind ~= 0) then
			self:setBindStatus(true)
			return
		end
		self:setBindStatus(false)
	end
end

function PropGrid:setBindStatus(bBind)
	if bBind then
		if self.m_BindedBG == nil then 	
			self.m_BindedBG = cc.Sprite:create("ui/common/bind.png")
			self.m_BindedBG:setAnchorPoint(cc.p(1, 1))
			self.m_BindedBG:setPosition(72, 72)
			self.m_BindedBG:addTo(self, bindArr['m_BindedBG'].zorder)
		else
			self.m_BindedBG:setVisible(true)
		end
	elseif self.m_BindedBG ~= nil then
		self.m_BindedBG:setVisible(false)
	end
end

function PropGrid:setSelectStatus(bSelected, bColor)
	self:setSelect(bSelected)
	self:setColor(bColor)
end

function PropGrid:getSelectStatus()
	return self.m_SelectedBG ~= nil and self.m_SelectedBG:isVisible()
end

function PropGrid:setSelect(bSelected)
	if bSelected then
		if self.m_SelectedBG == nil then 	
			self.m_SelectedBG = cc.Sprite:create("ui/common/prop_select_bg.png")
			self.m_SelectedBG:setAnchorPoint(cc.p(0.5, 0.5))
			self.m_SelectedBG:setPosition(36.67, 36.67)
			self.m_SelectedBG:addTo(self, bindArr['m_SelectedBG'].zorder)
		else
			self.m_SelectedBG:setVisible(true)
		end
	elseif self.m_SelectedBG ~= nil then
		self.m_SelectedBG:setVisible(false)
	end
end

function PropGrid:setColor(bColor)
	if self.m_GridImage ~= nil then
		if bColor == true then
			self.m_GridImage:setColor(cc.c3b(100,100,100))
		else
			self.m_GridImage:setColor(cc.c3b(255,255,255))
		end
	end
end

function PropGrid:setNewFlag(flag)
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

function PropGrid:getNewFlag()
	return self.m_NewFlagBG and self.m_NewFlagBG:isVisible() 
end

function PropGrid:touchEvent(sender, eventType)

	if self.m_BaseListCallBackFunc ~= nil then
		if self.super ~= nil and self.super["onTouchEvent"] ~= nil and (not self.m_bAlwaysClick) then --持续点击的事件响应的时候不响应单次点击事件
			self.super:onTouchEvent(self, eventType)
		end
	    if eventType == ccui.TouchEventType.began then
	    	self.m_bAlwaysClick = false
	    	if self.m_BaseListAlwaysCallBackFunc ~= nil then
	    		self:performWithDelay(function()
	    			self.m_bAlwaysClick = true --持续点击的事件响应了
	    			self.super:onAlwaysTouchEvent(self)
	    			end, 0.5)
	    	else
	    		self:performWithDelay(handler(self,self.updateGridTip), 1.5)
	    	end
			return true
		end
		if eventType == ccui.TouchEventType.moved then 
		    if self.m_bShowDescTip then
				self.m_bShowDescTip = false
		    	TipsMgr:removeDescTip(self, nil)
		    end
		end
	    if eventType == ccui.TouchEventType.ended then 
	    	audio.playSound(audio_file.menu_up,false)
			if self.m_bShowDescTip then
				self.m_bShowDescTip = false
		    	TipsMgr:removeDescTip(self, nil)
		    end
	    end
	else
		if eventType == 2 and self.m_GridData ~= nil then
			print("eventType=",eventType)
			
			if self.m_GridData.m_iItemID ~= nil then
				--dumppb(self.m_GridData)
	            FloatTipsMgr:showAllFloatProps(self.m_GridData.m_iItemID, self.m_GridData)
	        elseif self.m_GridData.m_iPropsID ~= nil then
	            local data = msconfig:getPropsByID(self.m_GridData.m_iPropsID)
	            --dump(self.m_GridData)
	            --dump(data)
	            if data ~= nil then
	                FloatTipsMgr:showAllFloatProps(self.m_GridData.m_iPropsID)
	                return
				end
				local card = msconfig:getCardData(self.m_GridData.m_iPropsID)
				if card ~= nil then
					local cardInfo = {}
					cardInfo.m_iCardID = self.m_GridData.m_iPropsID
					cardInfo.m_nLevel = self.m_GridData.m_iPropsCount
					cardInfo.m_byBind = self.m_GridData.m_byBind
					if self.m_GridData.m_abyRandAttr ~= nil then
						cardInfo.m_abyRandAttr = self.m_GridData.m_abyRandAttr
					end
					FloatTipsMgr:setCardTipsData(cardInfo)
				end
	        end
		end
	end
    self:stopAllActions()
end

function PropGrid:setTipsSubType(iTipsSubType)                       --给那些知道propid还不知道是什么东西的prop,例如许愿池
	self.m_iTipsSubType = iTipsSubType
end

function PropGrid:updateGridTip(sender)
	if self.m_iPropID ~= nil then
		mslog("m_iPropsID = 0x%08x", self.m_iPropID)
		local props = msconfig:getPropsByID(self.m_iPropID)
		if props ~= nil then
			if  props.m_szDesc  ~= nil then
				self.m_bShowDescTip = true
				local str = props.m_szDesc
				--配方
		        if props.m_iType == ms.propsType.material and props.m_iSubType == ms.materialSubType.formula then
		            local composeRule = msconfig:getComposeRuleByFormulaID(props.m_iPropsID)
		            local cardData = msconfig:getCardData(composeRule.m_iCardID)
		            local strMaterial = ""
		            for _,material in ipairs(composeRule.material) do
		                local materialData = msconfig:getPropsByID(material.m_iPropsID)
		                strMaterial = strMaterial.."["..materialData.m_szName.."]"
		            end
					str = string.format(language_ch.cn_61, cardData.m_szCardName, strMaterial)
		        end
		        --材料
		        if props.m_iType == ms.propsType.material and props.m_iSubType == ms.materialSubType.material then
		            local strCard = ""
		            local composeRuleTable = msconfig:getComposeRuleByMaterialID(props.m_iPropsID)
		            for _,rule in ipairs(composeRuleTable) do
		                local cardData = msconfig:getCardData(rule.m_iCardID)
		                if cardData ~= nil then
		                    strCard = strCard.."["..cardData.m_szCardName.."]"
		                end
		            end
					str = string.format(language_ch.cn_62, strCard)
		        end
		        --香料
		        if props.m_iType == ms.propsType.props and props.m_iSubType == ms.propsSubType.spices then
					str = string.format(language_ch.cn_63, props.m_szDesc)
		        end
		        --四叶草
		        if props.m_iType == ms.propsType.props and props.m_iSubType == ms.propsSubType.clover then
		           	str = string.format(language_ch.cn_64, props.m_szDesc)
		        end
		        --技能书
		        if props.m_iType == ms.propsType.props and props.m_iSubType == ms.propsSubType.skill then
		           	local skillData = msconfig:getCardSkillByBookID(props.m_iPropsID)
		           	str = string.format(language_ch.cn_65, skillData.m_szSkillDesc, props.m_szDesc, skillData.m_szEffectDesc)
		        end

                if props.m_iType == ms.propsType.props and props.m_iSubType == ms.propsSubType.show then       --例如许愿池展示的12个type
                    local showData = msconfig:getPropsIDByPropsShowType(self.m_iTipsSubType, props.m_iPropsID)
                    for _, v in ipairs(showData) do 
                    	str = str .. msconfig:getPropsByID(v).m_szName .. "\n"
                    end
                end

				TipsMgr:addDescTip(str,self:getWorldPosition(), cc.size(300, 0))
			end
		end
		self:stopAllActions()
	end
end

function PropGrid:showGridEffect(isShow)
	if isShow then
		if self.m_GridEffect == nil then
		    self.m_GridEffect = require("app.component.EffectPlayer").new("daojutexiao", "root")
		   	self.m_GridEffect:playAction("loop")
		   	self.m_GridEffect:setAnchorPoint(cc.p(0.5,0.5))
		   	self.m_GridEffect:setPosition(self:getContentSize().width/2  ,self:getContentSize().height/2 )
		    self:addChild(self.m_GridEffect,100)
	    end		
    else
    	if self.m_GridEffect ~= nil then
    		self.m_GridEffect:removeSelf()
    		self.m_GridEffect = nil
    	end
   	end
end

function PropGrid:addEvent()
	self:addTouchEventListener(handler(self,self.touchEvent))
	self:setTouchEnabled(true)
end

function PropGrid:removeEvent()
	self:setTouchEnabled(false)
	self:removeTouchEvent()
end

return PropGrid