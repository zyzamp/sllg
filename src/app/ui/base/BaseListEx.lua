
local BaseListEx = class("BaseListEx", function()
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

--设置格子文件名
--self:setGridFileName("app.ui.base.PropGrid")

--更新数据
--self:updateList({}) 

--设置格子事件（如点击）的回调函数（格子需自己调用BaseWidget的onTouchEvent方法触发回调）
--self:setGridEvent(handler(self, self.TouchTest)) 

--function BaseListEx:TouchTest(sender, eventType)
--	if eventType == 2 then print("点击测试") end
--end

--------------------------------


function BaseListEx:ctor()
	self.m_iRowCount = 1
	self.m_iColumnCount = 1
	self.m_iGridWidth = 10
	self.m_iGridHeight = 10
	self.m_arrGridList = {} --格子列表
	self.m_arrDataList = {} --格子数据
	self.m_arrBlockList = {} --格子模块
	self.m_GridEvent = nil --格子事件
	self.m_bInit = false --初始化
	self.innerWidth = 10
	self.innerHeight = 10
	self.iRealColumnCount = 1
	self.iRealRowCount = 1
	self.iBlockBeginIndex = 1
	self.iBlockEndIndex = 1
	self.m_iShowRowCount = 1
	self.m_iShowColumnCount = 1
	self.m_GridExtValue = nil
end

--设置默认范围（任务列表可以是0*1，仅自增row，row=0时无显示； 格子列表可以是5*4，列表为空时至少显示row=5）
function BaseListEx:setFormSize(iRowCount, iColumnCount)
	self.m_iRowCount = iRowCount
	self.m_iColumnCount = iColumnCount
end

--设置显示范围（任务列表可以是3*1，当格子row>3时，最多创建showRow=3+1）
function BaseListEx:setShowSize(iShowRowCount, iShowColumnCount)
	self.m_iShowRowCount = iShowRowCount
	self.m_iShowColumnCount = iShowColumnCount
end

--设置格子间距
function BaseListEx:setGridSize(iGridWidth, iGridHeight)
	self.m_iGridWidth = iGridWidth
	self.m_iGridHeight = iGridHeight
end

--设置格子事件
function BaseListEx:setGridEvent(callback)
	self.m_GridEvent = callback
	self:updateGridEvent()
end

--设置格子文件名
function BaseListEx:setGridFileName(szClassName)
	self.m_szClassName = szClassName
end

--设置格子的额外数据 当做setData()的第三个参数
function BaseListEx:setGridExtValue(value)
	self.m_GridExtValue = value
end

--更新数据(bRestorePos表示是否让列表停留在更新之前的位置)
function BaseListEx:updateList(arrData, bRestorePos)
	local iPosY = 0
	if bRestorePos then
		if #self.m_arrGridList > 0 then
			iPosY = self:getInnerContainer():getPositionY()
		else
			bRestorePos = false
		end
	end

	self:clearGridList()
	if self.m_szClassName == nil then
		return
	end
	local iDirection = self:getDirection()
	if iDirection == ccui.ScrollViewDir.vertical then
		self:dealWithVertical(arrData)
	elseif iDirection == ccui.ScrollViewDir.horizontal then
		--self:dealWithHorizontal(...)
	end
	self:updateGridEvent()

	if bRestorePos then
		self:getInnerContainer():setPositionY(iPosY)
		self:onScrollEvent(nil, 2)
	end
end

function BaseListEx:bInit()
	return self.m_bInit
end

--清空格子
function BaseListEx:clearGridList()
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
function BaseListEx:getGridList()
	return self.m_arrGridList
end

--格子数据
function BaseListEx:getDataList()
	return self.m_arrDataList
end

--更新数据
--若当前格子有显示，则会刷新显示
function BaseListEx:updateGridData(iDataIndex, newData)
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
			targetGrid:setData(newData, iDataIndex, self.m_GridExtValue)
		end
	end
	self.m_arrDataList[iDataIndex] = newDatad
end

----------------------------------------------------------------------------
--以下内部方法，一般不要调用
----------------------------------------------------------------------------

--更新事件 
function BaseListEx:updateGridEvent()
	if self.m_arrGridList ~= nil and self.m_GridEvent ~= nil then
		for _, grid in ipairs(self.m_arrGridList) do
			if grid.addCallBackFunc ~= nil then
				grid:addCallBackFunc(grid, self.m_GridEvent)
			end
		end
	end
end


--设置纵向表格
--@arrData 数据
--@szClassName 格子文件名
function BaseListEx:dealWithVertical(arrData)
	if arrData == nil or self.m_szClassName == nil then return end

	local fHalfGridWidth = self.m_iGridWidth / 2
	local fHalfGridHeight = self.m_iGridHeight / 2
	local iDataSize = table.getn(arrData)
	self.iRealColumnCount = self.m_iColumnCount
	self.iRealRowCount = math.floor((iDataSize + self.iRealColumnCount - 1) / self.iRealColumnCount)
	self.iRealRowCount = math.max(self.iRealRowCount, self.m_iRowCount)
	local iShowRowCount = self.iRealRowCount 
	if iShowRowCount > self.m_iShowRowCount then iShowRowCount = self.m_iShowRowCount + 1 end
	self.innerWidth = self.m_iGridWidth * self.iRealColumnCount
	self.innerHeight = self.m_iGridHeight * math.max(self.m_iShowRowCount, self.iRealRowCount)
	self.m_arrDataList = arrData
	for iRow = 1, iShowRowCount do
        local layout = ccui.Widget:create()
		for iColumn = 1, self.iRealColumnCount do
			grid = CacheMgr:getCacheGrid(self.m_szClassName)
			grid:setAnchorPoint(cc.p(0.5, 0.5))
			grid:setPosition(self.m_iGridWidth * iColumn - fHalfGridWidth, fHalfGridHeight)
			grid:addTo(layout)
			table.insert(self.m_arrGridList, grid)
		end
		layout:setAnchorPoint(cc.p(0, 0))
		layout:setContentSize(cc.size(fHalfGridWidth * self.iRealColumnCount, self.m_iGridHeight))
		layout:setVisible(false)
        self:addChild(layout)
		table.insert(self.m_arrBlockList, layout)
	end
	self.m_bInit = false
	self:setInnerContainerSize(cc.size(self:getContentSize().width, self.innerHeight))
	self:requestDoLayout()
	self:jumpToTop()

	self.m_bInit = true
	self:setDirection(ccui.ScrollViewDir.vertical)
    self:addEventListener(handler(self, self.onScrollEvent))
    self:onScrollEvent(nil, 0)
end

--更新格子数据
--@param iBlockIndex 格子集合的索引
--@param iRow 更新此行的数据
function BaseListEx:updateBlockGrid(iBlockIndex,  iRow)
	local iGridStartIndex = (iBlockIndex - 1) * self.iRealColumnCount
	local iDataStartIndex = (iRow - 1) * self.iRealColumnCount
	for i = 1, self.iRealColumnCount do
		local grid = self.m_arrGridList[i + iGridStartIndex]
		if grid ~= nil then
			--参数1 data
			--参数2 额外的数据，自己设置的
			--参数3 当前grid的索引
			grid:setData(self.m_arrDataList[i + iDataStartIndex], i + iDataStartIndex, self.m_GridExtValue)
		end
	end
end


--更新区间范围的格子的显示
--@param iBeginRow 起始行
--@param iEndRow 结束行
function BaseListEx:updateBlock(iBeginRow, iEndRow)
	if iBeginRow < 1 then iBeginRow = 1 end
	if iEndRow > self.iRealRowCount then iEndRow = self.iRealRowCount end
	if iEndRow - iBeginRow > self.m_iShowRowCount then iEndRow = self.m_iShowRowCount + iBeginRow end
	--print(iBeginRow, iEndRow)
	local arrBlock = self.m_arrBlockList
	for _, block in ipairs(arrBlock) do
		block:setVisible(false)
	end
	local arrCacheRow = {}
	for row = iBeginRow, iEndRow do
		local isSelect = false
		for index, block in ipairs(arrBlock) do
			if row == block.m_iBlockIndex then
				block:setVisible(true)
				isSelect = true
				break
			end
		end
		if isSelect == false then
			table.insert(arrCacheRow, row)
		end
	end
	for _, row in ipairs(arrCacheRow) do
		for index, block in ipairs(arrBlock) do
			if block:isVisible() == false  then
				block.m_iBlockIndex = row
				block:setVisible(true)
				block:setPosition(0, self.innerHeight - self.m_iGridHeight * row)
				self:updateBlockGrid(index, row)
				break
			end
		end
	end
	self.iBlockBeginIndex = iBeginRow
	self.iBlockEndIndex = iEndRow
end

--滚动
function BaseListEx:onScrollEvent(sender, eventType)
	--print(eventType)
	--print(self:getInnerContainer():getPosition())
	if self.m_bInit then
		if eventType == 0 or eventType == 5 then
			self:updateBlock(1, self.m_iShowRowCount)
		elseif eventType == 1 or eventType == 6 then 
			self:updateBlock(self.iRealRowCount - self.m_iShowRowCount + 1, self.iRealRowCount)
		else
			local fBottomY = self.innerHeight + self:getInnerContainer():getPositionY()
			local iBottomIndex = math.ceil(fBottomY / self.m_iGridHeight)
			self:updateBlock(iBottomIndex - self.m_iShowRowCount, iBottomIndex)
		end
	end
end

return BaseListEx
