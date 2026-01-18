local function convertGender(sex)
	if sex == "m" then
		return "male"
	elseif sex == "f" then
		return "female"
	end
	return "male"
end

local function getStreetName(coords)
	if not coords or not coords.x or not coords.y or not coords.z then
		return "Nieznana"
	end
	
	local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
	local streetName = GetStreetNameFromHashKey(streetHash)
	local crossingName = GetStreetNameFromHashKey(crossingHash)
	
	if streetName and streetName ~= "" then
		if crossingName and crossingName ~= "" then
			return streetName .. " / " .. crossingName
		end
		return streetName
	end
	
	return "Nieznana"
end

local function convertCharactersForNui(chars)
    if not chars or #chars == 0 then
        return {}
    end

    local result = {}

    for i, char in pairs(chars) do
        local bank = 0
        local cash = 0

        if char.accounts then
            if type(char.accounts) == "string" then
                local success, decoded = pcall(json.decode, char.accounts)
                if success and type(decoded) == "table" then
                    bank = tonumber(decoded.bank) or 0
                    cash = tonumber(decoded.money) or 0
                end
            elseif type(char.accounts) == "table" then
                bank = tonumber(char.accounts.bank) or 0
                cash = tonumber(char.accounts.money) or 0
            end
        end

        local jobName = "Bezrobotny"
        if char.job then
            if type(char.job) == "string" then
                local success, decoded = pcall(json.decode, char.job)
                if success and type(decoded) == "table" then
                    jobName = decoded.label or decoded.name or "Bezrobotny"
                else
                    jobName = char.job
                end
            elseif type(char.job) == "table" then
                jobName = char.job.label or char.job.name or "Bezrobotny"
            end
        end

        local defaultCoords = {x = 0, y = 0, z = 0}
        local coords = char.coords or defaultCoords

        result[i] = {
            id = tostring(i),
			
            firstName = char.firstname or "Nieznane",
            lastName = char.lastname or "",
            lastLocation = getStreetName(coords),
            bank = bank,
            cash = cash,
            job = jobName,
            gender = convertGender(char.sex),
            birthDate = char.birthdate or "Nieznana",
            height = char.height or 180,
            identifier = char.identifier,
        }
    end

    return result
end

local dataReceivedFlag = false
local isMulticharacterOpen = false
local reactReadyFlag = false
local reactReadyCheckCount = 0

RegisterNUICallback('multicharacter/reactReady', function(data, cb)
	reactReadyCheckCount = reactReadyCheckCount + 1
	reactReadyFlag = true
	cb('ok')
end)

AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		reactReadyFlag = false
		reactReadyCheckCount = 0
	end
end)

local function openMulticharacter(data)
	if not data or not data.chars then
		return
	end

	local characters = convertCharactersForNui(data.chars)
	
	if #characters == 0 then
		return
	end

	if isMulticharacterOpen then
		return
	end

	isMulticharacterOpen = true
	dataReceivedFlag = false

	local dataMessage = {
		eventName = "nui:data:update",
		dataId = "multicharacter-data",
		data = {
			characters = characters,
			maxSlots = data.maxSlots or 5
		}
	}
	
	local visibilityMessage = {
		eventName = "nui:visible:update",
		elementId = "multicharacter",
		visible = true
	}

	CreateThread(function()
		local waitCount = 0
		local maxWaitTime = 150
		
		while not reactReadyFlag and waitCount < maxWaitTime do
			Wait(100)
			waitCount = waitCount + 1
		end
		
		if not reactReadyFlag then
			print("^1[esx_hud] React nie zaladowal sie w ciagu 15 sekund! Probuje wyslac dane mimo to...^0")
		end
		
		local attempts = 0
		local maxAttempts = 20
		
		while not dataReceivedFlag and attempts < maxAttempts do
			attempts = attempts + 1
			
			SendNUIMessage(dataMessage)
			Wait(150)
			
			SendNUIMessage(visibilityMessage)
			
			Wait(200)
			
			if dataReceivedFlag then
				break
			end
		end
		
		if not dataReceivedFlag then
			print("^1[esx_hud] Multicharacter nie otrzymal danych po 20 probach! Sprawdz console F8.^0")
		end
		
		SendNUIMessage(visibilityMessage)
		
		Wait(100)
		
		SetNuiFocus(true, true)
	end)
end

exports('openMulticharacter', openMulticharacter)

RegisterNUICallback('multicharacter/create', function(data, cb)
	cb('ok')
	
	isMulticharacterOpen = false
	LocalPlayer.state:set('multicharChosen', false, false)

	SendNUIMessage({
		eventName = "nui:visible:update",
		elementId = "multicharacter",
		visible = false
	})

	SetNuiFocus(false, false)
	
	exports.esx_multicharacter:characterCreate()
end)

RegisterNUICallback('multicharacter/play', function(data, cb)
	cb('ok')
	
	if not data or not data.id then
		return
	end

	isMulticharacterOpen = false
	LocalPlayer.state:set('multicharChosen', false, false)

	SendNUIMessage({
		eventName = "nui:visible:update",
		elementId = "multicharacter",
		visible = false
	})

	SetNuiFocus(false, false)

	DoScreenFadeOut(1500)
	Wait(2500)

	local playerPed = PlayerPedId()
	TriggerServerEvent('esx_multicharacter:CharacterChosen', tonumber(data.id), false)
	TriggerEvent('esx_hud:loadSettings')
	ClearPedTasks(playerPed)
	FreezeEntityPosition(playerPed, false)
end)

RegisterNUICallback('multicharacter/switchCharacter', function(data, cb)
	cb('ok')
	
	if data and data.id then
		exports.esx_multicharacter:characterSwitch(tonumber(data.id), data.character)
	end
end)

RegisterNUICallback('multicharacter/dataReceived', function(data, cb)
	dataReceivedFlag = true
	cb('ok')
end)
