local function GetItemMetadata(item)
    if not item or not item.slot then
        return nil
    end

    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.inventory or not playerData.inventory[item.slot] then
        return nil
    end

    return playerData.inventory[item.slot].metadata
end

local function ApplyComponentVariation(componentId, skin1, skin2, clothType, checkValue, paletteId)
    local currentValue = GetPedDrawableVariation(cache.ped, componentId)
    
    if currentValue == checkValue then
        SetPedComponentVariation(cache.ped, componentId, skin1, skin2, paletteId)
        TriggerServerEvent('esx_core:remove:clothes', skin1, skin2, clothType)
    end
end

local function ApplyProp(propId, skin1, skin2, clothType, checkValue, textureId)
    local currentValue = GetPedPropIndex(cache.ped, propId)
    
    if currentValue == checkValue then
        SetPedPropIndex(cache.ped, propId, skin1, skin2, textureId)
        TriggerServerEvent('esx_core:remove:clothes', skin1, skin2, clothType)
    end
end

local function HandleComponentClothing(eventName, clothType, componentId, checkValue, paletteId)
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(item)
        local metadata = GetItemMetadata(item)
        if not metadata or not metadata.accessories or not metadata.accessories2 then
            return
        end

        local skin1 = metadata.accessories
        local skin2 = metadata.accessories2
        ApplyComponentVariation(componentId, skin1, skin2, clothType, checkValue, paletteId)
    end)
end

local function HandlePropClothing(eventName, clothType, propId, checkValue, textureId)
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, function(item)
        local metadata = GetItemMetadata(item)
        if not metadata or not metadata.accessories or not metadata.accessories2 then
            return
        end

        local skin1 = metadata.accessories
        local skin2 = metadata.accessories2
        ApplyProp(propId, skin1, skin2, clothType, checkValue, textureId)
    end)
end

RegisterNetEvent('esx_core:clothes:mask')
AddEventHandler('esx_core:clothes:mask', function(item)
    local metadata = GetItemMetadata(item)
    if not metadata or not metadata.accessories or not metadata.accessories2 then
        return
    end

    local skin1 = metadata.accessories
    local skin2 = metadata.accessories2
    local currentValue = GetPedDrawableVariation(cache.ped, 1)
    
    -- Załóż maskę jeśli jest zdjęta (wartość 0 lub -1)
    if currentValue == 0 or currentValue == -1 then
        SetPedComponentVariation(cache.ped, 1, skin1, skin2, 3)
        TriggerServerEvent('esx_core:remove:clothes', skin1, skin2, 'mask')
    end
end)

HandleComponentClothing('esx_core:clothes:arms', 'arms', 3, 15, 0)
HandleComponentClothing('esx_core:clothes:tshirt', 'tshirt', 8, -1, 2)
HandleComponentClothing('esx_core:clothes:bag', 'bagcloth', 5, -1, 2)
HandleComponentClothing('esx_core:clothes:torso', 'torso', 11, 15, 3)
HandleComponentClothing('esx_core:clothes:jeans', 'jeans', 4, 14, 0)
HandleComponentClothing('esx_core:clothes:shoes', 'shoes', 6, 34, 2)
HandleComponentClothing('esx_core:clothes:vest', 'vest', 9, -1, 2)

RegisterNetEvent('esx_core:clothes:chain')
AddEventHandler('esx_core:clothes:chain', function(item)
    local metadata = GetItemMetadata(item)
    if not metadata or not metadata.accessories or not metadata.accessories2 then
        return
    end

    local skin1 = metadata.accessories
    local skin2 = metadata.accessories2
    local currentValue = GetPedDrawableVariation(cache.ped, 7)
    
    if currentValue == 0 or currentValue == -1 then
        SetPedComponentVariation(cache.ped, 7, skin1, skin2, 2)
        TriggerServerEvent('esx_core:remove:clothes', skin1, skin2, 'chain')
    end
end)

HandlePropClothing('esx_core:clothes:ears', 'ears', 2, -1, true)
HandlePropClothing('esx_core:clothes:glasses', 'glasses', 1, -1, true)
HandlePropClothing('esx_core:clothes:helmet', 'helmet', 0, -1, true)
HandlePropClothing('esx_core:clothes:watches', 'watchcloth', 6, -1, 0)
HandlePropClothing('esx_core:clothes:bracelet', 'bracelet', 7, -1, 0)