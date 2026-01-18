local ox_inventory = exports.ox_inventory
local pma_voice = exports["pma-voice"]

local Radio = {
    Has = false,
    Open = false,
    On = false,
    Enabled = true,
    Handle = nil,
    Prop = `prop_cs_hand_radio`,
    Bone = 28422,
    Players = 0,
    Offset = vector3(0.0, 0.0, 0.0),
    Rotation = vector3(0.0, 0.0, 0.0),
    Dictionary = {
        "cellphone@",
        "cellphone@in_car@ds",
        "cellphone@str",
        "random@arrests",
    },
    Animation = {
        "cellphone_text_in",
        "cellphone_text_out",
        "cellphone_call_listen_a",
        "generic_radio_chatter",
    },
    Clicks = true,
}

local CustomLabels = {
    "LSPD Main Channel",
    "LSPD Tactical Channel #1",
    "LSPD Tactical Channel #2",
    "LSPD Tactical Channel #3",
    "LSPD Heist Channel #1",
    "LSPD Heist Channel #2",
    "Status 2",
    "EMS Main Channel",
    "FIB Main Channel",
    "LSC Main Channel",
    "DOJ Main Channel",
    "TAXI Main Channel",
}

local RADIO_ITEMS = {'radio', 'krotkofalowka'}
local SOUND_SUCCESS = "Hack_Success"
local SOUND_FAILED = "Hack_Failed"
local SOUND_LIB = "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS"

local cacheID = nil
local cacheLabel = ""

local cache = {}
local cacheOne = {}

local function UpdateRadioStatus()
    local inventory = ox_inventory:Search('count', RADIO_ITEMS)
    Radio.Has = false

    if inventory then
        for name, itemCount in pairs(inventory) do
            if (name == 'krotkofalowka' or name == 'radio') and itemCount > 0 then
                Radio.Has = true
                break
            end
        end
    end
end

local function CheckRadioInInventory()
    local inventory = ox_inventory:Search('count', RADIO_ITEMS)
    if not inventory then
        return false
    end

    for name, count in pairs(inventory) do
        if (name == 'krotkofalowka' or name == 'radio') and count > 0 then
            return true
        end
    end
    return false
end

local function DisableRadioOnItemLoss(item)
    if Radio.On then
        Radio:Remove()
        pma_voice:setVoiceProperty("radioEnabled", false)
        Radio.On = false
        TriggerEvent('esx_hud:leaveRadio')
        Radio.Has = false
        PlaySoundFrontend(-1, SOUND_FAILED, SOUND_LIB, 0)
        ESX.ShowNotification('Utracono połączenie z częstotliwością')
    end
end

AddEventHandler('esx:playerLoaded', function(playerData)
    ESX.PlayerData = playerData

    while not ESX.IsPlayerLoaded() do
        Wait(200)
    end

    TriggerServerEvent("pma-radio:searchOrgs")
    UpdateRadioStatus()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
    ESX.PlayerData.job = Job
end)

AddEventHandler('esx:addInventoryItem', function(item, count)
    if item == 'radio' or item == 'krotkofalowka' then
        if count[item] and count[item] > 0 then
            Radio.Has = true
        end
    end

    Radio.Has = CheckRadioInInventory()
end)

AddEventHandler('esx:removeInventoryItem', function(item)
    if item ~= 'radio' and item ~= 'krotkofalowka' then
        Radio.Has = CheckRadioInInventory()
        return
    end

    local inventory = ox_inventory:Search('count', RADIO_ITEMS)
    if not inventory then
        Radio.Has = false
        return
    end

    local hasRadio = false
    for name, count in pairs(inventory) do
        if (name == 'krotkofalowka' or name == 'radio') and count > 0 then
            hasRadio = true
            break
        end
    end

    if not hasRadio then
        DisableRadioOnItemLoss(item)
    else
        Radio.Has = true
    end
end)

