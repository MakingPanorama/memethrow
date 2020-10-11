function ExtraData( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 2800 * 1/30
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_anim_change", {})
end	

function HorizontalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 4000 then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
        caster:MoveToPosition(target:GetOrigin())
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName("modifier_anim_change")

        -- Move the caster to the ground
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end
end