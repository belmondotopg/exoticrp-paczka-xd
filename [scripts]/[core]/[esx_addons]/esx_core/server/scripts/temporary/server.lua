local RegisterServerEvent = RegisterServerEvent
local ESX = ESX
local esx_core = exports.esx_core
local TriggerClientEvent = TriggerClientEvent
local AddEventHandler = AddEventHandler
local GetCurrentResourceName = GetCurrentResourceName

local LombardMain = {
	obraz = 2000,
	bizuteria = 4000,
	figurka = 3000,
	zegarek = 1500,
	konsola = 1500,
	malalufa = 150,
	malyszkielet = 50,
	spust = 250,
	metal = 100,
	tasma = 50,
	handcuffs = 300,
	WEAPON_CROWBAR = 500
}

local LombardItemsSecond = {
	phone = 500
}

local LombardItemsThird = {
	gold = 500,
	diamond = 750
}

local LombardItemsFourth = {
	diamond = 750,
	goldwatch = 1000,
	ring = 1000,
	necklace = 1000
}

local lombardShops = {
	['esx_core:lombardShop'] = {
		items = LombardMain,
		name = "legalnym",
		legal = true
	},
	['esx_core:lombardShopSecond'] = {
		items = LombardItemsSecond,
		name = "nielegalnym",
		legal = false
	},
	['esx_core:lombardShopThird'] = {
		items = LombardItemsThird,
		name = "Fleeca",
		legal = false
	},
	['esx_core:lombardShopFourth'] = {
		items = LombardItemsFourth,
		name = "Vangelico",
		legal = false
	}
}

