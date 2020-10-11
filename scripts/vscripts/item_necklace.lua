LinkLuaModifier("modifier_item_necklace", "item_necklace.lua", LUA_MODIFIER_MOTION_NONE)
item_necklace_lua = item_necklace_lua or class({})


function item_necklace_lua:GetIntrinsicModifierName()

	return "modifier_item_necklace" 

end

modifier_item_necklace = modifier_item_necklace or class({})

function modifier_item_necklace:IsHidden()			return true 
end

function modifier_item_necklace:IsPurgable()		return false 
end

function modifier_item_necklace:RemoveOnDeath()		return false
end

function modifier_item_necklace:GetAttributes()		return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_item_necklace:DeclareFunctions()
	
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE
	}
end

function modifier_item_necklace:GetModifierBonusStats_Intellect(params)
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_necklace:GetModifierSpellAmplify_Percentage(params)
	return self:GetAbility():GetSpecialValueFor("spell_power")
end

function modifier_item_necklace:GetModifierManaBonus(params)
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_necklace:GetModifierCastRangeBonus(params)
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end

function modifier_item_necklace:GetModifierPercentageManacost(params)
	return self:GetAbility():GetSpecialValueFor("manacost")
end


function modifier_item_necklace:GetModifierConstantManaRegen(params)
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end