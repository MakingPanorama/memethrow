function ExtraData( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 135
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_anim_change", {})
end	

function HorizontalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 99999 then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
        caster:MoveToPosition(target:GetOrigin())
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName("modifier_anim_change")

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end
end

function VerticalJump( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local caster_loc = caster:GetAbsOrigin()
    local caster_loc_ground = GetGroundPosition(caster_loc, caster)


    if caster_loc.z <= caster_loc_ground.z then
    	caster:SetAbsOrigin(caster_loc_ground)
    end

	if ability.traveled_distance < ability.initial_distance / 2 then
		ability.z = ability.z + ability.speed_traveling / 2
		caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.z))
	elseif caster_loc.z > caster_loc_ground.z then
		ability.z = ability.z - ability.speed_traveling / 2
		caster:SetAbsOrigin(caster_loc_ground + Vector(0,0,ability.z))
	end
end

function GlobalSome ( keys )

	EmitGlobalSound("SoundSome")
	
end


function Damage_scepter ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability	
	local talent = caster:FindAbilityByName("special_bonus_unique_mirana_2")
		
	local dmg = ability:GetLevelSpecialValueFor("damage_scepter", ability:GetLevel() - 1 )	
		
	if caster:HasScepter() then
           ApplyDamage({victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL})
    end
        
    if talent:GetLevel() == 1 then
        ability:ApplyDataDrivenModifier(caster, target, "modifier_boloto_deregen", nil)
    end

end

function AcidSpraySound( event )
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

	target:EmitSound("Hero_Alchemist.AcidSpray")

	Timers:CreateTimer(duration-0.1, function() 
		target:StopSound("Hero_Alchemist.AcidSpray") 
	end)

end
---------------------------------
-- Урон от пердежа
---------------------------------
--
-- Current Ability: Shrek Make Puk :)
-------

shrek_bad_smell = shrek_bad_smell or class({})

-- Pukalka
LinkLuaModifier("modifier_pukalka", "ability/shrek.lua", LUA_MODIFIER_MOTION_NONE)

function shrek_bad_smell:GetIntrinsicModifierName()
	return "modifier_pukalka"
end

--
-- Modifiers
------

modifier_pukalka = modifier_pukalka or class({})

function modifier_pukalka:IsHidden() return true end 
function modifier_pukalka:IsPassive() return true end 
function modifier_pukalka:IsPurgable() return false end 
function modifier_pukalka:RemoveOnDeath() return true end

function modifier_pukalka:OnCreated()
	self.enabled = true

	self.damage_in_percent = self:GetAbility():GetSpecialValueFor("aura_damage")
	
	self:StartIntervalThink( 0.1 )
end

function modifier_pukalka:OnIntervalThink()
	
	if self:GetAbility():IsCooldownReady() and self:GetParent():IsAlive() and not self:GetParent():IsIllusion() then
	local radius = self:GetAbility():GetSpecialValueFor("radius")
	if self:GetAbility():IsCooldownReady() then
		local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		local caster = self:GetCaster()
		self.enabled = true
        
		if #units < 1 then return end
		Timers:CreateTimer(0.2, function()
			for _,target in ipairs( units ) do
				if self:GetCaster():FindAbilityByName("special_bonus_unique_mirana_1"):GetLevel() >= 1 then
					local damage_table = {
						victim = target,
						attacker = self:GetCaster(),
						ability = self,
						damage = target:GetMaxHealth() * self.damage_in_percent / 100,
						damage_type = DAMAGE_TYPE_PURE
					}
					ApplyDamage( damage_table )
				else
					local damage_table = {
						victim = target,
						attacker = self:GetCaster(),
						ability = self,
						damage = target:GetMaxHealth() * self.damage_in_percent / 100,
						damage_type = DAMAGE_TYPE_MAGICAL
					}
					ApplyDamage( damage_table )
				end
			end
		end)
		self:GetAbility():UseResources(false, false, true)
		local rand = RandomFloat(1, 40)
			if (rand >=1 and rand <= 10) then
					caster:EmitSound("SoundShrekPuk1")
				elseif (rand >10 and rand <= 20) then
					caster:EmitSound("SoundShrekPuk2")
				elseif (rand >20 and rand <= 30) then
					caster:EmitSound("SoundShrekPuk3")
				elseif (rand >30 and rand <= 40) then
					caster:EmitSound("SoundShrekPuk4")
			end	
				if caster:HasScepter() then
					local str = self:GetAbility():GetSpecialValueFor("bonus_strange_scepter")
					caster:ModifyStrength(str)
					caster.Additional_str = (caster.Additional_str or 0) + str
					local sila = caster:GetBaseStrength()
				end
	else
		self.enabled = false
	end
	end

end



-- Осёл : спавн осла

