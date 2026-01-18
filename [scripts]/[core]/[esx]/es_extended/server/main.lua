SetMapName("San Andreas")
SetGameType("ESX Legacy")

local oneSyncState = GetConvar("onesync", "off")
local DC_TOKEN = "MTQ1Nzc1NTg4MDc2NTUyNjA4OA.G-Ddy9.xbRAfdaIsU97AaZKGBHF419kxU0loJ03jNy7Zw"
local DiscordGuild = "1244700092108378113"
local DiscordRoles = {
    ['1318648159530123334'] = 'founder',
    ['1458653662669701213'] = 'founder',
    ['1318648286214885447'] = 'managment',
    ['1318648203360469102'] = 'headadmin',
    ['1318648256170823760'] = 'admin',
    ['1387555781934710934'] = 'trialadmin',
    ['1387555879309541478'] = 'seniormod',
    ['1318648312139747440'] = 'mod',
    ['1387555728717385778'] = 'trialmod',
    ['1318648332289179699'] = 'support',
    ['1318648351352160336'] = 'trialsupport',
    ['1318648922171772949'] = 'user',
}

local AddonRoles = {
    [''] = 'Gracz',
    [''] = 'SVIP',
    [''] = 'ELITE',
    [''] = 'VIP',
    ['1439768214249672918'] = 'PED'
}

local DiscordRolesCache = {}
local DiscordCacheTTL = 300000
local DiscordRequestQueue = {}
local DiscordRequestInProgress = false
local DiscordRequestDelay = 100

local newPlayer = "INSERT INTO `users` SET `accounts` = ?, `identifier` = ?, `group` = ?"
local loadPlayer = 'SELECT `id`, `accounts`, `inventory`, `job`, `job_grade`, `group`, `position`, `skin`, `metadata`, `discordid`, `firstname`, `lastname`, `dateofbirth`, `sex`, `height`, `playerName`, `badge`, `nationality`, `multi_jobs` FROM users WHERE identifier = ?'

if Config.Multichar then
    newPlayer = newPlayer .. ", `firstname` = ?, `lastname` = ?, `dateofbirth` = ?, `nationality` = ?, `sex` = ?, `height` = ?"
end

if Config.StartingInventoryItems then
    newPlayer = newPlayer .. ", `inventory` = ?"
end

local function GetPlayerIdentifierByType(source, type, sub)
    local identifiers = GetPlayerIdentifiers(source)

    for i = 1, #identifiers do
        if identifiers[i]:match(type .. ':') then
            if sub then
                return identifiers[i]:sub(type:len() + 2)
            end
            return identifiers[i]
        end
    end
end

local function DiscordApiRequest(method, endpoint, jsonData)
    local data

    PerformHttpRequest('https://discordapp.com/api/' .. endpoint, function(errorCode, resultData, resultHeaders)
        data = {
            data = resultData,
            code = errorCode,
            headers = resultHeaders
        }
    end, method, #jsonData > 0 and json.encode(jsonData) or '', {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. DC_TOKEN
    })

    while not data do
        Citizen.Wait(0)
    end

    return data
end

local function ProcessDiscordQueue()
    if DiscordRequestInProgress or #DiscordRequestQueue == 0 then
        return
    end

    DiscordRequestInProgress = true
    local request = table.remove(DiscordRequestQueue, 1)
    
    CreateThread(function()
        local endpoint = ('guilds/%s/members/%s'):format(DiscordGuild, request.discordId)
        local member = DiscordApiRequest('GET', endpoint, {})
        
        if member.code == 200 then
            local data = json.decode(member.data)
            
            if data and data.roles then
                local cacheEntry = {
                    roles = data.roles,
                    timestamp = GetGameTimer(),
                    group = nil,
                    addonRoles = {}
                }
                
                cacheEntry.group = 'user'
                for _, roleId in ipairs(data.roles) do
                    local roleGroup = DiscordRoles[roleId]
                    if roleGroup then
                        cacheEntry.group = roleGroup
                        break
                    end
                end
                
                for _, roleId in ipairs(data.roles) do
                    local addonRole = AddonRoles[roleId]
                    if addonRole then
                        cacheEntry.addonRoles[addonRole] = true
                    end
                end
                
                DiscordRolesCache[request.discordId] = cacheEntry
                
                if request.callback then
                    request.callback(cacheEntry.group, cacheEntry.addonRoles)
                end
            end
        elseif member.code == 429 then
            print(('[^3WARNING^7] Discord API rate limit hit, retrying for %s later'):format(request.discordId))
            table.insert(DiscordRequestQueue, request)
            Wait(5000)
        end
        
        DiscordRequestInProgress = false
        
        Wait(DiscordRequestDelay)
        ProcessDiscordQueue()
    end)
