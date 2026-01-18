function Customize:Interact(self)
    if self.interactType == 'default' then
        Customize:Debug(_U('default_interact'), 'info', 'Interact')
        self.setMarker(self.coords.openShowroom)
    elseif self.interactType == 'target' then
        if GetResourceState('ox_target') == 'started' then
            -- Customize:Debug(_U('debug_ox_target_started'), 'info', 'Interact')
            exports.ox_target:addBoxZone({
                coords = self.coords.openShowroom,
                size = vector3(2.0, 2.0, 2.0),
                rotation = 0,
                debug = self.debug,
                options = {
                    {
                        name = 'customize_vehicle',
                        icon = 'fas fa-car',
                        label = _U('target_open_showroom'),
                        onSelect = function()
                            Showroom:Open(self)
                        end
                    }
                }
            })
        elseif GetResourceState('qb-target') == 'started' then
            -- Customize:Debug(_U('debug_qb_target_started'), 'info', 'Interact')
            exports['qb-target']:AddBoxZone('customize_vehicle_' .. math.random(1000), self.coords.openShowroom, 2.0, 2.0, {
                name = 'customize_vehicle',
                heading = 0,
                debugPoly = self.debug,
                minZ = self.coords.openShowroom.z - 1.0,
                maxZ = self.coords.openShowroom.z + 1.0,
            }, {
                options = {
                    {
                        type = 'client',
                        icon = 'fas fa-car',
                        label = _U('target_open_showroom'),
                        action = function()
                            Showroom:Open(self)
                        end
                    },
                },
                distance = 3.0
            })
        elseif self.interactType == 'drawtext' then
            -- Customize:Debug(_U('debug_drawtext_interact'), 'info', 'Interact')
        end
    end
end


function Customize:Drawtext(self)
    if self.drawtextType == 'default' then
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(_U('press_to_open_showroom'))
        EndTextCommandDisplayHelp(0, false, true, -1)
        Customize:Debug(_U('default_interact'), 'info', 'Drawtext')
    -- elseif self.drawtextType == 'fivem' then
    end
end



function Customize:Notify(message, type, time)
    type = type or "success"
    time = time or 5000

    Customize:Debug(string.format("Notification sent: %s (Type: %s, Time: %dms)", message, type, time), 'info', 'Notify')

    if (Customize.NotifySystem == nil and GetResourceState("ox_lib") == "started") or Customize.NotifySystem == "ox_lib" then
        return exports["ox_lib"]:notify({
            title = "Salon Pojazdów: ",
            description = message,
            type = type
        })
        -- exports["ox_lib"]:notify({
        --     title = "Dealerships",
        --     description = msg,
        --     type = type
        --   })
    end

    local success = false
    if Customize.Framework == "QBCore" then
        success = QBCore.Functions.Notify(message, type, time)
    elseif Customize.Framework == "Qbox" then
        success = exports.qbx_core:Notify(message, type, time)
    elseif Customize.Framework == "ESX" then
        success = ESX.ShowNotification(message)
    else
        Customize:Warning("No notification system available", 'Notify')
        return false
    end

    if not success then
        Customize:Warning("Failed to send notification", 'Notify')
    end

    return success
end

exports('GetVehicleData', function(model)
    if not model then return nil end
    
    model = string.lower(model)
    
    for category, vehicles in pairs(Customize.Vehicles) do
        for _, vehicle in ipairs(vehicles) do
            if string.lower(vehicle.model) == model then
                return vehicle
            end
        end
    end
    
    return nil
end)

exports('GetAllVehicles', function()
    return Customize.Vehicles
end)

exports('GetVehiclesByCategory', function(category)
    if not category then return nil end
    return Customize.Vehicles[category]
end)