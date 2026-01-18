Customize = {
    Locale = 'en', -- 'en', 'de', 'bg', 'es', 'fr', 'it', 'pt', 'tr'
    Framework = "ESX",-- nil: auto, 'QBCore', 'ESX', 'Qbox'
    NotifySystem = nil,-- nil: auto, 'ox_lib'
    NotifyStyle = 'top-center',-- 'top-left', 'top-right', 'top-center', 'bottom-left', 'bottom-right', 'bottom-center', 'center-left', 'center-right', 'center'
    AutoCamDistVehicleAnim = true, -- true: enable camera animation, false: disable camera animation

    TestDriveTime = 40, -- Test Drive Time (seconds)
    Currency = 'USD', -- Change this to: 'USD', 'EUR', 'TRY', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'RUB'
    DebugMessage = false,

    Finance = {
        Enabled = false, -- true: enable financing/installments, false: disable financing completely
        Command = 'vfinance',
        MaxMissedPayments = 6, -- how many payments can be missed before the car is repossessed
    },

    PlateFormat = '1AA111AA', -- 1: number, A: string
    SpeedFormatMPH = false, -- true: mph, false: kmh

    -- # Client Side Functions
    Client = {
        SetUI = function(value) -- client side - true: hide, false: show
            if value then-- Hide hud
                TriggerEvent("mHud:HideHud")
            else-- Show hud
                TriggerEvent("mHud:ShowHud")
            end
            
            
            if GetResourceState('uz_PureHud') == 'started' then
                exports['uz_PureHud']:SetHudVisibility(value)
            end
        end,
        GiveKeys = function(plate, vehicle, type) -- client side - give keys to player - type: 'buy', 'testdrive'
            if type == 'buy' then
                TriggerServerEvent("esx_carkeys:getKeys", plate)
            end
        end
    }
}