
local BaseList = class("BaseList", function()
    return ccui.ScrollView:create()
end)

--------------------------------
--list中的格子需继承BaseWidget
--调用方式：
--------------------------------

--基本设置
--self:setBounceEnabled(true) -- 反弹
--self:setContentSize(cc.size(240, 300)) -- 大小
--self:setPosition(cc.p(500, 300)) -- 位置
--self:setFormSize(3, 3)  --范围
--self:setGridSize(10, 10)  --间隔

--方向
--self:setDirection(ccui.ScrollViewDir.vertical)
--self:setDirection(ccui.ScrollViewDir.horizontal)

--设置格子文件名
--self:setGridFileName("app.ui.base.PropGrid")

--更新数据
--self:updateList({}) 

--设置格子事件（如点击）的回调函数（格子需自己调用BaseWidget的onTouchEvent方法触发回调）
--self:setGridEvent(handler(self, self.TouchTest)) 

--function BaseList:TouchTest(sender, eventType)
--	if eventType == 2 then print("点击测试") end
--end

--------------------------------


function BaseList:ctor()
	self.m_iRowCount = 1
	self.m_iColumnCount = 1
	self.m_iDataCount = 0
	self.m_iRealColumnCount = 1
	self.m_iRealRowCount = 1
	self.m_iRealGridCount = 0
	self.m_iGridWidth = 10
	self.m_iGridHeight = 10
	self.m_arrGridList = {} --格子列表
	self.m_arrDataList = {} --格子数据
	self.m_arrBlockList = {}
	self.m_funcClickCallBack = nil --格子事件
	self.m_funcEachGridLoadedCallBack = nil --单个格子加载完成
	self.m_funcAllGridLoadedCallBack = nil --所有格子加载完成
	self.m_iUpdateIndex = 0
	self.m_iInnerWidth = 10
	self.m_iInnerHeight = 10
	self.m_ifDelayTime = 0.1
	self.m_iUpdateImageIndex = 1
	self.m_iGridOffsetY = 0
end

--设置默认范围（任务列表可以是0*1，仅自增row，row=0时无显示； 格子列表可以是5*4，列表为空时至少显示row=5）
function BaseList:setFormSize(iRowCount, iColumnCount)
	self.m_iRowCount = iRowCount
	self.m_iColumnCount = iColumnCount
end

--设置格子长宽
function BaseList:setGridSize(iGridWidth, iGridHeight)
	self.m_iGridWidth = iGridWidth
	self.m_iGridHeight = iGridHeight
end

--设置格子事件
function BaseList:setGridEvent(callback)
	self.m_funcClickCallBack = callback
	self:updateGridEvent()
end

--设置加载格子的间隔
function BaseList:setLoadDelayTime(fDelayTime)
	self.m_ifDelayTime = fDelayTime
end

--设置纵向偏移坐标
function BaseList:setGridOffsetY(offset)
	self.m_iGridOffsetY = offset
end

--设置每个格子加载完成后的回调
--回调参数（index, grid)
function BaseList:setEachGridLoaded(callback)
	self.m_funcEachGridLoadedCallBack = callback
end

--设置所有格子加载完成后的回调
--无回调函数
function BaseList:setAllGridLoaded(callback)
	self.m_funcAllGridLoadedCallBack = callback
end

--设置格子文件名
function BaseList:setGridFileName(szClassName)
	self.m_szClassName = szClassName
end

