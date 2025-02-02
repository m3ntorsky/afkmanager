AFKManager = {
    timerID = nil,
    config = {}
}
AFKManager.__index = AFKManager

local random = math.random 
function AFKManager:LoadConfig()
    config:Reload("afkmanager")
    
    self.config["prefix"] = tostring(config:Fetch("afkmanager.prefix")) or "{red}[AFK Manager]{default}"

    self.config["timer.interval"] = config:Fetch("afkmanager.timer.interval")

    self.config["immunity.enable"] = config:Fetch("afkmanager.immunity.enable") or true
    self.config["immunity.flags"] = config:Fetch("afkmanager.immunity.flags") or "z"

    if type(self.config["timer.interval"]) ~= "number" then
        self.config["timer.interval"] = 1
    end

    self.config["timer.interval"] = self.config["timer.interval"] * 1000

    self.config["move.enable"] = config:Fetch("afkmanager.move.enable") or true

    self.config["move.time"] = config:Fetch("afkmanager.move.time")

    if type(self.config["move.time"]) ~= "number" then
        self.config["move.time"] = 20
    end

    self.config["move.time"] = self.config["move.time"] * 1000

    self.config["kick.enable"] = config:Fetch("afkmanager.kick.enable") or true

    self.config["kick.time"] = config:Fetch("afkmanager.kick.time")

    if type(self.config["kick.time"]) ~= "number" then
        self.config["kick.time"] = 30
    end

    self.config["kick.time"] = self.config["kick.time"] * 1000
    
    self.config["warn.enable"] = config:Fetch("afkmanager.warn.enable") or true

    self.config["warn.time"] = config:Fetch("afkmanager.warn.time")

    if type(self.config["warn.time"]) == "number" then
        self.config["warn.time"] = self.config["warn.time"] * 1000
    elseif type(self.config["warn.time"]) == "table" then
        for k, v in next, self.config["warn.time"] do
            self.config["warn.time"][k] = v * 1000
        end 
    end

    self.config["slap.enable"] = config:Fetch("afkmanager.slap.enable") or true

    self.config["slap.time"] = config:Fetch("afkmanager.slap.time")

    if type(self.config["slap.time"]) == "number" then
        self.config["slap.time"] = self.config["slap.time"] * 1000
    elseif type(self.config["slap.time"]) == "table" then
        for k, v in next, self.config["slap.time"] do
            self.config["slap.time"][k] = v * 1000
        end 
    end

    self.config["slap.damage"] = tonumber(config:Fetch("afkmanager.slap.damage")) or 0

end

function AFKManager.Check()
    local currentTime = GetTime()
    for i = 0, playermanager:GetPlayerCap() - 1 do
        local player = GetPlayer(i)
        if not player or not player:IsValid() or player:IsFakeClient() then
            goto continue
        end

        if AFKManager.config["immunity.enable"] and exports["admins"]:HasFlags(player:GetSlot(), AFKManager.config["immunity.flags"]) then
            goto continue
        end

        local activeTime = player:GetVar("afkmanager.activity")
        if not activeTime then
            goto continue
        end

        local inactiveTime = currentTime - activeTime
        if AFKManager.config["move.enable"] then
            if inactiveTime > AFKManager.config["move.time"] and player:GetVar("afkmanager.moved") == false  then
                player:ChangeTeam(Team.Spectator)
                player:SetVar("afkmanager.moved", true)
            end
        end

        if AFKManager.config["kick.enable"] then
            if inactiveTime > AFKManager.config["kick.time"] then
                AFKManager.KickPlayer(player)
            end
        end

        if AFKManager.config["warn.enable"] then
            if type(AFKManager.config["warn.time"]) == "number" and inactiveTime > AFKManager.config["warn.time"] then
                AFKManager.WarnPlayer(player)
            elseif type(AFKManager.config["warn.time"]) == "table" then

                for k, v in next, AFKManager.config["warn.time"] do
                    local warnTimes = player:GetVar("afkmanager.warn")
                    if inactiveTime >= v and warnTimes <= k then
                        AFKManager.WarnPlayer(player)
                    end
                end

            end
        end

        if AFKManager.config["slap.enable"] then
            if type(AFKManager.config["slap.time"]) == "number" and inactiveTime > AFKManager.config["slap.time"] then
                AFKManager.SlapPlayer(player)
            elseif type(AFKManager.config["slap.time"]) == "table" then

                for k, v in next, AFKManager.config["slap.time"] do
                    local slapTimes = player:GetVar("afkmanager.slap")
                    if inactiveTime >= v and slapTimes <= k then
                        AFKManager.SlapPlayer(player)
                    end
                end

            end
        end

        ::continue::
    end
