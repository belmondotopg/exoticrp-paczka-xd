local Cooldowns = {}

local CardsJob = {
	["document-id"] = false,
	["business-card"] = false,
	["badge"] = {["police"] = true, ["ambulance"] = true, ["fib"] = true, ["mechanik"] = true, ["ec"] = true, ['doj']=true}
}

local function CheckCooldown(source)
	local src = source 
	local OnCooldown = false

	if (Cooldowns[src]) then 
		local TimeElapsed = (os.time() - Cooldowns[src])
		if (TimeElapsed < 10) then
			OnCooldown = true
		else
			Cooldowns[src] = false
		end
	else
		Cooldowns[src] = os.time()
	end

	return OnCooldown
end

local function GetLicenses(source)
	local src = source 
	local data = ESX.GetPlayerFromId(src)
	local Licenses = {
		["drive_bike"] = false,
		["drive"] = false,
		["drive_truck"] = false,
		["weapon"] = false
	}

	local LicensesQuery = MySQL.query.await("SELECT type FROM user_licenses WHERE owner = ?", {data.identifier})

	for _, License in pairs(LicensesQuery) do 
		Licenses[License["type"]] = true
	end

	return Licenses
end

local ActiveCards = {}

local function ShowCard(source, CardType, Mugshot, InitiatorId)
	local src = source 
	local data = ESX.GetPlayerFromId(src)
	local PlayerLicenses = GetLicenses(src)
	local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
	local NUIData = {}

	local MessageText = Config.CardsLocale[CardType](data)

	local MugshotToUse = Mugshot or ""
	
	for _, dataValue in pairs(Config.CardsData[CardType]) do 
		if (type(dataValue) == "table") then 
			NUIData[_] = {}
			for __, dataTableValue in pairs(dataValue) do 
				NUIData[_][__] = Config.CardsData[CardType][_][__](data, MugshotToUse, PlayerLicenses)
			end
		else
			NUIData[_] = Config.CardsData[CardType][_](data, MugshotToUse, PlayerLicenses)
		end
	end	
	
	if not Mugshot then
		ActiveCards[src] = {
			CardType = CardType,
			InitiatorId = InitiatorId,
			PlayerCoords = PlayerCoords,
			Data = data,
			PlayerLicenses = PlayerLicenses
		}
	end
	
	Wait(100)
	if (not InitiatorId) then 
		TriggerClientEvent("esx_hud:showCardNearby", -1, CardType, NUIData, PlayerCoords)
		TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, MessageText, src, {r = 255, g = 152, b = 247, alpha = 255})
		TriggerClientEvent("esx_chat:sendAddonChatMessageMe", -1, src, src, MessageText)

		TriggerClientEvent("esx_hud:cardAnimation", src, CardType)
	else
		TriggerClientEvent("esx_hud:showCardNearby", InitiatorId, CardType, NUIData, PlayerCoords)
	end
end

RegisterServerEvent("esx_hud:showCard", function(CardType, Mugshot)
	local src = source 
	local data = ESX.GetPlayerFromId(src)
	local CommandCooldown = CheckCooldown(src)
	if (CardsJob[CardType]) then 
		if (not CardsJob[CardType][data.job.name]) then 
			return
		end
	end

	if (not CommandCooldown) then 
		ShowCard(source, CardType, Mugshot, false)
	else
		data.showNotification("Odczekaj chwile przed ponownym pokazaniem dokumentu")
	end
end)

RegisterServerEvent("esx_hud:requestOtherPlayerCard", function(TargetId, CardType)
	local InitiatorId = source
	
	TriggerClientEvent("esx_hud:showCardToOtherPlayer", TargetId, CardType, InitiatorId)
end)

RegisterServerEvent("esx_hud:showOtherPlayerCard", function(CardType, Mugshot, InitiatorId)
	local src = source 
	local data = ESX.GetPlayerFromId(src)
	local CommandCooldown = CheckCooldown(src)

	if (CardsJob[CardType]) then 
		if (not CardsJob[CardType][data.job.name]) then 
			return
		end
	end

	if (not CommandCooldown) then 
		ShowCard(source, CardType, Mugshot, InitiatorId)
	else
		data.showNotification("Odczekaj chwile przed ponownym sprawdzeniem dokumentu")
	end
end)

RegisterServerEvent("esx_hud:updateCardMugshot", function(CardType, Mugshot, InitiatorId)
	local src = source
	local cardInfo = ActiveCards[src]
	
	if not cardInfo or cardInfo.CardType ~= CardType then
		local data = ESX.GetPlayerFromId(src)
		local PlayerLicenses = GetLicenses(src)
		local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
		local NUIData = {}
		
		for _, dataValue in pairs(Config.CardsData[CardType]) do 
			if (type(dataValue) == "table") then 
				NUIData[_] = {}
				for __, dataTableValue in pairs(dataValue) do 
					NUIData[_][__] = Config.CardsData[CardType][_][__](data, Mugshot, PlayerLicenses)
				end
			else
				NUIData[_] = Config.CardsData[CardType][_](data, Mugshot, PlayerLicenses)
			end
		end
		
		if InitiatorId then
			TriggerClientEvent("esx_hud:updateCardData", InitiatorId, CardType, NUIData)
		else
			TriggerClientEvent("esx_hud:updateCardData", -1, CardType, NUIData, PlayerCoords)
		end
		return
	end
	
	local NUIData = {}
	for _, dataValue in pairs(Config.CardsData[CardType]) do 
		if (type(dataValue) == "table") then 
			NUIData[_] = {}
			for __, dataTableValue in pairs(dataValue) do 
				NUIData[_][__] = Config.CardsData[CardType][_][__](cardInfo.Data, Mugshot, cardInfo.PlayerLicenses)
			end
		else
			NUIData[_] = Config.CardsData[CardType][_](cardInfo.Data, Mugshot, cardInfo.PlayerLicenses)
		end
	end
	
	if cardInfo.InitiatorId then
		TriggerClientEvent("esx_hud:updateCardData", cardInfo.InitiatorId, CardType, NUIData)
	else
		TriggerClientEvent("esx_hud:updateCardData", -1, CardType, NUIData, cardInfo.PlayerCoords)
	end
	
	ActiveCards[src] = nil
end)