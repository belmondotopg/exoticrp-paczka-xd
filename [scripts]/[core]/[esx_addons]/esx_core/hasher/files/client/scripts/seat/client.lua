local ESX = ESX
local TriggerEvent = TriggerEvent
local LocalPlayer = LocalPlayer
local SetPedIntoVehicle = SetPedIntoVehicle
local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle
local esx_hud = exports.esx_hud

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

local function switchSeat(_, args)
    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or not cacheVehicle then
        ESX.ShowNotification('Nie możesz teraz tego robić!')
        return
    end

    local seatIndex = tonumber(args[1]) - 1
    if seatIndex < -1 or seatIndex >= 4 then
        ESX.ShowNotification('Nie możesz przesiąść się na to miejsce!')
    else
        if cacheVehicle then
            if esx_hud:progressBar({
                duration = 2,
                label = 'Przesiadanie...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                    mouse = false,
                },
                anim = {},
                prop = {},
            }) 
            then 
                SetPedIntoVehicle(cachePed, cacheVehicle, seatIndex)
            end
        end
    end
end

RegisterCommand("seat", switchSeat)

TriggerEvent('chat:addSuggestion', '/seat', 'Możliwość przesiadania się pomiędzy siedzeniami', {{ name = "Siedzenie", help = "<0-5> | (0 - KIEROWCA)" }})
TriggerEvent('chat:addSuggestion', '/w', 'Wyślij prywatną wiadomość do gracza', {{name = "id", help = "ID gracza"},{name = "wiadomość", help = "Treść wiadomości"}})
TriggerEvent('chat:addSuggestion', '/setcrimejob', 'Ustaw organizację przestępczą graczowi', {{ name = "id", help = "ID gracza" },{ name = "indeks", help = "Indeks organizacji" }, { name = "ranga", help = "Ranga w organizacji (boss lub recruit)" }})
TriggerEvent('chat:addSuggestion', '/firemember', 'Wyrzuć gracza z organizacji', {{ name = "id", help = "ID gracza" }})
TriggerEvent('chat:addSuggestion', '/addcrimecar', 'Dodaj pojazd do organizacji przestępczej', {{ name = "model", help = "Model auta" },{ name = "indeks", help = "Indeks organizacji" }})