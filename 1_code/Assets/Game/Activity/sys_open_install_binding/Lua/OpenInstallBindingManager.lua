-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
OpenInstallBindingManager = {}
local M = OpenInstallBindingManager
M.key = "sys_open_install_binding"
M.head_image_server = GameButtonManager.ExtLoadLua(M.key, "head_image_server")
GameButtonManager.ExtLoadLua(M.key, "ChangeNamePanel")
GameButtonManager.ExtLoadLua(M.key, "ChangeHeadIconPanel")
GameButtonManager.ExtLoadLua(M.key, "ChangeHeadIconItem")
GameButtonManager.ExtLoadLua(M.key, "SysOpenInstallBindingPanel")
local lister
function M.CheckIsShow()
    if not GameGlobalOnOff.OpenInstall then
        return
    end
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "player_info" then
        return SysOpenInstallBindingPanel.Create(nil,parm)
    elseif parm.goto_scene_parm == "share" then
        return SysOpenInstallBindingPanel.Create(nil,parm)
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
    OpenInstallMgr.Initialization()
    OpenInstallMgr.GetInstall()
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

function M.GetHeadImage()
    if not M.head_image_server or not MainModel or not MainModel.UserInfo or not MainModel.UserInfo.img_type then return end
    return M.head_image_server.head_images[MainModel.UserInfo.img_type].url
end