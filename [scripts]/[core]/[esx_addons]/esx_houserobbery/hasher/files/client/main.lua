local esx_hud = exports.esx_hud
local ox_target = exports.ox_target
local ox_inventory = exports.ox_inventory

LocalPlayer.state:set('usingHouseRobbery', false, true)
LocalPlayer.state:set("insideHouseRobbery", false, true)

local Mission = {
    tier = 1,
    number = 1,
    targetIds = {},
    work = {
        coords = nil,
        oldCoords = nil,
    },
    robbery = nil,
    blips = {
        house = nil,
    }
}

local selectedItems = {}

local libCache = lib.onCache
local cache = {}

libCache('ped', function(ped)
    cache.ped = ped
end)

libCache('coords', function(coords)
    cache.coords = coords
end)

Citizen.CreateThread(function()
    while not cache.ped do
        cache.ped = PlayerPedId()
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while not cache.coords do
        cache.coords = GetEntityCoords(PlayerPedId())
        Citizen.Wait(500)
    end
end)


local function isNight()
	local hour = GetClockHours()
	return hour > 19 or hour < 5
end

local function EnterHouse(toEnter, houseLevel, x, y, z)
    Mission.work.oldCoords = vec3(x, y, z)

	for k, v in ipairs(Config.Houses[houseLevel]) do
		if v.id == toEnter then
            if Mission.blips.delivery then
                RemoveBlip(Mission.blips.delivery)
                Mission.blips.delivery = nil
            end

			SetEntityCoords(cache.ped, v.x2, v.y2, v.z2, false, false, false, true)
			SetEntityHeading(cache.ped, v.heading)
			
            LocalPlayer.state:set("usingHouseRobbery", true, true)
			LocalPlayer.state:set("insideHouseRobbery", true, true)

			TriggerServerEvent('esx_houserobbery/server/onEnterHouse', toEnter)
			break
		end
	end
end

local function stopMission()
    if not LocalPlayer.state.usingHouseRobbery then 
        return false 
    end
    
    TriggerServerEvent('esx_houserobbery/server/finishMission', Mission)
    LocalPlayer.state:set("usingHouseRobbery", false, true)
    ESX.ShowNotification('No albo uciekłeś, albo właśnie okradłeś niewinnych ludzi, niektórzy tak doszli do bogactwa. Ciekawe co będzie z tobą...')
    
    TriggerServerEvent('esx_houserobbery/server/releaseRobSpot', Mission)

    Mission = {
        tier = 1,
        number = 1,
        targetIds = {},
        work = {
            coords = nil,
            oldCoords = nil,
        },
        robbery = nil,
        blips = {
            house = nil,
        }
    }
end

