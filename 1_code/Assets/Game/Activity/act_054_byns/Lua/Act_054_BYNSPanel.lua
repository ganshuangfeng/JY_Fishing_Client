-- 创建时间:2021-03-08
-- Panel:Act_054_BYNSPanel
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

Act_054_BYNSPanel = basefunc.class()
local C = Act_054_BYNSPanel
local M = Act_054_BYNSManager
C.name = "Act_054_BYNSPanel"
local isshowHelp=true

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_xcns_task_refresh"] = basefunc.handler(self,self.on_model_xcns_task_refresh)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.cutdown_timer then
		self.cutdown_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUICfg()
	self:InitUI()
end

function C:InitUICfg()
	self.cfg = M.GetConfig()
end

function C:RefreshPanel()
	self.data = M.GetTaskData()
	self.lv = M.GetTaskLv()
	self:RefreshContentUI()
	self:RefreshProgressUI()
end

function C:MyRefresh()
	self:RefreshPanel()
end

function C:InitUI()
	self.zhizhen.gameObject:SetActive(false)

    self.cutdown_timer =CommonTimeManager.GetCutDownTimer(M.GetActEndTime(),self.remian_time_txt)
	---对应框架{底边描述}参数
	local downStr= M.GetDowDesc()
	if downStr and downStr~="" then
		self.down_txt.text=downStr
	end
	self:InitContentPre()
	self:InitProgressPre()
	self.get_btn.onClick:AddListener(function ()
		self:GetBtnOnClick()
	end)
	self.help_btn.onClick:AddListener(function ()
		self:OpenHelpPanel()
	end)
	self.help_btn.gameObject:SetActive(isshowHelp)

	self:MyRefresh()
end

function C:InitContentPre()
	self.content_pre = {}
	for i = 1, #self.cfg do
		local b = newObject("Act_054_BYNSItem", self.content_2.transform)
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform, b_ui)
		b_ui.award_name_txt.text = self.cfg[i].award_name
		b_ui.award_amount_txt.text = self.cfg[i].award_amount
		b_ui.award_icon_img.gameObject:SetActive(true)
		b_ui.award_icon_img.sprite = GetTexture(self.cfg[i].award_icon)
		b_ui.award_get_btn.onClick:AddListener(function()
			Network.SendRequest("get_task_award_new", { id = M.m_task_id, award_progress_lv = i })
		end)
		b_ui.tips_btn.onClick:AddListener(function()
			if self.cfg[i].tips then
				LittleTips.Create(self.cfg[i].tips)
			end
		end)
		self.content_pre[i] = b
	end
end

function C:InitProgressPre()

	for i = 1, self.d_content.transform.childCount do
		local b = self.d_content.transform:GetChild(i - 1)
		local need_num_txt = b.transform:GetComponent("Text")
		need_num_txt.text = self.cfg[i].need_num .. "积分"
	end

end

function C:GetBtnOnClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

	if MainModel.myLocation == "game_Fishing3D" 
	then 
		--HintPanel.Create(1,"已在游戏中")
        LittleTips.Create("已在游戏中")
		return
	end
	Event.Brocast("exit_fish_scene")
	GameManager.CommonGotoScence({gotoui = M.GetGotoUIStr()})

end

function C:RefreshContentUI()
	local isShowFinger=false
	self:ReSetZhiZhen()
	local check_value
	if self.lv == 1 then
		--self:ReSetZhiZhen()
		self:SetZhiZhen(1)
	else
		check_value = self.lv == #self.cfg and self.lv or self.lv - 1
	end

	for i = 1, #self.cfg do
		if not self.content_pre[i] or not self.data.award_status[i] then
			break
		end
		if check_value and i == check_value then
			dump(check_value,"<color=white>check_value</color>")
			self:SetZhiZhen(i)
			-- self.zhizhen.transform:SetParent(self.content_pre[i].transform)
			-- self.zhizhen.transform.localPosition = Vector3.zero
			-- self.zhizhen.gameObject:SetActive(true)
			-- self.my_progress_txt.text = self.data.now_total_process
		end
		local b_ui = {} 
		LuaHelper.GeneratingVar(self.content_pre[i].transform,b_ui)
		b_ui.award_get_btn.gameObject:SetActive(self.data.award_status[i] == 1)
		b_ui.tips_btn.gameObject:SetActive(not (self.data.award_status[i] == 1))
		b_ui.bg_1.gameObject:SetActive(self.data.award_status[i] == 1)
		b_ui.finger.gameObject:SetActive(false)
		b_ui.award_geted.gameObject:SetActive(self.data.award_status[i] == 2)
		self:LoadNameOutLine(b_ui.award_name_txt,self.data.award_status[i] == 1)
		self:LoadNameOutLine(b_ui.award_amount_txt,self.data.award_status[i] == 1)
		if self.data.award_status[i]==1 and not isShowFinger then
			isShowFinger=true
			b_ui.finger.gameObject:SetActive(true)
		end
	end
