--[[ events.lua ]]

---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	local rand = RandomFloat(1, 80)
	--print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
	EmitGlobalSound("SoundPick")
	end

	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
			
	
		if (rand >=1 and rand <= 10) then
				EmitGlobalSound("SoundStart")
		elseif (rand >10 and rand <= 20) then
				EmitGlobalSound("SoundStart2")
		elseif (rand >20 and rand <= 30) then
				EmitGlobalSound("SoundStart3")
		elseif (rand >30 and rand <= 40) then
				EmitGlobalSound("SoundStart4")
		elseif (rand >40 and rand <= 50) then
				EmitGlobalSound("SoundStart5")
		elseif (rand >50 and rand <= 60) then
				EmitGlobalSound("SoundStart6")
		elseif (rand >60 and rand <= 70) then
				EmitGlobalSound("SoundStart7")
		elseif (rand >70 and rand <= 80) then
				EmitGlobalSound("SoundStart8")
		end
		
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 7 then
			--self.TEAM_KILLS_TO_WIN = 25
			nCOUNTDOWNTIMER = 2300
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			--self.TEAM_KILLS_TO_WIN = 20
			nCOUNTDOWNTIMER = 2000
		else
			--self.TEAM_KILLS_TO_WIN = 15
			nCOUNTDOWNTIMER = 1500
		end
		if GetMapName() == "forest_solo" then
			self.TEAM_KILLS_TO_WIN = 30
		elseif GetMapName() == "desert_duo" then
			self.TEAM_KILLS_TO_WIN = 30
		elseif GetMapName() == "desert_quintet" then
			self.TEAM_KILLS_TO_WIN = 50
		elseif GetMapName() == "temple_quartet" then
			self.TEAM_KILLS_TO_WIN = 60
		else
			self.TEAM_KILLS_TO_WIN = 30
		end
		--print( "Kills to win = " .. tostring(self.TEAM_KILLS_TO_WIN) )

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		EmitGlobalSound( "SoundFight")
		--print( "OnGameRulesStateChange: Game In Progress" )
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
	end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned + скины
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	local hero = EntIndexToHScript(event.entindex)
	if hero:GetUnitName() == "npc_dota_hero_juggernaut" then
           SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/generic_wep_broadsword.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_back/bladesrunner_back.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/arcana/juggernaut_arcana_mask.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/juggernaut/bladesrunner_legs/bladesrunner_legs.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/juggernaut/juggernaut_arcana.vmdl"}):FollowEntity(hero, true)
	end
	if hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
           SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/phantom_assassin/creeping_shadow_back/creeping_shadow_back.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/phantom_assassin/creeping_shadow_belt/creeping_shadow_belt.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/phantom_assassin/creeping_shadow_head/creeping_shadow_head.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/phantom_assassin/creeping_shadow_shoulder/creeping_shadow_shoulder.vmdl"}):FollowEntity(hero, true)
		   SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/phantom_assassin/creeping_shadow_weapon/creeping_shadow_weapon.vmdl"}):FollowEntity(hero, true)
	end
	if spawnedUnit:IsRealHero() then
		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end
		if self.allSpawned == false then
			if GetMapName() == "mines_trio" then
				--print("mines_trio is the map")
				--print("self.allSpawned is " .. tostring(self.allSpawned) )
				local unitTeam = spawnedUnit:GetTeam()
				local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
				ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
			end
		end
	end
end



