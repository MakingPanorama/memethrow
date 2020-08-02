function Purge(keys)
	local caster = keys.caster
	local ability = keys.ability
	local model_scale = ability:GetLevelSpecialValueFor( "model_scale", ability:GetLevel() - 1 )
	
	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	
	caster:SetModelScale(1)
	caster:SetRenderColor(255, 255, 0)
end


function ChangeAppearance(keys)
	local caster = keys.caster

	caster:SetModelScale(0.74)
	caster:SetRenderColor(255, 255, 255)
end