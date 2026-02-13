local QBCore = exports['qb-core']:GetCoreObject()

local activeC1 = false
local C1 = nil
local C1Blip = nil
local activeC2 = false
local C2 = Config.C2
local C2Blip = nil
local CUTSCENE_ACTIVE = false
local isChopping = false 

local areaZone = nil
local areaBlip = nil
local chopVehicle = 0
local dropOffZone = nil
local dropOffBlip = nil
local props = {} 

local targetPlate = nil
local targetModelName = nil

local vehMods = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 22 }

local function ShowMissionResult(title, subtitle, isSuccess)
    local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    PushScaleformMovieMethodParameterString(title)
    PushScaleformMovieMethodParameterString(subtitle)
    PushScaleformMovieMethodParameterInt(isSuccess and 100 or 90)
    PushScaleformMovieFunctionParameterBool(false)
    PushScaleformMovieFunctionParameterBool(false)
    EndScaleformMovieMethod()
    CreateThread(function()
        local timer = GetGameTimer() + 5000
        while GetGameTimer() < timer do
            Wait(0)
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
        end
        SetScaleformMovieAsNoLongerNeeded(scaleform)
    end)
end

local function Alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function PlayMessageSound()
    if Config.ClientSound then
        PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
    end
end

local function Subtitle(text, durationMs)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandPrint(durationMs or 2000, true)
end

