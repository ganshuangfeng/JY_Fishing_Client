-- 创建时间:2019-03-19
-- Panel:FishingDRUninstallPanel
local basefunc = require "Game/Common/basefunc"

FishingDRUninstallPanel = basefunc.class()
local C = FishingDRUninstallPanel
C.name = "FishingDRUninstallPanel"

C.LoadingState = 
{
	LS_Res = "加载资源",
	LS_Ready = "发送准备",
	LS_Recover = "恢复场景",
	LS_Finish = "加载完成",
}

local instance
function C.Create(call)
	return C.New(call)
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timerUpdate then
		self.timerUpdate:Stop()
		self.timerUpdate = nil
	end
	if self.call then
		if type(self.call) == "function" then
			self.call()
			self.call = nil
		end
	end
	self:RemoveListener()
	-- GameObject.Destroy(self.transform.gameObject)

	 
end

function C:ctor(call)

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.call = call

	self.by_bg = tran:Find("UINode/BGImage"):GetComponent("Image")
	self.RateText = tran:Find("UINode/RateText"):GetComponent("Text")
	self.Rate = tran:Find("UINode/Rate"):GetComponent("Image")
	self.RateNode = tran:Find("UINode/Rate/RateNode")
	self.width = 1000
	self.load_state = C.LoadingState.LS_Res
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	local bg = self.transform:Find("UINode/BGImage")
	MainModel.SetGameBGScale(bg)
end

function C:InitUI()
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
	local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
    if matchWidthOrHeight == 0 then
        self.by_bg.transform.localScale = Vector3.New(1, 1, 1)
    else
        self.by_bg.transform.localScale = Vector3.New(1.25, 1.25, 1)
    end

	self.Rate.fillAmount = 0
	self.RateText.text = "0%"
	self.RateNode.localPosition = Vector3.New(-self.width/2, 0, 0)

	self.rate_val = 0
	self.currLoadCount = 0
	self.allLoadCount = #FishingModel.Config.fish_cache_list
	self.timerUpdate = Timer.New(function ()
		self:Update()
	end, -1, -1, true)
	self.timerUpdate:Start()
end

function C:UninstallAssetAsync()
	-- 卸载
	for k,v in ipairs(FishingModel.Config.fish_cache_list) do
		CachePrefabManager.DelCachePrefab(v.prefab)
		Yield(0)
        self.currLoadCount = self.currLoadCount + 1
	end
end

function C:Update()
	if self.load_state == C.LoadingState.LS_Res then
		FishingModel.IsLoadRes = true
		coroutine.start(function ( )
			self:UninstallAssetAsync()
		end)
		self.load_state = C.LoadingState.LS_Res_Loading
	elseif self.load_state == C.LoadingState.LS_Res_Loading then
		self.rate_val = self.currLoadCount / self.allLoadCount
		self:UpdateRate(self.rate_val)
		if self.rate_val >= 1 then
			self.load_state = C.LoadingState.LS_Ready
		end
	else
		FishingModel.IsLoadRes = false
		self:MyExit()
	end
end

function C:UpdateRate(val)
	if IsEquals(self.Rate) then
		self.Rate.fillAmount = val
	end

	if IsEquals(self.RateText) then
		self.RateText.text = string.format("%.2f", val * 100) .. "%"
	end

	if IsEquals(self.RateNode) then
		self.RateNode.localPosition = Vector3.New(-self.width/2 + self.width * val, 0, 0)
	end
end
