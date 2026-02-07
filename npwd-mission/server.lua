local QBCore = exports['qb-core']:GetCoreObject()
math.randomseed(os.time())

local PlayerState = {}

local function GenerateInformantNumber()
    local prefix = "404"
    local suffix = math.random(1000, 9999)
    return ("%s-%04d"):format(prefix, suffix)
end

Config.InformantNumber = GenerateInformantNumber()

local function NormalizeMsg(msg)
    msg = (msg or ""):lower()
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
    return msg
end

local function GetPlayerPhoneNumber(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData.charinfo.phone ~= "" then
        return Player.PlayerData.charinfo.phone
    end
    return nil
end

local function SendNPWDText(fromNumber, toNumber, text)
    exports.npwd:emitMessage({
        senderNumber = fromNumber,
        targetNumber = toNumber,
        message = text
    })
end

-- Trigger the initial interaction
RegisterCommand("start_mission", function(source)
    local src = source
    local phone = GetPlayerPhoneNumber(src)
    if not phone then return end

    PlayerState[src] = { phase = "INVITED" }

    SendNPWDText(Config.InformantNumber, phone, Config.Texts.Initial)
    SendNPWDText(Config.InformantNumber, phone, Config.Texts.Help)
    TriggerClientEvent("npwd-mission:client:Notify", src, "message")
end, false)

-- Handle replies for NPWD
exports.npwd:onMessage(Config.InformantNumber, function(ctx)
    local src = ctx.source
    local msg = NormalizeMsg(ctx.data and ctx.data.message or "")
    local phone = GetPlayerPhoneNumber(src)
    if not phone or not PlayerState[src] then return end

    if msg == "accept" or msg == "yes" or msg == "1" then
        SetTimeout(Config.AcceptDelayMs, function()
            -- initial accept ack
            -- FIX: Changed playerPhone to phone
            SendNPWDText(Config.InformantNumber, phone, Config.Texts.AcceptAck)
            TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")

            -- ping C1 + marker
            TriggerClientEvent("npwd-mission:client:StartC1", src, {
                x = Config.C1.x,
                y = Config.C1.y,
                z = Config.C1.z,
                w = Config.C1.w
            })

            -- after 5s → text 1
            SetTimeout(5000, function()
                -- FIX: Changed playerPhone to phone
                SendNPWDText(Config.InformantNumber, phone, Config.Texts.PullUp1)
                TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")

                -- after 2s → text 2
                SetTimeout(2000, function()
                    -- FIX: Changed playerPhone to phone
                    SendNPWDText(Config.InformantNumber, phone, Config.Texts.PullUp2)
                    TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
                end)
            end)

            -- mission now client-driven
            PlayerState[src] = nil
        end)

        return
    -- FIX: Removed the 'end' that was here previously
    elseif msg == "decline" or msg == "no" or msg == "2" then
        PlayerState[src].phase = "DECLINED"
        SetTimeout(Config.DeclineFollowupDelayMs, function()
            SendNPWDText(Config.InformantNumber, phone, Config.Texts.DeclineFollowup)
            TriggerClientEvent("npwd-mission:client:Notify", src, "new_message")
            PlayerState[src] = nil
        end)
    else
        SendNPWDText(Config.InformantNumber, phone, Config.Texts.Help)
    end
end)