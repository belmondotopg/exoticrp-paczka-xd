local Jobs = setmetatable({}, {__index = function(_, key)
	return ESX.GetJobs()[key]
end
})

local QFSOCIETY_SERVER = {}

CreateThread(function()
    local columnExists = MySQL.single.await([[
        SELECT COUNT(*) as count 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'users' 
        AND COLUMN_NAME = 'rankLegalCourses'
    ]])
    
    if not columnExists or columnExists.count == 0 then
        MySQL.query.await([[
            ALTER TABLE `users` 
            ADD COLUMN `rankLegalCourses` INT NOT NULL DEFAULT 0;
        ]])
    end
end)

local badgeCache = {}
local nameCache = {}
local CACHE_TTL = 300 -- 5 minut

local function GetBadge(identifier)
    if not identifier or type(identifier) ~= "string" then return "#" end
    
    if badgeCache[identifier] and os.time() < badgeCache[identifier].expires then
        return badgeCache[identifier].value
    end
    
    local success, result = pcall(function()
        return MySQL.single.await('SELECT badge FROM users WHERE identifier = ?', {identifier})
    end)
    
    if not success then
        print('[ERROR] GetBadge MySQL query failed:', result)
        return "#"
    end
    
    local badge = (result and result.badge) or "#"
    
    badgeCache[identifier] = {
        value = badge,
        expires = os.time() + CACHE_TTL
    }
    
    return badge
end

local function AddHistory(src, job, date, fpName, fpDiscord, action, secondaction, spName, spDiscord)
    local esx_core = exports.esx_core

    if secondaction then
        MySQL.update(
            'INSERT INTO esx_society_history (job, date, firstplayer_name, firstplayer_discordid, action, secondaction, secondplayer_name, secondplayer_discordid) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            { job, date, fpName, fpDiscord, action, secondaction, spName, spDiscord }
        )

        local logMessage = string.format(
            "Nowe zdarzenie w bossmenu\n\n" ..
            "Data: %s\n\n" ..
            "Osoba wykonująca akcję:\n" ..
            "Imię i nazwisko: %s\n" ..
            "Discord ID: %s\n\n" ..
            "Akcja: %s\n" ..
            "Opis akcji: %s\n\n" ..
            "Osoba, której dotyczy zmiana:\n" ..
            "Imię i nazwisko: %s\n" ..
            "Discord ID: %s",
            date, fpName, fpDiscord, action, secondaction, spName, spDiscord
        )

        esx_core:SendLog(src, "Bossmenu", logMessage, 'bossmenu', '3066993')
    else
        MySQL.update(
            'INSERT INTO esx_society_history (job, date, firstplayer_name, firstplayer_discordid, action) VALUES (?, ?, ?, ?, ?)',
            { job, date, fpName, fpDiscord, action }
        )

        local logMessage = string.format(
            "Nowe zdarzenie w bossmenu\n\n" ..
            "Data: %s\n\n" ..
            "Osoba wykonująca akcję:\n" ..
            "Imię i nazwisko: %s\n" ..
            "Discord ID: %s\n\n" ..
            "Akcja: %s",
            date, fpName, fpDiscord, action
        )

        esx_core:SendLog(src, "Bossmenu", logMessage, 'bossmenu', '3066993')
    end
end

exports('AddHistory', AddHistory)

local function UpdatePlayerKursy(identifier, jobName, newKursy)
    if not QFSOCIETY_SERVER[jobName] or not QFSOCIETY_SERVER[jobName].playersData then
        return
    end
    
    for k, v in pairs(QFSOCIETY_SERVER[jobName].playersData) do
        if v.playerIdentifier == identifier then
            v.playerKursy = newKursy
            if QFSOCIETY_SERVER[jobName].userJobData and QFSOCIETY_SERVER[jobName].userJobData.jobData then
                local totalKursy = 0
                for _, playerData in pairs(QFSOCIETY_SERVER[jobName].playersData) do
                    totalKursy = totalKursy + (playerData.playerKursy or 0)
                end
                QFSOCIETY_SERVER[jobName].userJobData.jobData.jobDataKursy = totalKursy
            end
            
            for playerId, _ in pairs(ESX.GetPlayers()) do
                local xPlayerMenu = ESX.GetPlayerFromId(playerId)
                if xPlayerMenu and xPlayerMenu.job and xPlayerMenu.job.name == jobName and xPlayerMenu.job.grade >= Config.AuthorizedGrade[jobName] then
                    TriggerClientEvent('esx_society:setPlayersData', playerId, QFSOCIETY_SERVER[jobName].playersData)
                    if QFSOCIETY_SERVER[jobName].userJobData then
                        TriggerClientEvent('esx_society:setJobData', playerId, QFSOCIETY_SERVER[jobName].userJobData)
                    end
                end
            end
            break
        end
    end
end

exports('UpdatePlayerKursy', UpdatePlayerKursy)

local function AddTuneHistory(job, date, fpName, fpDiscord, action, secondaction, identifier)
    MySQL.update('INSERT INTO esx_society_tunehistory (job, date, firstplayer_name, firstplayer_discordid, action, secondaction, identifier) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        job, date, fpName, fpDiscord, action, secondaction, identifier
    })
end

exports('AddTuneHistory', AddTuneHistory)

local function getTargetName(identifier)
    if not identifier or type(identifier) ~= "string" then return "Nieznany" end
    
    if nameCache[identifier] and os.time() < nameCache[identifier].expires then
        return nameCache[identifier].value
    end
    
    local success, getName = pcall(function()
        return MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
    end)
    
    if not success then
        print('[ERROR] getTargetName MySQL query failed:', getName)
        return "Nieznany"
    end
    
    if not getName or not getName.firstname or not getName.lastname then
        return "Nieznany"
    end
    
    local fullName = getName.firstname .. ' ' .. getName.lastname
    
    nameCache[identifier] = {
        value = fullName,
        expires = os.time() + CACHE_TTL
    }
    
    return fullName
end

local function ClearPlayerCache(identifier)
    if identifier and type(identifier) == "string" then
        badgeCache[identifier] = nil
        nameCache[identifier] = nil
    end
end

local function SplitId(str)
    if not str or type(str) ~= "string" then return "Brak" end
    local output
    for s in str:gmatch("([^:]+)") do
        output = s
    end
    return output or "Brak"
end

local function ValidateIdentifier(identifier)
    if not identifier or type(identifier) ~= "string" then return false end
    if not identifier:match("^[%w:]+$") then return false end
    if identifier:len() > 100 then return false end
    return true
end

local function ValidateGrade(grade)
    local numGrade = tonumber(grade)
    if not numGrade then return false end
    if numGrade < 0 or numGrade > 100 then return false end
    return true
end

local function ValidateMoney(amount)
    local numAmount = tonumber(amount)
    if not numAmount then return false end
    if numAmount <= 0 or numAmount > Config.Limits.MaxMoneyTransfer then return false end
    return true
end

local function ValidateBadge(badge)
    if not badge or type(badge) ~= "string" then return false end
    if badge:len() > Config.Limits.MaxBadgeLength then return false end
    return true
end

local function ValidateWebhookURL(url)
    if not url or type(url) ~= "string" then return false end
    if url:len() > Config.Limits.MaxWebhookURLLength then return false end
    return url:match("^https?://") ~= nil
end

local function ValidateUpgradeColumn(columnName)
    if not columnName or type(columnName) ~= "string" then return false end
    return Config.AllowedUpgradeColumns[columnName] == true
end

local function GetSafeColumnName(columnName)
    if not ValidateUpgradeColumn(columnName) then
        return nil
    end
    return columnName
end

local function CheckAuthorization(xPlayer, jobName)
    if not xPlayer then return false end
    if not jobName then jobName = xPlayer.job.name end
    if not Config.AuthorizedGrade[jobName] then return false end
    return xPlayer.job.grade >= Config.AuthorizedGrade[jobName]
end

local function ResetPlayerHours(identifier, jobName, xTarget)
    if not identifier or not jobName then return false end
    
    local success = false
    
    if jobName == 'police' or jobName == 'sheriff' then
        local querySuccess = pcall(function()
            MySQL.update('UPDATE qf_mdt_time SET time = ? WHERE identifier = ?', {0, identifier})
        end)
        if querySuccess and xTarget then
            Player(xTarget.source).state:set('RankTimePolice', 0, true)
            TriggerClientEvent('qf_mdt:resetHoursPlayer', xTarget.source)
        end
        success = true
    elseif jobName == 'ambulance' then
        local querySuccess = pcall(function()
            MySQL.update('UPDATE qf_mdt_ems_time SET time = ? WHERE identifier = ?', {0, identifier})
        end)
        if querySuccess and xTarget then
            Player(xTarget.source).state:set('RankTimeAmbulance', 0, true)
            TriggerClientEvent('qf_mdt_ems:resetHoursPlayer', xTarget.source)
        end
        success = true
    elseif jobName == 'mechanik' then
        local querySuccess = pcall(function()
            MySQL.update('UPDATE qf_mdt_lsc_time SET time = ? WHERE identifier = ?', {0, identifier})
        end)
        if querySuccess and xTarget then
            Player(xTarget.source).state:set('RankTimeMechanic', 0, true)
            TriggerClientEvent('qf_mdt_lsc:resetHoursPlayer', xTarget.source)
        end
        success = true
    elseif jobName == 'ec' then
        local querySuccess = pcall(function()
            MySQL.update('UPDATE qf_mdt_ec_time SET time = ? WHERE identifier = ?', {0, identifier})
        end)
        if querySuccess and xTarget then
            Player(xTarget.source).state:set('RankTimeMechanic', 0, true)
            TriggerClientEvent('qf_mdt_ec:resetHoursPlayer', xTarget.source)
        end
        success = true
    end
    
    return success
end

local function SafeJsonDecode(jsonString)
    if not jsonString then return {} end
    local success, result = pcall(json.decode, jsonString)
    return success and result or {}
end

local function IsLegalJob(jobName)
    if not jobName or not Config.LegalJobs then return false end
    for _, legalJob in ipairs(Config.LegalJobs) do
        if jobName == legalJob then
            return true
        end
    end
    return false
end

local function IsFractionJob(jobName)
    if not jobName or not Config.FractionJobs then return false end
    for _, fractionJob in ipairs(Config.FractionJobs) do
        if jobName == fractionJob then
            return true
        end
    end
    return false
end

local function ExtractIdentifiers(src)
	local identifiers = {}

    if src then
		identifiers = {
	        id = src,
			name = GetPlayerName(src),
			steamhex = "Brak",
			steamid = "Brak",
			discord = "Brak",
			license = "Brak",
			license2 = "Brak",
			xbl = "Brak",
			live = "Brak",
			fivem = "Brak",
			hwid = {}
		}
	else
		identifiers = {
			id = "Brak",
			name = "Brak",
			steamhex = "Brak",
			steamid = "Brak",
			discord = "Brak",
			license = "Brak",
			license2 = "Brak",
			xbl = "Brak",
			live = "Brak",
			fivem = "Brak",
			hwid = {}
		}
	end

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id:find("steam") then
            identifiers.steamhex = SplitId(id)
        elseif id:find("discord") then
            identifiers.discord = SplitId(id)
        elseif id:find("license2") then
            identifiers.license2 = SplitId(id)
        elseif id:find("license") then
            identifiers.license = SplitId(id)
        elseif id:find("xbl") then
            identifiers.xbl = SplitId(id)
        elseif id:find("live") then
            identifiers.live = SplitId(id)
        elseif id:find("fivem") then
            identifiers.fivem = SplitId(id)
        end
    end

    for i = 0, GetNumPlayerTokens(src) - 1 do
        table.insert(identifiers.hwid, GetPlayerToken(src, i))
    end

    return identifiers
