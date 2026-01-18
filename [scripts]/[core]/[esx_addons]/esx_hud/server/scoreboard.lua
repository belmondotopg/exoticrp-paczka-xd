local Player = Player
local MySQL = MySQL
local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local ESX = ESX
local GetNumPlayerIndices = GetNumPlayerIndices
local GetConvarInt = GetConvarInt
local GetPlayerName = GetPlayerName
local Citizen = Citizen

local DC_TOKEN = "MTM2MjAyOTQ2OTgzMzEwNTQyOA.GKvtZ3.qygjatPM7E1s_-5TCBb8EVZxDKcJ8yCraKNTa4"
local DiscordGuild = "1244700092108378113"
local DEFAULT_MAX_PLAYERS = 300
local INIT_WAIT_TIME = 10000
local DISCORD_API_URL = 'https://discordapp.com/api/'

local DiscordRoles = {
	["1318648159530123334"] = "Founder",
	["1318648181067612241"] = "Owner",
	["1244700143794520094"] = "Co-Owner",
	["1318648286214885447"] = "Management",
	["1318648203360469102"] = "Head Administrator",
	["1318648256170823760"] = "Administrator",
	["1387555781934710934"] = "Trial Administrator",
	["1387555879309541478"] = "Senior Moderator",
	["1318648312139747440"] = "Moderator",
	["1387555728717385778"] = "Trial Moderator",
	["1318648332289179699"] = "Support",
	["1318648351352160336"] = "Trial Support"
}

local ADMIN_GROUPS = {
	['founder'] = true,
	['developer'] = true,
	['managment'] = true,
	['headadmin'] = true,
	['admin'] = true,
	['trialadmin'] = true,
	['seniormod'] = true,
	['mod'] = true,
	['moderator'] = true,
	['trialmod'] = true,
	['helper'] = true,
	['trialhelper'] = true,
	['support'] = true,
	['trialsupport'] = true,
}

local ADMIN_GROUPS_VIEW = {
	['founder'] = true,
	['developer'] = true,
	['managment'] = false,
	['headadmin'] = true,
	['admin'] = true,
	['trialadmin'] = true,
	['seniormod'] = true,
	['mod'] = true,
	['trialmod'] = true,
	['support'] = true,
	['trialsupport'] = true,
}

local ADMIN_GROUPS_ALLOWED = {
	['founder'] = true,
	['managment'] = true,
	['developer'] = false,
	['headadmin'] = true,
}

local POLICE_JOBS = {
	['police'] = true,
	['sheriff'] = true,
}

GlobalState.onlineAdmins = 0

local streamermode = {}
local connectedPlayers = {}
local Counter = {
	['ambulance'] = 0,
	['police'] = 0,
	['mechanik'] = 0,
	['cardealer'] = 0,
	['sheriff'] = 0,
	['doj'] = 0,
	['ec'] = 0,
	['players'] = 0,
	['maxPlayers'] = GetConvarInt('sv_maxclients', DEFAULT_MAX_PLAYERS)
}

local function ShouldCountJob(jobName, jobGrade, onDuty)
	if not Counter[jobName] then
		return false
	end
	
	if onDuty ~= true then
		return false
	end
	
	if POLICE_JOBS[jobName] then
		return jobGrade > 0
	end
	
	return true
end

local function IsAdminGroup(group)
	return ADMIN_GROUPS[group] == true
end

local Nametags = {}
local Usernames = {}
GlobalState.Nametags = {}
GlobalState.Usernames = {}

