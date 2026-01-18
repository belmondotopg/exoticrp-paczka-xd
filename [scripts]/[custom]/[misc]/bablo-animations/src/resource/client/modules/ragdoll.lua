if not Config.Modules['Ragdoll'] then return end

RegisterKeyMapping("ragdoll", "Ragdoll", "keyboard", "U")

RegisterCommand('ragdoll', function()
    if IsPedInAnyVehicle(cache.ped, false) then return end

    if not isRagdolling then
        isRagdolling = true
    else
        isRagdolling = false
    end

    Citizen.CreateThread(function()
        while isRagdolling do

            SetPedToRagdoll(cache.ped, 1000, 1000, 0, 0, 0, 0)

            Citizen.Wait(5)
        end
    end)
end)