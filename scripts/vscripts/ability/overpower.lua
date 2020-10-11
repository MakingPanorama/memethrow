function overpower_init( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_enrage_buff_datadriven"
	local duration = ability:GetLevelSpecialValueFor( "duration_tooltip", ability:GetLevel() - 1 )
	local max_stack = ability:GetLevelSpecialValueFor( "max_attacks", ability:GetLevel() - 1 )
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, { duration = 6 } )
	caster:SetModifierStackCount( modifierName, ability, max_stack )

	if caster:HasScepter() then
		caster:RemoveModifierByName(modifierName)
		ability:ApplyDataDrivenModifier( caster, caster, modifierName, { duration = -1 } )
		caster:SetModifierStackCount( modifierName, ability, max_stack + 4 )
	end
end

--[[
	Author: kritth
	Date: 7.1.2015.
	Main: Decrease stack upon attack
]]
function overpower_decrease_stack( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_enrage_buff_datadriven"
	local current_stack = caster:GetModifierStackCount( modifierName, ability )

	if current_stack > 1 then
		caster:SetModifierStackCount( modifierName, ability, current_stack - 1 )
	else
		caster:RemoveModifierByName( modifierName )
	end
end