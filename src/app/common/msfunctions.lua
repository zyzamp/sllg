
msfunc = msfunc or {}


--创建一个网络图片
--ms.SpriteUrl:create("http://news.baidu.com/resource/img/logo_news_276_88.png")


--创建一个UI
function msfunc.createUI(iTag)
    --获取资源
    local data = msmodule[iTag]
    if data == nil then
        printf("Error: Tag = %d 未定义", iTag)
        return nil
    end
    --创建UI
    local uiNode = require(data.szClass).new()
    uiNode:setName(data.szName)
    return uiNode
end

--打开一个UI(如果当前UI已经打开，调用该方法的时候会把UI关掉)
function msfunc.openUI(iTag)
    local sceneUI = msglobal.ui[msui.scene]
    if sceneUI ~= nil then
        sceneUI:changeViewShow(iTag)
    else
        SceneMgr:addPopUI(msfunc.createUI(iTag))
    end
end

--布局适配方案
--@iType 适配类型 （详情参照ms.layoutType.exact_fit定义）
--@node 适配对象 
function msfunc.layoutTypeHandle(iType, node)
    if node ~= nil then
        local nodeSize = node:getContentSize()
        local screenSize = cc.Director:getInstance():getVisibleSize()
        local screenWidth = screenSize.width
        local screenHeight = screenSize.height
        if screenWidth < CONFIG_DESIGN_WIDTH then
            screenWidth = screenWidth / msfunc.getFinalScaleX(node)
            screenHeight = screenHeight / msfunc.getFinalScaleY(node)
        end
        if iType == ms.layoutType.exact_fit then
            node:setScale(screenWidth / nodeSize.width, screenHeight / nodeSize.height)
        elseif iType == ms.layoutType.no_border then
            local fScreenRate = screenWidth / screenHeight
            local fNodeRate = nodeSize.width / nodeSize.height
            if fScreenRate > fNodeRate then
                local widthRate = screenWidth / nodeSize.width
                node:setScale(widthRate, widthRate)
            else
                local heightRate = screenHeight / nodeSize.height
                node:setScale(heightRate, heightRate)
            end
        elseif iType == ms.layoutType.show_all then
            local fScreenRate = screenWidth / screenHeight
            local fNodeRate = nodeSize.width / nodeSize.height
            if fScreenRate < fNodeRate then
                local widthRate = screenWidth / nodeSize.width
                node:setScale(widthRate, widthRate)
            else
                local heightRate = screenHeight / nodeSize.height
                node:setScale(heightRate, heightRate)
            end
        elseif iType == ms.layoutType.fixed_width then
            local widthRate = screenWidth / nodeSize.width
            node:setScale(widthRate, widthRate)
        elseif iType == ms.layoutType.fixed_height then
            local heightRate = screenHeight / nodeSize.height
            node:setScale(heightRate, heightRate)
        elseif iType == ms.layoutType.size_full then
            node:setContentSize(screenSize)
        elseif iType == ms.layoutType.keep_width then
            if screenWidth < CONFIG_DESIGN_WIDTH then
                local fExScale = screenWidth / CONFIG_DESIGN_WIDTH
                node:setScale(node:getScaleX() * fExScale, node:getScaleY() * fExScale)
            end
        end
    end
end

function msfunc.getFinalScaleX(node)
    local res = 1
    if node ~= nil and node.getParent ~= nil then
        repeat
            res = res * node:getScaleX()
            node = node:getParent()
        until node == nil
    end
    return res
end

function msfunc.getFinalScaleY(node)
    local res = 1
    if node ~= nil and node.getParent ~= nil then
        repeat
            res = res * node:getScaleY()
            node = node:getParent()
        until node == nil
    end
    return res
end

