-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysInteractiveAniManager = {}
local M = SysInteractiveAniManager
M.key = "sys_interactive_ani"
M.config = GameButtonManager.ExtLoadLua("sys_interactive_player", "player_Interaction")
GameButtonManager.ExtLoadLua(M.key, "GameAnimChatLogic")
GameButtonManager.ExtLoadLua(M.key, "GameAnimChatModel")
GameButtonManager.ExtLoadLua(M.key, "GameAnimChatPanel")
local lister
function M.CheckIsShow()
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return GameAnimChatPanel.SendAnimChat(parm.u_id, parm.u_id, parm.key)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if M then
		RemoveLister()
		M.m_data = nil
	end
end
function M.InitUIConfig()
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.Init(model)
    GameAnimChatLogic.Init(model)
end
function M.Exit(  )
    GameAnimChatLogic.Exit()
end