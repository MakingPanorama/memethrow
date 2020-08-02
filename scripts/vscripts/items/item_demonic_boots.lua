item_demonic_boots = item_demonic_boots or class({})

LinkLuaModifier("modifier_demonic_boots", "items/item_demonic_boots.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_demonic_boots_passive", "items/item_demonic_boots.lua", LUA_MODIFIER_MOTION_NONE)

function item_demonic_boots:GetIntrinsicModifierName()
	return "modifier_demonic_boots_passive"
end

function item_demonic_boots:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_demonic_boots", { duration = 3 })

	EmitSoundOn("DOTA_Item.PhaseBoots.Activate", self:GetCaster())
end

function item_demonic_boots:GetAbilityTextureName()
	return "demonic_boots"
end

modifier_demonic_boots = modifier_demonic_boots or class({})

function modifier_demonic_boots:IsHidden() return false end
function modifier_demonic_boots:IsPassive() return false end
function modifier_demonic_boots:IsDebuff() return false end

function modifier_demonic_boots:GetEffectName()
	return "particles/econ/events/ti10/phase_boots_ti10.vpcf"
end

function modifier_demonic_boots:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_demonic_boots:OnCreated()
	self.phase_movement_speed = self:GetAbility():GetSpecialValueFor("phase_movement_speed")
	self.phase_movement_speed_range = self:GetAbility():GetSpecialValueFor("phase_movement_speed_range")

	self.bonus_turn_rate = self:GetAbility():GetSpecialValueFor("turn_rate")
end

function modifier_demonic_boots:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,

		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
end

function modifier_demonic_boots:CheckState()
	return {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end

function modifier_demonic_boots:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_demonic_boots:GetModifierMoveSpeed_Limit()
	if self:GetParent():GetUnitName() == "npc_dota_hero_pangolier" then
		return nil
	end
	return 660
end

function modifier_demonic_boots:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():IsRangedAttacker() then
		return  self.phase_movement_speed_range
	end
	return self.phase_movement_speed
end

function modifier_demonic_boots:GetModifierTurnRate_Percentage()
	return self.bonus_turn_rate
end

modifier_demonic_boots_passive = modifier_demonic_boots_passive or class({})

function modifier_demonic_boots_passive:IsHidden() return true end
function modifier_demonic_boots_passive:IsPassive() return true end
function modifier_demonic_boots_passive:OnCreated()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")

	self.movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")

	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_demonic_boots_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_demonic_boots_passive:GetModifierMoveSpeedBonus_Constant()
	return self.movement_speed
end

function modifier_demonic_boots_passive:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_demonic_boots_passive:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end