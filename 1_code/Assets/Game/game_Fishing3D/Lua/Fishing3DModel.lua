-- 创建时间:2019-03-06
local basefunc = require "Game/Common/basefunc"
require "Game.game_Fishing3D.Lua.Fishing3DConfig"

FishingModel = {}
FishingModel.isDebug = false
FishingModel.isPrintFrame = false

FishingModel.IsEDITOR = AppDefine.IsEDITOR()

-- 是否补间
FishingModel.isBJ = false
-- 切换AI
FishingModel.isChangeAI = false

FishingModel.is3D = true
FishingModel.maxPlayerNumber = 4
FishingModel.game_type = {
    nor = "nor_fishing_nor",
}

FishingModel.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

FishingModel.Status = {
}

FishingModel.Defines = {
    FrameTime = 0.033,
    WorldDimensionUnit={xMin=-9.6, xMax=9.6, yMin=-5.4, yMax=5.4},

    BulledSpeed = 20, -- 子弹运动速度
    bullet_num_limit = 10, -- 每个玩家同屏最多的子弹数
    nor_bullet_cooldown = 0.15, -- 子弹发射频率
    auto_bullet_speed = {1,1,1,1}, -- 自动开抢的子弹发射频率
}

FishingModel.TimeSkill = {
    [1] = {type="frozen", tool_type = "prop_3d_fish_frozen"}, -- 冰冻
    [2] = {type="lock", tool_type = "prop_3d_fish_lock"}, -- 锁定
    [3] = {type="accelerate", tool_type = "prop_3d_fish_accelerate"}, -- 快射
    [4] = {type="wild", tool_type = "prop_3d_fish_wild"}, -- 命中
    [5] = {type="doubled", tool_type = "prop_3d_fish_doubled"}, -- 加倍
}
FishingModel.TimeSkillMap = {
    frozen = FishingModel.TimeSkill[1],
    lock = FishingModel.TimeSkill[2],
    accelerate = FishingModel.TimeSkill[3],
    wild = FishingModel.TimeSkill[4],
    doubled = FishingModel.TimeSkill[5],
}

FishingModel.BulletType = {
    free_bullet = 1,
    power_bullet = 2,
    crit_bullet = 3,
    quick_shoot = 4,
    drill_bullet = 5,
    pierce_bullet = 6,
    time_free_power_bullet = 7,
    power2_bullet = 8,
    power3_bullet = 9,
    crit2_bullet = 10,

    skill_power_bullet = 11, -- 技能火力
    skill_crit_bullet = 12,  -- 技能双倍
}

-- 断线重连中
FishingModel.IsRecoverRet = false
-- 资源加载中
FishingModel.IsLoadRes = false

local this
local lister
local ext_lister
local m_data
local update
local updateDt = 0.1
local update_frame_msg
local send_all_msg
-- 待同步的操作列表：发射子弹，碰撞
local cache_oper_list = {shoot={},boom={},skill={},fish_explode={}, activity = {}}

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    lister["fsg_3d_all_info_test_response"] = this.on_fsg_all_info_test_response
    lister["fsg_3d_join_msg"] = this.on_fsg_join_msg
    lister["fsg_3d_leave_msg"] = this.on_fsg_leave_msg
    lister["fish_out_pool"] = this.on_fish_out_pool
    lister["fish_move_finish"] = this.on_fish_move_finish

    ext_lister = {}
    ext_lister["AssetChange"] = this.OnAssetChange
    -- 等级解锁炮台
    ext_lister["by3d_level_lock_rate_init"] = this.on_by3d_level_lock_rate_init
    ext_lister["by3d_level_lock_rate_change"] = this.on_by3d_level_lock_rate_change
end

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
        return
    end
    if proto_name ~= "fish_out_pool" then
        --临时限制   一般在断线重连时生效  由logic控制
        if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
            if proto_name ~= "fish_move_finish" then
                print("<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXX proto_name = " .. proto_name .."</color>")
                dump(data, "<color=red>MsgDispatch </color>")
            end
            return
        end
    end
    func(proto_name, data)
end

--注册斗地主正常逻辑的消息事件
function FishingModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
    for proto_name, fun in pairs(ext_lister) do
        Event.AddListener(proto_name, fun)
    end
end

--删除斗地主正常逻辑的消息事件
function FishingModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
    for proto_name, fun in pairs(ext_lister) do
        Event.RemoveListener(proto_name, fun)
    end
end

function FishingModel.OnAssetChange(data)
    if not m_data or not m_data.seat_num then
        return
    end
    local isUp = false
    if data.change_type and string.len(data.change_type) > 12 then
        local kk = string.sub(data.change_type, 1, 12)
        if kk ~= "fish_3d_game" then
            isUp = true
        end
    else
        isUp = true
    end

    local b = false
    for k,v in ipairs(data.data) do
        if m_data.players_info then
            if v.asset_type == "jing_bi" and isUp then
                b = true
                m_data.players_info[m_data.seat_num].base.score = m_data.players_info[m_data.seat_num].base.score + v.value
            end
            if v.asset_type == "fish_coin" then
                b = true
                m_data.players_info[m_data.seat_num].base.fish_coin = (m_data.players_info[m_data.seat_num].base.fish_coin or 0) + v.value
            end
            for k1,v1 in ipairs(FishingModel.TimeSkill) do
                if v1.tool_type == v.asset_type then                    
                    b = true
                    m_data.players_info[m_data.seat_num]["prop_fish_" .. v1.type] = (m_data.players_info[m_data.seat_num]["prop_fish_" .. v1.type] or 0) + v.value
                    break
                end
            end
        end
    end
    if m_data.seat_num and b then
        Event.Brocast("model_player_money_msg",{change_type = data.change_type,seat_num = m_data.seat_num})
    end
end
function FishingModel.Update()
end

local function InitMatchData(gameID)
    if not FishingModel.baseData then
        FishingModel.baseData = {}
    end
    FishingModel.data = {
        --游戏名
        name = nil,
        --fg_room_info****
        --房间数据信息
        room_id = nil, --当前房间ID
        table_num = nil, --当前房间中桌子位置
        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0,
        --我的座位号
        seat_num = nil,

        scene_frozen_cd = 0,
        scene_frozen_state = "nor",
        use_frozen_seat_num = nil,
    }
    m_data = FishingModel.data
end

local function InitMatchStatusData(status)
    m_data.status = status
end

function FishingModel.Init()
    InitMatchData()
    this = FishingModel
    this.InitUIConfig()

    -- 本地存储的我的枪炮索引
    FishingModel.my_gun_cur_index = nil

    MakeLister()
    this.AddMsgListener()

    FishingActivityManager.Init()
    FishingPlayerAIManager.Init()

    update = Timer.New(FishingModel.Update, 1, -1, true)
    update:Start()

    FishingModel.InitGameData()
    FishingModel.InitLocalFrameID()

    update_frame_msg = Timer.New(FishingModel.SendFrameMsgToServer, 0.1, -1, false, true)

    return this
end

