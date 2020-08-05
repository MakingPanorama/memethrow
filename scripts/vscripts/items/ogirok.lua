function AddStat(keys) -- Just datadriven here nothing.
	local caster = keys.caster
	if not caster:IsHero() then
		return
	end
	if keys.str then
		local ability = keys.ability
		local strength_count = caster:GetModifierStackCount("modifier_bonus_strength_stackable", ability)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_strength_stackable", {})
		caster:SetModifierStackCount("modifier_bonus_strength_stackable", ability, strength_count + 1)
	end
	if keys.agi then
		local ability = keys.ability
		local agility_count = caster:GetModifierStackCount("modifier_bonus_agility_stackable", ability)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_agility_stackable", {})
		caster:SetModifierStackCount("modifier_bonus_agility_stackable", ability, agility_count + 1)
	end
	if keys.int then
		local ability = keys.ability
		local intellect_count = caster:GetModifierStackCount("modifier_bonus_intellect_stackable", ability)

		ability:ApplyDataDrivenModifier(caster, caster, "modifier_bonus_intellect_stackable", {})
		caster:SetModifierStackCount("modifier_bonus_intellect_stackable", ability, intellect_count + 1)
	end
end