end

RegisterServerEvent('esx_society:upgradesLegal', function(xPlayer)
    if not xPlayer then return end
    
    if not CheckAuthorization(xPlayer) then return end
    
    local data = {}
    local upgrades_data = Config.UpgradesLegal
    
    for k, v in pairs(upgrades_data) do
        local safeColumnName = GetSafeColumnName(v.upgrade_source)
        if not safeColumnName then
            print('[WARNING] Invalid upgrade_source:', v.upgrade_source)
            goto continue
        end
        
        local success, mysql_data = pcall(function()
            return MySQL.single.await('SELECT `'..safeColumnName..'` FROM esx_society WHERE name = ?', {xPlayer.job.name})
        end)
        
        if not success then
            print('[ERROR] upgradesLegal MySQL query failed:', mysql_data)
            goto continue
        end
        
        local buyed = mysql_data and mysql_data[safeColumnName] == 1
        table.insert(data, {
            upgrade_name = v.upgrade_name,
            upgrade_source = v.upgrade_source,
            upgrade_price = v.upgrade_price,
            upgrade_buyed = buyed
        })
        
        ::continue::
    end

    TriggerClientEvent('esx_society:updateUpgradesLegal', xPlayer.source, data)
end)

local lastGameTimerId = {}

local function CheckRateLimit(src, eventName, maxCalls, timeWindow)
    local key = src .. ":" .. eventName
    local now = os.time()
    if not lastGameTimerId[key] then
        lastGameTimerId[key] = {count = 0, resetTime = now + timeWindow}
    end
    if now > lastGameTimerId[key].resetTime then
        lastGameTimerId[key] = {count = 0, resetTime = now + timeWindow}
    end
    lastGameTimerId[key].count = lastGameTimerId[key].count + 1
    return lastGameTimerId[key].count <= maxCalls
end

CreateThread(function()
    while true do
        Wait(600000)
        local now = os.time()
        for key, data in pairs(lastGameTimerId) do
            if now > (data.resetTime + 3600) then
                lastGameTimerId[key] = nil
            end
        end
    end
end)


RegisterServerEvent('esx_society:openbosshub', function(btype, permid, fullAccess, job_type)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not Config.AuthorizedGrade[xPlayer.job.name] then return end
    if xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then return end

    local playerJobName = xPlayer.job.name
    local playerJobLabel = xPlayer.job.label

    QFSOCIETY_SERVER[playerJobName] = {
        playerData = {
            identifier = xPlayer.identifier,
            id = xPlayer.source,
            permid = Player(src).state.ssn,
            name = xPlayer.getName(),
            firstname = xPlayer.get('firstName'),
            lastname = xPlayer.get('lastName'),
            job = xPlayer.job.name,
            job_grade = xPlayer.job.grade,
            discordid = xPlayer.discordid,
            money = xPlayer.getMoney(),
        },
        playersData = {},
        jobData = {},
        historyData = {},
        tunehistoryData = {},
    }

    local jobPlayers

    if btype == 'legal' then
        TriggerEvent('esx_society:upgradesLegal', xPlayer)
    end

    if btype == 'fraction' then
        local jobTypes = {xPlayer.job.name}
        local placeholders = {}
        local params = {}

        for _, jobType in ipairs(jobTypes) do
            table.insert(placeholders, "(JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = ? OR JSON_CONTAINS_PATH(multi_jobs, 'one', CONCAT('$.\"', ?, '\"')) = 1)")
            table.insert(params, jobType)
            table.insert(params, jobType)
        end

        local query = "SELECT identifier, job, multi_jobs, firstname, lastname, discordid, playerName FROM users WHERE " .. table.concat(placeholders, " OR ")

        jobPlayers = MySQL.query.await(query, params)
    else
        jobPlayers = MySQL.query.await([[
            SELECT *
            FROM users
            WHERE (job IS NOT NULL AND JSON_VALID(job) = 1 AND JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = ?)
               OR (multi_jobs IS NOT NULL AND JSON_VALID(multi_jobs) = 1 AND JSON_CONTAINS_PATH(multi_jobs, 'one', CONCAT('$.\"', ?, '\"')) = 1)
            ORDER BY CASE WHEN job IS NOT NULL AND JSON_VALID(job) = 1 THEN JSON_UNQUOTE(JSON_EXTRACT(job, '$.grade')) ELSE 0 END DESC
        ]], {playerJobName, playerJobName})
    end

    local historyData = MySQL.query.await('SELECT * FROM esx_society_history WHERE job = ?', {playerJobName})
    
    local tunehistoryData
    if playerJobName == 'mechanik' then
        tunehistoryData = MySQL.query.await('SELECT * FROM esx_society_tunehistory WHERE job = ? OR job = ?', {'mechanik'})
    elseif playerJobName == 'ec' then
        tunehistoryData = MySQL.query.await('SELECT * FROM esx_society_tunehistory WHERE job = ?', {'ec'})
    else
        tunehistoryData = MySQL.query.await('SELECT * FROM esx_society_tunehistory WHERE job = ?', {playerJobName})
    end
    
    local jobMoney = MySQL.single.await('SELECT money FROM addon_account_data WHERE account_name = ?', {playerJobName})

    QFSOCIETY_SERVER[playerJobName].historyData = historyData or {}
    QFSOCIETY_SERVER[playerJobName].tunehistoryData = tunehistoryData or {}

    local wyrokCount = MySQL.single.await('SELECT COUNT(*) as ilosc FROM qf_mdt_jails') or {ilosc = 0}
    local mandatCount = MySQL.single.await('SELECT COUNT(*) as ilosc FROM qf_mdt_fines') or {ilosc = 0}
    local fakturaEMSCount = MySQL.single.await('SELECT COUNT(*) as ilosc FROM qf_mdt_lsc_invoices') or {ilosc = 0}
    local fakturaLSCCount = MySQL.single.await('SELECT COUNT(*) as ilosc FROM qf_mdt_lsc_invoices') or {ilosc = 0}
    
    local totalKursy = 0
    if IsLegalJob(playerJobName) then
        local kursyResult = MySQL.single.await('SELECT SUM(rankLegalCourses) as total FROM users WHERE (job IS NOT NULL AND JSON_VALID(job) = 1 AND JSON_UNQUOTE(JSON_EXTRACT(job, \'$.name\')) = ?) OR (multi_jobs IS NOT NULL AND JSON_VALID(multi_jobs) = 1 AND JSON_CONTAINS_PATH(multi_jobs, \'one\', CONCAT(\'$."\', ?, \'"\')) = 1)', {playerJobName, playerJobName})
        totalKursy = (kursyResult and kursyResult.total) or 0
    end

    QFSOCIETY_SERVER[playerJobName].userJobData = {
        jobName = playerJobName,
        jobLabel = playerJobLabel,
        jobImage = 'https://i.ibb.co/kVsZnt71/logo.png',
        jobMoney = (jobMoney and jobMoney.money) or 0,
        jobPlayers = #jobPlayers,
        jobData = {
            jobDataOnline = 0,
            jobDataLevel = 0,
            jobDataLevelPoints = 0,
            jobDataNextLevelPoints = 100,
            jobDataStrefy = 0,
            jobDataNapady = 0,
            jobDataKursy = totalKursy,
            jobDataFaktury = playerJobName == "ambulance" and fakturaEMSCount.ilosc or (playerJobName == "mechanik" or playerJobName == "ec") and fakturaLSCCount.ilosc or 0,
            jobDataMandaty = mandatCount.ilosc or 0,
            jobDataWyroki = wyrokCount.ilosc or 0,
            jobDataBonusZarobki = 0,
            jobDataBonusDropy = 0,
        }
    }

    local identifiersList = {}
    local playerJobsData = {}
    local validPlayers = {}
    
    for k, v in pairs(jobPlayers) do
        local pJobs = SafeJsonDecode(v.job)
        local pMultiJobs = SafeJsonDecode(v.multi_jobs)
        local targetJob, targetJobGrade, targetJobGradeLabel

        if pJobs and pJobs.name ~= playerJobName and not pMultiJobs[playerJobName] then goto skipPlayer end
        if pJobs and pJobs.name == playerJobName then
            targetJob = pJobs.name
            targetJobGrade = pJobs.grade
            targetJobGradeLabel = pJobs.grade_label
        elseif pMultiJobs and pMultiJobs[playerJobName] then
            targetJob = playerJobName
            targetJobGrade = pMultiJobs[playerJobName].grade
            targetJobGradeLabel = pMultiJobs[playerJobName].gradeLabel
        else
            goto skipPlayer
        end
        
        table.insert(identifiersList, v.identifier)
        playerJobsData[v.identifier] = {
            data = v,
            targetJob = targetJob,
            targetJobGrade = targetJobGrade,
            targetJobGradeLabel = targetJobGradeLabel
        }
        table.insert(validPlayers, v.identifier)
        
        ::skipPlayer::
    end
    
    local hoursData = {}
    local tunesData = {}
    local tunesMoneyData = {}
    local kursyData = {}
    local bansData = {}
    local paycheckData = {}
    
    if #identifiersList > 0 then
        local placeholders = table.concat(identifiersList, "','")
        
        if IsFractionJob(playerJobName) then
            if playerJobName == 'police' or playerJobName == 'sheriff' then
                local hours = MySQL.query.await('SELECT identifier, time FROM qf_mdt_time WHERE identifier IN (?)', {identifiersList})
                if hours then
                    for _, row in ipairs(hours) do
                        hoursData[row.identifier] = row.time or 0
                    end
                end
            elseif playerJobName == 'ambulance' then
                local hours = MySQL.query.await('SELECT identifier, time FROM qf_mdt_ems_time WHERE identifier IN (?)', {identifiersList})
                if hours then
                    for _, row in ipairs(hours) do
                        hoursData[row.identifier] = row.time or 0
                    end
                end
            elseif playerJobName == 'mechanik' or playerJobName == 'ec' then
                local hours = MySQL.query.await('SELECT identifier, time FROM qf_mdt_lsc_time WHERE identifier IN (?)', {identifiersList})
                if hours then
                    for _, row in ipairs(hours) do
                        hoursData[row.identifier] = row.time or 0
                    end
                end
                local tunes = MySQL.query.await('SELECT identifier, COUNT(*) AS ilosc FROM esx_society_tunehistory WHERE identifier IN (?) GROUP BY identifier', {identifiersList})
                if tunes then
                    for _, row in ipairs(tunes) do
                        tunesData[row.identifier] = row.ilosc or 0
                    end
                end
                local tunesMoney = MySQL.query.await('SELECT identifier, SUM(secondaction) as ilosc FROM esx_society_tunehistory WHERE identifier IN (?) GROUP BY identifier', {identifiersList})
                if tunesMoney then
                    for _, row in ipairs(tunesMoney) do
                        tunesMoneyData[row.identifier] = row.ilosc or 0
                    end
                end
            end
        end
        
        if IsLegalJob(playerJobName) then
            local kursy = MySQL.query.await('SELECT identifier, rankLegalCourses FROM users WHERE identifier IN (?)', {identifiersList})
            if kursy then
                for _, row in ipairs(kursy) do
                    kursyData[row.identifier] = row.rankLegalCourses or 0
                end
            end
        end
        
        local licenseList = {}
        for _, identifier in ipairs(identifiersList) do
            table.insert(licenseList, string.sub(identifier, 7))
        end
        local bans = MySQL.query.await('SELECT license, id FROM bans WHERE license IN (?)', {licenseList})
        if bans then
            for _, row in ipairs(bans) do
                bansData['license:'..row.license] = row.id
            end
        end
        
        local jobGradeCombos = {}
        for identifier, data in pairs(playerJobsData) do
            local key = data.targetJob .. ':' .. data.targetJobGrade
            if not jobGradeCombos[key] then
                jobGradeCombos[key] = true
            end
        end
        for key, _ in pairs(jobGradeCombos) do
            local jobName, grade = key:match("^(.+):(.+)$")
            if jobName and grade then
                local perhour = MySQL.single.await('SELECT perhour FROM job_grades WHERE job_name = ? AND grade = ?', {jobName, tonumber(grade)})
                if perhour then
                    paycheckData[key] = perhour.perhour or 0
                end
            end
        end
    end
    
    for _, identifier in ipairs(validPlayers) do
        local v = playerJobsData[identifier].data
        local targetJob = playerJobsData[identifier].targetJob
        local targetJobGrade = playerJobsData[identifier].targetJobGrade
        local targetJobGradeLabel = playerJobsData[identifier].targetJobGradeLabel
        
        local xTarget = ESX.GetPlayerFromIdentifier(identifier)
        
        local targetHours = 0
        if hoursData[identifier] then
            targetHours = math.floor(hoursData[identifier] / 60)
        end
        
        local targetPaycheck = 0
        local paycheckKey = targetJob .. ':' .. targetJobGrade
        if paycheckData[paycheckKey] then
            targetPaycheck = targetHours * paycheckData[paycheckKey]
        end
        
        local targetKursy = kursyData[identifier] or 0
        local targetTunes = tunesData[identifier] or 0
        local targetTunesMoney = tunesMoneyData[identifier] or 0
        
        local sqlTargetData = nil
        local banId = bansData['license:'..string.sub(identifier, 7)]
        if banId then
            sqlTargetData = {id = banId}
        end

        local targetData = {
            playerIdentifier = identifier,
            playerActive = false,
            playerJob = targetJob,
            playerJobGrade = targetJobGrade,
            playerJobGradeLabel = targetJobGradeLabel,
            playerName = v.playerName,
            playerFirstName = v.firstname,
            playerLastName = v.lastname,
            playerID = 0,
            playerPermID = sqlTargetData and sqlTargetData.id or 'Nieznane',
            playerDiscordID = v.discordid,
            playerHours = targetHours,
            playerTunes = targetTunes,
            playerTunesMoney = targetTunesMoney,
            playerKursy = targetKursy,
            playerBadge = GetBadge(identifier),
            playerPaycheck = targetPaycheck,
            playerLicenses = {}
        }

        if Config.JobLicenses[playerJobName] then
            for job_index, job_value in pairs(Config.JobLicenses[playerJobName]) do
                targetData.playerLicenses[job_value] = false
            end
        end
        
        table.insert(QFSOCIETY_SERVER[playerJobName].playersData, targetData)

        if xTarget then
            targetData['playerID'] = xTarget.source
            targetData['playerActive'] = true
            QFSOCIETY_SERVER[playerJobName].userJobData.jobData.jobDataOnline = QFSOCIETY_SERVER[playerJobName].userJobData.jobData.jobDataOnline + 1
        end
    end
    
    if Config.JobLicenses[playerJobName] and #validPlayers > 0 then
        local allLicenses = MySQL.query.await('SELECT owner, type FROM user_licenses WHERE owner IN (?)', {validPlayers})
        if allLicenses then
            local licensesByOwner = {}
            for _, license in ipairs(allLicenses) do
                if not licensesByOwner[license.owner] then
                    licensesByOwner[license.owner] = {}
                end
                licensesByOwner[license.owner][string.upper(license.type or '')] = true
            end
            
            for _, playerData in ipairs(QFSOCIETY_SERVER[playerJobName].playersData) do
                if licensesByOwner[playerData.playerIdentifier] then
                    for job_index, job_value in pairs(Config.JobLicenses[playerJobName]) do
                        if licensesByOwner[playerData.playerIdentifier][string.upper(job_value)] then
                            playerData.playerLicenses[job_value] = true
                        end
                    end
                end
            end
        end
    end

    if btype ~= 'fraction' or playerJobName == 'ambulance' then
        table.sort(QFSOCIETY_SERVER[playerJobName].playersData, function(a, b)
            return a.playerJobGrade > b.playerJobGrade
        end)
    end

    local currentJobName = xPlayer.job.name
    if currentJobName ~= playerJobName then
        print(string.format('[esx_society] Security check failed: Player %s changed job from %s to %s during menu load', xPlayer.identifier, playerJobName, currentJobName))
        return
    end
    
    if not Config.AuthorizedGrade[currentJobName] or xPlayer.job.grade < Config.AuthorizedGrade[currentJobName] then
        print(string.format('[esx_society] Security check failed: Player %s no longer has required grade for job %s', xPlayer.identifier, currentJobName))
        return
    end
    
    local check = (playerJobName == 'ambulance')
    if fullAccess == nil then fullAccess = true end
    TriggerClientEvent('esx_society:fullyOpenBoss', xPlayer.source, QFSOCIETY_SERVER[playerJobName], check, btype, permid, fullAccess, job_type)
end)

