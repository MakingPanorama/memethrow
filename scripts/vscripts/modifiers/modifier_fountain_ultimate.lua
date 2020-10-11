modifier_fountain_ultimate = class({})

function modifier_fountain_ultimate:IsHidden() return true end
function modifier_fountain_ultimate:IsPassive() return true end
function modifier_fountain_ultimate:IsPurgable() return false end

function modifier_fountain_ultimate:OnCreated()
	self:StartIntervalThink( 1 ) 
end

function modifier_fountain_ultimate:OnIntervalThink()
	local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	for _,unit in ipairs(units) do
		local fountain_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		
		ParticleManager:SetParticleControlEnt(fountain_particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:SetParticleControlEnt(fountain_particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
		ParticleManager:ReleaseParticleIndex( fountain_particle )

		unit:EmitSound("Ability.LagunaBlade")

		ApplyDamage( { victim = unit, attacker = self:GetCaster(), damage = unit:GetMaxHealth() * 20 / 100, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK } )
		if unit:IsIllusion() then
			unit:Kill( self:GetCaster(), self:GetCaster() )
		end
	end
end
