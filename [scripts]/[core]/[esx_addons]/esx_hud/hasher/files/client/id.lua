local ESX = ESX
local RegisterNetEvent = RegisterNetEvent
local TriggerServerEvent = TriggerServerEvent
local SendNUIMessage = SendNUIMessage
local lib = lib
local TaskPlayAnim = TaskPlayAnim
local AttachEntityToEntity = AttachEntityToEntity
local AddEventHandler = AddEventHandler
local DeleteEntity = DeleteEntity
local Citizen = Citizen
local GetGameTimer = GetGameTimer
local GetPlayerServerId = GetPlayerServerId
local GetPlayerName = GetPlayerName
local GetPedBoneIndex = GetPedBoneIndex
local cache = cache
local exports = exports
local wallet = nil
local id = nil
local mugshotURL = ''

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('coords', function(coords)
    cacheCoords = coords
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	ESX.PlayerData.job = Job
end)

local function CardAnim()
	lib.requestAnimDict('random@atmrobberygen')
    TaskPlayAnim(cachePed, "random@atmrobberygen", "a_atm_mugging", 8.0, 3.0, 2000, 56, 1, false, false, false)
    wallet = CreateObject(`prop_ld_wallet_01`, cacheCoords, true)
    AttachEntityToEntity(wallet, cachePed, GetPedBoneIndex(cachePed, 0x49D9), 0.17, 0.0, 0.019, -120.0, 0.0, 0.0, 1, 0, 0, 0, 0, 1)
    Citizen.Wait(500)
    id = CreateObject(`prop_michael_sec_id`, cacheCoords, true)
    AttachEntityToEntity(id, cachePed, GetPedBoneIndex(cachePed, 0xDEAD), 0.150, 0.045, -0.015, 0.0, 0.0, 180.0, 1, 0, 0, 0, 0, 1)
    Citizen.Wait(1300)
    DeleteEntity(wallet)
    DeleteEntity(id)
end

local function BadgeAnim()
	lib.requestAnimDict('paper_1_rcm_alt1-9')
    local prop = CreateObject(`prop_fib_badge`, cacheCoords, true)
    AttachEntityToEntity(prop, cachePed, GetPedBoneIndex(cachePed, 0xDEAD), 0.07, 0.003, -0.065, 90.0, 0.0, 95.0, 1, 0, 0, 0, 0, 1)
    TaskPlayAnim(cachePed, "paper_1_rcm_alt1-9", "player_one_dual-9", 8.0, 3.0, 1000, 56, 1, false, false, false)
    Citizen.Wait(1000)
    DeleteEntity(prop)
end

RegisterNetEvent('esx_hud:walletSend', function(data, playerMugshot)
    if Config.Avatar then
        data['avatar'] = playerMugshot
    end

    SendNUIMessage({
        action = 'esx_hud:addWalletData',
        data = data
    })
end)

local lastGameTimer = 0

local function openIDMenu(idType)
    local coords = cacheCoords
    local list = ESX.Game.GetPlayersInArea(coords, 5.0)
    local players = {}
    local title = idType == 'id' and 'dowód' or idType == 'dmv' and 'prawo jazdy' or idType == 'weapon' and 'licencje na broń' or idType == 'card' and 'wizytowke' or (idType == 'lspd' or idType == 'lssd' or idType == 'ems' or idType == 'lsc') and 'odznake' or idType == 'doj' and 'legitymacje' or ''
    local now = GetGameTimer()

    if now <= lastGameTimer then
        ESX.ShowNotification('Nie możesz tak szybko tego używać!')
        return
    end

    TriggerServerEvent('esx_hud:updateMugshotImage', exports.esx_menu:GetMugShotBase64(cache.ped, true), true)

    if #list > 0 then
        table.insert(players, {
            title = 'Najbliższe osoby',
            description = 'Gracze do 5 metrów',
            icon = 'user-group',
            iconAnimation = 'pulse',
            onSelect = function()
                for k, v in pairs(list) do
                    local idd = GetPlayerServerId(v)
                        
                    if idType == 'ems' or idType == 'lspd' or idType == 'sheriff' or idType == 'lsc' or idType == 'doj' then
                        if not (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff" or ESX.PlayerData.job.name == "ambulance" or ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "doj") then
                            ESX.ShowNotification('Nie posiadasz dostępu!')
                            return
                        end
                    end

                    TriggerServerEvent('esx_hud:sendWalletData', idType, idd, 'Przekazano '..title..' dla graczy w pobliżu (do 5m)')

                    lastGameTimer = now + 5000
                end
            end,
        })
    
        for k, v in pairs(list) do
            local idd = GetPlayerServerId(v)
            local name = GetPlayerName(v)
            table.insert(players, {
                title = '['..idd..'] '..name,
                icon = 'user',
                onSelect = function()
                    if idType == 'ems' or idType == 'lspd' or idType == 'sheriff' or idType == 'lsc' or idType == 'doj' then
                        if not (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff" or ESX.PlayerData.job.name == "ambulance" or ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "doj") then
                            ESX.ShowNotification('Nie posiadasz dostępu!')
                            return
                        end
                    end

                    TriggerServerEvent('esx_hud:sendWalletData', idType, idd, 'Przekazano '..title..' dla gracza ['..idd..']', exports.esx_menu:GetMugShotBase64(PlayerPedId(), true))

                    lastGameTimer = now + 5000
                end,
            })
        end
    end

    table.insert(players, {
        title = 'Obejrzyj '..title,
        icon = 'eye',
        iconAnimation = 'pulse',
        onSelect = function()
            if idType == 'ems' or idType == 'lspd' or idType == 'sheriff' or idType == 'lsc' or idType == 'doj' then
                if not (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff" or ESX.PlayerData.job.name == "ambulance" or ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "doj") then
                    ESX.ShowNotification('Nie posiadasz dostępu!')
                    return
                end
            end
            local zydzik = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            TriggerServerEvent('esx_hud:sendWalletData', idType, 'me', title, zydzik)

            lastGameTimer = now + 5000
        end,
    })

    lib.registerContext({
        id = "id_menu",
        title = "Przekaż "..title,
        options = players
    })

    lib.showContext('id_menu')
end

exports('openIDMenu', openIDMenu)

RegisterNetEvent("esx_hud:cl:id:forceShow", function(who) 
    TriggerServerEvent('esx_hud:sendWalletData', 'id', who, 'Dowód został sprawdzony przez ID '..who)
end)

RegisterNetEvent('esx_hud:animSend', function (data)
    if data.type ~= nil then
        if data.type == 'ems' or data.type == 'lspd' or data.type == 'sheriff' or data.type == 'lsc' or data.type == 'doj' then
            if ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff" or ESX.PlayerData.job.name == "ambulance" or ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "doj" then
                BadgeAnim()
            end
        else
            CardAnim()
        end
    end
end)