ESX.RegisterServerCallback('esx_society:getJob', function(source, cb, society)
	if not Jobs[society] then
		return cb(false)
	end

	local job = {}
	for k, v in pairs(Jobs[society]) do
		job[k] = v
	end
	local grades = {}

	for k,v in pairs(job.grades) do
		table.insert(grades, v)
	end

	table.sort(grades, function(a, b)
		return a.grade < b.grade
	end)

	job.grades = grades

	cb(job)
end)

ESX.RegisterServerCallback('esx_society:getPromotion', function(source, cb, data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local jobName = xPlayer.job.name

    local jobs = {}

    local getJobs = MySQL.query.await('SELECT label, grade FROM job_grades WHERE job_name = ? ORDER BY grade DESC', {jobName})

    local getTarget = MySQL.single.await('SELECT job, multi_jobs FROM users WHERE identifier = ?', {data.identifier})
    if not getTarget then
        cb({})
        return
    end

    local decodedJob = SafeJsonDecode(getTarget.job)
    local decodedMultiJobs = SafeJsonDecode(getTarget.multi_jobs)

    local targetGrade = nil

    if decodedJob and decodedJob.name == jobName then
        targetGrade = decodedJob.grade
    elseif decodedMultiJobs and decodedMultiJobs[jobName] then
        targetGrade = decodedMultiJobs[jobName].grade
    end

    if not targetGrade then
        cb({})
        return
    end

    for k, v in ipairs(getJobs) do
        local sameJob = v.grade == targetGrade

        table.insert(jobs, {
            jobLabel = v.label,
            jobGrade = v.grade,
            sameJob = sameJob,
            higherJob = false,
        })
    end

    cb(jobs)
end)

ESX.RegisterServerCallback('esx_society:getPlayerInfo', function(source, cb, data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        cb({})
        return
    end
    local playersInfo = {}
    local playerPed = GetPlayerPed(src)
    if not playerPed or playerPed == 0 then
        cb({})
        return
    end
    local playerCoords = GetEntityCoords(playerPed)
    local count = 0
    
    local xPlayersList = ESX.GetExtendedPlayers()
    
    for _, xPlayers in pairs(xPlayersList) do
        if xPlayer.identifier ~= xPlayers.identifier then
            local targetPed = GetPlayerPed(xPlayers.source)
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                
                local targetJobName = xPlayers.job.name
                local targetMultiJobs = xPlayers.get('multi_jobs') or {}
                local hasJobInMultiJob = targetMultiJobs[xPlayer.job.name] ~= nil
                local hasSameMainJob = targetJobName == xPlayer.job.name
                local canHire = not hasSameMainJob and not hasJobInMultiJob
                
                if distance < 10.0 then
                    if canHire then
                        local playerState = Player(xPlayers.source).state
                        local permid = playerState and playerState.ssn or 0
                        local firstName = xPlayers.get('firstName') or ''
                        local lastName = xPlayers.get('lastName') or ''
                        local discordId = xPlayers.discord or ''
                        
                        count = count + 1
                        playersInfo[count] = {
                            id = xPlayers.source,
                            identifier = xPlayers.identifier,
                            permid = permid,
                            firstname = firstName,
                            lastname = lastName,
                            discordid = discordId
                        }
                    end
                end
            end
        end
    end
    
    cb(playersInfo)
end)

RegisterNetEvent('esx_society:hirePlayer', function(targetIdentifier, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if xPlayer then
    end
    local xTarget = ESX.GetPlayerFromIdentifier(targetIdentifier)
    local jobName = xPlayer.job.name
    local jobLabel = ESX.GetJobLabelFromName(jobName)
    local targetIdentifiers = xTarget and ExtractIdentifiers(xTarget.source) or {}
    local playerDiscord = ExtractIdentifiers(src)

    if xPlayer.job.grade < Config.AuthorizedGrade[jobName] then return end
    if xTarget and xPlayer.identifier == xTarget.identifier then return end

    local exoticBusinesses = GetResourceState('exotic_businesses')
    if exoticBusinesses == 'started' then
        local success, currentCount = pcall(function()
            return exports.exotic_businesses:GetCurrentEmployeeCount(jobName)
        end)
        local success2, maxLimit = pcall(function()
            return exports.exotic_businesses:GetEmployeeLimit(jobName)
        end)
        
        if success and success2 and currentCount ~= nil and maxLimit ~= nil then
            if currentCount >= maxLimit then
                xPlayer.showNotification(("Osiągnięto maksymalny limit pracowników (%d/%d). Ulepsz firmę aby zwiększyć limit."):format(currentCount, maxLimit))
                return
            end
        end
    end

    if xTarget then
        
        local multiJobs = xTarget.get('multi_jobs') or {}

        if multiJobs[jobName] then
            xPlayer.showNotification('Gracz już posiada tę pracę w multijob!')
            return
        end

        local grade = 0
        multiJobs[jobName] = {
            grade = grade,
            label = jobLabel,
            gradeLabel = ESX.GetGradeLabel(jobName, grade)
        }

        xTarget.setJob(jobName, grade)
        xTarget.set('multi_jobs', multiJobs)
        exports['esx_multijob']:SaveJobData(xTarget.identifier, multiJobs)
        TriggerClientEvent('esx_multijob/updateJobs', xTarget.source, multiJobs)

        local targetKursy = 0
        if IsLegalJob(jobName) then
            local kursySQL = MySQL.single.await('SELECT rankLegalCourses FROM users WHERE identifier = ?', {targetIdentifier})
            targetKursy = kursySQL and kursySQL.rankLegalCourses or 0
        end

        table.insert(QFSOCIETY_SERVER[jobName].playersData, {
            playerIdentifier = targetIdentifier,
            playerJob = jobName,
            playerJobGrade = grade,
            playerJobGradeLabel = ESX.GetGradeLabel(jobName, grade),
            playerName = GetPlayerName(xTarget.source),
            playerFirstName = xTarget.get('firstName'),
            playerLastName = xTarget.get('lastName'),
            playerID = xTarget.source,
            playerPermID = Player(xTarget.source).state.ssn,
            playerDiscordID = xTarget.discord,
            playerHours = 0,
            playerTunes = 0,
            playerTunesMoney = 0,
            playerKursy = targetKursy,
            playerBadge = GetBadge(xTarget.identifier),
            playerPaycheck = 0,
            playerLicenses = {},
        })

        AddHistory(src, jobName, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zatrudnił osobę', xTarget.identifier, xTarget.getName(), targetIdentifiers.discord)
        xPlayer.showNotification('Zatrudniono gracza '..jobLabel)
        xTarget.showNotification('Otrzymałeś pracę '..jobLabel)
    end

    CreateThread(function()
        Wait(Config.Delays.GeneralWait * 2)
        TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[jobName].playersData)
    end)
    TriggerClientEvent('esx_society:openZatrudnienie', src)

end)

RegisterNetEvent('esx_society:targetChangeGrade', function(identifier, grade, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    if not ValidateIdentifier(identifier) then
        xPlayer.showNotification('Nieprawidłowy identyfikator gracza')
        return
    end
    
    if not ValidateGrade(grade) then
        xPlayer.showNotification('Nieprawidłowa ranga')
        return
    end
    
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    local playerJob = xPlayer.job.name

    if not Config.AuthorizedGrade[playerJob] or xPlayer.job.grade < Config.AuthorizedGrade[playerJob] then return end
    if identifier == xPlayer.identifier then
        xPlayer.showNotification('Nie możesz zmienić rangi samemu sobie!')
        return
    end
    if not QFSOCIETY_SERVER[playerJob] then return end

    local newGrade = tonumber(grade)
    if newGrade > xPlayer.job.grade then
        xPlayer.showNotification('Nie możesz nadać rangi wyższej niż twoja!')
        return
    end

    if xTarget then
        local multiJobs = xTarget.get('multi_jobs') or {}
        local gradeBefore
        local targetGrade = 0

        if xTarget.job.name == playerJob then
            targetGrade = xTarget.job.grade
        elseif multiJobs[playerJob] then
            targetGrade = multiJobs[playerJob].grade or 0
        end

        if targetGrade >= xPlayer.job.grade then
            xPlayer.showNotification('Nie możesz zmienić rangi osoby z równą lub wyższą rangą!')
            return
        end

        if xTarget.job.name == playerJob then
            gradeBefore = ESX.GetGradeLabel(playerJob, xTarget.job.grade)
            xTarget.setJob(playerJob, newGrade)
        end

        if multiJobs[playerJob] then
            gradeBefore = gradeBefore or multiJobs[playerJob].gradeLabel
            multiJobs[playerJob].grade = newGrade
            multiJobs[playerJob].gradeLabel = ESX.GetGradeLabel(playerJob, newGrade)
            xTarget.set('multi_jobs', multiJobs)
            exports['esx_multijob']:SaveJobData(xTarget.identifier, multiJobs)
            TriggerClientEvent('esx_multijob/updateJobs', xTarget.source, multiJobs)
        end

        if not gradeBefore then
            xPlayer.showNotification('Gracz nie ma tej pracy.')
            return
        end

        xTarget.showNotification('Otrzymałeś awans!')
        xPlayer.showNotification('Nadano awans dla '..GetPlayerName(xTarget.source))

        local playerDiscord = ExtractIdentifiers(src)
        local targetDiscord = ExtractIdentifiers(xTarget.source)
        AddHistory(src, playerJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Nadał awans', gradeBefore, xTarget.getName(), targetDiscord.discord)

        for k, v in pairs(QFSOCIETY_SERVER[playerJob].playersData) do
            if v.playerIdentifier == identifier then
                v.playerJobGrade = tonumber(grade)
                v.playerJobGradeLabel = ESX.GetGradeLabel(playerJob, tonumber(grade))
                break
            end
        end

    else
        local user = MySQL.single.await('SELECT job, job_grade, multi_jobs, firstname, lastname FROM users WHERE identifier = ?', {identifier})
        if not user then return end

        local decodedJob = SafeJsonDecode(user.job)
        local decodedMultiJobs = SafeJsonDecode(user.multi_jobs)
        local gradeBefore
        local targetGrade = 0

        if decodedJob.name == playerJob then
            targetGrade = decodedJob.grade or 0
        elseif decodedMultiJobs[playerJob] then
            targetGrade = decodedMultiJobs[playerJob].grade or 0
        end

        if targetGrade >= xPlayer.job.grade then
            xPlayer.showNotification('Nie możesz zmienić rangi osoby z równą lub wyższą rangą!')
            return
        end

        if decodedJob.name == playerJob then
            gradeBefore = ESX.GetGradeLabel(playerJob, decodedJob.grade)
            MySQL.update('UPDATE users SET job = JSON_SET(job, \'$.grade\', ?) WHERE identifier = ?', {
                newGrade,
                identifier
            })
        end

        if decodedMultiJobs[playerJob] then
            gradeBefore = gradeBefore or decodedMultiJobs[playerJob].gradeLabel
            decodedMultiJobs[playerJob].grade = newGrade
            decodedMultiJobs[playerJob].gradeLabel = ESX.GetGradeLabel(playerJob, newGrade)
            MySQL.update('UPDATE users SET multi_jobs = ? WHERE identifier = ?', {json.encode(decodedMultiJobs), identifier})
        end

        if not gradeBefore then
            xPlayer.showNotification('Gracz offline nie ma tej pracy.')
            return
        end

        xPlayer.showNotification('Nadano awans graczowi offline.')

        local playerDiscord = ExtractIdentifiers(src)
        local targetName = user.firstname.." "..user.lastname
        AddHistory(src, playerJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Nadał awans', gradeBefore, targetName, '-')
    end

    table.sort(QFSOCIETY_SERVER[playerJob].playersData, function(a, b)
        return a.playerJobGrade > b.playerJobGrade
    end)
    TriggerClientEvent('esx_society:setPlayersData', -1, QFSOCIETY_SERVER[playerJob].playersData)
end)

RegisterNetEvent('esx_society:targetChangeBadge', function (identifier, badge, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if not ValidateIdentifier(identifier) then
        xPlayer.showNotification('Nieprawidłowy identyfikator gracza')
        return
    end
    
    if not ValidateBadge(badge) then
        xPlayer.showNotification('Nieprawidłowa odznaka (max '..Config.Limits.MaxBadgeLength..' znaków)')
        return
    end
    
    local currentJob = xPlayer.job.name
    if not CheckAuthorization(xPlayer, currentJob) then return end
    
    if not QFSOCIETY_SERVER[currentJob] then return end
    
    local rateLimit = Config.RateLimits.targetChangeBadge
    if not CheckRateLimit(src, 'targetChangeBadge', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end
    
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)

    if xTarget then
        xTarget.set('badge', badge)

        local success, result = pcall(function()
            return MySQL.update("UPDATE users SET badge = ? WHERE identifier = ?", {
                tostring(badge),
                xTarget.identifier
            })
        end)
        
        if not success then
            print('[ERROR] targetChangeBadge MySQL update failed:', result)
            xPlayer.showNotification('Błąd podczas aktualizacji odznaki')
            return
        end

        xTarget.showNotification('Zmieniono odznakę na ['..badge..']!')
        xPlayer.showNotification('Nadano nowa odznake ['..badge..'] dla '..xTarget.getName())

        local playerDiscord = ExtractIdentifiers(src)
        local targetDiscord = ExtractIdentifiers(xTarget.source)
        AddHistory(
            src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord,
            'Zaaktualizował odznakę', 'Nowa odznaka '..badge, xTarget.getName(), targetDiscord.discord
        )
    else
        local success, result = pcall(function()
            return MySQL.update("UPDATE users SET badge = ? WHERE identifier = ?", {
                tostring(badge),
                identifier
            })
        end)
        
        if not success then
            print('[ERROR] targetChangeBadge MySQL update failed (offline):', result)
            xPlayer.showNotification('Błąd podczas aktualizacji odznaki')
            return
        end

        xPlayer.showNotification('Nadano nową odznakę dla gracza offline')

        local playerDiscord = ExtractIdentifiers(src)
        local targetName = getTargetName(identifier)
        AddHistory(
            src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord,
            'Zaaktualizował odznakę', 'Nowa odznaka '..badge, targetName, '-'
        )
    end

    Wait(250)

    for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
        if v.playerIdentifier == identifier then
            v.playerBadge = badge
        end
    end

    TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[currentJob].playersData)
end)


RegisterNetEvent('esx_society:fireTargetPlayer', function(identifier, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    local currentJob = xPlayer.job.name

    if identifier == xPlayer.identifier then return end

    if xTarget then
       
        local multiJobs = xTarget.get('multi_jobs') or {}

        if not multiJobs[currentJob] and xTarget.job.name ~= currentJob then return end

        local targetGrade = 0
        if xTarget.job.name == currentJob then
            targetGrade = xTarget.job.grade
        elseif multiJobs[currentJob] then
            targetGrade = multiJobs[currentJob].grade or 0
        end

        if targetGrade >= xPlayer.job.grade then
            xPlayer.showNotification('Nie możesz wyrzucić osoby z równą lub wyższą rangą!')
            return
        end

        if multiJobs[currentJob] then
            multiJobs[currentJob] = nil
            xTarget.set('multi_jobs', multiJobs)
            exports['esx_multijob']:SaveJobData(xTarget.identifier, multiJobs)
            TriggerClientEvent('esx_multijob/updateJobs', xTarget.source, multiJobs)
        end

        if xTarget.job.name == currentJob then
            xTarget.setJob('unemployed', 0)
        end

        xPlayer.showNotification('Zwolniłeś gracza ' .. GetPlayerName(xTarget.source) .. ' z pracy ' .. ESX.GetJobLabelFromName(currentJob))
        xTarget.showNotification('Zostałeś zwolniony z pracy ' .. ESX.GetJobLabelFromName(currentJob))

        local playerDiscord = ExtractIdentifiers(src)
        local targetDiscord = ExtractIdentifiers(xTarget.source)
        AddHistory(src, currentJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zwolnił gracza', '', xTarget.getName(), targetDiscord.discord)

        for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
            if v.playerIdentifier == identifier then
                table.remove(QFSOCIETY_SERVER[currentJob].playersData, k)
                break
            end
    
        end
    else
       
        local user = MySQL.single.await('SELECT multi_jobs, job, firstname, lastname FROM users WHERE identifier = ?', {identifier})
        if not user then return end

        local decodedJob = user.job and json.decode(user.job) or {}
        local multiJobs = user.multi_jobs and json.decode(user.multi_jobs) or {}
        local removed = false

        local targetGrade = 0
        if decodedJob.name == currentJob then
            targetGrade = decodedJob.grade or 0
        elseif multiJobs[currentJob] then
            targetGrade = multiJobs[currentJob].grade or 0
        end

        if targetGrade >= xPlayer.job.grade then
            xPlayer.showNotification('Nie możesz wyrzucić osoby z równą lub wyższą rangą!')
            return
        end

        if multiJobs[currentJob] then
            multiJobs[currentJob] = nil
            MySQL.update('UPDATE users SET multi_jobs = ? WHERE identifier = ?', {json.encode(multiJobs), identifier})
            removed = true
        end

        if decodedJob.name == currentJob then
            MySQL.update('UPDATE users SET job = ? WHERE identifier = ?', {json.encode({name = 'unemployed', grade = 0}), identifier})
            removed = true
        end

        if not removed then
            xPlayer.showNotification('Gracz offline nie miał tej pracy.')
            return
        end

        xPlayer.showNotification('Zwolniłeś gracza offline z pracy ' .. ESX.GetJobLabelFromName(currentJob))

        local playerDiscord = ExtractIdentifiers(src)
        local targetName = user.firstname .. " " .. user.lastname
        AddHistory(src, currentJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zwolnił gracza', '', targetName, '-')

        for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
            if v.playerIdentifier == identifier then
                table.remove(QFSOCIETY_SERVER[currentJob].playersData, k)
                break
            end
        end
   
    end

    TriggerClientEvent('esx_society:setPlayersData', -1, QFSOCIETY_SERVER[currentJob].playersData)
end)

RegisterNetEvent('esx_society:hoursReset', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then return end
    if not QFSOCIETY_SERVER[xPlayer.job.name] then return end

    if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
        MySQL.update('UPDATE qf_mdt_time SET time = ?', {0})
        TriggerClientEvent('qf_mdt/resetHoursPlayer', -1)
    elseif xPlayer.job.name == 'ambulance' then
        MySQL.update('UPDATE qf_mdt_ems_time SET time = ?', {0})
        TriggerClientEvent('qf_mdt_ems/resetHoursPlayer', -1)
    elseif xPlayer.job.name == 'mechanik' then
        MySQL.update('UPDATE qf_mdt_lsc_time SET time = ?', {0})
        TriggerClientEvent('qf_mdt_lsc/resetHoursPlayer', -1)
    elseif xPlayer.job.name == 'ec' then
        MySQL.update('UPDATE qf_mdt_ec_time SET time = ?', {0})
        TriggerClientEvent('qf_mdt_ec/resetHoursPlayer', -1)
    end

    local playerDiscord = ExtractIdentifiers(src)
    AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a godziny dla każdego')

    for k, v in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
        v.playerHours = 0
    end

    xPlayer.showNotification('Wyczyściłeś godziny każdemu funkcjonariuszowi!')
    TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[xPlayer.job.name].playersData)
end)

RegisterNetEvent('esx_society:tuneCountReset', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then return end
    if not QFSOCIETY_SERVER[xPlayer.job.name] then return end

    MySQL.update('DELETE FROM esx_society_tunehistory')

    local playerDiscord = ExtractIdentifiers(src)
    AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a ilość tuningów dla każdego')

    for k, v in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
        v.playerTunes = 0
        v.playerTunesMoney = 0
    end

    xPlayer.showNotification('Wyczyściłeś/aś tuningów dla każdego!')
    TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[xPlayer.job.name].playersData)
end)

RegisterNetEvent('esx_society:coursesReset', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then 
        print('[esx_society] coursesReset: xPlayer is nil for source ' .. src)
        return 
    end
    if not xPlayer.job or not xPlayer.job.name then 
        print('[esx_society] coursesReset: xPlayer.job is nil or job.name is nil for source ' .. src)
        return 
    end
    if not Config.AuthorizedGrade[xPlayer.job.name] then 
        print('[esx_society] coursesReset: Config.AuthorizedGrade[' .. xPlayer.job.name .. '] is nil')
        return 
    end
    if xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then 
        print('[esx_society] coursesReset: Player grade ' .. xPlayer.job.grade .. ' is less than required ' .. Config.AuthorizedGrade[xPlayer.job.name])
        return 
    end

    if not QFSOCIETY_SERVER[xPlayer.job.name] then 
        print('[esx_society] coursesReset: QFSOCIETY_SERVER[' .. xPlayer.job.name .. '] is nil')
        return 
    end
    
    if IsLegalJob(xPlayer.job.name) then
        local affectedRows = MySQL.update.await('UPDATE users SET rankLegalCourses = 0 WHERE (job IS NOT NULL AND JSON_VALID(job) = 1 AND JSON_UNQUOTE(JSON_EXTRACT(job, \'$.name\')) = ?) OR (multi_jobs IS NOT NULL AND JSON_VALID(multi_jobs) = 1 AND JSON_CONTAINS_PATH(multi_jobs, \'one\', CONCAT(\'$."\', ?, \'"\')) = 1)', {xPlayer.job.name, xPlayer.job.name})
        print('[esx_society] coursesReset: Updated ' .. (affectedRows or 0) .. ' rows in database')
    end

    for k, v in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
        if v.playerID and v.playerID > 0 then
            local xTarget = ESX.GetPlayerFromId(v.playerID)
            if xTarget then
                local kursySQL = MySQL.single.await('SELECT rankLegalCourses FROM users WHERE identifier = ?', {v.playerIdentifier})
                v.playerKursy = kursySQL and kursySQL.rankLegalCourses or 0
            else
                v.playerKursy = 0
            end
        else
            local kursySQL = MySQL.single.await('SELECT rankLegalCourses FROM users WHERE identifier = ?', {v.playerIdentifier})
            v.playerKursy = kursySQL and kursySQL.rankLegalCourses or 0
        end
    end
    if QFSOCIETY_SERVER[xPlayer.job.name].userJobData and QFSOCIETY_SERVER[xPlayer.job.name].userJobData.jobData then
        local totalKursy = 0
        for _, playerData in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
            totalKursy = totalKursy + (playerData.playerKursy or 0)
        end
        QFSOCIETY_SERVER[xPlayer.job.name].userJobData.jobData.jobDataKursy = totalKursy
    end

    local playerDiscord = ExtractIdentifiers(src)
    AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a kursy dla każdego')

    xPlayer.showNotification('Wyczyściłeś kursy każdemu pracownikowi!')
    

    for playerId, _ in pairs(ESX.GetPlayers()) do
        local xPlayerMenu = ESX.GetPlayerFromId(playerId)
        if xPlayerMenu and xPlayerMenu.job and xPlayerMenu.job.name == xPlayer.job.name and Config.AuthorizedGrade[xPlayer.job.name] and xPlayerMenu.job.grade >= Config.AuthorizedGrade[xPlayer.job.name] then
            TriggerClientEvent('esx_society:setPlayersData', playerId, QFSOCIETY_SERVER[xPlayer.job.name].playersData)
            if QFSOCIETY_SERVER[xPlayer.job.name].userJobData then
                TriggerClientEvent('esx_society:setJobData', playerId, QFSOCIETY_SERVER[xPlayer.job.name].userJobData)
            end
        end
    end
end)

RegisterNetEvent('esx_society:targetResetCourses', function(identifier, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    local currentJob = xPlayer.job.name

    if xPlayer.job.grade < Config.AuthorizedGrade[currentJob] then return end
    if not QFSOCIETY_SERVER[currentJob] then return     end

    if not IsLegalJob(currentJob) then
        xPlayer.showNotification('Ta funkcja jest dostępna tylko dla legalnych jobów!')
        return
    end

    if xTarget then
        MySQL.update('UPDATE users SET rankLegalCourses = ? WHERE identifier = ?', {0, identifier})
        
        local targetFirstName = xTarget.get('firstName') or ''
        local targetLastName = xTarget.get('lastName') or ''
        local targetFullName = targetFirstName .. ' ' .. targetLastName
        
        local playerDiscord = ExtractIdentifiers(src)
        local targetDiscord = ExtractIdentifiers(xTarget.source)
        AddHistory(src, currentJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a kursy', '', targetFullName, targetDiscord.discord)
        
        for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
            if v.playerIdentifier == identifier then
                v.playerKursy = 0
                break
            end
        end
        
        if QFSOCIETY_SERVER[currentJob].userJobData and QFSOCIETY_SERVER[currentJob].userJobData.jobData then
            local totalKursy = 0
            for _, playerData in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
                totalKursy = totalKursy + (playerData.playerKursy or 0)
            end
            QFSOCIETY_SERVER[currentJob].userJobData.jobData.jobDataKursy = totalKursy
        end
        
        xPlayer.showNotification('Zresetowałeś kursy dla ' .. targetFullName)
        TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[currentJob].playersData)
        if QFSOCIETY_SERVER[currentJob].userJobData then
            TriggerClientEvent('esx_society:setJobData', src, QFSOCIETY_SERVER[currentJob].userJobData)
        end
    else
        MySQL.update('UPDATE users SET rankLegalCourses = ? WHERE identifier = ?', {0, identifier})
        
        local user = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
        if user then
            local playerDiscord = ExtractIdentifiers(src)
            local targetName = user.firstname .. " " .. user.lastname
            AddHistory(src, currentJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a kursy', '', targetName, '-')
            
            for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
                if v.playerIdentifier == identifier then
                    v.playerKursy = 0
                    break
                end
            end
            
            if QFSOCIETY_SERVER[currentJob].userJobData and QFSOCIETY_SERVER[currentJob].userJobData.jobData then
                local totalKursy = 0
                for _, playerData in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
                    totalKursy = totalKursy + (playerData.playerKursy or 0)
                end
                QFSOCIETY_SERVER[currentJob].userJobData.jobData.jobDataKursy = totalKursy
            end
            
            xPlayer.showNotification('Zresetowałeś kursy dla ' .. targetName)
            TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[currentJob].playersData)
            if QFSOCIETY_SERVER[currentJob].userJobData then
                TriggerClientEvent('esx_society:setJobData', src, QFSOCIETY_SERVER[currentJob].userJobData)
            end
        else
            xPlayer.showNotification('Nie znaleziono gracza!')
        end
    end
end)

RegisterNetEvent('esx_society:targetResetHours', function(identifier, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if not ValidateIdentifier(identifier) then
        xPlayer.showNotification('Nieprawidłowy identyfikator gracza')
        return
    end
    
    local currentJob = xPlayer.job.name
    if not CheckAuthorization(xPlayer, currentJob) then return end
    
    if not QFSOCIETY_SERVER[currentJob] then return end
    
    local rateLimit = Config.RateLimits.targetResetHours
    if not CheckRateLimit(src, 'targetResetHours', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end

    if not IsFractionJob(currentJob) then
        xPlayer.showNotification('Ta funkcja jest dostępna tylko dla frakcji!')
        return
    end
    
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)

    if xTarget then
        ResetPlayerHours(identifier, currentJob, xTarget)
        
        local targetFirstName = xTarget.get('firstName') or ''
        local targetLastName = xTarget.get('lastName') or ''
        local targetFullName = targetFirstName .. ' ' .. targetLastName
        
        local playerDiscord = ExtractIdentifiers(src)
        local targetDiscord = ExtractIdentifiers(xTarget.source)
        AddHistory(src, currentJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a godziny', '', targetFullName, targetDiscord.discord)
        
        for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
            if v.playerIdentifier == identifier then
                v.playerHours = 0
                break
            end
        end
        
        xPlayer.showNotification('Zresetowałeś godziny dla ' .. targetFullName)
        TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[currentJob].playersData)
    else
        ResetPlayerHours(identifier, currentJob, nil)
        
        local user = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
        if user then
            local playerDiscord = ExtractIdentifiers(src)
            local targetName = user.firstname .. " " .. user.lastname
            AddHistory(src, currentJob, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a godziny', '', targetName, '-')
            
            for k, v in pairs(QFSOCIETY_SERVER[currentJob].playersData) do
                if v.playerIdentifier == identifier then
                    v.playerHours = 0
                    break
                end
            end
            
            xPlayer.showNotification('Zresetowałeś godziny dla ' .. targetName)
            TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[currentJob].playersData)
        else
            xPlayer.showNotification('Nie znaleziono gracza!')
        end
    end
end)

RegisterNetEvent('esx_society:tuneReset', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then return end

    if not QFSOCIETY_SERVER[xPlayer.job.name] then return end
    
    MySQL.update('DELETE FROM esx_society_tunehistory')

    QFSOCIETY_SERVER[xPlayer.job.name].tunehistoryData = {}

    local playerDiscord = ExtractIdentifiers(src)
    AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zresetował/a historie tuningów')

    xPlayer.showNotification('Wyczyściłeś historię tuningów!')
    TriggerClientEvent('esx_society:setTuneHistory', src, QFSOCIETY_SERVER[xPlayer.job.name].tunehistoryData)
end)

RegisterNetEvent('esx_society:depositMoney', function(money, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    money = tonumber(money)
    if not ValidateMoney(money) then
        xPlayer.showNotification('Nieprawidłowa kwota')
        return
    end

    if not CheckAuthorization(xPlayer) then return end
    
    local targetJob = xPlayer.job.name

    if not QFSOCIETY_SERVER[targetJob] then return end
    
    local rateLimit = Config.RateLimits.depositMoney
    if not CheckRateLimit(src, 'depositMoney', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end

    TriggerEvent('esx_addonaccount:getSharedAccount', targetJob, function(account)
        if not account then
            xPlayer.showNotification('Błąd: Nie znaleziono konta firmowego')
            return
        end
        
        if money > 0 and xPlayer.getMoney() >= money then
            xPlayer.removeMoney(money)
            account.addMoney(money)
            xPlayer.showNotification('Wpłaciłeś: '..ESX.Math.GroupDigits(money)..'$ na konto')

            local playerDiscord = ExtractIdentifiers(src)
            AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Wpłacił '..ESX.Math.GroupDigits(money)..'$')

            CreateThread(function()
                Wait(Config.Delays.UpdateDelay)
                if QFSOCIETY_SERVER[targetJob] and QFSOCIETY_SERVER[targetJob].userJobData then
                    QFSOCIETY_SERVER[targetJob].userJobData.jobMoney = account.money
                    QFSOCIETY_SERVER[targetJob].playerData.money = xPlayer.getMoney()
                    TriggerClientEvent('esx_society:setJobData', src, QFSOCIETY_SERVER[targetJob].userJobData)
                    TriggerClientEvent('esx_society:setPlayerData', src, QFSOCIETY_SERVER[targetJob].playerData)
                end
            end)
        else
            xPlayer.showNotification('Nie masz wystarczająco pieniędzy!')
        end
    end)
end)

RegisterNetEvent('esx_society:withdrawMoney', function(money, jobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    money = tonumber(money)
    if not ValidateMoney(money) then
        xPlayer.showNotification('Nieprawidłowa kwota')
        return
    end

    if not CheckAuthorization(xPlayer) then return end
    
    local targetJob = xPlayer.job.name
    
    local rateLimit = Config.RateLimits.withdrawMoney
    if not CheckRateLimit(src, 'withdrawMoney', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end

    if targetJob == 'taxi' then
        local success, topGrades = pcall(function()
            return MySQL.query.await('SELECT grade FROM job_grades WHERE job_name = ? ORDER BY grade DESC LIMIT 2', {'taxi'})
        end)
        
        if success and topGrades then
            if #topGrades >= 2 then
                local highestGrade = topGrades[1].grade
                local secondHighestGrade = topGrades[2].grade
                if xPlayer.job.grade ~= highestGrade and xPlayer.job.grade ~= secondHighestGrade then
                    xPlayer.showNotification('Tylko szef i z-szef mogą wypłacać pieniądze z sejfu taxi!')
                    return
                end
            elseif #topGrades == 1 then
                if xPlayer.job.grade ~= topGrades[1].grade then
                    xPlayer.showNotification('Tylko szef może wypłacać pieniądze z sejfu taxi!')
                    return
                end
            end
        end
    end

    if not QFSOCIETY_SERVER[targetJob] then return end

    TriggerEvent('esx_addonaccount:getSharedAccount', targetJob, function(account)
        if not account then
            xPlayer.showNotification('Błąd: Nie znaleziono konta firmowego')
            return
        end
        
        if money > 0 and account.money >= money then
            account.removeMoney(money)
            xPlayer.addMoney(money)
            xPlayer.showNotification('Wypłaciłeś: '..ESX.Math.GroupDigits(money)..'$ z konta')

            local playerDiscord = ExtractIdentifiers(src)
            AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Wypłacił '..ESX.Math.GroupDigits(money)..'$')

            CreateThread(function()
                Wait(Config.Delays.UpdateDelay)
                if QFSOCIETY_SERVER[targetJob] and QFSOCIETY_SERVER[targetJob].userJobData then
                    QFSOCIETY_SERVER[targetJob].userJobData.jobMoney = account.money
                    QFSOCIETY_SERVER[targetJob].playerData.money = xPlayer.getMoney()
                    TriggerClientEvent('esx_society:setJobData', src, QFSOCIETY_SERVER[targetJob].userJobData)
                    TriggerClientEvent('esx_society:setPlayerData', src, QFSOCIETY_SERVER[targetJob].playerData)
                end
            end)
        else
            xPlayer.showNotification('Konto firmowe nie posiada wystarczająco pieniędzy!')
        end
    end)
end)

RegisterNetEvent('esx_society:addLicense', function(identifier, license, hasLicense)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end

    if not CheckAuthorization(xPlayer) then 
        xPlayer.showNotification('Nie posiadasz wystarczających uprawnień do zarządzania licencjami (Wymagana ranga: '..Config.AuthorizedGrade[xPlayer.job.name]..')')
        return 
    end
    
    if not ValidateIdentifier(identifier) then
        xPlayer.showNotification('Nieprawidłowy identyfikator gracza')
        return
    end
    
    if not license or type(license) ~= "string" then 
        xPlayer.showNotification('Nieprawidłowa licencja')
        return 
    end
    
    local rateLimit = Config.RateLimits.addLicense
    if not CheckRateLimit(src, 'addLicense', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end
    
    if not QFSOCIETY_SERVER[xPlayer.job.name] then 
        xPlayer.showNotification('Błąd: Brak danych frakcji (spróbuj otworzyć menu ponownie)')
        return 
    end
    
    local jobLicenses = Config.JobLicenses[xPlayer.job.name]
    if not jobLicenses then
        xPlayer.showNotification('Błąd: Brak konfiguracji licencji dla tej frakcji')
        return
    end
    
    local licenseUpper = string.upper(license)
    local licenseFound = false
    for _, allowedLicense in pairs(jobLicenses) do
        if string.upper(allowedLicense) == licenseUpper then
            licenseFound = true
            break
        end
    end
    
    if not licenseFound then
        xPlayer.showNotification('Błąd: Ta licencja nie jest dozwolona dla tej frakcji')
        return
    end
    
    license = string.lower(license)
    
    if not hasLicense then
        MySQL.update.await('DELETE FROM user_licenses WHERE owner = ? AND type = ?', {identifier, license})
        MySQL.update.await('INSERT INTO user_licenses (type, owner) VALUES (?, ?)', {license, identifier})
    else
        MySQL.update.await('DELETE FROM user_licenses WHERE owner = ? AND type = ?', {identifier, license})
    end
    
    local getName = getTargetName(identifier)
    local xTarget = ESX.GetPlayerFromIdentifier(identifier)
    local targetDiscord = '-'
    local whatDid = 'Nadał'
    
    if hasLicense then
        whatDid = 'Odebrał'
    end
    
    if xTarget then
        local targetDiscordData = ExtractIdentifiers(xTarget.source)
        targetDiscord = targetDiscordData.discord
    end
    
    local playerDiscord = ExtractIdentifiers(src)
    AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Zaaktualizował licencję', whatDid..' licencja '..license:upper(), getName, targetDiscord)
    
    for k, v in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
        if v.playerIdentifier == identifier then
            local key = string.upper(license)
            if v.playerLicenses[key] ~= nil then
                v.playerLicenses[key] = not hasLicense
            else
                v.playerLicenses[key] = not hasLicense
            end
            break
        end
    end

    TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[xPlayer.job.name].playersData)
end)

RegisterNetEvent('esx_society:transferMoney', function(identifier, money)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then return end
    if not QFSOCIETY_SERVER[xPlayer.job.name] then return end
    if not identifier or not money then return end

    local xTarget = ESX.GetPlayerFromIdentifier(identifier)

    if not xTarget then
        TriggerEvent('esx_addonaccount:getSharedAccount', xPlayer.job.name, function(account)
            if money > 0 and account.money >= money then
                local playerDiscord = ExtractIdentifiers(src)
        
                local bank = MySQL.scalar.await('SELECT accounts FROM users WHERE identifier = ?', {identifier})
				bank = SafeJsonDecode(bank)
				bank.bank = bank.bank + tonumber(money)
				MySQL.update.await('UPDATE users SET accounts = ? WHERE identifier = ?', {json.encode(bank), identifier})

                local getName = MySQL.single.await('SELECT firstname, lastname, discordid FROM users WHERE identifier = ?', {identifier})

                if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
                    MySQL.update('UPDATE qf_mdt_time SET time = ? WHERE identifier = ?', {0, identifier})
                elseif xPlayer.job.name == 'ambulance' then
                    MySQL.update('UPDATE qf_mdt_ems_time SET time = ? WHERE identifier = ?', {0, identifier})
                elseif xPlayer.job.name == 'mechanik' then
                    MySQL.update('UPDATE qf_mdt_lsc_time SET time = ? WHERE identifier = ?', {0, identifier})
                elseif xPlayer.job.name == 'ec' then
                    MySQL.update('UPDATE qf_mdt_ec_time SET time = ? WHERE identifier = ?', {0, identifier})
                end
        
                account.removeMoney(money)
                xPlayer.showNotification('Przelałeś '..money..'$ na konto '..getName.firstname .. ' ' .. getName.lastname)
        
                AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Przelał pieniądze', ESX.Math.GroupDigits(money)..'$', getName.firstname .. ' ' .. getName.lastname, getName.discordid)
        
                CreateThread(function()
                    Wait(Config.Delays.GeneralWait)
                    for k, v in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
                        if v.playerIdentifier == identifier then
                            v.playerPaycheck = 0
                            v.playerHours = 0
                            break
                        end
                    end
                    TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[xPlayer.job.name].playersData)
                end)
            else
                xPlayer.showNotification('Twoje konto firmowe nie posiada wystarczająco pieniędzy!')
            end
        end)
    else
        TriggerEvent('esx_addonaccount:getSharedAccount', xPlayer.job.name, function(account)
            if money > 0 and account.money >= money then
                local playerDiscord = ExtractIdentifiers(src)
                local targetDiscord = ExtractIdentifiers(xTarget.source)
        
                xTarget.addAccountMoney('bank', tonumber(money))
        
                if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
                    MySQL.update('UPDATE qf_mdt_time SET time = ? WHERE identifier = ?', {0, identifier})
                    Player(xTarget.source).state:set('RankTimePolice', 0, true)
                    TriggerClientEvent('qf_mdt:resetHoursPlayer', xTarget.source)
                elseif xPlayer.job.name == 'ambulance' then
                    MySQL.update('UPDATE qf_mdt_ems_time SET time = ? WHERE identifier = ?', {0, identifier})
                    Player(xTarget.source).state:set('RankTimeAmbulance', 0, true)
                    TriggerClientEvent('qf_mdt_ems:resetHoursPlayer', xTarget.source)
                elseif xPlayer.job.name == 'mechanik' then
                    MySQL.update('UPDATE qf_mdt_lsc_time SET time = ? WHERE identifier = ?', {0, identifier})
                    Player(xTarget.source).state:set('RankTimeMechanic', 0, true)
                    TriggerClientEvent('qf_mdt_lsc:resetHoursPlayer', xTarget.source)
                elseif xPlayer.job.name == 'ec' then
                    MySQL.update('UPDATE qf_mdt_ec_time SET time = ? WHERE identifier = ?', {0, identifier})
                    Player(xTarget.source).state:set('RankTimeMechanic', 0, true)
                    TriggerClientEvent('qf_mdt_ec:resetHoursPlayer', xTarget.source)
                end
        
                account.removeMoney(money)
                xPlayer.showNotification('Przelałeś '..money..'$ na konto '..xTarget.getName())
                xTarget.showNotification('Otrzymałeś wypłatę o wysokości '..money..'$')
        
                AddHistory(src, xPlayer.job.name, os.time(), xPlayer.getName(), playerDiscord.discord, 'Przelał pieniądze', ESX.Math.GroupDigits(money)..'$', xTarget.getName(), targetDiscord.discord)
        
                CreateThread(function()
                    Wait(Config.Delays.GeneralWait)
                    for k, v in pairs(QFSOCIETY_SERVER[xPlayer.job.name].playersData) do
                        if v.playerIdentifier == identifier then
                            v.playerPaycheck = 0
                            v.playerHours = 0
                            break
                        end
                    end
                    TriggerClientEvent('esx_society:setPlayersData', src, QFSOCIETY_SERVER[xPlayer.job.name].playersData)
                end)
            else
                xPlayer.showNotification('Twoje konto firmowe nie posiada wystarczająco pieniędzy!')
            end
        end)
    end
end)

RegisterServerEvent('esx_society:discordWebhook', function (data, generalJobType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if not CheckAuthorization(xPlayer) then return end
    
    if not data or not data.value then
        xPlayer.showNotification('Błąd: Brak danych webhook')
        return
    end
    
    if not ValidateWebhookURL(data.value) then
        xPlayer.showNotification('Błąd: Nieprawidłowy URL webhook')
        return
    end
    
    local rateLimit = Config.RateLimits.discordWebhook
    if not CheckRateLimit(src, 'discordWebhook', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end

    local success, result
    if not data.webhook then
        success, result = pcall(function()
            return MySQL.update('UPDATE webhook_fraction SET webhook = ? WHERE name = ?', {data.value, xPlayer.job.name})
        end)
    else
        local webhook = data.webhook
        if webhook == 'main' then
            webhook = ''
        end

        success, result = pcall(function()
            return MySQL.update('UPDATE webhook_fraction SET webhook = ? WHERE name = ?', {data.value, xPlayer.job.name..webhook})
        end)
    end
    
    if not success then
        print('[ERROR] discordWebhook MySQL update failed:', result)
        xPlayer.showNotification('Błąd podczas aktualizacji webhook')
        return
    end
    
    xPlayer.showNotification('Ustawiono webhook!')
end)

RegisterServerEvent('esx_society:buyUpgradeLegal', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end
    
    if not CheckAuthorization(xPlayer) then return end
    
    if not data or not data.upgrade_source then
        xPlayer.showNotification('Błąd: Nieprawidłowe dane ulepszenia')
        return
    end
    
    if not ValidateUpgradeColumn(data.upgrade_source) then
        xPlayer.showNotification('Błąd: Nieprawidłowa kolumna ulepszenia')
        return
    end
    
    if not ValidateMoney(data.upgrade_price) then
        xPlayer.showNotification('Błąd: Nieprawidłowa cena')
        return
    end
    
    local rateLimit = Config.RateLimits.buyUpgradeLegal
    if not CheckRateLimit(src, 'buyUpgradeLegal', rateLimit.maxCalls, rateLimit.timeWindow) then
        xPlayer.showNotification('Zbyt wiele próśb!')
        return
    end

    TriggerEvent("esx_core:takeMoneyServer", xPlayer.source, data.upgrade_price, function(success)
        if success then
            local safeColumnName = GetSafeColumnName(data.upgrade_source)
            if not safeColumnName then
                xPlayer.showNotification('Błąd: Nieprawidłowa kolumna ulepszenia')
                return
            end
            
            local querySuccess, result = pcall(function()
                return MySQL.query('UPDATE esx_society SET `'..safeColumnName..'` = ? WHERE name = ?', {1, xPlayer.job.name})
            end)
            
            if not querySuccess then
                print('[ERROR] buyUpgradeLegal MySQL query failed:', result)
                xPlayer.showNotification('Błąd podczas zakupu ulepszenia')
                return
            end
            
            xPlayer.showNotification('Zakupiono ulepszenie!')
            TriggerEvent('esx_society:upgradesLegal', xPlayer)
        else
            xPlayer.showNotification("Nie stać Cię na kupno ulepszenia")
        end
    end)
end)

local function getUpgradesLegal(xPlayer, upgradeName)
	if not xPlayer then return false end
	
	local safeColumnName = GetSafeColumnName(upgradeName)
	if not safeColumnName then
		return false
	end

	local haveUpgrade = false
	local success, license = pcall(function()
		return MySQL.scalar.await('SELECT `'..safeColumnName..'` FROM esx_society WHERE name = ?', { xPlayer.job.name })
	end)
	
	if not success then
		print('[ERROR] getUpgradesLegal MySQL query failed:', license)
		return false
	end
	
	if license ~= nil then
		if license == 1 then
			haveUpgrade = true
		end
	end

	return haveUpgrade
end

exports('getUpgradesLegal', getUpgradesLegal)

lib.callback.register('esx_society:getUpgradesLegal', function(source, upgradeName)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return false end
	
	local safeColumnName = GetSafeColumnName(upgradeName)
	if not safeColumnName then
		return false
	end

	local haveUpgrade = false
	local success, license = pcall(function()
		return MySQL.scalar.await('SELECT `'..safeColumnName..'` FROM esx_society WHERE name = ?', { xPlayer.job.name })
	end)
	
	if not success then
		return false
	end
	
	if license ~= nil then
		if license == 1 then
			haveUpgrade = true
		end
	end

	return haveUpgrade
end)

ESX.RegisterServerCallback('esx_society:getEmployees', function(source, cb, society)
	local employees = {}
	local employeesIdentifiers = {}
	local employeeCount = 0
	local societyJobData = Jobs[society]
	
	local function formatPlayerName(xPlayer)
		local name = xPlayer.getName()
		local firstName = xPlayer.get('firstName')
		local lastName = xPlayer.get('lastName')
		if firstName and lastName and firstName ~= "" and lastName ~= "" then
			name = firstName .. ' ' .. lastName
		end
		return name
	end
	
	for _, xPlayer in pairs(ESX.Players) do
		local identifier = xPlayer.identifier
		
		if xPlayer.job.name == society then
			employeeCount = employeeCount + 1
			employees[employeeCount] = {
				name = formatPlayerName(xPlayer),
				identifier = identifier,
				job = {
					name = society,
					label = xPlayer.job.label,
					grade = xPlayer.job.grade,
					grade_name = xPlayer.job.grade_name,
					grade_label = xPlayer.job.grade_label
				},
				duty = xPlayer.job.onDuty or true
			}
			employeesIdentifiers[identifier] = true
		else
			local multiJobs = xPlayer.get('multi_jobs') or {}
			local multiJobData = multiJobs[society]
			if multiJobData and not employeesIdentifiers[identifier] then
				local jobGrade = multiJobData.grade or 0
				local gradeStr = tostring(jobGrade)
				local gradeData = societyJobData and societyJobData.grades and societyJobData.grades[gradeStr]
				
				employeeCount = employeeCount + 1
				employees[employeeCount] = {
					name = formatPlayerName(xPlayer),
					identifier = identifier,
					job = {
						name = society,
						label = multiJobData.label or (societyJobData and societyJobData.label or society),
						grade = jobGrade,
						grade_name = gradeData and gradeData.name or "unknown",
						grade_label = multiJobData.gradeLabel or (gradeData and gradeData.label or ESX.GetGradeLabel(society, jobGrade))
					},
					duty = xPlayer.job.onDuty or true
				}
				employeesIdentifiers[identifier] = true
			end
		end
	end
		
	local query = [[
		SELECT 
			u.identifier, 
			u.firstname, 
			u.lastname,
			u.job,
			u.multi_jobs
		FROM users u
		WHERE (u.job IS NOT NULL AND JSON_VALID(u.job) = 1 AND JSON_UNQUOTE(JSON_EXTRACT(u.job, '$.name')) = ?)
		   OR (u.multi_jobs IS NOT NULL AND JSON_VALID(u.multi_jobs) = 1 AND JSON_CONTAINS_PATH(u.multi_jobs, 'one', CONCAT('$."', ?, '"')) = 1)
	]]

	MySQL.query(query, {society, society},
	function(result)
		if result then
			for k, row in pairs(result) do
				local identifier = row.identifier
				
				if not employeesIdentifiers[identifier] then
					local name = row.firstname .. ' ' .. row.lastname
					local jobGrade = 0
					local found = false
					
					local decodedJob = SafeJsonDecode(row.job)
					if decodedJob.name == society then
						jobGrade = decodedJob.grade or 0
						found = true
					else
						local decodedMultiJobs = SafeJsonDecode(row.multi_jobs)
						if decodedMultiJobs[society] then
							jobGrade = decodedMultiJobs[society].grade or 0
							found = true
						end
					end
					
					if found then
						local gradeStr = tostring(jobGrade)
						local gradeData = societyJobData and societyJobData.grades and societyJobData.grades[gradeStr]
						
						local offlinePlayer = ESX.GetPlayerFromIdentifier(identifier)
						local duty = false
						if offlinePlayer then
							duty = offlinePlayer.job.onDuty or true
						end

						employeeCount = employeeCount + 1
						employees[employeeCount] = {
							name = name,
							identifier = identifier,
							job = {
								name = society,
								label = societyJobData and societyJobData.label or society,
								grade = jobGrade,
								grade_name = gradeData and gradeData.name or "unknown",
								grade_label = gradeData and gradeData.label or ESX.GetGradeLabel(society, jobGrade)
							},
							duty = duty
						}
						employeesIdentifiers[identifier] = true
					end
				end
			end
		end

		cb(employees)
	end)
end)

ESX.RegisterServerCallback('esx_society:getSocietyMoney', function(source, cb, societyName)    
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' ..societyName, function(account)
        if account and account.money then
            cb(account.money)
        else
            TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account2)
                cb(account2 and account2.money or 0)
            end)
        end
    end)
end)

ESX.RegisterServerCallback('esx_society:getOnlinePlayers', function(source, cb)
    local players = {}
    local xPlayers = ESX.GetExtendedPlayers()
    
    for _, xPlayer in pairs(xPlayers) do
        local name = xPlayer.getName()
        local firstName = xPlayer.get('firstName')
        local lastName = xPlayer.get('lastName')
        
        if firstName and lastName and firstName ~= "" and lastName ~= "" then
            name = firstName .. ' ' .. lastName
        end
        
        table.insert(players, {
            source = xPlayer.source,
            identifier = xPlayer.identifier,
            name = name
        })
    end
    
    cb(players)
end)

ESX.RegisterServerCallback('esx_society:checkBossPermission', function(source, cb, jobName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        return cb(false)
    end
    
    if xPlayer.job.name ~= jobName then
        return cb(false)
    end
    
    if Config.AuthorizedGrade[jobName] and xPlayer.job.grade >= Config.AuthorizedGrade[jobName] then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('esx_society:setJob', function(source, cb, targetIdentifier, jobName, grade, action)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromIdentifier(targetIdentifier)
    
    if not xPlayer then
        return cb(false)
    end
    
    if not Config.AuthorizedGrade[xPlayer.job.name] or xPlayer.job.grade < Config.AuthorizedGrade[xPlayer.job.name] then
        return cb(false)
    end
    
    if action == "hire" then
        if not xTarget then
            return cb(false)
        end
        
        if xPlayer.identifier == xTarget.identifier then
            return cb(false)
        end
        
        local exoticBusinesses = GetResourceState('exotic_businesses')
        if exoticBusinesses == 'started' then
            local success, currentCount = pcall(function()
                return exports.exotic_businesses:GetCurrentEmployeeCount(jobName)
            end)
            local success2, maxLimit = pcall(function()
                return exports.exotic_businesses:GetEmployeeLimit(jobName)
            end)
            
            if success and success2 and currentCount ~= nil and maxLimit ~= nil then
                if currentCount >= maxLimit then
                    xPlayer.showNotification(("Osiągnięto maksymalny limit pracowników (%d/%d). Ulepsz firmę aby zwiększyć limit."):format(currentCount, maxLimit))
                    return cb(false)
                end
            end
        end
        
        local multiJobs = xTarget.get('multi_jobs') or {}
        local jobLabel = ESX.GetJobLabelFromName(jobName)
        
        if multiJobs[jobName] then
            xPlayer.showNotification('Gracz już posiada tę pracę w multijob!')
            return cb(false)
        end
        
        local targetGrade = grade or 1
        multiJobs[jobName] = {
            grade = targetGrade,
            label = jobLabel,
            gradeLabel = ESX.GetGradeLabel(jobName, targetGrade)
        }
        
        xTarget.setJob(jobName, targetGrade)
        xTarget.set('multi_jobs', multiJobs)
        
        if exports['esx_multijob'] then
            exports['esx_multijob']:SaveJobData(xTarget.identifier, multiJobs)
            TriggerClientEvent('esx_multijob/updateJobs', xTarget.source, multiJobs)
        end
        
        xPlayer.showNotification('Zatrudniono gracza ' .. jobLabel)
        xTarget.showNotification('Otrzymałeś pracę ' .. jobLabel)
        
        cb(true)
    elseif action == "fire" then
        local currentJob = xPlayer.job.name
        
        if targetIdentifier == xPlayer.identifier then
            return cb(false)
        end
        
        if xTarget then
            local multiJobs = xTarget.get('multi_jobs') or {}
            
            if not multiJobs[currentJob] and xTarget.job.name ~= currentJob then
                return cb(false)
            end
            
            local targetGrade = 0
            if xTarget.job.name == currentJob then
                targetGrade = xTarget.job.grade
            elseif multiJobs[currentJob] then
                targetGrade = multiJobs[currentJob].grade or 0
            end
            
            if targetGrade >= xPlayer.job.grade then
                xPlayer.showNotification('Nie możesz wyrzucić osoby z równą lub wyższą rangą!')
                return cb(false)
            end
            
            if multiJobs[currentJob] then
                multiJobs[currentJob] = nil
                xTarget.set('multi_jobs', multiJobs)
                if exports['esx_multijob'] then
                    exports['esx_multijob']:SaveJobData(xTarget.identifier, multiJobs)
                    TriggerClientEvent('esx_multijob/updateJobs', xTarget.source, multiJobs)
                end
            end
            
            if xTarget.job.name == currentJob then
                xTarget.setJob('unemployed', 0)
            end
            
            xPlayer.showNotification('Zwolniłeś gracza ' .. GetPlayerName(xTarget.source) .. ' z pracy ' .. ESX.GetJobLabelFromName(currentJob))
            xTarget.showNotification('Zostałeś zwolniony z pracy ' .. ESX.GetJobLabelFromName(currentJob))
            
            cb(true)
        else
            local user = MySQL.single.await('SELECT multi_jobs, job FROM users WHERE identifier = ?', {targetIdentifier})
            if not user then
                return cb(false)
            end
            
            local decodedJob = user.job and json.decode(user.job) or {}
            local multiJobs = user.multi_jobs and json.decode(user.multi_jobs) or {}
            
            local targetGrade = 0
            if decodedJob.name == currentJob then
                targetGrade = decodedJob.grade or 0
            elseif multiJobs[currentJob] then
                targetGrade = multiJobs[currentJob].grade or 0
            end
            
            if targetGrade >= xPlayer.job.grade then
                xPlayer.showNotification('Nie możesz wyrzucić osoby z równą lub wyższą rangą!')
                return cb(false)
            end
            
            local removed = false
            if multiJobs[currentJob] then
                multiJobs[currentJob] = nil
                MySQL.update('UPDATE users SET multi_jobs = ? WHERE identifier = ?', {json.encode(multiJobs), targetIdentifier})
                removed = true
            end
            
            if decodedJob.name == currentJob then
                MySQL.update('UPDATE users SET job = ? WHERE identifier = ?', {json.encode({name = 'unemployed', grade = 0}), targetIdentifier})
                removed = true
            end
            
            if not removed then
                xPlayer.showNotification('Gracz offline nie miał tej pracy.')
                return cb(false)
            end
            
            xPlayer.showNotification('Zwolniłeś gracza offline z pracy ' .. ESX.GetJobLabelFromName(currentJob))
            cb(true)
        end
    elseif action == "promote" then
        local currentJob = xPlayer.job.name
        
        if targetIdentifier == xPlayer.identifier then
            xPlayer.showNotification('Nie możesz zmienić rangi samemu sobie!')
            return cb(false)
        end
        
        if xTarget then
            local multiJobs = xTarget.get('multi_jobs') or {}
            local targetJob = xTarget.job.name
            
            if targetJob ~= currentJob and not multiJobs[currentJob] then
                return cb(false)
            end
            
            local targetGrade = 0
            if targetJob == currentJob then
                targetGrade = xTarget.job.grade
            elseif multiJobs[currentJob] then
                targetGrade = multiJobs[currentJob].grade or 0
            end
            
            if grade >= xPlayer.job.grade or grade <= targetGrade then
                return cb(false)
            end
            
            if not Jobs[currentJob] or not Jobs[currentJob].grades[tostring(grade)] then
                return cb(false)
            end
            
            if targetJob == currentJob then
                xTarget.setJob(currentJob, grade)
            end
            
            if multiJobs[currentJob] then
                multiJobs[currentJob].grade = grade
                multiJobs[currentJob].gradeLabel = ESX.GetGradeLabel(currentJob, grade)
                xTarget.set('multi_jobs', multiJobs)
                if exports['esx_multijob'] then
                    exports['esx_multijob']:SaveJobData(xTarget.identifier, multiJobs)
                    TriggerClientEvent('esx_multijob/updateJobs', xTarget.source, multiJobs)
                end
            end
            
            xPlayer.showNotification('Awansowano gracza ' .. GetPlayerName(xTarget.source))
            xTarget.showNotification('Zostałeś awansowany w pracy ' .. ESX.GetJobLabelFromName(currentJob))
            
            cb(true)
        else
            if targetIdentifier == xPlayer.identifier then
                xPlayer.showNotification('Nie możesz zmienić rangi samemu sobie!')
                return cb(false)
            end
            
            local user = MySQL.single.await('SELECT multi_jobs, job FROM users WHERE identifier = ?', {targetIdentifier})
            if not user then
                return cb(false)
            end
            
            local decodedJob = user.job and json.decode(user.job) or {}
            local multiJobs = user.multi_jobs and json.decode(user.multi_jobs) or {}
            
            if decodedJob.name ~= currentJob and not multiJobs[currentJob] then
                return cb(false)
            end
            
            local targetGrade = 0
            if decodedJob.name == currentJob then
                targetGrade = decodedJob.grade or 0
            elseif multiJobs[currentJob] then
                targetGrade = multiJobs[currentJob].grade or 0
            end
            
            if grade >= xPlayer.job.grade or grade <= targetGrade then
                return cb(false)
            end
            
            if not Jobs[currentJob] or not Jobs[currentJob].grades[tostring(grade)] then
                return cb(false)
            end
            
            if decodedJob.name == currentJob then
                decodedJob.grade = grade
                MySQL.update('UPDATE users SET job = ? WHERE identifier = ?', {json.encode(decodedJob), targetIdentifier})
            end
            
            if multiJobs[currentJob] then
                multiJobs[currentJob].grade = grade
                multiJobs[currentJob].gradeLabel = ESX.GetGradeLabel(currentJob, grade)
                MySQL.update('UPDATE users SET multi_jobs = ? WHERE identifier = ?', {json.encode(multiJobs), targetIdentifier})
            end
            
            xPlayer.showNotification('Awansowano gracza offline')
            cb(true)
        end
    else
        cb(false)
    end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        ClearPlayerCache(xPlayer.identifier)
    end
    
    for key, _ in pairs(lastGameTimerId) do
        if key:match("^" .. playerId .. ":") then
            lastGameTimerId[key] = nil
        end
    end
end)