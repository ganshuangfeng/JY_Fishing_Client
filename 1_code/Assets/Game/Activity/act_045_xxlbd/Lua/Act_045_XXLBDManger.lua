-- 创建时间:2020-09-28
-- JjcyXxlbdManger 管理器
local basefunc = require "Game/Common/basefunc"
Act_045_XXLBDManger = {}
local M = Act_045_XXLBDManger
M.key = "act_045_xxlbd"
--GameButtonManager.ExtLoadLua(M.key, "Act_034_JjcyXxlbdEnter")
GameButtonManager.ExtLoadLua(M.key, "Act_045_XXLBDPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_045_XXLBDEXTRAPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_045_XXLBDEXTRAItemBase")

local this
local lister
local  notice_timer
local  btn_gameObject
local  notice_prefab

local awd_cfg = {
    40000, 15000, 5000, 2200, 2200,
    2200, 1200, 1200, 1200, 1200,
    600, 600, 600, 600, 600,
    300, 300, 300, 300, 300
}

local extra_awd_cfg = {
    60000, 15000, 5000, 800, 800,
    800, 800, 800, 800, 800,
    400, 400, 400, 400, 400, 
    200, 200, 200, 200, 200
}

local extra_condition = {
    150000,90000,45000,22000,22000,
    22000,14600,14600,14600,14600,
    8800,8800,8800,8800,8800,
    4500,4500,4500,4500,4500
}

local HGList = {
    [1] = "localpop_icon_1",
    [2] = "localpop_icon_2",
    [3] = "localpop_icon_3",
}

local location_show =
{
    "game_Eliminate",
    "game_EliminateSH",
    "game_EliminateCS",
    "game_EliminateXY",
}

local user_data = {}
local rank_data = {}
local _rank_type = "cjj_xxlzb_rank"

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time 
    local s_time 
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end 

    -- 对应权限的key
    local _permission_key = "actp_cjj_gej_exchange"
    if _permission_key then
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end

-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)

    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Act_045_XXLBDPanel.Create(parm.parent, parm.backcall)
        end
        --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_rank_base_info_response"] = this.query_rank_base_info_response
    lister["query_rank_data_response"] = this.query_rank_data_response

    lister["year_btn_created"] = this.on_year_btn_created
    lister["EnterScene"] = this.On_EnterScene
end

function M.Init()
    M.Exit()

    this = Act_045_XXLBDManger
    this.m_data = {}
    this.m_data.mydata = {}

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
    M.GetBaseDataFromNet()
    M.GetRankDataFromNet()
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
    end
end
function M.OnReConnecteServerSucceed()

end

function M.GetData()
end

function M.InitRankData(_data)
    rank_data = {}
    if table_is_null(_data.rank_data) then
        return
    end
    for i = 1, #_data.rank_data do
        local lis_prop = {}

        --dump(_data.rank_data,"_data.rank_dataaaaa")
        lis_prop["name"] = _data.rank_data[i].name or ""
        --lis_prop["ranking_num"] = _data.rank_data[i].rank
        if _data.rank_data[i].rank then
            lis_prop["ranking_num"] = _data.rank_data[i].rank
        else
            lis_prop["ranking_num"] = -1
        end

        lis_prop["rank_mult"] = _data.rank_data[i].score
        lis_prop["rank_award"] = awd_cfg[_data.rank_data[i].rank]
        lis_prop["rank_extra_award"] = extra_awd_cfg[_data.rank_data[i].rank]
        lis_prop["player_id"]=_data.rank_data[i].player_id
        if tonumber(_data.rank_data[i].score) and extra_condition[_data.rank_data[i].rank] then
            lis_prop["is_can"] = tonumber(_data.rank_data[i].score) >= extra_condition[_data.rank_data[i].rank]*10000
        else
            lis_prop["is_can"] = false
        end
        local json_data = json2lua(_data.rank_data[i].other_data)
        if json_data then
            lis_prop["rank_game"] = json_data.source_type
        end
        rank_data[i] = lis_prop
        lis_prop = {}
    end
end

