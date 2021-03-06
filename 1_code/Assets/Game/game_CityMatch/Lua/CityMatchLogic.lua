--MatchLogic
package.loaded["Game.game_CityMatch.Lua.CityMatchModel"] = nil
require "Game.game_CityMatch.Lua.CityMatchModel"

package.loaded["Game.game_CityMatch.Lua.CityMatchMyCardUiManger"] = nil
require "Game.game_CityMatch.Lua.CityMatchMyCardUiManger"
package.loaded["Game.game_CityMatch.Lua.CityMatchPlayersActionManger"] = nil
require "Game.game_CityMatch.Lua.CityMatchPlayersActionManger"
package.loaded["Game.game_CityMatch.Lua.CityMatchActionUiManger"] = nil
require "Game.game_CityMatch.Lua.CityMatchActionUiManger"

package.loaded["Game.game_CityMatch.Lua.CityMatchHallPanel"] = nil
require "Game.game_CityMatch.Lua.CityMatchHallPanel"
package.loaded["Game.game_CityMatch.Lua.CityMatchWaitPanel"] = nil
require "Game.game_CityMatch.Lua.CityMatchWaitPanel"
package.loaded["Game.game_CityMatch.Lua.CityMatchWaitRematchPanel"] = nil
require "Game.game_CityMatch.Lua.CityMatchWaitRematchPanel"
package.loaded["Game.game_CityMatch.Lua.CityMatchSharePanel"] = nil
require "Game.game_CityMatch.Lua.CityMatchSharePanel"

package.loaded["Game.game_CityMatch.Lua.CityMatchGamePanel"] = nil
require "Game.game_CityMatch.Lua.CityMatchGamePanel"

package.loaded["Game.game_CityMatch.Lua.CityRankPanel"] = nil
require "Game.game_CityMatch.Lua.CityRankPanel"

package.loaded["Game.game_CityMatch.Lua.CityAwardPanel"] = nil
require "Game.game_CityMatch.Lua.CityAwardPanel"

package.loaded["Game.game_CityMatch.Lua.CitySettlementPanel"] = nil
require "Game.game_CityMatch.Lua.CitySettlementPanel"

package.loaded["Game.normal_ddz_common.Lua.nor_ddz_base_lib"] = nil
require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"

package.loaded["Game.normal_ddz_common.Lua.DdzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzDzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzDzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzCardTag"] = nil
require "Game.normal_ddz_common.Lua.DdzCardTag"

package.loaded["Game.normal_ddz_common.Lua.DDZAnimation"] = nil
require "Game.normal_ddz_common.Lua.DDZAnimation"

package.loaded["Game.normal_ddz_common.Lua.DdzHelpPanel"] = nil
require "Game.normal_ddz_common.Lua.DdzHelpPanel"

city_match_config = require "Game.game_CityMatch.Lua.city_match_config"

CityMatchLogic = {}

--????????????
--[[
	??????
	--
	????????????
	--
	????????????
	--
	??????

{name  ,instance}
]]
local panelNameMap = {
    hall = "CityMatchHallPanel",
    wait = "CityMatchWaitPanel",
    wait_rematch = "CityMatchWaitRematchPanel",
    game = "CityMatchGamePanel"
}
local cur_loc
local cur_panel

local this
local updateDt = 1
local update
--????????????????????????
local req_sign_num_inval = 3
local req_sign_num_count = 0
--?????????????????????
local lister

local is_allow_forward = false
--view???????????????
local viewLister = {}
local have_Jh
local jh_name = "ddz_match_jh"
--????????????????????????????????????????????????????????????????????????????????????
local function MakeLister()
    lister = {}
    --????????????panel?????????
    lister["model_citymg_begin_msg"] = this.on_citymg_begin_msg
    lister["model_citymg_gameover_msg"] = this.on_citymg_gameover_msg
    --response
    lister["model_citymg_signup_response"] = this.on_citymg_signup_response
    lister["model_citymg_cancel_signup_response"] = this.on_citymg_cancel_signup_response

    lister["model_citymg_statusNo_error_msg"] = this.on_citymg_status_error_msg
    lister["model_citymg_all_info"] = this.on_citymg_all_info

    lister["model_nor_ddz_nor_status_info"] = this.on_nor_ddz_nor_status_info

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
end