local function TriggerIncomingCall(soundFile, callerName, duration)
    local ped = PlayerPedId()
    local waitingForAnswer = true
    local phoneProp = nil 
    local lastRingTime = 0 

    CreateThread(function()
        local maxWait = 0
        while waitingForAnswer do
            Wait(0)
            maxWait = maxWait + 1

            if GetGameTimer() - lastRingTime > 3500 then
                TriggerServerEvent('InteractSound_SV:PlayOnSource', 'cellcall', 0.5)
                lastRingTime = GetGameTimer()
            end

            if maxWait > 2000 then 
                waitingForAnswer = false 
                QBCore.Functions.Notify("Call missed.", "error")
                return 
            end

            SetTextComponentFormat("STRING")
            AddTextComponentString("Incoming Call: ~b~" .. callerName .. "~n~~w~Press ~g~[E]~w~ to Answer")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustPressed(0, 38) then 
                waitingForAnswer = false

                local model = `prop_npc_phone_02`
                RequestModel(model)
                while not HasModelLoaded(model) do Wait(0) end

                phoneProp = CreateObject(model, 0, 0, 0, true, true, false)
                AttachEntityToEntity(phoneProp, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

                TriggerServerEvent('InteractSound_SV:PlayOnSource', soundFile, 1.0)

                local animDict = "cellphone@"
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do Wait(0) end
                TaskPlayAnim(ped, animDict, "cellphone_call_listen_base", 3.0, -1, -1, 50, 0, false, false, false)

                QBCore.Functions.Notify("Call Connected...", "success")

                CreateThread(function()

                    Subtitle("Hehe, yeah, my G.", 2000)
                    Wait(2000)

                    Subtitle("What's good!", 1000)
                    Wait(1000)

                    Subtitle("This is Josef. Laquisha's contact", 2500)
                    Wait(2500)

                    Subtitle("Yeah, tell her that,", 1500)
                    Wait(1500)

                    Subtitle("I ain't in this thing no more.", 2500)
                    Wait(2500)

                    Subtitle("I ain't got that 'dough' no more!", 2000)
                    Wait(2000)

                    Subtitle("To get myself free from the COPS, my G!", 3500)
                    Wait(3500)

                    Subtitle("I ain't doin this no more", 1500)
                    Wait(1500)

                    Subtitle("I am here enjoying", 1300)
                    Wait(1300)

                    Subtitle("Some ZAZA and some PIZZA", 1500)
                    Wait(1500)

                    Subtitle("I am chillin the hell out", 2200)
                    Wait(2200)

                    Subtitle("Yeah, you better tell her that", 1800)
                    Wait(1800)

                    Subtitle("she better pay up her rent", 1300)
                    Wait(1300)

                    Subtitle("and find anotha guy for the job, G!!", 2400)
                    Wait(2400)

                    Subtitle("Aight, Too-da-loo my MAN!", 2500)
                end)

                Wait(duration) 

                if DoesEntityExist(phoneProp) then DeleteEntity(phoneProp) end
                StopAnimTask(ped, animDict, "cellphone_call_listen_base", 1.0)
                QBCore.Functions.Notify("Call Ended", "primary")
            end
        end
    end)
end

local function LoadAnimationDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

local function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y+0.015, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

local function DrawMissionHUD()
    CreateThread(function()
        while targetPlate do 

            Wait(0)

            if not targetPlate then break end 

            local x, y = 0.90, 0.20 

            DrawRect(x, y, 0.16, 0.08, 0, 0, 0, 150)

            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextRightJustify(true)
            SetTextWrap(0.0, x + 0.07) 
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName("~y~STEAL TO ORDER")
            EndTextCommandDisplayText(x + 0.07, y - 0.03)

            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            BeginTextCommandDisplayText("STRING")

            AddTextComponentSubstringPlayerName("Model: ~b~" .. string.upper(tostring(targetModelName or "Unknown")))
            EndTextCommandDisplayText(x - 0.07, y)

            BeginTextCommandDisplayText("STRING")

            AddTextComponentSubstringPlayerName("Plate: ~g~" .. targetPlate)
            EndTextCommandDisplayText(x - 0.07, y + 0.025)
        end
    end)
end

local function SpawnCarPartInHand(partName)
    local playerPed = PlayerPedId()
    local boneIndex = GetPedBoneIndex(playerPed, 57005)
    local prop = CreateObject(GetHashKey(partName), 0, 0, 0, true, true, true)
    AttachEntityToEntity(prop, playerPed, boneIndex, 0.1, 0.5, -0.3, 0.0, 0.0, 90.0, true, true, false, true, 1, true)
    return prop
end

local function ChopVehicleAction(veh)
    local ped = PlayerPedId()
    TaskLeaveVehicle(ped, veh, 0)
    FreezeEntityPosition(veh, true)
    Wait(1500)

    local chopParts = {
        { part = 0, bone = 'door_dside_f', text = 'Front Left Door', prop = "prop_car_door_01" },
        { part = 1, bone = 'door_pside_f', text = 'Front Right Door', prop = "prop_car_door_01" },
        { part = 2, bone = 'door_dside_r', text = 'Rear Left Door', prop = "prop_car_door_01" },
        { part = 3, bone = 'door_pside_r', text = 'Rear Right Door', prop = "prop_car_door_01" },
        { part = 4, bone = 'bonnet', text = 'Hood', prop = "prop_car_bonnet_02" },
        { part = 5, bone = 'boot', text = 'Trunk', prop = "prop_car_bonnet_02" },

        { part = 0, bone = 'wheel_lf', text = 'Front Left Wheel', isWheel = true, prop = "prop_wheel_01" },
        { part = 1, bone = 'wheel_rf', text = 'Front Right Wheel', isWheel = true, prop = "prop_wheel_01" },
        { part = 4, bone = 'wheel_lr', text = 'Rear Left Wheel', isWheel = true, prop = "prop_wheel_01" },
        { part = 5, bone = 'wheel_rr', text = 'Rear Right Wheel', isWheel = true, prop = "prop_wheel_01" }
    }

    for _, partInfo in ipairs(chopParts) do
        local boneIndex = GetEntityBoneIndexByName(veh, partInfo.bone)

        if boneIndex ~= -1 then
            local coords = GetWorldPositionOfEntityBone(veh, boneIndex)

            while true do
                Wait(0)
                DrawText3Ds(coords.x, coords.y, coords.z, "Press [~g~E~w~] to chop ".. partInfo.text)

                if #(GetEntityCoords(ped) - coords) < 1.5 and IsControlJustReleased(1, 38) then 

                    TaskTurnPedToFaceCoord(ped, coords.x, coords.y, coords.z, 1500)
                    Wait(1500) 

                    break 
                end
            end

            if not partInfo.isWheel then
                SetVehicleDoorOpen(veh, partInfo.part, false, false)
            end

            if partInfo.isWheel then

                local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
                local animName = "machinic_loop_mechandplayer"
                LoadAnimationDict(animDict)

                TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            else

                TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_WELDING', 0, true)
            end

            Wait(10000) 
            ClearPedTasksImmediately(ped)

            if partInfo.isWheel then
                SetVehicleTyreBurst(veh, partInfo.part, true, 1000.0)
            else
                SetVehicleDoorBroken(veh, partInfo.part, true)
            end

            local prop = SpawnCarPartInHand(partInfo.prop)
            table.insert(props, prop)

            LoadAnimationDict("anim@heists@box_carry@")
            TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)

            Wait(2000)
            DeleteEntity(prop)
            ClearPedTasks(ped)

            TriggerServerEvent('npwd-mission:server:ChopReward', partInfo.text:gsub(" ", "_"):lower())
        end
    end

    QBCore.Functions.Notify("Vehicle chopped completely!", "success")
    TriggerServerEvent('npwd-mission:server:ChopReward', 'cash')
    chopVehicle = 0
    NetworkFadeOutEntity(veh, true, false)
    Wait(2000)
    TriggerServerEvent("npwd-mission:server:DeleteVehicle", NetworkGetNetworkIdFromEntity(veh))

    Wait(3000)
    TriggerIncomingCall("josef_call", "Josef", 29500)
    Wait(29500)
    local spawnPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0) 

    CreateThread(function()
        Subtitle("Then whose car was it?", 5000)
    end)
    Wait(5000) 

    QBCore.Functions.SpawnVehicle("banshee2", function(banshee)
        local plate = QBCore.Functions.GetPlate(banshee)
        SetVehicleNumberPlateText(banshee, plate)
        SetEntityHeading(banshee, GetEntityHeading(ped))
        SetVehicleDoorsLocked(banshee, 1) 
        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)

        TriggerServerEvent("npwd-mission:server:JamalEscape")

        local dest = Config.C1
        local destBlip = AddBlipForCoord(dest.x, dest.y, dest.z)
        SetBlipSprite(destBlip, 1)
        SetBlipRoute(destBlip, true)
        SetBlipColour(destBlip, 5) 

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Meetup Point")
        EndTextCommandSetBlipName(destBlip)

        QBCore.Functions.Notify("Drive back to the start! You have 7 minutes!", "error", 5000)

        CreateThread(function()
            local timeLimit = 7 * 60 * 1000 
            local startTime = GetGameTimer()
            local active = true

            while active do
                Wait(0) 

                local timeLeft = timeLimit - (GetGameTimer() - startTime)
                local seconds = math.ceil(timeLeft / 1000)
                local mins = math.floor(seconds / 60)
                local secs = seconds % 60

                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextOutline()
                SetTextCentre(true)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(string.format("ESCAPE TIME: ~r~%02d:%02d", mins, secs))
                EndTextCommandDisplayText(0.5, 0.95)

                DrawMarker(1, dest.x, dest.y, dest.z - 1.0, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)

                local dist = #(GetEntityCoords(PlayerPedId()) - vector3(dest.x, dest.y, dest.z))

                if dist < 5.0 then
                    active = false
                    RemoveBlip(destBlip)

                    DoScreenFadeOut(1000)
                    while not IsScreenFadedOut() do Wait(10) end

                    Wait(1500) 

                    DoScreenFadeIn(1000)

                    ShowMissionResult("MISSION PASSED", "You made it back in time!", true)
                    Wait(5500)

                    QBCore.Functions.Notify("You made it safe!", "success")
                end

                if timeLeft <= 0 then
                    active = false
                    RemoveBlip(destBlip)

                    ShowMissionResult("MISSION FAILED", "You ran out of time!", false)
                    Wait(5500)

                    QBCore.Functions.Notify("You ran out of time!", "error")
                end
            end
        end)

    end, vector4(spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(ped)), true)