local function OpenSellMenu()
    lib.callback('esx_houserobbery/server/getItemsToSell', false, function(itemsList)
        if not itemsList or #itemsList == 0 then
            ESX.ShowNotification('Nie posiadasz żadnych przedmiotów do sprzedania', 'error')
            selectedItems = {}
            return
        end

        local options = {}
        
        -- Opcja "Sprzedaj wszystko"
        table.insert(options, {
            title = '💰 Sprzedaj wszystko',
            description = 'Sprzedaj wszystkie przedmioty za ' .. (function()
                local total = 0
                for _, item in ipairs(itemsList) do
                    total = total + item.totalPrice
                end
                return '$' .. total
            end)(),
            icon = 'fa-solid fa-check-double',
            onSelect = function()
                -- Sprzedaj wszystko (stary sposób)
                TriggerServerEvent("esx_houserobbery:SellItems", nil)
                
                Citizen.Wait(1000)
                
                if LocalPlayer.state.usingHouseRobbery then
                    lib.callback('esx_houserobbery/server/hasItemsToSell', false, function(hasItems)
                        if not hasItems then
                            if Mission.blips.seller then
                                RemoveBlip(Mission.blips.seller)
                                Mission.blips.seller = nil
                            end
                            if Mission.blips.house then
                                RemoveBlip(Mission.blips.house)
                                Mission.blips.house = nil
                            end
                            stopMission()
                        else
                            -- Odśwież menu jeśli jeszcze są przedmioty
                            OpenSellMenu()
                        end
                    end)
                end
            end
        })

        table.insert(options, {
            title = '─',
            disabled = true
        })

        -- Opcje dla każdego przedmiotu
        for _, item in ipairs(itemsList) do
            -- Sprawdź czy przedmiot jest zaznaczony
            local isSelected = false
            for _, selected in ipairs(selectedItems) do
                if selected == item.name then
                    isSelected = true
                    break
                end
            end
            
            table.insert(options, {
                title = (isSelected and '✅ ' or '') .. item.label .. ' x' .. item.count,
                description = 'Cena: $' .. item.price .. ' za sztukę | Razem: $' .. item.totalPrice,
                icon = isSelected and 'fa-solid fa-check-circle' or 'fa-solid fa-box',
                iconColor = isSelected and '#22c55e' or nil,
                onSelect = function()
                    -- Dodaj/usuń z listy wybranych
                    local found = false
                    for i, selected in ipairs(selectedItems) do
                        if selected == item.name then
                            table.remove(selectedItems, i)
                            found = true
                            ESX.ShowNotification('Odznaczono: ' .. item.label, 'info')
                            break
                        end
                    end
                    
                    if not found then
                        table.insert(selectedItems, item.name)
                        ESX.ShowNotification('Zaznaczono: ' .. item.label, 'success')
                    end
                    
                    -- Odśwież menu
                    OpenSellMenu()
                end
            })
        end

        -- Przycisk "Sprzedaj wybrane"
        if #selectedItems > 0 then
            table.insert(options, {
                title = '─',
                disabled = true
            })
            
            table.insert(options, {
                title = '✅ Sprzedaj wybrane (' .. #selectedItems .. ')',
                description = 'Sprzedaj tylko zaznaczone przedmioty',
                icon = 'fa-solid fa-shopping-cart',
                onSelect = function()
                    -- Skopiuj tablicę aby uniknąć problemów z zakresem zmiennych
                    local itemsToSell = {}
                    for _, item in ipairs(selectedItems) do
                        table.insert(itemsToSell, item)
                    end
                    
                    if #itemsToSell > 0 then
                        TriggerServerEvent("esx_houserobbery:SellItems", itemsToSell)
                    else
                        ESX.ShowNotification('Nie wybrano żadnych przedmiotów!', 'error')
                    end
                    
                    Citizen.Wait(1000)
                    
                    if LocalPlayer.state.usingHouseRobbery then
                        lib.callback('esx_houserobbery/server/hasItemsToSell', false, function(hasItems)
                            if not hasItems then
                                if Mission.blips.seller then
                                    RemoveBlip(Mission.blips.seller)
                                    Mission.blips.seller = nil
                                end
                                if Mission.blips.house then
                                    RemoveBlip(Mission.blips.house)
                                    Mission.blips.house = nil
                                end
                                stopMission()
                            else
                                -- Odśwież menu jeśli jeszcze są przedmioty
                                selectedItems = {}
                                OpenSellMenu()
                            end
                        end)
                    end
                end
            })
        end

        lib.registerContext({
            id = "houserobbery_sell_menu",
            title = "Sprzedaż przedmiotów",
            options = options
        })

        lib.showContext("houserobbery_sell_menu")
    end)
end

