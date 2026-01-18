local CurrentLottery = false
local MINUTE_MS = 60 * 1000

local function FormatTimeLeft(timeLeftMs)
    local minutes = math.floor(timeLeftMs / MINUTE_MS)
    if minutes == 1 then
        return "1 minutę"
    elseif minutes < 5 then
        return minutes .. " minuty"
    else
        return minutes .. " minut"
    end
end

local function EndLottery()
    if not CurrentLottery then return end

    local members = CurrentLottery.Members
    if #members == 0 then
        CurrentLottery = false
        return
    end

    local winner = members[math.random(1, #members)]
    local winnerData = ESX.GetPlayerFromId(winner)

    if winnerData then
        winnerData.addMoney(CurrentLottery.Prize)
        local firstName = winnerData.get("firstName") or ""
        local lastName = winnerData.get("lastName") or ""
        TriggerClientEvent("chat:sendNewAddonChatMessage", -1, "LOTERIA", {255, 222, 89}, " Obywatel " .. firstName .. " " .. lastName .. " Zwyciężył Loterie na Kwote $" .. CurrentLottery.Prize, "fa-solid fa-ticket", {255, 222, 89}, {255, 222, 89})
    end

    CurrentLottery = false
end

local function CreateLottery(lotteryPrize, adminName)
    CurrentLottery = {
        Members = {},
        Prize = lotteryPrize,
        TimeLeft = MINUTE_MS * 3
    }

    local timeLeft = FormatTimeLeft(CurrentLottery.TimeLeft)
    local message = "Administrator " .. adminName .. " rozpoczął Loterie na kwote $" .. lotteryPrize .. "! Wykup Bilet na Loterie poprzez komende /loteriadolacz (Koszt $" .. Config.TicketPrice .. "). Loteria kończy się za " .. timeLeft
    TriggerClientEvent("chat:sendNewAddonChatMessage", -1, "LOTERIA", {255, 222, 89}, message, "fa-solid fa-ticket", {255, 222, 89}, {255, 222, 89})

    CreateThread(function()
        while CurrentLottery and CurrentLottery.TimeLeft > 0 do
            Wait(MINUTE_MS)
            CurrentLottery.TimeLeft = CurrentLottery.TimeLeft - MINUTE_MS

            if CurrentLottery.TimeLeft <= 0 then
                EndLottery()
                break
            else
                local timeLeft = FormatTimeLeft(CurrentLottery.TimeLeft)
                local reminderMessage = "Trwa obecnie Loteria na kwote $" .. lotteryPrize .. "! Wykup Bilet na Loterie poprzez komende /loteriadolacz (Koszt $" .. Config.TicketPrice .. "). Loteria kończy się za " .. timeLeft
                TriggerClientEvent("chat:sendNewAddonChatMessage", -1, "LOTERIA", {255, 222, 89}, reminderMessage, "fa-solid fa-ticket", {255, 222, 89}, {255, 222, 89})
            end
        end
    end)
end

local function IsPlayerInLottery(playerSource)
    if not CurrentLottery then return false end

    for _, memberId in ipairs(CurrentLottery.Members) do
        if memberId == playerSource then
            return true
        end
    end

    return false
end

local function JoinLottery(playerSource)
    if not CurrentLottery then return end

    local data = ESX.GetPlayerFromId(playerSource)
    if not data then return end

    if IsPlayerInLottery(playerSource) then
        data.showNotification("Wykupiłeś już los do tej Loterii")
        return
    end

    if data.getMoney() < Config.TicketPrice then
        data.showNotification("Nie posiadasz wystarczającej ilości gotówki")
        return
    end

    table.insert(CurrentLottery.Members, playerSource)
    data.removeMoney(Config.TicketPrice)
    local timeLeft = FormatTimeLeft(CurrentLottery.TimeLeft)
    data.showNotification("Pomyślnie zakupiono los do trwającej Loterii ($" .. Config.TicketPrice .. "). Loteria kończy się za " .. timeLeft)
end

RegisterCommand("loteriadolacz", function(source)
    JoinLottery(source)
end)

RegisterCommand("loteriastworz", function(source, args)
    local data = ESX.GetPlayerFromId(source)
    if not data or data.group ~= "founder" then return end

    if CurrentLottery then
        data.showNotification("Loteria jest już w toku")
        return
    end

    local prize = tonumber(args[1])
    if not prize then
        data.showNotification("Nieprawidłowa kwota wygranej")
        return
    end

    CreateLottery(prize, data.getName())
end, false)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    TriggerClientEvent('chat:addSuggestion', -1, '/loteriadolacz', 'Dołącz do trwającej loterii', {})
    TriggerClientEvent('chat:addSuggestion', -1, '/loteriastworz', 'Stwórz nową loterię', {
        { name = 'kwota', help = 'Kwota wygranej w loterii' }
    })
end)

AddEventHandler('esx:playerLoaded', function(source)
    Wait(1000)
    TriggerClientEvent('chat:addSuggestion', source, '/loteriadolacz', 'Dołącz do trwającej loterii', {})
    TriggerClientEvent('chat:addSuggestion', source, '/loteriastworz', 'Stwórz nową loterię', {
        { name = 'kwota', help = 'Kwota wygranej w loterii' }
    })
end)