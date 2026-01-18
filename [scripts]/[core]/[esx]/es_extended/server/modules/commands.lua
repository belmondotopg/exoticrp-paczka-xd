local GetPlayerName = GetPlayerName
local esx_core = exports.esx_core

ESX.RegisterCommand({'setcoords', 'tp'}, { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer then
		xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
		esx_core:SendLog(xPlayer.source, "Teleportacja", "Użył komendy /setcoords /tp na coords: " ..args.x.. " " ..args.y.. " " ..args.z, 'admin-commands')
	end
end, false, {help = TranslateCap('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = TranslateCap('command_setcoords_x'), type = 'number'},
	{name = 'y', help = TranslateCap('command_setcoords_y'), type = 'number'},
	{name = 'z', help = TranslateCap('command_setcoords_z'), type = 'number'}
}})

ESX.RegisterCommand('kick', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer then
		if args.reason then
			DropPlayer(args.playerId.source, "Wyrzucony z serwera przez ".. GetPlayerName(xPlayer.source)..' z powodem '..args.reason)
			esx_core:SendLog(xPlayer.source, "Wyrzucenie gracza", "Wyrzucony z serwera przez ".. GetPlayerName(xPlayer.source)..' z powodem '..args.reason, 'admin-kick')
		else
			DropPlayer(args.playerId.source, "Wyrzucony z serwera przez ".. GetPlayerName(xPlayer.source))
			esx_core:SendLog(xPlayer.source, "Wyrzucenie gracza", "Wyrzucony z serwera przez ".. GetPlayerName(xPlayer.source), 'admin-kick')
		end
	end
end, true, {help = TranslateCap('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'reason', help = 'Powód wyrzucenia gracza', type = 'string'},
}})

local upgrades = Config.SpawnVehMaxUpgrades and
{
	modEngine = 3,
	modBrakes = 2,
	modTransmission = 2,
	modSuspension = -1,
	modTurbo = true,
	modXenon = true,
	modArmor = 4,
	windowTint = 1
} or {}

ESX.RegisterCommand('car', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' }, function(xPlayer, args, showError)
    if not xPlayer then
        return showError("[^1ERROR^7] The xPlayer value is nil")
    end

    local playerPed = GetPlayerPed(xPlayer.source)
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

	if GetPlayerRoutingBucket(xPlayer.source) ~= 0 then
		xPlayer.showNotification('Nie możesz respić pojazdów na innych sesjach')
		return
	else
		if not args.car or type(args.car) ~= "string" then
			args.car = "adder"
		end

		if playerVehicle then
			DeleteEntity(playerVehicle)
		end

		local vehicleExist = ESX.IsVehicleExist(args.car, xPlayer.source)

		if not vehicleExist then
			xPlayer.showNotification('Taki pojazd nie istnieje')
			return
		end

		ESX.OneSync.SpawnVehicle(args.car, playerCoords, playerHeading, upgrades, function(networkId)
			if networkId then
				local vehicle = NetworkGetEntityFromNetworkId(networkId)
				for _ = 1, 100 do
					Wait(0)
					SetPedIntoVehicle(playerPed, vehicle, -1)

					if GetVehiclePedIsIn(playerPed, false) == vehicle then
						break
					end
				end

				if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
					showError("[^1ERROR^7] The player could not be seated in the vehicle")
				end
			end
		end)
	
		esx_core:SendLog(xPlayer.source, "Spawn pojazdu", "Użył komendy /car "..args.car, 'admin-car')
	end
end, false, {help = TranslateCap('command_car'), validate = false, arguments = {
	{name = 'car',validate = false, help = TranslateCap('command_car_car'), type = 'string'}
}}) 

ESX.RegisterCommand({'cardel', 'dv'}, { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer then
		esx_core:SendLog(xPlayer.source, "Usunięcie pojazdu", "Użył komendy /cardel /dv", 'admin-cardel')

		local PedVehicle = GetVehiclePedIsIn(GetPlayerPed(xPlayer.source), false)

		if DoesEntityExist(PedVehicle) then
			TriggerEvent('esx_carkeys:vehicleDeleted', xPlayer.source, GetVehicleNumberPlateText(PedVehicle))
			DeleteEntity(PedVehicle)
			return
		end

		local Vehicles = ESX.OneSync.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(xPlayer.source)), tonumber(args.radius) or 2.0)
		for i=1, #Vehicles do 
			local Vehicle = NetworkGetEntityFromNetworkId(Vehicles[i])
			if DoesEntityExist(Vehicle) then
				TriggerEvent('esx_carkeys:vehicleDeleted', xPlayer.source, GetVehicleNumberPlateText(Vehicle))
				DeleteEntity(Vehicle)
			end
		end
	end
end, false, {help = TranslateCap('command_cardel'), validate = false, arguments = {
	{name = 'radius',validate = false, help = TranslateCap('command_cardel_radius'), type = 'number'}
}})

