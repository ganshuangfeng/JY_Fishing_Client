
local basefunc = require "Game/Common/basefunc"
SCLB1Panel = basefunc.class()
local C = SCLB1Panel
C.name = "SCLB1Panel"
local M = SYSSCLB1Manager
local instance
function C.Create(parent,backcall)
    if  instance==nil then
        instance = C.New(parent,backcall)
    end
    return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["model_sclb1_gift_change_msg"] = basefunc.handler(self, self.on_model_sclb1_gift_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if self.backcall then 
        self.backcall()
    end 
	self:RemoveListener()
    instance=nil
    destroy(self.gameObject)

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)
    M.CheckShopId()
    self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("SCLB1Panel"..M.type, parent)
	local tran = obj.transform
	self.transform = tran
    self.gameObject = obj
	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform,self)
	self:InitUI()
end


function C:InitUI()
    self.close_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:MyExit()
    end)
    for i=1,#SYSSCLB1Manager.shopid do
        self["gift" .. i .. "_btn"].onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            self:OnShopClick(SYSSCLB1Manager.shopid[i])
        end)
    end
---冲金鸡修改
    -- local channel_type = gameMgr:getMarketChannel()
    -- if channel_type == "cjj" then
        -- self["_icon_img"].sprite = GetTexture("com_award_icon_hfsp")
        -- self["_num_txt"].text = "x3"
    -- else
    --     self["_icon_img"].sprite = GetTexture("3dby_btn_sd")
    --     self["_num_txt"].text = "x1"
    -- end

	self:MyRefresh()
end

function C:MyRefresh()    
    
end

function C:OnShopClick(id)
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“畅游新世界”公众号获取"..self.gift_config.pay_title})
    else
        local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
	end
end

function C:on_model_sclb1_gift_change_msg()
    self:MyExit()
end

function C:OnExitScene()
	self:MyExit()
end