--[[function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if spawnedUnit:IsRealHero() or spawnedUnit:IsIllusion() then
		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end
		if self.allSpawned == false then
			if GetMapName() == "mines_trio" then
				--print("mines_trio is the map")
				--print("self.allSpawned is " .. tostring(self.allSpawned) )
				local unitTeam = spawnedUnit:GetTeam()
				local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
				ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
			end
		end
		if spawnedUnit:GetUnitName() == "npc_dota_courier_flying" then
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_no_limit_speed", {})
		end
		if 	tostring(PlayerResource:GetSteamID(0)) == "76561198363232884" then
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_green_man", {}) --2
			print("Test " ..tostring(PlayerResource:GetSteamID(0)))
		end
		if tostring(PlayerResource:GetSteamID(0)) == "76561198172972295" then
			spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_blue_man", {}) --1
			print("Test " ..tostring(PlayerResource:GetSteamID(0)))
		end
	end

end ]]

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function COverthrowGameMode:BountyRunePickupFilter( filterTable )
      filterTable["xp_bounty"] = 2*filterTable["xp_bounty"]
      filterTable["gold_bounty"] = 2*filterTable["gold_bounty"]
      return true
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function COverthrowGameMode:OnTeamKillCredit( event )
--	print( "OnKillCredit" )
--	DeepPrint( event )

	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

	if nKillsRemaining <= 0 then
		EmitGlobalSound( "SoundEnd")
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		GameRules:SetGameWinner( nTeamID )
		broadcast_kill_event.victory = 1

	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "SoundFinish" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
		EmitGlobalSound( "SoundFinished" )
		broadcast_kill_event.close_to_victory = 1
	elseif nKillsRemaining == 30 then
		EmitGlobalSound( "SoundFight")
	end

	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function COverthrowGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()
	local extraTime = 0
	if killedUnit:IsRealHero() then
		self.allSpawned = true
		--print("Hero has been killed")
		--Add extra time if killed by Necro Ult
		if hero:IsRealHero() == true then
			if event.entindex_inflictor ~= nil then
				local inflictor_index = event.entindex_inflictor
				if inflictor_index ~= nil then
					local ability = EntIndexToHScript( event.entindex_inflictor )
					if ability ~= nil then
						if ability:GetAbilityName() ~= nil then
							if ability:GetAbilityName() == "skeleton_king_mortal_strike_datadriven" then
								print("Killed by Necro Ult")
								extraTime = 20
							end
						end
					end
				end
			end
		end
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, true, 0 )
				hero:AddExperience( 500, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
			else
				hero:AddExperience( 150, 0, false, false )
			end
		end
		--Granting XP to all heroes who assisted
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			--print(killedUnit:GetNumAttackers())
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker == killedUnit:GetAttacker( i ) then
					--print("Granting assist xp")
					attacker:AddExperience( 100, 0, false, false )
				end
			end
		end
		if killedUnit:GetRespawnTime() > 10 then
			--print("Hero has long respawn time")
			if killedUnit:IsReincarnating() == true then
				--print("Set time for Wraith King respawn disabled")
				return nil
			else
				COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
			end
		else
			COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
		end
	end
end

function COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit, extraTime )
	--print("Setting time for respawn")
	if killedTeam == self.leadingTeam and self.isGameTied == false then
		killedUnit:SetTimeUntilRespawn( 20 + extraTime )
	else
		killedUnit:SetTimeUntilRespawn( 10 + extraTime )
	end
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function COverthrowGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	r = 322
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		--print("Bag of gold picked up")
		PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	elseif event.itemname == "item_treasure_chest" then
		--print("Special Item Picked Up")
		DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Stop", "0", 0, self, self )
		COverthrowGameMode:SpecialItemAdd( event )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end


--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		COverthrowGameMode:TreasureDrop( npc )
	end
end

--------------------------------------------------------------------------------
-- Event: OnHeroLeveled
--------------------------------------------------------------------------------
function COverthrowGameMode:OnHeroLeveled( event )
    local player = EntIndexToHScript(event.player)
    local level = event.level

    if level and player then
        local no_point_level = {
            [17] = 1,
            [19] = 1,
            [21] = 1,
            [22] = 1,
            [23] = 1,
            [24] = 1,
        }
        local hero = player:GetAssignedHero()
        if no_point_level[level] or level >= 30 then
            if hero then
                hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
            end
        end
    end
end