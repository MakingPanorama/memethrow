function modifier_item_sange_datadriven_on_attack_landed_random_on_success(keys)
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		
		local rand = RandomFloat(1, 30)
		if (rand >=1 and rand <= 10) then
				keys.target:EmitSound("SoundKrik1")
		elseif (rand >10 and rand <= 20) then
				keys.target:EmitSound("SoundKrik2")
		elseif (rand >20 and rand <= 30) then
				keys.target:EmitSound("SoundKrik3")
		end
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_sange_datadriven_lesser_maim", nil)
	end
end