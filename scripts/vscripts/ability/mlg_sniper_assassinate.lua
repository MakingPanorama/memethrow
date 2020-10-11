function MlgSniperKillOrDamage( keys )
	local caster = keys.caster
	local target = keys.target

	local damage = keys.ability:GetAbilityDamage()

	if RollPercentage( 30 ) then
		target:Kill( keys.ability, caster )
		EmitGlobalSound("SoundDmg")
	else
		ApplyDamage( { victim = target, attacker = caster, ability = keys.ability, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL  } )
	end
end