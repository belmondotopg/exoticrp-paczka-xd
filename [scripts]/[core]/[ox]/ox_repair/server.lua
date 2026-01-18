local Player = Player

local esx_core = exports.esx_core
local ox_inventory = exports.ox_inventory
local repairs = {}
local resourceName = GetCurrentResourceName()

local function fixWeapon(payload)
    if type(payload) ~= 'table' then return end
    TriggerClientEvent('ox_inventory:closeInventory', payload.source)
    ox_inventory:RemoveItem(payload.source, payload.fromSlot.name, 1)
    repairs[payload.source] = {
        slot = payload.toSlot.slot,
        name = payload.toSlot.name
    }
    TriggerClientEvent('ox_repair:itemRepaired', payload.source, payload.toSlot.name)
end

local function startRepair(src, data, withData)
    repairs[src] = {
        slot = data.slot,
        name = data.name
    }
    if withData then
        TriggerClientEvent('ox_repair:itemRepaired', src, data.name, data)
    else
        TriggerClientEvent('ox_repair:itemRepaired', src, data.name)
    end
    esx_core:SendLog(src, "Naprawa przedmiotu", "Rozpoczął naprawianie przedmiotu `"..data.name.."`", 'crafting-repair')
end

RegisterNetEvent('ox_repair:weaponRepairStarted', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local slot = ox_inventory:GetSlot(src, data.slot)

    if data.playerIndex ~= Player(src).state.playerIndex then
        esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..resourceName, "ac")
        DropPlayer(src, "["..resourceName.."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
        return
    end
    Player(src).state.playerIndex = ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999)

    if not slot or slot.name ~= data.name then return end

    local location = Config.locations[data.bench]
    local pCoords = GetEntityCoords(GetPlayerPed(src))
    if #(pCoords - location.coords) > 10.0 then return end

    if not location.free then
        local weaponConfig = Config.require[data.name]
        local requiredItem = weaponConfig and weaponConfig.requireditem or Config.requireditem
        local requiredAmount = weaponConfig and weaponConfig.requireditemamount or Config.requireditemamount
        local count = ox_inventory:Search(src, 'count', requiredItem)

        if location.job and xPlayer.job.name == "police" then
            startRepair(src, data, false)
            return
        end

        if not count then
            xPlayer.showNotification('Czegoś ci brakuje!')
            return
        end

        if count >= requiredAmount then
            startRepair(src, data, true)
        else
            xPlayer.showNotification('Brakuje ci przedmiotów aby naprawić broń')
        end
    else
        if location.job and xPlayer.job.name ~= "police" then
            xPlayer.showNotification('Nie posiadasz dostępu do tego elementu!')
            return
        end
        startRepair(src, data, true)
    end
end)

RegisterNetEvent('ox_repair:weaponFix', function(playerIndex, data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if Player(src).state.playerIndex then
        if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
            esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..resourceName, "ac")
            DropPlayer(src, "["..resourceName.."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
            return
        end
        Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
    end

    if not repairs[src] then return end

    local slot = ox_inventory:GetSlot(src, repairs[src].slot)
    if not slot or slot.name ~= repairs[src].name then return end

    local weaponConfig = Config.require[data.name]
    local requiredItem = weaponConfig and weaponConfig.requireditem or Config.requireditem
    local requiredAmount = weaponConfig and weaponConfig.requireditemamount or Config.requireditemamount
    local count = ox_inventory:Search(src, 'count', requiredItem)

    if count >= requiredAmount then
        ox_inventory:RemoveItem(src, requiredItem, requiredAmount)
        ox_inventory:SetDurability(src, repairs[src].slot, 100)
    else
        xPlayer.showNotification('Brakuje ci przedmiotów aby naprawić broń')
    end
    repairs[src] = nil
end)

lib.callback.register('openRepairBench', function(source)
    return ox_inventory:Search(source, 'slots', Weapons)
end)

ox_inventory:registerHook('swapItems', function(payload)
    if type(payload.toSlot) ~= 'table' or payload.fromSlot.name ~= Config.repairItem then
        return true
    end
    if not WeaponHashes[payload.toSlot.name] then
        return true
    end
    if payload.toSlot.metadata.durability >= 100.0 then
        TriggerClientEvent('ox_lib:notify', payload.source, {position = 'top', type = 'error', description = 'Broń nie potrzebuje naprawy'})
        return false
    end
    Citizen.CreateThread(function() fixWeapon(payload) end)
    return false
end, {print = false, itemFilter = Filter})
