--
-- Current Ability: Hell
---------
hell_lua = hell_lua or class({})

LinkLuaModifier("modifier_hell_aura", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hell", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_all_can_see_hellish_racer", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

function hell_lua:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("radius_scepter")
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end

function hell_lua:GetAbilityDamage()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("damage_scepter")
	end

	return self:GetSpecialValueFor("damage")
end

function hell_lua:GetAbilityDamageType()
	if self:GetCaster():HasScepter() then
		return DAMAGE_TYPE_PURE
	end
	return DAMAGE_TYPE_PHYSICAL
end

function hell_lua:OnSpellStart()
	local particle = ParticleManager:CreateParticle("particles/alchemist_acid_spray.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	
	-- Ability Special
	self.radius = self:GetSpecialValueFor("radius")
	self.scepter_radius = self:GetSpecialValueFor("radius_scepter")
	self.duration = self:GetSpecialValueFor("duration")

	if self:GetCaster():HasScepter() and self:GetCaster():IsAlive() then
		ParticleManager:SetParticleControl(particle, 1, Vector(self.scepter_radius,self.scepter_radius,0))
	else
		ParticleManager:SetParticleControl(particle, 1, Vector(self.radius,self.radius,0))
	end

	Timers:CreateTimer(self.duration, function()
		ParticleManager:DestroyParticle(particle, false)
	end)

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_hell_aura", { duration = self.duration })
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_all_can_see_hellish_racer", { duration = self.duration })
	local random = RandomInt(1, 2)

	if random == 1 then
		EmitGlobalSound( "SoundAd2" )
	elseif random == 2 then
		EmitGlobalSound( "SoundAd" )
	end

	Timers:CreateTimer(function()
		if not self:GetCaster():IsAlive() then
			ParticleManager:DestroyParticle(particle, false)
			StopGlobalSound( "SoundAd" )
			StopGlobalSound( "SoundAd2" )
			self:GetCaster():RemoveModifierByName("modifier_hell_aura")
		end
		return 0.1
	end)

end

--
-- Modifiers
---------

modifier_hell_aura = modifier_hell_aura or class({})

function modifier_hell_aura:IsHidden() return true end
function modifier_hell_aura:IsPassive() return false end
function modifier_hell_aura:IsAura() return true end
function modifier_hell_aura:RemoveOnDeath() return true end
function modifier_hell_aura:GetAuraRadius() 
	if self:GetCaster():HasScepter() then
		return self:GetAbility():GetSpecialValueFor("radius_scepter")
	end

	return self:GetAbility():GetSpecialValueFor("radius")
end
function modifier_hell_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_hell_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_hell_aura:GetModifierAura() return "modifier_hell" end
function modifier_hell_aura:GetAuraEntityReject( hTarget )
	if IsServer() then
		if hTarget == self:GetCaster() or hTarget == self:GetCaster():GetOwner() then
			return true
		else
			return false
		end
	end
end

modifier_hell = modifier_hell or class({})

function modifier_hell:IsHidden() return true end
function modifier_hell:IsPassive() return true end
function modifier_hell:OnCreated( kv )
	self.damage_scepter = self:GetAbility():GetSpecialValueFor("damage_scepter")
	self.damage = self:GetAbility():GetSpecialValueFor("damage")

	self:StartIntervalThink( 1 )
end

function modifier_hell:OnIntervalThink()
	local damage_table = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
	}
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_purifyingflames_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

	if self:GetCaster():HasScepter() then
		damage_table.damage = self.damage_scepter
		damage_table.damage_type = DAMAGE_TYPE_PURE
	else
		damage_table.damage = self.damage
		damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
	end
	ApplyDamage( damage_table )

	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), 200, 1, false)
end

modifier_all_can_see_hellish_racer = modifier_all_can_see_hellish_racer or class({})

