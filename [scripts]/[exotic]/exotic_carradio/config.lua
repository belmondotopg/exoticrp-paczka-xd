Config = {}

Config.Language = 'pl' -- pl / en

Config.DefaultDist = 25.0

Config.RefreshRate = 250 -- if default dist is 25.0 leave it on 250, if you increase refresh rate, you need to increase default dist

Config.Distance = {
    ['SULTAN2'] = 30.0
}

Config.Restrict = { -- which seats can open car radio (remove table if you dont want restrict) https://docs.fivem.net/natives/?_0x22AC59A870E6A669
    ["-1"] = true, -- driver
    ["0"] = true -- front passenger
}

Config.Notification = function(player, text) -- server side
    local xPlayer = ESX.GetPlayerFromId(player)
    xPlayer.showNotification(text) 
end

Config.Translation = {
    ['pl'] = {
        ['not_in_veh'] = 'Nie jesteś w pojeździe',
        ['not_on_seat'] = 'Nie możesz otworzyć radia na tym miejscu',
        ['nothing'] = 'Nic',
        ['playing'] = 'Odtwarzasz',
        ['remaining_time'] = 'Pozostały czas',
        ['loop_on'] = 'Odtwórz w pętli',
        ['loop_off'] = 'Wyłącz zapętlenie',
        ['music_link'] = 'Link do muzyki...',
        ['saved_songs'] = 'Zapisane utwory',
    },
    ['en'] = {
        ['not_in_veh'] = 'You are not in any vehicle',
        ['not_on_seat'] = 'You cant open radio on this seat',
        ['nothing'] = 'Nothing',
        ['playing'] = 'Playing',
        ['remaining_time'] = 'Remaining time',
        ['loop_on'] = 'Play in loop',
        ['loop_off'] = 'Turn off loop',
        ['music_link'] = 'Music link...',
        ['saved_songs'] = 'Saved songs',
    }
}