local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end
local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

function CityMatchLogic.setViewMsgRegister(lister, registerName)
    --????????????????????????
    if not registerName or viewLister[registerName] then
        print("<color=red>setViewMsgRegister</color>")
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end
function CityMatchLogic.clearViewMsgRegister(registerName)
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function CityMatchLogic.change_panel(panelName)
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end

    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == panelNameMap.hall then
            cur_panel = {name = panelName, instance = CityMatchHallPanel.Create()}
        elseif panelName == panelNameMap.wait then
			cur_panel = {name = panelName, instance = CityMatchWaitPanel.Create()}
		elseif panelName == panelNameMap.wait_rematch then
            cur_panel = {name = panelName, instance = CityMatchWaitRematchPanel.Create()}
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = CityMatchGamePanel.Create()}
        end
    end
    --cur_panel=MatchPanel.Show(load_callback)
end

function CityMatchLogic.get_cur_panel()
    if cur_panel then
        return cur_panel.instance
    end
    return nil
end

function CityMatchLogic.on_citymg_signup_response(result)
	--?????? ??????????????????
	if CityMatchModel.data.match_type == 1 then
		CityMatchLogic.change_panel(panelNameMap.wait)
	elseif CityMatchModel.data.match_type == 2 then
		CityMatchLogic.change_panel(panelNameMap.wait_rematch)
	end
end

function CityMatchLogic.on_citymg_cancel_signup_response(result)
    CityMatchLogic.change_panel(panelNameMap.hall)
end

--??????????????????????????????????????????????????????????????????????????????????????????
function CityMatchLogic.on_mjfg_auto_cancel_signup_msg(result)
    CityMatchLogic.change_panel(panelNameMap.hall)
end

function CityMatchLogic.on_citymg_begin_msg()
    --????????? ??????????????????
    CityMatchLogic.change_panel(panelNameMap.game)
end

function CityMatchLogic.on_citymg_gameover_msg()
    --????????? ???????????????
    CityMatchLogic.change_panel(panelNameMap.hall)
    CitySettlementPanel.Create(CityMatchModel.data.citymg_final_result)
end

--?????? ??????????????????????????????
function CityMatchLogic.on_citymg_all_info()
    --??????????????????
    CityMatchModel.data.limitDealMsg = nil
    local go_to
    --?????????????????????????????????panel
    if CityMatchModel.data.model_status == nil then
        --????????????
        go_to = panelNameMap.hall
    elseif CityMatchModel.data.model_status == CityMatchModel.Model_Status.wait_begin then
		--??????????????????
		if CityMatchModel.data.match_type == 1 then
			go_to = panelNameMap.wait
		elseif CityMatchModel.data.match_type == 2 then
			go_to = panelNameMap.wait_rematch
		end
    elseif CityMatchModel.data.model_status == CityMatchModel.Model_Status.gameover then
        --???????????????
        go_to = panelNameMap.hall
        CitySettlementPanel.Create(CityMatchModel.data.citymg_final_result)
    elseif
        CityMatchModel.data.model_status == CityMatchModel.Model_Status.gaming or
            CityMatchModel.data.model_status == CityMatchModel.Model_Status.promoted or
            CityMatchModel.data.model_status == CityMatchModel.Model_Status.wait_result or
            CityMatchModel.data.model_status == CityMatchModel.Model_Status.wait_table
     then
        --????????????
        go_to = panelNameMap.game
    end
    CityMatchLogic.change_panel(go_to)
    is_allow_forward = true
    --????????????
    ViewMsgRegister()
end

