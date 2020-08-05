--
-- Current Ability: VolDeMort Avada Kedavra
--------

voldemort_avada_kedavra = voldemort_avada_kedavra or class({})

function voldemort_avada_kedavra:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()

	self:GetCaster():FaceTowards( target:GetAbsOrigin() )

	EmitSoundOn("SoundAvada", self:GetCaster())

	return true
end

function voldemort_avada_kedavra:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "SoundAvada" )
end

function voldemort_avada_kedavra:OnSpellStart()
	local target = self:GetCursorTarget()

	self.damage = self:GetSpecialValueFor("damage")

	local avada_kedavra = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_POINT_FOLLOW, target )
		
		ParticleManager:SetParticleControlEnt( avada_kedavra, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
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
end