-- spawns the current player at a certain spawn point index (or a random one, for that matter)
function spawnPlayer(spawnIdx, cb)

    Citizen.CreateThread(function()
        -- get the spawn from the array

        spawn = spawnIdx

        -- prevent errors when passing spawn table
        spawn.x = spawn.x + 0.00
        spawn.y = spawn.y + 0.00
        spawn.z = spawn.z + 0.00

        spawn.heading = spawn.heading and (spawn.heading + 0.00) or 0

        if not spawn.skipFade then
            DoScreenFadeOut(500)

            while not IsScreenFadedOut() do
                Citizen.Wait(0)
            end
        end

        -- if the spawn has a model set
        RequestModel(spawn.model)

        -- load the model for this spawn
        while not HasModelLoaded(spawn.model) do
            RequestModel(spawn.model)

            Wait(0)
        end

        -- change the player model
        SetPlayerModel(PlayerId(), spawn.model)

        -- release the player model
        SetModelAsNoLongerNeeded(spawn.model)

        -- preload collisions for the spawnpoint
        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)

        -- spawn the player
        local ped = PlayerPedId()

        -- V requires setting coords as well
        SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)

        NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.heading, true, true, false)

        -- gamelogic-style cleanup stuff
        ClearPedTasksImmediately(ped)
        --SetEntityHealth(ped, 300) -- TODO: allow configuration of this?
        RemoveAllPedWeapons(ped) -- TODO: make configurable (V behavior?)
        ClearPlayerWantedLevel(PlayerId())
		
        local time = GetGameTimer()

        while (not HasCollisionLoadedAroundEntity(ped) and (GetGameTimer() - time) < 5000) do
            Citizen.Wait(0)
        end

        ShutdownLoadingScreen()

        if IsScreenFadedOut() then
            DoScreenFadeIn(500)

            while not IsScreenFadedIn() do
                Citizen.Wait(0)
            end
        end

        TriggerEvent('playerSpawned', spawn)
		
		if cb then
            cb(spawn)
        end

    end)
end

exports('spawnPlayer', spawnPlayer)
