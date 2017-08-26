local BaseTips = class("BaseTips", require("app.ui.BaseDialog"))

function BaseTips:ctor()
end

function BaseTips:setData(pos, iUIN, iType, szRoleName)
	self.m_MemberUIN = iUIN
	self.m_szRoleName = szRoleName
	self:removeAllChildren()

	local iIntervalY = 10
	local posx, posy = 5, -5 - iIntervalY

	----------------共用的提到外面----------------
	if not msglobal:isMyFriend(iUIN) then   
	    --添加好友
        self.m_FriendBtn = self:createBtn("addfriend", posx, posy)
		posy = posy - self.m_FriendBtn:getContentSize().height - iIntervalY
    end
    --私聊
	self.m_ChatBtn = self:createBtn("chat", posx, posy)
	posy = posy - self.m_ChatBtn:getContentSize().height - iIntervalY
	--玩家信息
	self.m_PlayInfoBtn = self:createBtn("player_info", posx, posy)
	posy = posy - self.m_PlayInfoBtn:getContentSize().height - iIntervalY
    
    -----------------私有的----------------
    if iType == ms.tips_type.normal then
	elseif iType == ms.tips_type.team_member then	
	elseif iType == ms.tips_type.chat_name then
		--公会邀请
		if msglobal.m_iGuildID > 0 then
			self.m_GuildInviteBtn = self:createBtn("association_invited_", posx, posy)
			posy = posy - self.m_GuildInviteBtn:getContentSize().height - iIntervalY
		end
	elseif iType == ms.tips_type.rank_item then
	elseif iType == ms.tips_type.student_item then
		--邀请组队
		self.m_TeamInviteBtn = self:createBtn("invite_team", posx, posy)
		posy = posy - self.m_TeamInviteBtn:getContentSize().height - iIntervalY
		--解除关系
		self.m_RemoveShipBtn = self:createBtn("remove_", posx, posy)
		posy = posy - self.m_RemoveShipBtn:getContentSize().height - iIntervalY
	elseif iType == ms.tips_type.teacher_item then
		--邀请组队
		self.m_TeamInviteBtn = self:createBtn("invite_team", posx, posy)
		posy = posy - self.m_TeamInviteBtn:getContentSize().height - iIntervalY
		--解除关系
		self.m_RemoveTeacherShipBtn = self:createBtn("remove_", posx, posy)
		posy = posy - self.m_RemoveTeacherShipBtn:getContentSize().height - iIntervalY
	end

	local iWidth = 116--posx + self.m_ExitBtn:getContentSize().width + 5
	local iHeight = -posy
	local bgScale9 = ccui.Scale9Sprite:create("ui/common/tc.png")
	bgScale9:setContentSize(cc.size(iWidth, iHeight))
	bgScale9:setAnchorPoint(cc.p(0, 1))
	bgScale9:setPosition(cc.p(0, 0))
	self:addChild(bgScale9, 1)

	--设置大小
	self:setContentSize(bgScale9:getContentSize())
	--设置位置 防止出界
	local xx = pos.x + 10
	local yy = pos.y
	if xx + iWidth > display.width then xx = display.width - iWidth end
	if yy < iHeight then yy = iHeight end
	self:setPosition(cc.p(xx, yy))
	--设置遮罩 (这三者的顺序不能变)
	self:setMask()
	self.m_BaseBgMask:addTouchEventListener(handler(self, self.maskTouchEvent))
end

function BaseTips:createBtn(btnName, posx, posy)
	local btn = ccui.Button:create("ui/common/button/"..btnName.."1.png", "ui/common/button/"..btnName.."2.png", "ui/common/button/"..btnName.."3.png")
	btn:setAnchorPoint(cc.p(0, 1))
	btn:setPosition(cc.p(posx, posy))
	btn:addTo(self, 2)
	btn:addTouchEventListener(handler(self, self.touchEvent))
	return btn
end

