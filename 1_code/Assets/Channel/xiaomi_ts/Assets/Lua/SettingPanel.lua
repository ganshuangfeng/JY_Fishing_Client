-- 创建时间:2018-06-04

local basefunc = require "Game.Common.basefunc"
SettingPanel = basefunc.class()

SettingPanel.name = "SettingPanel"


SettingPanel.instance = nil


function SettingPanel.Show()
	if SettingPanel.instance then
		SettingPanel.instance:ShowUI()
		return
	end
	SettingPanel.Create()
end
function SettingPanel.Hide()
	if SettingPanel.instance then
		SettingPanel.instance:HideUI()
	end
end
function SettingPanel.Create()
	SettingPanel.instance = SettingPanel.New()
	return SettingPanel.instance
end
function SettingPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	SettingPanel.HideParent = GameObject.Find("GameManager").transform

	local obj = newObject(SettingPanel.name, parent)
	obj = obj.transform
	self.transform = obj
	self.BackButton = obj:Find("BackButton"):GetComponent("Button")
	self.BackButton.name = "set_back"-- 和引导界面重复，因为设置界面或缓存在GameManager下
	self.BackButton.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	
	self.YLScrollbar = obj:Find("RectYL/Scrollbar"):GetComponent("Scrollbar")
	self.YLScrollbar.onValueChanged:AddListener(function (val)
		self:YLRateCall(val)
	end)
	self.YLOnRate = obj:Find("RectYL/Scrollbar/OnRate"):GetComponent("RectTransform")
	self.YLOnRateImage = obj:Find("RectYL/Scrollbar/OnRate/OnRate"):GetComponent("Image")
	self.YLOnOrOffButton = obj:Find("RectYL/OnOrOffButton"):GetComponent("Button")
	self.YLOnOrOffButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnYLOnOffClick()
	end)
	self.YLOnObj = obj:Find("RectYL/OnOrOffButton/OnButton").gameObject
	self.YLOffObj = obj:Find("RectYL/OnOrOffButton/OffButton").gameObject
	self.YLOnMove = obj:Find("RectYL/OnOrOffButton/MoveImage/MoveOn").gameObject
	self.YLOffMove = obj:Find("RectYL/OnOrOffButton/MoveImage/MoveOff").gameObject
	self.YLMove = obj:Find("RectYL/OnOrOffButton/MoveImage")

	self.YXScrollbar = obj:Find("RectYX/Scrollbar"):GetComponent("Scrollbar")
	self.YXScrollbar.onValueChanged:AddListener(function (val)
		self:YXRateCall(val)
	end)
	self.YXOnRate = obj:Find("RectYX/Scrollbar/OnRate"):GetComponent("RectTransform")
	self.YXOnRateImage = obj:Find("RectYX/Scrollbar/OnRate/OnRate"):GetComponent("Image")
	self.YXOnOrOffButton = obj:Find("RectYX/OnOrOffButton"):GetComponent("Button")
	self.YXOnOrOffButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnYXOnOffClick()
	end)
	self.YXOnObj = obj:Find("RectYX/OnOrOffButton/OnButton").gameObject
	self.YXOffObj = obj:Find("RectYX/OnOrOffButton/OffButton").gameObject
	self.YXOnMove = obj:Find("RectYX/OnOrOffButton/MoveImage/MoveOn").gameObject
	self.YXOffMove = obj:Find("RectYX/OnOrOffButton/MoveImage/MoveOff").gameObject
	self.YXMove = obj:Find("RectYX/OnOrOffButton/MoveImage")

	self.ShakeOnOffButton = obj:Find("ShakeOnOffButton"):GetComponent("Button")
	self.ShakeOnOffButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnShakeOnOffClick()
	end)
	self.ShakeOnObj = obj:Find("ShakeOnOffButton/OnButton").gameObject
	self.ShakeOffObj = obj:Find("ShakeOnOffButton/OffButton").gameObject
	self.ShakeOnMove = obj:Find("ShakeOnOffButton/MoveImage/MoveOn").gameObject
	self.ShakeOffMove = obj:Find("ShakeOnOffButton/MoveImage/MoveOff").gameObject
	self.ShakeMove = obj:Find("ShakeOnOffButton/MoveImage")

	self.AudioOnOrOffButton = obj:Find("AudioOnOffButton"):GetComponent("Button")
	self.AudioOnOrOffButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnAudioOnOffClick()
	end)
	self.AudioOnObj = obj:Find("AudioOnOffButton/OnButton").gameObject
	self.AudioOffObj = obj:Find("AudioOnOffButton/OffButton").gameObject
	self.AudioMove = obj:Find("AudioOnOffButton/MoveImage")



	self.ExitButton = obj:Find("ButtonRect/ExitButton"):GetComponent("Button")
	self.ExitButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnExitClick()
	end)
	self.KFDHButton = obj:Find("ButtonRect/KFDHButton"):GetComponent("Button")
	self.KFDHButton.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		Event.Brocast("callup_service_center", "400-8882620")
	end)
	self.TJYJButton = obj:Find("ButtonRect/TJYJButton"):GetComponent("Button")
	self.TJYJButton.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		MainModel.OpenKFFK()
	end)

	self.KFDHButton.gameObject:SetActive(false)
	self.TJYJButton.gameObject:SetActive(false)

	self.VersionsText = obj:Find("VersionsText"):GetComponent("Text")
	self:InitRect()
