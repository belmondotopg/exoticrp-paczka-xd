local esx_core = exports.esx_core

local function CheckInsurance(src, job, licenseType, columnName)
	if src then
		local xPlayer = ESX.GetPlayerFromId(src)
		if not xPlayer then return false end
		local results = MySQL.prepare.await('SELECT type FROM user_licenses WHERE type = ? AND owner = ?', {licenseType, xPlayer.identifier})
		return results ~= nil
	else
		if not job then return false end
		local results = MySQL.prepare.await('SELECT '..columnName..' FROM jobs_insurance WHERE name = ?', {job})
		return results == 1
	end
end

local function CheckInsuranceEMS(src, job)
	return CheckInsurance(src, job, 'ems_insurance', 'nnw')
end

local function CheckInsuranceLSC(src, job)
	return CheckInsurance(src, job, 'oc_insurance', 'oc')
end

RegisterServerEvent("esx_menu:dices", function()
	local src = source
	local Message = "rzuca kością, wypada [" .. math.random(1,6) .. "]"
	TriggerClientEvent('esx_chat:sendAddonChatMessageDo', -1, src, src, Message)
	TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, Message, src, {r = 255, g = 152, b = 247, alpha = 255})
end)

local Kills = {}
local Deaths = {}
local Headshots = {}
local countHS = {}
local firstKill = {}

local woundShoot = {
	'Rana postrzałowa przelotowa prawego uda',
	'Rana postrzałowa styczna w okolicy lewego barku',
	'Rana postrzałowa ślepa w okolicy prawego barku',
	'Rana postrzałowa ślepa z przebiciem płuc po stronie lewej',
	'Rana postrzałowa w lewej dłoni z uszkodzeniem nerwu promieniowego',
	'Rana postrzałowa w prawym kolanie z uszkodzeniem łąkotki',
}

local woundFight = {
	'Stłuczenie w okolicy lewego ramienia',
	'Rozcięcie prawego łuku brwiowego',
	'Rozcięcie lewego łuku brwiowego',
	'Złamanie kości lewej ręki bez przemieszczenia',
	'Złamanie kości prawej ręki z przemieszczeniem',
	'Silny krwotok z nosa',
}

local woundCasual = {
	'Podbite prawe oko',
	'Zwichnięty nadgarstek prawej dłoni',
	'Zwichnięta kostka prawej stopy',
	'Złamany nos',
	'Podbite lewe oko',
	'Pęknięcie żebra po lewej stronie klatki piersiowej',
	'Skaleczenie kciuka prawej dłoni',
	'Wybity prawy siekacz',
}

local woundKnife = {
	'Wniknięcie ostrza w mięsień ramienia po stronie lewej',
	'Przebicie bicepsa po stronie lewej z uszkodzeniem ścięgien',
	'Przecięcie skóry na wewnętrznej stronie lewego ramienia',
	'Rozcięcie tętnicy nadgarstka po stronie prawej',
	'Przecięcie nerwu promieniowego w prawej dłoni',
}

local woundFire = {
	'Oparzenia III stopnia na całym ciele',
	'Oparzenia III stopnia w okolicach prawego ramienia',
	'Oparzenia II stopnia w okolicach lewego ramienia',
	'Wstrząs mózgu i złamania żeber w wyniku uderzenia fali uderzeniowej',
	'Oparzenia klatki piersiowej II stopnia',
	'Rozległe oparzenia na twarzy, szyi i rękach',
	'Złamanie kości piszczelowej prawej nogi',
	'Zatrucie pokarmowe',
	'Odłamki nieznanych ciał obcych wbite w ciało',
	'Uszkodzenie płuc i krtani',
}

local meleeWeapons = {
	['Knife'] = true, ['Nightstick'] = true, ['Hammer'] = true, ['Baseball Bat'] = true,
	['Crowbar'] = true, ['Golf Club'] = true, ['Bottle'] = true, ['Antique Cavalry Dagger'] = true,
	['Hatchet'] = true, ['Knuckle Duster'] = true, ['Machete'] = true, ['Flashlight'] = true,
	['Switchblade'] = true, ['Battleaxe'] = true, ['Poolcue'] = true, ['Wrench'] = true,
	['Stone Hatchet'] = true,
}

