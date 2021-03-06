-- 创建时间:2019-05-16
-- Panel:New Lua
local basefunc = require "Game/Common/basefunc"
EliminateSHMoneyPanel = basefunc.class()
local C = EliminateSHMoneyPanel
C.name = "EliminateSHMoneyPanel"
local instance

function C:MakeLister()
    self.lister = {}
    self.lister["view_lottery_start"] = basefunc.handler(self, self.eliminate_lottery_start)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.eliminate_lottery_end)
    self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["view_lottery_sucess"] = basefunc.handler(self, self.view_lottery_sucess)
	self.lister["view_quit_game"] = basefunc.handler(self, self.view_quit_game)
	self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
	self.lister["PayPanelClosed"] = basefunc.handler(self, self.OnClosePayPanel)
    self.lister["view_lottery_start_yxcard"] = basefunc.handler(self, self.view_lottery_start_yxcard)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C.Create()
    if not instance then
        instance = C.New()
    end
    return instance
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv1").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.jiaqian = {}
    self:InitBetList()
    self.MaxIndex = #self.jiaqian
    self.index = self:GetUserBet()
    if self.index >= self.MaxIndex then 
        self.index = self.MaxIndex
    end 
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    self:InitChildButton()
    self:RefreshGoldText()
    self:CheakButtonStatus()
end

function C:MyExit()
    self:RemoveListener()
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
    destroy(self.gameObject)
end

function C:Close()
    self:MyExit()
end

--根据用户的金币数量获得一个初始档位
function C:GetUserBet()
    local data=EliminateSHModel.xiaoxiaole_sh_defen_cfg.auto
    local qx_max = self.MaxIndex
    for i=#data,1,-1 do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="sh_xxl_bet_".. i, is_on_hint=true}, "CheckCondition")
        if not a or b then
            qx_max = i
            break
        end 
    end
    for i = qx_max,1,-1 do
        if not data[i].min or MainModel.GetMiniGameCoinAndJingBiAllNum() >= data[i].min then 
            return i
        end 
    end
    return 1
end

--初始化押注的档次表
function C:InitBetList()
    for key, value in pairs(EliminateSHModel.xiaoxiaole_sh_defen_cfg.yazhu) do
        self.jiaqian[value.dw] = value.jb
    end
end

function C:InitUI()
    local betdata = EliminateSHModel.GetBet()
    self.Content = self.transform:Find("Viewport/layoutgroup")
    self.GoldText = self.gameObject.transform:Find("GoldInfo/GoldText"):GetComponent("Text")
    self.jiaqianText = self.gameObject.transform:Find("AddMoney/Text"):GetComponent("Text")
    self.ps = self.gameObject.transform:Find("AddMoney/shanguang"):GetComponent("ParticleSystem")
    self.Addbutton = self.gameObject.transform:Find("AddMoney/AddButton"):GetComponent("Button")
    self.Redubutton = self.gameObject.transform:Find("AddMoney/ReduButton"):GetComponent("Button")
    self.PayBtn = self.gameObject.transform:Find("GoldInfo/PayBtn"):GetComponent("Button")
    self.PayBtn_ = self.gameObject.transform:Find("CoinInfo/PayBtn_"):GetComponent("Button")
    self.jiaqianText.text = self.jiaqian[self.index]
    EventTriggerListener.Get(self.Addbutton.gameObject).onClick = basefunc.handler(self, self.OnAddOnClick)
    EventTriggerListener.Get(self.Redubutton.gameObject).onClick = basefunc.handler(self, self.OnReduOnClick)
    EventTriggerListener.Get(self.PayBtn.gameObject).onClick = basefunc.handler(self, self.OpenPayPanel)
    EventTriggerListener.Get(self.PayBtn_.gameObject).onClick = basefunc.handler(self, self.OpenPayPanel)
   
    self.btn_node = self.gameObject.transform:Find("btn_node")
    local btn_map = {}
	self.btn_node=self.gameObject.transform:Find("btn_node")
    btn_map["money_btn"] = {self.btn_node}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlsh_game")
    
end

function C:RefreshGoldText()
    self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新金币显示
    self.coin_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("prop_tiny_game_coin"))--刷新小游戏币显示
end

