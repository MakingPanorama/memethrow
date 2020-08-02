modifier_screamed_custom = modifier_screamed_custom or class({})

function modifier_screamed_custom:IsHidden() return false end function modifier_screamed_custom:IsPassive() return false end function modifier_screamed_custom:IsPurgable() return true end

function modifier_screamed_custom:OnCreated()
	if not IsServer() then return end

	local buildings = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),
		Vector(0,0,0),
		nil,
		FIND_UNITS_EVERYWHERE,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		0,
		false
	)


	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetClassname() == "ent_dota_fountain" then
			fountain = building
			break
		end
	end

	if not fountain then return end

	self:GetParent():MoveToPosition( fountain:GetOrigin() )
end

function modifier_screamed_custom:CheckState()
	return {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}
end


function modifier_screamed_custom:OnDestroy()
	if not IsServer() then return end
	self:GetParent():Stop()
end

