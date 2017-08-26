local BaseDialog = class("BaseDialog", function() return cc.Node:create() end)

------------------通用定义-----------------

-------------------------------------------

function BaseDialog:ctor()
	
end

--设置遮罩
function BaseDialog:setMask(iZorder, bEatClick)
	if iZorder == nil then iZorder = -1 end
	if bEatClick == nil then bEatClick = true end
	if self.m_BaseBgMask ~= nil then
		self.m_BaseBgMask:removeFromParent(true)
		self.m_BaseBgMask = nil
	end
	local mask = self.m_BaseBgMask
	if mask == nil then
		mask = msfunc.getMask(self, 150, bEatClick)
    	mask:setLocalZOrder(iZorder)
		mask:addTo(self)
	end
	self.m_BaseBgMask = mask
	self:sortAllChildren()
end

function BaseDialog:removeMask()
	if self.m_BaseBgMask ~= nil then
		self.m_BaseBgMask:removeFromParent(true)
		self.m_BaseBgMask = nil		
	end
end

--创建 定义在GlobalEnum.lua中
function BaseDialog:bindByTag(iTag, bindArr, iZorder)
	--获取资源
	local data = msmodule[iTag]
	if data == nil then
		printf("Error: Tag = %d 未定义", iTag)
		return 
	end
	--读取节点
	local resNode = cc.uiloader:load(data.szRes)
	if resNode == nil then
		printf("Error: %s 加载失败", data.szRes)
		return 
	end
	--移除名称重复的节点
	local lastNode = self:getChildByName(data.szName) 
	if lastNode ~= nil then lastNode:removeSelf() end
	--添加节点
	if iZorder == nil then iZorder = 0 end
	resNode:setName(data.szName)
	resNode:addTo(self, iZorder)
	--绑定节点
    self:bindByNode(resNode, bindArr)
end

--绑定 资源名
function BaseDialog:bindByFile(szResFile, bindArr)
	local resNode = cc.uiloader:load(szResFile)
	if resNode == nil then
		printf("Error: %s 加载失败", data.szRes)
		return 
	end
    self:bindByNode(resNode, bindArr)
    return resNode
end

--绑定 定义在msfunctions.lua中
function BaseDialog:bindByNode(resNode, bindArr)
	if resNode:getParent() == nil then
		resNode:addTo(self)
	end
    msfunc.resoueceBinding(self, resNode, bindArr)
end

--设置为全局Tag单例
function BaseDialog:setToGlobal(iTag)
	msglobal.ui[iTag] = self
	self.m_iGlobalUITag = iTag
    self:registerNodeEvent()
end

function BaseDialog:removeFromGlobal()
    if self.m_iGlobalUITag ~= nil then 
        msglobal.ui[self.m_iGlobalUITag] = nil
        self.m_iGlobalUITag = nil
    end
end

--节点清理时，调用清理方法
function BaseDialog:onCleanUpCallBack()
	local arrList = self.m_arrCleanUpCallback 
	if arrList ~= nil then
		for _,func in ipairs(arrList) do
			func(self)
		end
	end
	self:removeFromGlobal()
end

--通过右上角topbar关闭时触发
function BaseDialog:onMenuClose()
end

------------------------------------------------------
--事件
------------------------------------------------------

--此操作将占用cc.NODE_EVENT事件
--调用注册之后，可以直接创建 onEnter()、onExit()、onEnterTransitionFinish()、onExitTransitionStart()、cleanup() 等方法
function BaseDialog:registerNodeEvent()
	if self.m_bIsNodeEvent then return end            
	--self:setNodeEventEnabled(true)
	self:addNodeEventListener(cc.NODE_EVENT, function (event)
        if event.name == "enter" then if self.onEnter ~= nil then self:onEnter() end
        elseif event.name == "exit" then if self.onExit ~= nil then self:onExit() end
        elseif event.name == "enterTransitionFinish" then if self.onEnterTransitionFinish ~= nil then self:onEnterTransitionFinish() end
        elseif event.name == "exitTransitionStart" then if self.onExitTransitionStart ~= nil then self:onExitTransitionStart() end
        elseif event.name == "cleanup" then if self.onCleanup ~= nil then self:onCleanup() end
			--self:unRegisterNodeEvent()
        	self:onCleanUpCallBack() 
        end
    end)
	self.m_bIsNodeEvent = true
end

function BaseDialog:unRegisterNodeEvent()
	self:removeNodeEventListenersByEvent(cc.NODE_EVENT)
	self.m_bIsNodeEvent = nil
end

--节点清理事件，当节点被清理时触发（一般用于清除该节点在其它地方的引用）
function BaseDialog:registerCleanUpCallback(func)
	if func == nil then return end
	local arrList = self.m_arrCleanUpCallback 
	if arrList == nil then
		arrList = {}
		self.m_arrCleanUpCallback = arrList
	end
	table.insert(arrList, func)
	self:registerNodeEvent()
end

return BaseDialog
