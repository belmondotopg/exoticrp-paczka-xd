local surgeonPed = nil
local blip = nil
local SurgeryConfig = {}

SurgeryConfig.SurgeonLocation = {
    coords = vector3(1126.3043, -1532.2391, 35.0330),
    heading = 320.4092
}

SurgeryConfig.PedModel = 's_m_m_doctor_01'
SurgeryConfig.SurgeryPrice = 5000
SurgeryConfig.SurgeryDuration = 5000
SurgeryConfig.SurgeryDurationText = "5 sekund"

CreateThread(function()
    local pedModel = GetHashKey(SurgeryConfig.PedModel)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end

    surgeonPed = CreatePed(4, pedModel, SurgeryConfig.SurgeonLocation.coords.x, SurgeryConfig.SurgeonLocation.coords.y,
        SurgeryConfig.SurgeonLocation.coords.z - 1.0, SurgeryConfig.SurgeonLocation.heading, false, true)

    FreezeEntityPosition(surgeonPed, true)
    SetEntityInvincible(surgeonPed, true)
    SetBlockingOfNonTemporaryEvents(surgeonPed, true)

    exports.ox_target:addLocalEntity(surgeonPed, {
        {
            name = 'plastic_surgery',
            label = 'Operacja plastyczna ($' .. SurgeryConfig.SurgeryPrice .. ')',
            icon = 'fas fa-user-md',
            distance = 2.5,
            onSelect = function()
                TriggerServerEvent('exoticrp:requestSurgery')
            end
        }
    })
end)

RegisterNetEvent('exoticrp:performSurgery', function()
    local playerPed = PlayerPedId()
    ESX.ShowNotification('Ustaw się w dogodnym miejscu!')     
    if exports.esx_hud:progressBar({
        duration = 7,
        label = 'Przygotowywanie do opreacji...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = 'move_m@drunk@verydrunk_idles@',
            clip = 'fidget_07',
            flag = 49
        },
    }) 
    then
        TriggerEvent('qf_skinmenu/skinMenu')
    else 
        ESX.ShowNotification('Anulowano.')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if surgeonPed and DoesEntityExist(surgeonPed) then
        DeleteEntity(surgeonPed)
    end

    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end)
