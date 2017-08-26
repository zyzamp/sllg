
local BaseList = class("BaseList", function()
    return ccui.ListView:create()
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
--self:setFormMargin(10, 10)  --间隔

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
	self.m_fMarginX = 0
	self.m_fMarginY = 0
	self.m_arrGridList = {} --格子列表
	self.m_GridEvent = nil --格子事件
	self.m_GridAlwaysEvent = nil --格子持续点击事件
	self.m_bInit = false --初始化
end

--设置格子数量
function BaseList:setFormSize(iRowCount, iColumnCount)
	self.m_iRowCount = iRowCount;
	self.m_iColumnCount = iColumnCount;
end

--设置格子间距
function BaseList:setFormMargin(fMarginX, fMarginY)
	self.m_fMarginX = fMarginX
	self.m_fMarginY = fMarginY
end

--设置格子事件
function BaseList:setGridEvent(callback, callback1)
	self.m_GridEvent = callback
	self.m_GridAlwaysEvent = callback1
	self:updateGridEvent()
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
	local iDirection = self:getDirection()
	if iDirection == ccui.ScrollViewDir.vertical then
		self:dealWithVertical(arrData)
	elseif iDirection == ccui.ScrollViewDir.horizontal then
		self:dealWithHorizontal(arrData)
	end
	self:updateGridEvent()
	self.m_bInit = true

	if bRestorePos then
		self:getInnerContainer():setPosition(cc.p(iPosX, iPosY))
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
	self:removeAllItems()
	self.m_arrGridList = {}
end

--更新事件 
function BaseList:updateGridEvent()
	if self.m_arrGridList ~= nil and self.m_GridEvent ~= nil then
		for _, grid in ipairs(self.m_arrGridList) do
			if grid.addCallBackFunc ~= nil then
				grid:addCallBackFunc(grid, self.m_GridEvent, self.m_GridAlwaysEvent)
			end
		end
	end
end

--设置纵向表格
--@arrData 数据
--@szClassName 格子文件名
function BaseList:dealWithVertical(arrData)
	if arrData == nil or self.m_szClassName == nil then
		return
	end
	local iGridCount = 0

	--local stHandle = require(self.m_szClassName)
	local iDataSize = table.getn(arrData)
	local iRealColumnCount = self.m_iColumnCount
	local iRealRowCount = (iDataSize + iRealColumnCount - 1) / iRealColumnCount
	iRealRowCount = math.max(iRealRowCount, self.m_iRowCount)
	local iCurrentIndex = 0
	for iRow = 1, iRealRowCount do
        local layout = ccui.Widget:create()
		local fMaxHeight = self.m_fMarginY 
		local fCurrentWidth = 0
		for iColumn = 1, iRealColumnCount do
			iCurrentIndex = iCurrentIndex + 1
			local grid = {}
			if iCurrentIndex <= iGridCount then 
				grid = self.m_arrGridList[iCurrentIndex]
			else
				grid = CacheMgr:getCacheGrid(self.m_szClassName)
				table.insert(self.m_arrGridList, grid)
			end
			local gridSize = grid:getContentSize()
			grid:setAnchorPoint(cc.p(0.5, 0.5))
			grid:setPosition(cc.p(fCurrentWidth + (self.m_fMarginX + gridSize.width) / 2, (self.m_fMarginY + gridSize.height) / 2))
			fMaxHeight = math.max(fMaxHeight, gridSize.height + self.m_fMarginY)
			fCurrentWidth = fCurrentWidth + gridSize.width + self.m_fMarginX
			
			if iCurrentIndex <= iDataSize then
				grid:setData(arrData[iCurrentIndex], iCurrentIndex)
			else
				grid:setData() --重新clear一次
			end
			if grid:getParent() ~= nil then
				 
			end
			layout:addChild(grid)
		end

		layout:setContentSize(cc.size(fCurrentWidth, fMaxHeight))
        self:pushBackCustomItem(layout)
	end


	self:requestDoLayout()
	self:jumpToTop()
end

--设置横向表格
--@arrData 数据
--@szClassName 格子文件名
function BaseList:dealWithHorizontal(arrData)
	if arrData == nil or self.m_szClassName == nil then
		return
	end
	local iGridCount = 0

	local stHandle = require(self.m_szClassName)
	local iDataSize = table.getn(arrData)
	local iRealRowCount = self.m_iRowCount
	local iRealColumnCount = (iDataSize + iRealRowCount - 1) / iRealRowCount
	iRealColumnCount = math.max(iRealColumnCount, self.m_iColumnCount)
	local iCurrentIndex = 0
	for iColumn = 1, iRealColumnCount do
        local layout = ccui.Widget:create()
		local fMaxWidth = self.m_fMarginY 
		local fCurrentHeight = 0
		for iRow = 1, iRealRowCount do
			iCurrentIndex = iCurrentIndex + 1

			local grid = {}
			if iCurrentIndex <= iGridCount then 
				grid = self.m_arrGridList[iCurrentIndex]
			else
				grid = stHandle.new()
				table.insert(self.m_arrGridList, grid)
			end 

			local gridSize = grid:getContentSize();
			fMaxWidth = math.max(fMaxWidth, gridSize.width + self.m_fMarginX)
			fCurrentHeight = fCurrentHeight + gridSize.height + self.m_fMarginY
			
			if iCurrentIndex <= iDataSize then
				grid:setData(arrData[iCurrentIndex], iCurrentIndex)
			else
				grid:setData() --重新clear一次
			end

			layout:addChild(grid)
		end

		layout:setContentSize(cc.size(fMaxWidth, fCurrentHeight));
        self:pushBackCustomItem(layout)
		for iRow = iCurrentIndex - iRealRowCount + 1, iCurrentIndex do
			local grid = self.m_arrGridList[iRow]
			local gridSize = grid:getContentSize();
			fCurrentHeight = fCurrentHeight - gridSize.height - self.m_fMarginY
			grid:setPosition(cc.p(0 + (self.m_fMarginX + gridSize.width) / 2, fCurrentHeight + (self.m_fMarginY + gridSize.height) / 2))
		end
	end
	self:requestDoLayout()
	self:jumpToLeft()
end

return BaseList
