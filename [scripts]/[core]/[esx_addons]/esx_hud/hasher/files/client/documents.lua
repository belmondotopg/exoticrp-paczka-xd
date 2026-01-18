local ShowingCard = false
local CardQueue = {}
local CachedMugshot = nil
local MugshotLoading = false

local function CardAnim()
    local playerPed = PlayerPedId()
    local playerPosition = GetEntityCoords(playerPed)

    lib.requestAnimDict('random@atmrobberygen')
    TaskPlayAnim(playerPed, "random@atmrobberygen", "a_atm_mugging", 8.0, 3.0, 2000, 56, 1, false, false, false)
    wallet = CreateObject(`prop_ld_wallet_01`, playerPosition, true)
    AttachEntityToEntity(wallet, playerPed, GetPedBoneIndex(playerPed, 0x49D9), 0.17, 0.0, 0.019, -120.0, 0.0, 0.0, 1, 0, 0, 0, 0, 1)
    Citizen.Wait(500)
    id = CreateObject(`prop_michael_sec_id`, playerPosition, true)
    AttachEntityToEntity(id, playerPed, GetPedBoneIndex(playerPed, 0xDEAD), 0.150, 0.045, -0.015, 0.0, 0.0, 180.0, 1, 0, 0, 0, 0, 1)
    Citizen.Wait(1300)
    DeleteEntity(wallet)
    DeleteEntity(id)
end

local function BadgeAnim()
    local playerPed = PlayerPedId()
    local playerPosition = GetEntityCoords(playerPed)


    lib.requestAnimDict('paper_1_rcm_alt1-9')
    local prop = CreateObject(`prop_fib_badge`, playerPosition, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 0xDEAD), 0.07, 0.003, -0.065, 90.0, 0.0, 95.0, 1, 0, 0, 0, 0, 1)
    TaskPlayAnim(playerPed, "paper_1_rcm_alt1-9", "player_one_dual-9", 8.0, 3.0, 1000, 56, 1, false, false, false)
    Citizen.Wait(1000)
    DeleteEntity(prop)
end

local CardAnimations = {
    ["document-id"] = function()
        CardAnim()
    end,
    ["business-card"] = function()
        CardAnim()
    end,
    ["badge"] = function()
        BadgeAnim()
    end
}

local function ShowCard(CardType, NUIData)
    ShowingCard = true

    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = CardType,
        data = NUIData
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = CardType,
        visible = true
    })

    Wait(10000)
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = CardType,
        visible = false
    })
    ShowingCard = false
end

RegisterNetEvent("esx_hud:cardAnimation", function(CardType)
    CardAnimations[CardType]()
end)

local function GetPlayerMugshot()
    if CachedMugshot then
        return CachedMugshot
    end
    
    if not MugshotLoading then
        MugshotLoading = true
        CreateThread(function()
            CachedMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            MugshotLoading = false
        end)
    end
    
    return nil
end

local function RefreshMugshotCache()
    CachedMugshot = nil
    if not MugshotLoading then
        MugshotLoading = true
        CreateThread(function()
            Wait(500)
            CachedMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            MugshotLoading = false
        end)
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    CreateThread(function()
        Wait(2000)
        
        if not CachedMugshot and not MugshotLoading then
            MugshotLoading = true
            CachedMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            MugshotLoading = false
        end
    end)
end)

RegisterNetEvent('skinchanger:loadSkin', function()
    RefreshMugshotCache()
end)

RegisterNetEvent('esx_hud:reloadSkin', function()
    RefreshMugshotCache()
end)

RegisterNetEvent('qf_skinmenu/changeOutfit', function()
    RefreshMugshotCache()
end)

RegisterNetEvent('skinchanger:loadClothes', function()
    RefreshMugshotCache()
end)

exports("ShowCardProximity", function(CardType)
    local PlayerMugshot = GetPlayerMugshot()
    
    TriggerServerEvent("esx_hud:showCard", CardType, PlayerMugshot)
    
    if not PlayerMugshot then
        CreateThread(function()
            local NewMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            CachedMugshot = NewMugshot
            TriggerServerEvent("esx_hud:updateCardMugshot", CardType, NewMugshot)
        end)
    end
end)

RegisterCommand("dowod", function()
    local PlayerMugshot = GetPlayerMugshot()
    
    TriggerServerEvent("esx_hud:showCard", "document-id", PlayerMugshot)
    
    if not PlayerMugshot then
        CreateThread(function()
            local NewMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            CachedMugshot = NewMugshot
            TriggerServerEvent("esx_hud:updateCardMugshot", "document-id", NewMugshot)
        end)
    end
end)

RegisterCommand("wizytowka", function()
    local PlayerMugshot = GetPlayerMugshot()
    
    TriggerServerEvent("esx_hud:showCard", "business-card", PlayerMugshot)
    
    if not PlayerMugshot then
        CreateThread(function()
            local NewMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            CachedMugshot = NewMugshot
            TriggerServerEvent("esx_hud:updateCardMugshot", "business-card", NewMugshot)
        end)
    end
end)

RegisterNetEvent("esx_hud:showCardToOtherPlayer", function(CardType, InitiatorId)
    local PlayerMugshot = GetPlayerMugshot()
    
    TriggerServerEvent("esx_hud:showOtherPlayerCard", CardType, PlayerMugshot, InitiatorId)
    
    if not PlayerMugshot then
        CreateThread(function()
            local NewMugshot = exports.esx_menu:GetMugShotBase64(PlayerPedId(), true)
            CachedMugshot = NewMugshot
            TriggerServerEvent("esx_hud:updateCardMugshot", CardType, NewMugshot, InitiatorId)
        end)
    end
end)

RegisterNetEvent("esx_hud:showCardNearby", function(CardType, NUIData, Coords)
    local Distance = #(GetEntityCoords(PlayerPedId()) - Coords)

    if (Distance > 10.0) then return end

    if (not ShowingCard) then 
        ShowCard(CardType, NUIData)
    else
        CardQueue[#CardQueue + 1] = {
            ["Type"] = CardType,
            ["Data"] = NUIData
        }
    end
end)

RegisterNetEvent("esx_hud:updateCardData", function(CardType, NUIData, Coords)
    if Coords then
        local Distance = #(GetEntityCoords(PlayerPedId()) - Coords)
        if (Distance > 10.0) then return end
    end
    
    if ShowingCard then
        SendNUIMessage({
            eventName = "nui:data:update",
            dataId = CardType,
            data = NUIData
        })
    end
end)

CreateThread(function()
    while (true) do 
        Wait(1000)
        if (#CardQueue > 0) then 
            if (not ShowingCard) then
                local CurrentCard = CardQueue[1]
                ShowCard(CurrentCard["Type"], CurrentCard["Data"])
                table.remove(CardQueue, 1)
            end
        end
    end
end)