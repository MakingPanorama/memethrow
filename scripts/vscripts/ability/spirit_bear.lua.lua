--[[
	Author Noya
	Date 15.01.2015.
	Spawns a unit with different levels of the unit_name passed
	Each level needs a _level unit inside npc_units or npc_units_custom.txt
]]
function SpiritBearSpawn( event )
	local caster = event.caster
	local player = casterGetPlayerID()
	local ability = event.ability
	local level = abilityGetLevel()
	local origin = casterGetAbsOrigin() + RandomVector(100)

	-- Set the unit name, concatenated with the level number
	local unit_name = event.unit_name
	unit_name = unit_name..level

	-- Synergy Level. Checks both the default and the datadriven Synergy
	local synergyAbility = casterFindAbilityByName(lone_druid_synergy_datadriven)
	if synergyAbility == nil then
		synergyAbility = casterFindAbilityByName(lone_druid_synergy)
	end

	-- Check if the bear is alive, heals and spawns them near the caster if it is
	if caster.bear and and IsValidEntity(caster.bear) and caster.bearIsAlive() then
		FindClearSpaceForUnit(caster.bear, origin, true)
		caster.bearSetHealth(caster.bearGetMaxHealth())
	
		-- Spawn particle
		local particle = ParticleManagerCreateParticle(particlesunitsheroeshero_lone_druidlone_druid_bear_spawn.vpcf, PATTACH_ABSORIGIN_FOLLOW, caster.bear)	

		-- Re-Apply the synergy buff if we found one
		if caster.bearHasModifier(modifier_bear_synergy) then
			caster.bearRemoveModifierByName(modifier_bear_synergy)
			synergyAbilityApplyDataDrivenModifier(caster, caster.bear, modifier_bear_synergy, nil)
		end
		
	else
		-- Create the unit and make it controllable
		caster.bear = CreateUnitByName(unit_name, origin, true, caster, caster, casterGetTeamNumber())
		caster.bearSetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		if ability ~= nil then
			abilityApplyDataDrivenModifier(caster, caster.bear, modifier_spirit_bear, nil)
		end

		-- Apply the synergy buff if the ability exists
		if synergyAbility ~= nil then
			synergyAbilityApplyDataDrivenModifier(caster, caster.bear, modifier_bear_synergy, nil)
		end

		-- Learn its abilities return lvl 2, entangle lvl 3, demolish lvl 4. By Index
		LearnBearAbilities( caster.bear, 1 )
	end

end

--[[
	Author Noya
	Date 15.01.2015.
	When the skill is leveled up, try to find the casters bear and replace it by a new one on the same place
]]
function SpiritBearLevel( event )
	local caster = event.caster
	local player = casterGetPlayerID()
	local ability = event.ability
	local level = abilityGetLevel()
	local unit_name = npc_dota_lone_druid_bear..level

	print(Level Up Bear)

	-- Synergy Level. Checks both the default and the datadriven Synergy
	local synergyAbility = casterFindAbilityByName(lone_druid_synergy_datadriven)
	if synergyAbility == nil then
		synergyAbility = casterFindAbilityByName(lone_druid_synergy)
	end

	if caster.bear and caster.bearIsAlive() then 
		-- Remove the old bear in its position
		local origin = caster.bearGetAbsOrigin()
		caster.bearRemoveSelf()

		-- Create the unit and make it controllable
		caster.bear = CreateUnitByName(unit_name, origin, true, caster, caster, casterGetTeamNumber())
		caster.bearSetControllableByPlayer(player, true)

		-- Apply the backslash on death modifier
		abilityApplyDataDrivenModifier(caster, caster.bear, modifier_spirit_bear, nil)

		-- Apply the synergy buff if the ability exists
		if synergyAbility ~= nil then
			synergyAbilityApplyDataDrivenModifier(caster, caster.bear, modifier_bear_synergy, nil)
		end

		-- Learn its abilities return lvl 2, entangle lvl 3, demolish lvl 4. By Index
		LearnBearAbilities( caster.bear, 1 )
	end
end

-- Auxiliar Function to loop over all the abilities of the unit and set them to a level
function LearnBearAbilities( unit, level )

	-- Learn its abilities, for lone_druid_bear its return lvl 2, entangle lvl 3, demolish lvl 4. By Index
	for i=0,15 do
		local ability = unitGetAbilityByIndex(i)
		if ability then
			abilitySetLevel(level)
			print(Set Level ..level.. on ..abilityGetAbilityName())
		end
	end

end