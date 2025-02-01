function IsPlayerAlive(player)
	
	if not player or not player:IsValid() then
		return false
	end
	
	local playerLifeState = player:CBaseEntity().LifeState
	
	if playerLifeState ~= LifeState_t.LIFE_ALIVE then
		return false
	end
	
	return true
end


function GetPlayerHealth(player)

	if not player or not player:IsValid() then
		return 0
	end
	
	return player:CBaseEntity().Health
end