function SpiritBearSpawn( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local origin = caster:GetAbsOrigin() + RandomVector(100)

	-- Set the unit name, concatenated with the level number
	local unit_name = event.unit_name
	unit_name = unit_name..level


	-- Check if the osel is alive, heals and spawns them near the caster if it is
	if caster.osel and IsValidEntity(caster.osel) and caster.osel:IsAlive() then
		FindClearSpaceForUnit(caster.osel, origin, true)
		caster.osel:SetHealth(caster.osel:GetMaxHealth())
	
		-- Spawn particle
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_osel_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster.osel)	

		
	else
		-- Create the unit and make it controllable
		caster.osel = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.osel:SetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		if ability ~= nil then
			ability:ApplyDataDrivenModifier(caster, caster.osel, "modifier_spirit_osel", nil)
		end

		-- Learn its abilities: return lvl 2, entangle lvl 3, demolish lvl 4. By Index
		LearnoselAbilities( caster.osel, 1 )
	end

end

--[[
	Author: Noya
	Date: 15.01.2015.
	When the skill is leveled up, try to find the casters osel and replace it by a new one on the same place
]]
function SpiritBearLevel( event )
	local caster = event.caster
	local player = caster:GetPlayerID()
	local ability = event.ability
	local level = ability:GetLevel()
	local unit_name = "npc_dota_shrek_osel"..level


	-- Synergy Level. Checks both the default and the datadriven Syner

	if caster.osel and caster.osel:IsAlive() then 
		-- Remove the old osel in its position
		local origin = caster.osel:GetAbsOrigin()
		caster.osel:RemoveSelf()

		-- Create the unit and make it controllable
		caster.osel = CreateUnitByName(unit_name, origin, true, caster, caster, caster:GetTeamNumber())
		caster.osel:SetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		ability:ApplyDataDrivenModifier(caster, caster.osel, "modifier_spirit_osel", nil)


		-- Learn its abilities: return lvl 2, entangle lvl 3, demolish lvl 4. By Index
		LearnoselAbilities( caster.osel, 1 )
	end
end


-- Auxiliar Function to loop over all the abilities of the unit and set them to a level
function LearnoselAbilities( unit, level )

	-- Learn its abilities, for lone_druid_osel its return lvl 2, entangle lvl 3, demolish lvl 4. By Index
	for i=0,15 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(level)
			print("Set Level "..level.." on "..ability:GetAbilityName())
		end
	end

end

-- Осёл : доебатся
function ExtraDataD( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:Stop()

	ability.target = target
	ability.traveled_distance = 0
	ability.speed_traveling = 30
	ability.z = 0 
	ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
	ability.move = keys.target:GetOrigin()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_anim_change", {})
end	

function GoHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability
	local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local distance = (target_loc - caster_loc):Length2D()
    local direction = (target_loc - caster_loc):Normalized()

 	
    if (target_loc - caster_loc):Length2D() >= 4000 then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end

	if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.speed_traveling)
        ability.traveled_distance= ability.traveled_distance + ability.speed_traveling
        caster:MoveToPosition(target:GetOrigin())
    else
        caster:InterruptMotionControllers(true)
        caster:RemoveModifierByName("modifier_anim_change")

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))
    end
    if caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() then
    	caster:InterruptMotionControllers(true)
    	caster:RemoveModifierByName("modifier_anim_change")
    end
end
--
-- Current Ability: Shrek Osel ZaebaAura
------

function ZaebaAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local target_max_hp = target:GetMaxHealth() / 100
	local aura_damage = 1.5
	local aura_damage_interval = 0.2


	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = target_max_hp * aura_damage * aura_damage_interval

	ApplyDamage(damage_table)
end

-- scream lua
--
-- Current Ability: Shrek Scream
------------

shrek_scream = shrek_scream or class({})

function shrek_scream:OnSpellStart()
	local radius = self:GetSpecialValueFor("scream_radius")
	local duration = self:GetSpecialValueFor("scream_duration")
	local damage = self:GetSpecialValueFor("scream_damage")
	local screamer = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local caster = self:GetCaster()
	
	local scream_particle = ParticleManager:CreateParticle("particles/queen_scream_of_pain_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

	ParticleManager:SetParticleControl(scream_particle, PATTACH_ABSORIGIN_FOLLOW, Vector( radius, radius, 0 ))
	
	
	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(scream_particle, false)
	end)
	
	for _,screamed in pairs( screamer ) do
		caster:EmitSound("SoundShrekWhat")
		screamed:AddNewModifier(self:GetCaster(), self, "modifier_screamed_custom", { duration = duration })
		ApplyDamage({
			victim = screamed,
			attacker = self:GetCaster(),
			ability = self, -- optional
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL
		})
	end
	
	
end

function VonFromBoloto ( keys )

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("von_duration")
	
	if not target:HasModifier("modifier_screamed_custom") then
	target:AddNewModifier(caster, target, "modifier_screamed_custom", { duration = duration })
	EmitGlobalSound("SoundShrekWhat")
	end
	
end



