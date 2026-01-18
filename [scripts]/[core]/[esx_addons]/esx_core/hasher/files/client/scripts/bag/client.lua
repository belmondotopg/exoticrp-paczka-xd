local ESX = ESX
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local GetGamePool = GetGamePool
local IsEntityAttachedToEntity = IsEntityAttachedToEntity
local DetachEntity = DetachEntity
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteObject = DeleteObject
local DeleteEntity = DeleteEntity
local SetPedComponentVariation = SetPedComponentVariation
local ClearPedBloodDamage = ClearPedBloodDamage
local ResetPedVisibleDamage = ResetPedVisibleDamage
local Wait = Wait
local SetTimeout = SetTimeout

local canUsePropfix = true
local bagEquipped = false
local kaburaEquipped = false
local ox_inventory = exports.ox_inventory
local justConnect = true
local cachePed = cache.ped

lib.onCache('ped', function(ped)
    cachePed = ped
end)

local function PutOnBag()
    SetPedComponentVariation(cachePed, 5, 81, 0, 0)
    bagEquipped = true
end

local function RemoveBag()
    SetPedComponentVariation(cachePed, 5, 0, 0, 0)
    bagEquipped = false
end

local function PutOnKabura()
    -- SetPedComponentVariation(cachePed, 7, 176, 0, 2)
    kaburaEquipped = true
end

local function RemoveKabura()
    -- SetPedComponentVariation(cachePed, 7, 0, 0, 2)
    kaburaEquipped = false
end

local function IsInHeist()
    return LocalPlayer.state.InBettaHeist or LocalPlayer.state.InFleecaHeist or LocalPlayer.state.InVangelicoHeist
end

local function UpdateBagState()
    local bagCount = ox_inventory:Search('count', 'bag')
    if bagCount > 0 and not bagEquipped then
        if not IsInHeist() then
            PutOnBag()
        end
    elseif bagCount < 1 and bagEquipped then
        if not IsInHeist() then
            RemoveBag()
        end
    end
end

local function UpdateKaburaState()
    local kaburaCount = ox_inventory:Search('count', 'kabura')
    if kaburaCount > 0 and not kaburaEquipped then
        PutOnKabura()
    elseif kaburaCount < 1 and kaburaEquipped then
        RemoveKabura()
    end
end

exports('PutOnBag', PutOnBag)
exports('RemoveBag', RemoveBag)

AddEventHandler('ox_inventory:updateInventory', function(changes)
    if justConnect then
        Wait(4500)
        justConnect = false
    end

    if next(changes) then
        UpdateBagState()
        UpdateKaburaState()
    end
end)

lib.onCache('vehicle', function(vehicle)
    if GetResourceState('ox_inventory') ~= 'started' then return end

    local bagCount = ox_inventory:Search('count', 'bag')
    local kaburaCount = ox_inventory:Search('count', 'kabura')

    if vehicle then
        if bagCount and bagCount >= 1 and bagEquipped then
            RemoveBag()
        end
        if kaburaCount and kaburaCount >= 1 and kaburaEquipped then
            RemoveKabura()
        end
    else
        if bagCount and bagCount >= 1 and not bagEquipped then
            PutOnBag()
        end
        if kaburaCount and kaburaCount >= 1 and not kaburaEquipped then
            PutOnKabura()
        end
    end
end)

exports('openBag', function(data, slot)
    exports.ox_inventory:closeInventory()
    
    local identifier = slot?.metadata?.identifier
    if not identifier then
        identifier = lib.callback.await('esx_core:getNewIdentifier', 100, data.slot)
    else
        TriggerServerEvent('esx_core:openBag', identifier)
    end
    
    SetTimeout(200, function()
        ox_inventory:openInventory('stash', 'bag_' .. identifier)
    end)
end)

local function ExecutePropfix()
    for _, object in pairs(GetGamePool('CObject')) do
        if IsEntityAttachedToEntity(object, cachePed) then
            DetachEntity(object, true, true)
            SetEntityAsMissionEntity(object, true, true)
            DeleteObject(object)
            DeleteEntity(object)
        end
    end

    local bagCount = ox_inventory:Search('count', 'bag')
    if bagCount > 0 and not bagEquipped then
        PutOnBag()
    end

    ClearPedBloodDamage(cachePed)
    ResetPedVisibleDamage(cachePed)
end

RegisterCommand("propfix", function()
    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then
        ESX.ShowNotification('Nie możesz teraz tego robić!')
        return
    end

    local isAdmin = ESX.IsPlayerAdminClient()

    if isAdmin then
        ExecutePropfix()
        ESX.ShowNotification('Użyto /propfix')
    else
        if not canUsePropfix then
            ESX.ShowNotification('Nie możesz tak często używać tej komendy!')
            return
        end

        ExecutePropfix()
        ESX.ShowNotification('Użyto /propfix, otrzymano cooldown 30 sekund na jego używanie!')
        canUsePropfix = false
        SetTimeout(30000, function()
            canUsePropfix = true
        end)
    end
end, false)

RegisterNetEvent("esx_core:cl:bag:rename", function(slotId)
    local input = lib.inputDialog('Zmiana nazwy torby', {
        {type = 'input', label = 'Nowa nazwa', description = 'Maksymalnie 15 znaków', required = true, min = 1, max = 15},
    })

    if not input then return end
    TriggerServerEvent('esx_core:sv:bag:renameBag', slotId, input[1])
end)