local function ExitHouse(val)
	LocalPlayer.state:set("insideHouseRobbery", false, true)

	TriggerServerEvent('esx_houserobbery/server/onExitHouse')
	
	if val then
        RemoveBlip(Mission.blips.house)
        stopMission()
        return
	end

	if Mission.work.oldCoords == nil then
		SetEntityCoords(cache.ped, vec3(-541.1813, -213.9782, 37.6498))
	else
		SetEntityCoords(cache.ped, Mission.work.oldCoords.x, Mission.work.oldCoords.y, Mission.work.oldCoords.z)
	end

	if LocalPlayer.state.usingHouseRobbery then
		lib.callback('esx_houserobbery/server/hasItemsToSell', false, function(hasItems)
			if not hasItems then
				if Mission.blips.house then
					RemoveBlip(Mission.blips.house)
					Mission.blips.house = nil
				end
				stopMission()
			else
				Mission.blips.seller = AddBlipForCoord(Config.Seller["Coords"][1], Config.Seller["Coords"][2], Config.Seller["Coords"][3])

				SetBlipSprite(Mission.blips.seller, 304)
				SetBlipDisplay(Mission.blips.seller, 4)
				SetBlipScale(Mission.blips.seller, 0.7)
				SetBlipColour(Mission.blips.seller, 17)
				SetBlipAsShortRange(Mission.blips.seller, true)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentString('Kupiec')
				EndTextCommandSetBlipName(Mission.blips.seller)
				SetBlipRoute(Mission.blips.seller, true)

				ESX.ShowNotification("Dobra robota! Na GPS'ie oznaczyłem lokalizacje kupca u którego możesz sprzedać skradzione przedmioty")

				Wait(90000)

				RemoveBlip(Mission.blips.seller)
			end
		end)
	end

	Mission.work.oldCoords = nil
end

RegisterNetEvent('esx_houserobbery/client/stopMission', stopMission)

AddEventHandler('esx:onPlayerDeath', stopMission)

