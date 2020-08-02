function GetGold(keys)
	local caster = keys.caster
	local ability = keys.ability
	local gold_min = ability:GetLevelSpecialValueFor("gold_gain_min", ability:GetLevel() - 1 )
	local gold_max = ability:GetLevelSpecialValueFor("gold_gain_max", ability:GetLevel() - 1 )
	local jackchance = ability:GetLevelSpecialValueFor("jackpot_chance", ability:GetLevel() - 1 )
	local rand = math.random(1, 100)
	
	if caster:HasScepter() then
		if rand <= jackchance then
			caster:ModifyGold(99999, true, 1)
			EmitGlobalSound("SoundJackPot")
		end
		
		
	end
		
		
		local random = RandomFloat(0, 1)
		local gold = gold_min + (gold_max - gold_min) * random
		
		if caster:HasScepter() then
			gold = (gold_max) * random
		end
		
		
		caster:ModifyGold(gold, true, 1)
		if gold <= 0 then 
		caster:EmitSound("SoundLose")
			else caster:EmitSound("SoundWin")
		end
end


function GetJack(keys)
	
	local caster = keys.caster
	local ability = keys.ability
	local jackchance = ability:GetLevelSpecialValueFor("jackpot_chance", ability:GetLevel() - 1 )
	
	
	
	local rand = math.random(1, 100)

       if rand <= jackchance then
			caster:ModifyGold(99999, true, 1)
			EmitGlobalSound("SoundJackPot")
		end

end