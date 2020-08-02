function StoneGazeStart( keys )
	local caster = keys.caster

	caster.stone_gaze_table = {}
end

--[[Author: Pizzalol
	Date: 07.03.2015.
	Checks if the caster has the Stone Gaze modifier
	If the caster doesnt have the modifier then remove the debuff modifier from the target]]
function StoneGazeSlow( keys )
	local caster = keys.caster
	local target = keys.target
	
	local modifier_caster = keys.modifier_caster
	local modifier_target = keys.modifier_target

	if not caster:HasModifier(modifier_caster) then
		target:RemoveModifierByNameAndCaster(modifier_target, caster)
	end
end

--[[Author: Pizzalol, math by BMD
	Date: 07.03.2015.
	Checks if the target is currently facing the caster
	then it checks if the target faced the caster before
	if the target did face the caster before then apply the counter modifier
	otherwise add the target as a new target]]
function StoneGaze( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_slow = keys.modifier_slow
	local modifier_facing = keys.modifier_facing

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local vision_cone = ability:GetLevelSpecialValueFor("vision_cone", ability_level)

	-- Locations
	local caster_location = caster:GetAbsOrigin()
	local target_location = target:GetAbsOrigin()	

	-- Angle calculation
	local direction = (caster_location - target_location):Normalized()
	local forward_vector = target:GetForwardVector()
	local angle = math.abs(RotationDelta((VectorToAngles(direction)), VectorToAngles(forward_vector)).y)
	--print("Angle: " .. angle)

	ability:ApplyDataDrivenModifier(caster, target, modifier_facing, {Duration = 0.06})
end

--[[Author: Pizzalol
	Date: 07.03.2015.
	Checks for how long the target faced the caster
	If it was for longer than the minimum required facing time then
	apply the petrification debuff if the target was not petrified before]]
function StoneGazeFacing( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local face_duration = ability:GetLevelSpecialValueFor("face_duration", ability_level)
	local stone_duration = ability:GetLevelSpecialValueFor("stone_duration", ability_level)
	local modifier_stone = keys.modifier_stone


	-- If the target was facing the caster for more than the required time and wasnt petrified before
	-- then petrify it
		ability:ApplyDataDrivenModifier(caster, target, modifier_stone, {Duration = stone_duration})
		target.stone_gaze_stoned = true
end