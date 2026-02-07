-- 1. We get the "Core Object". This is how we talk to qb-core.
local QBCore = exports['qb-core']:GetCoreObject()
local missionVehicle = nil

-- Command: /spawn_robbery_vehicle
RegisterCommand('spawn_robbery_vehicle', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnLocation = coords + (forward * 5.0)

    -- QBCore handles the spawning for us
    QBCore.Functions.SpawnVehicle('sultan', function(veh)
        missionVehicle = veh
        SetEntityHeading(veh, GetEntityHeading(ped))
        
        -- Lock the door (Status 2 = Locked)
        SetVehicleDoorsLocked(veh, 2)
        
        -- Tell qb-vehiclekeys the car is locked
        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2)

        local plate = QBCore.Functions.GetPlate(veh)
        QBCore.Functions.Notify("Mission Car Spawned: " .. plate, "primary")

        -- Use qb-target to create the interaction eye
        exports['qb-target']:AddTargetEntity(veh, {
            options = {
                {
                    icon = "fas fa-lock",
                    label = "Lockpick Mission Car",
                    action = function()
                        StartMissionLockpick(veh)
                    end,
                    -- Only show if the door is currently locked
                    canInteract = function()
                        return GetVehicleDoorLockStatus(veh) == 2
                    end
                }
            },
            distance = 2.5
        })
    end, spawnLocation, true)
end)

function StartMissionLockpick(vehicle)
    local item = "lockpick" 
    local difficulty = 1 
    local pins = 4

    -- CALLING T3_LOCKPICK
    -- We use the export to start the minigame. 
    -- The code waits here until the player wins or loses.
    local success = exports["t3_lockpick"]:startLockpick(item, difficulty, pins)

    if success then
        local plate = QBCore.Functions.GetPlate(vehicle)
        local netId = NetworkGetNetworkIdFromEntity(vehicle)

        -- UNLOCKING
        -- We tell the server to update the lock state to 1 (Unlocked)
        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', netId, 1)

        -- KEY GIVING
        -- We tell the server to give the keys to the player
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)

        QBCore.Functions.Notify("Vehicle Unlocked! Keys acquired.", "success")
    else
        QBCore.Functions.Notify("Lockpick failed! Try again.", "error")
    end
end