end

function AFKManager.SetPlayerActivity(playerid)
    local player = GetPlayer(playerid)

    if not player or not player:IsValid() or player:IsFakeClient() then
        return
    end
    local time =  GetTime()
    player:SetVar("afkmanager.activity", time)
    player:SetVar("afkmanager.warn", 0)
    player:SetVar("afkmanager.slap", 0)
    player:SetVar("afkmanager.moved", false)
end

function AFKManager.ClearPlayerActivity(playerid)
    local player = GetPlayer(playerid)

    if not player or not player:IsValid() or player:IsFakeClient() then
        return
    end
    player:SetVar("afkmanager.activity", nil)
    player:SetVar("afkmanager.warn", nil)
    player:SetVar("afkmanager.slap", nil)
    player:SetVar("afkmanager.moved", nil)
end

---@param player Player
function AFKManager.WarnPlayer(player)
    ReplyToCommand(player:GetSlot(), AFKManager.config["prefix"], FetchTranslation("afkmanager.warn", player:GetSlot()))
    local warnTimes = player:GetVar("afkmanager.warn")
    player:SetVar("afkmanager.warn", warnTimes+ 1 )
end

---@param player Player
function AFKManager.SlapPlayer(player)

    if not IsPlayerAlive(player) then return end
    local health = GetPlayerHealth(player)

    if health - AFKManager.config["slap.damage"] > 0 then
        local velocity = player:CBaseEntity().AbsVelocity
        velocity.x = velocity.x + random(50, 230) * (random(0, 1) == 1 and -1 or 1)
		velocity.y = velocity.y + random(50, 230) * (random(0, 1) == 1 and -1 or 1)
		velocity.z = velocity.z + random(100, 299)
        player:CBaseEntity().AbsVelocity = Vector(velocity.z, velocity.y, velocity.z)
        player:CBaseEntity().Health = health - AFKManager.config["slap.damage"]
    else
        AFKManager.SlayPlayer(player)
    end

end

---@param player Player
function AFKManager.SlayPlayer(player)

    if not IsPlayerAlive(player) then return end

    local pointHurtInstance = CreateEntityByName("point_hurt")

    if not pointHurtInstance or not pointHurtInstance:IsValid() then return end

    local pointHurt = CPointHurt(pointHurtInstance:ToPtr())

    if not pointHurt or not pointHurt:IsValid() then return end


    if not player:CBaseEntity() or not player:CBaseEntity():IsValid() then return end

    local playerEntityName = player:CBaseEntity().Parent.Entity.Name
    local slayEntityName = "player_slay"..player:GetSlot()
    player:CBaseEntity().Parent.Entity.Name = slayEntityName

    local health = GetPlayerHealth(player)

    pointHurt.Damage = health
    pointHurt.StrTarget = slayEntityName
	pointHurt.Parent.Parent:Spawn()
	pointHurt.Parent.Parent:AcceptInput("Hurt", player:CBaseEntity().Parent, pointHurt.Parent.Parent.Parent, "", 0)
	pointHurt.Parent.Parent:Despawn()    

    player:CBaseEntity().Parent.Entity.Name = playerEntityName

end

---@param player Player
function AFKManager.KickPlayer(player)
    ReplyToCommand(player:GetSlot(), AFKManager.config["prefix"], FetchTranslation("afkmanager.kick", player:GetSlot()))

    SetTimeout(1000, function()
        player:Drop(DisconnectReason.DisconnectByServer)
    end)
end