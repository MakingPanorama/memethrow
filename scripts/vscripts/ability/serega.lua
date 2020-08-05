function OnSpellStart( keys )
	if keys.target:TriggerSpellAbsorb( keys.ability ) then return end

	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_projectile_control", {})
end

function MovementCheck(keys)
	local target = keys.unit
	local ability = keys.ability
	local backtrack_time = ability:GetLevelSpecialValueFor("backtrack_time", ability:GetLevel() -1)
	
	-- Temporary position array and index
	local temp = {}
	local temp_index = 0
	
	-- Global position array and index
	local target_index = 0
	if target.position == nil then
		target.position = {}
	end
	
	-- Sets the position and game time values in the tempororary array, if the target moved within 4 seconds of current time
	while target.position do
		if target.position[target_index] == nil then
		break
		elseif Time() - target.position[target_index+1] <= backtrack_time then
			temp[temp_index] = target.position[target_index]
			temp[temp_index+1] = target.position[target_index+1]
			temp_index = temp_index + 2
		end
		target_index = target_index + 2
	end
	
	-- Places most recent position and current time in the temporary array
	temp[temp_index] = target:GetAbsOrigin()
	temp[temp_index+1] = Time()
	
	-- Sets the global array as the temporary array
	target.position = temp
end

function ProjectileControl(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability	
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability:GetLevel() -1)/100
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() -1)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability:GetLevel() -1)
	ability.moved = false
	
	-- The glimpse location will be the oldest stored position in the array, providing it has been instantiated
	if target.position[0] == nil then
		ability.glimpse_location = target:GetAbsOrigin()
	else
		ability.glimpse_location = target.position[0]
	end
	
	-- Creates a dummy unit at the glimpse location to throw the projectile at
	local dummy = CreateUnitByName("npc_dummy_unit", ability.glimpse_location, false, caster, caster, caster:GetTeamNumber())
	-- Applies a modifier that removes it health bar
	ability:ApplyDataDrivenModifier(caster, dummy, "modifier_dummy", {})
	
	
	-- Throws the glimpse projectile at the dummy
	local info = {
	Target = dummy,
	Source = target,
	Ability = ability,
	bDodgeable = false,

	iMoveSpeed = projectile_speed,
	iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile( info )
end

function MoveTarget(keys)
	local target = keys.target
	local ability = keys.ability
	
	-- Checks if the target has been moved yet
	if ability.moved == false then
		-- Plays the move sound on the target
		EmitSoundOn(keys.sound, target)
		
		-- Moves the target
		target:SetAbsOrigin(ability.glimpse_location)
		FindClearSpaceForUnit(target, ability.glimpse_location, true)
	end
	
	ability.moved = true
end



--------------------------------------
-- Heal Хил залечить рану
----------------------------------------
function Heal( keys )

	local caster = keys.caster
	local ability = keys.ability
	local heal = ability:GetLevelSpecialValueFor("heal", ability:GetLevel() -1)
	
	if caster:HasScepter() then 
	heal = ability:GetLevelSpecialValueFor("heal_scepter", ability:GetLevel() -1)
	end
	
	local regen = caster:GetMaxHealth() * heal
	
	local rand = RandomFloat(1, 40)
	
	if (rand >=1 and rand <= 10) then
				caster:EmitSound("SoundHeal1")
		elseif (rand >10 and rand <= 20) then
				caster:EmitSound("SoundHeal2")
		elseif (rand >20 and rand <= 30) then
				caster:EmitSound("SoundHeal3")
		elseif (rand >30 and rand <= 40) then
				caster:EmitSound("SoundHeal4")
	end
	caster:Heal(regen, caster)
	
end

-------------------------------------------
-- Что это за слово
-------------------------------------------

russian_sergey_what_is_this_word = russian_sergey_what_is_this_word or class({})
LinkLuaModifier("modifier_reflector", "ability/serega.lua", LUA_MODIFIER_MOTION_NONE)

function russian_sergey_what_is_this_word:GetIntrinsicModifierName()
	return "modifier_reflector"
end

function russian_sergey_what_is_this_word:GetCooldown(ilevel)
	if self:GetCaster():HasScepter() then
		return 5
	end

	return self.BaseClass.GetCooldown( self, ilevel )
end

local function SpellReflect(parent, params)
	-- If some spells shouldn't be reflected, enter it into this spell-list
	local exception_spell = {
		["rubick_spell_steal"] = true,
		["duel_datadriven"] = true,
	}

	local reflected_spell_name = params.ability:GetAbilityName()
	local target = params.ability:GetCaster()

	-- Does not reflect allies' projectiles for any reason
	if target:GetTeamNumber() == parent:GetTeamNumber() then
		return nil
	end

	-- FOR NOW, UNTIL LOTUS ORB IS DONE
	-- Do not reflect spells if the target has Lotus Orb on, otherwise the game will die hard.
	if target:HasModifier("modifier_item_lotus_orb_active") or target:HasModifier("modifier_item_mirror_shield") then
		return nil
	end

	if ( not exception_spell[reflected_spell_name] ) then

		-- If this is a reflected ability, do nothing
		if params.ability.spell_shield_reflect then
			return nil
		end

		local reflect_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(reflect_pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(reflect_pfx)

		local old_spell = false
		for _,hSpell in pairs(parent.tOldSpells) do
			if hSpell ~= nil and hSpell:GetAbilityName() == reflected_spell_name then
				old_spell = true
				break
			end
		end
		if old_spell then
			ability = parent:FindAbilityByName(reflected_spell_name)
		else
			ability = parent:AddAbility(reflected_spell_name)
			ability:SetStolen(true)
			ability:SetHidden(true)

			-- Tag ability as a reflection ability
			ability.spell_shield_reflect = true

			-- Modifier counter, and add it into the old-spell list
			ability:SetRefCountsModifiers(true)
			table.insert(parent.tOldSpells, ability)
		end

		ability:SetLevel(params.ability:GetLevel())
		-- Set target & fire spell
		parent:SetCursorCastTarget(target)
		ability:OnSpellStart()
		
		-- This isn't considered vanilla behavior, but at minimum it should resolve any lingering channeled abilities...
		if ability.OnChannelFinish then
			ability:OnChannelFinish(false)
		end	
	end

	return false
end

--
-- Modifiers
---------

-- Modifier Reflector
modifier_reflector = modifier_reflector or class({})

function modifier_reflector:IsHidden() return true end function modifier_reflector:IsPassive() return true end function modifier_reflector:IsPurgable() return false end

function modifier_reflector:OnCreated()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("magic_resistance") -- Magic Resistance
	self.chance_reflect = self:GetAbility():GetSpecialValueFor("chance") -- Chance reflect

	AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

	self:GetParent().tOldSpells = {} -- Table

	self:StartIntervalThink( FrameTime() )
end

function modifier_reflector:OnRefresh()
	self.magic_resist = self:GetAbility():GetSpecialValueFor("magic_resistance")
end

function modifier_reflector:DeclareFunctions()
	local decFunc = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_PROPERTY_REFLECT_SPELL
	}
	return decFunc
end

function modifier_reflector:GetModifierMagicalResistanceBonus()
	return self.magic_resist
end

function modifier_reflector:GetAbsorbSpell( params )
	if IsServer() then
		if ( not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() or self:GetAbility():IsCooldownReady() then
			-- use resources
			self:GetAbility():UseResources( false, false, true )

			self:PlayEffects( true )

			EmitSoundOn(AbilityKV[self:GetAbility():GetName()]["AbilityCastSound"], self:GetCaster())
			return 1
		end
	end
end




modifier_reflector.reflected_spell = nil
function modifier_reflector:GetReflectSpell( params )
	if self:GetAbility():IsCooldownReady() then
		return SpellReflect(self:GetParent(), params)
	end
end

function modifier_reflector:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		for i=#caster.tOldSpells,1,-1 do
			local hSpell = caster.tOldSpells[i]
			if hSpell:NumModifiersUsingAbility() == 0 and not hSpell:IsChanneling() then
				hSpell:RemoveSelf()
				table.remove(caster.tOldSpells,i)
			end
		end
	end
end

--------------------------------------------------------------------------------
function modifier_reflector:PlayEffects( bBlock )
	-- Get Resources

	local particle_cast = ""

	if bBlock then
		particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf"
	else
		particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	end

	-- Play particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		self:GetParent(),
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		self:GetParent():GetOrigin(), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- Play sounds
	EmitSoundOn( sound_cast, self:GetParent() )
end

modifier_reflector.reflect_exceptions = {
	["rubick_spell_steal_lua"] = true
}


--------------------------------------
-- Vsego Horoshego
--------------------------------------

function Von( event )
	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor("duration_fear", ability:GetLevel() -1)
	local duration_scepter = ability:GetLevelSpecialValueFor("duration_scepter", ability:GetLevel() -1)
	local chance = ability:GetLevelSpecialValueFor("triger_chance", ability:GetLevel() -1)
	local talent = caster:FindAbilityByName("special_bonus_unique_silencer_2")
	local talents = caster:FindAbilityByName("special_bonus_unique_silencer_3")
	local damage = ability:GetLevelSpecialValueFor( "damage" , ability:GetLevel() - 1  )
	local damageType = ability:GetAbilityDamageType()
	
	if talent:GetLevel() == 1 then
		chance = ability:GetLevelSpecialValueFor("trigger_chance_talent", ability:GetLevel() -1)
	end
	

	local rand = math.random(1, 100)
	if rand <= chance then
		
		if talents:GetLevel() == 1 then
		ApplyDamage({ victim = attacker, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
		else ApplyDamage({ victim = attacker, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL })
		end
		if caster:HasScepter() then
			caster:EmitSound("SoundVsegoHoroshego")
			ApplyFearCustomModifier( caster, attacker, ability, duration_scepter )
			else
			caster:EmitSound("SoundVsegoHoroshego")
			ApplyFearCustomModifier( caster, attacker, ability, duration )
		end
	end
	
end

function RandomSound ( keys )


	local caster = keys.caster
	local rand = RandomFloat(1, 50)
	
	if (rand >=1 and rand <= 10) then
				caster:EmitSound("SoundSKrik1")
		elseif (rand >10 and rand <= 20) then
				caster:EmitSound("SoundSKrik2")
		elseif (rand >20 and rand <= 30) then
				caster:EmitSound("SoundSKrik3")
		elseif (rand >30 and rand <= 40) then
				caster:EmitSound("SoundSKrik4")
		elseif (rand >40 and rand <= 50) then
				caster:EmitSound("SoundSKrik5")
	end


end

function Start ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() -1)
	local talent = caster:FindAbilityByName("special_bonus_unique_silencer_2")
	
	if target:TriggerSpellAbsorb( ability ) then return end

	ability:ApplyDataDrivenModifier(caster, target, "modifier_primal_roar_stun", {})
	ability:ApplyDataDrivenModifier(caster, target, "modifier_primal_roar_slow", {})
	
	if talent:GetLevel() == 1 then
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE })
	else ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL })
	end
end




