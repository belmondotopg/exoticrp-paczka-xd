local Player = Player
local esx_core = exports.esx_core

RegisterServerEvent('exotic_cashregister:getItems', function(playerIndex)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local playerState = Player(src).state

	if playerState.playerIndex then
		if playerIndex ~= ESX.GetServerKey(playerState.playerIndex) then
			local resourceName = GetCurrentResourceName()
			esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: " .. resourceName, "ac")
			DropPlayer(src, "[" .. resourceName .. "] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją ExoticRP")
			return
		else
			playerState.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20)) .. '-' .. math.random(10000, 99999))
		end
	end

	if not playerState.InKasetka then return end

	local moneyReward = math.random(Config.FromMoney, Config.ToMoney)
	local vipRole = xPlayer.source
	local vipMultiplier = 1.0

	if ESX.AddonPlayerDiscordRoles(vipRole, 'ELITE') then
		vipMultiplier = 1.15
	elseif ESX.AddonPlayerDiscordRoles(vipRole, 'SVIP') then
		vipMultiplier = 1.10
	elseif ESX.AddonPlayerDiscordRoles(vipRole, 'VIP') then
		vipMultiplier = 1.05
	end

	moneyReward = math.floor(moneyReward * vipMultiplier)
	xPlayer.addInventoryItem('money', moneyReward)

	local selectedItem = Config.Items[math.random(1, #Config.Items)]
	local itemName = 'Brak'
	local itemCount = 0

	if selectedItem then
		xPlayer.addInventoryItem(selectedItem.name, selectedItem.count)
		itemName = selectedItem.name
		itemCount = selectedItem.count
	end

	local resourceName = GetCurrentResourceName()
	esx_core:SendLog(src, "Rabunek na kasetkę", "Wykonał rabunek na kasetkę\nOtrzymał " .. moneyReward .. "$ oraz " .. itemName .. " " .. itemCount .. "x\nSkrypt wykonujący: `" .. resourceName .. "`", "heist-general")

	playerState.InKasetka = false
	TriggerEvent('exotic_cashregister:EndRobbery')
end)