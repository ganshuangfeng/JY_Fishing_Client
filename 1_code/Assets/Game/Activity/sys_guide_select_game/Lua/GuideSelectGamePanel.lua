-- 创建时间:2018-12-13

GuideSelectGamePanel = {}


local basefunc = require "Game.Common.basefunc"

GuideSelectGamePanel = basefunc.class()

local C = GuideSelectGamePanel

C.name = "GuideSelectGamePanel"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)

    self.guideddz_Polygon = self.guideddz_Polygon:GetComponent("PolygonClick")
    self.guideddz_Polygon.PointerClick:AddListener(function (obj)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnDDZClick()
    end)
    self.guidemj_Polygon = self.guidemj_Polygon:GetComponent("PolygonClick")
    self.guidemj_Polygon.PointerClick:AddListener(function (obj)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnMJClick()
    end)
    self:InitUI()
end

function C:InitUI()
	GuideLogic.CheckRunGuide("guide_select")
end

function C:MyExit()
	self:RemoveListener()
    destroy(self.gameObject)
end

function C:OnMJClick()
	GameFreeModel.SetInitRapidID (17)
	self:OnBackClick()
end

function C:OnDDZClick()
	GameFreeModel.SetInitRapidID (1)
	self:OnBackClick()
end

function C:OnBackClick()
	self:MyExit()
end