RegisterNetEvent('esx_houserobbery/client/startMission', function (missionTier)
    Mission.tier = missionTier
    
    lib.callback('esx_houserobbery/server/getFreeRobSpot', false, function (randomHouse, tier, randomNumber)
        if not randomHouse or not randomNumber then 
            stopMission()
            return
        end

        Mission.number = randomNumber
        Mission.robbery = randomHouse

        Mission.blips.house = AddBlipForCoord(Mission.robbery.xTarget, Mission.robbery.yTarget, Mission.robbery.zTarget)

        SetBlipSprite(Mission.blips.house, 304)
        SetBlipDisplay(Mission.blips.house, 4)
        SetBlipScale(Mission.blips.house, 0.7)
        SetBlipColour(Mission.blips.house, 17)
        SetBlipAsShortRange(Mission.blips.house, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Zlecenie: Mieszkanie do obrabowania')
        EndTextCommandSetBlipName(Mission.blips.house)
        SetBlipRoute(Mission.blips.house, true)

        ESX.ShowNotification('Oznaczyłem ci na GPS mieszkanie do obrabowania, nie daj dupy!')

        TriggerServerEvent('esx_houserobbery/server/addTargets', Mission.robbery, Mission.tier)
    end, Mission.tier)
end)

local function cancelMenu()
    lib.callback('esx_houserobbery/server/getPlayerQueue', false, function(position, totalPlayers)
        position = position or 0
        totalPlayers = totalPlayers or 0

        if position > 0 and position <= Config.MaxWorkingPositions then
            lib.registerContext({
                id = 'cancelMenu',
                title = 'Zlecenia',
                options = {
                    {
                        title = 'Opuść zlecenie',
                        description = 'Po kliknięciu przycisku, przerwiesz wykonywanie zlecenia.',
                        icon = 'fa-solid fa-hourglass-half',
                        onSelect = function()
                            stopMission()
                            TriggerServerEvent('esx_houserobbery/server/removeQueue')
                        end,
                        metadata = {
                            {label = 'Ilość osób w kolejce', value = totalPlayers},
                            {label = 'Twoja pozycja w kolejce', value = position}
                        },
                    },
                }
            })

            lib.showContext('cancelMenu')
        end
    end)
end

local function queueMenu()
    lib.callback('esx_houserobbery/server/getPlayerQueue', false, function(position, totalPlayers)
        lib.callback('esx_houserobbery/server/getSpecialisation', false, function(count, requiredCount, level, maxCount)
            if position == 0 then
                lib.registerContext({
                    id = 'queueMenu',
                    title = 'Zlecenia',
                    options = {
                        {
                            title = 'Dołącz do kolejki zleceń',
                            description = 'Po kliknięciu przycisku, dołączysz do kolejki oczekujących na zlecenie.',
                            icon = 'fa-solid fa-hourglass-half',
                            onSelect = function()
                                TriggerServerEvent('esx_houserobbery/server/joinQueue')
                                lib.hideContext('queueMenu')
                            end,
                            metadata = {
                                {label = 'Ilość osób w kolejce', value = totalPlayers},
                                {label = 'Twój poziom specjalizacji', value = level .. ' / 3'},
                                {label = 'Ilość zleceń do zwiększenia', value = (count >= maxCount) and 'Maksymalny poziom' or (requiredCount - count)}
                            },
                        },
                    }
                })
            else
                lib.registerContext({
                    id = 'queueMenu',
                    title = 'Zlecenia',
                    options = {
                        {
                            title = 'Opuść kolejkę zleceń',
                            description = 'Po kliknięciu przycisku, opuścisz kolejkę oczekujących na zlecenie.',
                            icon = 'fa-solid fa-hourglass-half',
                            onSelect = function()
                                stopMission()
                                TriggerServerEvent('esx_houserobbery/server/removeQueue')
                            end,
                            metadata = {
                                {label = 'Ilość osób w kolejce', value = totalPlayers},
                                {label = 'Twoja pozycja w kolejce', value = position},
                                {label = 'Twój poziom specjalizacji', value = level .. ' / 3'},
                                {label = 'Ilość zleceń do zwiększenia', value = (count >= maxCount) and 'Maksymalny poziom' or (requiredCount - count)}
                            },
                        },
                    }
                })
            end

            lib.showContext('queueMenu')
        end)
    end)
end

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`a_m_m_og_boss_01`)

		Citizen.Wait(1000)

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z, point.heading, false, true)
	
		TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)
	
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

        ox_target:addLocalEntity(entity, {
            {
                icon = 'fa fa-laptop',
                label = point.label,
                canInteract = function()
                    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
                    if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
                    if Config.ForbiddenJobs[ESX.PlayerData.job.name] then return false end

                    return true
                end,
                onSelect = function()
                    if GlobalState.Counter['police'] >= Config.Requirements.Cops then
                        -- if not isNight() then
                        --     ESX.ShowNotification('Jest zbyt jasno, abyśmy w ogóle mieli o czym gadać!')
                        --     return false
                        -- end
                        local count = ox_inventory:Search('count', 'advancedlockpick')
                        if count > 0 then
                            local options = {}

                            options[0] = {
                                title = 'Poziom specjalizacji',
                                icon = 'fa-solid fa-file',
                                onSelect = function()
                                    lib.callback('esx_houserobbery/server/getSpecialisation', false, function(count, requiredCount, level, maxCount)
                                        lib.registerContext({
                                            id = 'Specialisations',
                                            title = 'Poziom specjalizacji',
                                            options = {
                                                {
                                                    title = (count >= maxCount) and 'Ilość wykonanych zleceń' or 'Ilość zleceń do zwiększenia poziomu',
                                                    description = (count >= maxCount) and tostring(count) or (count .. ' / ' .. requiredCount),
                                                    icon = 'fa-solid fa-list-check',
                                                },
                                                {
                                                    title = 'Poziom specjalizacji',
                                                    description = level .. ' / 3',
                                                    icon = 'fa-solid fa-building',
                                                },
                                                {
                                                    title = 'Zwiększ poziom',
                                                    description = (level >= 3) and
                                                        'Osiągnąłeś na ten moment maksymalny poziom specjalizacji!' or
                                                        'Wykonuj zlecenia i zwiększaj przy użyciu tego przycisku poziom specjalizacji, aby zdobywać bardziej wartościowe łupy!',
                                                    icon = 'fa-solid fa-turn-up',
                                                    onSelect = function()
                                                        if count >= requiredCount and level < 3 then
                                                            TriggerServerEvent('esx_houserobbery/server/upgradeLevel')
                                                            Citizen.Wait(500)
                                                            lib.callback('esx_houserobbery/server/getSpecialisation', false, function(newCount, newRequiredCount, newLevel, newMaxCount)
                                                                lib.hideContext('Specialisations')
                                                            end)
                                                        elseif level >= 3 then
                                                            ESX.ShowNotification('Osiągnąłeś już maksymalny poziom specjalizacji!')
                                                        else
                                                            ESX.ShowNotification('Musisz jeszcze wykonać ' .. (requiredCount - count) .. ' zleceń, aby zwiększyć swój poziom specjalizacji')
                                                        end
                                                    end,
                                                },
                                            },
                                        })
                                        lib.showContext('Specialisations')
                                    end)
                                end
                            }

                            options[1] = {
                                title = 'Zlecenia',
                                icon = 'fa-solid fa-truck-fast',
                                onSelect = function()
                                    lib.callback('esx_houserobbery/server/getPlayerQueue', false, function()
                                        if LocalPlayer.state.usingHouseRobbery then
                                            cancelMenu()
                                        else
                                            queueMenu()
                                        end
                                    end)
                                end
                            }

                            options[2] = {
                                title = 'Wskazówki',
                                icon = 'fa-solid fa-circle-info',
                                onSelect = function()
                                    ESX.ShowNotification('Wysyłam ci GPS, udajesz się na miejsce, włamujesz się do mieszkania następnie zbierasz po cichu wszystkie fanty i uciekasz z miejsca zdarzenia. Zebrane fanty możesz opylić w ukrytych lombardach i nie tylko!')
                                end
                            }

                            lib.registerContext({
                                id = 'manageNPC',
                                title = 'Zarządzaj',
                                options = options
                            })
                            lib.showContext('manageNPC')
                        else
                            ESX.ShowNotification('Zanim cokolwiek pierw weź ze sobą zaawansowany wytrych, bez niego nic nie zrobisz.')
                        end
                    else
                        ESX.ShowNotification('Nie ma odpowiedniej liczby policjantów!')
                    end
                end,
                distance = 2.0
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

Citizen.CreateThread(function ()
    for k, v in pairs(Config.Peds) do
        lib.points.new({
            id = v.id,
            distance = v.distance,
            coords = v.coords,
            heading = v.heading,
            label = v.label,
            isSeller = v.isSeller,
            onEnter = onEnter,
            onExit = onExit,
        })
    end

    local model = lib.requestModel(`a_m_m_og_boss_01`)
    local entity = CreatePed(0, model, Config.Seller["Coords"][1], Config.Seller["Coords"][2], Config.Seller["Coords"][3] - 1.0, 265.8270, false, true)

    TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    ox_target:addBoxZone({
        coords = Config.Seller["Coords"],
        size = vec3(1.2, 0.35, 1.75),
        rotation = 1.0,
        debug = false,
        options = {
            {
                name = "esx_houserobberyseller",
                icon = "fa-solid fa-comments-dollar",
                label = 'Sprzedaj Przedmioty',
                canInteract = function(entity, distance, coords, name)
                    return true
                end,
                onSelect = function()
                    OpenSellMenu()
                end
            }
        }
    })
end)

RegisterNetEvent('esx_houserobbery/client/addTargets', function (robbingHouse, houseLevel, val)
	if val then
		Citizen.CreateThread(function ()
			Mission.targetIds[#Mission.targetIds + 1] = ox_target:addBoxZone({
				coords = vec3(robbingHouse.xTarget, robbingHouse.yTarget, robbingHouse.zTarget),
				size = robbingHouse.size,
				rotation = robbingHouse.rotation,
				debug = false,
				options = {
					{
						name = 'esx_houserobbery/enter'..robbingHouse.id,
						icon = "fa-solid fa-hand",
						label = 'Wejdź',
						canInteract = function(entity, distance, coords, name)
							if LocalPlayer.state.IsDead then return false end
							if LocalPlayer.state.IsHandcuffed then return false end
							if distance > 1.5 then return false end
							if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
							if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' then return true end

							return false
						end,
						onSelect = function ()
							EnterHouse(robbingHouse.id, houseLevel, robbingHouse.x, robbingHouse.y, robbingHouse.z)
						end
					}
				}
			})
		end)
	else
		Citizen.CreateThread(function ()
			for k, v in pairs(Config.HousesItemsLocation[houseLevel]) do
				Mission.targetIds[#Mission.targetIds + 1] = ox_target:addBoxZone({
					coords = vec3(v.x, v.y, v.z),
					size = v.size,
					rotation = v.rotation,
					debug = false,
					options = {
						{
							name = 'esx_houserobbery/robbable'..k,
							icon = "fa-solid fa-hand",
							label = 'Obrabuj',
							canInteract = function(entity, distance, coords, name)
								if LocalPlayer.state.IsDead then return false end
								if LocalPlayer.state.IsHandcuffed then return false end
								if distance > 1.25 then return false end
								if not LocalPlayer.state.insideHouseRobbery then return false end
								if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
                                if Config.ForbiddenJobs[ESX.PlayerData.job.name] then return false end

								return not Config.HousesItemsLocation[houseLevel][k]['isSearched']
							end,
							onSelect = function ()
								local location = Config.HousesItemsLocation[houseLevel][k]

								if not location['isSearched'] then
									location['isSearched'] = true
									if esx_hud:progressBar({
											duration = Config.Requirements.RobbingInteriors,
											label = 'Obrabowywanie',
											useWhileDead = false,
											canCancel = true,
											disable = {
												car = true,
												move = true,
												combat = true,
												mouse = false,
											},
											anim = {
												dict = 'mini@repair',
												clip = 'fixing_a_player',
												flag = 42
											},
											prop = {},
										}) then	
										TriggerServerEvent("esx_houserobbery/server/takeItems", houseLevel, ESX.GetClientKey(LocalPlayer.state.playerIndex))
										ox_target:removeZone(Mission.targetIds[k])
									else
										ESX.ShowNotification('Anulowano.')
									end
								end
							end
						}
					}
				})
			end
		end)
	
		Citizen.CreateThread(function ()
			Mission.targetIds[#Mission.targetIds + 1] = ox_target:addBoxZone({
				coords = vec3(robbingHouse.xTarget, robbingHouse.yTarget, robbingHouse.zTarget),
				size = robbingHouse.size,
				rotation = robbingHouse.rotation,
				debug = false,
				options = {
					{
						name = 'esx_houserobbery/robbable'..robbingHouse.id,
						icon = "fa-solid fa-hand",
						label = 'Włam się',
						canInteract = function(entity, distance, coords, name)
							if LocalPlayer.state.IsDead then return false end
							if LocalPlayer.state.IsHandcuffed then return false end
							if distance > 1.5 then return false end
							if not LocalPlayer.state.usingHouseRobbery then return false end
							if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
							if Config.ForbiddenJobs[ESX.PlayerData.job.name] then return false end
							
							return true
						end,
						onSelect = function ()
                            local count = ox_inventory:Search('count', 'advancedlockpick')

                            if count > 0 then
                                    if esx_hud:progressBar({
                                        duration = Config.Requirements.RobbingDoors,
                                        label = 'Włamywanie',
                                        useWhileDead = false,
                                        canCancel = true,
                                        disable = {
                                            car = true,
                                            move = true,
                                            combat = true,
                                            mouse = false,
                                        },
                                        anim = {
                                            dict = 'mini@safe_cracking',
                                            clip = 'dial_turn_clock_normal',
                                            flag = 42
                                        },
                                        prop = {},
                                    }) then											
                                    if not lib.skillCheck({'medium', 'easy', 'medium'}) then
                                        local random = math.random(1, 10)
            
                                        if random < 5 then
                                            ESX.ShowNotification('W mieszkaniu uruchomił się alarm, policja otrzymała zgłoszenie.')
                                            TriggerServerEvent('qf_mdt/addDispatchAlertSV', cache.coords, 'Włamanie do mieszkania!', 'Zgłoszono włamanie na terenie posiadłości w podanej lokalizacji!', '10-73', 'rgb(156, 85, 37)', '10', 492, 3, 6)
                                        end
            
                                        TriggerServerEvent("esx_houserobbery/server/onRemoveDurability", 'advancedlockpick')
                                    else
                                        ESX.ShowNotification('Włamywanie zakończone powodzeniem.')
                                        TriggerServerEvent("esx_houserobbery/server/onRemoveDurability", 'advancedlockpick')
            
                                        for i = 1, #Config.HousesItemsLocation[houseLevel] do
                                            Config.HousesItemsLocation[houseLevel][i]['isSearched'] = false
                                        end
            
                                        local random = math.random(1, 10)
            
                                        if random < 5 then
                                            ESX.ShowNotification('W mieszkaniu uruchomił się alarm, policja otrzymała zgłoszenie.')
                                            TriggerServerEvent('qf_mdt/addDispatchAlertSV', cache.coords, 'Włamanie do mieszkania!', 'Zgłoszono włamanie na terenie posiadłości w podanej lokalizacji!', '10-73', 'rgb(156, 85, 37)', '10', 492, 3, 6)
                                        end
            
                                        Mission.work.coords = vec3(cache.coords.x, cache.coords.y, cache.coords.z)
            
                                        TriggerServerEvent('esx_core:getNewMessage', cache.serverId, 'Odważnie, okradasz czyjąś własność, a nie sam cie tego nauczyłem...')
            
                                        EnterHouse(robbingHouse.id, houseLevel, robbingHouse.x, robbingHouse.y, robbingHouse.z)
                                    end
                                else
                                    ESX.ShowNotification('Anulowano.')
                                end
                            else
                                ESX.ShowNotification('Zanim cokolwiek pierw weź ze sobą zaawansowany wytrych, bez niego nic nie zrobisz.')
                            end
						end
					}
				}
			})
		end)
	end
end)

