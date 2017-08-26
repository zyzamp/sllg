--
-- Author: shimin
-- Date: 2016-05-23 09:07:17
--
BaseGridList = BaseGridList or {
	m_BaseGridList = {}
}

function BaseGridList.release()
	for szClass, arrList in pairs(BaseGridList.m_BaseGridList) do
		 
		for i, grid in ipairs(arrList) do 
			grid:release()
		end
		BaseGridList.m_BaseGridList[szClass] = nil
	end
	BaseGridList.m_BaseGridList = {}
end

function BaseGridList.init()
	--------初始化100个卡片格子
	BaseGridList.create("app.ui.base.CardGrid",100)
	BaseGridList.create("app.ui.base.PropGrid",100)
	--BaseGridList.create("app.ui.skill.SkillItem",40)
	BaseGridList.create("app.ui.task.NewTaskList",40)
	BaseGridList.create("app.ui.achieve.AchieveListItemItem",20)
end

function BaseGridList.create(szClassName,iCount)
	local arrGrid = BaseGridList.m_BaseGridList[szClassName] or {}
	for i = #arrGrid + 1, iCount do
		--print("szClassName=",szClassName)
		local grid = require(szClassName).new()
		grid:retain()
		table.insert(arrGrid, grid)
	end
	BaseGridList.m_BaseGridList[szClassName] = arrGrid
end

function BaseGridList.getBaseGrid(szClassName)
	local arrGrid = BaseGridList.m_BaseGridList[szClassName]
	if arrGrid == nil then
		BaseGridList.m_BaseGridList[szClassName] = {}
		arrGrid = BaseGridList.m_BaseGridList[szClassName]
	elseif #arrGrid > 0 then
		for i,grid in ipairs(arrGrid) do 
			if grid:getParent() == nil then
				grid:setVisible(true)
				return grid
			end
		end
	end
	local grid = require(szClassName).new()
	grid:retain()
	table.insert(arrGrid, grid)
	return grid
end