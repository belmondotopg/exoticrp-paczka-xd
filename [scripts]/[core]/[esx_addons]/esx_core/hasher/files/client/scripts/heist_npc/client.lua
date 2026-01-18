
local ANIM_DICT = "random@arrests"
local ANIM_NAME = "kneeling_arrest_idle"
local FLEE_DISTANCE = 200.0
local NETWORK_CONTROL_WAIT = 10
local ENTITY_CHECK_WAIT = 10
local ANIM_CHECK_INTERVAL = 350
local CLEANUP_DELAY = 10000
local INITIALIZATION_DELAY = 1000
local OFFSET_DISTANCE = 1.0

local holdupNPC = {}

local allowedPeds = {
    `s_m_m_highsec_01`,
    `s_m_m_strpreach_01`,
    `a_m_y_genstreet_01`,
    `a_m_m_og_boss_01`,
    `U_M_M_BankMan`,
    `s_m_m_autoshop_02`,
    `a_m_y_soucent_02`,
    `a_m_y_cyclist_01`,
    `s_m_y_dealer_01`,
    `a_m_y_business_02`,
    `a_m_y_mexthug_01`,
    `a_m_y_busicas_01`
}

local function getRandomPed()
    return allowedPeds[math.random(1, #allowedPeds)]
end

local function removeNPC(entity)
    if not DoesEntityExist(entity) then
        return
    end

    local attempts = 0
    while not NetworkHasControlOfEntity(entity) and attempts < 50 do
        NetworkRequestControlOfEntity(entity)
        Wait(NETWORK_CONTROL_WAIT)
        attempts = attempts + 1
    end

    if not NetworkHasControlOfEntity(entity) then
        return
    end

    FreezeEntityPosition(entity, false)
    Entity(entity).state:set('IsNiewolnik', false, true)
    SetEntityInvincible(entity, false)
    ClearPedTasks(entity)
    TaskSmartFleePed(entity, PlayerPedId(), FLEE_DISTANCE, -1, false, false)

    CreateThread(function()
        Wait(CLEANUP_DELAY)
        if DoesEntityExist(entity) then
            exports.ox_target:removeLocalEntity(entity)
            DeleteEntity(entity)
        end
    end)
end

local function createHeistPed(heistId, coords, totalNPCs, index)
    local pedModel = getRandomPed()
    lib.requestModel(pedModel)
    lib.requestAnimDict(ANIM_DICT)

    local heading = coords[4] or 0
    local offsetX = math.cos(math.rad(heading)) * OFFSET_DISTANCE
    local offsetY = math.sin(math.rad(heading)) * OFFSET_DISTANCE

    local startX = coords[1] - (totalNPCs - 1) * offsetX / 2
    local startY = coords[2] - (totalNPCs - 1) * offsetY / 2
    local pedX = startX + (index - 1) * offsetX
    local pedY = startY + (index - 1) * offsetY

    local ped = CreatePed(4, pedModel, pedX, pedY, coords[3], heading, true, true)

    if not DoesEntityExist(ped) then
        return nil
    end

    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)

    Entity(ped).state:set('IsNiewolnik', true, true)

    if not holdupNPC[heistId] then
        holdupNPC[heistId] = {}
    end
    table.insert(holdupNPC[heistId], ped)

    CreateThread(function()
        while DoesEntityExist(ped) do
            Wait(ANIM_CHECK_INTERVAL)
            if Entity(ped).state.IsNiewolnik ~= true then
                break
            end
            if not IsEntityPlayingAnim(ped, ANIM_DICT, ANIM_NAME, 3) then
                TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, 8.0, 8.0, -1, 1, 0, 0, 0, 0)
            end
        end
    end)

    return ped
end

local function SetNPC(heistId, coords, countNPC, endHeist)
    CreateThread(function()
        if endHeist then
            return
        end

        holdupNPC[heistId] = {}

        for i = 1, countNPC do
            createHeistPed(heistId, coords, countNPC, i)
        end

        Wait(INITIALIZATION_DELAY)

        if not holdupNPC[heistId] or #holdupNPC[heistId] == 0 then
            return
        end

        local netIDs = {}
        for _, ped in ipairs(holdupNPC[heistId]) do
            if DoesEntityExist(ped) then
                local netID = PedToNet(ped)
                table.insert(netIDs, netID)
            end
        end

        if #netIDs > 0 then
            TriggerServerEvent('esx:core:npc:get', netIDs)
        end

        for _, ped in ipairs(holdupNPC[heistId]) do
            if DoesEntityExist(ped) then
                FreezeEntityPosition(ped, true)
            end
        end
    end)
end

RegisterNetEvent('esx_core:SetNPC')
AddEventHandler('esx_core:SetNPC', function(heistId, countNPC, coords, done)
    SetNPC(heistId, coords, countNPC, done)
end)

RegisterNetEvent('esx_core:setNPCtarget', function(npcs)
    for _, netID in ipairs(npcs) do
        local ped = NetToPed(netID)
        if DoesEntityExist(ped) then
            exports.ox_target:addLocalEntity(ped, {
                {
                    label = "Wypuść zakładnika",
                    name = "uncuff-hostage",
                    icon = "fas fa-handcuffs",
                    onSelect = function(data)
                        removeNPC(data.entity)
                    end,
                }
            })
        end
    end
end)

RegisterNetEvent('esx_core:GetPlayerPositionForHostage', function(token)
    if not token then return end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    TriggerServerEvent('esx_core:CreateHostageAtPosition', {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, heading, token)
end)