local function HasAccessToFrequency(frequency)
    local gangId = LocalPlayer.state.gangId
    local accessList = Config.RadioConfig.Frequency.Access[frequency]

    if not accessList then
        return true, false
    end

    for i = 1, #accessList do
        local accessName = accessList[i]

        if ESX.PlayerData.job and ESX.PlayerData.job.name == accessName then
            return true, true
        end

        local orgMatch = accessName:match("^org(%d+)")
        if orgMatch then
            local orgNum = tonumber(orgMatch)
            if orgNum and orgNum >= 1 and gangId == orgNum then
                return true, true
            end
        end

        local gangMatch = accessName:match("^gang(%d+)")
        if gangMatch then
            local gangNum = tonumber(gangMatch)
            if gangNum and gangId == gangNum then
                return true, true
            end
        end
    end

    return false, false
end

local function GetRadioChannelName(frequency, isPrivate, gangName)
    if frequency <= #CustomLabels then
        return CustomLabels[frequency]
    end

    if frequency == 162 then
        return 'FIB'
    end

    if isPrivate then
        if gangName then
            return gangName
        elseif ESX.PlayerData.job and ESX.PlayerData.job.label then
            return ESX.PlayerData.job.label
        end
    end

    return frequency
end

local function FindFrequencyIndex(frequency)
    for i = 1, #Config.RadioConfig.Frequency.List do
        if Config.RadioConfig.Frequency.List[i] == frequency then
            return i
        end
    end
    return nil
end

local function SwitchToFrequency(frequency, isPrivate)
    local idx = FindFrequencyIndex(frequency)
    if not idx then
        return false
    end

    if Radio.On then
        Radio:Remove()
        Wait(50)
        Radio:Add(frequency)
    end

    Config.RadioConfig.Frequency.CurrentIndex = idx
    Config.RadioConfig.Frequency.Current = frequency

    local gangName = LocalPlayer.state.gangName
    local radioName = GetRadioChannelName(frequency, isPrivate, gangName)

    local data = {
        job = ESX.PlayerData.job and ESX.PlayerData.job.name or nil,
        radioName = radioName
    }

    TriggerEvent('esx_hud:joinRadio', data)
    TriggerServerEvent('pma-radio:getUsersInRadio', frequency)
    return true
end

RegisterNetEvent('pma-radio:toogle')
AddEventHandler('pma-radio:toogle', function()
    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
        return
    end

    if not Radio.Has then
        return
    end

    if not Radio.On then
        local gangId = LocalPlayer.state.gangId

        if gangId and gangId >= 1 then
            Config.RadioConfig.Frequency.Current = 100 + gangId
        end

        local hasAccess, isPrivate = HasAccessToFrequency(Config.RadioConfig.Frequency.Current)

        if hasAccess then
            PlaySoundFrontend(-1, SOUND_SUCCESS, SOUND_LIB, 1)
            Radio.On = true
            pma_voice:setVoiceProperty("radioEnabled", true)
            Radio:Add(Config.RadioConfig.Frequency.Current)
            ESX.ShowNotification("Włączono radio")

            local gangName = LocalPlayer.state.gangName
            local radioName = GetRadioChannelName(Config.RadioConfig.Frequency.Current, isPrivate, gangName)

            local data = {
                job = ESX.PlayerData.job and ESX.PlayerData.job.name or nil,
                radioName = radioName
            }

            TriggerEvent('esx_hud:joinRadio', data)
            TriggerServerEvent('pma-radio:getUsersInRadio', Config.RadioConfig.Frequency.Current)
        else
            PlaySoundFrontend(-1, SOUND_FAILED, SOUND_LIB, 0)
            ESX.ShowNotification("Nie masz dostępu do tej częstotliwości")
        end
    else
        PlaySoundFrontend(-1, SOUND_FAILED, SOUND_LIB, 0)
        Radio.On = false
        pma_voice:setVoiceProperty("radioEnabled", false)
        Radio:Remove()
        ESX.ShowNotification("Wyłączono radio")
        TriggerEvent('esx_hud:leaveRadio')
    end
end)

