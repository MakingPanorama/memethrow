sniper_assassinate_lua = sniper_assassinate_lua or class({})

LinkLuaModifier("modifier_assassinate_target", "ability/sniper.lua", LUA_MODIFIER_MOTION_NONE)

AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")

function sniper_assassinate_lua:OnAbilityPhaseStart()
	local target = self:GetCursorTarget()
	target:AddNewModifier(self:GetCaster(), self, "modifier_assassinate_target", { duration = 4 })
	EmitGlobalSound( AbilityKV[self:GetName()]["AbilityCastSoundPhase"] )
	return true
end

function sniper_assassinate_lua:OnAbilityPhaseInterrupted()
	StopGlobalSound( AbilityKV[self:GetName()]["AbilityCastSoundPhase"] )
	local target = self:GetCursorTarget()
	target:RemoveModifierByName("modifier_assassinate_target")
end

function sniper_assassinate_lua:OnSpellStart()
	local target = self:GetCursorTarget()
	EmitGlobalSound( AbilityKV[self:GetName()]["AbilityCastSoundLaunch"] ) -- Launch

	local projectile = {
		Ability = self,
		Source = self:GetCaster(),
		Target = target,
		iMoveSpeed = 5000,
		bDodgeable = true,
		EffectName = "particles/sniper_assassinate.vpcf",
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( projectile )

end

function sniper_assassinate_lua:OnProjectileHit(hTarget, vLocation)
	local sounds_stop = {
		AbilityKV[self:GetName()]["AbilityCastSoundPhase"],
		AbilityKV[self:GetName()]["AbilityCastSoundLaunch"],
		AbilityKV[self:GetName()]["AbilityCastSoundHit"],
	}

	if hTarget == nil then return end

	for _,sounds in pairs(sounds_stop) do
		self:GetCaster():StopSound( sounds )
	end

	if hTarget:TriggerSpellAbsorb( self ) then return end

	hTarget:Kill( self, self:GetCaster() )

	EmitGlobalSound(AbilityKV[self:GetName()]["AbilityCastSoundHit"])
end


modifier_assassinate_target = modifier_assassinate_target or class({})

function modifier_assassinate_target:IsHidden() return false end function modifier_assassinate_target:IsPassive() return false end function modifier_assassinate_target:IsPurgable() return false end

function modifier_assassinate_target:GetEffectName()
	return "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf"
end

function modifier_assassinate_target:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

