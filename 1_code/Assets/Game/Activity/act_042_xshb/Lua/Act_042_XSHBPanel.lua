-- 创建时间:2020-11-30
-- Panel:Template_NAME
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_042_XSHBPanel = basefunc.class()
local C = Act_042_XSHBPanel
C.name = "Act_042_XSHBPanel"
local M = Act_042_XSHBManager
local DESCRIBE_TEXT = {
	[1] = "1.解锁任务并完成，可领取支付宝红包",
	[2] = "2.任务每日9点重置，未完成的任务退还福利券",
	[3] = "3.支付宝红包提取失败后，红包金额会自动转入赚钱→我的收益里",
}

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["xian_shi_hong_bao_change"] = basefunc.handler(self,self.on_xian_shi_hong_bao_change)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["unlock_xian_shi_hong_bao_response"] = basefunc.handler(self,self.on_unlock_xian_shi_hong_bao_response)
end
--@Event.Brocast("xian_shi_hong_bao_change",{data = {}})

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	M.ExitCheck()
	if self.Timer then
		self.Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	Network.SendRequest("query_total_xian_shi_hong_bao_data")
    Network.SendRequest("query_xian_shi_hong_bao_system_data")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.Timer = Timer.New(
		function()
			Network.SendRequest("query_total_xian_shi_hong_bao_data")
			Network.SendRequest("query_xian_shi_hong_bao_system_data")
		end
	,10,50)
	self.Timer:Start()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.bind_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
		end
	)
	self.fuka_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
	self:InitMainUI()
	self:MyRefresh()
end

