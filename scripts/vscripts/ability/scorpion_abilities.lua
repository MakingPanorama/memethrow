--
-- Current Ability: Scorpion Crash
---------

scorpion_crash = scorpion_crash or class({})
LinkLuaModifier("modifier_chance_crash", "ability/scorpion_abilities.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_crashed", "ability/scorpion_abilities.lua", LUA_MODIFIER_MOTION_NONE)


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
			kv.target:EmitSound("SoundCrush")
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