ESX.RegisterCommand('setaccountmoney', { 'founder', 'developer', 'managment', 'headadmin' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer then
		if args.playerId.getAccount(args.account) then
			args.playerId.setAccountMoney(args.account, args.amount, "Government Grant")
			esx_core:SendLog(xPlayer.source, "Ustawienie pieniędzy", "Użył komendy /setaccountmoney "..args.account.. " " ..args.amount, 'admin-money')
		else
			showError(TranslateCap('command_giveaccountmoney_invalid'))
		end
	else
		if args.playerId.getAccount(args.account) then
			args.playerId.setAccountMoney(args.account, args.amount, "Government Grant")
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "[PROMPT] Ustawienie pieniędzy", "Użył komendy /setaccountmoney "..args.account.. " " ..args.amount, 'admin-money')
		end
	end
end, true, {help = TranslateCap('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = TranslateCap('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = TranslateCap('command_setaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveaccountmoney', { 'founder', 'developer', 'managment', 'headadmin' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer then
		if args.playerId.getAccount(args.account) then
			args.playerId.addAccountMoney(args.account, args.amount, "Government Grant")
			esx_core:SendLog(xPlayer.source, "Dodanie pieniędzy", "Użył komendy /giveaccountmoney "..args.account.. " " ..args.amount, 'admin-money')
		else
			showError(TranslateCap('command_giveaccountmoney_invalid'))
		end
	else
		if args.playerId.getAccount(args.account) then
			args.playerId.addAccountMoney(args.account, args.amount, "Government Grant")
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "[PROMPT] Dodanie pieniędzy", "Użył komendy /giveaccountmoney "..args.account.. " " ..args.amount, 'admin-money')
		end
	end
end, true, {help = TranslateCap('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = TranslateCap('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = TranslateCap('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand({'clear', 'cls'}, { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' , 'user' }, function(xPlayer, args, showError)
	if xPlayer then
		xPlayer.triggerEvent('chat:clear')
	end
end, false, {help = TranslateCap('command_clear')})

ESX.RegisterCommand({'clearall', 'clsall'}, { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer then
		TriggerClientEvent('chat:clear', -1)
		esx_core:SendLog(xPlayer.source, "Wyczyszczenie chatu", "Użył komendy /clearall /clsall", 'admin-commands')
	end
end, true, {help = TranslateCap('command_clearall')})

ESX.RegisterCommand('setgroup', {'founder'}, function(xPlayer, args, showError)
    if xPlayer and xPlayer.getGroup and xPlayer.getGroup() ~= 'founder' then
        return xPlayer.showNotification('Brak uprawnień do użycia tej komendy!')
    end

    if not args.playerId then
        if xPlayer then
            return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!')
        else
            return showError('Nie znaleziono gracza o podanym ID!')
        end
    end

    if not args.group then
        if xPlayer then
            return xPlayer.showNotification('Nie podano grupy!')
        else
            return showError('Nie podano grupy!')
        end
    end

    args.playerId.setGroup(args.group)
    print(("[^2GROUP SET^7] %s is now %s"):format(args.playerId.name, args.group))
    
    if xPlayer then
        esx_core:SendLog(xPlayer.source, "Ustawienie grupy", "Ustawił grupę " .. args.group .. " dla gracza " .. args.playerId.name, 'admin-group')
    end
end, true, {help = 'Ustawia grupę gracza', validate = true, arguments = {
    {name = 'playerId', help = 'ID gracza', type = 'player'},
    {name = 'group', help = 'Nazwa grupy', type = 'string'}
}})

ESX.RegisterCommand('tpm', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer then
		xPlayer.triggerEvent("esx:tpm")
		esx_core:SendLog(xPlayer.source, "Teleportacja", "Użył komendy /tpm", 'admin-commands')
	end
end, true)

ESX.RegisterCommand('goto', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer and args.playerId then
		local targetCoords = args.playerId.getCoords()
		xPlayer.setCoords(targetCoords)
		esx_core:SendLog(xPlayer.source, "Teleportacja", "Użył komendy /goto do: " ..args.playerId.source, 'admin-commands')
	end
end, true, {help = TranslateCap('command_goto'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('bring', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer and args.playerId then
		local playerCoords = xPlayer.getCoords()
		args.playerId.setCoords(playerCoords)
		esx_core:SendLog(xPlayer.source, "Teleportacja", "Użył komendy /bring na: " ..args.playerId.source, 'admin-commands')
	end
end, true, {help = TranslateCap('command_bring'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('revivedist', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
    if xPlayer then
		if args.dist then
			if args.dist <= 500 then
				for k, xPlayers in pairs(ESX.GetExtendedPlayers()) do 
					local admincoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
					local distance = #(admincoords - GetEntityCoords(GetPlayerPed(xPlayers.source)))
					if distance < args.dist then
						TriggerClientEvent('esx_ambulance:onTargetRevive', xPlayers.source, true)
						xPlayers.showNotification("Zostałeś ożywiony przez administratora "..GetPlayerName(xPlayer.source).."!")
					end
				end
				esx_core:SendLog(xPlayer.source, "Ożywienie graczy", "Użyto komendy /revivedist " .. tonumber(args.dist), "admin-revivedist")
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, "Za duży dystans :v (>500)")
			end
		end
	end
end, true, {help = "Ożywia graczy w danym dystansie", validate = true, arguments = {
    {name = 'dist', help = "Odległość do reva", type = 'number'},
}})

ESX.RegisterCommand('spawn', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
    if xPlayer and (not args.targetid) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if args.targetid and args.spawn then
        local xPlayerTarget = ESX.GetPlayerFromId(args.targetid)
        if xPlayerTarget then
			if args.spawn == "ls" then
				xPlayerTarget.setCoords({x = -543.5777, y = -206.5548, z = 37.7928})
			elseif args.spawn == "sandy" then
				xPlayerTarget.setCoords({x = 1556.2242, y = 3799.9600, z = 34.2557})
			elseif args.spawn == "paleto" then
				xPlayerTarget.setCoords({x = 137.5000, y = 6636.8545, z = 31.6164,})
			end
			if xPlayer then
				xPlayerTarget.showNotification('Zostałeś przeteleportowany na spawn przez administratora '..GetPlayerName(xPlayer.source)..'!')
				esx_core:SendLog(xPlayer.source, "Spawn gracza", "Użył komendy /spawn "..args.spawn .. " ".. args.targetid, 'admin-spawn')
			else
				esx_core:SendLog(xPlayer and xPlayer.source or -1, "[PROMPT] Użył komendy /spawn " ..args.targetid.." ["..GetPlayerName(args.targetid).."] License ["..xPlayerTarget.identifier.."]", 'admin-spawn')
			end
        end
    end
end, true, {help = "Teleportuj gracza na spawn", validate = true, arguments = {
    {name = 'targetid', help = "ID gracza", type = 'number'},
	{name = 'spawn', help = "Spawn (ls, sandy, paleto)", type = 'string'}
}})

ESX.RegisterCommand('fix', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support' }, function(xPlayer, args, showError)
	if xPlayer then
		xPlayer.triggerEvent('esx:repairPedVehicle')
		esx_core:SendLog(xPlayer.source, "Naprawa pojazdu", "Użył komendy /fix", "admin-fix")
	end
end, true, {help = "Napraw pojazd", validate = true})

ESX.RegisterCommand('slay', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' }, function(xPlayer, args)
	if xPlayer then
		args.playerId.triggerEvent("esx:killPlayer")
		esx_core:SendLog(xPlayer.source, "Zabójstwo gracza", "Użył komendy /slay na graczu: ["..args.playerId.playerName.."]", "admin-slay")
	end
end, true, {help = "Zabij gracza", validate = true, arguments = {
	{ name = 'playerId', help = "ID gracza", type = 'player' }
}})

-- Funkcja do generowania tablicy rejestracyjnej
local Charset = {}
for i = 48, 57 do table.insert(Charset, string.char(i)) end -- 0-9
for i = 65, 90 do table.insert(Charset, string.char(i)) end -- A-Z

local function GetRandomNumber(length)
	math.randomseed(GetGameTimer())
	local result = {}
	for i = 1, length do
		result[i] = Charset[math.random(1, 10)] -- 0-9
	end
	return table.concat(result)
end

local function GetRandomLetter(length)
	math.randomseed(GetGameTimer())
	local result = {}
	for i = 1, length do
		result[i] = Charset[math.random(11, #Charset)] -- A-Z
	end
	return table.concat(result)
end

local function generatePlate()
	local generatedPlate
	while true do
		generatedPlate = string.upper(GetRandomLetter(4) .. GetRandomNumber(4))
		local result = MySQL.query.await('SELECT 1 FROM owned_vehicles WHERE plate = ?', { generatedPlate })
		if not result or not result[1] then
			break
		end
	end
	return generatedPlate
end

ESX.RegisterCommand('save', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' }, function(xPlayer, args, showError)
	if args.targetid and args.type then
		local tPlayer = ESX.GetPlayerFromId(args.targetid)
		if tPlayer then
			TriggerClientEvent('es_extended:getPlayerFromCar', tPlayer.source, args.type)
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "[PROMPT] Użył komendy /save " ..args.targetid.. " typ "..args.type.." ["..GetPlayerName(args.targetid).."] License ["..tPlayer.identifier.."]", 'admin-commands')
		else
			if xPlayer then
				xPlayer.showNotification("Nie znaleziono gracza o podanym ID!")
			end
		end
	else
		if xPlayer then
			xPlayer.showNotification("Użycie: /save [id] [car/boat/plane]")
		end
	end
end, true, {help = "Przypisz auto w którym siedzi gracz do niego", validate = true, arguments = {
    {name = 'targetid', help = "ID gracza", type = 'number'},
	{name = 'type', help = "Typ pojazdu (car, boat, plane)", type = 'string'},
}})

-- Obsługa callbacka z klienta - zapisanie pojazdu do bazy danych
RegisterNetEvent('es_extended:saveVehicleToDatabase', function(vehicleProps, vehicleType)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then
		return
	end
	
	if not vehicleProps or not vehicleType then
		return
	end
	
	-- Generuj tablicę rejestracyjną
	local plate = generatePlate()
	
	-- Ustaw tablicę w właściwościach pojazdu
	vehicleProps.plate = plate
	
	-- Zapisz pojazd do bazy danych
	MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (?, ?, ?, ?)', {
		xPlayer.identifier,
		plate,
		json.encode(vehicleProps),
		vehicleType
	}, function(insertId)
		if insertId then
			TriggerClientEvent('esx:showNotification', src, "Pojazd został zapisany! Tablica: " .. plate)
		else
			TriggerClientEvent('esx:showNotification', src, "Błąd podczas zapisywania pojazdu!", "error")
		end
	end)
end)

ESX.RegisterCommand('updateplate', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' }, function(xPlayer, args, showError)
	if args.oldPlate and args.newPlate then
		local oldPlate = string.upper(args.oldPlate)
		local newPlate = string.upper(args.newPlate)
		if xPlayer then
			esx_core:SendLog(xPlayer.source, "Zmiana rejestracji", "Użył komendy /updateplate " .. oldPlate .. " " .. newPlate, "admin-updateplate")
			MySQL.update.await('UPDATE owned_vehicles SET plate = ?, vehicle = JSON_SET(vehicle, "$.plate", ?) WHERE plate = ?',{ newPlate, newPlate, oldPlate })
		else
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "Użyto komendy /updateplate " .. oldPlate .. " " .. newPlate, "admin-updateplate")
			MySQL.update.await('UPDATE owned_vehicles SET plate = ?, vehicle = JSON_SET(vehicle, "$.plate", ?) WHERE plate = ?',{ newPlate, newPlate, oldPlate })
		end
	end
end, true, {help = "Zmień rejestrację auta", validate = true, arguments = {
    {name = 'oldPlate', help = "Stara rejestracja w cudzysłowiu", type = 'string'},
    {name = 'newPlate', help = "Nowa rejestracja w cudzysłowiu", type = 'string'}
}})

ESX.RegisterCommand('delcar', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' }, function(xPlayer, args, showError)
	if args.Plate then
		if xPlayer then
			local Plate = string.upper(args.Plate)
			MySQL.update.await('DELETE FROM owned_vehicles WHERE plate = ?',{ Plate })
			esx_core:SendLog(xPlayer.source, "Usunięcie pojazdu z garażu", "Użył komendy /delcar "..Plate, "admin-delcar")
		else
			local Plate = string.upper(args.Plate)
			MySQL.update.await('DELETE FROM owned_vehicles WHERE plate = ?',{ Plate })
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "Usunięcie pojazdu z garażu", "Użył komendy /delcar "..Plate, "admin-delcar")
		end
	end
end, true, {help = "Usun auto", validate = true, arguments = {
    {name = 'Plate', help = "Rejestracja pojazdu", type = 'string'},
}})

ESX.RegisterCommand('clearinvoffline', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' }, function(xPlayer, args, showError)
	if args.license then
		if xPlayer then
			MySQL.update.await('UPDATE users SET inventory = ? WHERE identifier = ?',{ '[]', args.license })
			esx_core:SendLog(xPlayer.source, "Wyczyszczenie ekwipunku offline", "Użył komendy /clearinvoffline "..args.license, "admin-clearinvoffline")
		else
			MySQL.update.await('UPDATE users SET inventory = ? WHERE identifier = ?',{ '[]', args.license })
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "[PROMPT] Wyczyszczenie ekwipunku offline", "Użył komendy /clearinvoffline "..args.license, 'admin-clearinvoffline')
		end
	end
end, true, {help = "Wyczyść graczowi ekwipunek offline", validate = true, arguments = {
    {name = 'license', help = "Licencja gracza", type = 'string'},
}})

ESX.RegisterCommand('giveitemall', {'founder', 'managment'}, function(xPlayer, args, showError)
    if xPlayer then
		local itemLabel = ESX.GetItemLabel(args.item)

		for _,zPlayer in pairs(ESX.GetExtendedPlayers()) do
			zPlayer.addInventoryItem(args.item, args.count)	
			zPlayer.showNotification('Otrzymano od administratora '..itemLabel.. ' '..args.count..'x')
		end

		xPlayer.showNotification('Pomyślnie rozdano przedmiot '..itemLabel..' w ilości '..args.count..'x')
		esx_core:SendLog(xPlayer.source, "Rozdanie przedmiotu wszystkim graczom", "Administrator: " ..GetPlayerName(xPlayer.source).. " użył komendy /giveitemall "..args.item.." "..args.count, 'admin-giveitemall')
	end
end, true, {help = "Daje wskazane itemy wszystkim graczom na serwerze", validate = true, arguments = {
    {name = 'item', help = "Nazwa przedmiotu", type = 'string'},
	{name = 'count', help = "Ilość przedmiotu", type = 'number'}
}})


ESX.RegisterCommand('removeantytroll', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' }, function(source, args)
    if args.id then
        local id = tonumber(args.id)
        local xPlayer = ESX.GetPlayerFromId(id)

        if xPlayer then
            if id ~= nil then
                MySQL.query('UPDATE users SET protection = ? WHERE identifier = ?', { 0, xPlayer.identifier})

                Player(id).state.ProtectionTime = 0
                xPlayer.showNotification('Usunięto antytroll ID: ('..id..')')
				TriggerClientEvent("esx_antitroll/startProtection", id, 0)
				esx_core:SendLog(xPlayer.source, "Usunięcie antytrolla", "Użył komendy /removeantytroll "..id, "admin-removeantytroll")
            end
		else
			MySQL.query('UPDATE users SET protection = ? WHERE identifier = ?', { 0, xPlayer.identifier})

			Player(id).state.ProtectionTime = 0
			TriggerClientEvent("esx_antitroll/startProtection", id, 0)
			esx_core:SendLog(xPlayer and xPlayer.source or -1, "[PROMPT] Usunięcie antytrolla", "Użył komendy /removeantytroll "..id, "admin-removeantytroll")
        end
    end
end, true, {help = "Usuwanie antytrolla", validate = true, arguments = {
    {name = 'id', help = "ID osoby", type = 'number'},
}})

ESX.RegisterCommand('updatename', { 'founder', 'developer', 'managment', 'headadmin', 'admin' }, function(xPlayer, args, showError)
	if args.identifier ~= nil and args.firstname ~= nil and args.lastname ~= nil then
		local targetPlayer = ESX.GetPlayerFromIdentifier(args.charid..args.identifier)

		if targetPlayer then
			DropPlayer(targetPlayer.source, 'Zmiana danych postaci!')
			MySQL.update.await('UPDATE users SET firstname = ? AND lastname = ? WHERE identifier = ?', {args.firstname, args.lastname, args.charid..args.identifier})
		else
			MySQL.update.await('UPDATE users SET firstname = ? AND lastname = ? WHERE identifier = ?', {args.firstname, args.lastname, args.charid..args.identifier})
		end

		esx_core:SendLog(xPlayer and xPlayer.source or nil, "Zmiana danych gracza", "Użył komendy /updatename "..args.charid.." | "..args.identifier.." | "..args.firstname.." | "..args.lastname, 'admin-updatename')
	end
end, true, {help = "Zaktualizuj dane gracza", validate = true, arguments = {
	{name = 'charid', help = "np char1", type = 'string'},
	{name = 'identifier', help = "Licencja", type = 'string'},
	{name = 'firstname', help = "Imię", type = 'string'},
	{name = 'lastname', help = "Nazwisko", type = 'string'}
}})

local launchboostVehicles = {}

ESX.RegisterCommand('launchboostadd', { 'founder', 'developer', 'managment' }, function(xPlayer, args, showError)
    local plate = args.plate
    if not plate or plate == '' then
        xPlayer.showNotification('~r~Musisz podać tablicę rejestracyjną pojazdu!')
        return
    end

    launchboostVehicles[plate] = true

    xPlayer.showNotification('Launchboost dodany do pojazdu o tablicy: ' .. plate)
    if esx_core then
        esx_core:SendLog(xPlayer.source, "Dodanie launchboostu do pojazdu", "Dodano launchboost do pojazdu: "..plate, 'admin-launchboost')
    end
end, true, {help = "Dodaj launchboost do pojazdu", validate = true, arguments = {
    {name = 'plate', help = "Tablica rejestracyjna pojazdu", type = 'string'}
}})

ESX.RegisterCommand('launchboostremove', { 'founder', 'developer', 'managment' }, function(xPlayer, args, showError)
    local plate = args.plate
    if not plate or plate == '' then
        xPlayer.showNotification('~r~Musisz podać tablicę rejestracyjną pojazdu!')
        return
    end

    if launchboostVehicles[plate] then
        launchboostVehicles[plate] = nil
        xPlayer.showNotification('Launchboost usunięty z pojazdu o tablicy: ' .. plate)
        if esx_core then
            esx_core:SendLog(xPlayer.source, "Usunięcie launchboostu z pojazdu", "Usunięto launchboost z pojazdu: "..plate, 'admin-launchboost')
        end
    else
        xPlayer.showNotification('~y~Pojazd z taką tablicą nie miał launchboosta.')
    end
end, true, {help = "Usuń launchboost z pojazdu", validate = true, arguments = {
    {name = 'plate', help = "Tablica rejestracyjna pojazdu", type = 'string'}
}})

RegisterNetEvent('es_extended/launchboost:checkVehicle')
AddEventHandler('es_extended/launchboost:checkVehicle', function(plate)
    local src = source
    if launchboostVehicles[plate] then
        TriggerClientEvent('es_extended/launchboost:applyBoost', src, true)
    else
        TriggerClientEvent('es_extended/launchboost:applyBoost', src, false)
    end
end)