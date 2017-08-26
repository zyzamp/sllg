local BasePage = class("BasePage", function()
    return ccui.PageView:create()
end)

function BasePage:ctor()
    self.m_previousPage = nil
    self.m_nextPageIndex = nil
    self.m_previousPageIndex = nil
    self.m_PageData = nil
    self.m_PageItemNum = nil
end

function BasePage:init(parent)
    self.m_Parent = parent
    self:addEventListener(handler(self, self.touchEvent))

end

--设置页面格子数量
function BasePage:setFormSize(iRowCount, iColumnCount)
    self.m_iRowCount = iRowCount
    self.m_iColumnCount = iColumnCount
end

--设置页面格子间距
function BasePage:setFormMargin(fMarginX, fMarginY)
    self.m_fMarginX = fMarginX
    self.m_fMarginY = fMarginY
end

--设置页面格子文件名
function BasePage:setGridFileName(szClassName)
    self.m_szClassName = szClassName
end

--设置格子事件
function BasePage:setGridEvent(callback)
    self.m_GridEvent = callback
end

function BasePage:setPageData(pIdx, bDel)
    local page = self:getPage(pIdx)
    if page ~= nil then 
        page:removeAllChildren()
        if bDel ~= true then
            local list = self.m_PageData[pIdx + 1]
            if list ~= nil then
                local pageHeight = self:getContentSize().height
                for i = 1, #list do
                    local grid = CacheMgr:getCacheGrid(self.m_szClassName)
                    local size = grid:getContentSize()
                    grid:setPosition(size.width /2 + ( size.width + self.m_fMarginX )* ( (i -1) % self.m_iColumnCount), pageHeight - size.height / 2  -  math.floor( ( i - 1 ) / self.m_iRowCount ) * ( size.height + self.m_fMarginY ))
                    grid:setAnchorPoint(0.5,0.5)
                    grid:addCallBackFunc(grid, self.m_GridEvent)
                    grid:setData(list[i])
                    grid:addTo(page,10)
                    grid:setTag(100 + i)

                end
            end
        end
    end

end

function BasePage:initPages(iPages)
    self.m_iLastPageIndex = 0
    self:removeAllPages()
    for i = 1, iPages do
        local layout = ccui.Layout:create()
        layout:setContentSize(self:getContentSize())
        self:addPage(layout)
        if i <= 3 then
            self:setPageData(i - 1)
        end
    end
end

function BasePage:touchEvent(sender, eventType, other)
    print(self:getCurPageIndex())
    if eventType == 0 then   -- PAGEVIEW_EVENT_TYPE.TURNING
        local iCurrentPageIndex = self:getCurPageIndex()
        local pages = #self.m_PageData
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


function BasePage:updatePageData(arrData)
    self.m_PageData = {}
    self.m_PageItemNum =  self.m_iRowCount * self.m_iColumnCount
    for i,v in ipairs(arrData) do
        if self.m_PageData[math.floor((i - 1) / self.m_PageItemNum)  + 1 ] == nil then self.m_PageData[math.floor((i - 1) / self.m_PageItemNum)  + 1 ] = {} end
        table.insert(self.m_PageData[math.floor((i - 1) / self.m_PageItemNum)  + 1 ],v)
    end
    self:initPages(#self.m_PageData)
end
 
return BasePage