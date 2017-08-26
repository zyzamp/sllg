
local BaseWidget = class("BaseWidget", function()
	return ccui.Widget:create()
end)


function BaseWidget:ctor()
end


--由子类继承，塞数据
function BaseWidget:setData(...)
end

--由子类添加监听事件
--当受到点击时，触发回调函数
--若子类继承此点击事件，需手动调用一次
--@sender 这是子类（self）
function BaseWidget:onTouchEvent(sender, eventType, ...)
	if sender.m_BaseListCallBackFunc ~= nil then
		sender.m_BaseListCallBackFunc(sender, eventType, ...)
	end
end

--由子类添加监听事件
--当持续点击时，触发回调函数
function BaseWidget:onAlwaysTouchEvent(sender, ...)
    if sender.m_BaseListAlwaysCallBackFunc ~= nil then
        sender.m_BaseListAlwaysCallBackFunc(sender, ...)
    end
end

--添加回调函数
--@sender 这是子类
function BaseWidget:addCallBackFunc(sender, callback, callback1)
    if sender ~= nil then
        sender.m_BaseListCallBackFunc = callback
        sender.m_BaseListAlwaysCallBackFunc = callback1
    end
end

--移除回调函数
function BaseWidget:removeCallBackFunc(sender)
    sender.m_BaseListCallBackFunc = nil
    sender.m_BaseListAlwaysCallBackFunc = nil
end

--绑定资源
--由于cocosstudio中的资源都是Node节点，导致ui的触发事件紊乱
--因此这里将Node中的资源提取到self中(self为Widget类)
--@resourceFilename  csb文件路径
--@bindArr 参数table
--注意！！！！！！！ 继承此table的资源，必须以锚点为原点（0，0）的状态进行布局
function BaseWidget:widgetResourceBind(resourceFilename, bindArr)
	local resourceNode = cc.uiloader:load(resourceFilename) 
    for nodeName, nodeBinding in pairs(bindArr) do
        local node = resourceNode:getChildByName(nodeName)
        if nodeBinding.varname and node ~= nil then
            self[nodeBinding.varname] = node
            node:retain()
            node:removeFromParent()
            node:addTo(self, nodeBinding.zorder)
            node:release()
            node:setName(nodeBinding.varname)
            if nodeBinding.touchEvent ~=  nil then
            	if node:isTouchEnabled() == false then
            		node:setTouchEnabled(true)
            	end
            	node:addTouchEventListener(handler(self, self[nodeBinding.touchEvent]))
	       	end
            if nodeBinding.nodeTouchEvent ~= nil then
                if node:isTouchEnabled() == false then 
                    node:setTouchEnabled(true)
                end 
                node:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self[nodeBinding.nodeTouchEvent]))
            end
        end     
    end
    self:setAnchorPoint(cc.p(0.5, 0.5))
    resourceNode:retain()
    resourceNode:release()
end


return BaseWidget
