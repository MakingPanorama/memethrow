function ApplyFearCustomModifier( caster, target, ability, duration )
	return target:AddNewModifier(caster, ability, "modifier_screamed_custom", { duration = duration  })
end

function ApplyGenericStun( target, caster, ability, duration )
	return target:AddNewModifier( caster, ability, "modifier_stunned", { duration = duration } )
end

function GetAllItemsInSlotAndTableInsert( needTarget, nameTable )
	for i=0,9 do
		local items = needTarget:GetItemInSlot(i)

		if items ~= nil then
			table.insert( nameTable, items )
		end
	end
end