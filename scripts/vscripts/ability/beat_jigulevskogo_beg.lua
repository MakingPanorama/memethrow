function ExtraData( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 1800 * 1/30
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin() 
end	

function HorizontalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 3000 then
    	caster:InterruptMotionControllers(true)
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
    else
        caster:InterruptMotionControllers(true)

        -- Move the caster to the ground
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    end
end

function VerticalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)


    if caster_loc.z <= caster_loc_ground.z then
    	caster:SetAbsOrigin(caster_loc_ground)
    end

	if ability.traveled_distance < ability.initial_distance / 2 then
		ability.z = ability.z + ability.speed_traveling / 2
		caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.z))
	elseif caster_loc.z > caster_loc_ground.z then
		ability.z = ability.z - ability.speed_traveling / 2
		caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.z))
	end
end
function ExtraData( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 1800 * 1/30
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin() 
end	

function HorizontalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 3000 then
    	caster:InterruptMotionControllers(true)
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
    else
        caster:InterruptMotionControllers(true)

        -- Move the caster to the ground
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    end
end