GlobalState.Counter = Counter

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
	if not playerId or not job or not connectedPlayers[playerId] then
		return
	end

	local wasOnDuty = connectedPlayers[playerId].onDuty
	local oldJob = connectedPlayers[playerId].job
	local oldJobGrade = connectedPlayers[playerId].jobgrade

	connectedPlayers[playerId].job = job.name
	connectedPlayers[playerId].joblabel = job.label
	connectedPlayers[playerId].jobgrade = job.grade
	connectedPlayers[playerId].onDuty = job.onDuty

	if oldJob == job.name and wasOnDuty ~= job.onDuty then
		if wasOnDuty == true and ShouldCountJob(oldJob, oldJobGrade, true) and Counter[oldJob] and Counter[oldJob] > 0 then
			Counter[oldJob] = Counter[oldJob] - 1
		end
		if job.onDuty == true and ShouldCountJob(job.name, job.grade, true) then
			Counter[job.name] = (Counter[job.name] or 0) + 1
		end
	else
		if lastJob and lastJob.name and ShouldCountJob(lastJob.name, lastJob.grade, wasOnDuty) and Counter[lastJob.name] and Counter[lastJob.name] > 0 then
			Counter[lastJob.name] = Counter[lastJob.name] - 1
		end

		if ShouldCountJob(job.name, job.grade, job.onDuty) then
			Counter[job.name] = (Counter[job.name] or 0) + 1
		end
	end

	GlobalState.Counter = Counter
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	if not xPlayer then return end

	if not connectedPlayers[playerId] then
		AddPlayerToScoreboard(xPlayer)
	else
		local oldJob = connectedPlayers[playerId].job
		local oldJobGrade = connectedPlayers[playerId].jobgrade
		local oldOnDuty = connectedPlayers[playerId].onDuty

		if ShouldCountJob(oldJob, oldJobGrade, oldOnDuty) and Counter[oldJob] and Counter[oldJob] > 0 then
			Counter[oldJob] = Counter[oldJob] - 1
		end

		connectedPlayers[playerId].job = xPlayer.job.name
		connectedPlayers[playerId].jobgrade = xPlayer.job.grade
		connectedPlayers[playerId].onDuty = xPlayer.job.onDuty

		if ShouldCountJob(xPlayer.job.name, xPlayer.job.grade, xPlayer.job.onDuty) then
			Counter[xPlayer.job.name] = (Counter[xPlayer.job.name] or 0) + 1
		end
	end

	if IsAdminGroup(xPlayer.group) then
		GlobalState.onlineAdmins = (GlobalState.onlineAdmins or 0) + 1
	end

	Counter['players'] = GetNumPlayerIndices()
	GlobalState.Counter = Counter

	TriggerClientEvent('esx_hud:updateStreamers', xPlayer.source, streamermode)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			local players = ESX.GetExtendedPlayers()

			for _, xPlayer in ipairs(players) do
				AddPlayerToScoreboard(xPlayer)
			end

			Citizen.Wait(INIT_WAIT_TIME)
			Counter['players'] = GetNumPlayerIndices()
			Counter['maxPlayers'] = GetConvarInt('sv_maxclients', DEFAULT_MAX_PLAYERS)

			GlobalState.Counter = Counter
		end)
	end
end)

AddEventHandler('esx:playerDropped', function(id)
	local xPlayer = ESX.GetPlayerFromId(id)

	if connectedPlayers[id] then
		local jobName = connectedPlayers[id].job
		local jobGrade = connectedPlayers[id].jobgrade
		local onDuty = connectedPlayers[id].onDuty

		if ShouldCountJob(jobName, jobGrade, onDuty) and Counter[jobName] and Counter[jobName] > 0 then
			Counter[jobName] = Counter[jobName] - 1
		end
		
		connectedPlayers[id] = nil
	end

	if xPlayer and IsAdminGroup(xPlayer.group) then
		GlobalState.onlineAdmins = math.max(0, (GlobalState.onlineAdmins or 0) - 1)
	end

	Counter['players'] = GetNumPlayerIndices()
	GlobalState.Counter = Counter
end)

