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