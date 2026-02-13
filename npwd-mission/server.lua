local QBCore = exports['qb-core']:GetCoreObject()
math.randomseed(os.time())

local PlayerState = {}

local function GenerateInformantNumber()
    return ("%s-%04d"):format("404", math.random(1000, 9999))
end
Config.InformantNumber = GenerateInformantNumber()

local function GetPlayerPhoneNumber(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return (Player and Player.PlayerData.charinfo.phone ~= "") and Player.PlayerData.charinfo.phone or nil
end

local function SendNPWDText(fromNumber, toNumber, text)
    exports.npwd:emitMessage({ senderNumber = fromNumber, targetNumber = toNumber, message = text })
end

RegisterCommand("start_mission", function(source)
    local src = source
    local phone = GetPlayerPhoneNumber(src)
    if not phone then return end
    PlayerState[src] = { phase = "INVITED" }
    SendNPWDText(Config.InformantNumber, phone, Config.Texts.Initial)
    SendNPWDText(Config.InformantNumber, phone, Config.Texts.Help)
    TriggerClientEvent("npwd-mission:client:Notify", src, "message")
end, false)

exports.npwd:onMessage(Config.InformantNumber, function(ctx)
    local src = ctx.source
    local msg = (ctx.data and ctx.data.message or ""):lower()
    local phone = GetPlayerPhoneNumber(src)
    if not phone or not PlayerState[src] then return end

    if msg == "accept" or msg == "yes" or msg == "1" then
        SetTimeout(Config.AcceptDelayMs, function()
            SendNPWDText(Config.InformantNumber, phone, Config.Texts.AcceptAck)
            TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
            TriggerClientEvent("npwd-mission:client:StartC1", src, { x = Config.C1.x, y = Config.C1.y, z = Config.C1.z, w = Config.C1.w })

            SetTimeout(5000, function()
                SendNPWDText(Config.InformantNumber, phone, Config.Texts.PullUp1)
                TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
                SetTimeout(2000, function()
                    SendNPWDText(Config.InformantNumber, phone, Config.Texts.PullUp2)
                    TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
                end)
            end)
            PlayerState[src] = nil
        end)
    elseif msg == "decline" then
        PlayerState[src].phase = "DECLINED"
        SendNPWDText(Config.InformantNumber, phone, Config.Texts.DeclineFollowup)
    end
end)

RegisterNetEvent("npwd-mission:server:LockpickSuccess", function()
    local src = source
    local phone = GetPlayerPhoneNumber(src)
    if phone then
        SendNPWDText(Config.InformantNumber, phone, Config.Texts.LockpickSuccess)
        TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
    end
end)

RegisterNetEvent("npwd-mission:server:PostCutsceneMessages", function()
    local src = source
    local phone = GetPlayerPhoneNumber(src)
    if not phone then return end
    
    SetTimeout(2000, function()
        SendNPWDText(Config.InformantNumber, phone, Config.Texts.PostCutscene)
        TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
    end)
end)

local function GeneratePlate()
    local plate = QBCore.Shared.RandomInt(1)..QBCore.Shared.RandomStr(2)..QBCore.Shared.RandomInt(3)..QBCore.Shared.RandomStr(2)
    return plate:upper()
end

QBCore.Functions.CreateCallback('npwd-mission:server:GetPlate', function(source, cb)
    cb(GeneratePlate())
end)

QBCore.Functions.CreateCallback('npwd-mission:server:SpawnTargetVehicle', function(source, cb, model, loc, plate)
    local veh = CreateVehicle(model, loc.x, loc.y, loc.z, loc.w, true, false)
    SetVehicleNumberPlateText(veh, plate)
    while not DoesEntityExist(veh) do Wait(10) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

RegisterNetEvent('npwd-mission:server:ChopReward', function(type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if type == 'cash' then
        Player.Functions.AddMoney('cash', math.random(810, 2190), 'chopshop-reward')
    else

        local amount = math.random(2, 5)
        Player.Functions.AddItem("metalscrap", amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["metalscrap"], "add", amount)
    end
end)

RegisterNetEvent('npwd-mission:server:DeleteVehicle', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    DeleteEntity(vehicle)
end)

RegisterNetEvent("npwd-mission:server:JamalEscape", function()
    local src = source
    local phone = GetPlayerPhoneNumber(src)
    if phone then
        SendNPWDText(Config.InformantNumber, phone, Config.Texts.JamalRun)
        TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
    end
end)