end

local function QueueDiscordRequest(discordId, callback)
    for _, req in ipairs(DiscordRequestQueue) do
        if req.discordId == discordId then
            if callback then
                req.callback = callback
            end
            return
        end
    end
    
    table.insert(DiscordRequestQueue, {
        discordId = discordId,
        callback = callback
    })

    ProcessDiscordQueue()
end 

local function DiscordGetRoles(discordId, useCache)
    useCache = useCache ~= false
    
    if not discordId then
        return nil
    end
    
    if useCache and DiscordRolesCache[discordId] then
        local cacheEntry = DiscordRolesCache[discordId]
        local cacheAge = GetGameTimer() - cacheEntry.timestamp
        
        if cacheAge < DiscordCacheTTL then
            return cacheEntry.roles
        end
    end
    
    QueueDiscordRequest(discordId)
    
    if DiscordRolesCache[discordId] then
        return DiscordRolesCache[discordId].roles
    end
    
    return nil
end

local function PlayerDiscordRoles(playerId, useCache, fallbackGroup)
    useCache = useCache ~= false

    if playerId then
        local discordId = GetPlayerIdentifierByType(playerId, 'discord', true)
        if discordId then
            if useCache and DiscordRolesCache[discordId] then
                local cacheEntry = DiscordRolesCache[discordId]
                local cacheAge = GetGameTimer() - cacheEntry.timestamp

                if cacheAge < DiscordCacheTTL and cacheEntry.group then
                    return cacheEntry.group
                end

                if cacheEntry.group then
                    QueueDiscordRequest(discordId)
                    return cacheEntry.group
                end
            end

            local userRoles = DiscordGetRoles(discordId, useCache)

            if userRoles then
                for _, roleId in ipairs(userRoles) do
                    local roleGroup = DiscordRoles[roleId]
                    if roleGroup then
                        return roleGroup
                    end
                end
            else
                QueueDiscordRequest(discordId)
            end
        end
    end

    return fallbackGroup or 'user'
end

function ESX.AddonPlayerDiscordRoles(playerId, roleType, useCache)
    useCache = useCache ~= false

    if playerId then
        local discordId = GetPlayerIdentifierByType(playerId, 'discord', true)

        if discordId then
            if useCache and DiscordRolesCache[discordId] then
                local cacheEntry = DiscordRolesCache[discordId]
                local cacheAge = GetGameTimer() - cacheEntry.timestamp

                if cacheAge < DiscordCacheTTL and cacheEntry.addonRoles[roleType] then
                    return roleType
                end
            end

            local userRoles = DiscordGetRoles(discordId, useCache)

            if userRoles then
                for _, roleId in ipairs(userRoles) do
                    local roleGroup = AddonRoles[roleId]

                    if roleGroup == roleType then
                        return roleGroup
                    end
                end
            else
                QueueDiscordRequest(discordId)
            end
        end
    end

    return false
end

local function createESXPlayer(identifier, playerId, data)
    local accounts = {}

    for account, money in pairs(Config.StartingAccountMoney) do
        accounts[account] = money
    end

    local defaultGroup = PlayerDiscordRoles(playerId, true, nil) or "user"
    if defaultGroup == "user" and Core.IsPlayerAdmin(playerId) then
        print(("[^2INFO^0] Player ^5%s^0 Has been granted admin permissions via ^5Ace Perms^7."):format(playerId))
        defaultGroup = "admin"
    elseif defaultGroup ~= "user" then
        print(("[^2INFO^0] Player ^5%s^0 Has been granted ^5%s^0 permissions via ^5Discord roles^7."):format(playerId, defaultGroup))
    end
    
    local discordId = GetPlayerIdentifierByType(playerId, 'discord', true)
    if discordId then
        QueueDiscordRequest(discordId)
    end

    local parameters = Config.Multichar and { json.encode(accounts), identifier, defaultGroup, data.firstname, data.lastname, data.dateofbirth, data.nationality, data.sex, data.height } or { json.encode(accounts), identifier, defaultGroup }

    if Config.StartingInventoryItems then
        table.insert(parameters, json.encode(Config.StartingInventoryItems))
    end

    MySQL.prepare(newPlayer, parameters, function()
        loadESXPlayer(identifier, playerId, true)
    end)