local function GetInitPlayer()
    local D = {}
    D.base = nil
    D.wait_add_score = 0
    D.last_wait_add_score_time = 0
    D.wait_dec_score = 0

    for k,v in ipairs(FishingModel.TimeSkill) do
        D[v.type .. "_cd"] = 0
        D[v.type .. "_max_cd"] = 1
        D[v.type .. "_state"] = "nor" -- nor 可使用 inuse使用中 cooling CD中
        D["prop_fish_" .. v.type] = 0
    end

    D.lock_fish_id = -1-- 锁定鱼的ID
    D.old_lock_fish_id = -1-- 锁定鱼的ID
    D.use_laser_state = "nor"
    D.laser_rate = 0
    D.use_missile_state = "nor"
    D.missile_list = {0, 0, 0, 0}
    D.missile_index = 0
    D.is_auto = false
    D.auto_index = 1
    D.index = 1
    return D
end
function FishingModel.InitGameData()
    m_data.players_info = {}
    for i=1, 4 do
        m_data.players_info[i] = GetInitPlayer()
    end
    m_data.scene_frozen_state = "nor"
end

function FishingModel.Exit()
    if this then
        FishingActivityManager.Exit()
        FishingPlayerAIManager.Exit()
        FishingModel.RemoveMsgListener()
        update:Stop()
        update = nil
        if update_frame_msg then
            update_frame_msg:Stop()
        end
        update_frame_msg = nil
        if send_all_msg then
            send_all_msg:Stop()
        end
        send_all_msg = nil

        this = nil
        lister = nil
        ext_lister = nil
        m_data = nil
        FishingModel.data = nil
        FishingModel.SaveMoneyLog()
        FishingModel.SaveFrameLog()
    end
end

function FishingModel.InitUIConfig()
    this.Config = {}
    local cc = Fishing3DConfig.InitUIConfig()
    for k,v in pairs(cc) do
        this.Config[k] = v
    end

    if this.Config.fish_parm_map then
        if this.Config.fish_parm_map.nor_bullet_speed and this.Config.fish_parm_map.nor_bullet_speed ~= 0 then
            FishingModel.Defines.nor_bullet_cooldown = 1 / this.Config.fish_parm_map.nor_bullet_speed
        end
        if this.Config.fish_parm_map.auto_bullet_speed then
            FishingModel.Defines.auto_bullet_speed = this.Config.fish_parm_map.auto_bullet_speed
        end
        if this.Config.fish_parm_map.bullet_num_limit then
            FishingModel.Defines.bullet_num_limit = this.Config.fish_parm_map.bullet_num_limit
        end
        if this.Config.fish_parm_map.bullet_move_speed then
            FishingModel.Defines.BulledSpeed = this.Config.fish_parm_map.bullet_move_speed
        end
    end
end

function FishingModel.ReloadFishCacheConfig()
	Fishing3DConfig.ReloadFishCacheConfig(FishingModel.game_id)
end

-- 跳转的捕鱼场ID
--is_ignore_entrance_restrictions是否无视入场限制
-- 这里不需要场景切换
function FishingModel.GotoFishingByID(id,is_ignore_entrance_restrictions)
    if id == FishingModel.game_id then
        return
    end
    -- 排名赛屏蔽跳转
    if FishingModel.data.is_close_goto then
        LittleTips.Create("积分赛中不可前往其他场景，请先完成比赛！")
        return
    end

    local can_sign = GameFishing3DManager.CheckCanBeginGameIDByGold(id)
    if not is_ignore_entrance_restrictions and can_sign ~= 0 then
        FishingLogic.quit_game()
        return
    end


    FishingModel.my_gun_cur_index = nil
    FishingLogic.is_quit = true
    FishingModel.IsRecoverRet = true
    DOTweenManager.KillAllStopTween()
    InitMatchData()
    FishingModel.InitGameData()
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    FishingLogic.GetPanel():ResetUI()
    FishingPlayerAIManager.InitAI()
    FishingActivityManager.fish_activity_exit_all()

    Network.SendRequest("fsg_3d_force_change_fishery", {target_fishery = id}, "发送请求", function (data)
        if data.result == 0 then
            FishingModel.SendAllInfo()
            MainModel.UserInfo.xsyd_status = -1
            Network.SendRequest("set_xsyd_status", {status = -1, xsyd_type="xsyd"})
        else
            FishingModel.IsRecoverRet = false
            HintPanel.ErrorMsg(data.result)
        end
    end)
end
-- 掉帧重连
function FishingModel.Reconnection()
    FishingModel.InitLocalFrameID()
    FishingLogic.is_quit = true
    FishingModel.IsRecoverRet = true
    DOTweenManager.KillAllStopTween()
    InitMatchData()
    FishingModel.InitGameData()
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    FishingLogic.GetPanel():ResetUI()
    FishingPlayerAIManager.InitAI()
    FishingActivityManager.fish_activity_exit_all()

    FishingModel.SendAllInfo()
end

function FishingModel.StopUpdateFrame()
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    update_frame_msg = nil

end

-- 返回自己的座位号
function FishingModel.GetPlayerSeat()
    if m_data.seat_num then
        return m_data.seat_num
    else
        return 1
    end
end

-- 返回自己的数据
function FishingModel.GetPlayerData()
    if m_data then
        return m_data.players_info[m_data.seat_num]
    end
end

-- 返回自己的UI位置
function FishingModel.GetPlayerUIPos()
    return FishingModel.GetSeatnoToPos(m_data.seat_num)
end

-- 根据座位号获取玩家UI位置
function FishingModel.GetSeatnoToPos(seatno)
    if FishingModel.IsRotationPlayer() then
        return FishingModel.maxPlayerNumber - seatno + 1
    end
    return seatno
end

-- 根据UI位置获取玩家座位号
function FishingModel.GetPosToSeatno(uiPos)
    if FishingModel.IsRotationPlayer() then
        return FishingModel.maxPlayerNumber - uiPos + 1
    end
    return uiPos
end

-- 根据UI位置获取玩家数据
function FishingModel.GetPosToPlayer(uiPos)
    local seatno = FishingModel.GetPosToSeatno(uiPos)
    return m_data.players_info[seatno]
end
-- 根据座位号获取玩家数据
function FishingModel.GetSeatnoToUser(seatno)
    return m_data.players_info[seatno]
end
-- 根据ID获取玩家数据
function FishingModel.GetIDToUser(id)
    for k,v in ipairs(m_data.players_info) do
        if v.base and v.base.id == id then
            return v
        end
    end
end

-- 根据ID获取玩家座位
function FishingModel.GetIDToSeatno(id)
    for k,v in ipairs(m_data.players_info) do
        if v.base and v.base.id == id then
            return k
        end
    end
end

-- 是否旋转玩家 为以后联机准备
function FishingModel.IsRotationPlayer()
    if FishingModel.GetPlayerSeat() > 2 then
        return true
    end
    return false
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function FishingModel.GetAnimChatShowPos(id)
    if m_data and m_data.players_info then
        for k, v in ipairs(m_data.players_info) do
            if v.id == id then
                local uiPos = FishingModel.GetSeatnoToPos(v.seat_num)
                if FishingModel.data.dizhu and FishingModel.data.dizhu > 0 then
                    return uiPos, true
                else
                    return uiPos, false
                end
            end
        end
    end

    dump(id, "<color=red>发送者ID</color>")
    dump(m_data.players_info, "<color=red>玩家列表</color>")
    return 1, false
