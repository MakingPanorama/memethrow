function CreateMeIllusion( keys )
	local caster = keys.caster
	local ability = keys.ability
	local talent = caster:FindAbilityByName("special_bonus_unique_omniknight_1")
	local talentsec = caster:FindAbilityByName("special_bonus_unique_omniknight_2")

	if ability.phantasm_illusions then
		for _, illusion in pairs(ability.phantasm_illusions) do
			if illusion and not illusion:IsNull() then
				illusion:ForceKill(false)
			end
		end
	end

	ability.phantasm_illusions = {}

	if talent:GetLevel() == 1 then
       local modifierKeys = {
		outgoing_damage = 0,
		incoming_damage = 100,
		duration = 20
		}
	else
		local modifierKeys = {
		outgoing_damage = -50,
		incoming_damage = 100,
		duration = 20
		}
	end

	if talentsec:GetLevel() == 1 then
		local illusions = CreateIllusions( caster, caster, modifierKeys, 6, 20, true, true )
	else
		local illusions = CreateIllusions( caster, caster, modifierKeys, 3, 20, true, true )
	end
	
	for _, illusion in pairs( illusions ) do
		table.insert(ability.phantasm_illusions, illusion)
	end
end