--??????????????????
function CityMatchLogic.on_nor_ddz_nor_status_info()
    --if  ???????????????????????? then
    --?????????????????????????????????panel
    --else
    --??????????????????????????????????????????
end

local function SendRequestAllInfo()
    --?????????????????????
    MainModel.RequestCityMatchStateData(nil,function (data)
        dump(data, "<color=yellow>???????????????????????????</color>")
        CityMatchModel.macthUIConfig.config = data
        this.parm = data
    end)
    
    if CityMatchModel.data and CityMatchModel.data.model_status == CityMatchModel.Model_Status.gameover then
        CityMatchLogic.on_citymg_all_info()
    else
        --??????????????????  ??????????????????????????????
        CityMatchModel.data.limitDealMsg = {citymg_all_info = true}
        Network.SendRequest("citymg_req_info_by_send", {type = "all"})
    end
end

--??????????????????**************
--??????????????????
function CityMatchLogic.on_citymg_status_error_msg()
    print("<color=yellow>on_citymg_status_error_msg</color>")
    --??????view model
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("??????????????????", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end

--???????????????????????????
function CityMatchLogic.on_backgroundReturn_msg()
    print("<color=yellow>on_backgroundReturn_msg</color>")
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("??????????????????", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end

--??????????????????
function CityMatchLogic.on_background_msg()
    cancelViewMsgRegister()
end

--????????????????????????
function CityMatchLogic.on_network_error_msg()
    cancelViewMsgRegister()
end

--??????????????????????????????
function CityMatchLogic.on_network_repair_msg()
end
--?????????????????????
function CityMatchLogic.on_network_poor_msg()
end

--????????????????????????
function CityMatchLogic.on_reconnect_msg()
    print("<color=yellow>on_reconnect_msg</color>")
    --??????ALL??????
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("??????????????????", have_Jh)
    end
    SendRequestAllInfo()
end

--??????????????????**************
function CityMatchLogic.Update()
    if CityMatchModel.data and CityMatchModel.data.model_status == CityMatchModel.Model_Status.wait_begin then
        req_sign_num_count = req_sign_num_count + updateDt
        if req_sign_num_count >= req_sign_num_inval then
            req_sign_num_count = 0
            Network.SendRequest("citymg_req_cur_signup_num")
        end
    end

    -- dump(this.parm, "<color=yellow>this.parm</color>")
    if this and this.parm then
        local data = this.parm
        if data.time < 0 then return end
        if data.time == 0 then
            --?????????????????????
            MainModel.RequestCityMatchStateData(
                function(data)
                    CityMatchModel.macthUIConfig.config = data
                    this.parm = data
                    Event.Brocast("city_match_refersh_state")
                end
            )
        end
        data.time = data.time - 1
    end
end

--?????????
function CityMatchLogic.Init(parm)
    this = CityMatchLogic
    this.parm = parm
    --?????????model
    local model = CityMatchModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(CityMatchLogic.Update, updateDt, -1, nil, true)
    update:Start()
    SysInteractiveChatManager.Init(model)
    SysInteractiveAniManager.Init(model)

    print("<color=yellow>MainModel.Location</color>", MainModel.Location)
    --?????????
    if not MainModel.Location then
        is_allow_forward = true
    else
        have_Jh = jh_name

        FullSceneJH.Create("??????????????????", have_Jh)
        --??????ALL??????
        SendRequestAllInfo()
    end
    CityMatchLogic.change_panel(panelNameMap.hall)

    MainModel.CacheShop()
end

function CityMatchLogic.Exit()
    SysInteractiveChatManager.Exit()
    SysInteractiveAniManager.Exit()
    this = nil
    update:Stop()
    update = nil
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil

    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
	CityMatchModel.Exit()

	CityRankPanel.Close()
	CitySettlementPanel.Close()
end

function CityMatchLogic.quit_game(call, quit_msg_call)
    Network.SendRequest("citymg_quit_game", nil, "????????????", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            if not call then
                CityMatchLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return CityMatchLogic