function AddPlayerToScoreboard(xPlayer)
	if not xPlayer then return end

	local playerId = xPlayer.source
	local onDuty = xPlayer.job.onDuty
	
	-- Jeśli onDuty jest nil, ustaw domyślnie na true (dla kompatybilności wstecznej)
	if onDuty == nil then
		onDuty = true
	end
	
	connectedPlayers[playerId] = {
		id = playerId,
		identifier = xPlayer.identifier,
		name = xPlayer.getName(),
		username = GetPlayerName(playerId),
		job = xPlayer.job.name,
		jobgrade = xPlayer.job.grade,
		joblabel = xPlayer.job.label,
		onDuty = onDuty,
		group = xPlayer.group,
		isAdmin = ESX.IsPlayerAdmin(playerId),
		discord = xPlayer.discordid
	}

	local SSN = MySQL.scalar.await("SELECT id FROM users WHERE identifier = ?", {xPlayer.identifier})
	Player(playerId).state.ssn = SSN

	TriggerClientEvent('esx_core_discord:getPermID', xPlayer.source, SSN)
	
	if ShouldCountJob(xPlayer.job.name, xPlayer.job.grade, onDuty) then
		Counter[xPlayer.job.name] = (Counter[xPlayer.job.name] or 0) + 1
	end

	GlobalState.Counter = Counter
end