local firearmWeapons = {
	['Pistol XM 3'] = true, ['Pistol'] = true, ['Pistol MK2'] = true, ['Combat Pistol'] = true,
	['Pistol .50'] = true, ['SNS Pistol'] = true, ['SNS Pistol MK2'] = true, ['Heavy Pistol'] = true,
	['Vintage Pistol'] = true, ['Marksman Pistol'] = true, ['Heavy Revolver'] = true,
	['Heavy Revolver MK2'] = true, ['Double-Action Revolver'] = true, ['AP Pistol'] = true,
	['Stun Gun'] = true, ['Flare Gun'] = true, ['Up-n-Atomizer'] = true, ['Micro SMG'] = true,
	['Machine Pistol'] = true, ['Mini SMG'] = true, ['SMG'] = true, ['SMG MK2'] = true,
	['Assault SMG'] = true, ['Combat PDW'] = true, ['MG'] = true, ['Combat MG'] = true,
	['Gusenberg Sweeper'] = true, ['Unholyuy Deathbringer'] = true, ['Assault Rifle'] = true,
	['Assault Rifle MK2'] = true, ['Carbine Rifle'] = true, ['Carbine Rifle MK2'] = true,
	['Advanced Rifle'] = true, ['Special Carbine'] = true, ['Special Carbine MK2'] = true,
	['Bullpup Rifle'] = true, ['Bullpup Rifle MK2'] = true, ['Compact Rifle'] = true,
	['Sniper Rifle'] = true, ['Heavy Sniper'] = true, ['Heavy Sniper MK2'] = true,
	['Marksman Rifle'] = true, ['Marksman Rifle MK2'] = true, ['Pump Shotgun'] = true,
	['Pump Shotgun MK2'] = true, ['Sawed-off Shotgun'] = true, ['Bullpup Shotgun'] = true,
	['Assault Shotgun'] = true, ['Musket'] = true, ['Heavy Shotgun'] = true,
	['Double Barrel Shotgun'] = true, ['Sweeper Shotgun'] = true,
}

local explosiveWeapons = {
	['Grenade'] = true, ['Sticky Bomb'] = true, ['Proximity Mine'] = true, ['Pipe Bomb'] = true,
	['Tear Gas'] = true, ['BZ Gas'] = true, ['Molotov'] = true, ['Fire Extinguisher'] = true,
	['Jerry Can'] = true, ['Ball'] = true, ['Snowball'] = true, ['Flare'] = true,
	['Grenade Launcher'] = true, ['RPG'] = true, ['Minigun'] = true, ['Firework Launcher'] = true,
	['Railgun'] = true, ['Homing Launcher'] = true, ['Compact Grenade Launcher'] = true,
	['Widowmaker'] = true, ['Rocket'] = true, ['Tank'] = true, ['Laser'] = true,
	['Fire'] = true, ['Heli Crash'] = true,
}

local function getWoundType(weapon)
	if weapon == 'Unarmed' then
		return woundFight
	elseif meleeWeapons[weapon] then
		return woundKnife
	elseif firearmWeapons[weapon] then
		return woundShoot
	elseif explosiveWeapons[weapon] then
		return woundFire
	else
		return woundCasual
	end
end

local function ensureStat(identifier, statTable)
	if not statTable[identifier] then
		statTable[identifier] = 0
	end
end