---name:名字，ranking_num：排名，rank_game：所属游戏
---rank_mult：倍数，rank_award：奖励
function M.InitUserData(_data)
    user_data["name"] = MainModel.UserInfo.name
    if _data.rank then
        user_data["ranking_num"] = _data.rank
    else
        user_data["ranking_num"] = -1
    end
    --user_data["ranking_num"] = _data.rank
    local json_data = json2lua(_data.other_data)
    if json_data then
        user_data["rank_game"] = json_data.source_type
    end
    user_data["rank_mult"] = _data.score
    user_data["rank_award"] = awd_cfg[_data.rank]
    user_data["rank_extra_award"] = extra_awd_cfg[_data.rank]
    if tonumber(_data.score) and extra_condition[_data.rank] then
        user_data["is_can"] = tonumber(_data.score) >= extra_condition[_data.rank]*10000
    else
        user_data["is_can"] = false
    end
end


function M.GetBaseDataFromNet()
    Network.SendRequest("query_rank_base_info", { rank_type = _rank_type })
end

function M.GetRankDataFromNet()
    --第1页
    Network.SendRequest("query_rank_data", { page_index = 1, rank_type = _rank_type })
end

function M.GetRankData()
    return rank_data
end

function M.GetUserRankData()
    return user_data
end

function M.GetHGList(hg_num)
    return HGList[hg_num]
end

--------------response------------
function M.query_rank_base_info_response(_, data)
    dump(data, "<color=red><size=15>消消乐榜单rank_base_info-----</size></color>")
    if data and data.result == 0 then
        this.m_data.mydata[data.rank_type] = data
        M.InitUserData(data)
        Event.Brocast("act_045_xxlbd_base_info_get",{rank_type = data.rank_type})
    end
end

function M.query_rank_data_response(_, data)
    -- body
    dump(data, "<color=red><size=15>消消乐榜单rank_data-------</size></color>")
    if data and data.result == 0 then
        M.InitRankData(data)
        Event.Brocast("act_045_xxlbd_rank_info_get",{rank_type = data.rank_type})
    end
end

function M.on_year_btn_created(data)
    
end

function M.ShowNoticePrefab()

    if M.GetBestRank() > 20 or M.GetBestRank() < 2 then
        return
    end
    if MainModel.myLocation == "game_Hall"
    or MainModel.myLocation == "game_Eliminate"
    or MainModel.myLocation == "game_EliminateSH"
    or MainModel.myLocation == "game_EliminateCS" then--每次返回大厅时提示一次
        if btn_gameObject and IsEquals(btn_gameObject) and IsEquals(notice_prefab) then
            notice_prefab.gameObject:SetActive(true)
            Timer.New(
            function()
                if IsEquals(notice_prefab) then
                    notice_prefab.gameObject:SetActive(false)
                end
            end
            , 4, 1):Start()
        end
    end
    if MainModel.myLocation == "game_Hall"
    or MainModel.myLocation == "game_Eliminate"
    or MainModel.myLocation == "game_EliminateSH"
    or MainModel.myLocation == "game_EliminateCS" then
        M.StopNoticeTime()
        if btn_gameObject and IsEquals(btn_gameObject) and IsEquals(notice_prefab) then
            local time_index = 0
            local space = 60
            local show_time = 4
            notice_timer = Timer.New(
            function()
                if IsEquals(notice_prefab) then
                    time_index = time_index + 1
                    if time_index == space then
                        notice_prefab.gameObject:SetActive(true)
                    end
                    if time_index == show_time + space then
                        notice_prefab.gameObject:SetActive(false)
                        time_index = 0
                    end
                end
            end
            , 1, -1)
            notice_timer:Start()
        end
    end

end
function M.StopNoticeTime()
    if notice_timer then
        notice_timer:Stop()
        notice_timer=nil
    end
end

function M.GetBestRank()
    local best_rank = 100000
    for k,v in pairs(this.m_data.mydata) do
        if v.rank > 0 and v.rank < best_rank then
            best_rank = v.rank
        end
    end
    return best_rank
end

function M.IsPlatformOfWZQ()
    local _permission_key = "acatp_buy_gift_bag_class_044_qflb_gswzq"
    local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

function M.On_EnterScene()
    if M.IsActive() and M.IsShowLocation() and M.GetBestRank() <= 20  then
        GameButtonManager.GotoUI({gotoui = "by3d_phb", goto_scene_parm = "panel"})
    end
end

function M.IsShowLocation()
    local _myLocation = MainModel.myLocation
    for i = 1, #location_show do
        if _myLocation == location_show[i] then
            return true
        end
    end
    return false
end

function M.GetCurExtraAwardConfig()
    return extra_awd_cfg
end

function M.GerCurExtraAward(index)
    return extra_awd_cfg[index]
end

function M.GetCurExtraCondition(index)
    return extra_condition[index]
end