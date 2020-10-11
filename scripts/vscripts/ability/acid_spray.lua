function ApplyDPS(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local dmg = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1 )
	
	if caster:HasScepter() then
           ApplyDamage({victim = target, attacker = caster, damage = 250, damage_type = DAMAGE_TYPE_PURE})
		   else ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = ability:GetAbilityDamageType()})
    end
end

function ApplySound(keys)
	local caster = keys.caster
	
	
	if caster:HasScepter() then
	EmitGlobalSound("SoundAd2")
	else EmitGlobalSound("SoundAd")
	end

end	