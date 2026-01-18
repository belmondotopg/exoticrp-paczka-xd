local esx_hud = exports.esx_hud
local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local LocalPlayer = LocalPlayer
local GetCurrentResourceName = GetCurrentResourceName
local FreezeEntityPosition = FreezeEntityPosition
local minimumPlayersCount = 1
local canCancel = false
local libCache = lib.onCache
local cachePed = cache.ped
local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

local drugs_animations = {
	meth = {
		Collect = {
			Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
			Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
		},
		Transform = {
			Collect = {
				Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
				Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
			},
		},
	},
	cocaine = {
		Collect = {
			Prop = { model = 'anim@gangops@facility@servers@bodysearch@', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
			Anim = { dict = 'anim@gangops@facility@servers@bodysearch@', clip = 'player_search' },
		},
		Transform = {
			Collect = {
				Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
				Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
			},
		},
	},
	opium = {
		Collect = {
			Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
			Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
		},
		Transform = {
			Collect = {
				Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
				Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
			},
		},
	},
	heroina = {
		Collect = {
			Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
			Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
		},
		Transform = {
			Collect = {
				Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
				Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
			},
		},
	},
	bagniak = {
		Collect = {
			Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
			Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
		},
		Transform = {
			Collect = {
				Prop = { model = 'bkr_prop_coke_spatula_04', pos = vector3(0.10, 0.0, 0.0), rot = vector3(0.0, 0.0, 90.0), bone = 28422 },
				Anim = { dict = 'anim@amb@drug_processors@coke@female_b@idles', clip = 'idle_d' },
			},
		},
	},
}

LocalPlayer.state:set('onCollectingDrugs', false, true)
LocalPlayer.state:set('onTransferringDrugs', false, true)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

libCache('ped', function(ped)
    cachePed = ped
end)

local function CollectNaroctic(naroctic)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then
		ESX.ShowNotification('Nie możesz teraz tego robić!')
		canCancel = false
		return
	end

	if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then
		ESX.ShowNotification('Nie możesz teraz tego robić!')
		canCancel = false
		return
	end

	TriggerEvent('ox_inventory:disarm')

	if canCancel == false then
		canCancel = true
		Citizen.CreateThread(function()
			ESX.UI.Menu.CloseAll()
			FreezeEntityPosition(cachePed, true)
			repeat
				local count = ox_inventory:Search('count', naroctic)

				if count >= 150 then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Masz już wystarczającą ilość tego narkotyku!')
					break
				end

				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Nie możesz teraz tego robić!')
					return
				end

				if ox_inventory:GetPlayerWeight() >= 60000 then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Masz pełny ekwipunek!')
					return
				end

				local drugData = drugs_animations[naroctic]
                local anim = drugData and drugData.Collect.Anim or nil
                local prop = drugData and drugData.Collect.Prop or nil

                if exports["esx_hud"]:progressBar({
                    duration = 10,
                    label = 'Zbieranie...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                        mouse = false,
                    },
                    anim = anim,
                    prop = {},
                })
				then
					if canCancel then
						LocalPlayer.state:set('onCollectingDrugs', true, true)
						Citizen.Wait(1000)
						TriggerServerEvent(GetCurrentResourceName() .. ':onCollectingDrugs', naroctic)
					end
				else 
					ESX.ShowNotification('Anulowano zbieranie.')
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					LocalPlayer.state:set('onCollectingDrugs', false, true)
				end
				
				Citizen.Wait(1000)
			until (canCancel == false)

			LocalPlayer.state:set('onCollectingDrugs', false, true)
		end)
	end
end

local function ProcessNaroctic(naroctic, naroctic2)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then
		ESX.ShowNotification('Nie możesz teraz tego robić!')
		canCancel = false
		return
	end

	if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then
		ESX.ShowNotification('Nie możesz teraz tego robić!')
		canCancel = false
		return
	end

	TriggerEvent('ox_inventory:disarm')

	if canCancel == false then
		canCancel = true
		Citizen.CreateThread(function()
			ESX.UI.Menu.CloseAll()
			FreezeEntityPosition(cachePed, true)
			repeat
				local count = ox_inventory:Search('count', naroctic2..'_packaged')
				local countStart = ox_inventory:Search('count', naroctic)

				if countStart < 5 then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Nie masz wystarczająco narkotyku do przerobienia!')
					break
				end

				if count >= 30 then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Masz już wystarczającą ilość tego narkotyku!')
					break
				end

				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Nie możesz teraz tego robić!')
					return
				end

				if ox_inventory:GetPlayerWeight() >= 60000 then
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					ESX.ShowNotification('Masz pełny ekwipunek!')
					return
				end

				local drugData = drugs_animations[naroctic]
                local anim = drugData and drugData.Transform.Anim or nil
                local prop = drugData and drugData.Transform.Prop or nil

				if esx_hud:progressBar({
					duration = 20,
					label = 'Przerabianie...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = anim,
					prop = {},
				})
				then
					if canCancel then
						LocalPlayer.state:set('onTransferringDrugs', true, true)
						Citizen.Wait(1000)
						TriggerServerEvent(GetCurrentResourceName() .. ':onProcessDrugs', naroctic, naroctic2)
					end
				else 
					ESX.ShowNotification('Anulowano przerabianie.')
					canCancel = false
					TriggerServerEvent('esx_drugs:onStopDrugs')
					FreezeEntityPosition(cachePed, false)
					LocalPlayer.state:set('onTransferringDrugs', false, true)
				end

				Citizen.Wait(1000)
			until (canCancel == false)
			LocalPlayer.state:set('onTransferringDrugs', false, true)
		end)
	end
