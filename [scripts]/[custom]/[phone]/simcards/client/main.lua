local lbphone = exports['lb-phone']
local ESX = exports.es_extended:getSharedObject()

local simStatus = {}

local MENU_IDS = {
    SHOP = 'shop_menu',
    SIM_CLONE = 'sim_clone_menu',
    SIM_CLONE_CONFIRM = 'sim_clone_confirm',
    SIM_DELETE = 'sim_delete_menu',
    SIM_DELETE_CONFIRM = 'sim_delete_confirm'
}

local function closePhoneIfOpen()
    if lbphone:IsOpen() then
        lbphone:ToggleOpen(false, false)
    end
end

local function createSimMenuElements(numbers)
    local elements = {}
    for _, simData in ipairs(numbers) do
        table.insert(elements, {
            label = simData.number,
            value = simData.number,
            raw = simData
        })
    end
    return elements
end

local function openSimSelectionMenu(title, callback)
    ESX.TriggerServerCallback('vwk/phone/getPublicNumbers', function(numbers)
        if not numbers or #numbers == 0 then
            ESX.ShowNotification('Nie znaleziono kart SIM.')
            return
        end

        local elements = createSimMenuElements(numbers)
        local menuId = callback == 'clone' and MENU_IDS.SIM_CLONE or MENU_IDS.SIM_DELETE

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), menuId, {
            title = title,
            align = 'center',
            elements = elements
        }, function(data, menu)
            local selected = data.current
            menu.close()

            local confirmMenuId = callback == 'clone' and MENU_IDS.SIM_CLONE_CONFIRM or MENU_IDS.SIM_DELETE_CONFIRM
            local confirmTitle = callback == 'clone' 
                and ('Klonuj kartę: %s?'):format(selected.value)
                or ('Dezaktywować kartę: %s?'):format(selected.value)

            ESX.UI.Menu.Open('default', GetCurrentResourceName(), confirmMenuId, {
                title = confirmTitle,
                align = 'center',
                elements = {
                    { label = callback == 'clone' and 'Tak — sklonuj' or 'Tak', value = 'yes' },
                    { label = 'Nie — anuluj', value = 'no' }
                }
            }, function(confirmData, confirmMenu)
                if confirmData.current.value == 'yes' then
                    local simData = selected.raw
                    if callback == 'clone' then
                        TriggerServerEvent('vwk/phone/clone', simData)
                    else
                        TriggerServerEvent('vwk/phone/delete', simData)
                    end
                end
                confirmMenu.close()
            end, function(_, confirmMenu)
                confirmMenu.close()
            end)
        end, function(_, menu)
            menu.close()
        end)
    end)
end

lib.callback.register('lbphonesim:changingsimcard', function(newNumber)
    closePhoneIfOpen()

    local status, err = pcall(function()
        Wait(100)
        lbphone:SetPhone(newNumber, false)
    end)

    if not status then
        lib.print.error(T('DEBUG.SETTING_NUMBER_FAILED'), err)
        return err
    end

    simStatus[newNumber] = false

    lbphone:SendNotification({
        app = "Phone",
        title = 'Operator Exotic5G',
        content = ("Twój nowy numer telefonu to %s"):format(newNumber),
    })

    return true
end)

RegisterNetEvent('vwk/phone/removeSim', function(number)
    closePhoneIfOpen()
    simStatus[number] = true
end)

RegisterNetEvent('vwk/phone/notify', function(title, content, app)
    app = app or "Phone"
    lbphone:SendNotification({
        app = app,
        title = title,
        content = content,
    })
end)

RegisterNetEvent("vwk/phone/update", function(number)
    lbphone:SetPhone(number, false)
end)

local function HasActiveSimCard()
    local hasSim = lib.callback.await('lbphonesim:hasActiveSim', false)
    return hasSim ~= nil
end

exports('HasActiveSimCard', HasActiveSimCard)

