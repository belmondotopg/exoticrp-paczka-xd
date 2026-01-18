local saved_components = {}
local hasScubaEquipped = false
local currentSlot = nil
local oxy_value = 0

function isWearingScuba(playerPed, pedModel)
    local isMale = Config.pedsMale[pedModel] or false
    local isFemale = Config.pedsFemale[pedModel] or false
    local componentIndex = isMale and Config.maleScubaVariation or (isFemale and Config.femaleScubaVariation or nil)
    return componentIndex and GetPedDrawableVariation(playerPed, 8) == componentIndex
end

RegisterNetEvent('exotic_nurek:wear', function(slot) 
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    local isMale = Config.pedsMale[pedModel] or false
    local isFemale = Config.pedsFemale[pedModel] or false
    
    if saved_components[1] then
        local oldSlot = currentSlot
        local currentOxy = oxy_value
        
        ESX.Streaming.RequestAnimDict('clothingtie')
        TaskPlayAnim(playerPed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0.0, false, false, false)
        RemoveAnimDict('clothingtie')
        Wait(1200)
        
        SetPedComponentVariation(playerPed, 8, saved_components[1][1], saved_components[1][2], 0)
        if saved_components[1][3] ~= -1 then
            SetPedPropIndex(playerPed, 1, saved_components[1][3], saved_components[1][4], 0)
        else
            ClearPedProp(playerPed, 1)
        end
        
        saved_components = {}
        hasScubaEquipped = false
        currentSlot = nil
        oxy_value = 0
        SetPedConfigFlag(playerPed, 3, true)
        
        if oldSlot then
            TriggerServerEvent('exotic_nurek:updateMetadata', oldSlot.slot, currentOxy)
        end
    else
        local currentPropIndex = GetPedPropIndex(playerPed, 1)
        saved_components[1] = {
            GetPedDrawableVariation(playerPed, 8),
            GetPedTextureVariation(playerPed, 8),
            currentPropIndex ~= -1 and currentPropIndex or -1,
            currentPropIndex ~= -1 and GetPedPropTextureIndex(playerPed, 1) or 0
        }
        ESX.Streaming.RequestAnimDict('clothingtie')
        TaskPlayAnim(playerPed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0.0, false, false, false)
        RemoveAnimDict('clothingtie')
        Wait(1200)
        local scubaVar = isMale and Config.maleScubaVariation or (isFemale and Config.femaleScubaVariation or 0)
        local maskVar = isMale and Config.maleScubaMaskVariation or (isFemale and Config.femaleScubaMaskVariation or 0)
        SetPedComponentVariation(playerPed, 8, scubaVar, 0, 0)
        SetPedPropIndex(playerPed, 1, maskVar, 0, 0)
        hasScubaEquipped = true
        currentSlot = slot
        oxy_value = slot.metadata?.oxy or Config.fulltank
        
        if not slot.metadata?.oxy then
            TriggerServerEvent('exotic_nurek:updateMetadata', slot.slot, oxy_value)
        end
        
        SetPedConfigFlag(playerPed, 3, false)
    end
end)

exports('nurekWear', function(data, slot)
    if data.name == Config.nurekItem then
        TriggerEvent('exotic_nurek:wear', slot)
        return true
    else
        print('Item name nie pasuje!')
        return false
    end
end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(item, count)
    if item and item.name == Config.nurekItem and count < 1 then
        local playerPed = PlayerPedId()
        if saved_components[1] then
            local oldSlot = currentSlot
            local currentOxy = oxy_value
            
            SetPedComponentVariation(playerPed, 8, saved_components[1][1], saved_components[1][2], 0)
            if saved_components[1][3] ~= -1 then
                SetPedPropIndex(playerPed, 1, saved_components[1][3], saved_components[1][4], 0)
            else
                ClearPedProp(playerPed, 1)
            end
            
            saved_components = {}
            hasScubaEquipped = false
            currentSlot = nil
            oxy_value = 0
            SetPedConfigFlag(playerPed, 3, true)
            
            if oldSlot then
                TriggerServerEvent('exotic_nurek:updateMetadata', oldSlot.slot, currentOxy)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local playerPed = PlayerPedId()
        if saved_components[1] then
            SetPedComponentVariation(playerPed, 8, saved_components[1][1], saved_components[1][2], 0)
            SetPedPropIndex(playerPed, 1, saved_components[1][3], saved_components[1][4], 0)
            SetPedConfigFlag(playerPed, 3, true)
            if currentSlot then
                TriggerServerEvent('exotic_nurek:updateMetadata', currentSlot.slot, oxy_value)
            end
        end
    end
end)

local lastMetadataUpdate = 0

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        local wearingScuba = isWearingScuba(playerPed, pedModel)
        local isUnderWater = IsPedSwimmingUnderWater(playerPed)
        local waitTime = 5000
        
        if wearingScuba and not hasScubaEquipped then
            hasScubaEquipped = true
            SetPedConfigFlag(playerPed, 3, false)
        elseif not wearingScuba and hasScubaEquipped then
            hasScubaEquipped = false
            SetPedConfigFlag(playerPed, 3, true)
        end
        
        if hasScubaEquipped and currentSlot then
            if isUnderWater then
                if oxy_value > 0 then
                    SetPedConfigFlag(playerPed, 3, false)
                    oxy_value = oxy_value - 1
                    
                    if oxy_value <= 0 then
                        SetPedConfigFlag(playerPed, 3, true)
                        ESX.ShowNotification('~r~Zabrakło tlenu!')
                    end
                    
                    local currentTime = GetGameTimer()
                    if currentTime - lastMetadataUpdate >= 5000 then
                        TriggerServerEvent('exotic_nurek:updateMetadata', currentSlot.slot, oxy_value)
                        lastMetadataUpdate = currentTime
                    end
                    
                    waitTime = 1000
                else
                    SetPedConfigFlag(playerPed, 3, true)
                    waitTime = 1000
                end
            else
                SetPedConfigFlag(playerPed, 3, false)
                if lastMetadataUpdate > 0 then
                    TriggerServerEvent('exotic_nurek:updateMetadata', currentSlot.slot, oxy_value)
                    lastMetadataUpdate = 0
                end
                waitTime = 2000
            end
        end
        
        Wait(waitTime)
    end
end)