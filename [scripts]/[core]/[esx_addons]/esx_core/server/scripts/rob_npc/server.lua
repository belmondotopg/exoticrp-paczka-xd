local esx_core = exports.esx_core

local robberyCooldowns = {}
local activeRobberies = {}
local ROBBERY_COOLDOWN_MS = 30000
local REQUIRED_COPS = 1

AddEventHandler('playerDropped', function()
    local src = source
    robberyCooldowns[src] = nil
    activeRobberies[src] = nil
end)

RegisterServerEvent("esx_core_robnpc:giveReward", function(playerIndex)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    if not playerIndex or type(playerIndex) ~= "string" then
        local resourceName = GetCurrentResourceName()
        esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent bez odpowiedniego tokenu playerIndex! Skrypt: " .. resourceName, "ac")
        DropPlayer(src, "[" .. resourceName .. "] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
        return
    end

    local playerState = Player(src).state

    if playerState.ProtectionTime and playerState.ProtectionTime > 0 then
        xPlayer.showNotification('Nie możesz okradać NPC będąc na antytrollu!')
        return
    end

    if playerState.IsDead then
        xPlayer.showNotification('Nie możesz okradać NPC będąc martwym!')
        return
    end

    if playerState.IsHandcuffed then
        xPlayer.showNotification('Nie możesz okradać NPC będąc zakuty w kajdanki!')
        return
    end

    if playerState.InSafeZone then
        xPlayer.showNotification('Nie możesz okradać NPC w safe zone!')
        return
    end

    if playerState.playerIndex then
        if playerIndex ~= ESX.GetServerKey(playerState.playerIndex) then
            local resourceName = GetCurrentResourceName()
            esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: " .. resourceName, "ac")
            DropPlayer(src, "[" .. resourceName .. "] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
            return
        else
            playerState.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20)) .. '-' .. math.random(10000, 99999))
        end
    end

    local currentTime = GetGameTimer()
    if robberyCooldowns[src] and (currentTime - robberyCooldowns[src]) < ROBBERY_COOLDOWN_MS then
        local remainingTime = math.ceil((ROBBERY_COOLDOWN_MS - (currentTime - robberyCooldowns[src])) / 1000)
        xPlayer.showNotification('Musisz odczekać ' .. remainingTime .. ' sekund przed kolejnym okradaniem!')
        esx_core:SendLog(src, "Aktywność nadużycia", "Próba okradania NPC podczas cooldown (pozostało: " .. remainingTime .. "s)", "ac")
        return
    end

    if activeRobberies[src] then
        xPlayer.showNotification('Już wykonujesz rabunek!')
        esx_core:SendLog(src, "Aktywność nadużycia", "Próba wykonania wielu rabunków jednocześnie", "ac")
        return
    end

    if not GlobalState.Counter or not GlobalState.Counter['police'] or GlobalState.Counter['police'] < REQUIRED_COPS then
        xPlayer.showNotification('Minimalnie musi być ' .. REQUIRED_COPS .. ' policjantów, aby okraść lokalnego')
        return
    end

    activeRobberies[src] = true

    local chance = math.random(100)
    local money = ESX.Math.Round(math.random(500, 3000))
    local reward

    if chance < 3 then
        xPlayer.addInventoryItem('karta_zakladnika', 1)
        reward = 'Okradanie zakończone powodzeniem otrzymano: Karta zakładnika x1'
        xPlayer.showNotification(reward)
    elseif chance < 8 then
        xPlayer.addInventoryItem('handcuffs', 1)
        reward = 'Okradanie zakończone powodzeniem otrzymano: Kajdanki x1'
        xPlayer.showNotification(reward)
    elseif chance < 13 then
        xPlayer.addInventoryItem('lockpick', 1)
        reward = 'Okradanie zakończone powodzeniem otrzymano: Wytrych x1'
        xPlayer.showNotification(reward)
    elseif chance < 23 then
        xPlayer.addInventoryItem('WEAPON_CROWBAR', 1)
        reward = 'Okradanie zakończone powodzeniem otrzymano: Łom x1'
        xPlayer.showNotification(reward)
    elseif chance < 39 then
        xPlayer.addInventoryItem('scratchcardbasic', 1)
        reward = 'Okradanie zakończone powodzeniem otrzymano: Zdrapka Basic x1'
        xPlayer.showNotification(reward)
    elseif chance < 55 then
        xPlayer.addMoney(money)
        reward = 'Okradanie zakończone powodzeniem zarobiono: ' .. money .. '$'
        xPlayer.showNotification(reward)
    else
        reward = 'Obywatel miał puste kieszenie [nic nie otrzymał]!'
        xPlayer.showNotification('Obywatel miał puste kieszenie!')
    end

    robberyCooldowns[src] = currentTime
    activeRobberies[src] = nil

    esx_core:SendLog(xPlayer.source, "Okradanie NPC", "Okradł NPC: " .. reward, "heist-npc")
end)
