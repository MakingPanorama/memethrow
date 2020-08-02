function ApplyModifiers(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stacks = ability:GetLevelSpecialValueFor( "instances", ability:GetLevel() - 1 )
	
	if caster:HasScepter() then
           stacks = ability:GetLevelSpecialValueFor("instances_scepter", ability:GetLevel() - 1 )
    end
	
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_damage_absorb", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage", {})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage_visual", {})
	caster:SetModifierStackCount("modifier_damage_absorb", ability, stacks)
	caster:SetModifierStackCount("modifier_bonus_damage_visual", ability, stacks)
	
	
	
	if caster:HasScepter() then
           caster:RemoveModifierByName("modifier_damage_absorb")
		   caster:RemoveModifierByName("modifier_bonus_damage")
		   caster:RemoveModifierByName("modifier_bonus_damage_visual")
		   
		   
		   ability:ApplyDataDrivenModifier(caster, caster, "modifier_damage_absorb_scepter", {})
		   ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage_scepter", {})
		   ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_damage_visual_scepter", {})
    end
	
	ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(ability.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(ability.particle, 3, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
end

function RemoveDamageAbsorbStack(keys)
	local caster = keys.caster
	local ability = keys. ability
	local modifier = "modifier_damage_absorb"
	local damage_threshold = ability:GetLevelSpecialValueFor( "damage_threshold", ability:GetLevel() - 1 )
	local damage = keys.damage
	local stacks = caster:GetModifierStackCount(modifier, ability)
	
	
	if caster:HasScepter() then
		modifier  = "modifier_damage_absorb_scepter"
    end
	
	if caster:HasModifier(modifier) then
		
		if damage >= damage_threshold then
			
			caster:SetHealth(caster:GetHealth() + damage)
				
			caster:SetModifierStackCount(modifier, ability, stacks - 1)
			stacks = caster:GetModifierStackCount(modifier, ability)
	
	
			if stacks == 0 then
				caster:RemoveModifierByName(modifier)
			end
			
		
			EmitSoundOn(keys.sound, caster)
		end
	else
		
		ParticleManager:DestroyParticle(ability.particle, true)
	end
end


function RemoveDamageAbsorbStackScepter(keys)
	local caster = keys.caster
	local ability = keys. ability
	local modifier = "modifier_damage_absorb_scepter"
	local damage_threshold = ability:GetLevelSpecialValueFor( "damage_threshold_scepter", ability:GetLevel() - 1 )
	local damage = keys.damage
	local stacks = ability:GetLevelSpecialValueFor("instances_scepter", ability:GetLevel() - 1 )
	
	
	if caster:HasScepter() then
		modifier  = "modifier_damage_absorb_scepter"
    end
	
	if caster:HasModifier(modifier) then
		
		if damage >= damage_threshold then
			
			caster:SetHealth(caster:GetHealth() + damage)
				
			caster:SetModifierStackCount(modifier, ability, stacks - 1)
			stacks = caster:GetModifierStackCount(modifier, ability)
	
	
			if stacks == 0 then
				caster:RemoveModifierByName(modifier)
			end
			
		
			EmitSoundOn(keys.sound, caster)
		end
	else
		ParticleManager:DestroyParticle(ability.particle, true)
	end
end


function RemoveBonusDamageStack(keys)
	local caster  = keys.caster
	local ability = keys. ability
	local modifier = "modifier_bonus_damage_visual"
	local stacks = caster:GetModifierStackCount(modifier, ability)
	

	caster:SetModifierStackCount(modifier, ability, stacks - 1)
	stacks = caster:GetModifierStackCount(modifier, ability)
	
	if stacks == 0 then
		caster:RemoveModifierByName(modifier)
		caster:RemoveModifierByName("modifier_bonus_damage")
	end
end