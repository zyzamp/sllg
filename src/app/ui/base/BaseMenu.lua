local BaseMenu = class("BaseMenu", require("app.ui.BaseDialog"))

function BaseMenu:ctor()
	self.super.ctor(self)
	self.m_CallBack = nil
end

function BaseMenu:init(resourceNode,bindArr,parent,callBack)
	self:bindByNode(resourceNode, bindArr) 
 	self.m_iSelectIndex = 0
 	self.m_BindArr = bindArr
 	self.m_Parent = parent
 	self.m_CallBack = callBack
 	local iCount = 0
 	for _,data in pairs(bindArr) do
 		if data.index ~= nil and data.index >= iCount then
 			iCount = data.index
 		end
 	end
 	---------- 这里要注意，其他地方用到这个菜单的时候，需要注意这里的引导
 	--------后面要清空掉
 	if FairyGuide.m_iSubTag ~= nil and FairyGuide.m_iSubTag <= iCount then
 		self.m_iSelectIndex = FairyGuide.m_iSubTag
 	end  
	for nodeName, nodeBinding in pairs(bindArr) do
		local down = resourceNode:getChildByName(nodeBinding.varname)
		--print(down:getName())
        if nodeBinding.index == self.m_iSelectIndex then
 			self:updateMenuStatus(down)
 			break           
        end
    end
    FairyGuide.m_iSubTag = nil
end

function BaseMenu:getSelectIndex()
	return self.m_iSelectIndex
end

function BaseMenu:updateSelectIndex(iSelectIndex)
	for nodeName, nodeBinding in pairs(self.m_BindArr) do
	    if nodeBinding.index == iSelectIndex then
 			self.m_TabUp:setPosition(self[nodeBinding.varname]:getPosition())
 			self.m_iSelectIndex = nodeBinding.index
 			if self.m_Parent ~= nil then
 				if self.m_CallBack == nil then
	 				self.m_Parent:selectTable(self.m_iSelectIndex)       
	 			else
	 				self.m_CallBack(self.m_iSelectIndex)       
	 			end
 			end
 			--print(string.format("BaseMenu:touchEvent1 = %s,%s,%d",sender:getName(),nodeBinding.varname,self.m_iSelectIndex))    
        end     
    end
end

function BaseMenu:updateMenuStatus(sender)  
	EffectMgr:removeFingerGuideMask(sender, nil, nil, true)	
	for nodeName, nodeBinding in pairs(self.m_BindArr) do			
	    if nodeBinding.varname == sender:getName() then
			self.m_TabUp:setPosition(sender:getPosition())
			self.m_iSelectIndex = nodeBinding.index
			if self.m_Parent ~= nil then
				if self.m_CallBack == nil then
 					self.m_Parent:selectTable(self.m_iSelectIndex)       
	 			else
	 				self.m_CallBack(self.m_iSelectIndex)       
	 			end     
			end
	    end     
	end
end

function BaseMenu:touchEvent(sender, eventType)
    if eventType == 2 then 
    	mslog(string.format("BaseMenu:touchEvent = %s",sender:getName()))   
		self:updateMenuStatus(sender)
	    audio.playSound(audio_file.menu_up,false)
    end
end

return BaseMenu