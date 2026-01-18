local Config, Strings = table.unpack(require 'config.main')
local utils = require 'server.utils'

local esx_core = exports.esx_core

local lastRob = 0
local state = {
    clientSync = {
        lootSync = {
            painting = {},
            glassCutting = false,
            smashScenes = {},
        },
    },
    serverSync = {
        resetTimeout = nil,
        resetHandler = nil,
        didLoot = false,

        stateSetters = {
            painting = {},
            glassCutting = nil,
            smashScenes = {},
        },
        rewardsGiven = {
            painting = {},
            glassCutting = false,
            smashScenes = {},
        }
    },
}
local subscribers = {}

local getarrsubs = function()
    local subs = {}
    for k, v in pairs(subscribers) do
        subs[#subs + 1] = k
    end
    return subs
end

local function sendToSubs(event, ...)
    lib.triggerClientEvent(event, getarrsubs(subscribers), ...)
end

local function removeHeistObjects()
    utils.deleteByNetids(state.serverSync.glass)
    utils.deleteByNetids(state.serverSync.reward)
    utils.deleteByNetids(state.serverSync.rewardDisp)
    utils.deleteByNetids(state.serverSync.paintings)
end

local DURABILITY_LOSS <const> = 5

RegisterNetEvent('vangelicoheist:server:degradeMask', function(slot)
    local src = source
    if type(slot) ~= 'number' then return end

    local itemName = Config['VangelicoHeist']['gasMask']['itemName']

    local slotData = exports.ox_inventory:GetSlot(src, slot)
    if not slotData or slotData.name ~= itemName then
        return
    end

    local meta = slotData.metadata or {}
    local durability = meta.durability

    if type(durability) ~= 'number' then
        durability = 100
    end

    local newDurability = durability - DURABILITY_LOSS

    if newDurability <= 0 then
        exports.ox_inventory:SetDurability(src, slot, 0)
    else
        exports.ox_inventory:SetDurability(src, slot, newDurability)
    end
end)

CreateThread(function()
    ESX.RegisterUsableItem(Config['VangelicoHeist']['gasMask']['itemName'], function(source)
        local src = source
        TriggerClientEvent('vangelicoheist:client:wearMask', src)
    end)

    ESX.RegisterServerCallback('vangelicoheist:server:checkPoliceCount', function(source, cb)
        if true then return cb(true) end
        local src = source
        local policeCount = utils.getJobOnlineCount(Config['VangelicoHeist']['dispatchJobs'])

        if policeCount >= Config['VangelicoHeist']['requiredPoliceCount'] then
            cb(true)
        else
            cb(false)
            utils.notify(src, Strings['need_police'])
        end
    end)

    ESX.RegisterServerCallback('vangelicoheist:server:checkTime', function(source, cb)
        local src = source

        if (os.time() - lastRob) < Config['VangelicoHeist']['nextRob'] and lastRob ~= 0 then
            local seconds = Config['VangelicoHeist']['nextRob'] - (os.time() - lastRob)
            utils.notify(src, Strings['wait_nextrob'] .. ' ' .. math.floor(seconds / 60) .. ' ' .. Strings['minute'])
            cb(false)
        else
            lastRob = os.time()
            start = true

            state.serverSync.robber = source
            state.serverSync.resetHandler = function()
                sendToSubs('vangelicoheist:client:resetHeist')
                removeHeistObjects()

                state = {
                    clientSync = {
                        lootSync = {
                            painting = {},
                            glassCutting = false,
                            smashScenes = {},
                        },
                    },
                    serverSync = {
                        resetTimeout = nil,
                        resetHandler = nil,
                        stateSetters = {
                            painting = {},
                            glassCutting = nil,
                            smashScenes = {},
                        },
                        rewardsGiven = {
                            painting = {},
                            glassCutting = false,
                            smashScenes = {},
                        }
                    },
                }
            end
            state.serverSync.resetTimeout = ESX.SetTimeout((Config['VangelicoHeist']['nextRob'] - 60) * 1000, state.serverSync.resetHandler)
            esx_core:SendLog(source, "Rabunek na jubilera", "Wykonał rabunek na jubilera", "heist-general")
            cb(true)
        end
    end)
end)

RegisterServerEvent('vangelicoheist:server:rewardItem')
AddEventHandler('vangelicoheist:server:rewardItem', function(indextype, index)
    local src = source

    local sourcePed = GetPlayerPed(src)
    local sourceCoords = GetEntityCoords(sourcePed)
    local dist = #(sourceCoords - Config['VangelicoInside'].glassCutting.displayPos)
    if dist > 100.0 then
        return print('[vangelicoheist] add money exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
    end

    local item
    if indextype == 'painting' then
        if state.serverSync.stateSetters[indextype][index] ~= src then
            return print('[vangelicoheist] reward exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
        end
        if state.serverSync.rewardsGiven[indextype][index] then
            return print('[vangelicoheist] reward exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
        end
        state.serverSync.rewardsGiven[indextype][index] = true
        item = Config['VangelicoInside']['painting'][index]['rewardItem']
    elseif indextype == 'glassCutting' then
        if state.serverSync.stateSetters[indextype] ~= src then
            return print('[vangelicoheist] reward exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
        end
        if state.serverSync.rewardsGiven[indextype] then
            return print('[vangelicoheist] reward exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
        end
        state.serverSync.rewardsGiven[indextype] = true
        item = Config['VangelicoInside']['glassCutting']['rewards'][state.clientSync.globalObject.random]['item']
    elseif indextype == 'smashScenes' then
        if state.serverSync.stateSetters[indextype][index] ~= src then
            return print('[vangelicoheist] reward exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
        end
        if state.serverSync.rewardsGiven[indextype][index] then
            return print('[vangelicoheist] reward exploit playerID: ' .. src .. ' name: ' .. GetPlayerName(src))
        end
        state.serverSync.rewardsGiven[indextype][index] = true
        local random = math.random(1, #Config['VangelicoHeist']['smashRewards'])
        item = Config['VangelicoHeist']['smashRewards'][random]['item']
    end

    if not item then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        xPlayer.addInventoryItem(item, 1)
        esx_core:SendLog(src, "Rabunek na jubilera", "Pozyskał nagrodę z jubilera: `" .. item .. "`", "heist-general")
    end
end)

RegisterServerEvent('vangelicoheist:server:sellRewardItems')
AddEventHandler('vangelicoheist:server:sellRewardItems', function()
    local src = source
    local player = ESX.GetPlayerFromId(src)
    local totalMoney = 0

    if player then
        for k, v in pairs(Config['VangelicoHeist']['smashRewards']) do
            local playerItem = player.getInventoryItem(v['item'])
            if playerItem and playerItem.count >= 1 then
                local randomPrice = math.random(10000, 14000)
                player.removeInventoryItem(v['item'], playerItem.count)
                player.addAccountMoney("black_money", playerItem.count * randomPrice)
                totalMoney = totalMoney + (playerItem.count * randomPrice)
            end
        end

        for k, v in pairs(Config['VangelicoInside']['glassCutting']['rewards']) do
            local playerItem = player.getInventoryItem(v['item'])
            if playerItem and playerItem.count >= 1 then
                local randomPrice = math.random(15000, 22000)
                player.removeInventoryItem(v['item'], playerItem.count)
                player.addAccountMoney("black_money", playerItem.count * randomPrice)
                totalMoney = totalMoney + (playerItem.count * randomPrice)
            end
        end

        for k, v in pairs(Config['VangelicoInside']['painting']) do
            local playerItem = player.getInventoryItem(v['rewardItem'])
            if playerItem and playerItem.count >= 1 then
                local randomPrice = math.random(10000, 20000)
                player.removeInventoryItem(v['rewardItem'], playerItem.count)
                player.addAccountMoney("black_money", playerItem.count * randomPrice)
                totalMoney = totalMoney + (playerItem.count * randomPrice)
            end
        end

        esx_core:SendLog(source, "Rabunek na jubilera", "Sprzedał itemy z rabunku za: $" .. tostring(totalMoney), "heist-general")
        utils.notify(src, Strings['total_money'] .. ' $' .. math.floor(totalMoney))
    end
end)

RegisterServerEvent('vangelicoheist:server:startGas')
AddEventHandler('vangelicoheist:server:startGas', function()
    sendToSubs('vangelicoheist:client:startGas')
end)

RegisterServerEvent('vangelicoheist:server:insideLoop')
AddEventHandler('vangelicoheist:server:insideLoop', function(glass, reward, rewardDisp, paintings)
    local src = source
    if src == state.serverSync.robber and not state.serverSync.initialized then
        state.serverSync.initialized = true
        state.serverSync.glass = glass
        state.serverSync.reward = reward
        state.serverSync.rewardDisp = rewardDisp
        state.serverSync.paintings = paintings
        utils.setHeistPropAttributes(state.serverSync.glass)
        utils.setHeistPropAttributes(state.serverSync.reward)
        utils.setHeistPropAttributes(state.serverSync.rewardDisp)
        utils.setHeistPropAttributes(state.serverSync.paintings)
        sendToSubs('vangelicoheist:client:insideLoop')
    end
end)

lib.callback.register('vangelicoheist:server:lootSync', function(src, type, index)
    if (type == 'painting' or type == 'smashScenes') and not state.clientSync.lootSync[type][index] then
        state.serverSync.stateSetters[type][index] = src
        state.clientSync.lootSync[type][index] = true
        state.serverSync.didLoot = true
        sendToSubs('vangelicoheist:client:lootSync', type, index)
        return true
    elseif type == 'glassCutting' and not state.clientSync.lootSync[type] then
        state.serverSync.stateSetters[type] = src
        state.clientSync.lootSync[type] = true
        state.serverSync.didLoot = true
        sendToSubs('vangelicoheist:client:lootSync', type, index)
        return true
    end
    return false
end)

RegisterServerEvent('vangelicoheist:server:globalObject')
AddEventHandler('vangelicoheist:server:globalObject', function(obj, random)
    state.clientSync.globalObject = { obj = obj, random = random }
    sendToSubs('vangelicoheist:client:globalObject', obj)
end)

RegisterServerEvent('vangelicoheist:server:smashSync')
AddEventHandler('vangelicoheist:server:smashSync', function(index)
    state.clientSync.smashSync = state.clientSync.smashSync or {}
    state.clientSync.smashSync[index] = true
    sendToSubs('vangelicoheist:client:smashSync', index)
end)

RegisterNetEvent('vangelicoheist:server:robberLeftZone', function()
    local src = source
    if src ~= state.serverSync.robber then return end
    if not state.serverSync.initialized then return end

    if not state.serverSync.didLoot then
        if state.serverSync.resetHandler then
            state.serverSync.resetHandler()
        end
    end
end)


lib.callback.register('vangelicoheist:server:getHeistState', function(source)
    if subscribers[source] then return end
    subscribers[source] = true
    if not state.serverSync.initialized then return end
    return state.clientSync
end)

RegisterNetEvent('vangelicoheist:server:unSubscribe', function()
    local src = source
    subscribers[src] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    subscribers[src] = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    removeHeistObjects()
end)