end

local function onPlayerJoined(playerId)
    local identifier = ESX.GetIdentifier(playerId)
    if not identifier then
        return DropPlayer(playerId, "there was an error loading your character!\nError code: identifier-missing-ingame\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.")
    end

    if ESX.GetPlayerFromIdentifier(identifier) then
        DropPlayer(
            playerId,
            ("there was an error loading your character!\nError code: identifier-active-ingame\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same Rockstar account.\n\nYour Rockstar identifier: %s"):format(
                identifier
            )
        )
    else
        local result = MySQL.scalar.await("SELECT 1 FROM users WHERE identifier = ?", { identifier })
        if result then
            loadESXPlayer(identifier, playerId, false)
        else
            createESXPlayer(identifier, playerId)
        end
    end
end

local function onPlayerDropped(playerId, reason, cb)
    local p = not cb and promise:new()
    local function resolve()
        if cb then
            return cb()
        elseif p then
            return p:resolve()
        end
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return resolve()
    end

    TriggerEvent("esx:playerDropped", playerId, reason)

    Core.SavePlayer(xPlayer, function()
        GlobalState["playerCount"] = GlobalState["playerCount"] - 1
        ESX.Players[playerId] = nil
        Core.playersByIdentifier[xPlayer.identifier] = nil

        resolve()
    end)

    if p then
        return Citizen.Await(p)
    end
end
AddEventHandler("esx:onPlayerDropped", onPlayerDropped)

if Config.Multichar then
    AddEventHandler("esx:onPlayerJoined", function(src, char, data)
        while not next(ESX.Jobs) do
            Wait(50)
        end

        if not ESX.Players[src] then
            local identifier = char .. ":" .. ESX.GetIdentifier(src)
            if data then
                createESXPlayer(identifier, src, data)
            else
                loadESXPlayer(identifier, src, false)
            end
        end
    end)
else
    RegisterNetEvent("esx:onPlayerJoined", function()
        local _source = source
        while not next(ESX.Jobs) do
            Wait(50)
        end

        if not ESX.Players[_source] then
            onPlayerJoined(_source)
        end
    end)
end

if not Config.Multichar then
    AddEventHandler("playerConnecting", function(_, _, deferrals)
        local playerId = source
        deferrals.defer()
        Wait(0)
        local identifier
        local correctLicense, _ = pcall(function ()
            identifier = ESX.GetIdentifier(playerId)
        end)

        if not SetEntityOrphanMode then
            return deferrals.done(("[ESX] ESX Requires a minimum Artifact version of 10188, Please update your server."))
        end

        if oneSyncState == "off" or oneSyncState == "legacy" then
            return deferrals.done(("[ESX] ESX Requires Onesync Infinity to work. This server currently has Onesync set to: %s"):format(oneSyncState))
        end

        if not Core.DatabaseConnected then
            return deferrals.done("[ESX] OxMySQL Was Unable To Connect to your database. Please make sure it is turned on and correctly configured in your server.cfg")
        end

        if not identifier or not correctLicense then
            if GetResourceState("esx_identity") ~= "started" then
                return deferrals.done("[ESX] There was an error loading your character!\nError code: identifier-missing\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.")
            end
        end

        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)

        if not xPlayer then
            return deferrals.done()
        end

        if GetPlayerPing(xPlayer.source) > 0 then
            return deferrals.done(
                ("[ESX] There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same account.\n\nYour identifier: %s"):format(identifier)
            )
        end

        deferrals.update("[ESX] Cleaning stale player entry...")
        onPlayerDropped(xPlayer.source, "esx_stale_player_obj")
        deferrals.done()
    end)
end