function BaseTips:touchEvent(sender, evt)
	if evt ~= 2 then return end

	if sender == self.m_ChatBtn then
		self:requestPrivateChat()
	elseif sender == self.m_FriendBtn then
		self:requestAddFriend()
	elseif sender == self.m_PlayInfoBtn then
		self:requestOtherPlayerInfo()
	elseif sender == self.m_GuildInviteBtn then
		self:requestInviteJoinGuild()
	elseif sender == self.m_TeamInviteBtn then
		self:requestJoinTeam()
	elseif sender == self.m_RemoveShipBtn then
		local str = language_ch["cn_662"]
		str = string.format(str, self.m_szRoleName)
		local node = msfunc.createUI(msui.confirm_dialog)
		SceneMgr:addFloatUI(node)
		node:setEvent(handler(msglobal, msglobal.requestRemoveShip), str, nil, language_ch["cn_697"], self.m_MemberUIN, self.m_szRoleName)
	elseif sender == self.m_RemoveTeacherShipBtn then
		local str = language_ch["cn_659"]
		str = string.format(str, self.m_szRoleName)
		local node = msfunc.createUI(msui.confirm_dialog)
		SceneMgr:addFloatUI(node)
		node:setEvent(handler(msglobal, msglobal.requestRemoveShip), str, nil, language_ch["cn_697"], self.m_MemberUIN, self.m_szRoleName)
	end

	audio.playSound(audio_file.button)
	self:removeSelf()
end

function BaseTips:requestPrivateChat()
	if msglobal.ui[msui.chat] ~= nil then
		msglobal.ui[msui.chat]:sendToUIN(self.m_MemberUIN)
	end
end

function BaseTips:requestAddFriend()
	local msg = ServerProtoMgr:getMsgBody("CPbMsgRequestAddFriend")
	msg.m_szFriendName = ""
	msg.m_byRelationType = 1
	msg.m_iRoleUIN = self.m_MemberUIN
	ServerProtoMgr:sendToServer(ServerProtoMacro.MSG_LOGIC_ADD_FRIEND, msg)  
end

function BaseTips:requestOtherPlayerInfo()
	msglobal:dealWithOtherPlayerInfo({self.m_MemberUIN}, ms.get_other_player_type.player_info)
end

function BaseTips:requestInviteJoinGuild()
	if msglobal:checkIsGuildChief(msglobal.m_stRoleInfo.m_stRoleBrief.m_iUIN) == false then
		TipsMgr:addLineTipsCenter(language_ch["cn_229"])
		return
	end

	local msg = ServerProtoMgr:getMsgBody("CPbMsgRequestInviteJoinGuild")
	msg.m_iGuildID = msglobal.m_iGuildID
	msg.m_iDstUIN = self.m_MemberUIN
	ServerProtoMgr:sendToServer(ServerProtoMacro.MSG_LOGIC_INVITE_JOIN_GUILD, msg)
end

--延迟调用


function BaseTips:requestJoinTeam()
	if msglobal.m_Team.m_iTeamID ~= nil then
		--邀请
		local msg = ServerProtoMgr:getMsgBody("CPbMsgRequestInviteTeam")   --发送消息，msg.lua接受消息结果
    	msg.m_iRoleUIN = self.m_MemberUIN
    	ServerProtoMgr:sendToServer(ServerProtoMacro.MSG_LOGIC_INVITE_TEAM, msg)
    	--TipsMgr:addLineTipsCenter(language_ch["cn_225"])
	else
		self:requestCreateTeam()
	end
end

function BaseTips:requestCreateTeam()
	local mapInfo = msconfig:getMapInfoByIndex(msglobal.m_stRoleInfo.m_nCopyChapter, msglobal.m_stRoleInfo.m_nCopyChapterIndex, ms.mapType.base)
	local iMapID = 10101
	if mapInfo ~= nil then
		iMapID = mapInfo.m_iSceneID
	end

	--在global里暂存一个数据(组队要邀请的对象)
	msglobal.m_iInviteTeamCacheUIN = self.m_MemberUIN

	local msg = ServerProtoMgr:getMsgBody("CPbMsgRequestJoinTeam")   --发送消息，msg.lua接受消息结果
    msg.m_iTeamID = 0
    msg.m_iMapID  = iMapID
    msg.m_byMatch = 0
    ServerProtoMgr:sendToServer(ServerProtoMacro.MSG_LOGIC_JOIN_TEAM, msg)
end

function BaseTips:maskTouchEvent(sender, evt)
	if evt ~= 2 then return end
	self:removeSelf()
end


return BaseTips
