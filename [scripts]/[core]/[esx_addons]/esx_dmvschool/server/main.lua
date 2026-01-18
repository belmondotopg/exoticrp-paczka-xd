local Player = Player
local esx_core = exports.esx_core
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local TriggerClientEvent = TriggerClientEvent
local TriggerEvent = TriggerEvent

local function decrypt(key)
    local result = ""

    for i = 1, #key do
        local char = string.byte(key, i)
        char = char - 3
        result = result .. string.char(char)
    end

    return result
end

local function encrypt(key)
    local result = ""

    for i = 1, #key do
        local char = string.byte(key, i)
        char = char + 3
        result = result .. string.char(char)
    end

    return result
end

ESX.RegisterServerCallback('esx_dmvschool:canYouPay', function(source, cb, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		if xPlayer.getMoney() >= Config.Prices[type] then
			if type == 'weapon' then
				local data = {from = xPlayer.getName(), amount = Config.Prices[type] * 0.7, jobName = 'doj', jobLabel = 'DOJ'}
				exports['p_dojmdt']:addMoney(data)
			end
			xPlayer.removeMoney(Config.Prices[type], "Licencja Zakup")
			TriggerClientEvent('esx:showNotification', source, "Zapłaciłeś "..ESX.Math.GroupDigits(Config.Prices[type], 1).."$")
			cb(true)
		else
			cb(false)
		end
	end
end)

RegisterServerEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source)
	TriggerEvent('esx_license:getLicenses', source, function(licenses)
		TriggerClientEvent('esx_dmvschool:loadLicenses', source, licenses)
	end)
end)

RegisterServerEvent('esx_dmvschool:addLicense')
AddEventHandler('esx_dmvschool:addLicense', function(type, playerIndex)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if Player(src).state.playerIndex then
		if playerIndex ~= decrypt(Player(src).state.playerIndex) then
			esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
			DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
			return
		else
			Player(src).state.playerIndex = encrypt(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
		end
	end

	if type ~= 'dmv' and type ~= 'drive' and type ~= 'drive_truck' and type ~= 'drive_bike' and type ~= 'weapon' then return end

	if xPlayer then 
		TriggerEvent('esx_license:addLicense', src, type, function()
			TriggerEvent('esx_license:getLicenses', src, function(licenses)
				TriggerClientEvent('esx_dmvschool:loadLicenses', src, licenses)
			end)
		end)
		if type == 'weapon' then
			exports.esx_core:SendLog(src, "Licencja na broń", "Gracz zdał licencję na broń", "license-set")
		end
	end
end)

RegisterServerEvent('esx_dmvschool:reloadLicense')
AddEventHandler('esx_dmvschool:reloadLicense', function()
	local src = source
	TriggerEvent('esx_license:getLicenses', src, function(licenses)
		TriggerClientEvent('esx_dmvschool:loadLicenses', src, licenses)
	end)
end)