RegisterServerEvent('esx_hud:showPlayers')
AddEventHandler('esx_hud:showPlayers', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end

	local isPolice = (xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff')
	local esx_police = GetResourceState('esx_police') == 'started' and exports.esx_police or nil

	local infoCounter = {
		['police'] = 0,
		['ambulance'] = 0,
		['mechanik'] = 0,
		['cardealer'] = 0,
		['sheriff'] = 0,
		['ec'] = 0,
		['doj'] = 0,
		players = {}
	}

	for _, v in pairs(connectedPlayers) do
		if infoCounter[v.job] ~= nil then
			local shouldCount = true
			if POLICE_JOBS[v.job] and v.jobgrade == 0 then
				shouldCount = false
			end
			
			if v.onDuty ~= true then
				shouldCount = false
			end
			
			if shouldCount then
				infoCounter[v.job] = infoCounter[v.job] + 1
			end
		end

		local playerName = GetPlayerName(v.id)
		
		-- Sprawdź czy gracz ma opaskę i czy oglądający to policja
		if isPolice and esx_police and esx_police:hasBracelet(v.id) then
			local targetPlayer = ESX.GetPlayerFromId(v.id)
			if targetPlayer then
				local firstName = targetPlayer.get('firstName') or ''
				local lastName = targetPlayer.get('lastName') or ''
				playerName = '[LOKALIZATOR] ' .. firstName .. '_' .. lastName
			end
		end

		table.insert(infoCounter['players'], {
			playerAvatar = v.avatar,
			playerId = v.id,
			playerName = playerName,
			playerDiscordID = "[".. v.job .. "]"
		})
	end

	Counter['police'] = infoCounter['police']
	Counter['ambulance'] = infoCounter['ambulance']
	Counter['mechanik'] = infoCounter['mechanik']
	Counter['cardealer'] = infoCounter['cardealer']
	Counter['sheriff'] = infoCounter['sheriff']
	Counter['doj'] = infoCounter['doj']
	Counter['ec'] = infoCounter['ec']

	GlobalState.Counter = Counter

	local info = {
		players = infoCounter['players'],
		onlinePlayers = Counter['players'],
		playerName = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'),
		playerJob = xPlayer.job.label,
		playerJobGrade = xPlayer.job.grade_label,
		lspd = infoCounter['police'],
		lssd = infoCounter['sheriff'],
		ems = infoCounter['ambulance'],
		doj = infoCounter['doj'],
		lsc = infoCounter['mechanik'],
		ec = infoCounter['ec'],
		dangerCode = GlobalState.dangerCode,
	}

	table.sort(info.players, function(a, b)
		return a.playerId < b.playerId
	end)

	TriggerClientEvent('esx_hud:showPlayers', src, info)
end)

RegisterCommand('admins', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer or not ADMIN_GROUPS_ALLOWED[xPlayer.group] then
		return
	end

	local adminsTable = {}
	for _, v in pairs(connectedPlayers) do
		if ADMIN_GROUPS_VIEW[v.group] then
			table.insert(adminsTable, {
				title = '['..v.id..'] '..v.username,
				description = 'Ranga: '..v.group
			})
		end
	end
	
	TriggerClientEvent('esx_hud:open_admin_list', src, adminsTable)
end, false)

RegisterNetEvent("txsv:req:spectate:end", function()
	local src = source
	Player(src).state.Spectating = false
end)

RegisterNetEvent("txsv:req:spectate:start", function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if xPlayer.group == 'user' then return end
	Player(src).state.Spectating = true
end)

RegisterCommand('live', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end

	if streamermode[xPlayer.source] then
		streamermode[xPlayer.source] = nil
		xPlayer.showNotification('Wyłączono tryb streamera!')
	else
		streamermode[xPlayer.source] = true
		xPlayer.showNotification('Włączono tryb streamera!')
	end

	TriggerClientEvent('esx_hud:updateStreamers', -1, streamermode)
	TriggerClientEvent('esx_hud:updateStreamersRadio', -1, streamermode)
end, false)

local function Players()
	return connectedPlayers
end

local function CounterPlayers(what)
	return Counter[what]
end

exports('Players', Players)
exports('CounterPlayers', CounterPlayers)

local function GetPlayerIdentifierByType(source, type, sub)
	local identifiers = GetPlayerIdentifiers(source)

	for i = 1, #identifiers do
		if identifiers[i]:match(type .. ':') then
			if sub then
				return identifiers[i]:sub(type:len() + 2, identifiers[i]:len())
			end

			return identifiers[i]
		end
	end

	return nil
end

local function DiscordApiRequest(method, endpoint, jsonData)
    local data = nil
    local jsonString = #jsonData > 0 and json.encode(jsonData) or ''
  
    PerformHttpRequest(DISCORD_API_URL .. endpoint, function(errorCode, resultData, resultHeaders)
        data = {
            data = resultData,
            code = errorCode,
            headers = resultHeaders
        }
    end, method, jsonString, {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. DC_TOKEN
    })
  
    while data == nil do
        Citizen.Wait(0)
    end
  
    return data
end 

local function DiscordGetRoles(discordId)
    local endpoint = ('guilds/%s/members/%s'):format(DiscordGuild, discordId)
    local member = DiscordApiRequest('GET', endpoint, {})
  
    if member.code == 200 then
        local data = json.decode(member.data)
        
        return data.roles
    end
  
    return nil
end

local function PlayerDiscordRoles(playerId)
	if playerId then
		local discordId = GetPlayerIdentifierByType(playerId, 'discord', true)
		if discordId then
            local userRoles = DiscordGetRoles(discordId)

            if userRoles then
                for _, roleId in ipairs(userRoles) do
                    local roleGroup = DiscordRoles[roleId]
                    if roleGroup then
                        return roleGroup
                    end
                end
            end
		end
	end

	return 'user'
end

RegisterCommand("nametag", function(source)
	local src = source
	local srcString = tostring(src)
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end

	local playerRole = PlayerDiscordRoles(src)
	if playerRole == "user" then return end

	if not Nametags[srcString] then 
		Nametags[srcString] = playerRole
		xPlayer.showNotification("Włączono wyświetlanie Name-tagu [" .. playerRole .. "]")
	else
		Nametags[srcString] = nil
		xPlayer.showNotification("Wyłączono wyświetlanie Name-tagu [" .. playerRole .. "]")
	end
	
	if not Usernames[srcString] then 
		Usernames[srcString] = GetPlayerName(src)
	end

	GlobalState.Usernames = Usernames
	GlobalState.Nametags = Nametags
end)