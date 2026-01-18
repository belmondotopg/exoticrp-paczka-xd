local esx_hud = exports.esx_hud
local qtarget = exports.qtarget
local LocalPlayer = LocalPlayer

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(Job)
    ESX.PlayerData.job = Job
end)

local props = {}

local function openRepairBench(i)
    local options = {}
    local items = lib.callback.await('openRepairBench', false)
    if not items then return end

    for name, data in pairs(items) do
        for _, v in pairs(data) do
            if v.slot and v.metadata.durability < 100 then
                options[#options+1] = {
                    id = name .. v.slot,
                    title = v.label,
                    description = string.format('Wytrzymałość: %s', Round(v.metadata.durability).. '%'),
                    serverEvent = 'ox_repair:weaponRepairStarted',
                    args = {slot = v.slot, name = name, bench = i, playerIndex = LocalPlayer.state.playerIndex}
                }
            end
        end
    end

    lib.registerContext({id = 'repairbench', title = 'Warsztat', options = options})
    lib.showContext('repairbench')
end

RegisterNetEvent('ox_repair:itemRepaired', function(name, data)
    TriggerEvent('ox_inventory:disarm')
    Citizen.Wait(1000)
    if esx_hud:progressBar({
        duration = Config.require[name] and Config.require[name].repairtime or Config.repairtime,
        useWhileDead = false,
        canCancel = true,
        label = 'Naprawianie',
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped'
        },
        disable = {
            move = true,
            car = true
        }
    }) then
        TriggerServerEvent('ox_repair:weaponFix', ESX.GetClientKey(LocalPlayer.state.playerIndex), data)
        ESX.ShowNotification('Naprawa zakończona sukcesem!')
    end
end)

for i = 1, #Config.locations do
    local location = Config.locations[i]

    if location.spawnprop then
        local benchfar = lib.points.new(location.coords, 50, {coords = location.coords, heading = location.heading, index = i})

        function benchfar:onEnter()
            lib.requestModel(`gr_prop_gr_bench_02a`)
            props[self.index] = CreateObject(`gr_prop_gr_bench_02a`, self.coords.x, self.coords.y, self.coords.z, false, false, false)
            SetEntityHeading(props[self.index], self.heading)
            FreezeEntityPosition(props[self.index], true)

            qtarget:AddTargetEntity(props[self.index], {
                options = {
                    {
                        icon = 'fa fa-wrench',
                        label = 'Otwórz warsztat',
                        action = function()
                            if Config.locations[self.index].job and ESX.PlayerData.job.name ~= "police" then
                                ESX.ShowNotification('Nie posiadasz dostępu do tego elementu!')
                                return
                            end
                            openRepairBench(self.index)
                        end
                    }
                },
                distance = 2.0
            })
        end

        function benchfar:onExit()
            DeleteEntity(props[self.index])
        end
    end
end

AddEventHandler('onResourceStop', function(name)
    if name ~= cache.resource then return end
    for _, v in pairs(props) do
        DeleteEntity(v)
    end
end)