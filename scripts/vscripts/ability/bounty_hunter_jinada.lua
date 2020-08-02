function JinadaStart(keys)

	local ability = keys.ability
    local level = ability:GetLevel() - 1
    local cooldown = ability:GetCooldown(level)
    local caster = keys.caster
	local target = keys.target
    local modifier = keys.modifier
	
	local steal_gold = 0 - (target:GetGold() * keys.StealGold / 100)
	local get_gold = (target:GetGold() * keys.GetGoldSelf / 100)
	
		if caster:HasScepter() then
			local steal_gold = 0 - (target:GetGold() * keys.StealGoldScepter / 100)
			local get_gold = (target:GetGold() * keys.GetGoldScepter / 100)
		end
		
    local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
   
   if caster:IsRealHero() then
	  if target:IsRealHero() then
        ability:StartCooldown(cooldown)
        target:ModifyGold(steal_gold, true, 1)
        caster:ModifyGold(get_gold, true, 1)
		print("Enemy has " ..keys.target:GetGold())
        caster:RemoveModifierByName(modifier)
        ParticleManager:SetParticleControlEnt(midas_particle, 1, keys.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.caster:GetAbsOrigin(), false)
        keys.target:EmitSound("Hero_BountyHunter.Jinata")
        keys.target:EmitSound("DOTA_Item.Hand_Of_Midas")
		 print("You get gold" ..steal_gold)
    end
		else caster:RemoveModifierByName(modifier)
  end
    if target:IsCreep() then
        caster:RemoveModifierByName(modifier)
        keys.target:EmitSound("Hero_BountyHunter.Jinada")
        ability:StartCooldown(cooldown)
        ParticleManager:DestroyParticle(midas_particle, true)
    end
    Timers:CreateTimer(cooldown, function()
        ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
        end)
end