Citizen.CreateThread(function ()
	for i = 1, 3 do
		local firstHouse = Config.Houses[i][1]
		if firstHouse then
			ox_target:addBoxZone({
				coords = vec3(firstHouse.x2Target, firstHouse.y2Target, firstHouse.z2Target),
				size = firstHouse.size2,
				rotation = firstHouse.rotation2,
			debug = false,
			options = {
				{
					name = 'esx_houserobbery/quit',
					icon = "fa-solid fa-door-closed",
					label = 'Wyjdź',
					canInteract = function(entity, distance, coords, name)
						if LocalPlayer.state.IsDead then return false end
						if LocalPlayer.state.IsHandcuffed then return false end
						if distance > 1.50 then return false end
						if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
						if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' then return true end
						if LocalPlayer.state.insideHouseRobbery then return true end
	
						return false
					end,
					onSelect = function ()
						if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance' then
							ExitHouse()
						else
							ExitHouse(false)
							Mission.work.coords = nil
						end
					end
				}
			}
		})
		end
	end
end)

Citizen.CreateThread(function()
	local Speeding = 0.0
	while true do
		if LocalPlayer.state.insideHouseRobbery then
			local jobName = ESX.PlayerData.job.name
			if jobName ~= "police" and jobName ~= "ambulance" then
				if GetVehiclePedIsIn(cache.ped, false) == 0 then
					local random = math.random(1, 20)
					if GetEntitySpeed(cache.ped) > 3.0 then
						Speeding = Speeding + 0.1
					end
					
					if random < 5 and Speeding > 60 then
						ESX.ShowNotification('Robisz zbyt duży hałas, uważaj na psiarskie!')
						TriggerServerEvent('qf_mdt/addDispatchAlertSV', Mission.work.coords, 'Włamanie do mieszkania!', 'Zgłoszono włamanie na terenie posiadłości w podanej lokalizacji!', '10-73', 'rgb(156, 85, 37)', '10', 492, 3, 6)
						Speeding = 0.0
					end
				end
			else
				Citizen.Wait(1000)
			end
		else
			Citizen.Wait(1000)
		end
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_houserobbery/client/removeTargets', function ()
	for i = 1, #Mission.targetIds do
		ox_target:removeZone(Mission.targetIds[i])
	end
	
	Mission.targetIds = {}
end)