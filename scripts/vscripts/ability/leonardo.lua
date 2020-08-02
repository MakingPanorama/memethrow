function Damagedeal( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local damage = ability:GetSpecialValueFor("damages")
	local damage_pct = ability:GetSpecialValueFor("damage_pct")
	if caster:HasScepter() then
		 damage_pct = ability:GetSpecialValueFor("damage_pct_scepter")
	end
	
	local cdamage = caster:GetAttackDamage()

		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		damage_table.ability = ability
		damage_table.damage = damage + ( cdamage * damage_pct)

		ApplyDamage(damage_table)
	
end