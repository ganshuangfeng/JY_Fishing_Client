-- 创建时间:2018-12-10
local basefunc = require "Game.Common.basefunc"
local item_config = SysItemManager.item_config

GameItemModel = {}

GameItemModel.ItemType = {
    nor = 0,
    skill = 1, -- 技能
    act = 2, -- 活动
    cf_skill = 3, -- 分场次的技能
}

local this
local m_data
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["AssetChange"] = GameItemModel.OnAssetChange
    lister["OnLoginResponse"] = GameItemModel.OnLoginResponse
end
function GameItemModel.OnLoginResponse(result)
    if result == 0 then
        GameItemModel.InitRedData()
    end
end
-- 初始化Data
local function InitMatchData()
    GameItemModel.data={
    }
    m_data = GameItemModel.data
end

function GameItemModel.Init()
    this = GameItemModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    return this
end
function GameItemModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end

function GameItemModel.InitUIConfig()
    this.UIConfig={}

    local cfg = {}
    local bag_cfg = {}
    local cfg_map = {}
    for k,v in ipairs(item_config.config) do
        v.id = nil -- 与服务器obj道具id重复
        cfg[v.item_id] = v
        cfg_map[v.item_key] = v
        if v.is_show_bag and v.is_show_bag == 1 then
            bag_cfg[v.item_id] = v
        end
    end
    -- 道具ID为key
    this.UIConfig.config = cfg
    -- 道具key为key
    this.UIConfig.config_map = cfg_map
    -- 道具ID为key
    this.UIConfig.config_bag = bag_cfg
end

-- tag
-- 1 大厅背包 
-- 2 捕鱼自由场背包
-- 4 捕鱼比赛场背包
-- 8 捕鱼3D自由场背包
-- 16 水族馆背包

-- 是否包含
function GameItemModel.IsInclude(cfg_tag, tag)
    cfg_tag = cfg_tag or 1
    if basefunc.bit_and(cfg_tag, tag) > 0 then
        return true
    end
end