end

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 服务器消息 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 玩家进入
function FishingModel.on_fsg_join_msg(_, data)
    dump(data, "<color=red>on_fsg_join_msg >>>>>>>>>>>>>>>>>>>> </color>")
    m_data.players_info = m_data.players_info or {}
    data.player_info.score = tonumber(data.player_info.score)
    m_data.players_info[data.player_info.seat_num].base = data.player_info
    m_data.players_info[data.player_info.seat_num].base.fish_coin = data.player_info.fish_coin or 0
    if m_data.barbette_id then
        m_data.players_info[data.player_info.seat_num].index = m_data.barbette_id[1]
    else
        m_data.players_info[data.player_info.seat_num].index = 1
    end
    Event.Brocast("model_fsg_join_msg_sub_sys", data.player_info.seat_num)
    Event.Brocast("model_fsg_join_msg", data.player_info.seat_num)
end
-- 玩家离开
function FishingModel.on_fsg_leave_msg(_, data)
    dump(data, "<color=red>on_fsg_leave_msg >>>>>>>>>>>>>>>>>>>> </color>")
    m_data.players_info[data.seat_num] = GetInitPlayer()
    Event.Brocast("model_fsg_leave_msg_sub_sys", data.seat_num)
    Event.Brocast("model_fsg_leave_msg", data.seat_num)

    BulletManager.RemoveBulletBySeatno(data.seat_num)
end
function FishingModel.GetLockFishID(seat_num)
    if m_data.players_info[seat_num] then
        if m_data.players_info[seat_num].lock_fish_id < 0 and m_data.players_info[seat_num].old_lock_fish_id > 0 then
            m_data.players_info[seat_num].lock_fish_id = m_data.players_info[seat_num].old_lock_fish_id
            m_data.players_info[seat_num].old_lock_fish_id = -1
        end
        local fish = FishManager.GetFishByID(m_data.players_info[seat_num].lock_fish_id)
        if not fish or fish:CheckIsOutPool_Whole() then
            FishingModel.RemoveLockFishID(seat_num)
            fish = FishManager.GetMaxScorePoolFish(seat_num)
            if fish and fish.data and fish.data.fish_id then
                m_data.players_info[seat_num].lock_fish_id = fish.data.fish_id
            end
        end
        return m_data.players_info[seat_num].lock_fish_id
    end
    return -1
end
function FishingModel.SetLockFishID(seat_num, fish_id)
    m_data.players_info[seat_num].lock_fish_id = fish_id
    m_data.players_info[seat_num].old_lock_fish_id = fish_id
end
function FishingModel.RemoveLockFishID(seat_num)
    if m_data.players_info[seat_num].lock_fish_id > 0 then
        m_data.players_info[seat_num].old_lock_fish_id = m_data.players_info[seat_num].lock_fish_id
    end
    m_data.players_info[seat_num].lock_fish_id = -1
end

local fish_out_pool = {}
-- 鱼游动完成
function FishingModel.on_fish_move_finish(_, fish_id)
    fish_out_pool[fish_id] = fish_id
    for i=1, 4 do
        if m_data.players_info[i].lock_fish_id and m_data.players_info[i].lock_fish_id == fish_id then
            m_data.players_info[i].lock_fish_id = -1
        end
    end
    if m_data.small_boss_map and m_data.small_boss_map[fish_id] then
        m_data.small_boss_map[fish_id] = nil
        FishingAnimManager.PlayBossFenwei("small", nil, nil, true)
    end
end
-- 鱼游出屏幕
function FishingModel.on_fish_out_pool(_, fish_id)
    for i=1, 4 do
        if m_data.players_info[i].lock_fish_id and m_data.players_info[i].lock_fish_id == fish_id then
            m_data.players_info[i].lock_fish_id = -1
        end
    end
    if m_data.small_boss_map and m_data.small_boss_map[fish_id] then
        m_data.small_boss_map[fish_id] = nil
        FishingAnimManager.PlayBossFenwei("small", nil, nil, true)
    end