function loadESXPlayer(identifier, playerId, isNew)
    local userData = {
        accounts = {},
        inventory = {},
        loadout = {},
        weight = 0,
        name = GetPlayerName(playerId),
        identifier = identifier,
        firstName = "John",
        lastName = "Doe",
        dateofbirth = "01/01/2000",
        height = 120,
        dead = false,
        discordid = "",
    }

    local result = MySQL.prepare.await(loadPlayer, { identifier })

    local accounts = result.accounts
    accounts = (accounts and accounts ~= "") and json.decode(accounts) or {}

    for account, data in pairs(Config.Accounts) do
        data.round = data.round ~= false

        local index = #userData.accounts + 1
        userData.accounts[index] = {
            name = account,
            money = accounts[account] or Config.StartingAccountMoney[account] or 0,
            label = data.label,
            round = data.round,
            index = index,
        }
    end

    local job, grade = result.job, tostring(result.job_grade)

    if not ESX.DoesJobExist(job, grade) then
        print(("[^3WARNING^7] Ignoring invalid job for ^5%s^7 [job: ^5%s^7, grade: ^5%s^7]"):format(identifier, job, grade))
        job, grade = "unemployed", "0"
    end

    local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

    userData.job = {
        id = jobObject.id,
        name = jobObject.name,
        label = jobObject.label,

        grade = tonumber(grade),
        grade_name = gradeObject.name,
        grade_label = gradeObject.label,
        grade_salary = gradeObject.salary,
        grade_coins = gradeObject.coins,
        grade_perhour = gradeObject.perhour,

        skin_male = gradeObject.skin_male and json.decode(gradeObject.skin_male) or {},
        skin_female = gradeObject.skin_female and json.decode(gradeObject.skin_female) or {},
    }

    if not Config.CustomInventory then
        local inventory = (result.inventory and result.inventory ~= "") and json.decode(result.inventory) or {}

        for name, item in pairs(ESX.Items) do
            local count = inventory[name] or 0
            userData.weight += (count * item.weight)

            userData.inventory[#userData.inventory + 1] = {
                name = name,
                count = count,
                label = item.label,
                weight = item.weight,
                usable = Core.UsableItemsCallbacks[name] ~= nil,
                rare = item.rare,
                canRemove = item.canRemove,
            }
        end
        table.sort(userData.inventory, function(a, b)
            return a.label < b.label
        end)
    elseif result.inventory and result.inventory ~= "" then
        userData.inventory = json.decode(result.inventory)
    end

    local dbGroup = result.group or 'user'
    local discordGroup = PlayerDiscordRoles(playerId, true, dbGroup)
    userData.group = discordGroup or dbGroup

    if discordGroup and discordGroup ~= dbGroup then
        print(('[^2INFO^0] Player ^5%s^0 assigned group ^5%s^0 via Discord roles (was: ^5%s^0)'):format(identifier, discordGroup, dbGroup))
    elseif not discordGroup or discordGroup == 'user' then
        userData.group = dbGroup
    end

    local discordId = GetPlayerIdentifierByType(playerId, 'discord', true)
    if discordId then
        QueueDiscordRequest(discordId, function(group, addonRoles)
            if group and group ~= userData.group then
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer then
                    xPlayer.setGroup(group)
                    print(('[^2INFO^0] Player ^5%s^0 group updated to ^5%s^0 via Discord roles refresh (was: ^5%s^0)'):format(identifier, group, userData.group))
                end
            end
        end)
    end

    userData.coords = json.decode(result.position) or Config.DefaultSpawns[ESX.Math.Random(1,#Config.DefaultSpawns)]

    userData.skin = (result.skin and result.skin ~= "") and json.decode(result.skin) or { sex = userData.sex == "f" and 1 or 0 }

    userData.metadata = (result.metadata and result.metadata ~= "") and json.decode(result.metadata) or {}
    userData.discordid = discordId or result.discordid
    
    userData.vip = ESX.AddonPlayerDiscordRoles(playerId, 'VIP', true)
    userData.svip = ESX.AddonPlayerDiscordRoles(playerId, 'SVIP', true)
    userData.elite = ESX.AddonPlayerDiscordRoles(playerId, 'ELITE', true)
    userData.pedperms = ESX.AddonPlayerDiscordRoles(playerId, 'PED', true)
    userData.source = playerId

    if result.firstname and result.firstname ~= "" then
        userData.firstName = result.firstname
        userData.lastName = result.lastname

        local name = ("%s %s"):format(result.firstname, result.lastname)
        userData.name = name

        if result.dateofbirth then
            userData.dateofbirth = result.dateofbirth
        end

        if result.playerName ~= GetPlayerName(playerId) then
            userData.playerName = GetPlayerName(playerId)
        end

        if result.sex then
            userData.sex = result.sex
        end

        if result.height then
            userData.height = result.height
        end

        if result.badge then
            userData.badge = result.badge
        end
    
        if result.nationality then
            userData.nationality = result.nationality
        end

        if result.multi_jobs then
            userData.multi_jobs = result.multi_jobs
        end
    end

    local xPlayer = CreateExtendedPlayer(playerId, identifier, userData.group, userData.accounts, userData.inventory, userData.weight, userData.job, userData.loadout, GetPlayerName(playerId), userData.coords, userData.metadata, userData.badge, userData.discordid, userData.playerName, userData.nationality, userData.multi_jobs, userData.vip, userData.svip, userData.elite, userData.pedperms)

    if result.firstname and result.firstname ~= "" then
        local name = ("%s %s"):format(result.firstname, result.lastname)

        xPlayer.set("firstName", result.firstname)
        xPlayer.set("lastName", result.lastname)
        xPlayer.setName(name)

        if result.dateofbirth then
            xPlayer.set("dateofbirth", result.dateofbirth)
        end

        if result.playerName then
            xPlayer.set("playerName", result.playerName)
        end

        if result.sex then
            xPlayer.set("sex", result.sex)
        end

        if result.height then
            xPlayer.set("height", result.height)
        end

        if result.badge then
            xPlayer.set("badge", result.badge)
        end
    
        if result.nationality then
            xPlayer.set("nationality", result.nationality)
        end

        if result.multi_jobs then
            xPlayer.set("multi_jobs", result.multi_jobs)
        end
    end

    if xPlayer.multi_jobs and ESX.UpdateMultiJobsLabels then
        ESX.UpdateMultiJobsLabels(xPlayer)
    end

    GlobalState["playerCount"] = GlobalState["playerCount"] + 1
    ESX.Players[playerId] = xPlayer
    Core.playersByIdentifier[identifier] = xPlayer

    TriggerEvent("esx:playerLoaded", playerId, xPlayer, isNew)
    userData.money = xPlayer.getMoney()
    userData.maxWeight = xPlayer.getMaxWeight()
    userData.variables = xPlayer.variables or {}
    xPlayer.triggerEvent("esx:playerLoaded", userData, isNew, userData.skin)

    if not Config.CustomInventory then
        xPlayer.triggerEvent("esx:createMissingPickups", Core.Pickups)
    elseif setPlayerInventory then
        setPlayerInventory(playerId, xPlayer, userData.inventory, isNew)
    end

    xPlayer.triggerEvent("esx:registerSuggestions", Core.RegisteredCommands)
    print(('[^2INFO^0] Player ^5"%s"^0 has connected to the server. ID: ^5%s^7'):format(xPlayer.getName(), playerId))
end

AddEventHandler("chatMessage", function(playerId, _, message)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and message:sub(1, 1) == "/" and playerId > 0 then
        CancelEvent()
        local commandName = message:sub(1):gmatch("%w+")()
        xPlayer.showNotification(TranslateCap("commanderror_invalidcommand", commandName), "error")
    end
end)

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer then
        TriggerEvent("esx:playerDropped", playerId, reason)
        Core.playersByIdentifier[xPlayer.identifier] = nil

        Core.SavePlayer(xPlayer, function()
            GlobalState["playerCount"] = GlobalState["playerCount"] - 1
            ESX.Players[playerId] = nil
        end)
    end
end)

AddEventHandler("esx:playerLogout", function(playerId, cb)
    onPlayerDropped(playerId, "esx_player_logout", cb)
    TriggerClientEvent("esx:onPlayerLogout", playerId)
end)

if not Config.CustomInventory then
    RegisterNetEvent("esx:updateWeaponAmmo", function(weaponName, ammoCount)
        local xPlayer = ESX.GetPlayerFromId(source)

        if xPlayer then
            xPlayer.updateWeaponAmmo(weaponName, ammoCount)
        end
    end)

    RegisterNetEvent("esx:giveInventoryItem", function(target, itemType, itemName, itemCount)
        local playerId = source
        local sourceXPlayer = ESX.GetPlayerFromId(playerId)
        local targetXPlayer = ESX.GetPlayerFromId(target)
        local distance = #(GetEntityCoords(GetPlayerPed(playerId)) - GetEntityCoords(GetPlayerPed(target)))
        if not sourceXPlayer or not targetXPlayer or distance > Config.DistanceGive then
            print(("[^3WARNING^7] Player Detected Cheating: ^5%s^7"):format(GetPlayerName(playerId)))
            return
        end

        if itemType == "item_standard" then
            local sourceItem = sourceXPlayer.getInventoryItem(itemName)

            if itemCount < 1 or sourceItem.count < itemCount then
                return sourceXPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
            end

            if not targetXPlayer.canCarryItem(itemName, itemCount) then
                return sourceXPlayer.showNotification(TranslateCap("ex_inv_lim", targetXPlayer.name))
            end

            sourceXPlayer.removeInventoryItem(itemName, itemCount)
            targetXPlayer.addInventoryItem(itemName, itemCount)

            sourceXPlayer.showNotification(TranslateCap("gave_item", itemCount, sourceItem.label, targetXPlayer.name))
            targetXPlayer.showNotification(TranslateCap("received_item", itemCount, sourceItem.label, sourceXPlayer.name))
        elseif itemType == "item_account" then
            if itemCount < 1 or sourceXPlayer.getAccount(itemName).money < itemCount then
                return sourceXPlayer.showNotification(TranslateCap("imp_invalid_amount"))
            end

            sourceXPlayer.removeAccountMoney(itemName, itemCount, "Gave to " .. targetXPlayer.name)
            targetXPlayer.addAccountMoney(itemName, itemCount, "Received from " .. sourceXPlayer.name)

            sourceXPlayer.showNotification(TranslateCap("gave_account_money", ESX.Math.GroupDigits(itemCount), Config.Accounts[itemName].label, targetXPlayer.name))
            targetXPlayer.showNotification(TranslateCap("received_account_money", ESX.Math.GroupDigits(itemCount), Config.Accounts[itemName].label, sourceXPlayer.name))
        elseif itemType == "item_weapon" then
            if not sourceXPlayer.hasWeapon(itemName) then
                return
            end

            local weaponLabel = ESX.GetWeaponLabel(itemName)
            if targetXPlayer.hasWeapon(itemName) then
                sourceXPlayer.showNotification(TranslateCap("gave_weapon_hasalready", targetXPlayer.name, weaponLabel))
                targetXPlayer.showNotification(TranslateCap("received_weapon_hasalready", sourceXPlayer.name, weaponLabel))
                return
            end

            local _, weapon = sourceXPlayer.getWeapon(itemName)
            local _, weaponObject = ESX.GetWeapon(itemName)
            itemCount = weapon.ammo
            local weaponComponents = ESX.Table.Clone(weapon.components)
            local weaponTint = weapon.tintIndex

            if weaponTint then
                targetXPlayer.setWeaponTint(itemName, weaponTint)
            end

            if weaponComponents then
                for _, v in pairs(weaponComponents) do
                    targetXPlayer.addWeaponComponent(itemName, v)
                end
            end

            sourceXPlayer.removeWeapon(itemName)
            targetXPlayer.addWeapon(itemName, itemCount)

            if weaponObject.ammo and itemCount > 0 then
                local ammoLabel = weaponObject.ammo.label
                sourceXPlayer.showNotification(TranslateCap("gave_weapon_withammo", weaponLabel, itemCount, ammoLabel, targetXPlayer.name))
                targetXPlayer.showNotification(TranslateCap("received_weapon_withammo", weaponLabel, itemCount, ammoLabel, sourceXPlayer.name))
            else
                sourceXPlayer.showNotification(TranslateCap("gave_weapon", weaponLabel, targetXPlayer.name))
                targetXPlayer.showNotification(TranslateCap("received_weapon", weaponLabel, sourceXPlayer.name))
            end
        elseif itemType == "item_ammo" then
            if not sourceXPlayer.hasWeapon(itemName) then
                return
            end

            local _, weapon = sourceXPlayer.getWeapon(itemName)

            if not targetXPlayer.hasWeapon(itemName) then
                sourceXPlayer.showNotification(TranslateCap("gave_weapon_noweapon", targetXPlayer.name))
                targetXPlayer.showNotification(TranslateCap("received_weapon_noweapon", sourceXPlayer.name, weapon.label))
                return
            end

            local _, weaponObject = ESX.GetWeapon(itemName)

            if not weaponObject.ammo then return end

            local ammoLabel = weaponObject.ammo.label
            if weapon.ammo >= itemCount then
                sourceXPlayer.removeWeaponAmmo(itemName, itemCount)
                targetXPlayer.addWeaponAmmo(itemName, itemCount)

                sourceXPlayer.showNotification(TranslateCap("gave_weapon_ammo", itemCount, ammoLabel, weapon.label, targetXPlayer.name))
                targetXPlayer.showNotification(TranslateCap("received_weapon_ammo", itemCount, ammoLabel, weapon.label, sourceXPlayer.name))
            end
        end
    end)

    RegisterNetEvent("esx:removeInventoryItem", function(itemType, itemName, itemCount)
        local playerId = source
        local xPlayer = ESX.GetPlayerFromId(playerId)

        if itemType == "item_standard" then
            if not itemCount or itemCount < 1 then
                return xPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
            end

            local xItem = xPlayer.getInventoryItem(itemName)

            if itemCount > xItem.count or xItem.count < 1 then
                return xPlayer.showNotification(TranslateCap("imp_invalid_quantity"))
            end

            xPlayer.removeInventoryItem(itemName, itemCount)
            local pickupLabel = ("%s [%s]"):format(xItem.label, itemCount)
            ESX.CreatePickup("item_standard", itemName, itemCount, pickupLabel, playerId)
            xPlayer.showNotification(TranslateCap("threw_standard", itemCount, xItem.label))
        elseif itemType == "item_account" then
            if itemCount == nil or itemCount < 1 then
                return xPlayer.showNotification(TranslateCap("imp_invalid_amount"))
            end

            local account = xPlayer.getAccount(itemName)

            if itemCount > account.money or account.money < 1 then
                return xPlayer.showNotification(TranslateCap("imp_invalid_amount"))
            end

            xPlayer.removeAccountMoney(itemName, itemCount, "Threw away")
            local pickupLabel = ("%s [%s]"):format(account.label, TranslateCap("locale_currency", ESX.Math.GroupDigits(itemCount)))
            ESX.CreatePickup("item_account", itemName, itemCount, pickupLabel, playerId)
            xPlayer.showNotification(TranslateCap("threw_account", ESX.Math.GroupDigits(itemCount), string.lower(account.label)))
        elseif itemType == "item_weapon" then
            itemName = string.upper(itemName)

            if not xPlayer.hasWeapon(itemName) then return end

            local _, weapon = xPlayer.getWeapon(itemName)
            local _, weaponObject = ESX.GetWeapon(itemName)
            local weaponPickupLabel = ""
            local components = ESX.Table.Clone(weapon.components)
            xPlayer.removeWeapon(itemName)

            if weaponObject.ammo and weapon.ammo > 0 then
                local ammoLabel = weaponObject.ammo.label
                weaponPickupLabel = ("%s [%s %s]"):format(weapon.label, weapon.ammo, ammoLabel)
                xPlayer.showNotification(TranslateCap("threw_weapon_ammo", weapon.label, weapon.ammo, ammoLabel))
            else
                weaponPickupLabel = ("%s"):format(weapon.label)
                xPlayer.showNotification(TranslateCap("threw_weapon", weapon.label))
            end

            ESX.CreatePickup("item_weapon", itemName, weapon.ammo, weaponPickupLabel, playerId, components, weapon.tintIndex)
        end
    end)

    RegisterNetEvent("esx:useItem", function(itemName)
        local source = source
        local xPlayer = ESX.GetPlayerFromId(source)
        local count = xPlayer.getInventoryItem(itemName).count

        if count < 1 then
            return xPlayer.showNotification(TranslateCap("act_imp"))
        end

        ESX.UseItem(source, itemName)
    end)

    RegisterNetEvent("esx:onPickup", function(pickupId)
        local pickup, xPlayer, success = Core.Pickups[pickupId], ESX.GetPlayerFromId(source)

        if not pickup then return end

        local playerPickupDistance = #(pickup.coords - xPlayer.getCoords(true))
        if playerPickupDistance > 5.0 then
            print(("[^3WARNING^7] Player Detected Cheating (Out of range pickup): ^5%s^7"):format(xPlayer.getIdentifier()))
            return
        end

        if pickup.type == "item_standard" then
            if not xPlayer.canCarryItem(pickup.name, pickup.count) then
                return xPlayer.showNotification(TranslateCap("threw_cannot_pickup"))
            end

            xPlayer.addInventoryItem(pickup.name, pickup.count)
            success = true
        elseif pickup.type == "item_account" then
            success = true
            xPlayer.addAccountMoney(pickup.name, pickup.count, "Picked up")
        elseif pickup.type == "item_weapon" then
            if xPlayer.hasWeapon(pickup.name) then
                return xPlayer.showNotification(TranslateCap("threw_weapon_already"))
            end

            success = true
            xPlayer.addWeapon(pickup.name, pickup.count)
            xPlayer.setWeaponTint(pickup.name, pickup.tintIndex)

            for _, v in ipairs(pickup.components) do
                xPlayer.addWeaponComponent(pickup.name, v)
            end
        end

        if success then
            Core.Pickups[pickupId] = nil
            TriggerClientEvent("esx:removePickup", -1, pickupId)
        end
    end)
end

ESX.RegisterServerCallback("esx:getPlayerData", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    cb({
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
        position = xPlayer.getCoords(true),
        metadata = xPlayer.getMeta(),
    })
end)

ESX.RegisterServerCallback("esx:isUserAdmin", function(source, cb)
    cb(Core.IsPlayerAdmin(source))
end)

ESX.RegisterServerCallback("esx:getGameBuild", function(_, cb)
    cb(tonumber(GetConvar("sv_enforceGameBuild", "1604")))
end)

ESX.RegisterServerCallback("esx:getOtherPlayerData", function(_, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    cb({
        identifier = xPlayer.identifier,
        accounts = xPlayer.getAccounts(),
        inventory = xPlayer.getInventory(),
        job = xPlayer.getJob(),
        loadout = xPlayer.getLoadout(),
        money = xPlayer.getMoney(),
        position = xPlayer.getCoords(true),
        metadata = xPlayer.getMeta(),
    })
end)

ESX.RegisterServerCallback("esx:getPlayerNames", function(source, cb, players)
    players[source] = nil

    for playerId, _ in pairs(players) do
        local xPlayer = ESX.GetPlayerFromId(playerId)

        if xPlayer then
            players[playerId] = xPlayer.getName()
        else
            players[playerId] = nil
        end
    end

    cb(players)
end)

ESX.RegisterServerCallback("esx:spawnVehicle", function(source, cb, vehData)
    local ped = GetPlayerPed(source)
    ESX.OneSync.SpawnVehicle(vehData.model or `ADDER`, vehData.coords or GetEntityCoords(ped), vehData.coords.w or 0.0, vehData.props or {}, function(id)
        if vehData.warp then
            local vehicle = NetworkGetEntityFromNetworkId(id)
            local timeout = 0
            while GetVehiclePedIsIn(ped, false) ~= vehicle and timeout <= 15 do
                Wait(0)
                TaskWarpPedIntoVehicle(ped, vehicle, -1)
                timeout += 1
            end
        end
        cb(id)
    end)
end)

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        CreateThread(function()
            Wait(50000)
            Core.SavePlayers()
        end)
    end
end)

AddEventHandler("txAdmin:events:serverShuttingDown", function()
    Core.SavePlayers()
end)

local DoNotUse = {
    ["essentialmode"] = true,
    ["es_admin2"] = true,
    ["basic-gamemode"] = true,
    ["mapmanager"] = true,
    ["fivem-map-skater"] = true,
    ["fivem-map-hipster"] = true,
    ["qb-core"] = true,
    ["default_spawnpoint"] = true,
}

AddEventHandler("onResourceStart", function(key)
    if DoNotUse[string.lower(key)] then
        while GetResourceState(key) ~= "started" do
            Wait(0)
        end

        StopResource(key)
        error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(key))
    end

    if not SetEntityOrphanMode then
        CreateThread(function()
            while true do
                error("ESX Requires a minimum Artifact version of 10188, Please update your server.")
                Wait(60 * 1000)
            end
        end)
    end
end)

for key in pairs(DoNotUse) do
    if GetResourceState(key) == "started" or GetResourceState(key) == "starting" then
        StopResource(key)
        error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(key))
    end
end

RegisterServerEvent('es_extended:useDecorUpdate')
AddEventHandler('es_extended:useDecorUpdate', function(action, networkId, key, value)
    if action ~= 'DEL' and action ~= 'BOOL' and action ~= 'INT' and action ~= 'FLOAT' then
        return
    end

    local id = tonumber(networkId)
    if not id then
        print(('[DecorUpdate] Invalid network ID: %s'):format(tostring(networkId)))
        return
    end

    TriggerClientEvent('es_extended:useDecorUpdate', -1, action, id, key, value)
end)