function C:InitMainUI()
	self.Item_Data = {}
	for i = 1,#M.config.base do
		local cfg = M.config.base[i]
		if cfg.is_on == 1 then  
			if M.ShowCheck(cfg.show_permission) then
				local temp_ui = {}
				local b = GameObject.Instantiate(self.item,self.content)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform,temp_ui)
				if cfg.tag == "新人" then
					temp_ui.tag_img.sprite = GetTexture("xshb_icon_bq2")
				else
					temp_ui.tag_img.sprite = GetTexture("xshb_icon_bq1")
					temp_ui.tag_txt.text = cfg.tag
				end
				temp_ui.tag_img.gameObject:SetActive(not not cfg.tag)
				temp_ui.award_txt.text = cfg.award
				temp_ui.task_txt.text = cfg.task_txt
				local task_data = GameTaskModel.GetTaskDataByID(cfg.task_id)
				if not task_data then return end
				dump(task_data,"<color=red>++++++++++++任务数据++++++++++</color>")
				if task_data.id == 1000663 then
					local num = 0
					if task_data.now_process >= 600 then
						num = 1
					end
					temp_ui.pro_txt.text = "("..num.."/1)"
				else
					temp_ui.pro_txt.text = "("..task_data.now_process.."/"..task_data.need_process..")"
				end
				
				local m_data = M.GetDataByTaskID(cfg.task_id)
				dump(m_data,"m_data:  ")
				if not m_data then return end
				if m_data.total_remain == -1 then
					temp_ui.t2_txt.text = " "
					temp_ui.remian_txt.text = "剩余".. m_data.unlock_remain.."份"
				else
					temp_ui.t2_txt.text = ""
					temp_ui.remian_txt.text = "剩余".. m_data.total_remain.."份"
				end
				if m_data.unlock_type == 1 then
					temp_ui.t1_txt.text = "终身可领    次"
				else
					temp_ui.t1_txt.text = "今日可领    次"
				end
				temp_ui.limit_txt.text = m_data.unlock_remain
				temp_ui.unlock_txt.text = "消耗"..cfg.cost.."福利券"
				temp_ui.goto_btn.onClick:AddListener(
					function()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
						if cfg.goto_ui == "shop" then
							PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
							return
						end
						local parm = {}
						SetTempParm(parm, cfg.goto_ui)
						GameManager.GotoUI(parm)
					end
				)
				temp_ui.get_btn.onClick:AddListener(
					function()
						--鲸鱼斗地主新手引导最后一步埋点
						if cfg.task_id == M.sp_taskid then
							Event.Brocast("bsds_send_power",{key = "click_xsyd_xshb_get_award"})
						end
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
						MainModel.GetBindZFB(function(  )
							if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
								LittleTips.Create("请先绑定支付宝")
								GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
							else
								Network.SendRequest("get_task_award",{id = cfg.task_id})
							end
						end)
					end
				)
				temp_ui.unlock_btn.onClick:AddListener(
					function()
						ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
						if GameItemModel.GetItemCount("shop_gold_sum") >= cfg.cost then
							if M.UnlockCheck(cfg.unlock_permission) then
								local m_data = M.GetDataByTaskID(cfg.task_id)
								if m_data.total_remain == -1 or m_data.total_remain > 0 then				
									Network.SendRequest("unlock_xian_shi_hong_bao",{unlock_id = cfg.unlock_id},nil,function()
										Network.SendRequest("query_total_xian_shi_hong_bao_data")
    									Network.SendRequest("query_xian_shi_hong_bao_system_data")
									end)
								else
									LittleTips.Create("任务已被抢光，每日9点刷新")
								end
							end
						else
							LittleTips.Create("福利券不足~")
						end
					end
				)
				local re = {ui = temp_ui,config = cfg,prefab = b}
				self.Item_Data[#self.Item_Data + 1] = re

				--引导特殊处理
				if cfg.task_id == M.sp_taskid then
					temp_ui.unlock_btn.gameObject.name = "xshb_21578_unlock_btn"
					temp_ui.get_btn.gameObject.name = "xshb_21578_get_btn"
				end

				if temp_ui.xshb_21578_unlock_btn then
					temp_ui.unlock_btn = temp_ui.xshb_21578_unlock_btn
				end
				if temp_ui.xshb_21578_get_btn then
					temp_ui.get_btn = temp_ui.xshb_21578_get_btn
				end
			end
		end
	end
end

function C:on_unlock_xian_shi_hong_bao_response(_,data)
	dump(data,"<color=red>解锁返回</color>")
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	if IsEquals(self.guide_dianji) then
		destroy(self.guide_dianji.gameObject)
	end
	for i = 1,#self.Item_Data do
		local cfg = self.Item_Data[i].config
		local temp_ui = self.Item_Data[i].ui
		local task_data = GameTaskModel.GetTaskDataByID(cfg.task_id)
		if task_data.id == 1000663 then
			local num = 0
			if task_data.now_process >= 600 then
				num = 1
			end
			temp_ui.pro_txt.text = "("..num.."/1)"
		else
			temp_ui.pro_txt.text = "("..task_data.now_process.."/"..task_data.need_process..")"
		end
		local m_data = M.GetDataByTaskID(cfg.task_id)
		if m_data.total_remain == -1 then
			temp_ui.t2_txt.text = " "
			temp_ui.remian_txt.text = "剩余".. m_data.unlock_remain.."份"
		else
			temp_ui.t2_txt.text = ""
			temp_ui.remian_txt.text = "剩余".. m_data.total_remain.."份"
		end
		if m_data.unlock_type == 1 then
			temp_ui.t1_txt.text = "终身可领    次"
		else
			temp_ui.t1_txt.text = "每日可领    次"
		end
		temp_ui.limit_txt.text = m_data.unlock_remain
		if task_data.other_data_str and basefunc.parse_activity_data(task_data.other_data_str).is_unlock == 1 then
			if task_data.award_status == 1 then
				temp_ui.get_btn.gameObject:SetActive(true)
				temp_ui.finish.gameObject:SetActive(false)
				temp_ui.goto_btn.gameObject:SetActive(false)
				temp_ui.unlock_btn.gameObject:SetActive(false)
				temp_ui.remian_txt.text = "已解锁"
				temp_ui.limit_txt.text = m_data.unlock_remain + 1
			elseif task_data.award_status == 2 then
				if m_data.unlock_remain == 0 then
					temp_ui.get_btn.gameObject:SetActive(false)
					temp_ui.finish.gameObject:SetActive(true)
					temp_ui.goto_btn.gameObject:SetActive(false)
					temp_ui.unlock_btn.gameObject:SetActive(false)
					temp_ui.remian_txt.text = "已解锁"
				else
					temp_ui.get_btn.gameObject:SetActive(false)
					temp_ui.finish.gameObject:SetActive(false)
					temp_ui.goto_btn.gameObject:SetActive(false)
					temp_ui.unlock_btn.gameObject:SetActive(true)
				end
			else
				temp_ui.get_btn.gameObject:SetActive(false)
				temp_ui.finish.gameObject:SetActive(false)
				temp_ui.goto_btn.gameObject:SetActive(true)
				temp_ui.unlock_btn.gameObject:SetActive(false)
				temp_ui.remian_txt.text = "已解锁"
				temp_ui.limit_txt.text = m_data.unlock_remain + 1
			end

			if cfg.task_id and cfg.task_id == M.sp_taskid and GuideLogic then
				if task_data.award_status == 1 then
					self.guide_dianji = newObject("dianji_xshb",temp_ui.get_btn.transform)
				end
			end

			-- if m_data.unlock_remain == 0 and task_data.award_status == 2 then
			-- 	self.Item_Data[i].prefab.gameObject:SetActive(false)
			-- end
			if cfg.task_id==1000663 or cfg.task_id==1000664 then
				if task_data.award_status == 2 and m_data.unlock_remain == 0 then
					self.Item_Data[i].prefab.gameObject:SetActive(false)
				end
			end
		else
			temp_ui.get_btn.gameObject:SetActive(false)
			temp_ui.finish.gameObject:SetActive(false)
			temp_ui.goto_btn.gameObject:SetActive(false)
			temp_ui.unlock_btn.gameObject:SetActive(true)
			-- if m_data.unlock_remain == 0 then
			-- 	self.Item_Data[i].prefab.gameObject:SetActive(false)
			-- end
			if cfg.task_id==1000663 or cfg.task_id==1000664 then
				if task_data.award_status == 2  and m_data.unlock_remain == 0 then
					self.Item_Data[i].prefab.gameObject:SetActive(false)
				end
			end

			if cfg.task_id and cfg.task_id == M.sp_taskid and GuideLogic then
				-- GuideLogic.CheckRunGuide("xshb_panel")
			end
		end
	end
end

function C:OnAssetChange()
	self.fuka_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
end

function C:on_xian_shi_hong_bao_change()
	--dump("<color=red>-----on_xian_shi_hong_bao_change-----</color>")
	self:MyRefresh()
end

function C:on_model_task_change_msg()
	self:MyRefresh()
end

function C:OpenHelpPanel()
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end