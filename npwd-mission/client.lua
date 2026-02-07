-- Modified client.lua: Only alerts and sounds remain
local function Alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function PlayMessageSound()
    PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
end

-- Listen for notification triggers from the server
RegisterNetEvent("npwd-mission:client:Notify", function(kind)
    if Config.ClientPopupAlert then
        if kind == "new_message" then
            Alert("You have a new message")
        else
            Alert("You have a message")
        end
    end
    if Config.ClientSound then
        PlayMessageSound()
    end
end)

local activeC1 = false
local C1 = nil
local C1Blip = nil

local function ClearC1()
    activeC1 = false
    C1 = nil
    if C1Blip then
        RemoveBlip(C1Blip)
        C1Blip = nil
    end
end

local function CreateRouteBlip(x, y, z)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, 1)
    SetBlipScale(blip, 0.9)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meet Location")-- client.lua
-- NPWD notify + marker ping + local-only cinematic cutscene

-- =====================
-- Basic UI helpers
-- =====================
local function Alert(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function PlayMessageSound()
    PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", true)
end

local function Subtitle(text, durationMs)
    -- Standard GTA subtitles at bottom
    ClearPrints()
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandPrint(durationMs or 2000, true)
end

-- Listen for notification triggers from the server
RegisterNetEvent("npwd-mission:client:Notify", function(kind)
    if Config.ClientPopupAlert then
        if kind == "new_message" then
            Alert("You have a new message")
        else
            Alert("You have a message")
        end
    end
    if Config.ClientSound then
        PlayMessageSound()
    end
end)

-- =====================
-- Marker / Ping (C1)
-- =====================
local activeC1 = false
local C1 = nil
local C1Blip = nil

local function ClearC1()
    activeC1 = false
    C1 = nil
    if C1Blip then
        RemoveBlip(C1Blip)
        C1Blip = nil
    end
end

local function CreateRouteBlip(x, y, z)
    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, 1)
    SetBlipScale(blip, 0.9)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meet Location")
    EndTextCommandSetBlipName(blip)
    return blip
end

RegisterNetEvent("npwd-mission:client:StartC1", function(data)
    C1 = vector4(data.x, data.y, data.z, data.w)
    activeC1 = true

    if C1Blip then RemoveBlip(C1Blip) end
    C1Blip = CreateRouteBlip(C1.x, C1.y, C1.z)

    Alert("Location pinged.")
end)

-- =====================
-- Cutscene
-- =====================
local CUTSCENE_ACTIVE = false

local function LoadModel(model)
    local hash = type(model) == "number" and model or joaat(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    return hash
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end
end

local function StopCams()
    RenderScriptCams(false, true, 400, true, true)
end

local function DestroyCamSafe(cam)
    if cam and DoesCamExist(cam) then
        DestroyCam(cam, false)
    end
end

local function SafeDeletePed(ped)
    if ped and DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end

local function CreateCamAt(pos, rot, fov)
    return CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        pos.x, pos.y, pos.z,
        rot.x, rot.y, rot.z,
        fov or 50.0,
        true, 2
    )
end

function StartInformantCutscene()
    if CUTSCENE_ACTIVE then return end
    CUTSCENE_ACTIVE = true

    local playerPed = PlayerPedId()

    -- Fixed positions (from you)
    local playerPos = vector3(329.6381, -210.1057, 54.0863)
    local playerHeading = 85.8988

    local pedPos = vector3(327.2242, -209.7443, 54.0863)
    local pedHeading = 258.7648

    -- Load assets
    local pedHash = LoadModel("g_f_y_families_01")

    local playerAnimDict = "switch@michael@talks_to_guard"
    local playerAnimName = "001393_02_mics3_3_talks_to_guard_idle_guard"
    LoadAnimDict(playerAnimDict)

    local pedAnimDict = "missheistfbi_fire"
    local pedAnimName = "two_talking"
    LoadAnimDict(pedAnimDict)

    -- Fade out to set up
    DoScreenFadeOut(700)
    while not IsScreenFadedOut() do Wait(0) end

    -- Freeze + position player
    FreezeEntityPosition(playerPed, true)
    SetEntityCoordsNoOffset(playerPed, playerPos.x, playerPos.y, playerPos.z, false, false, false)
    SetEntityHeading(playerPed, playerHeading)
    ClearPedTasksImmediately(playerPed)

    -- Spawn ped (LOCAL ONLY)
    local talkPed = CreatePed(
        4, pedHash,
        pedPos.x, pedPos.y, pedPos.z,
        pedHeading,
        false,  -- not networked
        true
    )

    -- Ensure ground/collision is ready
RequestCollisionAtCoord(pedPos.x, pedPos.y, pedPos.z)
local timeout = GetGameTimer() + 2000
while not HasCollisionLoadedAroundEntity(talkPed) and GetGameTimer() < timeout do
    Wait(0)
end

-- Snap ped to ground (prevents floating)
SetEntityCoordsNoOffset(talkPed, pedPos.x, pedPos.y, pedPos.z, false, false, false)
PlaceObjectOnGroundProperly(talkPed)

-- Small settle wait before freezing
Wait(50)

