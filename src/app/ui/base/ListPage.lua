--
-- Author: shijimin
-- Date: 2016-08-01 11:38:26
--
local ListPage = class("ListPage", function()
    return ccui.PageView:create()
end)

function ListPage:ctor()
    self.m_previousPage = nil
    self.m_nextPageIndex = nil
    self.m_previousPageIndex = nil
    self.m_PlayerListData = nil
    self.m_arrGridList = {}
end

function ListPage:init(parent,szItem,iCount)
	self.m_szItem = szItem
	self.m_iCount = iCount
    self.m_Parent = parent
    self:addEventListener(handler(self, self.touchEvent))
end

function ListPage:setPageData(pIdx, bDel)
    local page = self:getPage(pIdx)    
    if page ~= nil then 
        page:removeAllChildren()
        if bDel ~= true then
            local list = self.m_PlayerListData[pIdx + 1]
            if list ~= nil then
                local pageHeight = self:getContentSize().height
                for i = 1, math.min(#list, self.m_iCount) do
                    local grid = CacheMgr:getCacheGrid(self.m_szItem)
                    local size = grid:getContentSize()
                    grid:setPosition(size.width / 2 + 4, pageHeight - ( i - 0.5 ) * size.height)
                    grid:setData(list[i])
                    grid:setName(self.m_szItem)
                    grid:addTo(page)
                    if grid.addCallBackFunc ~= nil then
                        grid:addCallBackFunc(grid, self.m_funcClickCallBack)
                    end
                    if self.m_funcEachGridLoadedCallBack ~= nil then
                        self.m_funcEachGridLoadedCallBack(i, grid)
                    end
                end
                print("#self.m_arrGridList="..#self.m_arrGridList)
            end
            --self:getGridList()
        end
    end
end
function ListPage:setEachGridLoaded(callback)
    self.m_funcEachGridLoadedCallBack = callback
end
--设置格子事件
function ListPage:setGridEvent(callback)
	self.m_funcClickCallBack = callback 
end
 


function ListPage:initPages(iPages)
    self.m_iLastPageIndex = 0
    self:removeAllPages()
    self.m_iPages = iPages
    for i = 1, self.m_iPages do
        local layout = ccui.Layout:create()
        layout:setContentSize(self:getContentSize())
        self:addPage(layout)
        if i <= 3 then
            self:setPageData(i - 1)
        end
    end   
end

function ListPage:getGridList()
    local arrGridList = {}
    for i = 1, self.m_iPages do
        local page = self:getPage(i -1)
        if page ~= nil then
            local child = page:getChildren()
            for _,grid in ipairs(child) do
                table.insert(arrGridList,grid)
            end
        end
    end   
    return arrGridList
end

function ListPage:touchEvent(sender, eventType, other)
    -- print("()()()())()(((")
    print(self:getCurPageIndex())
    if eventType == 0 then   -- PAGEVIEW_EVENT_TYPE.TURNING
        local iCurrentPageIndex = self:getCurPageIndex()
        local pages = #self.m_PlayerListData
        if pages > 3 then
            if self.m_iLastPageIndex > iCurrentPageIndex then
                if  iCurrentPageIndex > 0 then
                    self:setPageData(iCurrentPageIndex + 2, true)
                    self:setPageData(iCurrentPageIndex - 1)
                end
            elseif self.m_iLastPageIndex < iCurrentPageIndex then
                if iCurrentPageIndex < pages - 1 then
                    self:setPageData(iCurrentPageIndex - 2, true)
                    self:setPageData(iCurrentPageIndex + 1)
                end
            end
        end
        if self.m_iLastPageIndex ~= iCurrentPageIndex then
            self.m_iLastPageIndex = iCurrentPageIndex
            audio.playSound(audio_file.button)
        end
    end
end


function ListPage:updateListData(arrData)
    self.m_PlayerListData = {}
    for i,v in ipairs(arrData) do
        if self.m_PlayerListData[math.floor((i - 1) / self.m_iCount ) + 1 ] == nil then self.m_PlayerListData[math.floor((i - 1) / self.m_iCount ) + 1 ] = {} end
        table.insert(self.m_PlayerListData[math.floor((i - 1) / self.m_iCount ) + 1 ],v)
    end
   -- dumppb(self.m_PlayerListData)
    self:initPages(#self.m_PlayerListData)
end
 
return ListPage