end

-- KOORDYNATY DO USTAWIENIA --

-- Citizen.CreateThread(function ()
-- 	ox_target:addBoxZone({
-- 		name = "collect_meth",
-- 		coords = vec3(777.05, 743.2, 105.95),
-- 		size = vec3(9.6, 2.65, 1.35),
-- 		rotation = 332.75,
-- 		options = {
-- 			{
-- 				name = 'collect_meth',
-- 				event = 'esx_drugs:collect_meth',
-- 				icon = 'fa-solid fa-tablets',
-- 				label = 'Zbierz metamfetamine',
-- 				canInteract = function(entity, distance, coords, name)
-- 					if LocalPlayer.state.IsDead then return false end
-- 					if LocalPlayer.state.IsHandcuffed then return false end
-- 					if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'offpolice' or ESX.PlayerData.job.name == 'offsheriff' or ESX.PlayerData.job.name == 'offambulance' then return false end

-- 					return true
-- 				end,
-- 				onSelect = function ()
-- 					if GlobalState.Counter['players'] >= minimumPlayersCount then
-- 						CollectNaroctic('meth')
-- 					else
-- 						ESX.ShowNotification('Nie ma wystaczającej ilości graczy minimum '..minimumPlayersCount)
-- 						return
-- 					end
-- 				end
-- 			},
-- 		},
-- 	})

-- 	ox_target:addBoxZone({ -- USTAWIONE
-- 		name = "transfer_meth",
-- 		coords = vec3(-897.7, 4045.3, 162.55),
-- 		size = vec3(5.65, 4.0, 1.7),
-- 		rotation = 350.0,
-- 		options = {
-- 			{
-- 				name = 'transfer_meth',
-- 				event = 'esx_drugs:transfer_meth',
-- 				icon = 'fa-solid fa-tablets',
-- 				label = 'Przerób metamfetamine',
-- 				canInteract = function(entity, distance, coords, name)
-- 					if LocalPlayer.state.IsDead then return false end
-- 					if LocalPlayer.state.IsHandcuffed then return false end
-- 					if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'offpolice' or ESX.PlayerData.job.name == 'offsheriff' or ESX.PlayerData.job.name == 'offambulance' then return false end

-- 					return true
-- 				end,
-- 				onSelect = function ()
-- 					if GlobalState.Counter['players'] >= minimumPlayersCount then
-- 						local count = ox_inventory:Search('count', 'meth')

-- 						if count >= 5 then
-- 							ProcessNaroctic('meth', 'meth')
-- 						else
-- 							ESX.ShowNotification('Nie ma wystaczającej ilości narkotyku')
-- 							return
-- 						end
-- 					else
-- 						ESX.ShowNotification('Nie ma wystaczającej ilości graczy minimum '..minimumPlayersCount)	
-- 						return
-- 					end
-- 				end
-- 			},
-- 		},
-- 	})

-- 	ox_target:addBoxZone({
-- 		name = "collect_cocaine",
-- 		coords = vec3(-1912.75, 1388.25, 219.0),
-- 		size = vec3(4.75, 3.25, 1.0),
-- 		rotation = 0.0,
-- 		options = {
-- 			{
-- 				name = 'collect_cocaine',
-- 				event = 'esx_drugs:collect_cocaine',
-- 				icon = 'fa-solid fa-capsules',
-- 				label = 'Zbierz kokaine',
-- 				canInteract = function(entity, distance, coords, name)
-- 					if LocalPlayer.state.IsDead then return false end
-- 					if LocalPlayer.state.IsHandcuffed then return false end
-- 					if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'offpolice' or ESX.PlayerData.job.name == 'offsheriff' or ESX.PlayerData.job.name == 'offambulance' then return false end

-- 					return true
-- 				end,
-- 				onSelect = function ()
-- 					CollectNaroctic('cocaine')
					
-- 				end
-- 			},
-- 		},
-- 	})

-- 	ox_target:addBoxZone({ -- USTAWIONE
-- 		name = "transfer_cocaine",
-- 		coords = vec3(-482.5, -1411.35, 11.1),
-- 		size = vec3(1.3, 8.15, 1.4),
-- 		rotation = 345.0,
-- 		options = {
-- 			{
-- 				name = 'transfer_cocaine',
-- 				event = 'esx_drugs:transfer_cocaine',
-- 				icon = 'fa-solid fa-capsules',
-- 				label = 'Przerób kokaine',
-- 				canInteract = function(entity, distance, coords, name)
-- 					if LocalPlayer.state.IsDead then return false end
-- 					if LocalPlayer.state.IsHandcuffed then return false end
-- 					if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'offpolice' or ESX.PlayerData.job.name == 'offsheriff' or ESX.PlayerData.job.name == 'offambulance' then return false end

-- 					return true
-- 				end,
-- 				onSelect = function ()
-- 					if GlobalState.Counter['players'] >= minimumPlayersCount then
-- 						local count = ox_inventory:Search('count', 'cocaine')

-- 						if count >= 5 then
-- 							ProcessNaroctic('cocaine', 'cocaine')
-- 						else
-- 							ESX.ShowNotification('Nie ma wystaczającej ilości narkotyku')
-- 							return
-- 						end
-- 					else
-- 						ESX.ShowNotification('Nie ma wystaczającej ilości graczy minimum '..minimumPlayersCount)	
-- 						return
-- 					end
-- 				end
-- 			},
-- 		},
-- 	})

-- 	ox_target:addBoxZone({
-- 		name = "transfer_heroina",
-- 		coords = vec3(395.25, 1.25, 85.0),
-- 		size = vec3(1, 2, 2.0),
-- 		rotation = 330.0,
-- 		options = {
-- 			{
-- 				name = 'transfer_heroina',
-- 				event = 'esx_drugs:transfer_heroina',
-- 				icon = 'fa-solid fa-cannabis',
-- 				label = 'Przerób heroine',
-- 				canInteract = function(entity, distance, coords, name)
-- 					if LocalPlayer.state.IsDead then return false end
-- 					if LocalPlayer.state.IsHandcuffed then return false end
-- 					if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' or ESX.PlayerData.job.name == 'ambulance' or ESX.PlayerData.job.name == 'offpolice' or ESX.PlayerData.job.name == 'offsheriff' or ESX.PlayerData.job.name == 'offambulance' then return false end
-- 					if ESX.PlayerData.job.name ~= "org19" then return false end

-- 					return true
-- 				end,
-- 				onSelect = function ()
-- 					if GlobalState.Counter['players'] >= minimumPlayersCount then
-- 						local count = ox_inventory:Search('count', 'heroina')

-- 						if count >= 5 then
-- 							ProcessNaroctic('heroina', 'heroina')
-- 						else
-- 							ESX.ShowNotification('Nie ma wystaczającej ilości narkotyku')
-- 							return
-- 						end
-- 					else
-- 						ESX.ShowNotification('Nie ma wystaczającej ilości graczy minimum '..minimumPlayersCount)	
-- 						return
-- 					end
-- 				end
-- 			},
-- 		},
-- 	})
-- end)

