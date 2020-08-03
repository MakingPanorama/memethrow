--
-- Current Ability: Sonic Super Speed
---------

sonic_super_speed = sonic_super_speed or class({})

LinkLuaModifier("modifier_sonic_super_speed", "ability/sonic.lua", LUA_MODIFIER_MOTION_NONE)

function sonic_super_speed:GetIntrinsicModifierName()
	return "modifier_sonic_super_speed"
end

function sonic_super_speed:OnUpgrade()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sonic_super_speed", {})
end

--
-- Modifiers
-------

modifier_sonic_super_speed = modifier_sonic_super_speed or class({})

function modifier_sonic_super_speed:IsHidden() return true end
function modifier_sonic_super_speed:IsPassive() return true end
function modifier_sonic_super_speed:IsPermanent() return true end
function modifier_sonic_super_speed:IsPurgable() return true end
function modifier_sonic_super_speed:RemoveOnDeath() return false end

function modifier_sonic_super_speed:OnCreated()
	self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	self.max_movement_speed_limit = self:GetAbility():GetSpecialValueFor("max_movement_speed_limit")
end

function modifier_sonic_super_speed:OnRefresh()
	self.bonus_movement_speed = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	self.max_movement_speed_limit = self:GetAbility():GetSpecialValueFor("max_movement_speed_limit")
end

function modifier_sonic_super_speed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
end

function modifier_sonic_super_speed:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_sonic_super_speed:GetModifierMoveSpeed_Limit()
	return self.max_movement_speed_limit
end

function modifier_sonic_super_speed:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_movement_speed
end

function modifier_sonic_super_speed:GetEffectName()
	return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_sonic_super_speed:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

--
-- Current Ability: Sonic Time Deceleration(Not using)
--------

sonic_time_deceleration = sonic_time_deceleration or class({})
LinkLuaModifier("modifier_speed_in_time", "ability/sonic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_time_deceleration", "ability/sonic.lua", LUA_MODIFIER_MOTION_NONE)
function sonic_time_deceleration:OnSpellStart()
	local this_unit = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	EmitSoundOn("Hero_FacelessVoid.Chronosphere", self:GetCaster())
	for _,v in pairs(this_unit) do
		if v ~= self:GetCaster() then
			v:AddNewModifier(self:GetCaster(), self, "modifier_sonic_time_deceleration", { duration = self:GetSpecialValueFor("duration") })

			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_speed_in_time", { duration = self:GetSpecialValueFor("duration") })
		end
	end
end

modifier_sonic_time_deceleration = modifier_sonic_time_deceleration or class({})

function modifier_sonic_time_deceleration:IsHidden() return true end
function modifier_sonic_time_deceleration:IsPassive() return false end
function modifier_sonic_time_deceleration:IsPurgable() return false end

function modifier_sonic_time_deceleration:CheckState()
	return {
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_STUNNED] = true,
	}
end

modifier_speed_in_time = modifier_speed_in_time or class({})

function modifier_speed_in_time:IsHidden() return true end
function modifier_speed_in_time:IsPassive() return false end
function modifier_speed_in_time:IsPurgable() return false end

function modifier_speed_in_time:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
end
function modifier_speed_in_time:GetModifierMoveSpeed_Absolute()
	return 1200
end

function modifier_speed_in_time:GetEffectName()
	return "particles/units/heroes/hero_faceless_void/faceless_void_chrono_speed.vpcf"
end

sonic_magic_ring = sonic_magic_ring or class({})

function sonic_magic_ring:OnSpellStart()
	local target = self:GetCursorTarget()

	EmitSoundOn("Hero_Sonic.Coin", self:GetCaster())
	self.damage = self:GetSpecialValueFor("damage_in_health")

	local projectile = {
		Ability = self,
		Source = self:GetCaster(),
		Target = target,
		iMoveSpeed = 1200,
		bDodgeable = true,
		EffectName = "particles/econ/items/terrorblade/terrorblade_ti9_immortal/terrorblade_ti9_immortal_metamorphosis_base_attack.vpcf",
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projectile )
end