-- 是否包含
function GameItemModel.GetIncludeByTag(tag)
    if tag then
        local list = {}
        for k,v in pairs(this.UIConfig.config_bag) do
            if GameItemModel.IsInclude(v.tag, tag) then
                list[#list + 1] = v
            end
        end
        return list
    else
        return this.UIConfig.config_bag
    end
end

-- 请求所有道具数据
function GameItemModel.ReqAllItem()
end

-- 根据道具Key获取道具tag
function GameItemModel.GetItemTagToKey(key)
    local tag = 1
    local item = GameItemModel.GetItemToKey(key)
    if item then
        tag = item.tag or 1
    elseif key == "obj_fishbowl_fish" then -- 水族馆里鱼缸的鱼
        tag = 16
    end
    return tag
end
-- 根据道具Key获取道具
function GameItemModel.GetItemToKey(key)
    if this.UIConfig.config_map[key] then
        return this.UIConfig.config_map[key] 
    else
        local a,b = GameButtonManager.RunFun({gotoui="sys_by_bag", key=key}, "GetItemToKey_G")
        if a then
            return b
        end
    end
end
-- 根据道具Key获取道具ID
function GameItemModel.GetItemIdsToKey(key, scene)
    local ids = {}
   if MainModel.UserInfo.ToolMap then
        local curT = os.time()
        for k, v in pairs(MainModel.UserInfo.ToolMap) do
            if not scene or ((v.scene and v.scene == scene) or (not v.scene and scene ~= "matchstyle")) then
                if v.asset_type == key and (v.valid_time and tonumber(v.valid_time) > curT) then
                    ids[#ids + 1] = v.id
                end
            end
        end
    end
    return ids
end

local callSort = function (v1, v2)
    if v1.order > v2.order then
        return true
    elseif v1.order < v2.order then
        return false        
    end
    if v1.num < v2.num then
        return true
    else
        return false
    end
end

local fishing_game_id_t = {
    2,3,4,1
}

local call_sort_fishing = function(v1,v2)
    if fishing_game_id_t[v1.game_id] > fishing_game_id_t[v2.game_id] then
       return true
    elseif fishing_game_id_t[v1.game_id] < fishing_game_id_t[v2.game_id] then
        return false            
    end
    if v1.order > v2.order then
        return true
    elseif v1.order < v2.order then
        return false            
    end
    if v1.bullet_num and v2.bullet_num then
        if tonumber(v1.bullet_num) > tonumber(v2.bullet_num) then
            return true
        elseif tonumber(v1.bullet_num) < tonumber(v2.bullet_num) then
            return false
        end
    else
        return false
    end
    if v1.bullet_index then
        if tonumber(v1.bullet_index) > tonumber(v2.bullet_index) then
            return true
        elseif tonumber(v1.bullet_index) < tonumber(v2.bullet_index) then
            return false
        end
    else
        return false
    end
end

-- 根据背包道具数据
function GameItemModel.GetBagItem(tag)
    local data = {}
    local list = GameItemModel.GetIncludeByTag(tag or 1)

    for k,v in pairs(list) do
        if MainModel.UserInfo[v.item_key] then
            local vv = {}
            for k1, v1 in pairs(v) do
                vv[k1] = v1
            end
            if v.item_key == "jipaiqi" then
                local nn = MainModel.UserInfo[v.item_key]
                vv.num = math.ceil((tonumber(nn) - os.time()) / 86400)
                vv.date = math.ceil((tonumber(nn) - os.time()) / 3600)
                data[#data + 1] = vv
            else
                vv.num = MainModel.UserInfo[v.item_key]
                if vv.num > 0 then
                    data[#data + 1] = vv
                end
            end
        else
            if not MainModel.UserInfo.ToolMap then
                MainModel.UserInfo.ToolMap = {}
            end
            for k1,v1 in pairs(MainModel.UserInfo.ToolMap) do
                if v1.asset_type == v.item_key and (not v1.valid_time or v1.valid_time > os.time()) then
                    local vv = {}
                    for k1, v1 in pairs(v) do
                        vv[k1] = v1
                    end
                    if v1.valid_time then
                        local nn = v1.valid_time
                        local days = math.ceil((tonumber(nn) - os.time()) / 3600)
                        vv.date = days
                    end
                    vv.num = v1.num or -1
                    data[#data + 1] = vv
                    for k2, v2 in pairs(v1) do
                        vv[k2] = v2
                    end
                end
            end
        end
    end
    local m_sort = function(v1,v2)
        if v1.game_id and v2.game_id then
            return call_sort_fishing(v1,v2)
        else
            return callSort(v1,v2)
        end
    end
    MathExtend.SortListCom(data, m_sort)
    return data
end

function GameItemModel.GetFishingBagItemByTag(game_id, tag, scene)
    local data = {}
    local list = GameItemModel.GetIncludeByTag(tag)
    for k,v in pairs(list) do
        if MainModel.UserInfo[v.item_key] then
            if scene ~= "matchstyle" then
                if not v.game_id  or v.game_id == game_id then
                    local vv = {}
                    for k1, v1 in pairs(v) do
                        vv[k1] = v1
                    end
                    vv.num = MainModel.UserInfo[v.item_key]
                    if vv.num > 0 then
                        data[#data + 1] = vv
                    end
                end
            end
        else
            if not MainModel.UserInfo.ToolMap then
                MainModel.UserInfo.ToolMap = {}
            end
            for k1,v1 in pairs(MainModel.UserInfo.ToolMap) do
                if v1.asset_type == v.item_key and 
                   ((v1.scene and v1.scene == scene) or (not v1.scene and scene ~= "matchstyle")) and
                   (not v1.valid_time or v1.valid_time > os.time()) then
                    local vv = {}
                    for k1, v1 in pairs(v) do
                        vv[k1] = v1
                    end
                    if v1.valid_time then
                        local nn = v1.valid_time
                        local days = math.ceil((tonumber(nn) - os.time()) / 3600)
                        vv.date = days
                    end
                    if v1.num then
                        vv.num = v1.num
                    else
                        vv.num = v1.bullet_num or -1
                    end
                    data[#data + 1] = vv
                    for k2, v2 in pairs(v1) do
                        vv[k2] = v2
                    end
                end
            end
        end
    end
    game_id = game_id or 0

    local cur_s_list = {}
    local nor_list = {}
    local not_s_list = {}
    for i,v in ipairs(data) do
        if not v.game_id then
            table.insert(nor_list,v)
        else
            if game_id == v.game_id then
                table.insert( cur_s_list,v)
            else
                table.insert( not_s_list,v)
            end
        end
    end
    MathExtend.SortListCom(cur_s_list,call_sort_fishing)
    MathExtend.SortListCom(nor_list,callSort)
    MathExtend.SortListCom(not_s_list,call_sort_fishing)
    for i,v in ipairs(nor_list) do
        table.insert( cur_s_list,v)
    end
    for i,v in ipairs(not_s_list) do
        table.insert( cur_s_list,v)
    end
    return cur_s_list
end

-- 获取捕鱼背包道具数据
function GameItemModel.GetFishingBagItem(game_id)
    local list = GameItemModel.GetFishingBagItemByTag(game_id, 2, "freestyle")
    local data = {}
    for k,v in ipairs(list) do
        if v.num > 0 or v.date > 0 then
            data[#data + 1] = v
        end
    end
    return data
end

-- 获取捕鱼比赛场背包道具数据
function GameItemModel.GetFishingMatchBagItem(game_id)
    local list = GameItemModel.GetFishingBagItemByTag(game_id, 4, "matchstyle")
    local data = {}
    for k,v in ipairs(list) do
        if v.num > 0 or v.date > 0 then
            data[#data + 1] = v
        end
    end
    return data
end

-- 获取3D捕鱼背包道具数据
function GameItemModel.GetFishing3DBagItem(game_id)
    local list = GameItemModel.GetFishingBagItemByTag(game_id, 8, "freestyle_3d")
    local data = {}
    for k,v in ipairs(list) do
        if v.num > 0 or v.date > 0 then
            data[#data + 1] = v
        end
    end
    return data
end

function GameItemModel.GetItemCount(itemKey)
    local n = MainModel.UserInfo[itemKey] or -1
    if n < 0 and MainModel.UserInfo.ToolMap then
        local curT = os.time()
        for k, v in pairs(MainModel.UserInfo.ToolMap) do
            if v.asset_type == itemKey and (v.valid_time and tonumber(v.valid_time) > curT) then
                n = math.max(0, n) + (v.num or 1)
            end
        end
    end
    if n < 0 then
        n = 0
    end
    return n
end

function GameItemModel.IsTimeLimitedItem(itemKey)
    local ret = false
    if itemKey and MainModel.UserInfo.ToolMap then
        for _, v in pairs(MainModel.UserInfo.ToolMap) do
            if v.asset_type == itemKey then
                ret = true
                break
            end
        end
    end
    return ret
end

-- 根据道具ID获取道具
function GameItemModel.GetToolDataByID(id)
    local ret
    if id and MainModel.UserInfo.ToolMap and MainModel.UserInfo.ToolMap[id] then
        local v = MainModel.UserInfo.ToolMap[id]
        ret = {}
        local cfg = GameItemModel.GetItemToKey(v.asset_type)
        for k1, v1 in pairs(cfg) do
            ret[k1] = v1
        end
        for k1, v1 in pairs(v) do
            ret[k1] = v1
        end
    end
    return ret
end

function GameItemModel.GetTimeUnlimitedItemKey(itemKeys)
    local key
    if itemKeys and next(itemKeys) then
        for _, v in pairs(itemKeys) do
            if not GameItemModel.IsTimeLimitedItem(v) then
                key = v
                break
            end
        end
    end
    return key
end

--unused
function GameItemModel.GetTimeLimitedItem(itemKeys)
    local key
    if itemKeys and next(itemKeys) then
        for _, v in pairs(itemKeys) do
            if not GameItemModel.IsTimeLimitedItem(v) then
                key = v
            end
        end
    end
    return key
end

function GameItemModel.GetItemTotalCount(itemKeys)
    local count = 0
    if itemKeys and next(itemKeys) then
        for _, v in pairs(itemKeys) do
            if v ~= "jing_bi" then
                count = count + math.max(0, GameItemModel.GetItemCount(v))
            end
        end
    end
    return count
end

function GameItemModel.GetUseToolCount(tarKey, itemKeys, itemCount)
    local cost = 0
    if tarKey and itemKeys and itemCount and #itemKeys <= #itemCount then
        for i, k in ipairs(itemKeys) do
            if k == tarKey then
                cost = itemCount[i]
                break
            end
        end
    end
    return cost
end

function GameItemModel.GetItemTypeExt(_type)
    if _type == "prop_3d_fish_frozen"
        or _type == "prop_3d_fish_frozen"
        then
            return GameItemModel.ItemType.skill
    elseif _type == "obj_fish_free_bullet"
        or _type == "obj_fish_power_bullet"
        or _type == "obj_fish_drill_bullet"
        or _type == "obj_fish_pierce_bullet"
        or _type == "obj_fish_summon_fish"
        or _type == "obj_fish_crit_bullet"
        or _type == "obj_fish_3d_free_bullet"
        or _type == "obj_fish_3d_power_bullet"
        or _type == "obj_fish_3d_crit_bullet"
        or _type == "obj_fish_3d_quick_shoot"
        or _type == "obj_fish_3d_drill_bullet"
        or _type == "obj_fish_3d_pierce_bullet"
        or _type == "obj_fish_3d_summon_fish"
        or _type == "obj_fish_3d_time_free_power_bullet"
        or _type == "obj_fish_3d_laser_bullet"
        then
            return GameItemModel.ItemType.act
    elseif _type == "obj_fish_secondary_bomb"
        or _type == "obj_fish_super_bomb"
        or _type == "obj_fish_secondary_bolt"
        or _type == "obj_fish_summon_fish"
        or _type == "obj_fish_super_bolt"
        or _type == "prop_fish_super_bomb_1"
        or _type == "prop_fish_secondary_bomb_1"
        or _type == "prop_fish_super_bomb_2"
        or _type == "prop_fish_secondary_bomb_2"
        or _type == "prop_fish_super_bomb_3"
        or _type == "prop_fish_secondary_bomb_3"
        or _type == "prop_fish_summon_fish"
        then
            return GameItemModel.ItemType.cf_skill
    else
            return GameItemModel.ItemType.nor
    end
end
function GameItemModel.GetItemType(data)
    if data.asset_type then
        return GameItemModel.GetItemTypeExt(data.asset_type)
    elseif data.item_key then
        return GameItemModel.GetItemTypeExt(data.item_key)
    end
    return GameItemModel.ItemType.nor
end

-- 背包道具红点功能
local function getRedDataPath()
    local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
    return path
end
local function getRedDataToDescPath()
    return getRedDataPath() .. "/bag_item_red.txt"
end
-- 加载
local function LoadRedData()
    local ok, _data = xpcall(function ()
        local path = getRedDataPath()
        if not Directory.Exists(path) then
            Directory.CreateDirectory(path)
        end
        path = getRedDataToDescPath()
        if not File.Exists(path) then
            return
        end
        local data = File.ReadAllText(path)
        if not data or data == "" then
            return
        end
        local list = {}
        local ns = StringHelper.Split(data, ",")
        for _,v in ipairs(ns) do
            list[#list + 1] = v
        end
        return list
    end
    ,function (err)
        print(err)
    end)

    return _data
end
-- 保存
local function SaveRedData(list)
    -- 最快30秒保存一次(非重要功能无需浪费太多资源)
    -- if not m_data.last_save_time or ( os.time()-m_data.last_save_time ) > 30 then
        m_data.last_save_time = os.time()

        local ok = xpcall(function ()
            local path = getRedDataPath()
            if not Directory.Exists(path) then
                Directory.CreateDirectory(path)
            end

            path = getRedDataToDescPath()
            local idstr = ""
            for i,v in ipairs(list) do
                idstr = idstr .. v .. ","
            end
            File.WriteAllText(path, idstr)
        end
        ,function (err)
            print(err)
        end)
    -- end
end
function GameItemModel.AddOrDelRedItem(id, is_add)
    m_data.item_red_data = m_data.item_red_data or {}
    m_data.item_red_data.red_map = m_data.item_red_data.red_map or {}
    m_data.item_red_data.red_list = m_data.item_red_data.red_list or {}

    if is_add then
        m_data.item_red_data.red_map[id] = 1
        m_data.item_red_data.red_list[#m_data.item_red_data.red_list + 1] = id
    else
        m_data.item_red_data.red_map[id] = nil
        for k,v in ipairs(m_data.item_red_data.red_list) do
            if v == id then
                table.remove(m_data.item_red_data.red_list, k)
                break
            end
        end
    end
end

function GameItemModel.InitRedData()
    m_data.item_red_data = {}
    m_data.item_red_data.red_list = {}
    m_data.item_red_data.red_map = {}

    local list = LoadRedData()
    local b = false
    if list then
        for i = #list, 1, -1 do
            local n = GameItemModel.GetItemCount(list[i])
            if n > 0 then
                m_data.item_red_data.red_list[#m_data.item_red_data.red_list + 1] = list[i]
                m_data.item_red_data.red_map[ list[i] ] = 1
            else
                b = true
                table.remove(list, i)
            end
        end
    end
    if b then
        SaveRedData(list)
    end

    Event.Brocast("UpdateHallBagRedHint")
end
function GameItemModel.OnAssetChange(data)
    local b = false
    if data.prop_assets_list then
        for k,v in ipairs(data.prop_assets_list) do
            if v.type == "add" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if not m_data.item_red_data or not m_data.item_red_data.red_map or not m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, true)
                    end
                end
            elseif v.type == "del" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if m_data.item_red_data and m_data.item_red_data.red_map and m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, false)
                    end
                end
            end
        end
    end
    if data.obj_assets_list then
        for k,v in ipairs(data.obj_assets_list) do
            if v.type == "add" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if not m_data.item_red_data or not m_data.item_red_data.red_map or not m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, true)
                    end
                end
            elseif v.type == "del" then
                local cfg = GameItemModel.GetItemToKey(v.key)
                if cfg and cfg.is_show_bag and cfg.is_show_bag == 1 then
                    if m_data.item_red_data and m_data.item_red_data.red_map and m_data.item_red_data.red_map[v.id] then
                        b = true
                        GameItemModel.AddOrDelRedItem(v.id, false)
                    end
                end
            end
        end
    end

    if b then
        SaveRedData(m_data.item_red_data.red_list)
        Event.Brocast("UpdateHallBagRedHint")
    end
end

-- 背包红点
function GameItemModel.IsBagRadByTag(tag)
    local _tag = tag or 1
    if m_data.item_red_data and m_data.item_red_data.red_list then
        for k,v in ipairs(m_data.item_red_data.red_list) do
            local t
            if MainModel.UserInfo.ToolMap[v] then
                t = GameItemModel.GetItemTagToKey( MainModel.UserInfo.ToolMap[v].asset_type )
            else
                t = GameItemModel.GetItemTagToKey( v )
            end
            if basefunc.bit_and(_tag, t) > 0 then
                return true
            end
        end
    end
    return false
end
-- 某个道具的红点状态
function GameItemModel.GetItemRadByKey(key)
    if m_data.item_red_data and m_data.item_red_data.red_map and m_data.item_red_data.red_map[key] then
        return true
    end
    return false
end

-- 某个道具的红点状态
function GameItemModel.SetItemRadByKey(key, b)
    GameItemModel.AddOrDelRedItem(key, b)

    SaveRedData(m_data.item_red_data.red_list)
    Event.Brocast("UpdateHallBagRedHint")
end
