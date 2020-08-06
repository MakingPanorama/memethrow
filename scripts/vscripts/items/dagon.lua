function Dagon( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local particle = "particles/item/dagon/dagon.vpcf"
	local damage = ability:GetSpecialValueFor("damage_tooltip")

	local dagon_pfx = ParticleManager:CreateParticle(particle, PATTACH_RENDERORIGIN_FOLLOW, source)
	ParticleManager:SetParticleControlEnt(dagon_pfx, 0, source, PATTACH_POINT_FOLLOW, "attach_attack1", source:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(dagon_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	ParticleManager:SetParticleControl(dagon_pfx, 2, Vector(damage, 0, 0))
	ParticleManager:SetParticleControl(dagon_pfx, 3, color)
	ParticleManager:ReleaseParticleIndex(dagon_pfx)

	ApplyDamage( {
		victim = target,
		attacker = caster,
		ability = ability,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	} )
end
