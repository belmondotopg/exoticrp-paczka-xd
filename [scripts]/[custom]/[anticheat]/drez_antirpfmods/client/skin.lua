function LoadPlayerDefaultModel()
    local ped = PlayerPedId()
    local characterModel = `mp_m_freemode_01`

    local p = promise.new()
    Citizen.CreateThreadNow(function()
        RequestStreamModel(characterModel)

        SetPlayerModel(PlayerId(), characterModel)
        
        Wait(100)

        while (GetEntityModel(PlayerPedId()) ~= characterModel) do  
            Wait(0)
        end
        
        ped = PlayerPedId()

        SetPedDefaultComponentVariation(ped)
        SetPedMaxHealth(ped, 200)
        SetEntityHealth(ped, 200)

        SetModelAsNoLongerNeeded(characterModel)

        p:resolve()
    end)

    Citizen.Await(p)
end