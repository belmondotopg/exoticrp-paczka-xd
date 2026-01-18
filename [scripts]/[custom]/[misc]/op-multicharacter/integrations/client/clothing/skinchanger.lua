if Config.Clothing ~= "skinchanger" and Config.Clothing ~= "p_appearance" then
    return
end

function applySkinToPed(ped, skin)
    if type(skin) ~= "table" then
        print("^1[applySkinToPed]^0 Invalid skin data (expected table, got " .. type(skin) .. ").")
        return
    end

    TriggerEvent("skinchanger:loadSkinOnPed", ped, skin.skin)
end

function openCreationMenu(isMale)
    local model = isMale and `mp_m_freemode_01` or `mp_f_freemode_01`

    lib.requestModel(model, 30000)
    SetPlayerModel(PlayerId(), model)

    Wait(150)
    SetModelAsNoLongerNeeded(model)

    local playerPed = PlayerPedId()
    SetPedDefaultComponentVariation(playerPed)
    if model == `mp_m_freemode_01` then
        SetPedHeadBlendData(playerPed, 0, 0, 0, 0, 0, 0, 0, 0, 0, false)
    elseif model == `mp_f_freemode_01` then
        SetPedHeadBlendData(playerPed, 45, 21, 0, 20, 15, 0, 0.3, 0.1, 0, false)
    end

    TriggerEvent('esx_skin:openSaveableMenu', function() 
        Fr.CharacterCreated()
    end, function()
        Fr.CharacterCreated()
    end)
end