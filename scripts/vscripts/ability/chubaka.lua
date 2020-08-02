function NoIllusionBash(keys)

	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
		
	 if caster:IsRealHero() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_bash_stun_datadriven", {})
		caster:EmitSound("SoundBash")
	 end

end

--
-- Current Ability: Chubaka Extra Armor
-------

chubaka_extra_armor = chubaka_extra_armor or class({})

LinkLuaModifier("modifier_reflect_damage", "ability/chubaka.lua", LUA_MODIFIER_MOTION_NONE)

function chubaka_extra_armor:GetIntrinsicModifierName()
	return "modifier_reflect_damage"
end

modifier_reflect_damage = modifier_reflect_damage or class({})

function modifier_reflect_damage:IsHidden() return true end
function modifier_reflect_damage:IsPassive() return true end

function modifier_reflect_damage:DeclareFunctions()
	local properties = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return properties
end

function modifier_reflect_damage:OnTakeDamage( params )

	local ability = self:GetAbility()
	self.bonus_reflect_damage = ability:GetSpecialValueFor("bonus_reflect_damage")
	self.reflect_percent = ability:GetSpecialValueFor("reflect_damage_percent")
	self.chance = ability:GetSpecialValueFor("chance_reflect")

	if not IsServer() then return end

	if params.unit == self:GetParent() and not params.attacker:IsBuilding() and params.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and not self:GetParent():FindItemInInventory("item_blade_mail") then
		local damage = self.bonus_reflect_damage + (params.damage / 100 * self.reflect_percent)
		print("Return damage:", damage)
		ApplyDamage({
			victim = params.attacker,
			attacker = params.unit,
			damage = params.damage,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
		})

		if RollPercentage( self.chance ) then
			local damage = self.bonus_reflect_damage + (params.damage / 100 * self.reflect_percent)
			print("Return damage:", damage)
			ApplyDamage({
			victim = params.attacker,
			attacker = params.unit,
			damage = params.damage,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags	= DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
			EmitSoundOn("SoundBash", params.unit)
			print("Damage fully reflected!")
		end
	end
end

function modifier_reflect_damage:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

-- 1 skill chubaka_earthshock
--------------------------------------------
chubaka_earthshock = chubaka_earthshock or class({})

LinkLuaModifier("modifier_extra_slow", "ability/chubaka.lua", LUA_MODIFIER_MOTION_NONE)

function chubaka_earthshock:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("shock_radius_scepter")
	end
	return self.BaseClass.GetCastRange( self ,vLocation, hTarget)
end

function chubaka_earthshock:GetCastPoint()
	return 0.69
end

function chubaka_earthshock:GetCastAnimation()
	if self:GetCaster():HasScepter() then
		return ACT_DOTA_CAST_ABILITY_1
	else return ACT_DOTA_CAST_ABILITY_2
	end
end

function chubaka_earthshock:OnSpellStart()
	local caster = self:GetCaster()

	self.radius = self:GetSpecialValueFor("shock_radius")
	self.scepter_radius = self:GetSpecialValueFor("shock_radius_scepter")
	self.damage = self:GetSpecialValueFor("ability_damage")
	self.damage_scepter = self:GetSpecialValueFor("damage_scepter")
	self.duration = self:GetSpecialValueFor("shock_extra_slow_duration")
	self.stun_duration = self:GetSpecialValueFor("stun_duration")

	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false) -- Первое получаем число команды, второе позицию кастеру, кеш юнита хз просто nil, радиус, команда на которых будет работать это, и тип цели, флаги, хз, и это тоже
	local units_scepter = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.scepter_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local chubaka_earthshock = ParticleManager:CreateParticle("particles/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, self:GetCaster())

	 -- x,y = как раз чтобы изменить размер партикла, z = высота партикла юзается для зевса и других.
	EmitSoundOn("SoundRik", self:GetCaster())
	if self:GetCaster():HasScepter() then
		ParticleManager:SetParticleControl(chubaka_earthshock, 1, Vector(self.scepter_radius,self.scepter_radius,0 ))
		for _,unit in ipairs( units_scepter ) do -- ищет юнитов здесь, а табло будет unit
			local damage_table = {
				victim = unit,
				attacker = self:GetCaster(),
				ability = self, -- optional
				damage = self.damage_scepter,
				damage_type = DAMAGE_TYPE_PHYSICAL
			}
			ApplyDamage( damage_table )
			unit:AddNewModifier(self:GetCaster(), self, "modifier_extra_slow", { duration = self.duration })
			unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", { duration = self.stun_duration })
		end 
	else
		ParticleManager:SetParticleControl(chubaka_earthshock, 1, Vector(self.radius,self.radius,0 ))
		for _,unit in ipairs( units ) do
			local damage_table = {
				victim = unit,
				attacker = self:GetCaster(),
				ability = self, -- optional
				damage = self.damage,
				damage_type = DAMAGE_TYPE_PHYSICAL
			}
			ApplyDamage( damage_table )
			unit:AddNewModifier(self:GetCaster(), self, "modifier_extra_slow", { duration = self.duration })
			unit:AddNewModifier(self:GetCaster(), self, "modifier_stunned", { duration = self.stun_duration })
		end
	end
end

modifier_extra_slow = modifier_extra_slow or class({})

function modifier_extra_slow:IsHidden() return false end
function modifier_extra_slow:IsPassive() return false end
function modifier_extra_slow:IsPurgable() return true end
function modifier_extra_slow:RemoveOnDeath() return true end

function modifier_extra_slow:OnCreated()
	local ability = self:GetAbility()

	-- Через это мы будем возращать, это можно где угодно возращать(в любой функции)
	self.slow_movespeed = ability:GetSpecialValueFor("shock_extra_slow")
	self.slow_attackspeed = ability:GetSpecialValueFor("shock_attack_slow_tooltip")
end

function modifier_extra_slow:DeclareFunctions() -- Property и ивенты на все остальное
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_extra_slow:GetModifierMoveSpeedBonus_Constant()
	return self.slow_movespeed
end

function modifier_extra_slow:GetModifierAttackSpeedBonus_Constant()
	return self.slow_attackspeed
end

--
-- Current Ability: Chubaka Rage
-------

chubaka_rage = chubaka_rage or class({})

LinkLuaModifier("modifier_chubaka_rage", "ability/chubaka.lua", LUA_MODIFIER_MOTION_NONE)

function chubaka_rage:GetCooldown( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_cooldown")
	end
	return self.BaseClass.GetCooldown( self, level )
end

function chubaka_rage:OnSpellStart()
	self.duration = self:GetSpecialValueFor("duration")

	EmitSoundOn("SoundChubaka", self:GetCaster())

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_chubaka_rage", { duration = self.duration })
end

--
-- Modifiers
-------

modifier_chubaka_rage = modifier_chubaka_rage or class({})

function modifier_chubaka_rage:IsHidden() return false end
function modifier_chubaka_rage:IsPassive() return false end
function modifier_chubaka_rage:IsPurgable() return false end
function modifier_chubaka_rage:OnCreated()
	local ability = self:GetAbility()

	self.bonus_damage_scepter = ability:GetSpecialValueFor("bonus_damage_scepter")
	self.bonus_damage = ability:GetSpecialValueFor("bonus_damage")
	self.damage_reduction = ability:GetSpecialValueFor("damage_reduction")
	self.movement_speed_bonus = ability:GetSpecialValueFor("bonus_movement_speed")
	self.bonus_attack_speed_scepter = ability:GetSpecialValueFor("bonus_attack_speed")
	self.status_resistance = ability:GetSpecialValueFor("status_resistance")

	self:GetCaster():SetModelScale(1.5)
	self:GetCaster():SetRenderColor(150, 75, 0)

end

function modifier_chubaka_rage:OnDestroy()
	self:GetCaster():SetModelScale(1.15000)
	self:GetCaster():SetRenderColor(255, 255, 255)
end

function modifier_chubaka_rage:DeclareFunctions()
	local prop = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE
	}
	return prop
end

function modifier_chubaka_rage:GetModifierPreAttack_BonusDamage()
	if self:GetCaster():HasScepter() then
		return self.bonus_damage_scepter
	end
	return self.bonus_damage
end

function modifier_chubaka_rage:GetModifierStatusResistance()
	if self:GetCaster():HasScepter() then
		return self.status_resistance_scepter
	end
	return self.status_resistance
end

function modifier_chubaka_rage:GetModifierIncomingDamage_Percentage()
	return self.damage_reduction
end

function modifier_chubaka_rage:GetModifierMoveSpeedBonus_Constant()
	return self.movement_speed_bonus
end

function modifier_chubaka_rage:GetModifierAttackSpeedBonus_Constant()
	if self:GetCaster():HasScepter() then
		return self.bonus_attack_speed_scepter
	end
	return 0
end

function modifier_chubaka_rage:GetModifierAttackRangeBonus()
	return 50
end
