local ESX = ESX
local Citizen = Citizen
local ox_target = exports.ox_target
local Licenses          = {}
local LocalPlayer = LocalPlayer

RegisterNetEvent('esx_dmvschool:loadLicenses')
AddEventHandler('esx_dmvschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`s_m_m_strpreach_01`)

		Citizen.Wait(1000)

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z, point.heading, false, true)
	
		TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_SEAT_WALL_TABLET', 0, true)
	
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

		ox_target:addLocalEntity(entity, {
			{
				icon = 'fa fa-laptop',
				label = point.label,
				canInteract = function ()
					if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then return false end

					local ownedLicenses = {}

					for i=1, #Licenses, 1 do
						ownedLicenses[Licenses[i].type] = true
					end

					return not ownedLicenses['weapon']
				end,
				onSelect = function()
					local ownedLicenses = {}

					for i=1, #Licenses, 1 do
						ownedLicenses[Licenses[i].type] = true
					end
				
					if not ownedLicenses['weapon'] then
						lib.registerContext({
							id = 'drive_school',
							title = 'Ośrodek egzaminacyjny',
							options = {
								{
									title = 'Egzamin na licencję na broń (50.000$)',
									description = 'Odpowiedz na proste pytania, aby móc otrzymać licencję na broń.',
									icon = 'fa-solid fa-gun',
									onSelect = function()
										if not ownedLicenses['weapon'] then
											lib.callback("esx_core:getLicenseTest", false, function(can, notification)
												if can then
													ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
														if haveMoney then
															exports['esx_hud']:startWeaponTest()
														else
															ESX.ShowNotification("Nie masz wystarczająco pieniędzy (50.000$)!")
														end
													end, 'weapon')
												else
													ESX.ShowNotification(notification)
												end
											end)
										end
									end,
								},
							}
						})
				
						lib.showContext('drive_school')
					else
						ESX.ShowNotification('Posiadasz już licencję na broń, nie mam jak ci inaczej pomóc...')
					end
				end,
				distance = 3.0
			}
		})

		point.entity = entity
	end
end
 
local function onExit(point)
	local entity = point.entity

	if not entity then return end

	ox_target:removeLocalEntity(entity, point.label)
	
	if DoesEntityExist(entity) then
		SetEntityAsMissionEntity(entity, false, true)
		DeleteEntity(entity)
	end

	point.entity = nil
end

local peds = {}

Citizen.CreateThread(function ()
    peds[1] = lib.points.new({
        id = 140,
        distance = 15,
		coords = vec3(-1009.0850, -475.7058, 50.6929 - 2.25),
        heading = 217.4110,
		label = 'Zacznij rozmowę',
        onEnter = onEnter,
        onExit = onExit,
    })
end)