end

local function StartChopJob()

    local model = Config.Vehicles[math.random(#Config.Vehicles)]
    local vehLoc = Config.TargetLocations[math.random(#Config.TargetLocations)]
    targetModelName = model
    QBCore.Functions.TriggerCallback('npwd-mission:server:GetPlate', function(plate)

        targetPlate = plate
        DrawMissionHUD()
        SetNewWaypoint(vehLoc.x, vehLoc.y)
        Alert("Check your GPS")

        areaBlip = AddBlipForRadius(vehLoc.x, vehLoc.y, vehLoc.z, 200.0)
        SetBlipColour(areaBlip, 1)
        SetBlipAlpha(areaBlip, 128)

        areaZone = CircleZone:Create(vector3(vehLoc.x, vehLoc.y, vehLoc.z), 200.0, { name = "chop_search", debugPoly = false })

        areaZone:onPlayerInOut(function(isPointInside)
            if isPointInside and chopVehicle == 0 then

                QBCore.Functions.TriggerCallback('npwd-mission:server:SpawnTargetVehicle', function(netId)
                    while not NetworkDoesEntityExistWithNetworkId(netId) do Wait(10) end
                    chopVehicle = NetworkGetEntityFromNetworkId(netId)

                    SetVehicleDoorsLocked(chopVehicle, 2)
                    exports['qb-target']:AddTargetEntity(chopVehicle, {
                        options = {
                            {
                                icon = "fas fa-user-secret",
                                label = "Lockpick Target",
                                action = function(entity)
                                    local success = exports['t3_lockpick']:startLockpick('lockpick', 4, 5)
                                    if success then
                                        SetVehicleDoorsLocked(entity, 1)
                                        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
                                        QBCore.Functions.Notify("Unlocked!", "success")
                                        exports['qb-target']:RemoveTargetEntity(entity, "Lockpick Target")
                                    else
                                        QBCore.Functions.Notify("Failed!", "error")
                                    end
                                end,
                                canInteract = function(entity) return GetVehicleDoorLockStatus(entity) == 2 end
                            }
                        },
                        distance = 2.5
                    })
                end, model, vehLoc, plate)

                areaZone:destroy()
                QBCore.Functions.Notify("The vehicle is nearby. Find it!", "success")
            end
        end)

        CreateThread(function()
            local found = false
            while not found do
                Wait(1000)
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh ~= 0 and GetVehicleNumberPlateText(veh) == plate then
                    chopVehicle = veh
                    found = true
                    targetPlate = nil
                    targetModelName = model
                    RemoveBlip(areaBlip)

                    local dropLoc = Config.DropOffLocations[math.random(#Config.DropOffLocations)]
                    SetNewWaypoint(dropLoc.x, dropLoc.y)
                    QBCore.Functions.Notify("Got it! Bring it back to the Scrapyard.", "success")

                    dropOffBlip = AddBlipForCoord(dropLoc.x, dropLoc.y, dropLoc.z)
                    SetBlipSprite(dropOffBlip, 227)
                    SetBlipColour(dropOffBlip, 2)
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentString("Chop Dropoff")
                    EndTextCommandSetBlipName(dropOffBlip)

                    dropOffZone = CircleZone:Create(dropLoc, 4.0, { name = "chop_drop", debugPoly = false })
                    dropOffZone:onPlayerInOut(function(inZone)
                        if inZone and not isChopping then
                            if GetVehiclePedIsIn(PlayerPedId(), false) == chopVehicle then
                                exports['qb-core']:DrawText('[E] Chop Vehicle', 'left')
                                CreateThread(function()
                                    while inZone and not isChopping do
                                        if IsControlJustPressed(0, 38) then
                                            isChopping = true
                                            exports['qb-core']:HideText()
                                            ChopVehicleAction(chopVehicle)
                                            dropOffZone:destroy()
                                            RemoveBlip(dropOffBlip)
                                            isChopping = false
                                            break
                                        end
                                        Wait(0)
                                    end
                                end)
                            end
                        else
                            exports['qb-core']:HideText()
                        end
                    end)
                end
            end
        end)
    end)
end

local function ClearC1()
    activeC1 = false
    C1 = nil
    if C1Blip then RemoveBlip(C1Blip); C1Blip = nil end
end

local function ClearC2()
    activeC2 = false
    if C2Blip then RemoveBlip(C2Blip); C2Blip = nil end
end

local function StartScrapyardInteraction()

    activeC2 = false
    ClearC2()

    DoScreenFadeOut(3000) 

    while not IsScreenFadedOut() do Wait(10) end

    local pedModel = `ig_josef`
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(0) end

    local josef = CreatePed(4, pedModel, 2339.44, 3051.93, 47.15, 273.39, false, true)

    FreezeEntityPosition(josef, true)
    SetEntityInvincible(josef, true)
    SetBlockingOfNonTemporaryEvents(josef, true)

    SetEntityAsMissionEntity(josef, true, true) 

    Wait(2000) 

    DoScreenFadeIn(3000) 

    while not IsScreenFadedIn() do Wait(10) end

    Alert("Talk to Josef to get the target.")
    StartChopJob()
end

local function StartSecondStage()
    activeC2 = true
    if C2Blip then RemoveBlip(C2Blip) end
    C2Blip = AddBlipForCoord(C2.x, C2.y, C2.z)
    SetBlipSprite(C2Blip, 1)
    SetBlipRoute(C2Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meet Contact")
    EndTextCommandSetBlipName(C2Blip)
    Alert("New location set.")
end

RegisterNetEvent("npwd-mission:client:Notify", function(kind)
    if Config.ClientPopupAlert then Alert(kind == "new_message" and "You have a new message" or "You have a message") end
    if Config.ClientSound then PlayMessageSound() end
end)

RegisterNetEvent("npwd-mission:client:StartC1", function(data)
    C1 = vector4(data.x, data.y, data.z, data.w)
    activeC1 = true
    if C1Blip then RemoveBlip(C1Blip) end
    C1Blip = AddBlipForCoord(C1.x, C1.y, C1.z)
    SetBlipSprite(C1Blip, 1)
    SetBlipRoute(C1Blip, true)
    Alert("Location pinged.")
end)

RegisterNetEvent("npwd-mission:client:ResetMission", function()
    ClearC1()
    ClearC2()
    Alert("Mission reset.")
end)

local function MissionLockpickSuccess(vehicle)
    local plate = QBCore.Functions.GetPlate(vehicle)
    SetVehicleDoorsLocked(vehicle, 1)
    TriggerServerEvent("qb-vehiclekeys:server:setVehLockState", NetworkGetNetworkIdFromEntity(vehicle), 1)
    TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
    QBCore.Functions.Notify("Vehicle Unlocked!", "success")
    TriggerServerEvent("npwd-mission:server:LockpickSuccess")
    StartSecondStage()
end

local function StartMissionLockpick(vehicle)
    local difficulty = 1
    local pins = 4
    local success = exports["t3_lockpick"]:startLockpick("lockpick", difficulty, pins)

    if success then
        MissionLockpickSuccess(vehicle)
        exports["qb-target"]:RemoveTargetEntity(vehicle, "MissionLockpick")
    else
        QBCore.Functions.Notify("Lockpick failed. Try again.", "error")
    end
end

local function SpawnMissionCar()
    local model = "sultan"
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityHeading(veh, Config.CarSpawn.w)
        SetVehicleDoorsLocked(veh, 2)
        TriggerServerEvent("qb-vehiclekeys:server:setVehLockState", NetworkGetNetworkIdFromEntity(veh), 2)
        exports["qb-target"]:AddTargetEntity(veh, {
            options = {
                {
                    icon = "fas fa-lock",
                    label = "Lockpick Mission Car",
                    action = function() StartMissionLockpick(veh) end,
                    canInteract = function() return GetVehicleDoorLockStatus(veh) == 2 end,
                    name = "MissionLockpick"
                }
            },
            distance = 2.5
        })
    end, Config.CarSpawn, true)
end

local function LoadModel(model)
    local hash = type(model) == "number" and model or joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    return hash
end

local function StopCams() RenderScriptCams(false, true, 400, true, true) end
local function DestroyCamSafe(cam) if cam and DoesCamExist(cam) then DestroyCam(cam, false) end end
local function SafeDeletePed(ped) if ped and DoesEntityExist(ped) then DeleteEntity(ped) end end
local function CreateCamAt(pos, rot, fov) return CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, fov or 50.0, true, 2) end

function StartInformantCutscene()
    if CUTSCENE_ACTIVE then return end
    CUTSCENE_ACTIVE = true
    local playerPed = PlayerPedId()
    local playerPos = vector3(329.6381, -210.1057, 54.0863)
    local playerHeading = 85.8988

    local pedPos = vector3(327.2242, -209.7443, 53.0863) 
    local pedHeading = 258.7648

    local pedHash = LoadModel("g_f_y_families_01")
    LoadAnimationDict("switch@michael@talks_to_guard")
    LoadAnimationDict("missheistfbi_fire")

    DoScreenFadeOut(700)
    while not IsScreenFadedOut() do Wait(0) end

    FreezeEntityPosition(playerPed, true)
    SetEntityCoordsNoOffset(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    SetEntityHeading(playerPed, playerHeading)
    ClearPedTasksImmediately(playerPed)

    local talkPed = CreatePed(4, pedHash, pedPos.x, pedPos.y, pedPos.z, pedHeading, false, true)

    PlaceObjectOnGroundProperly(talkPed) 
    FreezeEntityPosition(talkPed, true)
    SetEntityAsMissionEntity(talkPed, true, true)
    SetBlockingOfNonTemporaryEvents(talkPed, true)

    TaskPlayAnim(playerPed, "switch@michael@talks_to_guard", "001393_02_mics3_3_talks_to_guard_idle_guard", 8.0, -8.0, -1, 1, 0.0, false, false, false)
    TaskPlayAnim(talkPed, "missheistfbi_fire", "two_talking", 8.0, -8.0, -1, 1, 0.0, false, false, false)

    local camSide = CreateCamAt(vector3(326.5, -213, 54.4), vector3(-3.6, 1.0, 329), 50.0)
    local camPlayer = CreateCamAt(vector3(332, -209, 55.0), vector3(-8.0, 0.0, 104.0), 45.0)
    local camPed = CreateCamAt(vector3(324.5, -210.97, 55.0), vector3(-10.0, 0.0, 282.0), 45.0)

    SetCamActive(camSide, true)
    RenderScriptCams(true, true, 600, true, true)
    DoScreenFadeIn(700)
    while not IsScreenFadedIn() do Wait(0) end
    DisplayRadar(false)

    Wait(5000)
    SetCamActive(camSide, false); SetCamActive(camPed, true); RenderScriptCams(true, true, 500, true, true)
    Subtitle("What's the job", 5000)
    Wait(5000)
    SetCamActive(camPed, false); SetCamActive(camPlayer, true); RenderScriptCams(true, true, 500, true, true)
    Subtitle("No holla??? Man you rusty.", 4000)
    Wait(4000)
    Subtitle("Anyways, we gotta 'steal' this car.", 5000)
    Wait(5000)
    Subtitle("AND CHOP IT UP!!!", 3000)
    Wait(3000)
    SetCamActive(camPlayer, false); SetCamActive(camSide, true); RenderScriptCams(true, true, 500, true, true)
    Wait(3000)
    SetCamActive(camSide, false); SetCamActive(camPed, true); RenderScriptCams(true, true, 500, true, true)
    Subtitle("What do I get?", 3000)
    Wait(3000)
    SetCamActive(camPed, false); SetCamActive(camPlayer, true); RenderScriptCams(true, true, 500, true, true)
    Subtitle("My loooove and some dough.", 4000)
    Wait(4000)
    Subtitle("SO! You IN?", 2000)
    Wait(2000)

    DoScreenFadeOut(700)
    while not IsScreenFadedOut() do Wait(0) end
    StopCams()
    DestroyCamSafe(camSide); DestroyCamSafe(camPlayer); DestroyCamSafe(camPed)
    ClearPedTasksImmediately(playerPed)
    FreezeEntityPosition(playerPed, false)
    SafeDeletePed(talkPed)
    DisplayRadar(true)
    DoScreenFadeIn(700)
    while not IsScreenFadedIn() do Wait(0) end
    CUTSCENE_ACTIVE = false

    Wait(500)
    ShowMissionResult("MISSION STARTED", "Steal the car and chop it up!", true)
    Wait(5500)

    SpawnMissionCar()
    TriggerServerEvent("npwd-mission:server:PostCutsceneMessages")
end

CreateThread(function()
    while true do
        if not activeC1 or not C1 then
            Wait(1000)
        else
            Wait(0)
            DrawMarker(Config.Marker.type, C1.x, C1.y, C1.z - Config.Marker.zOffset, 0, 0, 0, 0, 0, 0, Config.Marker.scale, Config.Marker.scale, Config.Marker.scale, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, true, 2, false, nil, nil, false)
            if #(GetEntityCoords(PlayerPedId()) - vector3(C1.x, C1.y, C1.z)) <= 2.0 then
                ClearC1()
                StartInformantCutscene()
            end
        end
    end
end)

CreateThread(function()
    while true do
        if not activeC2 then
            Wait(1000)
        else
            Wait(0)
            DrawMarker(Config.Marker.type, C2.x, C2.y, C2.z - Config.Marker.zOffset, 0, 0, 0, 0, 0, 0, Config.Marker.scale, Config.Marker.scale, Config.Marker.scale, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, true, 2, false, nil, nil, false)
            if #(GetEntityCoords(PlayerPedId()) - C2) <= 4.0 then

                StartScrapyardInteraction() 
            end
        end
    end
end)