end
function SettingPanel:InitRect()
	self:InitNMGPass()
	self.AudioOnOrOffButton.gameObject:SetActive(false)
	print(gameMgr:GetVersionNumber())
	self.VersionsText.text = "版本：" .. gameMgr:GetVersionNumber()
	if MainModel.myLocation == "game_Hall" then
		self.ExitButton.gameObject:SetActive(true)
		--self.ShakeOnOffButton.transform.localPosition = Vector3.New(238, -190, 0)
		--self.ExitButton.transform.localPosition = Vector3.New(-237, -190, 0)
	else
		self.ExitButton.gameObject:SetActive(false)
		--self.ShakeOnOffButton.transform.localPosition = Vector3.New(238, -190, 0)
	end
	self.ExitGame = function ()
		print("<color=red>收到退出的返回消息</color>")
		if SettingPanel.instance and IsEquals(SettingPanel.instance.transform) then

			-- 先清理掉动画，MainLogic.Init()会释放所有动画资源，导致一些bug
			DOTweenManager.KillAllStopTween()
			DOTweenManager.KillAllExitTween()
			DOTweenManager.CloseAllSequence()

			Event.RemoveListener("ServerConnectDisconnect", self.ExitGame)

			destroy(SettingPanel.instance.transform.gameObject)
			SettingPanel.instance = nil
			RedHintManager.CloseAllRed()
            MainLogic.Exit()
            networkMgr:Init()
            Network.Start()
            MainLogic.Init()
		end
	end

	Event.AddListener("ServerConnectDisconnect", self.ExitGame)
	
	self.YLScrollbar.value = soundMgr:GetMusicVolume(MainModel.sound_pattern)
	self.YXScrollbar.value = soundMgr:GetSoundVolume(MainModel.sound_pattern)
	self:UpdateShake()
	self:UpdateAudio()

	DOTweenManager.OpenPopupUIAnim(self.transform)
end
function SettingPanel:UpdateMusic()
	if soundMgr:GetMusicVolume(MainModel.sound_pattern) > 0.0001 then
		self.YLOnObj:SetActive(true)
		self.YLOffObj:SetActive(false)
		self.YLOffMove:SetActive(false)
		self.YLOnMove:SetActive(true)
		self.YLMove.localPosition = Vector3.New(63, 0, 0)
		soundMgr:SetIsMusicOn(true, MainModel.sound_pattern)
	else
		self.YLOnObj:SetActive(false)
		self.YLOffObj:SetActive(true)
		self.YLOnMove:SetActive(false)
		self.YLOffMove:SetActive(true)
		self.YLMove.localPosition = Vector3.New(-63, 0, 0)
		soundMgr:SetIsMusicOn(false, MainModel.sound_pattern)
	end
end
function SettingPanel:UpdateSound()
	if soundMgr:GetSoundVolume(MainModel.sound_pattern) > 0.0001 then
		self.YXOnObj:SetActive(true)
		self.YXOffObj:SetActive(false)
		self.YXOffMove:SetActive(false)
		self.YXOnMove:SetActive(true)
		self.YXMove.localPosition = Vector3.New(63, 0, 0)
		soundMgr:SetIsSoundOn(true, MainModel.sound_pattern)
	else
		self.YXOnObj:SetActive(false)
		self.YXOffObj:SetActive(true)
		self.YXOnMove:SetActive(false)
		self.YXOffMove:SetActive(true)
		self.YXMove.localPosition = Vector3.New(-63, 0, 0)
		soundMgr:SetIsSoundOn(false, MainModel.sound_pattern)
	end
end
function SettingPanel:UpdateShake()
	if soundMgr:GetIsShakeOn(MainModel.sound_pattern) then
		self.ShakeOnObj:SetActive(true)
		self.ShakeOffObj:SetActive(false)
		self.ShakeOnMove:SetActive(true)
		self.ShakeOffMove:SetActive(false)
		self.ShakeMove.localPosition = Vector3.New(46, 0, 0)
	else
		self.ShakeOnObj:SetActive(false)
		self.ShakeOffObj:SetActive(true)
		self.ShakeOnMove:SetActive(false)
		self.ShakeOffMove:SetActive(true)
		self.ShakeMove.localPosition = Vector3.New(-66, 0, 0)
	end
end
function SettingPanel:UpdateAudio()
	if soundMgr:GetIsCenterOn(MainModel.sound_pattern) then
		self.AudioOnObj:SetActive(true)
		self.AudioOffObj:SetActive(false)
		self.AudioMove.localPosition = Vector3.New(77, 0, 0)
	else
		self.AudioOnObj:SetActive(false)
		self.AudioOffObj:SetActive(true)
		self.AudioMove.localPosition = Vector3.New(-77, 0, 0)
	end