FreezeEntityPosition(talkPed, true)


    SetEntityAsMissionEntity(talkPed, true, true)
    SetBlockingOfNonTemporaryEvents(talkPed, true)
    SetPedCanRagdoll(talkPed, false)
    FreezeEntityPosition(talkPed, true)
    ClearPedTasksImmediately(talkPed)

    -- Loop talk anims
    TaskPlayAnim(playerPed, playerAnimDict, playerAnimName, 8.0, -8.0, -1, 1, 0.0, false, false, false)
    TaskPlayAnim(talkPed, pedAnimDict, pedAnimName, 8.0, -8.0, -1, 1, 0.0, false, false, false)

    -- Cameras (you’ll tweak these later for perfect framing)
    local camSidePos = vector3(327.5011, -211.8373, 54.0863)
    local camSideRot = vector3(-8.0, 0.0, 329.7299)

    local camPlayerPos = vector3(331.2, -210.2, 55.0)
    local camPlayerRot = vector3(-8.0, 0.0, 90.0)

    local camPedPos = vector3(326.0, -209.7, 55.0)
    local camPedRot = vector3(-8.0, 0.0, 270.0)

    local camSide = CreateCamAt(camSidePos, camSideRot, 50.0)
    local camPlayer = CreateCamAt(camPlayerPos, camPlayerRot, 45.0)
    local camPed = CreateCamAt(camPedPos, camPedRot, 45.0)

    -- Start cam
    SetCamActive(camSide, true)
    RenderScriptCams(true, true, 600, true, true)

    -- Fade in to scene
    DoScreenFadeIn(700)
    while not IsScreenFadedIn() do Wait(0) end

    DisplayRadar(false)

    -- [5s side view of them talking]
    Wait(5000)

    -- [5s] (Cam facing player) Player : "What's the job"
    SetCamActive(camSide, false)
    SetCamActive(camPed, true)
    RenderScriptCams(true, true, 500, true, true)
    Subtitle("What's the job", 5000)
    Wait(5000)

    -- [4s] (Cam facing ped) PED : No holla??? Man you rusty.
    SetCamActive(camPed, false)
    SetCamActive(camPlayer, true)
    RenderScriptCams(true, true, 500, true, true)
    Subtitle("No holla??? Man you rusty.", 4000)
    Wait(4000)

    -- [5s] PED : Anyways, we gotta tail this car.
    Subtitle("Anyways, we gotta tail this car.", 5000)
    Wait(5000)

    -- [3s] PED : AND CHOP IT UP!!!
    Subtitle("AND CHOP IT UP!!!", 3000)
    Wait(3000)

    -- [3s pause]
    ClearPrints()
    Wait(3000)

    -- [3s] (Cam to player) Player : What do I get?
    SetCamActive(camPlayer, false)
    SetCamActive(camPed, true)
    RenderScriptCams(true, true, 500, true, true)
    Subtitle("What do I get?", 3000)
    Wait(3000)

    -- [4s] (Cam to ped) PED : My loooove and some dough.
    SetCamActive(camPed, false)
    SetCamActive(camPlayer, true)
    RenderScriptCams(true, true, 500, true, true)
    Subtitle("My loooove and some dough.", 4000)
    Wait(4000)

    -- [2s] PED : You IN?
    Subtitle("SO! You IN?", 2000)
    Wait(2000)

    -- Fade out -> cleanup -> fade in
    DoScreenFadeOut(700)
    while not IsScreenFadedOut() do Wait(0) end

    StopCams()
    DestroyCamSafe(camSide)
    DestroyCamSafe(camPlayer)
    DestroyCamSafe(camPed)

    ClearPedTasksImmediately(playerPed)
    FreezeEntityPosition(playerPed, false)

    SafeDeletePed(talkPed)

    DisplayRadar(true)

    DoScreenFadeIn(700)
    while not IsScreenFadedIn() do Wait(0) end

    CUTSCENE_ACTIVE = false
end

-- Thread: draw marker & detect arrival
CreateThread(function()
    while true do
        if not activeC1 or not C1 then
            Wait(500)
        else
            Wait(0)

            DrawMarker(
                Config.Marker.type,
                C1.x, C1.y, C1.z - Config.Marker.zOffset,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                Config.Marker.scale, Config.Marker.scale, Config.Marker.scale,
                Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(C1.x, C1.y, C1.z))

            if dist <= 2.0 then
                -- vanish marker and start cutscene
                ClearC1()
                StartInformantCutscene()
            end
        end
    end
end)

-- Optional: if you later add /reset_mission on server, you can call this
RegisterNetEvent("npwd-mission:client:ResetMission", function()
    ClearC1()
    Alert("Mission reset.")
end)

    EndTextCommandSetBlipName(blip)
    return blip
end

RegisterNetEvent("npwd-mission:client:StartC1", function(data)
    C1 = vector4(data.x, data.y, data.z, data.w)
    activeC1 = true

    if C1Blip then RemoveBlip(C1Blip) end
    C1Blip = CreateRouteBlip(C1.x, C1.y, C1.z)

    Alert("Location pinged.")
end)

CreateThread(function()
    while true do
        if not activeC1 or not C1 then
            Wait(500)
        else
            Wait(0)

            DrawMarker(
                Config.Marker.type,
                C1.x,
                C1.y,
                C1.z - Config.Marker.zOffset,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                Config.Marker.scale,
                Config.Marker.scale,
                Config.Marker.scale,
                Config.Marker.r,
                Config.Marker.g,
                Config.Marker.b,
                Config.Marker.a,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local dist = #(pos - vector3(C1.x, C1.y, C1.z))

            if dist <= 2.0 then
                Alert("You reached the location.")
                ClearC1()
            end
        end
    end
end)