function msfunc.getScreenPosByPer(perX, perY)
    local screenSize = cc.Director:getInstance():getVisibleSize()
    local screenWidth = screenSize.width
    local screenHeight = screenSize.height
    if screenWidth < CONFIG_DESIGN_WIDTH then
        screenWidth = screenWidth / msfunc.getFinalScaleX(target)
        screenHeight = screenHeight / msfunc.getFinalScaleY(target)
    end
    return screenWidth * perX / 100.0, screenHeight * perY / 100.0
end

--绑定资源，自己定义一个table
--local bindArr = {
--["资源名"] = {varname = "生成的变量名" , 
--              zorder = 层级 ,
--              perX = 坐标（屏幕百分比）, 
--              perY = 坐标（屏幕百分比）,
--              perWidth = 尺寸（屏幕百分比）,
--              perHeight = 尺寸（屏幕百分比）,
--              layout = 布局适配（参照宏：ms.layoutType.exact_fit）,
--              touchEvent = "ui事件绑定方法", 
--              nodeTouchEvent = "node事件绑定方法", 
--          },
--}
--优点，代码清晰和资源文件csb关联不大，名字改动也不影响，替换一下就好了。
function msfunc.resoueceBinding(target, resourceNode, bindArr)
    assert(resourceNode, "msfunc.resoueceBinding - not load resource node")
    assert(bindArr, "msfunc.resoueceBinding - not find bindArr")
    local screenSize = cc.Director:getInstance():getVisibleSize()
    local screenWidth = screenSize.width
    local screenHeight = screenSize.height
    if screenWidth < CONFIG_DESIGN_WIDTH then
        screenWidth = screenWidth / msfunc.getFinalScaleX(target)
        screenHeight = screenHeight / msfunc.getFinalScaleY(target)
    end
    for nodeName, nodeBinding in pairs(bindArr) do
        local node
        if nodeName == "_self" then
            node = resourceNode
        else
            node = resourceNode:getChildByName(nodeName)
        end
        if nodeBinding.varname ~= nil and node ~= nil then
            target[nodeBinding.varname] = node
            node:setName(nodeBinding.varname)
            --print(string.format("node.name = %s",nodeBinding.varname))
            --widget的touch事件（仅按钮可用）
            if nodeBinding.touchEvent ~=  nil then
                if node:isTouchEnabled() == false then
                    node:setTouchEnabled(true)
                end
                node:addTouchEventListener(handler(target, target[nodeBinding.touchEvent]))
            end
            --node的touch事件（按钮不可用）
            if nodeBinding.nodeTouchEvent ~=  nil then
                if node:isTouchEnabled() == false then
                    node:setTouchEnabled(true)
                end
                node:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(target, target[nodeBinding.nodeTouchEvent]))
            end
            --层级
            if nodeBinding.zorder ~= nil then
                node:setLocalZOrder(nodeBinding.zorder)
            end
            --全局位置适配
            if nodeBinding.perX ~= nil then
                node:setPositionX(screenWidth * nodeBinding.perX / 100.0)
            end
            if nodeBinding.perY ~= nil then
                node:setPositionY(screenHeight * nodeBinding.perY / 100.0)
            end
            --全局尺寸适配
            if nodeBinding.perWidth ~= nil then
                local nodeSize = node:getContentSize()
                node:setContentSize(cc.size(screenWidth * nodeBinding.perWidth / 100.0, nodeSize.height))
            end
            if nodeBinding.perHeight ~= nil then
                local nodeSize = node:getContentSize()
                node:setContentSize(cc.size(nodeSize.width, screenHeight * nodeBinding.perHeight / 100.0))
            end
            --全局尺寸适配
            if nodeBinding.layout ~= nil then
                msfunc.layoutTypeHandle(nodeBinding.layout, node)
            end
        end     
    end
end