RegisterNetEvent('esx_drugs:drugEffect', function (narcotic)
	if narcotic == 'codeine' then
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		ClearPedTasksImmediately(cachePed)
		SetTimecycleModifier("spectator5")
		SetPedMovementClipset(cachePed, "MOVE_M@QUICK", true)
		AnimpostfxPlay("DrugsMichaelAliensFight", 10000001, true)
		SetPedMotionBlur(cachePed, true)
		SetPedIsDrunk(cachePed, true)
		DoScreenFadeIn(1000)
		Citizen.Wait(1 * 60000)
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		DoScreenFadeIn(1000)
		ClearTimecycleModifier()
		ShakeGameplayCam("DRUNK_SHAKE", 0.0)
		AnimpostfxStopAll()
		ResetPedMovementClipset(cachePed)
		ResetScenarioTypesEnabled()
	elseif narcotic == 'bagniak' then
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		ClearPedTasksImmediately(cachePed)
		SetTimecycleModifier("spectator7")
		SetPedMovementClipset(cachePed, "MOVE_M@QUICK", true)
		AnimpostfxPlay("ChopVision", 10000001, true)
		ShakeGameplayCam("DRUNK_SHAKE", 1.0)
		SetPedMotionBlur(cachePed, true)
		DoScreenFadeIn(1000)
		Citizen.Wait(1 * 60000)
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		DoScreenFadeIn(1000)
		ClearTimecycleModifier()
		ShakeGameplayCam("DRUNK_SHAKE", 0.0)
		AnimpostfxStopAll()
		ResetPedMovementClipset(cachePed)
		ResetScenarioTypesEnabled()
	elseif narcotic == 'meth' then
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		ClearPedTasksImmediately(cachePed)
		SetTimecycleModifier("spectator8")
		AnimpostfxPlay("HeistCelebPass", 10000001, true)
		SetPedMovementClipset(cachePed, "MOVE_M@QUICK", true)
		SetPedMotionBlur(cachePed, true)
		SetPedIsDrunk(cachePed, true)
		DoScreenFadeIn(1000)
		Citizen.Wait(1 * 60000)
		DoScreenFadeOut(1000)
		Citizen.Wait(1000)
		DoScreenFadeIn(1000)
		AnimpostfxStopAll()
		ResetPedMovementClipset(cachePed)
		ClearTimecycleModifier()
		ResetScenarioTypesEnabled()
	end
end)