
LoginModel={}

local this

--[[
    youke
    wechat
    device_id
    device_os
]]
local loginData
local lastLoginChannel

local ykKey = "yk_login_id"
local wxKey = "hw_login_id"
local tokenKey = "hw_login_refresh_token"
local lastLoginChannelKey = "last_login_channel"

local function SaveLocalLoginData(channel,_id,_token)
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    if channel == "youke" then
        File.WriteAllText(path .. "/" .. ykKey .. ".txt", _id)
    elseif channel == "vivo" then
        File.WriteAllText(path .. "/" .. wxKey .. ".txt", _id)
    elseif channel == "token" then
    end
    File.WriteAllText(path .. "/" .. tokenKey .. ".txt", _token)
    File.WriteAllText(path .. "/" .. lastLoginChannelKey .. ".txt", channel)
end
local function CloseLastLoginData()
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath
    else
        path = AppDefine.LOCAL_DATA_PATH
    end
    File.WriteAllText(path .. "/" .. lastLoginChannelKey .. ".txt", "")
end
local function GetLocalLoginData(name)
    local path
    if AppDefine.IsEDITOR() then
        path = Application.dataPath .. "/" .. name .. ".txt"
    else
        path = AppDefine.LOCAL_DATA_PATH .. "/" .. name .. ".txt"
    end
    if File.Exists(path) then
        return File.ReadAllText(path)
    else
        return ""
    end
end

local function SetChannelData(channel, _id, _token)
    SaveLocalLoginData(channel, _id, _token)
end

--初始化登录数据
local function InitLoginData( )

    this.loginData={
        youke=GetLocalLoginData(ykKey),
        vivo=GetLocalLoginData(wxKey),
        refresh_token=GetLocalLoginData(tokenKey),
        lastLoginChannel=GetLocalLoginData(lastLoginChannelKey),
    }

    if this.loginData.youke == "" then
        this.loginData.youke = nil
    end

    if this.loginData.vivo == "" then
        this.loginData.vivo = nil
    end

    if this.loginData.lastLoginChannel == "" then
        this.loginData.lastLoginChannel = nil
    end

    this.loginData.device_id = MainModel.LoginInfo.device_id
    this.loginData.device_os = MainModel.LoginInfo.device_os
end



local lister
local function AddLister()
    lister={}
    lister["OnLoginResponse"] = this.OnLoginResult
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

function LoginModel.Init()
    this = LoginModel

    AddLister()

    InitLoginData( )

    return this
end



function LoginModel.OnLoginResult(result)

    if result == 0 then
        local channel = MainModel.UserInfo.channel_type
        local loginId = MainModel.UserInfo.login_id
        local token = MainModel.UserInfo.refresh_token
        SetChannelData(channel,loginId,token)
        
    end

end

function LoginModel.GetChannelLuaTable(channel)
	return nil
end

function LoginModel.ClearChannelData(channel)
    if this then
        this.loginData.channel = nil
    end

    if channel == "youke" then
        SaveLocalLoginData("youke", "", "")
        if this then
            this.loginData.youke = nil
        end
    elseif channel == "vivo" then
        SaveLocalLoginData("vivo", "", "")
        if this then
            this.loginData.vivo = nil
        end
    else
    end
end


function LoginModel.ClearLastLoginData()
    CloseLastLoginData()
    if this then
        this.loginData.lastLoginChannel=nil
    end
end

function LoginModel.Exit()
    
    if this then
        
        RemoveLister()

	this.loginData = {}
	this.loginData.device_id = MainModel.LoginInfo.device_id
	this.loginData.device_os = MainModel.LoginInfo.device_os
        this = nil
    end

end

function LoginModel.ClearLoginData(reason, channel)
    local ct = channel or LoginModel.GetLastLoginWay()
    if not ct then
        ct = GetLocalLoginData(lastLoginChannelKey)
    end
    if reason == "dlbc" then
        LoginModel.ClearChannelData(ct)
        LoginModel.ClearLastLoginData()
    end
    if reason == "dc" then
        if ct ~= "youke" then
            LoginModel.ClearChannelData(ct)
        end
        LoginModel.ClearLastLoginData()
    end
    if reason == "dh" then
        -- local ct = MainModel.LoginInfo.channel_type
        -- LoginModel.ClearChannelData(ct)
        -- LoginModel.ClearLastLoginData()
    end
end

function LoginModel.GetLastLoginWay()
    if this and this.loginData then 
        return this.loginData.lastLoginChannel
    end
end
