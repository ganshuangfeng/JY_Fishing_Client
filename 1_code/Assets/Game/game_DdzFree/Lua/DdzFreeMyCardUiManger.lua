--by hewei
--斗地主 我的牌 UI管理器

local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib=require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"

DdzFreeMyCardUiManger = basefunc.class()

local rule={
center="center", --居中
}
--管理规则
DdzFreeMyCardUiManger.mangerRule=nil
--node
DdzFreeMyCardUiManger.node=nil
--牌列表
DdzFreeMyCardUiManger.itemList=nil
--组件的宽度
DdzFreeMyCardUiManger.itemWidth=0
DdzFreeMyCardUiManger.width=0
--item间隔
DdzFreeMyCardUiManger.itemInterval=0
--
DdzFreeMyCardUiManger.moveDuration=0.2
local instance
function DdzFreeMyCardUiManger.Create(node,itemWidth,itemHeight,itemInterval)
	instance=DdzFreeMyCardUiManger.New()
	instance.cardCount=0
	instance.itemList={}
	--存放item的识别宽度 用于点击
	instance.itemPosList={}
    instance.Camera = GameObject.Find("Camera"):GetComponent("Camera")
	instance.node=node
	instance.nodeTransform=instance.node.transform

	instance.touch_scope=instance.node:Find("touch_scope")
	instance.touch_scope_transform=instance.touch_scope.transform
	
	instance.itemWidth=itemWidth
	instance.itemHeight=itemHeight
	instance.itemInterval=itemInterval

	instance:setRect(0,0,0)
	--默认规则
	instance.mangerRule=rule.center

	EventTriggerListener.Get(instance.touch_scope.gameObject).onDown =basefunc.handler(instance,instance.OnDown) 
    EventTriggerListener.Get(instance.touch_scope.gameObject).onUp =basefunc.handler(instance,instance.OnUp)
    

	instance.updateTimer=Timer.New(basefunc.handler(instance,instance.update), 0.05, -1,true)
    instance.updateTimer:Start()
    instance.touchFlag=false
    instance.touchStartPos=nil
	return instance
end
function DdzFreeMyCardUiManger:MyExit()
	if instance.updateTimer then
		instance.updateTimer:Stop()
		instance.updateTimer=nil
	end
