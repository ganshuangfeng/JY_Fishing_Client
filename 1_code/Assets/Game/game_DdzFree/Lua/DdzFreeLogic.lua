--MatchLogic
package.loaded["Game.game_DdzFree.Lua.normal_ddz_func_lib"] = nil

package.loaded["Game.game_DdzFree.Lua.DdzFreeModel"] = nil
require "Game.game_DdzFree.Lua.DdzFreeModel"

package.loaded["Game.game_DdzFree.Lua.DdzFreePlayersActionManger"] = nil
require "Game.game_DdzFree.Lua.DdzFreePlayersActionManger"

package.loaded["Game.game_DdzFree.Lua.DdzFreeActionUiManger"] = nil
require "Game.game_DdzFree.Lua.DdzFreeActionUiManger"

package.loaded["Game.game_DdzFree.Lua.DdzFreeGamePanel"] = nil
require "Game.game_DdzFree.Lua.DdzFreeGamePanel"

package.loaded["Game.game_DdzFree.Lua.DdzExerClearing"] = nil
require "Game.game_DdzFree.Lua.DdzExerClearing"

package.loaded["Game.game_DdzFree.Lua.DdzExerPanel"] = nil
require "Game.game_DdzFree.Lua.DdzExerPanel"

package.loaded["Game.game_DdzFree.Lua.DdzFreeClearing"] = nil
require "Game.game_DdzFree.Lua.DdzFreeClearing"

package.loaded["Game.game_DdzFree.Lua.DdzFreeMyCardUiManger"] = nil
require "Game.game_DdzFree.Lua.DdzFreeMyCardUiManger"

package.loaded["Game.normal_ddz_common.Lua.normal_ddz_func_lib"] = nil
require "Game.normal_ddz_common.Lua.normal_ddz_func_lib"

package.loaded["Game.normal_ddz_common.Lua.DdzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzDzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzDzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzCardTag"] = nil
require "Game.normal_ddz_common.Lua.DdzCardTag"

package.loaded["Game.normal_ddz_common.Lua.DdzTyCard"] = nil
require "Game.normal_ddz_common.Lua.DdzTyCard"

package.loaded["Game.normal_ddz_common.Lua.DdzDzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzDzCard"

package.loaded["Game.normal_ddz_common.Lua.DDZAnimation"] = nil
require "Game.normal_ddz_common.Lua.DDZAnimation"

package.loaded["Game.normal_ddz_common.Lua.DdzHelpPanel"] = nil
require "Game.normal_ddz_common.Lua.DdzHelpPanel"

package.loaded["Game.normal_ddz_common.Lua.DDZSharePrefab"] = nil
require "Game.normal_ddz_common.Lua.DDZSharePrefab"

require "Game.normal_base_common.Lua.PayFastLogic"

DdzFreeLogic = {}

--????????????
--[[
	??????
	--
	??????
{name  ,instance}
]]
DdzFreeLogic.panelNameMap = {
    hall = "DdzFreeHallPanel",
    game = "DdzFreeGamePanel"
}

local cur_loc
local cur_panel

local this
local updateDt = 1
-- Logic ??? Update
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
local jh_name = "ddz_free_game"
--????????????????????????????????????????????????????????????????????????????????????
local function MakeLister()
    lister = {}
    --????????????panel?????????
    -- lister["model_fg_gameover_msg"] = this.on_fg_gameover_msg
    lister["model_fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    lister["model_fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg

    --response
    lister["model_fg_signup_response"] = this.on_fg_signup_response
    lister["model_fg_cancel_signup_response"] = this.on_fg_cancel_signup_response

    lister["model_fg_statusNo_error_msg"] = this.on_fg_status_error_msg
	lister["model_fg_all_info"] = this.on_fg_all_info
	lister["model_nor_ddz_nor_status_info"] = this.on_fg_status_info

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

    --????????????
    lister["AssetChange"] = this.AssetChange
end

local function SendRequestAllInfo()
    if DdzFreeModel.data and DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gameover then
        DdzFreeLogic.on_fg_all_info()
    else
        --??????????????????  ??????????????????????????????
        DdzFreeModel.data.limitDealMsg = {fg_all_info = true}
        Network.SendRequest("fg_req_info_by_send", {type = "all"})
    end
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

function DdzFreeLogic.setViewMsgRegister(lister, registerName)
    --????????????????????????
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function DdzFreeLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function DdzFreeLogic.refresh_panel()
    if cur_panel then
        cur_panel.instance:MyRefresh()
    end
end

function DdzFreeLogic.change_panel(panelName)
    -- if have_Jh then
    --     FullSceneJH.RemoveByTag(have_Jh)
    --     have_Jh = nil
    -- end
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == DdzFreeLogic.panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyExit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == DdzFreeLogic.panelNameMap.hall then
            dump(DdzFreeModel.baseData, "<color=white>baseData:>>>>>>>>>>>>>>>>>>></color>")
            --????????????????????????
            if DdzFreeModel.baseData.jdz_type and DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
                --?????????????????????game_id????????????
                local game_table = {game_type = DdzFreeModel.baseData.game_type,game_id = DdzFreeModel.baseData.game_id}
                GameManager.GotoSceneName("game_Free",game_table)
            else
                GameManager.GotoSceneName("game_Free",DdzFreeModel.baseData.game_type)
            end
        elseif panelName == DdzFreeLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = DdzFreeGamePanel.Create()}
        end
    end
end

function DdzFreeLogic.on_fg_signup_response(result)
    SendRequestAllInfo()
    --DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.game)
    --DdzFreeClearing.Close()
    -- DdzExerClearing.Close()
    -- DdzExerPanel.Close()
