function modifier_item_sange_datadriven_on_attack_landed_random_on_success(keys)
	if keys.target.GetInvulnCount == nil then  --If the target is not a structure.
		keys.target:EmitSound("SoundBolno")
		keys.ability:ApplyDataDrivenModifier(keys.attacker, keys.target, "modifier_item_sange_datadriven_lesser_maim", nil)
	end
end