end
--按顺序添加item
--[[
	node
	--权重
	weight
	--编号信息
	no
--]]
function DdzFreeMyCardUiManger:addItemByOrder(item,isRefresh)
	self.itemList[#self.itemList+1]=item
	self.cardCount=self.cardCount+1
	if isRefresh then
		self:Refresh()
	end
end
--按权值添加item
function DdzFreeMyCardUiManger:addItemByWeight(item,isRefresh)
	local pos=nil
	for idx,value in ipairs(self.itemList) do
		if value.weight>item.weight then
			table.insert(self.itemList,idx,item)
			pos=idx
			break
		end
	end
	if not pos then 
		self.itemList[#self.itemList+1]=item
		pos=#self.itemList
	end
	self.cardCount=self.cardCount+1 
	item.transform:SetSiblingIndex(#self.itemList-pos)
	if isRefresh then
		self:Refresh()
	end
end
--从容器中移除
function DdzFreeMyCardUiManger:RemoveItemByNo(no,isRefresh)
	for idx,value in ipairs(self.itemList) do
		if value.no==no then
			self.cardCount=self.cardCount-1
			table.remove(self.itemList,idx)
			break
		end
	end
end
--删除
function DdzFreeMyCardUiManger:DeleteItemByNo(no,isRefresh)
	for idx,value in ipairs(self.itemList) do
		if value.no==no then
			value:Destroy()
			self.cardCount=self.cardCount-1
			table.remove(self.itemList,idx)
			break
		end
	end
end
--删除all
function DdzFreeMyCardUiManger:DeleteAllItem()
	for idx,value in ipairs(self.itemList) do
		value:Destroy()
	end
	self.cardCount=0
	self.itemList={}
end

--计算Item位置
function DdzFreeMyCardUiManger:CalculationPos()
	if self.mangerRule==rule.center then
 		self:CalculationPosByCenter()
	end
end
function DdzFreeMyCardUiManger:Refresh()
	self:CalculationPos()
	for idx,value in ipairs(self.itemList) do
		if IsEquals(value.transform) then
		value.transform.localPosition=value.designatedPos
		value.transform:SetSiblingIndex(0)
		end
	end

	if DdzFreeModel.data then
		if DdzFreeModel.data.dizhu then
			if DdzFreeModel.data.dizhu == DdzFreeModel.data.seat_num then
				if self.itemList and #self.itemList>0 then
					DdzCardTag.New(self.itemList[1].transform:Find("@card_img/@tag"),DdzCardTagType.sp,1)
				end
			end
		end
	end
end
function DdzFreeMyCardUiManger:RefreshWithAni()
	self:CalculationPos()
	for idx,value in ipairs(self.itemList) do
		if IsEquals(value.gameObject) and IsEquals(value.gameObject.transform) then
			if value.designatedPos ~=value.gameObject.transform.localPosition  then
				
				local tweenKey
				local action=value.gameObject.transform:DOLocalMove(value.designatedPos,self.moveDuration):OnKill(function ()
								DOTweenManager.RemoveStopTween(tweenKey)
								if value and IsEquals(value.gameObject) then
									value.gameObject.transform.localPosition=value.designatedPos
								end
							end)
				tweenKey = DOTweenManager.AddTweenToStop(action)
			end
		end
	end
	
	if DdzFreeModel.data then
		if DdzFreeModel.data.dizhu then
			if DdzFreeModel.data.dizhu == DdzFreeModel.data.seat_num then
				if self.itemList and #self.itemList>0 then
					DdzCardTag.New(self.itemList[1].transform:Find("@card_img/@tag"),DdzCardTagType.sp,1)
				end
			end
		end
	end
end


function DdzFreeMyCardUiManger:CalculationPosByCenter()
	local offsetX=0
	local len=#self.itemList
	if len<18 then
		offsetX=139-(17-len)*self.itemInterval*0.5
		if offsetX<0 then
			offsetX=0
		end
	elseif len<21 then
		offsetX=139-((len-17)*self.itemInterval*0.5)
	end
	local start=((#self.itemList-1)*self.itemInterval+self.itemWidth)/2-self.itemWidth/2 + offsetX
	local width=self.itemInterval*(#self.itemList-1)+self.itemWidth
	self.itemPosList={}
	for idx,value in ipairs(self.itemList) do
		value.designatedPos=Vector3.New(start-(idx-1)*self.itemInterval,0,0)
		if idx==1 then
			self.itemPosList[idx]={sx=width-self.itemWidth,ex=width}
		else
			local _sx=width-self.itemWidth-(idx-1)*self.itemInterval
			self.itemPosList[idx]={sx=_sx,ex=_sx+self.itemInterval}
		end
	end
	self:setRect(width,self.itemHeight,offsetX)
end

function DdzFreeMyCardUiManger:setRect(width,height,offsetX)
	offsetX=offsetX or 0
	self.width=width
	self.height=height
	local x=-width*0.5 + offsetX 
	local y=-height*0.5
	self.startX=x
	--包围检查 比实际略大 为了防止给玩家留操作缓冲
	local len=0
	if self.itemList then
		len=#self.itemList
	end

	
	self.rect=tls.rect(x-400,y,self.width+800,self.height+50)


	local left_len=400
	local right_len=0

	if len>0 and len<13 then
		right_len=(13-len)*35
	end
	if right_len>400 then
		right_len=400
	end

	self.touch_scope.gameObject:GetComponent("RectTransform").sizeDelta={x=self.width+left_len+right_len,y=self.height+25}
	self.touch_scope.gameObject.transform.localPosition=Vector3.New(offsetX+(left_len-right_len)*0.5,25,0)
end

function DdzFreeMyCardUiManger:clearItemChooseStatus()
end

function DdzFreeMyCardUiManger:chooseIetm(pos)
	if not pos or not tls.rectContainsPoint(self.rect,pos) then
		for idx,v in ipairs(self.itemList) do 
			v:changeColorStaus(0)
		end
		-- self.touchStartPos=nil
		-- self.touchFlag=false
		return 
	end
	local sx=self.touchStartPos.x-self.startX
	local ex=pos.x-self.startX
	if sx>ex then
		local _=ex
		ex=sx
		sx=_
	end
	local isContain=function (s,e,p)
		if  p>=s and p<=e then
			return true
		end
		return false
	end
	for idx,v in ipairs(self.itemPosList) do 
		if isContain(sx,ex,v.sx) or isContain(sx,ex,v.ex) or isContain(v.sx,v.ex,sx) or isContain(v.sx,v.ex,ex) then
			self.itemList[idx]:changeColorStaus(1)
		else
			self.itemList[idx]:changeColorStaus(0)
		end
	end

end
function DdzFreeMyCardUiManger:GetUIPos(pos)
	local vpos =  LuaHelper.MyScreenPointToLocalPointInRectangle(self.nodeTransform,pos,self.Camera)
	return vpos
end
function DdzFreeMyCardUiManger:OnDown()
	self.touchFlag=true
	self.touchStartPos=self:GetUIPos(UnityEngine.Input.mousePosition)
	self:chooseIetm(self.touchStartPos)
end
function DdzFreeMyCardUiManger:OnUp()
	self.touchFlag=false
	local pos=self:GetUIPos(UnityEngine.Input.mousePosition)
	self.touchStartPos=nil
	local flag=false
	--******是否需要智能补全 只有全部牌都在原位的时候点击才会智能补全 
	local ic_flag=true
	local list={}

	local frist_tanqi=true
	--判断是否为第一次弹起
	for idx,v in ipairs(self.itemList) do 
		if v.posStatus==1 then
			frist_tanqi=false
			break
		end
	end
	--************


	for idx,v in ipairs(self.itemList) do 
		if v.colorStatus==1 then
			v:changeColorStaus(0)
			v:ChangePosStatus()
			if v.posStatus==0 then
				ic_flag=false
			end
			flag=true
		end
		if ic_flag and v.posStatus==1 then
			list[#list+1]=v.no
		end
	end
	if flag then
		ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_pickcard.audio_name)
		if ic_flag then
			self:intelligent_completion(list,frist_tanqi)
		end
	end
end
--智能补全
function DdzFreeMyCardUiManger:intelligent_completion(list,frist_tanqi)
	local data=DdzFreeModel.data
	if list and #list>0 and #list<18 and data and data.status==DdzFreeModel.Status.cp and data.cur_p==data.seat_num then
		local pos=nor_ddz_base_lib.get_real_chupai_pos_by_act(data.action_list)
		local type=0
		local pai=nil
		if pos then
			DdzFreeModel.ddz_algorithm:get_cpInfo_by_action(data.action_list[pos])
			type=data.action_list[pos].type
			pai=data.action_list[pos].pai
		end

		local ic_map=DdzFreeModel.ddz_algorithm:intelligent_completion(type,pai,list,data.my_pai_list,data.laizi,frist_tanqi)
		print("<color=red>&&&&&***((((((&&&&&&&</color>")
		dump(ic_map)
		--用于标记已经弹出
		local flag={}
		if ic_map then
			local _pai
			--先去除已经弹出的
			for idx,v in ipairs(self.itemList) do
				if v.posStatus==1 then
					if v.no<60 then
						_pai=nor_ddz_base_lib.pai_map[v.no]
					else
						_pai=data.laizi
					end
					if ic_map[_pai] and ic_map[_pai]>0 then
						ic_map[_pai]=ic_map[_pai]-1
						flag[v.no]=true
					else
						v:ChangePosStatus(0) 
					end
				end 
			end
			--弹起未弹起的
			for idx,v in ipairs(self.itemList) do
				if v.posStatus==0 then
					if v.no<60 then
						_pai=nor_ddz_base_lib.pai_map[v.no]
					else
						_pai=data.laizi
					end
					if ic_map[_pai] and ic_map[_pai]>0 then
						ic_map[_pai]=ic_map[_pai]-1
						v:ChangePosStatus(1)
					end
				else
					if (not ic_map[_pai] or ic_map[_pai]<1) and not flag[v.no] then
						v:ChangePosStatus(0)
					end
				end 
			end
		end
	end
end

function DdzFreeMyCardUiManger:update()
	if self.touchFlag then
		local pos=self:GetUIPos(UnityEngine.Input.mousePosition)
		self:chooseIetm(pos)
	end
end