local function processLombardSale(src, eventName, itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	local shop = lombardShops[eventName]
	if not shop then return end

	local price = shop.items[itemName]
	if not price then return end

	local xItem = xPlayer.getInventoryItem(itemName)
	if not xItem or xItem.count < amount then
		xPlayer.showNotification("Nie masz wystarczającej ilości tego przedmiotu.")
		return
	end

	price = ESX.Math.Round(price * amount)

	xPlayer.removeInventoryItem(xItem.name, amount)
	
	if shop.legal then
		xPlayer.addInventoryItem('money', price)
		xPlayer.showNotification('Sprzedałeś '..amount..'x '..xItem.label..' za '..ESX.Math.GroupDigits(price)..'$')
	else
		xPlayer.addInventoryItem('black_money', price)
		xPlayer.showNotification('Sprzedałeś '..amount..'x '..xItem.label..' za '..ESX.Math.GroupDigits(price)..'$ (brudna gotówka)')
	end
	
	esx_core:SendLog(src, "Sprzedaż w Lombardzie", "Sprzedał w "..shop.name.." Lombardzie "..amount..'x '..xItem.name..' za '..price..'$ | '..xItem.label..' | '..ESX.Math.GroupDigits(price), 'lombard')
end

local lombardEvents = {
	'esx_core:lombardShop',
	'esx_core:lombardShopSecond',
	'esx_core:lombardShopThird',
	'esx_core:lombardShopFourth'
}

for _, eventName in ipairs(lombardEvents) do
	RegisterServerEvent(eventName)
	AddEventHandler(eventName, function(itemName, amount)
		processLombardSale(source, eventName, itemName, amount)
	end)
end

RegisterServerEvent('esx_core:useAtBusiness', function(playerIndex, count)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if Player(src).state.playerIndex then
		if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
			esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
			DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
			return
		else
			Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
		end
	end

	if not xPlayer then return end
	local playerOrg = exports['op-crime']:getPlayerOrganisation(xPlayer.identifier)
	if playerOrg.orgIndex ~= 1 then return end

	local blackMoney = exports.ox_inventory:GetItemCount(src, 'black_money')
	if blackMoney >= count then
		exports.ox_inventory:RemoveItem(src, 'black_money', count)

		local cleanMoney = ESX.Math.Round(count * 0.85)
		exports.ox_inventory:AddItem(src, 'money', cleanMoney)
		xPlayer.showNotification('Trzymaj nie rozpierdol tego, zabrałem 15% jako prowizję dla pośrednika!')
		esx_core:SendLog(src, "Pranie brudnej gotówki", "Przeprał brudnę gotówkę u peda w ilości "..cleanMoney.."$", "pranie")
	end
end)

local function sendMessageToPlayer(playerId, playerNumber, fromNumber, message, coords, attachments)
	exports["lb-phone"]:SendMessage(fromNumber, playerNumber, message, attachments)
end

local bl = {
	"niga",
	"wavesrp",
	"trujcarp",
	"trujca",
	"trujcardm",
	"exile",
	"exilerp",
	"hyperp",
	"bettersiderp",
	"waitrp",
	"notrp",
	"aries",
	"xaries",
	"bitsu",
	"krzychubaza",
	"discord",
	"Hitler",
	"pedofil",
	"Hilter",
	"Himler",
	"Himmler",
	"Stalin",
	"Putin",
	"nigga",
	"n igga",
	"nig ga",
	"nigg a",
	"n igger",
	"ni gger",
	"nig ger",
	"nigge r",
	"pedal",
	"pedał",
	"pedała",
	"pedale",
	"simp",
	"faggot",
	"upośledzony",
	"upośledzona",
	"retarded",
	"czarnuch",
	"c wel",
	"cw el",
	"cwel",
	"cwe l",
	"czarnuh",
	"żyd",
	"zyd",
	"hitler",
	"jebac disa",
	"nygus",
	"ciota",
	"cioty",
	"cioto",
	"cwelu",
	"cwele",
	"czarnuchu",
	"niggerze",
	"nigerze",
	"nygusie",
	"karzeł",
	"karzel",
	"simpie",
	"pedalskie",
	"zydzie",
	"żydzie",
	"geju",
	"nigger",
	"n1gger",
	"n1gger",
	"n1ga",
	"nigga",
	"n1gga",
	"nigg3r",
	"nig3r",
	"shagged",
	"n199er",
	"n1993r",
	"fucking",
	"nygga",
	"nyger",
	"nyggerze",
	"nygerze",
	"fuckniggas", 
	"fucknigas", 
	"fuck niggas",
	"fuck nigas",
	"fucknyggas", 
	"fucknygas", 
	"fuck nyggas", 
	"fuck nygas", 
	"nyga", 
	"pedai",
	"p3dal",
	"p3dał",
	"murzyn",
	"murzynie",
	"h i t l e r",
	"s t a l i n",
	"p u t i n",
	"n i g g a",
	"n i g g e r",
	"p e d a ł",
	"p e d a l",
	"p e d a i",
	"s i m p",
	"d o w n",
	"f a g g o t",
	"u p o ś l e d z o n y",
	"c w e l",
	"c z a r n u c h",
	"ż y d",
	"z y d",
	"n y g u s",
	"c i o t a",
	"cfel",
	"cfelu",
	"c f e l"
}

local function CheckBl(x)
	for _, v in pairs(bl) do
		if x:find(v) then
			return 1
		end
	end
	return 0
end

RegisterServerEvent('esx_core:getNewMessage', function(id, message, legal, legalcoords, attachments)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end
	if src == 0 then return end
	if id == -1 or id == 0 then return end
	if id ~= src then return end
	if #message >= 250 then return end
	if CheckBl(message) == 1 then return end

	local playerNumber = exports["lb-phone"]:GetEquippedPhoneNumber(src)
	local messageStr = tostring(message)

	if legal and legalcoords then
		sendMessageToPlayer(src, playerNumber, legal, messageStr, legalcoords, attachments)
	elseif legal == 'CUSTOMER' then
		sendMessageToPlayer(src, playerNumber, "Customer", messageStr, GetEntityCoords(GetPlayerPed(src)), attachments)
	else
		sendMessageToPlayer(src, playerNumber, "Anonim", messageStr, GetEntityCoords(GetPlayerPed(src)), attachments)
	end
end)

exports('sendMessageToPlayer', sendMessageToPlayer)