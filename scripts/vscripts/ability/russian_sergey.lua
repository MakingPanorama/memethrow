--
-- Current Ability: Sergey What Is The WORD?!
--------

russian_sergey_what_is_this_word = russian_sergey_what_is_this_word or class({})
LinkLuaModifier("modifier_reflector", "ability/russian_sergey.lua", LUA_MODIFIER_MOTION_NONE)

function russian_sergey_what_is_this_word:GetIntrinsicModifierName()
	return "modifier_reflector"
end

function russian_sergey_what_is_this_word:GetCooldown(ilevel)
	if self:GetCaster():HasScepter() then
		return 3
	end

	return self.BaseClass.GetCooldown( self, ilevel )
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

	tOldSpells = {} -- Table
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
		if ( not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() then
			-- use resources
			self:GetAbility():UseResources( false, false, true )

			self:PlayEffects( true )

			EmitSoundOn(AbilityKV["AbilityCastSound"], self:GetCaster())
			return 1
		end
	end
end


--

modifier_reflector.reflected_spell = nil
function modifier_reflector:GetReflectSpell( params )
	if IsServer() then
		-- If unable to reflect due to the source ability
		if params.ability==nil or self.reflect_exceptions[params.ability:GetAbilityName()] then
			return 0
		end

		if kv.ability:GetCaster():HasModifier("modifier_lotus_orb_active") or kv.ability:GetCaster():HasModifier("modifier_item_mirror_shield") then
			return 0
		end 

		if (not self:GetParent():PassivesDisabled()) and self:GetAbility():IsFullyCastable() then
			-- use resources
			self.reflect = true

			-- remove previous ability
			if self.reflected_spell~=nil then
				self:GetParent():RemoveAbility( self.reflected_spell:GetAbilityName() )
			end

			-- copy the ability
			local sourceAbility = params.ability
			local selfAbility = self:GetParent():AddAbility( sourceAbility:GetAbilityName() )
			selfAbility:SetLevel( sourceAbility:GetLevel() )
			selfAbility:SetStolen( true )
			selfAbility:SetHidden( true )

			-- store the ability
			self.reflected_spell = selfAbility

			-- cast the ability
			self:GetParent():SetCursorCastTarget( sourceAbility:GetCaster() )
			selfAbility:CastAbility()

			-- play effects
			self:PlayEffects( false )
			return 1
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