function modifier_all_can_see_hellish_racer:IsHidden() return true end
function modifier_all_can_see_hellish_racer:IsPassive() return false end
function modifier_all_can_see_hellish_racer:RemoveOnDeath() return true end
function modifier_all_can_see_hellish_racer:IsPurgable() return false end

function modifier_all_can_see_hellish_racer:CheckState()
	return {
		[MODIFIER_STATE_PROVIDES_VISION] = true,
	}
end

function modifier_all_can_see_hellish_racer:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
	}
end

function modifier_all_can_see_hellish_racer:GetModifierMoveSpeed_Limit()
	return 800
end

function modifier_all_can_see_hellish_racer:GetModifierIgnoreMovespeedLimit()
	return 800
end

--
-- Current Ability: Scorpion Crash
---------

scorpion_crash = scorpion_crash or class({})
LinkLuaModifier("modifier_chance_crash", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crashed", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)


function scorpion_crash:GetIntrinsicModifierName()
	return "modifier_chance_crash"
end

--
-- Modifiers
---------

modifier_chance_crash = modifier_chance_crash or class({})

function modifier_chance_crash:IsPassive() return true end
function modifier_chance_crash:IsHidden() return true end
function modifier_chance_crash:RemoveOnDeath() return false end
function modifier_chance_crash:IsPurgable() return false end

function modifier_chance_crash:OnCreated()
	self.chance = self:GetAbility():GetSpecialValueFor("chance")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	Timers:CreateTimer(function()
		if self:GetCaster():HasScepter() then
			if not self:GetCaster():HasAbility("scorpion_teleport") then
				local ability = self:GetCaster():AddAbility("scorpion_teleport")
				self:GetCaster():SwapAbilities("scorpion_teleport", "empty_1", true, false)
				
				ability:SetLevel(1)
			end
		else
			self:GetCaster():RemoveAbility("scorpion_teleport")
			self:GetCaster():SwapAbilities("scorpion_teleport", "empty_1", false, true)
		end
		return 0.1
	end)

end

function modifier_chance_crash:OnIntervalThink()
end

function modifier_chance_crash:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_chance_crash:OnAttackLanded( kv )
	if kv.attacker == self:GetParent() then

		if RollPercentage( self.chance ) then
			kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_crashed", { duration = self.duration  })
			kv.target:EmitSound("SoundBolno")
		end
	end
end

modifier_crashed = modifier_crashed or class({})

function modifier_crashed:IsPassive() return true end
function modifier_crashed:IsHidden() return true end
function modifier_crashed:RemoveOnDeath() return false end
function modifier_crashed:IsPurgable() return false end

function modifier_crashed:OnCreated()
	self.slow_movespeed = self:GetAbility():GetSpecialValueFor("slow_movespeed")
	self.slow_attackspeed = self:GetAbility():GetSpecialValueFor("slow_attackspeed")
	self.damage = self:GetAbility():GetSpecialValueFor("crash_damage")
	local random = RandomInt(1,3)

	if random == 1 then
		ApplyDamage( { victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage, damage_type = DAMAGE_TYPE_PURE } )
	elseif random == 2 then
		ApplyDamage( { victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage + 40, damage_type = DAMAGE_TYPE_PURE } )
	elseif random == 3 then
		ApplyDamage( { victim = self:GetParent(), attacker = self:GetCaster(), damage = self.damage + 80, damage_type = DAMAGE_TYPE_PURE } )
	end

end

function modifier_crashed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_crashed:GetModifierMoveSpeedBonus_Constant() return self.slow_movespeed end
function modifier_crashed:GetModifierAttackSpeedBonus_Constant() return self.slow_attackspeed end

--
-- Current Ability: Scorpion Teleport(Aghanim)
------

scorpion_teleport = scorpion_teleport or class({})

function scorpion_teleport:OnSpellStart()
	local units = FindUnitsInRadius( self:GetCaster():GetTeamNumber() , self:GetCaster():GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

	local random = RandomInt(1, #units)
	for _,unit in pairs( units ) do
		FindClearSpaceForUnit(self:GetCaster(), unit:GetAbsOrigin(), false)
	end
end

--
-- Current Ability: MLG Headshot
------

mlg_headshot_lua = mlg_headshot_lua or class({})

LinkLuaModifier("modifier_headshot", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

function mlg_headshot_lua:GetAbilityDamage()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("bonus_damage_scepter")
	end
	return self.BaseClass.GetAbilityDamage( self )
end

function mlg_headshot_lua:GetIntrinsicModifierName()
	return "modifier_headshot"
end

--
-- Modifiers
------

modifier_headshot = modifier_headshot or class({})

function modifier_headshot:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("default_damage")
	self.scepter_damage = self:GetAbility():GetLevelSpecialValueFor("bonus_damage_scepter", self:GetAbility():GetLevel() - 1)
	self.random = self:GetAbility():GetSpecialValueFor("proc_chance")
	self.knockback = RandomInt(50, 100)
end

function modifier_headshot:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_headshot:OnAttackLanded( kv )
	if kv.attacker == self:GetCaster() then
		if not kv.attacker:HasModifier("modifier_specific_headshot") then
			if RollPercentage( self.random ) then
				EmitSoundOn("SoundHit", kv.target)
				local knockbackModifierTable = {
					should_stun = 0,
					knockback_duration = 0.1,
					duration = 0.1,
					knockback_distance = self.knockback ,
					knockback_height = 0,
					center_x = kv.attacker:GetAbsOrigin().x,
					center_y = kv.attacker:GetAbsOrigin().y,
					center_z = kv.attacker:GetAbsOrigin().z
				}
				kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_knockback", knockbackModifierTable)
				kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_stunned", { duration = 0.1 })

				local damage_table = {
					victim = kv.target,
					attacker = kv.attacker,
				}

				if kv.attacker:HasScepter() then
					damage_table.damage = self.damage + self.scepter_damage
					damage_table.damage_type = DAMAGE_TYPE_PURE
				else
					damage_table.damage = self.damage
					damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
				end
				ApplyDamage( damage_table )
			end
		else
			EmitSoundOn("SoundHit", kv.target)
			local knockbackModifierTable = {
				should_stun = 0,
				knockback_duration = 0.1,
				duration = 0.1,
				knockback_distance = 10 ,
				knockback_height = 0,
				center_x = kv.attacker:GetAbsOrigin().x,
				center_y = kv.attacker:GetAbsOrigin().y,
				center_z = kv.attacker:GetAbsOrigin().z
			}
			kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_knockback", knockbackModifierTable)

			local damage_table = {
				victim = kv.target,
				attacker = kv.attacker,
			}

			
			damage_table.damage = self.damage - 40
			damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
			ApplyDamage( damage_table )
		end
	end
end

--
-- Current Ability: MLG Get NoScoped
------

mlg_get_noscoped = mlg_get_noscoped or class({})

LinkLuaModifier("modifier_specific_headshot", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

function mlg_get_noscoped:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_specific_headshot", { duration = 3 })
end

--
-- Modifiers
-----

modifier_specific_headshot = modifier_specific_headshot or class({})

function modifier_specific_headshot:IsHidden() return true end

--
-- Current Ability: Garry Poter Experto Patronium
------

LinkLuaModifier("modifier_delay_damage", "lua_abilities/lua_abilities", LUA_MODIFIER_MOTION_NONE)

poter_experto_patronium = poter_experto_patronium or class({})

function poter_experto_patronium:GetManaCost( level )
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor( "mana_cost_scepter" )
	end
	return self.BaseClass.GetManaCost( self, level )
end

function poter_experto_patronium:GetAOERadius()
	if self:GetCaster():HasScepter() then
		return 400
	end
	return 0
end

function poter_experto_patronium:CastFilterResultTarget(target) -- Thx Birzha)  
    if IsServer() then
        local caster = self:GetCaster()

        if not caster:HasScepter() then
            if target:IsMagicImmune() then
                return UF_FAIL_MAGIC_IMMUNE_ENEMY
            end
        end

        local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
        return nResult
    end
end

function poter_experto_patronium:OnSpellStart()
	local target = self:GetCursorTarget()

	if target:TriggerSpellAbsorb( self ) then
		return
	end

	EmitGlobalSound("SoundPatronum")
	target:AddNewModifier(self:GetCaster(), self, "modifier_delay_damage", { duration = 2.5 })
end

--
-- Modifiers
------

modifier_delay_damage = modifier_delay_damage or class({})

function modifier_delay_damage:IsHidden() return true end
function modifier_delay_damage:IsPassive() return false end
function modifier_delay_damage:RemoveOnDeath() return true end
function modifier_delay_damage:IsPurgable() return false end

function modifier_delay_damage:OnCreated()
	self.damage = self:GetAbility():GetSpecialValueFor("damage")
	self.damage_scepter = self:GetAbility():GetSpecialValueFor("damage_scepter")
end

function modifier_delay_damage:OnDestroy()
	local damage_table = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
	}
	if self:GetCaster():HasScepter() then
		damage_table.damage = self:GetParent():GetMaxHealth() * self.damage_scepter / 100
		damage_table.damage_type = DAMAGE_TYPE_PURE
	else
		damage_table.damage = self.damage
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
	end

	EmitSoundOn("SoundPiu", self:GetParent())

	-- Thx Elfansoer
	local direction = ( self:GetCaster():GetOrigin() - self:GetParent():GetOrigin() ):Normalized()
	local partilce_patronium = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())

	ParticleManager:SetParticleControlEnt(partilce_patronium, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(partilce_patronium, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(partilce_patronium, 2, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(partilce_patronium, 3, self:GetParent():GetOrigin() + direction )
	ParticleManager:SetParticleControlForward(partilce_patronium, 3, -direction)



	ParticleManager:ReleaseParticleIndex( partilce_patronium )

	ApplyDamage( damage_table )
end

--
-- Current Ability: Chubaka Rage
-------

chubaka_rage = chubaka_rage or class({})

LinkLuaModifier("modifier_chubaka_rage", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

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

	self:GetCaster():SetModelScale(2.0)
	self:GetCaster():SetRenderColor(255, 20, 10)

end

function modifier_chubaka_rage:OnDestroy()
	self:GetCaster():SetModelScale( 1.25000 )
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

function modifier_chubaka_rage:GetModifierStatusResistance()
	return 80
end
--
-- Current Ability: Chubaka Bash
-------

chubaka_bash = chubaka_bash or class({})

LinkLuaModifier("modifier_passive_counter", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bash_counter", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)


function chubaka_bash:GetIntrinsicModifierName()
	return "modifier_passive_counter"
end

--
-- Modifiers
-------

modifier_passive_counter = modifier_passive_counter or class({})

function modifier_passive_counter:IsHidden() return true end
function modifier_passive_counter:IsPassive() return true end

function modifier_passive_counter:OnCreated()
end

function modifier_passive_counter:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_passive_counter:OnAttack( kv )
	if kv.attacker == self:GetCaster() then 
		if not kv.attacker:HasModifier("modifier_bash_counter") and self:GetAbility():IsCooldownReady() then
			kv.attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_bash_counter", {})
		end
	end
end

modifier_bash_counter = modifier_bash_counter or class({})

function modifier_bash_counter:IsHidden() return false end
function modifier_bash_counter:IsPassive() return true end
function modifier_bash_counter:IsPurgable() return false end

function modifier_bash_counter:OnCreated()
	self.need_stacks = self:GetAbility():GetSpecialValueFor("need_stacks")
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	
end

function modifier_bash_counter:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_bash_counter:OnAttackLanded( kv )
	if kv.attacker == self:GetCaster() then
		if self:GetStackCount() < self.need_stacks then
			self:SetStackCount( self:GetStackCount() + 1 )
		else
			self:GetAbility():UseResources(false, false, true)
			EmitSoundOn("SoundBash", kv.target)
			ApplyDamage( { victim = kv.target, attacker = kv.attacker, ability = self:GetAbility(), damage = self.bonus_damage, damage_type = DAMAGE_TYPE_PHYSICAL } )
			kv.target:AddNewModifier(kv.attacker, self:GetAbility(), "modifier_stunned", { duration = self.duration  })
			kv.attacker:RemoveModifierByName("modifier_bash_counter")
		end
	end
end

--
-- Current Ability: Chubaka Extra Armor
-------

chubaka_extra_armor = chubaka_extra_armor or class({})

LinkLuaModifier("modifier_reflect_damage", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

function chubaka_extra_armor:GetIntrinsicModifierName()
	return "modifier_reflect_damage"
end

function chubaka_extra_armor:OnUpgrade()
	self:GetCaster():RemoveModifierByName("modifier_reflect_damage")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_reflect_damage", { duration = -1 })

	print( "Hero Level Up" )
end

--
-- Modifiers
--------


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

chubaka_earthshock = chubaka_earthshock or class({})

LinkLuaModifier("modifier_extra_slow", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

function chubaka_earthshock:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("shock_radius_scepter")
	end
	return self.BaseClass.GetCastRange( self ,vLocation, hTarget)
end

function chubaka_earthshock:GetCastPoint()
	return 0.66
end

function chubaka_earthshock:OnSpellStart()
	local caster = self:GetCaster()

	self.radius = self:GetSpecialValueFor("shock_radius")
	self.scepter_radius = self:GetSpecialValueFor("shock_radius_scepter")
	self.damage = self:GetAbilityDamage()
	self.duration = self:GetSpecialValueFor("shock_extra_slow_duration")
	self.stun_duration = self:GetSpecialValueFor("stun_duration")

	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false) -- Первое получаем число команды, второе позицию кастеру, кеш юнита хз просто nil, радиус, команда на которых будет работать это, и тип цели, флаги, хз, и это тоже
	local units_scepter = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.scepter_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local chubaka_earthshock = ParticleManager:CreateParticle("particles/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, self:GetCaster())

	 -- x,y = как раз чтобы изменить размер партикла, z = высота партикла юзается для зевса и других.
	EmitSoundOn("SoundRik", self:GetCaster())
	if self:GetCaster():HasScepter() then
		ParticleManager:SetParticleControl(chubaka_earthshock, 1, Vector(self.scepter_radius,self.scepter_radius, 200 ))
		for _,unit in ipairs( units_scepter ) do -- ищет юнитов здесь, а табло будет unit
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
	else
		ParticleManager:SetParticleControl(chubaka_earthshock, 1, Vector(self.radius,self.radius, 200 ))
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
-- Current Ability: VolDeMort Avada Kedavra
--------

voldemort_avada_kedavra = voldemort_avada_kedavra or class({})

LinkLuaModifier("modifier_voldemort_avada_kedavra_delay", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_voldemort_avada_kedavra_damage_counter", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE )
-- Crutch
LinkLuaModifier("modifier_voldemort_avada_kedavra_stacks", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE )

function voldemort_avada_kedavra:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()

	self:GetCaster():FaceTowards( target:GetAbsOrigin() )
	self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 0.3850 )

	EmitSoundOn("SoundAvada", self:GetCaster())

	return true
end

function voldemort_avada_kedavra:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "SoundAvada" )
end

function voldemort_avada_kedavra:OnSpellStart()
	local target = self:GetCursorTarget()
	local modifier_counter = self:GetCaster():FindModifierByName("modifier_voldemort_avada_kedavra_stacks")
	self.damage = self:GetSpecialValueFor("damage")

	local avada_kedavra = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_POINT_FOLLOW, target )
		
		ParticleManager:SetParticleControlEnt( avada_kedavra, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true )
		ParticleManager:SetParticleControlEnt( avada_kedavra, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
		ParticleManager:ReleaseParticleIndex( avada_kedavra )

	local damage_table = {
		victim = target,
		attacker = self:GetCaster(),
		ability = self,
		damage = self.damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
	}
	ApplyDamage( damage_table )

	target:AddNewModifier(self:GetCaster(), self, "modifier_voldemort_avada_kedavra_delay", { duration = 3 })

end

--
-- Current Ability: Shrek Make Puk :)
-------

shrek_bad_smell = shrek_bad_smell or class({})

-- Pukalka really?!
LinkLuaModifier("modifier_pukalka", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

function shrek_bad_smell:GetIntrinsicModifierName()
	return "modifier_pukalka"
end

--
-- Modifiers
------

modifier_pukalka = modifier_pukalka or class({})

function modifier_pukalka:IsHidden() return true end function modifier_pukalka:IsPassive() return true end function modifier_pukalka:IsPurgable() return false end function modifier_pukalka:RemoveOnDeath() return false end

function modifier_pukalka:OnCreated()
	self.enabled = true

	self.damage_in_percent = self:GetAbility():GetSpecialValueFor("aura_damage")

	self:StartIntervalThink( 0.1 )
end

function modifier_pukalka:OnIntervalThink()
	if self:GetAbility():IsCooldownReady() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

		self.enabled = true

		if #units < 1 then return end
		Timers:CreateTimer(0.2, function()
			for _,target in ipairs( units ) do
				local damage_table = {
					victim = target,
					attacker = self:GetCaster(),
					ability = self,
					damage = target:GetMaxHealth() * self.damage_in_percent / 100,
					damage_type = DAMAGE_TYPE_PURE
				}
				ApplyDamage( damage_table )
			end
		end)
		self:GetAbility():UseResources(false, false, true)
	else
		self.enabled = false
	end
end

--
-- Current Ability: Shrek Scream
------------

shrek_scream = shrek_scream or class({})

function shrek_scream:GetCooldown(iLevel)
	return self.BaseClass.GetCooldown( self, iLevel )
end

function shrek_scream:OnSpellStart()
	local radius = self:GetSpecialValueFor("scream_radius")
	local duration = self:GetSpecialValueFor("scream_duration")
	local damage = self:GetSpecialValueFor("damage")
	local screamer = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)

	local scream_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	ParticleManager:SetParticleControl(scream_particle, PATTACH_ABSORIGIN_FOLLOW, Vector( radius, radius, 0 ))
	
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(scream_particle, false)
	end)
	
	for _,screamed in pairs( screamer ) do
		screamed:AddNewModifier(self:GetCaster(), self, "modifier_screamed_custom", { duration = duration })
		ApplyDamage({
			victim = screamed,
			attacker = self:GetCaster(),
			ability = self, -- optional
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end

	if self:GetCaster():FindAbilityByName("chubaka_bash"):GetLevel() >= 1 then
		self:StartCooldown( self:GetCooldown( self:GetLevel() - 1 ) - 2 )
	end

end

--
-- Current Ability: Sonic Super Speed
---------

sonic_super_speed = sonic_super_speed or class({})

LinkLuaModifier("modifier_sonic_super_speed", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

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
-- Current Ability: Sonic Time Deceleration
--------

sonic_time_deceleration = sonic_time_deceleration or class({})
LinkLuaModifier("modifier_speed_in_time", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sonic_time_deceleration", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
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
LinkLuaModifier("modifier_form_check", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_form_change", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_night_wings", "lua_abilities/lua_abilities.lua", LUA_MODIFIER_MOTION_NONE)

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

modifier_form_change = modifier_form_change or class({})

function modifier_form_change:IsHidden() return true end function modifier_form_change:IsPassive() return true end function modifier_form_change:IsPurgable() return false end

function modifier_form_change:OnCreated()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end

function modifier_form_change:OnRefresh()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.attack_speed = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
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