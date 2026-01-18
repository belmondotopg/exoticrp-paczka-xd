local carry = {
	InProgress = false,
	targetSrc = -1,
	type = "",
	personCarrying = {
		animDict = "missfinale_c2mcs_1",
		anim = "fin_c2_mcs_1_camman",
		flag = 49,
	},
	personCarried = {
		animDict = "nm",
		anim = "firemans_carry",
		attachX = 0.27,
		attachY = 0.15,
		attachZ = 0.63,
		flag = 33,
	}
}

local function ensureAnimDict(animDict)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(0)
		end
	end
end

local function requestCarry(targetEntity)
	local playerPed = PlayerPedId()
	if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsConcussed then
		return
	end

	if not IsPedStill(playerPed) then
		ESX.ShowNotification("Nie możesz biegać podczas podnoszenia")
		return
	end

	if IsPedInAnyVehicle(playerPed) then
		return
	end

	local targetSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetEntity))
	if targetSrc == -1 then
		ESX.ShowNotification("Nie ma nikogo w pobliżu")
		return
	end

	if Player(targetSrc).state.IsHandcuffed then
		ESX.ShowNotification("Nie możesz podnieść zakutego gracza")
		return
	end

	if Player(targetSrc).state.IsConcussed then
		ESX.ShowNotification("Nie możesz podnieść powalonego gracza")
		return
	end

	TriggerServerEvent("CarryPeople:request", targetSrc)
end


local function stopCarry()
	if not carry.InProgress then
		return
	end

	carry.InProgress = false
	local playerPed = PlayerPedId()
	ClearPedSecondaryTask(playerPed)
	DetachEntity(playerPed, true, false)
	LocalPlayer.state:set('canUseWeapons', true, false)
	TriggerServerEvent("CarryPeople:stop", carry.targetSrc)
	carry.targetSrc = -1
end

RegisterCommand("stopcarry", function()
	stopCarry()
end, false)

exports.ox_target:addGlobalPlayer({
	{
		name = "carry_player",
		icon = "fa-solid fa-hand-holding",
		label = "Podnieś gracza",
		distance = 3.0,
		canInteract = function(entity, distance, coords, name, bone)
			if carry.InProgress then
				return false
			end

			if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsConcussed then
				return false
			end

			if distance > 3.0 then
				return false
			end

			local playerPed = PlayerPedId()
			if not IsPedStill(playerPed) or IsPedInAnyVehicle(playerPed) then
				return false
			end

			if not IsPedAPlayer(entity) then
				return false
			end

			local targetSrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
			if targetSrc ~= -1 then
				if Player(targetSrc).state.IsHandcuffed or Player(targetSrc).state.IsConcussed then
					return false
				end
			end

			return true
		end,
		onSelect = function(data)
			if not data.entity then
				return
			end
			requestCarry(data.entity)
		end
	}
})

local pendingRequest = nil

RegisterNetEvent("CarryPeople:requestReceived")
AddEventHandler("CarryPeople:requestReceived", function(sourceSrc)
	local sourceName = GetPlayerName(GetPlayerFromServerId(sourceSrc))
	pendingRequest = sourceSrc
	ESX.ShowNotification("Gracz " .. sourceName .. " chce Cię podnieść. Naciśnij [E] aby zaakceptować lub [X] aby odrzucić")
end)

Citizen.CreateThread(function()
	while true do
		if pendingRequest then
			if IsControlJustPressed(0, 38) then
				TriggerServerEvent("CarryPeople:accept", pendingRequest)
				pendingRequest = nil
			elseif IsControlJustPressed(0, 73) then
				TriggerServerEvent("CarryPeople:reject", pendingRequest)
				pendingRequest = nil
			end
			Citizen.Wait(0)
		else
			Citizen.Wait(250)
		end
	end
end)


RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
	local playerPed = PlayerPedId()
	carry.InProgress = true
	carry.targetSrc = targetSrc
	carry.type = "beingcarried"
	LocalPlayer.state:set('canUseWeapons', false, false)
	ensureAnimDict(carry.personCarried.animDict)
	AttachEntityToEntity(playerPed, targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY, carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
end)

RegisterNetEvent("CarryPeople:startCarrying")
AddEventHandler("CarryPeople:startCarrying", function(targetSrc)
	carry.InProgress = true
	carry.targetSrc = targetSrc
	carry.type = "carrying"
	LocalPlayer.state:set('canUseWeapons', false, false)
	ensureAnimDict(carry.personCarrying.animDict)
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
	carry.InProgress = false
	local playerPed = PlayerPedId()
	ClearPedSecondaryTask(playerPed)
	DetachEntity(playerPed, true, false)
	LocalPlayer.state:set('canUseWeapons', true, false)
end)

Citizen.CreateThread(function()
	while true do
		if carry.InProgress then
			local playerPed = PlayerPedId()
			local animData = carry.type == "beingcarried" and carry.personCarried or carry.personCarrying
			if not IsEntityPlayingAnim(playerPed, animData.animDict, animData.anim, 3) then
				TaskPlayAnim(playerPed, animData.animDict, animData.anim, 8.0, -8.0, 100000, animData.flag, 0, false, false, false)
			end
			
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 25, true)
			DisableControlAction(0, 257, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 142, true)
			DisableControlAction(0, 143, true)
			
			if carry.type == "carrying" and IsControlJustPressed(0, 73) then
				stopCarry()
			end
			
			Citizen.Wait(0)
		else
			Citizen.Wait(250)
		end
	end
end)