end

function DdzFreeLogic.on_fg_cancel_signup_response(result)
    DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.hall)
end

function DdzFreeLogic.on_fg_auto_cancel_signup_msg(result)
    DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.hall)
end

function DdzFreeLogic.on_fg_auto_quit_game_msg(result)
    DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.hall)
end

function DdzFreeLogic.on_fg_gameover_msg()
    DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.hall)
end

--?????? ??????????????????????????????
function DdzFreeLogic.on_fg_all_info()
    --??????????????????
    DdzFreeModel.data.limitDealMsg = nil

    --?????????????????????????????????panel
    if not DdzFreeModel.data.model_status then
        DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.hall)
        return
    end

    DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.game)
    is_allow_forward = true
    --????????????
    ViewMsgRegister()
    DdzFreeLogic.AssetChange()
end
--??????????????????
function DdzFreeLogic.on_fg_status_info()
    --if  ???????????????????????? then
    --?????????????????????????????????panel
    --else
    --??????????????????????????????????????????
end


--??????????????????**************
--??????????????????
function DdzFreeLogic.on_fg_status_error_msg()
    --??????view model
    -- if not have_Jh then
    --     have_Jh = jh_name
    --     FullSceneJH.Create("??????????????????", have_Jh)
    -- end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--???????????????????????????
function DdzFreeLogic.on_backgroundReturn_msg()
    -- if not have_Jh then
    --     have_Jh = jh_name
    --     FullSceneJH.Create("??????????????????", have_Jh)
    -- end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--??????????????????
function DdzFreeLogic.on_background_msg()
    cancelViewMsgRegister()
end
--????????????????????????
function DdzFreeLogic.on_network_error_msg()
    -- if not have_Jh then
    --     have_Jh = jh_name
    --     FullSceneJH.Create("??????????????????", have_Jh)
    -- end
    cancelViewMsgRegister()
end
--??????????????????????????????
function DdzFreeLogic.on_network_repair_msg()
end
--?????????????????????
function DdzFreeLogic.on_network_poor_msg()
end
--????????????????????????
function DdzFreeLogic.on_reconnect_msg()
    --??????ALL??????
    SendRequestAllInfo()
end
--??????????????????**************

--????????????
function DdzFreeLogic.AssetChange()
    Event.Brocast("logic_AssetChange")
end

function DdzFreeLogic.Update()
end

--?????????
function DdzFreeLogic.Init(isNotSendAllInfo)
    this = DdzFreeLogic

    --?????????model
    local model = DdzFreeModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(DdzFreeLogic.Update, updateDt, -1)
    update:Start()

    SysInteractiveChatManager.Init(model)
    SysInteractiveAniManager.Init(model)
    MainLogic.EnterGame()

    have_Jh = jh_name
    -- FullSceneJH.Create("??????????????????", have_Jh)
    --??????ALL??????
    if not isNotSendAllInfo then
        SendRequestAllInfo()
    end
    --SendRequestAllInfo()

    DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.game)
end

function DdzFreeLogic.Exit()
    if this then
        print("<color=green>???????????????</color>")
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
        DdzFreeModel.Exit()
    end
end

function DdzFreeLogic.get_cur_panel()
	if cur_panel then
		return cur_panel.instance
	end
	return nil
end

function DdzFreeLogic.quit_game(call, quit_msg_call)
    Network.SendRequest("fg_quit_game", nil, "????????????", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            if not call then
                DdzFreeLogic.change_panel(DdzFreeLogic.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return DdzFreeLogic