local function isSimTookOut(number)
    return simStatus[number] == true
end

exports('isSimTookOut', isSimTookOut)

local function isSimDeactivated(number, cb)
    if not number then
        cb(false)
        return
    end

    ESX.TriggerServerCallback('vwk/phone/isSimDeactivated', function(isBlocked)
        cb(isBlocked == true)
    end, number)
end

exports('isSimDeactivated', isSimDeactivated)

local Interactions = {
    [1] = {
        Coords = Config.SellerCoords,
        Icon = "fa-solid fa-mobile",
        Key = "ALT",
        Title = "Sklep Multimedialny",
        Label = "Naciśnij ALT aby otworzyć menu sklepu"
    },
    [2] = {
        Coords = vec3(-1079.9, -244.0, 37.7),
        Icon = "fa-solid fa-print",
        Key = "ALT",
        Title = "Drukowanie plików",
        Label = "Naciśnij ALT aby otworzyć drukarę"
    },
}

local function ShowInteractions()
    for _, data in pairs(Interactions) do
        exports["interactions"]:showInteraction(
            data.Coords,
            data.Icon,
            data.Key,
            data.Title,
            data.Label
        )
    end
end

local function DeleteInteractions()
    for _, data in pairs(Interactions) do
        exports["interactions"]:removeInteraction(data.Coords)
    end
end

local copierEntity = nil
local function ShowCopier()
    print('ShowCopier')
    local object = 'prop_copier_01'
    local modelHash = GetHashKey(object)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    copierEntity = CreateObject(modelHash, -1080.1177978516, -244.10264587402, 37.763195037842-0.98, true, false, false)
    SetEntityHeading(copierEntity, 27.0)
    PlaceObjectOnGroundOrObjectProperly(copierEntity)
    FreezeEntityPosition(copierEntity, true)
    SetEntityInvincible(copierEntity, true)
    
    SetModelAsNoLongerNeeded(modelHash)
end

CreateThread(function()
    ShowInteractions()
    SetTimeout(1000, function()
        ShowCopier()
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if copierEntity and DoesEntityExist(copierEntity) then
            DeleteEntity(copierEntity)
        end
        DeleteInteractions()
    end
end)

exports.ox_target:addSphereZone({
    coords = Config.SellerCoords,
    radius = 1,
    options = {
        {
            name = "open_shop",
            icon = "fa-solid fa-shop",
            label = "Otwórz sklep",
            onSelect = function()
                local elements = {
                    { label = "Karta SIM [ZAREJESTROWANA]", value = "sim" },
                    { label = "Karta SIM [NIEZAREJESTROWANA]", value = "simopsec" },
                    { label = "Telefon", value = "phone" }
                }

                ESX.UI.Menu.CloseAll()
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), MENU_IDS.SHOP, {
                    title = 'LifeInvader',
                    align = 'center',
                    elements = elements
                }, function(data, menu)
                    local value = data.current.value
                    if value == 'sim' then
                        TriggerServerEvent('vwk/phone/buy', 'simka')
                    elseif value == 'phone' then
                        TriggerServerEvent('vwk/phone/buy', 'fonik')
                    elseif value == "simopsec" then
                        TriggerServerEvent('vwk/phone/buy', 'opsec')
                    end
                    menu.close()
                end, function(data, menu)
                    menu.close()
                end)
            end
        },
        {
            name = "sim_card_menu",
            icon = 'fa-solid fa-sim-card',
            label = "Klonowanie Kart SIM",
            onSelect = function()
                openSimSelectionMenu('Wybierz kartę SIM do sklonowania', 'clone')
            end
        },
        {
            name = "delete_card",
            icon = 'fa-solid fa-sim-card',
            label = "Dezaktywowanie Kart SIM",
            onSelect = function()
                openSimSelectionMenu('Wybierz kartę SIM do dezaktywacji', 'delete')
            end
        }
    }
})
