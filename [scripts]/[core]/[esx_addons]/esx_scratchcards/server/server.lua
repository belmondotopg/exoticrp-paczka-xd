local esx_core = exports.esx_core

local Config = {
	Rewards = {
		scratchcardbasic = {
			winChance = 20,
			rewards = {
				{max = 50, amount = 750},
				{max = 75, amount = 1000},
				{max = 90, amount = 2000},
				{max = 98, amount = 4000},
				{max = 100, amount = 8000}
			}
		},
		scratchcardpremium = {
			winChance = 15,
			rewards = {
				{max = 50, amount = 1500},
				{max = 75, amount = 2500},
				{max = 90, amount = 5000},
				{max = 98, amount = 7500},
				{max = 100, amount = 10000}
			}
		}
	},
	ScratchTableTimeout = 5 * 60,
	CooldownTime = 1
}

local AllowedCardTypes = {
	['scratchcardbasic'] = true,
	['scratchcardpremium'] = true
}

local Messages = {
	wait = "Poczekaj zanim zdrapiesz aktualną zdrapkę",
	win = "Wygrałeś $%d",
	lose = "Spróbuj jeszcze raz",
	cooldown = "Poczekaj chwilę przed następną zdrapką"
}

local ScratchTable = {}
local LastScratchTime = {}

local function IsValidCardType(cardType)
	return type(cardType) == 'string' and AllowedCardTypes[cardType] == true
end

local function CalculatePayment(whichPayment, cardType)
	local cardRewards = Config.Rewards[cardType]
	if not cardRewards then 
		return 0 
	end

	for _, reward in ipairs(cardRewards.rewards) do
		if whichPayment <= reward.max then
			return reward.amount
		end
	end
	return 0
end

local function ClearScratchEntry(identifier)
	if ScratchTable[identifier] then
		ScratchTable[identifier] = nil
	end
end

local function ClearCooldownEntry(identifier)
	if LastScratchTime[identifier] then
		LastScratchTime[identifier] = nil
	end
end

local function IsOnCooldown(identifier)
	local lastTime = LastScratchTime[identifier]
	if not lastTime then
		return false
	end

	local currentTime = os.time()
	local timeDiff = currentTime - lastTime

	return timeDiff < Config.CooldownTime
end

local function TrySetScratchEntry(identifier)
	if ScratchTable[identifier] ~= nil then
		return false
	end
	
	ScratchTable[identifier] = {
		payment = nil,
		timestamp = os.time()
	}
	return true
end

local function ScratchCard(source, cardType)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then 
		return 
	end

	local identifier = xPlayer.identifier

	if not IsValidCardType(cardType) then
		print(string.format('[esx_scratchcards] Invalid card type: %s from player %s', cardType, identifier))
		return
	end

	local onCooldown, _ = IsOnCooldown(identifier)
	if onCooldown then
		TriggerClientEvent('esx:showNotification', source, Messages.cooldown)
		return
	end

	if not TrySetScratchEntry(identifier) then
		TriggerClientEvent('esx:showNotification', source, Messages.wait)
		return
	end

	LastScratchTime[identifier] = os.time()

	local cardRewards = Config.Rewards[cardType]
	if not cardRewards then 
		ClearScratchEntry(identifier)
		return 
	end

	local percent = math.random(1, 100)
	local payment = 0

	if percent <= cardRewards.winChance then
		local whichPayment = math.random(1, 100)
		payment = CalculatePayment(whichPayment, cardType)
	end

	ScratchTable[identifier].payment = payment

	TriggerClientEvent('esx_scratchcards:showSC', source, cardType, payment)
	
	if exports["esx_hud"] and exports["esx_hud"].UpdateTaskProgress then
		exports["esx_hud"]:UpdateTaskProgress(source, "Scratchcard")
	end
end

RegisterServerEvent('esx_scratchcards:payment')
AddEventHandler('esx_scratchcards:payment', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then 
		return 
	end

	local identifier = xPlayer.identifier
	local scratchEntry = ScratchTable[identifier]
	
	if not scratchEntry or scratchEntry.payment == nil then 
		return 
	end

	local payment = scratchEntry.payment

	esx_core:SendLog(src, "Zdrapki", "Zdrapka: PRZEGRANO", 'zdrapki')
	
	if payment > 0 then
		TriggerClientEvent('esx:showNotification', src, string.format(Messages.win, payment))
		esx_core:SendLog(src, "Zdrapki", string.format("Zdrapka: WYGRANO %d$", payment), 'zdrapki')
		xPlayer.addMoney(payment)
	else
		TriggerClientEvent('esx:showNotification', src, Messages.lose)
	end
	
	ClearScratchEntry(identifier)
end)

AddEventHandler('playerDropped', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer then
		local identifier = xPlayer.identifier
		ClearScratchEntry(identifier)
		ClearCooldownEntry(identifier)
	end
end)

CreateThread(function()
	local scratchList = {
		'scratchcardbasic',
		'scratchcardpremium'
	}

	for _, itemName in ipairs(scratchList) do
		ESX.RegisterUsableItem(itemName, function(source)
			local xPlayer = ESX.GetPlayerFromId(source)
			if not xPlayer then 
				return 
			end

			xPlayer.removeInventoryItem(itemName, 1)
			
			ScratchCard(source, itemName)
		end)
	end
end)

CreateThread(function()
	while true do
		Wait(60000)
		
		local currentTime = os.time()
		
		for identifier, entry in pairs(ScratchTable) do
			if entry.timestamp and (currentTime - entry.timestamp) > Config.ScratchTableTimeout then
				ClearScratchEntry(identifier)
			end
		end
		
		for identifier, timestamp in pairs(LastScratchTime) do
			if (currentTime - timestamp) > 60 then
				ClearCooldownEntry(identifier)
			end
		end
	end
end)
