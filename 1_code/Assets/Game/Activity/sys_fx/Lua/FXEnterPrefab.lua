-- 创建时间:2019-09-25
-- Panel:FXEnterPrefab
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
 --]]

local basefunc = require "Game/Common/basefunc"

FXEnterPrefab = basefunc.class()
local C = FXEnterPrefab
C.name = "FXEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
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
	RedHintManager.RemoveRed(RedHintManager.RedHintKey.RHK_Share, self.share_red.gameObject)

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("share_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)

	RedHintManager.AddRed(RedHintManager.RedHintKey.RHK_Share, self.share_red.gameObject)
	-- 获取分享的状态数据
	MainModel.GetShareStatusPYQ()
	MainModel.GetShareStatusHY()

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnEnterClick()
	SharePanel.Create()
end

function C:OnDestroy()
	self:MyExit()
end