function Radio:Add(id)
    cache = {}
    cacheOne = {}
    if Radio.On then
        TriggerServerEvent("pma-radio:registerRadioChannel", id)
    end
    pma_voice:SetRadioChannel(id)
end

function Radio:Remove()
    cache = {}
    cacheOne = {}
    TriggerServerEvent("pma-radio:unregisterRadioChannel")
    pma_voice:SetRadioChannel(0)
end

RegisterNetEvent("pma-radio:kickedFromRadio", function()
    ESX.ShowNotification("Zostałeś wyrzucony z radia przez moderatora")
    TriggerEvent('esx_hud:leaveRadio')
    Radio.On = false
    Radio:Remove()
end)

function GenerateFrequencyList()
    Config.RadioConfig.Frequency.List = {}

    for i = Config.RadioConfig.Frequency.Min, Config.RadioConfig.Frequency.Max do
        if not Config.RadioConfig.Frequency.Private[i] or Config.RadioConfig.Frequency.Access[i] then
            Config.RadioConfig.Frequency.List[#Config.RadioConfig.Frequency.List + 1] = i
        end
    end
end

function IsRadioOpen()
    return Radio.Open
end

function IsRadioOn()
    return Radio.On
end

function IsRadioAvailable()
    return Radio.Has
end

function IsRadioEnabled()
    return not Radio.Enabled
end

function CanRadioBeUsed()
    return Radio.Has and Radio.On and Radio.Enabled
end

function SetRadioEnabled(value)
    if type(value) == "string" then
        value = value == "true"
    elseif type(value) == "number" then
        value = value == 1
    end

    Radio.Enabled = value == true
end

function SetRadio(value)
    if type(value) == "string" then
        value = value == "true"
    elseif type(value) == "number" then
        value = value == 1
    end

    Radio.Has = value == true
end

function SetAllowRadioWhenClosed(value)
    Config.RadioConfig.Frequency.AllowRadioWhenClosed = value

    if Radio.On and not Radio.Open and Config.RadioConfig.AllowRadioWhenClosed then
        pma_voice:setVoiceProperty("radioEnabled", true)
    end
end

function AddPrivateFrequency(value)
    local frequency = tonumber(value)

    if frequency then
        if not Config.RadioConfig.Frequency.Private[frequency] then
            Config.RadioConfig.Frequency.Private[frequency] = true
            GenerateFrequencyList()
        end
    end
end

function RemovePrivateFrequency(value)
    local frequency = tonumber(value)

    if frequency then
        if Config.RadioConfig.Frequency.Private[frequency] then
            Config.RadioConfig.Frequency.Private[frequency] = nil
            GenerateFrequencyList()
        end
    end
end

function GivePlayerAccessToFrequency(value)
    local frequency = tonumber(value)

    if frequency then
        if Config.RadioConfig.Frequency.Private[frequency] then
            if not Config.RadioConfig.Frequency.Access[frequency] then
                Config.RadioConfig.Frequency.Access[frequency] = true
                GenerateFrequencyList()
            end
        end
    end
end

function RemovePlayerAccessToFrequency(value)
    local frequency = tonumber(value)

    if frequency then
        if Config.RadioConfig.Frequency.Access[frequency] then
            Config.RadioConfig.Frequency.Access[frequency] = nil
            GenerateFrequencyList()
        end
    end
end

function GivePlayerAccessToFrequencies(...)
    local frequencies = { ... }
    local newFrequencies = {}

    for i = 1, #frequencies do
        local frequency = tonumber(frequencies[i])

        if frequency then
            if Config.RadioConfig.Frequency.Private[frequency] then
                if not Config.RadioConfig.Frequency.Access[frequency] then
                    newFrequencies[#newFrequencies + 1] = frequency
                end
            end
        end
    end

    if #newFrequencies > 0 then
        for i = 1, #newFrequencies do
            Config.RadioConfig.Frequency.Access[newFrequencies[i]] = true
        end

        GenerateFrequencyList()
    end
end

function RemovePlayerAccessToFrequencies(...)
    local frequencies = { ... }
    local removedFrequencies = {}

    for i = 1, #frequencies do
        local frequency = tonumber(frequencies[i])

        if frequency then
            if Config.RadioConfig.Frequency.Access[frequency] then
                removedFrequencies[#removedFrequencies + 1] = frequency
            end
        end
    end

    if #removedFrequencies > 0 then
        for i = 1, #removedFrequencies do
            Config.RadioConfig.Frequency.Access[removedFrequencies[i]] = nil
        end

        GenerateFrequencyList()
    end
end

exports("IsRadioOpen", IsRadioOpen)
exports("IsRadioOn", IsRadioOn)
exports("IsRadioAvailable", IsRadioAvailable)
exports("IsRadioEnabled", IsRadioEnabled)
exports("CanRadioBeUsed", CanRadioBeUsed)
exports("SetRadioEnabled", SetRadioEnabled)
exports("SetRadio", SetRadio)
exports("SetAllowRadioWhenClosed", SetAllowRadioWhenClosed)
exports("AddPrivateFrequency", AddPrivateFrequency)
exports("RemovePrivateFrequency", RemovePrivateFrequency)
exports("GivePlayerAccessToFrequency", GivePlayerAccessToFrequency)
exports("RemovePlayerAccessToFrequency", RemovePlayerAccessToFrequency)
exports("GivePlayerAccessToFrequencies", GivePlayerAccessToFrequencies)
exports("RemovePlayerAccessToFrequencies", RemovePlayerAccessToFrequencies)

RegisterNetEvent("pma-radio:returnOrgs", function(orgs)
end)

CreateThread(function()
    GenerateFrequencyList()
end)

lib.addKeybind({
    name = 'changechannel',
    description = 'Zmień częstotliwość',
    defaultKey = 'MINUS',
    onPressed = function()
        if not Radio.Has or not Radio.On then
            return
        end

        if Config.RadioConfig.Controls.Input.Pressed then
            return
        end

        local minFrequency = Config.RadioConfig.Frequency.List[1]
        Config.RadioConfig.Controls.Input.Pressed = true

        CreateThread(function()
            local input = lib.inputDialog('Częstotliwość radia', {
                {
                    type = 'number',
                    label = 'Przedział częstotliwości od 1 do 999',
                    min = 1,
                    max = 999,
                    description = "Częstotliwości od 1 do 11 są prywatne!",
                    icon = 'hashtag',
                    default = Config.RadioConfig.Frequency.Current
                }
            })

            Config.RadioConfig.Controls.Input.Pressed = false

            if not input then
                return
            end

            local frequency = input[1]
            if not frequency then
                return
            end

            local maxFrequency = Config.RadioConfig.Frequency.List[#Config.RadioConfig.Frequency.List]

            if frequency < minFrequency or frequency > maxFrequency or frequency ~= math.floor(frequency) then
                return
            end

            if Config.RadioConfig.Frequency.Private[frequency] and not Config.RadioConfig.Frequency.Access[frequency] then
                return
            end

            local hasAccess, isPrivate = HasAccessToFrequency(frequency)

            if hasAccess then
                SwitchToFrequency(frequency, isPrivate)
            else
                PlaySoundFrontend(-1, SOUND_FAILED, SOUND_LIB, 0)
                ESX.ShowNotification("Nie masz dostępu do tej częstotliwości")
            end
        end)
    end
})

local changeRatelimit = false

CreateThread(function()
    while true do
        if Radio.On then
            if IsControlPressed(0, 21) then
                if not changeRatelimit then
                    if IsControlJustPressed(0, 175) then
                        CheckAccess(Config.RadioConfig.Frequency.Current + 1)
                    elseif IsControlJustPressed(0, 174) then
                        CheckAccess(Config.RadioConfig.Frequency.Current - 1)
                    else
                        Wait(50)
                    end
                else
                    Wait(100)
                end
            else
                Wait(225)
            end
        else
            Wait(2500)
        end
    end
end)

function CheckAccess(channel)
    changeRatelimit = true

    if channel < Config.RadioConfig.Frequency.Min or channel > Config.RadioConfig.Frequency.Max then
        changeRatelimit = false
        return
    end

    local hasAccess, isPrivate = HasAccessToFrequency(channel)

    if hasAccess then
        SwitchToFrequency(channel, isPrivate)
    else
        ESX.ShowNotification("Nie masz dostępu do tej częstotliwości")
    end

    changeRatelimit = false
end

CreateThread(function()
    while true do
        Wait(100)
        if NetworkIsSessionStarted() then
            pma_voice:setVoiceProperty("radioClickMaxChannel", Config.RadioConfig.Frequency.Max)
            pma_voice:setVoiceProperty("radioEnabled", false)
            break
        end
    end
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    
    Radio.On = false
    Radio.Open = false
    pma_voice:setVoiceProperty("radioEnabled", false)
    
    CreateThread(function()
        Wait(1000)
        if ESX.IsPlayerLoaded() then
            UpdateRadioStatus()
            TriggerServerEvent("pma-radio:searchOrgs")
        end
    end)
end)

RegisterNetEvent("Radio.Toggle")
AddEventHandler("Radio.Toggle", function()
    local cachePed = cache.ped
    local isFalling = IsPedFalling(cachePed)

    if not isFalling and not LocalPlayer.state.IsDead and Radio.Enabled and Radio.Has then
        if not Radio.On then
            local gangId = LocalPlayer.state.gangId

            if gangId and gangId >= 1 then
                Config.RadioConfig.Frequency.Current = 100 + gangId
            end

            local hasAccess, isPrivate = HasAccessToFrequency(Config.RadioConfig.Frequency.Current)

            if hasAccess then
                PlaySoundFrontend(-1, SOUND_SUCCESS, SOUND_LIB, 1)
                Radio.On = true
                pma_voice:setVoiceProperty("radioEnabled", true)
                Radio:Add(Config.RadioConfig.Frequency.Current)
                ESX.ShowNotification("Włączono radio")

                local gangName = LocalPlayer.state.gangName
                local radioName = GetRadioChannelName(Config.RadioConfig.Frequency.Current, isPrivate, gangName)

                local data = {
                    job = ESX.PlayerData.job and ESX.PlayerData.job.name or nil,
                    radioName = radioName
                }

                TriggerEvent('esx_hud:joinRadio', data)
                TriggerServerEvent('pma-radio:getUsersInRadio', Config.RadioConfig.Frequency.Current)
            else
                PlaySoundFrontend(-1, SOUND_FAILED, SOUND_LIB, 0)
                ESX.ShowNotification("Nie masz dostępu do tej częstotliwości")
            end
        else
            PlaySoundFrontend(-1, SOUND_FAILED, SOUND_LIB, 0)
            Radio.On = false
            pma_voice:setVoiceProperty("radioEnabled", false)
            Radio:Remove()
            ESX.ShowNotification("Wyłączono radio")
            TriggerEvent('esx_hud:leaveRadio')
        end
    end
end)

RegisterNetEvent("Radio.Set")
AddEventHandler("Radio.Set", function(value)
    if type(value) == "string" then
        value = value == "true"
    elseif type(value) == "number" then
        value = value == 1
    end

    Radio.Has = value == true
end)

function FindCustom(id)
    if cacheID == id then
        return cacheLabel
    end

    for i, v in ipairs(CustomLabels) do
        if type(v) == "table" and v[1] == tostring(id) then
            cacheID = id
            cacheLabel = v[2]
            return v[2]
        end
    end

    return false
end

function FrequencyGet()
    local nm = FindCustom(Config.RadioConfig.Frequency.Current)
    return nm or Config.RadioConfig.Frequency.Current
end

local function GetRadioData()
    return {Radio.Has, FrequencyGet(), Radio.Players}
end

RegisterNetEvent("pma-radio:openCrimeRadio", function(list)
    OpenRadioListCrime(list)
end)

function OpenRadioListCrime(players)
    local myId = GetPlayerServerId(PlayerId())
    local elements = {
        head = {"ID", "Imię i nazwisko", "Radio", "Wyciszony", "Działania"},
        rows = {}
    }

    for i = 1, #players do
        local player = players[i]
        local isMuted = exports['pma-voice']:getMutedPerson(player.id)
        local muted = isMuted and 'TAK' or 'NIE'
        local actions = '{{' .. "Wycisz/Odcisz" .. '|mute}}'

        if myId == player.id then
            actions = '{{' .. "BRAK" .. '|none}}'
            muted = '-'
        end

        table.insert(elements.rows, {
            data = player,
            cols = {
                player.id,
                player.nick,
                player.channel,
                muted,
                actions
            }
        })
    end

    ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'radio_list', elements, function(data, menu)
        if data.value == 'mute' then
            exports['pma-voice']:toggleMutePlayer(data.data.id)
            ESX.UI.Menu.CloseAll()
            TriggerServerEvent("pma-radio:openRadioListServer", FrequencyGet())
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenRadioListW(players)
    local nm = FindCustom(Config.RadioConfig.Frequency.Current)
    local elements = {
        head = {"ID", "Nazwa", "Radio"},
        rows = {}
    }

    for i = 1, #players do
        local player = players[i]
        local channel = nm or player.channel

        table.insert(elements.rows, {
            data = player,
            cols = {
                player.id,
                player.label,
                channel
            }
        })
    end

    ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'radio_list', elements, function(data, menu)
    end, function(data, menu)
        menu.close()
    end)
end

local function OpenRadioList(players)
    local nm = FindCustom(Config.RadioConfig.Frequency.Current)
    local elements = {
        head = {"ID", "Nazwa", "Radio", "Akcje"},
        rows = {}
    }

    for i = 1, #players do
        local player = players[i]
        local channel = nm or player.channel

        table.insert(elements.rows, {
            data = player,
            cols = {
                player.id,
                player.label,
                channel,
                '{{' .. "Wyrzuć z radia" .. '|kick}} {{' .. "Przenieś na inny kanał" .. '|move}}'
            }
        })
    end

    local channelOptions = {
        {label = 'Main Channel', value = '1'},
        {label = 'Tactic Channel #1', value = '2'},
        {label = 'Tactic Channel #2', value = '3'},
        {label = 'Tactic Channel #3', value = '4'},
        {label = 'Heist Channel #1', value = '5'},
        {label = 'Heist Channel #2', value = '6'},
        {label = 'Heist Channel #3', value = '7'},
        {label = 'Status 2', value = '8'},
        {label = 'EMS #1', value = '9'},
        {label = 'EMS #2', value = '10'}
    }

    ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'radio_list', elements, function(data, menu)
        local employee = data.data

        if data.value == 'kick' then
            menu.close()
            TriggerServerEvent("pma-radio:kickFromRadio", employee.id)
            ESX.ShowNotification("Wyrzucono z radia " .. employee.id)
        elseif data.value == "move" then
            menu.close()
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'radio_moving', {
                title = "Przenieś gracza na inny kanał",
                align = 'bottom-right',
                elements = channelOptions
            }, function(data2, menu2)
                TriggerServerEvent("pma-radio:moveInRadioChannel", employee.id, data2.current.value)
                ESX.ShowNotification("Przeniesiono gracza na kanał " .. data2.current.label)
                menu2.close()
                Wait(500)
                OpenRadioList(players)
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end

local function RadioList(args)
    if ESX.IsPlayerAdminClient() and args[1] then
        local radio = tonumber(args[1])
        if radio and radio > 0 and radio < 1000 then
            TriggerServerEvent("pma-radio:openRadioListServer", radio)
            return
        elseif args[1] == "all" then
            TriggerServerEvent("pma-radio:openRadioListServer", "all")
            return
        end
    end

    local frequencyType = type(FrequencyGet())
    local hasJobAccess = ESX.PlayerData.job and (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "ambulance")
    local hasGangAccess = LocalPlayer.state.gangId

    if frequencyType == "string" and (hasJobAccess or hasGangAccess) then
        TriggerServerEvent("pma-radio:openRadioListServerFrakcja", Config.RadioConfig.Frequency.Current)
    elseif frequencyType == "number" then
        TriggerServerEvent("pma-radio:openRadioListServer", FrequencyGet())
    else
        ESX.ShowNotification('Nie posiadasz dostępu do tego elementu!')
    end
end

RegisterNetEvent('pma-radio:openFrakcjaRadioList', function(pl)
    OpenRadioListW(pl)
end)

RegisterNetEvent('pma-radio:openFrakcjaRadioListZarzad', function(pl)
    OpenRadioList(pl)
end)

RegisterCommand("radiolist", function(src, args, raw)
    RadioList(args)
end, false)

RegisterNetEvent("pma-radio:movePlayerToChannel", function(channel)
    channel = tonumber(channel)
    if not channel then
        return
    end

    local chnl = FindCustom(channel) or channel
    ESX.ShowNotification("Zostałeś przeniesiony przez moderatora na kanał " .. chnl)

    local idx = FindFrequencyIndex(channel)
    if idx then
        Radio:Remove()
        Wait(50)
        Config.RadioConfig.Frequency.CurrentIndex = idx
        Radio:Add(channel)
        Config.RadioConfig.Frequency.Current = channel
    end
end)

RegisterNetEvent("pma-radio:addRadioTalking", function(label, id)
    for i = #cache, 1, -1 do
        if cache[i].id == id then
            table.remove(cache, i)
        end
    end
    
    table.insert(cache, {
        label = label,
        id = id
    })
    TriggerEvent('esx_hud:addPlayerTalking', id)
end)

RegisterNetEvent("pma-radio:stopRadioTalking", function(id)
    local removed = false
    for i = #cache, 1, -1 do
        if cache[i].id == id then
            table.remove(cache, i)
            removed = true
        end
    end
    if removed then
        TriggerEvent('esx_hud:removePlayerTalking', id)
    end
end)

RegisterNetEvent("pma-radio:addRadioTalking1", function(id, label, channel)
    -- Usuń istniejące wpisy tego gracza przed dodaniem nowego
    for i = #cacheOne, 1, -1 do
        if cacheOne[i].id == id then
            table.remove(cacheOne, i)
        end
    end
    
    local chnl = FindCustom(channel) or channel
    table.insert(cacheOne, {
        label = label,
        id = id,
        channel = chnl
    })
end)

RegisterNetEvent("pma-radio:stopRadioTalking1", function(id)
    for i = #cacheOne, 1, -1 do
        if cacheOne[i].id == id then
            table.remove(cacheOne, i)
        end
    end
end)

local function CountRadioPlayers()
    local players = pma_voice:getRadioData()
    if not players or type(players) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(players) do
        count = count + 1
    end
    return count
end

RegisterNetEvent("pma-voice:syncRadioData")
AddEventHandler("pma-voice:syncRadioData", function()
    if Radio.On then
        SetTimeout(1000, function()
            Radio.Players = CountRadioPlayers()
            TriggerEvent('pma-radio:getUsersInRadio', Config.RadioConfig.Frequency.Current)
        end)
    end
end)

RegisterNetEvent("pma-voice:addPlayerToRadio")
AddEventHandler("pma-voice:addPlayerToRadio", function()
    SetTimeout(1000, function()
        Radio.Players = CountRadioPlayers()
        TriggerServerEvent('pma-radio:getUsersInRadio', Config.RadioConfig.Frequency.Current)
    end)
end)

RegisterNetEvent("pma-voice:removePlayerFromRadio")
AddEventHandler("pma-voice:removePlayerFromRadio", function()
    SetTimeout(1000, function()
        local players = pma_voice:getRadioData()
        Radio.Players = (players and type(players) == "table") and #players or 0
        TriggerServerEvent('pma-radio:getUsersInRadio', Config.RadioConfig.Frequency.Current)
    end)
end)

RegisterNetEvent('pma-radio:updateHudPlayerList', function(players)
    TriggerEvent('esx_hud:syncRadioPlayers', players)
end)

exports('GetRadioData', GetRadioData)