RegisterServerEvent("es_extended:weaponDamageEvent")
AddEventHandler("es_extended:weaponDamageEvent", function(deathData)
	local src = source
	local weapon = deathData.weapon or "Brak informacji"
	
	local woundType = getWoundType(weapon)
	Player(src).state.BodyDamage = woundType[math.random(1, #woundType)]

	if not deathData.killedByPlayer then
		esx_core:SendLog(src, "Zabójstwa", GetPlayerName(src).. " zabił się!", 'kills')
		return
	end

	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer then
		ensureStat(xPlayer.identifier, Deaths)
		Deaths[xPlayer.identifier] = Deaths[xPlayer.identifier] + 1
		TriggerClientEvent("es_extended:setAfterWeaponData", xPlayer.source, false, Deaths[xPlayer.identifier])
	end

	local killerXPlayer = ESX.GetPlayerFromId(deathData.killerServerId)
	if not killerXPlayer then return end

	ensureStat(killerXPlayer.identifier, Kills)
	Kills[killerXPlayer.identifier] = Kills[killerXPlayer.identifier] + 1

	if weapon == "Unarmed" then
		weapon = "Pięść"
	end

	if deathData.bone == 31086 then
		local currentTime = os.time()
		local firstKillTime = firstKill[deathData.killerServerId]
		
		if firstKillTime and currentTime - firstKillTime > 30 then
			firstKill[deathData.killerServerId] = nil
			countHS[deathData.killerServerId] = nil
		end

		countHS[deathData.killerServerId] = (countHS[deathData.killerServerId] or 0) + 1

		if not firstKillTime then
			firstKill[deathData.killerServerId] = currentTime
		end

		if countHS[deathData.killerServerId] > 3 and currentTime - firstKill[deathData.killerServerId] < 30 then
			esx_core:SendLog(deathData.killerServerId, "Strzelanie headshotów", "Uwaga, podejrzenie oszustwa! "..GetPlayerName(deathData.killerServerId).. " Strzelił " .. countHS[deathData.killerServerId] .. " headshotów w " .. (currentTime - firstKill[deathData.killerServerId])  .. " sekund Broń: "..weapon, 'ActivatePhysics')
		end

		ensureStat(killerXPlayer.identifier, Headshots)
		Headshots[killerXPlayer.identifier] = Headshots[killerXPlayer.identifier] + 1
	end

	TriggerClientEvent("es_extended:setAfterWeaponData", killerXPlayer.source, Kills[killerXPlayer.identifier], false, Headshots[killerXPlayer.identifier])

	ensureStat(killerXPlayer.identifier, Kills)
	ensureStat(killerXPlayer.identifier, Headshots)
	ensureStat(killerXPlayer.identifier, Deaths)

	if deathData.distance > 120.0 then
		esx_core:SendLog(deathData.killerServerId, "Strzelanie dalej niż 120m", "Uwaga, podejrzenie oszustwa!"..GetPlayerName(deathData.killerServerId).. " Strzelił dalej niż 120m na odległość " .. deathData.distance .. "m Broń: **"..weapon, 'ac')
	end

	if xPlayer then
		local msg = "Zostałeś zabity przez ["..GetPlayerName(deathData.killerServerId).."] z odległości ["..deathData.distance.."m] Broń: ["..weapon.."]"
		TriggerClientEvent('esx_menu:showF8', xPlayer.source, msg)
	end

	esx_core:SendLog(deathData.killerServerId, "Zabójstwa", GetPlayerName(src).." zabity przez ".. GetPlayerName(deathData.killerServerId).. " z "..deathData.distance.."m, Broń: "..weapon, 'kills')
end)

AddEventHandler('esx:playerDropped', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local identifier = xPlayer.identifier
	MySQL.update.await('UPDATE users SET rankKills = ?, rankDeaths = ?, rankHeadshots = ? WHERE identifier = ?', {
		Kills[identifier] or 0,
		Deaths[identifier] or 0,
		Headshots[identifier] or 0,
		identifier
	})

	Kills[identifier] = nil
	Deaths[identifier] = nil
	Headshots[identifier] = nil
end)

AddEventHandler('esx:playerLoaded', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	MySQL.Async.fetchAll("SELECT rankKills, rankDeaths, rankHeadshots FROM users WHERE identifier = ?", { xPlayer.identifier }, function(result)
		if result and result[1] then
			local data = result[1]
			TriggerClientEvent("es_extended:setAfterWeaponData", xPlayer.source, data.rankKills, data.rankDeaths, data.rankHeadshots)

			Kills[xPlayer.identifier] = data.rankKills
			Deaths[xPlayer.identifier] = data.rankDeaths
			Headshots[xPlayer.identifier] = data.rankHeadshots
		end
	end)
end)

exports('CheckInsuranceEMS', CheckInsuranceEMS)
exports('CheckInsuranceLSC', CheckInsuranceLSC)

RegisterServerEvent('esx_menu:placeStinger', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer or xPlayer.job.name ~= 'police' then return end
	TriggerClientEvent('esx_menu:placeStinger', source)
end)