end

local width_p = 236.2
local width_p_1 = 91.91

function C:RefreshProgressUI()
	for i = 1, self.b_content.transform.childCount do
		local b = self.b_content.transform:GetChild(i - 1)
		local b_rect_trans = b:GetComponent("RectTransform")
		local b_rect = b:GetComponent("RectTransform").rect

		if i > self.lv then
			b_rect_trans.sizeDelta = { x = 0, y = b_rect.height }
		elseif i < self.lv then
			if i == 1 then
				b_rect_trans.sizeDelta = { x = width_p_1, y = b_rect.height }
			else
				b_rect_trans.sizeDelta = { x = width_p, y = b_rect.height }
			end
		else
			if self.lv == 1 then
				local rate = self.data.now_total_process / self.cfg[self.lv].need_num
				b_rect_trans.sizeDelta = { x = width_p_1 * rate, y = b_rect.height }
			else
				local rate = (self.data.now_total_process - self.cfg[self.lv - 1].need_num) / (self.cfg[self.lv].need_num - self.cfg[self.lv - 1].need_num)
				rate = rate > 1 and 1 or rate
				b_rect_trans.sizeDelta = { x = width_p * rate, y = b_rect.height }
			end
		end
	end

	for i = 1, self.c_content.transform.childCount do
		local b = self.c_content.transform:GetChild(i - 1)
		b.gameObject:SetActive(i < self.lv)
	end
end

function C:SetZhiZhen(i)
	self.zhizhen.transform:SetParent(self.content_pre[i].transform)
	self.zhizhen.transform.localPosition = Vector3.zero
	self.zhizhen.gameObject:SetActive(true)
	self.my_progress_txt.text = self.data.now_total_process
end

function C:ReSetZhiZhen()
	self.zhizhen.transform:SetParent(self.transform)
	self.zhizhen.transform.localPosition = Vector3.zero
	self.zhizhen.gameObject:SetActive(false)
end

local out_linc_c1 = Color.New(70/255,80/255,168/255)
local out_linc_c2 = Color.New(204/255,106/255,52/255)

function C:LoadNameOutLine(txt_obj,is_can_get)
	local out_line = txt_obj:GetComponent("Outline")
	if not out_line then
		return 
	end
	if is_can_get then
		out_line.effectColor = out_linc_c2
	else
		out_line.effectColor = out_linc_c1
	end
end

function C:on_model_xcns_task_refresh()
	self:MyRefresh()
end
function C:GetCurHelpInfor()
    local help_desc = {
	"1.10000及以上炮倍捕鱼可获得积分，获得积分数量=鱼的倍数。",
	"2.每日0点重置积分和奖励。",
	"3.美人鱼、骰子龟、宝藏章鱼不计入数据统计。"}
    local sta_t = self:GetStart_t()
    local end_t = self:GetEnd_t()
    -- help_desc[1] = "1.活动时间：".. sta_t .."-".. end_t
    return help_desc
end

function C:GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",self.cfg.startTime),1,1) ~= "0" and os.date("%m月%d日%H:%M",self.cfg.startTime) or string.sub(os.date("%m月%d日%H:%M",self.cfg.startTime),2)
end

function C:GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",self.cfg.endTime),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",self.cfg.endTime) or string.sub(os.date("%m月%d日%H:%M:%S",self.cfg.endTime),2)
end

function C:OpenHelpPanel()
	local str
	local help_info = self:GetCurHelpInfor()
	str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform, "IllustratePanel_New")
end