end
-- 获取游出去的鱼
-- 最多20条 防止数据过大
function FishingModel.GetOutPoolFish()
    local list = {}
    for k,v in pairs(fish_out_pool) do
        list[#list + 1] = v
        fish_out_pool[k] = nil
        -- if #list > 20 then
        --     break
        -- end
    end
    return list
end

function FishingModel.SetUpdateFrame(b)
    if update_frame_msg then
    if b then
        update_frame_msg:Start()
    else
        update_frame_msg:Stop()
        end
    end
end
function FishingModel.SendAllInfo()
    FishingLogic.is_quit = false
    FishingModel.IsRecoverRet = true
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    Network.SendRequest("fsg_3d_all_info_test", nil, "")
end
-- 断线重连数据 all_info
function FishingModel.on_fsg_all_info_test_response(_, data)
    cache_oper_list = {shoot={},boom={},skill={},fish_explode={}, activity = {}}

    VehicleManager.RemoveAll()
    FishManager.RemoveAll()
    BulletManager.RemoveAll()
    FishingModel.BrocastActivityExitAll()

    dump(data, "<color=red>all_info</color>",1000000)

    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result, function ()
            DOTweenManager.KillAllStopTween()
            DOTweenManager.KillAllExitTween()
            DOTweenManager.CloseAllSequence()
            FishingLogic.is_quiting = true
            FishingUninstallPanel.Create(function()
                if not call then
                    FishingLogic.change_panel("hall")
                else
                    call()
                end
                Event.Brocast("quit_game_success")
            end, "by3d")
        end)
        return
    end
    dump(data.nor_fishing_status_info.frozen_time_data, "<color=red>all_info frozen_time_data</color>")

    FishingModel.game_id = data.room_info.game_id
    m_data.game_id = data.room_info.game_id
    m_data.t_num = data.room_info.t_num
    m_data.seat_num = data.seat_num
    m_data.begin_time = tonumber(data.nor_fishing_status_info.begin_time)
    m_data.end_time = tonumber(data.nor_fishing_status_info.end_time)
    m_data.system_time = tonumber(data.nor_fishing_status_info.fishery_data.time)
    m_data.first_system_time = tonumber(data.nor_fishing_status_info.fishery_data.first_time)
    m_data.image_type_index = data.nor_fishing_status_info.image_type_index
    if data.nor_fishing_status_info.barbette_id then
        m_data.barbette_id = {}
        local s = data.nor_fishing_status_info.barbette_id
        for k = s[1], s[2] do
            m_data.barbette_id[#m_data.barbette_id + 1] = k
        end
    end

        -- 初始化枪炮皮肤id
    m_data.gun_skin_map = {}
    local a,b = GameButtonManager.RunFun({gotoui="sys_by_bag"}, "GetData")
    if a and b then
        FishingModel.SetGunSkinID(m_data.seat_num, b.barrel_id)
        FishingModel.SetBedSkinID(m_data.seat_num, b.bed_id)
    else
        FishingModel.SetGunSkinID(m_data.seat_num, 1)
        FishingModel.SetBedSkinID(m_data.seat_num, 1)
    end

    dump(data.nor_fishing_status_info.skill_cfg, "<color=red>|||||||||||| ser skill_cfg </color>")
    for k,v in ipairs(data.nor_fishing_status_info.skill_cfg) do
        FishingModel.Defines[v.skill .. "CD"] = v.cd_time
        FishingModel.Defines[v.skill .. "Indate"] = v.time
    end

    m_data.fish_map_id = data.nor_fishing_status_info.fish_map_id
    m_data.players_info = {}
    for i=1, 4 do
        m_data.players_info[i] = GetInitPlayer()
    end

    dump(FishingModel.my_gun_cur_index, "<color=red>FishingModel.my_gun_cur_index</color>")
    dump(data.players_info, "<color=red>data.players_info</color>")
    for k,v in ipairs(data.players_info) do
        v.score = tonumber(v.score)
        m_data.players_info[v.seat_num].base = v
        m_data.players_info[v.seat_num].base.fish_coin = v.fish_coin or 0
        if v.seat_num == 1 and FishingModel.my_gun_cur_index and 
            FishingModel.my_gun_cur_index >= m_data.barbette_id[1] and
            FishingModel.my_gun_cur_index <= m_data.barbette_id[#m_data.barbette_id] then
            m_data.players_info[v.seat_num].index = FishingModel.my_gun_cur_index
        else
            m_data.players_info[v.seat_num].index = m_data.barbette_id[1]
        end

        if v.seat_num ~= m_data.seat_num then
            Event.Brocast("ai_fsg_join_msg", v.seat_num)
            Event.Brocast("model_fsg_join_msg_sub_sys", v.seat_num)
        else
            for k1, v1 in ipairs(FishingModel.TimeSkill) do
                m_data.players_info[v.seat_num]["prop_fish_" .. v1.type] = MainModel.UserInfo[v1.tool_type] or 0
            end
        end
    end

    if data.nor_fishing_status_info.fishery_data.activity and next(data.nor_fishing_status_info.fishery_data.activity) then
        dump(data.nor_fishing_status_info.fishery_data.activity, "<color=red>Edata.nor_fishing_status_info.fishery_data.activity</color>")
        for k,v in ipairs(data.nor_fishing_status_info.fishery_data.activity) do
            if v.seat_num then
                m_data.players_info[v.seat_num].index = v.bullet_index
            end
        end
    end
    m_data.scene_frozen_cd = 0
    m_data.scene_frozen_state = "nor"
    m_data.use_frozen_seat_num = nil
    if data.nor_fishing_status_info.skill_status then
        for k,v in ipairs(data.nor_fishing_status_info.skill_status) do
            if FishingModel.TimeSkillMap[v.skill] and v.time then
                if v.time > FishingModel.Defines[v.skill .. "CD"] then
                    m_data.players_info[v.seat_num][v.skill .. "_cd"] = v.time - FishingModel.Defines[v.skill .. "CD"]
                    m_data.players_info[v.seat_num][v.skill .. "_max_cd"] = FishingModel.Defines[v.skill .. "Indate"]
                    m_data.players_info[v.seat_num][v.skill .. "_state"] = "inuse"
                else
                    m_data.players_info[v.seat_num][v.skill .. "_cd"] = v.time
                    m_data.players_info[v.seat_num][v.skill .. "_max_cd"] = FishingModel.Defines[v.skill .. "CD"]
                    m_data.players_info[v.seat_num][v.skill .. "_state"] = "cooling"
                end

                -- 特殊处理
                if v.skill == "frozen" then
                    if v.time > FishingModel.Defines.frozenCD then
                        m_data.scene_frozen_state = "inuse"
                        m_data.use_frozen_seat_num = v.seat_num
                        m_data.scene_frozen_cd = m_data.players_info[v.seat_num].frozen_cd
                    else
                        m_data.scene_frozen_cd = 0
                    end
                else
                    dump(v, "<color=red>冰冻技能</color>")
                end
            else
                if v.skill == "summon" then
                elseif v.skill == "laser" then
                    m_data.players_info[v.seat_num].laser_rate = v.time or 0
                elseif v.skill == "missile" then
                    local num = v.time or 0
                    for i=1, 4 do
                        m_data.players_info[v.seat_num].missile_list[i] = num % 10
                        num = math.floor(num / 10)
                        if m_data.players_info[v.seat_num].missile_list[i] > 0 then
                            m_data.players_info[v.seat_num].missile_index = i
                        end
                    end
                else
                    dump(v, "<color=red>not skill type</color>")
                end
            end
        end
    end

    m_data.frozen_time_data = data.nor_fishing_status_info.frozen_time_data
    -- local fishery_data = fish_lib.frame_data_unpack(data.fishery_data)
    FishingModel.lock_frame = nil
    Event.Brocast("model_refresh_player")
    
    FishingModel.S2CFrameMessage(data.nor_fishing_status_info.fishery_data)
    FishingModel.IsRecoverRet = false
    Event.Brocast("model_recover_finish")
    Event.Brocast("model_ready_finish_msg")

    --取消限制消息
    m_data.limitDealMsg = nil

    if update_frame_msg then
        update_frame_msg:Start()
    end
    FishingModel.PlaySceneBGM()
end

function FishingModel.PlaySceneBGM()
    -- 场景背景音乐
    if not m_data.game_id or m_data.game_id == 1 then
        ExtendSoundManager.PlaySceneBGM(audio_config.by3d.bgm_by_game.audio_name)
    else
        ExtendSoundManager.PlaySceneBGM(audio_config.by3d.bgm_by_2345chang.audio_name)
    end
end

function FishingModel.InitLocalFrameID()
    FishingModel.local_frame_id_left = 1
    FishingModel.local_frame_id_right = 1
end
function FishingModel.GetLocalFrameID()
    local frame_id = FishingModel.local_frame_id_right
    FishingModel.local_frame_id_right = FishingModel.local_frame_id_right + 1
    if FishingModel.local_frame_id_right > 1000000000 then
        FishingModel.local_frame_id_right = 1
    end
    return frame_id
end
function FishingModel.AddLocalFrameID()
    FishingModel.local_frame_id_left = FishingModel.local_frame_id_left + 1
    if FishingModel.local_frame_id_left > 1000000000 then
        FishingModel.local_frame_id_left = 1
    end
end

-- 发送帧数据到服务器
function FishingModel.SendFrameMsgToServer()
    if not FishingModel.IsRecoverRet then
        if FishingModel.lock_frame then
            --dump(FishingModel.local_frame_id_left, "<color=red>EEEE 当前帧数据返回延迟</color>")
            return
        end
        if cache_oper_list then     
            -- local msg = fish_lib.frame_data_pack({data=cache_oper_list,time=0,activity={}})
            cache_oper_list.time = 0
            cache_oper_list.fish_out_pool = FishingModel.GetOutPoolFish()
            cache_oper_list.frame_id = FishingModel.GetLocalFrameID()
            local msg = cache_oper_list
            cache_oper_list = {shoot={},boom={},skill={},fish_explode={},activity = {}}
            FishingModel.lock_frame = true
            local userdata = FishingModel.GetPlayerData()
            userdata.wait_dec_score = 0
            -- 发送消息到服务器
            Network.SendRequest("nor_fishing_3d_nor_frame_data_test", {data=msg}, function (data)
                if FishingLogic.is_quiting then
                    return
                end
                FishingModel.lock_frame = false
                FishingModel.AddFrameLog(data)
                if m_data and m_data.seat_num then
                    if data.result == 0 then
                        -- local unmsg = fish_lib.frame_data_unpack(data.data)
                        -- m_data.system_time = unmsg.time
                        -- FishingModel.S2CFrameMessage(unmsg)
                        m_data.system_time = tonumber(data.data.time)
                        m_data.end_time = tonumber(data.data.end_time)
                        FishingModel.S2CFrameMessage(data.data)
                    else
                        HintPanel.ErrorMsg(data.result)
                    end
                end
            end)

        end
    end
end
function FishingModel.C2SFrameMessage(data)
    local _data
    local list
    if data.Shoot then
        list = cache_oper_list.shoot or {}
        _data = {}
        _data.seat_num = data.Shoot.seat_num
        _data.index = data.Shoot.index
        _data.id = data.Shoot.id
        _data.x = data.Shoot.x
        _data.y = data.Shoot.y
        _data.rate = data.Shoot.rate
        _data.type = data.Shoot.type
        _data.status = data.Shoot.status
        _data.time = 0
    end

    if data.Boom then
        list = cache_oper_list.boom or {}
        -- 随机打死鱼
        _data = {}
        _data.id = data.Boom.id
        _data.fish_ids  = data.Boom.fish_list
    end

    if data.Skill then
        list = cache_oper_list.skill or {}
        _data = {}
        _data = data.Skill
    end

    if data.BoomHarm then
        list = cache_oper_list.fish_explode or {}
        _data = {}
        _data.id = data.BoomHarm.id
        _data.fish_ids = data.BoomHarm.fish_ids
    end

    if data.Activity then
        list = cache_oper_list.activity or {}
        _data = {}
        _data.activity_id = data.Activity.activity_id
        _data.status = 1
        dump(data.Activity, "<color=blue>活动状态设置</color>")
    end

    if _data and next(_data) then
        list[#list + 1] = _data
    end
end

-- 服务器同步帧
function FishingModel.S2CFrameMessage(data)
    if not m_data or not m_data.seat_num then
        return
    end
    if data.frame_id then
        if FishingModel.local_frame_id_left ~= data.frame_id then
            print("<color=red>同步帧 掉帧错误 EEEEEEEEEEEEE </color>")
            dump(FishingModel.local_frame_id_left, "<color=red>FishingModel.local_frame_id_left</color>")
            dump(FishingModel.local_frame_id_right, "<color=red>FishingModel.local_frame_id_right</color>")
            dump(data.frame_id, "<color=red>data.frame_id</color>")
            FishingModel.Reconnection()
            return
        end
        FishingModel.AddLocalFrameID()
    end

    if data.assets then
        for k1, v1 in ipairs(data.assets) do
            if v1.asset_type == "score" then
                m_data.cache_score = tonumber(v1.value)
            elseif v1.value == "sub_score" then
                m_data.cache_grades = v1.value
            end
        end
    end

    if data.event and #data.event > 0 then
        for k,v in ipairs(data.event) do
            if v.msg_type == "fish_boom" then
                dump(v, "<color=red>AAA fish_boom</color>")
                m_data.fish_map_id = v.value
                m_data.clear_level = v.clear_level
                m_data.begin_time = tonumber(m_data.system_time)
                m_data.image_type_index = v.index
                Event.Brocast("model_fish_wave")
                fish_out_pool = {}
            elseif v.msg_type == "box_fish" then
                Event.Brocast("model_box_fish")
            elseif v.msg_type == "summon_fish" then
                local dd = {}
                dd.use_fish = v.data[1] or 1
                dd.path = v.data[2] or 44
                Event.Brocast("model_event_summon_fish", dd)
            elseif v.msg_type == "special_fish" then
                local dd = {}
                dd.use_fish = v.data[1] or 1
                Event.Brocast("model_event_special_fish", dd)
            elseif v.msg_type == "small_boss" then
                local dd = {}
                dd.use_fish = v.data[1] or 1
                dd.max_rate = v.data[2] or 100
                dd.fish_id = v.data[3]
                m_data.small_boss_map = m_data.small_boss_map or {}
                if dd.fish_id then
                    m_data.small_boss_map[dd.fish_id] = 1
                end
                Event.Brocast("model_event_small_boss", dd)
            elseif v.msg_type == "big_boss" then
                local dd = {}
                dd.use_fish = v.data[1] or 1
                dd.max_rate = v.data[2] or 100
                Event.Brocast("model_event_big_boss", dd)
            elseif v.msg_type == "change_map" then
                dump(v, "<color=red>AAA change_map</color>")
                m_data.fish_map_type = v.type
                m_data.fish_map_no = v.index
                Event.Brocast("model_event_change_map")
            end
        end
    end

    -- dump(data, "<color=green>S2CFrameMessage</color>")
    if data.shoot and #data.shoot > 0 then
        if FishingModel.isDebug then
            if data.frame_id then
                print("<color=red>EEE data.frame_id = " .. data.frame_id .. "</color>")
            end
            dump(data.shoot, "<color=red>S2C 开抢</color>")
        end
        for k,v in ipairs(data.shoot) do
            if m_data.players_info[v.seat_num] and m_data.players_info[v.seat_num].base then
                v.x = v.x / 100
                v.y = v.y / 100
                BulletManager.UpdateBulledID(v)
            end
        end
    end
    if data.boom and #data.boom > 0 then
        -- dump(data.boom, "<color=red>鱼碰撞导致死亡</color>")
        for k,v in ipairs(data.boom) do
            Event.Brocast("model_fish_dead", v)
        end
    end
    if data.fish_group and #data.fish_group > 0 then
        -- dump(data.fish_group, "<color=red>产生一组鱼</color>")
        for k,v in ipairs(data.fish_group) do
            FishManager.AddFishGroup(v)
        end
    end
    if data.fish_team and #data.fish_team > 0 then
        -- dump(data.fish_team, "<color=red>产生敢死队鱼</color>")
        for k,v in ipairs(data.fish_team) do
            FishManager.AddFishTeam(v)
        end
    end
    if data.fish_explode and #data.fish_explode > 0 then
        -- dump(data.fish_explode, "<color=red>特殊鱼死亡效果</color>")
        for k,v in ipairs(data.fish_explode) do
            Event.Brocast("model_fish_explode_dead", v)
        end
    end
    
    if data.skill and #data.skill > 0 then
        Event.Brocast("model_receive_skill_data_msg", data.skill)
    end
    
    local userdata = FishingModel.GetPlayerData()
    if m_data.cache_score and m_data.cache_score ~= (userdata.wait_add_score + userdata.base.score + userdata.wait_dec_score) then
        dump(data, "<color=red>EEE S2CFrameMessage</color>")
        dump(m_data.cache_score, "<color=red>EEE cache_score</color>")
        dump(userdata.wait_add_score, "<color=red>EEE wait_add_score</color>")
        dump(userdata.base.score, "<color=red>EEE score</color>")
        local ss = m_data.cache_score - userdata.wait_add_score - userdata.wait_dec_score
        userdata.base.score = ss
        Event.Brocast("ui_refresh_player_money")
    end
    
    -- 额外数据 FishingModel.BrocastActivity  FishExtManager.RefreshData  顺序不能修改
    FishExtManager.RefreshData(data.ext_data)
    FishingModel.BrocastActivity(data)
end

function FishingModel.BrocastActivity(data)
    if data.activity and next(data.activity) then
        for k,v in ipairs(data.activity) do
            if v.seat_num and m_data.players_info[v.seat_num].base then
                if FishingModel.IsRecoverRet then
                    Event.Brocast("fish_activity_recover", v)
                else
                    Event.Brocast("fish_activity", v)
                end
            end
        end
    end
end

function FishingModel.BrocastActivityExitAll()
    Event.Brocast("fish_activity_exit_all")
end

-- 发送开枪消息
function FishingModel.SendShoot(vec, isPC)
    local userdata = FishingModel.GetSeatnoToUser(vec.seat_num)

    local x = vec.x
    local y = vec.y
    if not vec.id then
        vec.id = BulletManager.GetNextBulletID()
    end

    local sendData = { }
    sendData.Shoot = {}
    sendData.Shoot.id = vec.id
    sendData.Shoot.rate = vec.id
    sendData.Shoot.x = x * 100
    sendData.Shoot.y = y * 100
    sendData.Shoot.type = vec.act_type
    sendData.Shoot.status = vec.status
    sendData.Shoot.seat_num = vec.seat_num
    sendData.Shoot.index = userdata.index
    -- 破产了不创建子弹
    if not isPC then
        -- 自己和机器人发射子弹不用等服务器
        -- 模仿服务器的消息
        local shootData = { }
        shootData.x = x
        shootData.y = y
        shootData.id = vec.id
        shootData.seat_num = vec.seat_num
        shootData.index = userdata.index
        if vec.lock_fish_id then
            shootData.lock_fish_id = vec.lock_fish_id
        end
        shootData.type = vec.act_type
        shootData.status = vec.status
        Event.Brocast("model_shoot", shootData)
        -- 道具活动和子弹活动不能同时使用，优先道具活动因为是限时的
        if not vec.act_type or (vec.act_type ~= FishingModel.BulletType.skill_power_bullet and vec.act_type ~= FishingModel.BulletType.skill_crit_bullet) then
            Event.Brocast("activity_shoot", shootData)
        end
    end
    -- 发送消息给服务器
    FishingModel.C2SFrameMessage(sendData)
end

function FishingModel.SendBulletBoom(data)
    --dump(data,"<color=yellow>++++SendBulletBoom++++data++++++++</color>")
    for k,v in ipairs(data.fish_list) do
        local fish = FishManager.GetFishByID(v)
        if fish then
            fish.data.player_hit_map = fish.data.player_hit_map or {}
            fish.data.player_hit_map[data.seat_num] = fish.data.player_hit_map[data.seat_num] or 0
            fish.data.player_hit_map[data.seat_num] = fish.data.player_hit_map[data.seat_num] + 1
        end
    end
    local _data = {}
    _data.Boom = data
    Event.Brocast("model_bullet_boom", data)
    if data.id > 0 then
        FishingModel.C2SFrameMessage(_data)
    else
        BulletManager.AddSendTriggerFishMap(_data)
    end
end

-- 爆炸鱼的爆炸范围内选几条炸死
-- 发送给服务器验证死亡是否生效
function FishingModel.SendBoomFishHarm(data)
    local _data = {}
    _data.BoomHarm = data
    FishingModel.C2SFrameMessage(_data)
end
-- 更新技能CD
function FishingModel.UpdateSkillCD(time_elapsed)
    for i=1, 4 do
        for k,v in ipairs(FishingModel.TimeSkill) do
            if m_data.players_info[i][v.type .. "_cd"] and m_data.players_info[i][v.type .. "_cd"] > 0 then
                local oldcd = m_data.players_info[i][v.type .. "_cd"]
                m_data.players_info[i][v.type .. "_cd"] = m_data.players_info[i][v.type .. "_cd"] - time_elapsed

                if m_data.players_info[i][v.type .. "_cd"] < 0 then
                    m_data.players_info[i][v.type .. "_cd"] = 0
                    if m_data.players_info[i][v.type .. "_state"] == "inuse" then
                        if FishingModel.Defines[v.type .. "CD"] <= 0 then
                            m_data.players_info[i][v.type .. "_state"] = "nor"
                        else
                            m_data.players_info[i][v.type .. "_state"] = "cooling"
                            m_data.players_info[i][v.type .. "_cd"] = FishingModel.Defines[v.type .. "CD"]
                            m_data.players_info[i][v.type .. "_max_cd"] = FishingModel.Defines[v.type .. "CD"]
                        end
                    else
                        m_data.players_info[i][v.type .. "_state"] = "nor"
                    end

                    if v.type ~= "frozen" then -- 特殊处理 todo
                        Event.Brocast("model_time_skill_change_msg", i, v.type)
                    end
                end
            end
        end
    end

    if m_data.scene_frozen_state == "inuse" then
        local oldcd = m_data.scene_frozen_cd
        m_data.scene_frozen_cd = m_data.scene_frozen_cd - time_elapsed
        if oldcd > 3 and m_data.scene_frozen_cd < 3 then
            Event.Brocast("model_ice_skill_deblocking_msg")
        end
        if m_data.scene_frozen_cd <= 0 then
            m_data.scene_frozen_cd = 0
            m_data.scene_frozen_state = "nor"
            Event.Brocast("model_time_skill_change_msg", m_data.use_frozen_seat_num, "frozen")
            m_data.use_frozen_seat_num = nil
        end
    end
end

function FishingModel.GetLockState(seat_num)
    return m_data.players_info[seat_num].lock_state
end

function FishingModel.GetSceneIceState()
    return m_data.scene_frozen_state
end
-- 激光状态
function FishingModel.SetPlayerLaserState(seat_num, state)
    if m_data.players_info[seat_num] and m_data.players_info[seat_num].base then
        m_data.players_info[seat_num].use_laser_state = state
    end
end
function FishingModel.GetPlayerLaserState(seat_num)
    if m_data.players_info[seat_num] and m_data.players_info[seat_num].base then
        return m_data.players_info[seat_num].use_laser_state
    end
end

-- 核弹状态
function FishingModel.SetPlayerMissileState(seat_num, state)
    if m_data.players_info[seat_num] and m_data.players_info[seat_num].base then
        m_data.players_info[seat_num].use_missile_state = state
    end
end
function FishingModel.GetPlayerMissileState(seat_num)
    if m_data.players_info[seat_num] and m_data.players_info[seat_num].base then
        return m_data.players_info[seat_num].use_missile_state
    end
end

function FishingModel.GetSceneIceTime()
    return m_data.scene_frozen_cd
end

-- 发送技能消息
function FishingModel.SendSkill(data)
    if data.msg_type == "frozen" and m_data.scene_frozen_state == "inuse" then
        print("<color=red>冰冻状态中，无法再次使用冰冻</color>")
        return
    end
    local sendData = {}
    sendData.Skill = {}
    sendData.Skill = data

    -- 发送消息给服务器
    FishingModel.C2SFrameMessage(sendData)        
end

-- 技能能否使用
function FishingModel.CheckIsCanUseSkill(type)
    local userdata = FishingModel.GetPlayerData()
    if type == "prop_3d_fish_lock" then
        if userdata.lock_state == "nor" then
            return true
        else
            return false
        end
    end

    if type == "prop_3d_fish_frozen" then
        if FishingModel.data.scene_frozen_state == "inuse" then
            return false
        end
        if userdata.frozen_state == "nor" then
            return true
        else
            return false
        end
    end

    return false
end
-- 发送技能消息
function FishingModel.UseSkill(type)
    local userdata = FishingModel.GetPlayerData()
    if type == "prop_3d_fish_lock" then
        if userdata.lock_state == "nor" then
            if userdata.base.score >= FishingModel.GetSkillMoney("prop_3d_fish_lock") or userdata.prop_fish_lock > 0  then
                userdata.lock_state = "ready"
                FishingModel.SendSkill({seat_num=FishingModel.GetPlayerSeat(), msg_type="lock"})
                return true
            else
                PayPanel.Create(GOODS_TYPE.jing_bi)
            end
        else
            LittleTips.Create("无法使用")
            return false
        end
    end

    if type == "prop_3d_fish_frozen" then
        if FishingModel.data.scene_frozen_state == "inuse" then
            LittleTips.Create("冰冻状态中,无法使用")
            return false
        end
        local userdata = FishingModel.GetPlayerData()
        if userdata.frozen_state == "nor" then
            if userdata.base.score >= FishingModel.GetSkillMoney("prop_3d_fish_frozen") or userdata.prop_fish_frozen > 0 then
                userdata.frozen_state = "ready"
                FishingModel.SendSkill({seat_num=FishingModel.GetPlayerSeat(), msg_type="frozen"})
                return true
            else
                PayPanel.Create(GOODS_TYPE.jing_bi)
            end
        else
            LittleTips.Create("无法使用")
            return false
        end
    end
end

-- 发送活动消息
function FishingModel.SendActivity(data)
    local sendData = {}
    sendData.Activity = {}
    sendData.Activity = data
    dump(data, "<color=blue>SendActivity</color>")
    -- 发送消息给服务器
    FishingModel.C2SFrameMessage(sendData)        
end

-- 等级与场次 对应解锁的炮台
function FishingModel.on_by3d_level_lock_rate_init(parm)
    m_data.barbette_id = {}
    if parm then
        for i = parm[1], parm[2] do
            m_data.barbette_id[#m_data.barbette_id + 1] = i
        end
        Event.Brocast("model_by_rate_init_wc_msg")
    end
end
function FishingModel.on_by3d_level_lock_rate_change(parm)
    if parm then
        local user = FishingModel.GetPlayerData()
        if not user then
            return
        end
        local auto_up_index
        if parm.index and parm.is_hand and parm.index > user.index then
            auto_up_index = parm.index
        end
        if parm.index and parm.index > m_data.barbette_id[#m_data.barbette_id] then
            for i = m_data.barbette_id[#m_data.barbette_id]+1, parm.index do
                m_data.barbette_id[#m_data.barbette_id + 1] = i
            end
        end
        -- 需要自动升炮
        if false and auto_up_index then -- 屏蔽自动升炮
            -- 不在活动中，才能自动升炮
            if not FishingActivityManager.CheckHaveBullet(user.base.seat_num) then
                user.index = auto_up_index
                Event.Brocast("set_gun_rate", user.base.seat_num)
            end
    
            Event.Brocast("model_by3d_level_up_fx")
        end
    end
end


-- 修改抢倍率
function FishingModel.GetChangeRate(val, cg, seat_num)
    local max_index = GameFishing3DManager.GetCurMaxGunIndex()
    if seat_num == FishingModel.GetPlayerSeat() then
        local gun_cfg = FishingModel.Config.fish_gun_map[m_data.game_id]
        local cgk = val + cg
        if cgk < m_data.barbette_id[1] then
            return m_data.barbette_id[#m_data.barbette_id]
        elseif cgk > m_data.barbette_id[#m_data.barbette_id] then
            if cg == 1 and #m_data.barbette_id < max_index and (cgk-1) == m_data.barbette_id[#m_data.barbette_id] then
                local user = FishingModel.GetPlayerData()
                return m_data.barbette_id[#m_data.barbette_id] + 1
            else
                return m_data.barbette_id[1]
            end
        else
            return cgk
        end
    else
        local cgk = val + cg
        if cgk < 1 then
            return max_index
        elseif cgk > max_index then
            return 1
        else
            return cgk
        end
    end
end

-- 摄像机 用于坐标转化
function FishingModel.SetCamera(camera2d, camera)
    FishingModel.camera2d = camera2d
    FishingModel.camera = camera
end
-- 2D坐标转UI坐标
function FishingModel.Get2DToUIPoint(vec)
    vec = FishingModel.camera2d:WorldToScreenPoint(vec)
    vec = FishingModel.camera:ScreenToWorldPoint(vec)
    return vec
end
-- UI坐标转2D坐标
function FishingModel.GetUITo2DPoint(vec)
    vec = FishingModel.camera:WorldToScreenPoint(vec)
    vec = FishingModel.camera2d:ScreenToWorldPoint(vec)
    return vec
end

function FishingModel.GetFirstSystemTime()
    return m_data.first_system_time
end

function FishingModel.GetBeginTime()
    return m_data.begin_time
end
function FishingModel.GetSystemTime()
    return m_data.system_time
end

-- 基座的皮肤ID
function FishingModel.GetBedSkinID(seat_num)
    if m_data.bed_skin_map and m_data.bed_skin_map[seat_num] then
        return m_data.bed_skin_map[seat_num]
    else
        return 1
    end
end
-- 枪的皮肤ID
function FishingModel.SetGunSkinID(seat_num, skin_id)
    if not m_data.gun_skin_map then
        m_data.gun_skin_map = {}
    end
    m_data.gun_skin_map[seat_num] = skin_id

    Event.Brocast("model_gun_info_change", seat_num)
end
-- 基座的皮肤ID
function FishingModel.SetBedSkinID(seat_num, skin_id)
    if not m_data.bed_skin_map then
        m_data.bed_skin_map = {}
    end
    m_data.bed_skin_map[seat_num] = skin_id

    Event.Brocast("model_gun_info_change", seat_num)
end

-- 枪的基座皮肤配置
function FishingModel.GetBedSkinCfg(seat_num, index)
    local skin_id = FishingModel.GetBedSkinID(seat_num)
    return FishingModel.Config.gun_bed_style_map[skin_id]
end

-- 枪的皮肤ID
function FishingModel.GetGunSkinID(seat_num)
    if m_data.gun_skin_map and m_data.gun_skin_map[seat_num] then
        return m_data.gun_skin_map[seat_num]
    else
        return 1
    end
end
-- 枪的皮肤配置
function FishingModel.GetGunSkinCfg(seat_num, index)
    local skin_id = FishingModel.GetGunSkinID(seat_num)
    return FishingModel.Config.gun_style_map[seat_num][skin_id][index]
end

function FishingModel.GetGunSkinPower(seat_num, index)
    local skin_id = FishingModel.GetGunSkinID(seat_num)
    local rate = FishingModel.GetGunCfg(index).gun_rate
    if FishingModel.Config.gun_power_map[skin_id] and FishingModel.Config.gun_power_map[skin_id][rate] then
        return FishingModel.Config.gun_power_map[skin_id][rate].power_max_rate
    else
        print("<color=red>EEEEEE</color>")
        dump(FishingModel.Config.gun_power_map)
        dump(skin_id)
        dump(rate)
    end
end

function FishingModel.GetGunCfg(index)
    return FishingModel.Config.fish_gun_map[m_data.game_id][index]
end

function FishingModel.GetGunCfgByPlayer(user)
    local index = user.index
    return FishingModel.GetGunCfg(index)
end
function FishingModel.GetMinGunCfg()
    return FishingModel.Config.fish_gun_map[m_data.game_id][1]
end
function FishingModel.GetMinGunIndex()
    return m_data.barbette_id[1]
end
function FishingModel.GetGunIdToIndex(id)
    for k,v in ipairs(m_data.barbette_id) do
        if v == id then
            return k
        end
    end
    return 1
end

local debug_log = false
FishingModel.money_log = ""
FishingModel.frame_log_list = {}
function FishingModel.AddMoneyLog(seat_num, log)
    if debug_log then
        FishingModel.money_log = FishingModel.money_log .. "\n" .. "seat_num=" .. seat_num .. " " ..log
    end
end
-- 钱不同步
function FishingModel.SaveMoneyLog()
    if debug_log then
        local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id .. "/fish_money_log.txt"
        print("<color=red>钱同步路径 path = " .. path .. "</color>")
        File.WriteAllText(path, FishingModel.money_log)
    end
end

function FishingModel.AddFrameLog(data)
    if debug_log then
        FishingModel.frame_log_list[#FishingModel.frame_log_list + 1] = basefunc.safe_serialize(data)
    end
end
-- 钱不同步
function FishingModel.SaveFrameLog()
    if debug_log then
        local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id .. "/fish_frame_log.txt"
        print("<color=red>钱同步路径 path = " .. path .. "</color>")
        File.WriteAllText(path, basefunc.safe_serialize(FishingModel.frame_log_list))
    end
end

-- 返回能进入的场次ID
function FishingModel.GetCanEnterID()
    return GameFishing3DManager.GetTJGameID()
end
-- 检查钱是否超过上限
-- 目前只检查体验场
function FishingModel.IsMoneyBeyond()
    if m_data.game_id and m_data.game_id == 1 then
        local cfg = this.Config.fish_hall_map[m_data.game_id]
        local user = m_data.players_info[m_data.seat_num]
        local all_score = user.base.score + user.base.fish_coin + user.wait_add_score
        if all_score > cfg.enter_max then
            return false
        end
    end
    return true
end

--使用活动道具
function FishingModel.UseObjProp(id,callback)
    Network.SendRequest("use_obj_prop",{obj_id = tostring(id)}, "正在使用道具",function(data)
        dump(data, "<color=white>使用道具</color>")
        if data.result == 0 then
            if callback and type(callback) == "function" then
                callback()
            end
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end
--使用活动道具
function FishingModel.UseItem(item,callback)
    Network.SendRequest("use_item",{item = tostring(item)}, "使用道具",function(data)
        dump(data, "<color=white>使用道具 key=" .. item .. "</color>")
        data.item = data.item or item
        Event.Brocast("model_use_obj_prop", data)
        if data.result == 0 then
            if data.use_jingbi then
                local userdata = FishingModel.GetPlayerData()
                if userdata.base then
                    userdata.base.score = userdata.base.score - data.use_jingbi
                    if userdata.base.score < 0 then
                        print("<color=red><size=20>EEE 道具使用后钱不够扣</size></color>")
                    end
                    Event.Brocast("ui_refresh_player_money")
                end
            end
            if callback and type(callback) == "function" then
                callback()
            end
        else
            LittleTips.Create(errorCode[data.result] or "[Error Result]"..data.result)
        end
    end)
end
function FishingModel.GetCurHallCfg()
    if m_data and m_data.game_id and this and this.Config and this.Config.fish_hall_map then
        return this.Config.fish_hall_map[m_data.game_id]
    end
end

function FishingModel.GetSkillMoney(key)
    if this.Config.skill_money[FishingModel.game_id] then
        return this.Config.skill_money[FishingModel.game_id][key] or 1000
    end
    return this.Config.skill_money[#this.Config.skill_money][key] or 1000
end

-- boss类型 0没有boss 1宝蟾 2大鲨鱼 3宝藏鳄鱼 4章鱼触角
function FishingModel.GetBossType()
    if not FishingModel.data or not FishingModel.data.game_id then
        return 0
    end
    if FishingModel.data.game_id >= 1 and FishingModel.data.game_id <= 5 then
        if FishingModel.data.image_type_index == 3 then
            return FishingModel.data.game_id - 1
        else
            return 0
        end
    elseif FishingModel.data.game_id == 6 then
        if m_data.fish_map_type == 3 then
            return m_data.fish_map_no
        else
            return 0
        end        
    elseif FishingModel.data.game_id == 7 then
        return 0
    elseif FishingModel.data.game_id == 8 then
        if FishingModel.data.image_type_index == 3 then
            return 3
        else
            return 0
        end
    else
        return 0
    end
end
-- 场景ID
function FishingModel.GetSceneID()
    if not FishingModel.data or not FishingModel.data.game_id then
        return 1
    end

    if FishingModel.data.game_id >= 1 and FishingModel.data.game_id <= 5 then
        return FishingModel.data.game_id
    elseif FishingModel.data.game_id == 6 then
        if m_data.fish_map_type == 3 then
            return m_data.fish_map_no + 1
        else
            return
        end
    elseif FishingModel.data.game_id == 7 then
        return 1
    elseif FishingModel.data.game_id == 8 then
        return 4
    else
        return 1
    end
end

function FishingModel.Debug()
    print("<color=red><size=15>[Debug] FishingModel</size></color>")
    dump(m_data)
    print("破产相关 po can ----------------------")
    local seat_num = FishingModel.GetPlayerSeat()
    dump(FishingModel.data.players_info[seat_num])
    dump(BulletManager.GetBulletNumber(seat_num))
    dump(FishingActivityManager.CheckHaveBullet(seat_num))
    dump(FishingModel.GetMinGunCfg().gun_rate)

    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    FishingLogic.GetPanel().PlayerClass[uipos]:Debug()
end

function FishingModel.Face(num)
    --dump({num = num,count =FishingModel.data.face_count},"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
    if m_data then
        m_data.face_count = m_data.face_count or 0
        m_data.face_count = m_data.face_count + num
    end
end

function FishingModel.IsCanCreateFace(fish_cfg)
    if not m_data then
        return false
    end
    if m_data.scene_frozen_state == "inuse" then
        return false
    end
    if fish_cfg.prefab == "Fish_Act" then
        return true
    end
    if FishingModel.data and FishingModel.data.face_count and FishingModel.data.face_count > 0 then
        return false
    end
    return true
end

function FishingModel.GetBulletTypeBySeatno(seat_num)
    if not m_data.players_info or not m_data.players_info[seat_num] then
        return
    end
    if m_data.players_info[seat_num].wild_state == "inuse" then
        return FishingModel.BulletType.skill_power_bullet
    end

    if m_data.players_info[seat_num].doubled_state == "inuse" then
        return FishingModel.BulletType.skill_crit_bullet
    end
end