end

-- 音乐音量
function SettingPanel:YLRateCall(val)
	soundMgr:SetMusicVolume(val, MainModel.sound_pattern)
	local volume = soundMgr:GetCenterVolume(MainModel.sound_pattern) * soundMgr:GetMusicVolume(MainModel.sound_pattern)
	self.YLOnRate.sizeDelta = Vector2.New(515.34 * volume, 51.04)
	self:UpdateMusic()
end

-- 音乐开关
function SettingPanel:OnYLOnOffClick()
	soundMgr:SetIsMusicOn(not soundMgr:GetIsMusicOn(MainModel.sound_pattern), MainModel.sound_pattern)
	if soundMgr:GetIsMusicOn(MainModel.sound_pattern) then
		self.YLScrollbar.value = 1
	else
		self.YLScrollbar.value = 0
	end
end

-- 音效音量
function SettingPanel:YXRateCall(val)
	soundMgr:SetSoundVolume(val, MainModel.sound_pattern)
	local volume = soundMgr:GetCenterVolume(MainModel.sound_pattern) * soundMgr:GetSoundVolume(MainModel.sound_pattern)
	self.YXOnRate.sizeDelta = Vector2.New(515.34 * volume, 51.04)
	self:UpdateSound()
end

-- 音效开关
function SettingPanel:OnYXOnOffClick()
	soundMgr:SetIsSoundOn(not soundMgr:GetIsSoundOn(MainModel.sound_pattern), MainModel.sound_pattern)
	if soundMgr:GetIsSoundOn(MainModel.sound_pattern) then
		self.YXScrollbar.value = 1
	else
		self.YXScrollbar.value = 0
	end
end

-- 震动开关
function SettingPanel:OnShakeOnOffClick()
	soundMgr:SetIsShakeOn(not soundMgr:GetIsShakeOn(MainModel.sound_pattern), MainModel.sound_pattern)
	if soundMgr:GetIsShakeOn(MainModel.sound_pattern) then
		sdkMgr:RunVibrator(500)
	end
	self:UpdateShake()
end

-- 静音开关(总音量开关)
function SettingPanel:OnAudioOnOffClick()
	soundMgr:SetIsCenterOn(not soundMgr:GetIsCenterOn(MainModel.sound_pattern), MainModel.sound_pattern)
	self:UpdateMusic()
	self:UpdateSound()
	self:UpdateAudio()
end

-- 关闭
function SettingPanel:OnBackClick()
	self:HideUI()
end
-- 退出游戏
function SettingPanel:OnExitClick()

	Network.SendRequest("player_quit", nil, "登出",function (ret)
		if ret and ret.result~=0 then
			HintPanel.ErrorMsg(ret.result)
		else
			self.ExitGame()
		end
	end)
	
	LoginModel.ClearLoginData("dc")

	MainModel.IsLoged = false
end

-- 显示
function SettingPanel:ShowUI()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	if SettingPanel.instance and IsEquals(SettingPanel.instance.transform) then
		SettingPanel.instance.transform:SetParent(parent)
		SettingPanel.instance:InitRect()
	else
		SettingPanel.Create()
	end
end

-- 隐藏
function SettingPanel:HideUI()
	Event.RemoveListener("ServerConnectDisconnect", self.ExitGame)
	self.transform:SetParent(SettingPanel.HideParent)
end

function SettingPanel:InitNMGPass()
	local tran = self.transform
	self.nmgPass = "334455"
	self.inputPass = ""
	self.NMGCloseButton = tran:Find("NMGCloseButton"):GetComponent("Button")
	self.NMGCloseButton.onClick:AddListener(function ()
		self:NMGCloseButtonClick()
	end)
	for i=1 , 6 do
		local btn = tran:Find("NMGButton"..i):GetComponent("Button")
		btn.onClick:AddListener(function ()
			self:NMGButtonClick(btn)
		end)
	end
end
function SettingPanel:NMGButtonClick(obj)
    local uipos = tonumber(string.sub(obj.name,-1,-1))
	self.inputPass = self.inputPass .. "" .. uipos
	if self.inputPass == self.nmgPass then
		AppDefine.IsDebug = true
		print("<color=red>NMGButtonClick</color>")
		self.inputPass = ""
		local GM = GameObject.Find("GameManager")
		if GM then
			local fps = GM:GetComponent("ShowFPS")
			local rd = GM:GetComponent("RuntimeDebug")
			if fps then
				fps.enabled = true
			end
			if rd then
				rd.enabled = true
			end
		end
	elseif self.inputPass == "666" then
		package.loaded["Game.game_Login.Lua.CheatPanel"] = nil
		require "Game.game_Login.Lua.CheatPanel"
		CheatPanel.Create()
	elseif self.inputPass == "142536" then
		GameComToolPrefab.Create()
		GameManager.GotoUI({gotoui = "sys_game_tool",goto_scene_parm = "panel"})
	end
end
function SettingPanel:NMGCloseButtonClick()
	self.inputPass = ""
end