--获得全局位置
function msfunc.convertToGlobal(node, offsetX, offsetY)
    local resX, resY = node:getPosition()
    node = node:getParent()
    while node ~= nil do
        local nodeSize = node:getContentSize()
        local nodePosX, nodePosY = node:getPosition()
        local parent = node:getParent()
        local anchorPoint = node:getAnchorPoint()
        --print("resX = "  , resX , " , resY = " , resY)
        --print("--  nodePosX = "  , nodePosX , " , nodePosY = " , nodePosY)
        --print("--  node:getScaleX() = "  , node:getScaleX() , " , node:getScaleY() = " , node:getScaleY())
        --print("--  nodeSize.width = "  , nodeSize.width , " , nodeSize.height = " , nodeSize.height)
        --print("--  anchorPoint.x = "  , anchorPoint.x , " , anchorPoint.y = " , anchorPoint.y)
        if parent == nil then
            anchorPoint = cc.p(0, 0)
            resX = node:getScaleX() * resX
            resY = node:getScaleY() * resY
        else
            resX = nodePosX + node:getScaleX() * (resX - anchorPoint.x * nodeSize.width) 
            resY = nodePosY + node:getScaleY() * (resY - anchorPoint.y * nodeSize.height)
        end
        node = parent
    end
    --print("resX = " , resX , " , resY = " , resY)
    if offsetX ~= nil then
        resX = resX + offsetX
    end
    if offsetY ~= nil then
        resY = resY + offsetY
    end
    return resX, resY
end


function msfunc.getMask(node, opacity, bEatClick)
    local mask = ccui.Layout:create()
    local posX , posY = msfunc.convertToGlobal(node, 0, 0)
    local scaleX, scaleY = msfunc.getFinalScaleX(node), msfunc.getFinalScaleY(node)
    mask:setPosition(- posX / scaleX, - posY / scaleY)
    mask:setContentSize(cc.Director:getInstance():getVisibleSize())
    mask:setBackGroundColor(cc.c3b(0, 0, 0))
    mask:setBackGroundColorType(1)
    mask:setBackGroundColorOpacity(150)
    mask:setTouchEnabled(bEatClick)
    --mask:addTouchEventListener(function() dump(self) end) 
    mask:setScale(1 / scaleX, 1 / scaleY)
    return mask
end

-- 为progress添加进度动作
function msfunc.setProgressAction(progress, duration, startPer, endPer)
    if progress ~= nil then
        -- 按照平均速度
        local fDelay = 1 / 60.0
        local iTimes = math.ceil(duration / fDelay)
        local fInterval = (endPer - startPer) / iTimes
        local fCurrent = startPer
        progress:stopAllActions()
        progress:setPercent(fCurrent)
        progress:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.DelayTime:create(fDelay),
            cc.CallFunc:create(function() 
                fCurrent = fCurrent + fInterval
                progress:setPercent(fCurrent > 100 and 100 or fCurrent) 
            end)
        ), iTimes))
        -- -- 按照阻尼系数（受unity启发。 在这里利用等差数列的线性函数来表现，在duration较大的运动中效果会比较明显。 PS：其实用正弦曲线更好）
        -- local fDelay = 1 / 60.0
        -- local iTimes = (duration > fDelay) and (math.ceil(duration / fDelay)) or 1
        -- local fSpeed = (endPer - startPer) / iTimes
        -- local fAdd = (iTimes % 2 == 1) and (fSpeed * 4 / iTimes) or (fSpeed * 2 / (iTimes / 2 + 1))
        -- local iCurrentTimes = 0
        -- local iMidTimes = math.ceil(iTimes / 2)
        -- local fCurrent = startPer
        -- progress:stopAllActions()
        -- progress:setPercent(fCurrent)
        -- progress:runAction(cc.Repeat:create(cc.Sequence:create(
        --     cc.DelayTime:create(fDelay),
        --     cc.CallFunc:create(function() 
        --         iCurrentTimes = iCurrentTimes + 1
        --         fCurrent = fCurrent + fAdd * ((iCurrentTimes <= iMidTimes) and iCurrentTimes or (iTimes - iCurrentTimes))
        --         progress:setPercent(fCurrent > 100 and 100 or fCurrent) 
        --     end)
        -- ), iTimes))
    end
end


