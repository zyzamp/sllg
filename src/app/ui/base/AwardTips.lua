--
-- Author: shijimin
-- Date: 2016-08-31 17:38:55
--
local AwardTips = class("AwardTips", require("app.ui.BaseDialog"))

local bindArr = {
	["Text_1"] = {varname = "m_NameText"}, 
    ["Image_1"] = {varname = "m_AwardTipsBg"}
}

function AwardTips:ctor()
	self.super.ctor(self)
    self:bindByFile("ui/award_tips.csb", bindArr)
    self:bindByNode(self.m_AwardTipsBg, bindArr)
    self:init()
end

function AwardTips:init()
    self.m_AwardGridList = require("app.ui.base.BaseList").new()
    self.m_AwardTipsBg:addChild(self.m_AwardGridList)
    
end

--[[
function AwardTips:setData(list,szDesc)
	self.m_NameText:setString(szDesc)
	local tipBgWidth = 80 + #list * 80
	if tipBgWidth < 200 then
		tipBgWidth = 200
	end
    local textWidth = self.m_NameText:getContentSize().width
    print("textWidth,tipBgWidth=",textWidth,tipBgWidth)
    if textWidth >= tipBgWidth then
        tipBgWidth = textWidth + 20
    end

	self.m_NameText:setPosition(cc.p(tipBgWidth/2,self.m_NameText:getPositionY()))
	self.m_AwardTipsBg:setContentSize(cc.size(tipBgWidth,self.m_AwardTipsBg:getContentSize().height))
    self.m_AwardGridList:setContentSize(cc.size(#list * 80,80)) -- 大小
    self.m_AwardGridList:setPosition(cc.p((tipBgWidth-self.m_AwardGridList:getContentSize().width)/2,8)) -- 位置
    self.m_AwardGridList:setFormSize(1, #list)  --范围
    self.m_AwardGridList:setFormMargin(5, 5)  --间隔
    self.m_AwardGridList:setDirection(ccui.ScrollViewDir.horizontal)
    self.m_AwardGridList:setGridFileName("app.ui.base.PropGrid")
    self.m_AwardGridList:updateList(list)
end
]]

--一排最多6个，是上下方向的列表  
function AwardTips:setData(list,szDesc)
    self.m_NameText:setString(szDesc)
    local iWidth = #list
    local iHeight = math.ceil(#list / 6)
    if iWidth > 6 then iWidth = 6 end
    local tipBgWidth = 80 + iWidth * 80
    if tipBgWidth < 200 then
        tipBgWidth = 200
    end
    local textWidth = self.m_NameText:getContentSize().width
    
    if textWidth >= tipBgWidth then
        tipBgWidth = textWidth + 20
    end
    local tipBgHeight = iHeight * 80 + 40
    self.m_NameText:setPositionY(tipBgHeight - 20)
    print("textWidth,tipBgWidth,tipBgHeight=",textWidth,tipBgWidth,tipBgHeight)

    self.m_NameText:setPosition(cc.p(tipBgWidth/2, self.m_NameText:getPositionY()))
    self.m_AwardTipsBg:setContentSize(cc.size(tipBgWidth, tipBgHeight))
    self.m_AwardGridList:setContentSize(cc.size(iWidth * 80, iHeight * 80)) -- 大小
    self.m_AwardGridList:setPosition(cc.p((tipBgWidth-self.m_AwardGridList:getContentSize().width)/2,8)) -- 位置
    self.m_AwardGridList:setFormSize(iHeight, iWidth)  --范围
    self.m_AwardGridList:setFormMargin(5, 5)  --间隔
    self.m_AwardGridList:setDirection(ccui.ScrollViewDir.vertical)
    self.m_AwardGridList:setGridFileName("app.ui.base.PropGrid")
    self.m_AwardGridList:updateList(list)
end

return AwardTips

