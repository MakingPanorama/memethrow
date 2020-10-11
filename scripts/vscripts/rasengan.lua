function calcKnockbackRadius( keys )
	local caster = keys.caster
	local ability = keys.ability

	--Knockback
	local start_knockback = ability:GetSpecialValueFor("start_knockback")
	local max_knockback = ability:GetSpecialValueFor("max_knockback")

	local knockback_calculator = 0

	-- Damage
	local min_damage = ability:GetSpecialValueFor("min_damage")
	local max_damage = ability:GetSpecialValueFor("max_damage")

	local damage_calculator = 0

	-- Results 
	result_knockback = 0
	result_damage = 0

	Timers:CreateTimer(0,function()

		-- Calculating knockback strength
		knockback_calculator = knockback_calculator + 50
		result_knockback = start_knockback + knockback_calculator

		-- Calculating bonus damage
		damage_calculator = damage_calculator + 100
		result_damage = min_damage + damage_calculator

		if result_knockback >= max_knockback and damage_calculator >= max_damage then
			print("Rasengan fully charged. Knockback will be with strength "..result_knockback.. " and damage will be "..result_damage)
			return nil
		end

		if result_knockback >= max_knockback then
			result_knockback = max_knockback
		elseif result_damage >= max_damage then
			result_damage = max_damage
		end
		if ability:IsChanneling() then
			return 0.5
		else
		end
	end)
end

function TriggKnockAndDamage( keys )
	local vCaster = keys.caster:GetAbsOrigin()
	local vTarget = keys.target:GetAbsOrigin()
	local len = ( vTarget - vCaster ):Length2D()
	len = keys.distance - keys.distance * ( len / keys.range )
	local knockbackModifierTable =
	{
		should_stun = 0,
		knockback_duration = 0.5,
		duration = 0.5,
		knockback_distance = len + result_knockback ,
		knockback_height = 0,
		center_x = keys.caster:GetAbsOrigin().x,
		center_y = keys.caster:GetAbsOrigin().y,
		center_z = keys.caster:GetAbsOrigin().z
	}
	keys.target:AddNewModifier( keys.caster, nil, "modifier_knockback", knockbackModifierTable )

	local damage_table = {
		victim = keys.target,
		attacker = keys.caster,
		ability = keys.ability,
		damage = result_damage,
		damage_type = DAMAGE_TYPE_MAGICAL
	}

	ApplyDamage( damage_table )
end