function sonic_magic_ring:OnProjectileHit(hTarget, vLocation)
	if hTarget:TriggerSpellAbsorb( self ) then return end
	FindClearSpaceForUnit(self:GetCaster(), hTarget:GetAbsOrigin(), true)
	ProjectileManager:ProjectileDodge( self:GetCaster() )
	local damage_table = {
		victim = hTarget,
		attacker = self:GetCaster(),
		ability = self,
		damage = hTarget:GetMaxHealth() * self.damage / 100,
		damage_type = DAMAGE_TYPE_PURE
	}

	local knockbackModifierTable =
	{
		should_stun = 0,
		knockback_duration = 0.5,
		duration = 0.5,
		knockback_distance = 100 ,
		knockback_height = 250,
		center_x = self:GetCaster():GetAbsOrigin().x,
		center_y = self:GetCaster():GetAbsOrigin().y,
		center_z = self:GetCaster():GetAbsOrigin().z
	}

	EmitSoundOn("Hero_Sonic.Coin_Loss", hTarget)
	hTarget:AddNewModifier( self:GetCaster(), nil, "modifier_knockback", knockbackModifierTable )
	ApplyDamage( damage_table )
	ApplyGenericStun( hTarget, self:GetCaster(), self, self:GetSpecialValueFor("duration_stun") )


end

sonic_form_in_horror = sonic_form_in_horror or class({})
LinkLuaModifier("modifier_form_check", "ability/sonic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_form_change", "ability/sonic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_night_wings", "ability/sonic.lua", LUA_MODIFIER_MOTION_NONE)

function sonic_form_in_horror:GetIntrinsicModifierName()
	return "modifier_form_check"
end

function sonic_form_in_horror:GetBehavior()
	if self:GetCaster():HasModifier("modifier_form_change") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end

	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function sonic_form_in_horror:GetCooldown(iLevel)
	if self:GetCaster():HasModifier("modifier_form_change") then
		return 12.0
	end
	return 0
end

function sonic_form_in_horror:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_night_wings", { duration = 6 })
end

modifier_night_wings = modifier_night_wings or class({})

function modifier_night_wings:IsHidden() return false end function modifier_night_wings:IsPassive() return false end function modifier_night_wings:IsPurgable() return false end

function modifier_night_wings:CheckState()
	return {
		[MODIFIER_STATE_FLYING] = true,
	}
end

function modifier_night_wings:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}
end

function modifier_night_wings:GetActivityTranslationModifiers()
	return "hunter_night"
end

modifier_form_check = modifier_form_check or class({})

function modifier_form_check:IsHidden() return true end function modifier_form_check:IsPassive() return true end function modifier_form_check:IsPurgable() return false end

function modifier_form_check:OnCreated()
	self:StartIntervalThink( FrameTime() )
end

function modifier_form_check:OnIntervalThink()
	if not GameRules:IsDaytime() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_form_change", {})
	else
		self:GetCaster():RemoveModifierByName("modifier_form_change")
	end
end

function modifier_night_wings:OnDestroy()
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 200, false)
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 200, false)
end

modifier_form_change = modifier_form_change or class({})

function modifier_form_change:IsHidden() return true end function modifier_form_change:IsPassive() return true end function modifier_form_change:IsPurgable() return false end

function modifier_form_change:OnCreated()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")

	self.limit = 0

	if self.limit < 1 then
		self.wings = SpawnEntityFromTableSynchronous("prop_dynamic", { model = "models/heroes/nightstalker/nightstalker_wings_night.vmdl" })

		self.wings:FollowEntity(self:GetParent(), true)
		self.limit = self.limit + 1
	end
end

function modifier_form_change:OnRefresh()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_form_change:OnDestroy()
	UTIL_Remove( self.wings )
end

function modifier_form_change:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_CHANGE
	}
end

function modifier_form_change:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_form_change:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_form_change:GetModifierModelChange()
	return "models/heroes/nightstalker/nightstalker_night.vmdl"
end

function modifier_form_change:GetModifierMoveSpeedBonus_Percentage()
	return 100
end

function modifier_form_change:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

sonic_scream_meow = sonic_scream_meow or class({})

function sonic_scream_meow:OnAbilityPhaseStart()
	EmitSoundOn("Hero_Sonic.Meow", self:GetCaster())
	return true
end

function sonic_scream_meow:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_Sonic.Meow")
end

function sonic_scream_meow:OnSpellStart()
	local caster = self:GetCaster()
	local pind = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local meow_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_scream_of_pain_owner.vpcf", PATTACH_POINT, self:GetCaster())

	ParticleManager:SetParticleControl(meow_particle, 1, Vector(300,300,0))
	self.duration = self:GetSpecialValueFor("duration")


	for _,unit in ipairs(pind) do
		local damage_table = {
			victim = unit,
			attacker = caster,
			ability = self,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = DAMAGE_TYPE_PURE
		}

		ApplyDamage( damage_table )
		unit:AddNewModifier(self:GetCaster(), self, "modifier_screamed_custom", { duration = self.duration })
	end
end
