function GetGold(keys)
	local caster = keys.caster
	local ability = keys.ability
	local talent = caster:FindAbilityByName("special_bonus_unique_ogre_magi_2")
	local talentj = caster:FindAbilityByName("special_bonus_unique_ogre_magi_3")
	local gold_min = ability:GetLevelSpecialValueFor("gold_gain_min", ability:GetLevel() - 1 )
	local gold_max = ability:GetLevelSpecialValueFor("gold_gain_max", ability:GetLevel() - 1 )
	
	

	
-- Игра в Джекпот	
	local js = 0 -- джекпот скипетр
	if caster:HasScepter() then
		js = ability:GetLevelSpecialValueFor("jackpot_scepter", ability:GetLevel() - 1 )
	end
	
	local jt = 0 -- джекпот талант
	if talentj:GetLevel() == 1 then
		jt = ability:GetLevelSpecialValueFor("jackpot_talent", ability:GetLevel() - 1 )
	end
	
	local jackchance = js + jt -- джекпот = 2 если есть талант и скипетр
	
	local rand = math.random(1, 100)
		
	if rand <= jackchance then
		caster:ModifyGold(99999, true, 1)
		EmitGlobalSound("SoundJackPot")
	end
		
-- Игра в казино
		if talent:GetLevel() == 1 then
			gold_max = ability:GetLevelSpecialValueFor("gold_gain_max_talent", ability:GetLevel() - 1 )
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