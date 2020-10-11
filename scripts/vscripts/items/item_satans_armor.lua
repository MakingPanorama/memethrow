item_satans_armor = item_satans_armor or class({})

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

LinkLuaModifier('modifier_satans_armor_passive', 'items/item_satans_armor.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_satans_armor_active', 'items/item_satans_armor.lua', LUA_MODIFIER_MOTION_NONE)

function item_satans_armor:GetIntrinsicModifierName()
	return "modifier_satans_armor_passive"
end

function item_satans_armor:GetAbilityTextureName()
	return "satans_armor"
end

function item_satans_armor:OnSpellStart()
	local radius = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_satans_armor_active", { duration = self:GetSpecialValueFor('duration') })
	EmitSoundOn(AbilityKV[self:GetName()]["AbilityCastSound"], self:GetCaster())
	for _,units in pairs(radius) do
		units:AddNewModifier(self:GetCaster(), self, "modifier_satans_armor_active", { duration = self:GetSpecialValueFor('duration') })
	end
end

modifier_satans_armor_passive = modifier_satans_armor_passive or class({})

function modifier_satans_armor_passive:IsHidden() return true end function modifier_satans_armor_passive:IsPassive() return true end function modifier_satans_armor_passive:IsPurgable() return false end

function modifier_satans_armor_passive:OnCreated()
	self.health_regen_bonus = self:GetAbility():GetSpecialValueFor('health_regen_bonus')
	self.health_bonus = self:GetAbility():GetSpecialValueFor('health_bonus')
	self.armor_bonus = self:GetAbility():GetSpecialValueFor('armor_bonus')
	self.attack_damage_bonus = self:GetAbility():GetSpecialValueFor('attack_damage_bonus')
end

function modifier_satans_armor_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_satans_armor_passive:GetModifierHealthBonus()
	return self.health_bonus
end
function modifier_satans_armor_passive:GetModifierConstantHealthRegen()
	return self.health_regen_bonus
end
function modifier_satans_armor_passive:GetModifierPhysicalArmorBonus()
	return self.armor_bonus
end
function modifier_satans_armor_passive:GetModifierPreAttack_BonusDamage()
	return self.attack_damage_bonus
end

modifier_satans_armor_active = modifier_satans_armor_active or class({})

function modifier_satans_armor_active:IsHidden() return false end function modifier_satans_armor_active:IsPassive() return false end function modifier_satans_armor_active:IsPurgable() return false end
function modifier_satans_armor_active:GetTexture() return "item_satans_armor" end

function modifier_satans_armor_active:OnCreated()
	self.armor_bonus = self:GetAbility():GetSpecialValueFor('armor_bonus')
	self.block_damage = -17
end

function modifier_satans_armor_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_satans_armor_active:GetModifierIncomingDamage_Percentage()
	return self.block_damage
end

function modifier_satans_armor_active:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end