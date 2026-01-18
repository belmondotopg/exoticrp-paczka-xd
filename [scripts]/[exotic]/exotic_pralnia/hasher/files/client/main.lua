CreateThread(function()
    exports.interactions:showInteraction(
        Config.WashingLocation,
        "fa-solid fa-washing-machine",
        "ALT",
        "Skorzystaj z Pralni Pieniędzy",
        "Naciśnij ALT aby skorzystać z Pralni Pieniędzy"
    )

    exports.ox_target:addSphereZone({
        name = 'pralnia',
        coords = Config.WashingLocation,
        radius = 1.5,
        debug = false,
        options = {
            {
                name = 'pralnia:wash',
                icon = 'fa-solid fa-washing-machine',
                label = 'Przepierz Brudną Gotówke',
                distance = 2,
                onSelect = function()
                    TriggerServerEvent("exotic_pralnia:wash")
                end
            }
        }
    })
end)