--更新数据
function BaseList:updateList(arrData, bRestorePos)
	local iPosX, iPosY = 0, 0
	if bRestorePos then
		if #self.m_arrGridList > 0 then
			iPosX = self:getInnerContainer():getPositionX()
			iPosY = self:getInnerContainer():getPositionY()
		else
			bRestorePos = false
		end
	end

	self:clearGridList()
	if self.m_szClassName == nil then
		return
	end

	self:stopAllActions()
	local iDirection = self:getDirection()
	if iDirection == ccui.ScrollViewDir.vertical then
		self.m_arrDataList = arrData
		self.m_iUpdateIndex = 0
		self:updateRealFormSizeOfVertical(#arrData)		
		self.m_iInnerWidth = self.m_iGridWidth * self.m_iRealColumnCount
		self.m_iInnerHeight = self.m_iGridHeight * self.m_iRealRowCount
		self.m_iInnerHeight = self.m_iInnerHeight < self:getContentSize().height and self:getContentSize().height or self.m_iInnerHeight
		self:setInnerContainerSize(cc.size(self.m_iInnerWidth, self.m_iInnerHeight))
		
		--self:updateGridOfVertical()--
		--self:checkSurplusGird()
		self:updateDataVertical()
		self:updateGridImageData()
		self:requestDoLayout()
		self:jumpToTop()
	elseif iDirection == ccui.ScrollViewDir.horizontal then
		self.m_arrDataList = arrData
		self.m_iUpdateIndex = 0
		self:updateRealFormSizeOfHorizontal(#arrData)		
		self.m_iInnerWidth = self.m_iGridWidth * self.m_iRealColumnCount
		self.m_iInnerHeight = self.m_iGridHeight * self.m_iRealRowCount
		self.m_iInnerWidth = self.m_iInnerWidth < self:getContentSize().width and self:getContentSize().width or self.m_iInnerWidth
		self:setInnerContainerSize(cc.size(self.m_iInnerWidth, self.m_iInnerHeight))
		self:updateDataHorizontal()
		--self:updateGridOfHorizontal()
		--self:checkSurplusGird()
		self:updateGridImageData()
		self:requestDoLayout()
		self:jumpToLeft()
	end

	if bRestorePos then
		self:getInnerContainer():setPosition(cc.p(iPosX, iPosY))
	end
end

function BaseList:jumpTo()
	local iDirection = self:getDirection()
	if iDirection == ccui.ScrollViewDir.vertical then
		self:requestDoLayout()
		self:jumpToTop()
	elseif iDirection == ccui.ScrollViewDir.horizontal then
		self:requestDoLayout()
		self:jumpToLeft()
	end
end

function BaseList:bInit()
	return self.m_bInit
end

--清空格子
function BaseList:clearGridList()
	if self.m_arrGridList ~= nil then
		for _, grid in ipairs(self.m_arrGridList) do
			grid:removeSelf()
		end
	end
	self:removeAllChildren()
	self.m_arrGridList = {}
    self.m_arrBlockList = {}
    self.m_arrDataList = {}
end

--格子列表
function BaseList:getGridList()
	return self.m_arrGridList
end

--格子数据
function BaseList:getDataList()
	return self.m_arrDataList
end

--更新数据
--若当前格子有显示，则会刷新显示
function BaseList:updateGridData(iDataIndex, newData)
	local data = self.m_arrDataList[iDataIndex] 
	if data ~= nil then
		local targetGrid = nil
		for _, grid in ipairs(self.m_arrGridList) do
			if data == grid:getData() then
				targetGrid = grid
				break
			end
		end
		if targetGrid ~= nil then
			targetGrid:setData(newData)
		end
	end
	self.m_arrDataList[iDataIndex] = newDatad
end

----------------------------------------------------------------------------
--以下内部方法，一般不要调用
----------------------------------------------------------------------------


--检查多余的格子
function BaseList:checkSurplusGird()
	if 	self.m_arrGridList and self.m_arrDataList then
		while #self.m_arrGridList > #self.m_arrDataList do
			--local iIndex = 1 + #self.m_arrDataList
			local grid = table.remove(self.m_arrGridList, #self.m_arrGridList)
			if grid ~= nil then
				grid:removeFromParent(true)
			end
			--print("#self.m_arrGridList ="..#self.m_arrGridList)
		end
	end
end

--更新事件 
function BaseList:updateGridEvent()
	if self.m_arrGridList ~= nil and self.m_funcClickCallBack ~= nil then
		for _, grid in ipairs(self.m_arrGridList) do
			if grid.addCallBackFunc ~= nil then
				grid:addCallBackFunc(grid, self.m_funcClickCallBack)
			end
		end
	end
end

--更新真实格子范围
function BaseList:updateRealFormSizeOfVertical(iDataSize)
	
	if self.m_iColumnCount ~= nil and self.m_iColumnCount > 0 then
		self.m_iRealColumnCount = self.m_iColumnCount
	else
		self.m_iRealColumnCount = 1
	end
	if iDataSize == nil then
		iDataSize = 0
	end
	self.m_iRealRowCount = math.floor((iDataSize + self.m_iRealColumnCount - 1) / self.m_iRealColumnCount)
	if self.m_iRowCount ~= nil and self.m_iRowCount > self.m_iRealRowCount then
		self.m_iRealRowCount = self.m_iRowCount
	end
	self.m_iRealGridCount = self.m_iRealRowCount * self.m_iRealColumnCount
	--print("self.m_iRealGridCount = "..self.m_iRealGridCount)
	self.m_iDataCount = iDataSize
end
----更新数据先，然后再更新图片

function BaseList:updateDataVertical()
	local iUpdateIndex = 0
	while iUpdateIndex  < self.m_iRealGridCount do
		local iRow = math.floor(iUpdateIndex / self.m_iRealColumnCount) + 1
		local iColumn = iUpdateIndex - self.m_iRealColumnCount * (iRow - 1) + 1
		local layout = self:getBlock(iRow, 0, self.m_iInnerHeight - self.m_iGridHeight * iRow)
		iUpdateIndex = iUpdateIndex + 1
		self:pushGrid(iUpdateIndex, layout, self.m_iGridWidth * iColumn - self.m_iGridWidth / 2, self.m_iGridHeight / 2)
	end	
	self.m_iUpdateImageIndex = 0
end
--更新真实格子范围
function BaseList:updateRealFormSizeOfHorizontal(iDataSize)
	if self.m_iRowCount ~= nil and self.m_iRowCount > 0 then
		self.m_iRealRowCount = self.m_iRowCount
	else
		self.m_iRealRowCount = 1
	end
	if iDataSize == nil then
		iDataSize = 0
	end
	self.m_iRealColumnCount = math.floor((iDataSize + self.m_iRealRowCount - 1) / self.m_iRealRowCount)
	if self.m_iColumnCount ~= nil and self.m_iColumnCount > self.m_iRealColumnCount then
		self.m_iRealColumnCount = self.m_iColumnCount
	end
	self.m_iRealGridCount = self.m_iRealColumnCount * self.m_iRealRowCount
	self.m_iDataCount = iDataSize
end
----更新数据先，然后再更新图片
function BaseList:updateDataHorizontal()
	local iUpdateIndex = 0
	while iUpdateIndex  < self.m_iRealGridCount do
		local iColumn = math.floor(iUpdateIndex / self.m_iRealRowCount) + 1
		local iRow = iUpdateIndex - self.m_iRealRowCount * (iColumn - 1) + 1
		local layout = self:getBlock(iColumn, self.m_iGridWidth * (iColumn - 1), 0)

		iUpdateIndex = iUpdateIndex + 1
		self:pushGrid(iUpdateIndex, layout, self.m_iGridWidth / 2, self.m_iInnerHeight - self.m_iGridHeight * (iRow - 0.5)) 
	end
	self.m_iUpdateImageIndex = 0
end
--分帧更新格子数据
function BaseList:updateGridImageData()
	if self.m_iUpdateImageIndex < #self.m_arrGridList then
		local grid = self.m_arrGridList[self.m_iUpdateImageIndex + 1]
		--print(self.m_iUpdateImageIndex,#self.m_arrGridList,grid:getData())
		if grid ~= nil and grid["loaderImage"] ~= nil then
			grid:loaderImage()
			self.m_iUpdateImageIndex  = self.m_iUpdateImageIndex  + 1
			self:nextGridUpdate(self.m_iUpdateImageIndex, self.updateGridImageData)
			if self.m_funcEachGridLoadedCallBack ~= nil then
				self.m_funcEachGridLoadedCallBack(self.m_iUpdateImageIndex, grid)
			end
		end
	else
		if self.m_funcAllGridLoadedCallBack ~= nil then
			self.m_funcAllGridLoadedCallBack()
		end
	end
end

--分帧更新格子数据
function BaseList:updateGridOfVertical()
	local iUpdateIndex = self.m_iUpdateIndex
	if iUpdateIndex < self.m_iRealGridCount then
		local iRow = math.floor(iUpdateIndex / self.m_iRealColumnCount) + 1
		local iColumn = iUpdateIndex - self.m_iRealColumnCount * (iRow - 1) + 1
		local layout = self:getBlock(iRow, 0, self.m_iInnerHeight - self.m_iGridHeight * iRow)

		iUpdateIndex = iUpdateIndex + 1
		self:pushGrid(iUpdateIndex, layout, self.m_iGridWidth * iColumn - self.m_iGridWidth / 2, self.m_iGridHeight / 2)
		self:nextGridUpdate(iUpdateIndex, self.updateGridOfVertical)
	end
end

--分帧更新格子数据
function BaseList:updateGridOfHorizontal()
	local iUpdateIndex = self.m_iUpdateIndex
	if iUpdateIndex < self.m_iRealGridCount then
		local iColumn = math.floor(iUpdateIndex / self.m_iRealRowCount) + 1
		local iRow = iUpdateIndex - self.m_iRealRowCount * (iColumn - 1) + 1
		local layout = self:getBlock(iColumn, self.m_iGridWidth * (iColumn - 1), 0)

		iUpdateIndex = iUpdateIndex + 1
		self:pushGrid(iUpdateIndex, layout, self.m_iGridWidth / 2, self.m_iInnerHeight - self.m_iGridHeight * (iRow - 0.5)) 
		self:nextGridUpdate(iUpdateIndex, self.updateGridOfHorizontal)
	end
end

--
function BaseList:nextGridUpdate(index, func)
	self.m_iUpdateIndex = index
	if index < self.m_iRealGridCount then
		self:runAction(cc.Sequence:create(
			cc.DelayTime:create(self.m_ifDelayTime),
			cc.CallFunc:create(handler(self, func))
			))
	else
		if self.m_funcAllGridLoadedCallBack ~= nil then
			self.m_funcAllGridLoadedCallBack()
		end
	end
end

function BaseList:getBlock(index, posX, posY)
	local layout = nil
	if index > #self.m_arrBlockList then
		layout = ccui.Widget:create()
		layout:setAnchorPoint(cc.p(0, 0))
		layout:setContentSize(cc.size(self.m_iGridWidth, self.m_iGridHeight))
		layout:setPosition(posX, posY)
    	self:addChild(layout)
		table.insert(self.m_arrBlockList, layout)
	else
		layout = self.m_arrBlockList[index]
	end
	--dump(layout:getPosition())
	return layout
end
--
function BaseList:pushGrid(index, layout, posX, posY)	 
	if layout ~= nil then
		local grid = nil
		if index <= #self.m_arrGridList then
			grid = self.m_arrGridList[index]
		else
			grid = CacheMgr:getCacheGrid(self.m_szClassName)
			grid:setAnchorPoint(cc.p(0.5, 0.5))
			grid:setPosition(posX, posY + self.m_iGridOffsetY)
			layout:addChild(grid)
			grid:setVisible(true)
			table.insert(self.m_arrGridList, grid)	
		end
		if grid ~= nil then
			local arrData = self.m_arrDataList
			if index <= #arrData then 
				grid:setData(arrData[index], index,false)
			else
				grid:setData(nil, index)
			end

			if self.m_funcClickCallBack ~= nil then
				grid:addCallBackFunc(grid, self.m_funcClickCallBack)
			end
			
			if self.m_funcEachGridLoadedCallBack ~= nil then
				self.m_funcEachGridLoadedCallBack(index, grid)
			end
		end
    	--grid:setScale(0.7)
    	--grid:runAction(cc.ScaleTo:create(0.1, 1))
	end
end

return BaseList