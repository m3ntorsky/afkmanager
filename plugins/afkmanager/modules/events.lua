
local floor = math.floor

local isPluginLoading = nil
local isPluginLoadingLate = nil


---@param event Event
local function OnPluginStart(event)
    local serverTime = floor(server:GetCurrentTime() * 1000)

    isPluginLoading = true
    isPluginLoadingLate = serverTime > 0

    AFKManager:LoadConfig()
end

---@param event Event
local function OnAllPluginsLoaded(event)
    if isPluginLoadingLate then
        for playerid = 0, playermanager:GetPlayerCap() - 1 do
            AFKManager.SetPlayerActivity(playerid)
        end
    end

    if isPluginLoading and not AFKManager.timerID then
            AFKManager.Check()
            AFKManager.timerID = SetTimer(AFKManager.config["timer.interval"], AFKManager.Check)
        end
    isPluginLoading = nil
    isPluginLoadingLate = nil
end

---@param event Event
local function OnPluginStop(event)
    for playerid = 0, playermanager:GetPlayerCap() - 1 do
        AFKManager.ClearPlayerActivity(playerid)
    end
end

local function OnMapLoad(event, map)
    AFKManager:LoadConfig()

    if not isPluginLoading and not AFKManager.timerID then
        AFKManager.Check()
        AFKManager.timerID = SetTimer(AFKManager.config["timer.interval"], AFKManager.Check)
    end
end

local function OnMapUnload(event, map)
    if AFKManager.timerID then
        StopTimer(AFKManager.timerID)
        AFKManager.timerID = nil
    end
end

--- @param event Event
local function OnPlayerConnectFull(event)
    AFKManager.SetPlayerActivity(event:GetInt("userid"))
end

--- @param event Event
--- @param playerid number
--- @param key string
--- @param pressed boolean
local function OnClientKeyStateChange (event, playerid, key, pressed)
    AFKManager.SetPlayerActivity(playerid)
end

--- @param event Event
--- @param playerid number
--- @param command string
local function OnClientCommand(event, playerid, command)
    AFKManager.SetPlayerActivity(playerid)
end

--- @param event Event
local function OnPostPlayerShoot(event)
    AFKManager.SetPlayerActivity(event:GetInt("userid"))
end



AddEventHandler("OnPluginStart", OnPluginStart)
AddEventHandler("OnAllPluginsLoaded", OnAllPluginsLoaded)
AddEventHandler("OnPluginStop", OnPluginStop)
AddEventHandler("OnMapLoad", OnMapLoad)
AddEventHandler("OnMapUnload", OnMapUnload)
AddEventHandler("OnPlayerConnectFull", OnPlayerConnectFull)
AddEventHandler("OnClientKeyStateChange", OnClientKeyStateChange)
AddEventHandler("OnClientCommand", OnClientCommand)
AddEventHandler("OnPostPlayerShoot", OnPostPlayerShoot)
