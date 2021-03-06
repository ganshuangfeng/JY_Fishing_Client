-- 创建时间:2021-01-25
-- Act_049_XYHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_049_XYHLManager = {}
local M = Act_049_XYHLManager
M.key = "Act_049_XYHL"
GameButtonManager.ExtLoadLua(M.key, "Act_049_XYHLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_049_XYHLHintPanel")
M.act_config=GameButtonManager.ExtLoadLua(M.key,"act_049_config")


local this
local lister
M.sta_time = M.act_config.config.sta_time
M.end_time = M.act_config.config.end_time
M.JudgeType=M.act_config.config.judge_type
M.judgeNum=M.act_config.config.judge_num
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time -- = M.end_time
    local s_time --= M.sta_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then 
        return
    end
    if parm.goto_scene_parm == "panel" then
        return Act_049_XYHLPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["new_game_gift_query_cdk_response"] = this.on_new_game_gift_query_cdk_response
    lister["new_game_gift_get_cdk_response"] = this.on_new_game_gift_get_cdk_response
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()
    M.cdk = nil
	this = Act_049_XYHLManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("new_game_gift_query_cdk")
	end
end

function M.OnReConnecteServerSucceed()

end
M.cdk = nil
function M.on_new_game_gift_query_cdk_response(_,data)
    if data.result == 0 then
        M.cdk = data.cdk
        if data.cdk then
            SYSACTBASEManager.ForceToChangeIndex(M.key,100)
        end
    end
    Event.Brocast("new_game_gift_query_cdk_changed")
end

function M.on_new_game_gift_get_cdk_response(_,data)
    if data.result == 0 then
        M.cdk = data.cdk
    end
    Event.Brocast("new_game_gift_query_cdk_changed")
end