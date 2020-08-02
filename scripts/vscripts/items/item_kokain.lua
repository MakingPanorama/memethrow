function MinusInt(keys)
	local caster = keys.caster
	if not caster:IsHero() then
		return
	end
	local ability = keys.ability
	local int = keys.int
		
		caster:ModifyIntellect(int)
		caster.Additional_int = (caster.Additional_int or 0) + int
end


function MinusCharge(keys)
    local ability = keys.ability
	local caster = keys.caster
	
	ability:SpendCharge()
end