--增加押注
function C:OnAddOnClick()
    if self.index + 1 == self.MaxIndex then
        self.Addbutton.gameObject:SetActive(false)
    end
    if self.index < self.MaxIndex then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_jiajianzhu.audio_name)
        self.index = self.index + 1
        self.Redubutton.gameObject:SetActive(true)

        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="sh_xxl_bet_".. self.index}, "CheckCondition")
        if a and not b then
            self.index = self.index - 1
            return
        end
        self.yazhu = self.jiaqian[self.index]
        if MainModel.GetMiniGameCoinAndJingBiAllNum() < self.yazhu then
            self.index = self.index - 1
            C:OpenPayPanel()
            return
        end
        self:SetChildBet()
        self:PlayParticle()
    end
end

--初始化子按钮
function C:InitChildButton()
    self.childs = {}
    for i = 1, 5 do
        local child = EliminateSHButtonPrefab.Create(i, self.jiaqian[self.index] / 5, self.Content)
        self.childs[i] = child
    end
end

--播放特效
function C:PlayParticle()
    self.ps:Stop()
    self.ps:Play()
end

--减少押注
function C:OnReduOnClick()
    if self.index - 1 == 1 then
        self.Redubutton.gameObject:SetActive(false)
    end
    if (self.index - 1) > 0 then
        ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_jiajianzhu.audio_name)
        self.Addbutton.gameObject:SetActive(true)
        self.index = self.index - 1
        self.yazhu = self.jiaqian[self.index]

        self:SetChildBet()
        self:PlayParticle()
    end
end

function C:AssetChange(data)
    if table_is_null(EliminateSHModel.data) or EliminateSHModel.data.status_lottery == EliminateSHModel.status_lottery.run then return end
	if data.change_type and data.change_type ~= "xxl_shuihu_game_award" and data.change_type ~= "task_award_no_show" then
        self:RefreshGoldText()
    end
end

--开奖状态下禁止按钮
function C:eliminate_lottery_start()
    self.Addbutton.gameObject:SetActive(false)
	self.Redubutton.gameObject:SetActive(false)
	self.PayBtn.gameObject:SetActive(false)
    self.PayBtn_.gameObject:SetActive(false)
end

--开奖结束恢复按钮
function C:eliminate_lottery_end()
	self:RefreshGoldText()
    if not EliminateSHModel.GetAuto() then
        self.Addbutton.gameObject:SetActive(true)
		self.Redubutton.gameObject:SetActive(true)
		self.PayBtn.gameObject:SetActive(true)
        self.PayBtn_.gameObject:SetActive(true)
    else
        self.yazhu = self.jiaqian[self.index]
        if self.yazhu > MainModel.GetMiniGameCoinAndJingBiAllNum() then
        end
    end
    self:CheakButtonStatus()
end

--开奖成功
function C:view_lottery_sucess()
	--self:RefreshGoldText()
end

--开奖错误
function C:view_lottery_error()
	self:RefreshGoldText()
    self.Addbutton.gameObject:SetActive(true)
	self.Redubutton.gameObject:SetActive(true)
	self.PayBtn.gameObject:SetActive(true)
    self.PayBtn_.gameObject:SetActive(true)
    self.yazhu = self.jiaqian[self.index]
    if self.index < 1 then
        self.index = 1
    end
    self.yazhu = self.jiaqian[self.index]
    self:SetChildBet()
    self:CheakButtonStatus()
    self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)--刷新金币显示
    self.coin_txt.text = StringHelper.ToCash(GameItemModel.GetItemCount("prop_tiny_game_coin"))--刷新小游戏币显示
end

--开奖错误
function C:view_quit_game()
    self:Close()
end

--打开商城
function C:OpenPayPanel()
    GameButtonManager.RunFun({ gotoui="sys_jjj"}, "CheckAndRunJJJ", function ()
        Event.Brocast("show_gift_panel")
    end)
end

--当商城关闭时候
function C:OnClosePayPanel()
    self:RefreshGoldText()
end

function C:SetChildBet()
    self.jiaqianText.text = self.jiaqian[self.index]
    for i = 1, 5 do
        self.childs[i]:SetBet(self.jiaqian[self.index] / 5)
    end
end

--检查按钮的状态
function C:CheakButtonStatus()
    self.jiaqianText.text = self.jiaqian[self.index]
    if self.index == 1 then
        self.Redubutton.gameObject:SetActive(false)
    end
    if self.index == self.MaxIndex then
        self.Addbutton.gameObject:SetActive(false)
    end
end

--用游戏卡抽奖时
function C:view_lottery_start_yxcard()
    local jiaqian_card = EliminateSHModel.data.bet[1] * 5
    if self.jiaqian[self.index] ~= jiaqian_card then
        for k,v in ipairs(self.jiaqian) do
            if v == jiaqian_card then
                self.index = k
            end
        end
    end
    self:SetChildBet()
end
