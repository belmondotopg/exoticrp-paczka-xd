LocalPlayer.state:set('streakGym', 0, true)

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords or vector3(0, 0, 0)

local ox_target = exports.ox_target

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('coords', function(coords)
    cacheCoords = coords or vector3(0, 0, 0)
end)

local currentGymName = 'beach_gym'
local currentGymEquipmentUpgraded = 0

local function getGymNameForCurrentPosition()
    if not cacheCoords then
        return currentGymName
    end
    
    for _, v in ipairs(Config.Locations) do
        local dist = #(cacheCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
        if dist < 3.0 then
            return v.gym_name or currentGymName
        end
    end
    return currentGymName
end

local playerStats = { stamina = 0, strength = 0, lung = 0 }
local supplementBoosts = { stamina = 1.0, strength = 1.0, lung = 1.0 }

local function applyPlayerStats()
    if not playerStats then return end
    
    if playerStats.stamina then
        local staminaValue = math.floor(playerStats.stamina * 1.0)
        StatSetInt(`MP0_STAMINA`, staminaValue, true)
        StatSetInt(`MP1_STAMINA`, staminaValue, true)
    end
    
    if playerStats.strength then
        local strengthValue = math.floor(playerStats.strength * 1.0)
        StatSetInt(`MP0_STRENGTH`, strengthValue, true)
        StatSetInt(`MP1_STRENGTH`, strengthValue, true)
    end
    
    if playerStats.lung then
        local lungValue = math.floor(playerStats.lung * 1.0)
        StatSetInt(`MP0_LUNG_CAPACITY`, lungValue, true)
        StatSetInt(`MP1_LUNG_CAPACITY`, lungValue, true)
    end
end

local function loadPlayerStats()
    lib.callback('esx_gym/getPlayerStats', false, function(stats)
        if stats then
            playerStats = stats
            Wait(1000)
            applyPlayerStats()
        end
    end)
end

local function updatePlayerSkill(skillType, amount)
    lib.callback('esx_gym/updatePlayerSkill', false, function(success)
        if success then
            lib.callback('esx_gym/getPlayerStats', false, function(stats)
                if stats then
                    playerStats = stats
                    
                    local statNames = {
                        stamina = "Kondycja",
                        strength = "Siła",
                        lung = "Płuca"
                    }
                    
                    ESX.ShowNotification("Umiejętność " .. (statNames[skillType] or skillType) .. " zwiększona o " .. amount .. "! (Aktualnie: " .. playerStats[skillType] .. "/100)")
                    
                    applyPlayerStats()
                    
                    SendNUIMessage({
                        action = 'setPlayerStats',
                        data = playerStats
                    })
                end
            end)
        end
    end, skillType, amount)
end

local function loadSupplementBoosts()
    lib.callback('esx_gym/getSupplementBoosts', false, function(boosts)
        if boosts then
            supplementBoosts = boosts
        end
    end)
end

function startStamina()
    local gymName = getGymNameForCurrentPosition()
    lib.callback('esx_gym/hasValidPass', false, function(hasValidPass)
        if not hasValidPass then
            ESX.ShowNotification("Musisz mieć aktywne członkostwo, aby ćwiczyć!")
            return
        end
        
        local duration = Config.StaminaTime
        if currentGymEquipmentUpgraded == 1 then
            duration = duration * Config.Upgrades.equipment.speedMultiplier
        end
        
        local boostMultiplier = supplementBoosts.stamina
        local skillGain = math.ceil(1 * boostMultiplier)
        
        ESX.ShowNotification("Rozpoczynasz ćwiczenie wytrzymałości...")
        
        if exports.esx_hud:progressBar({
            duration = duration,
            label = "Ćwiczysz kondycje...",
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'move_m@jog@',
                clip = 'run',
                flag = 1
            },
            prop = {},
        }) 
        then
            updatePlayerSkill("stamina", skillGain)
        else
            ESX.ShowNotification("Ćwiczenie przerwane!")
        end
    end, gymName)
end

function startLungh()
    local gymName = getGymNameForCurrentPosition()
    lib.callback('esx_gym/hasValidPass', false, function(hasValidPass)
        if not hasValidPass then
            ESX.ShowNotification("Musisz mieć aktywne członkostwo, aby ćwiczyć!")
            return
        end
        
        local duration = Config.LunghTime
        if currentGymEquipmentUpgraded == 1 then
            duration = duration * Config.Upgrades.equipment.speedMultiplier
        end
        
        local boostMultiplier = supplementBoosts.lung
        local skillGain = math.ceil(1 * boostMultiplier)
        
        ESX.ShowNotification("Rozpoczynasz ćwiczenie płuc...")
        
        if exports.esx_hud:progressBar({
            duration = duration,
            label = "Ćwiczysz płuca...",
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = 'amb@world_human_sit_ups@male@base',
                clip = 'base',
                flag = 49
            },
            prop = {},
        }) 
        then
            updatePlayerSkill("lung", skillGain)
        else
            ESX.ShowNotification("Ćwiczenie przerwane!")
        end
    end, gymName)
end

function startStrength()
    local gymName = getGymNameForCurrentPosition()
    lib.callback('esx_gym/hasValidPass', false, function(hasValidPass)
        if not hasValidPass then
            ESX.ShowNotification("Musisz mieć aktywne członkostwo, aby ćwiczyć!")
            return
        end
        
        local duration = Config.StrengthTime
        if currentGymEquipmentUpgraded == 1 then
            duration = duration * Config.Upgrades.equipment.speedMultiplier
        end
        
        local boostMultiplier = supplementBoosts.strength
        local skillGain = math.ceil(1 * boostMultiplier)
        
        ESX.ShowNotification("Rozpoczynasz ćwiczenie siły...")
        
        if exports.esx_hud:progressBar({
            duration = duration,
            label = "Ćwiczysz siłę...",
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false,
            },
            anim = {
                dict = "amb@world_human_muscle_free_weights@male@barbell@base",
                clip = "base",
                flag = 49
            },
            prop = {
                model = "prop_barbell_02",
                pos = vec3(0.04, -0.12, 0.30),
                rot = vec3(-20.0, -60.0, -90.0)
            },
        }) 
        then
            updatePlayerSkill("strength", skillGain)
        else
            ESX.ShowNotification("Ćwiczenie przerwane!")
        end
    end, gymName)
end

function CheckPosition()
    if not cacheCoords then
        return
    end
    
    for k, v in ipairs(Config.Locations) do
        local dist = #(cacheCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
        local exerciseGymName = v.gym_name or currentGymName
        
        lib.callback('esx_gym/hasValidPass', false, function(hasPass)
            if hasPass or LocalPlayer.state.streakGym > 0 then
                if dist < 2.0 then
                    SetEntityHeading(cachePed, v.heading)
                    SetEntityCoords(cachePed, v.coords.x, v.coords.y, v.coords.z - 0.95)
                    FreezeEntityPosition(cachePed, true)

                    if hasPass or LocalPlayer.state.streakGym < 21 then
                        ox_target:removeModel("apa_p_apdlc_treadmill_s", "Zacznij ćwiczyć")
                        ox_target:removeModel("p_yoga_mat_03_s", "Zacznij ćwiczyć")
                        ox_target:removeModel("prop_weight_squat", "Zacznij ćwiczyć")
                       
                        if k <= 7 then
                            startStamina()
                        elseif k > 7 and k <= 13 then
                            startLungh()
                        elseif k > 13 and k <= 17 then
                            startStrength()
                        end
                    else
                        ESX.ShowNotification('Zrobiłeś już zbyt dużo ćwiczeń!')
                    end

                    FreezeEntityPosition(cachePed, false)
                    ClearPedTasksImmediately(cachePed)
                end
            else
                ESX.ShowNotification('Potrzebujesz przepustki do tej siłowni!')
            end
        end, exerciseGymName)
    end
end

local function canInteractWithEquipment(distance, maxDistance)
    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then
        return false
    end
    if distance > maxDistance then
        return false
    end
    local gymName = getGymNameForCurrentPosition()
    local hasPass = lib.callback.await('esx_gym/hasValidPass', false, gymName)
    return hasPass or LocalPlayer.state.streakGym > 0
end

function AddTargets()
    ox_target:addModel("apa_p_apdlc_treadmill_s", {
        {
            icon = "fa-solid fa-dumbbell",
            label = "Zacznij ćwiczyć",
            canInteract = function(entity, distance)
                return canInteractWithEquipment(distance, 1.5)
            end,
            onSelect = CheckPosition,
            distance = 2.0
        }
    })

    ox_target:addModel("p_yoga_mat_03_s", {
        {
            icon = "fa-solid fa-dumbbell",
            label = "Zacznij ćwiczyć",
            canInteract = function(entity, distance)
                return canInteractWithEquipment(distance, 1.0)
            end,
            onSelect = CheckPosition,
            distance = 1.0
        }
    })

    ox_target:addModel("prop_weight_squat", {
        {
            icon = "fa-solid fa-dumbbell",
            label = "Zacznij ćwiczyć",
            canInteract = function(entity, distance)
                return canInteractWithEquipment(distance, 1.5)
            end,
            onSelect = CheckPosition,
            distance = 2.0
        }
    })
end

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel("a_m_y_musclbeac_02")

		Citizen.Wait(1000)

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)
	
		TaskStartScenarioInPlace(entity, point.anim, 0, true)
	
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

        currentGymName = point.gym_name

        ox_target:addLocalEntity(entity, {
            {
                icon = 'fa-solid fa-credit-card',
                label = 'Rozmawiaj',
                canInteract = function ()
                    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then return false end

                    return true
                end,
                onSelect = function()
                    currentGymName = point.gym_name
                    
                    lib.callback('esx_gym/company/getGymAccess', false, function(accessData)
                        if not accessData then
                            ESX.ShowNotification('Błąd podczas ładowania danych siłowni!')
                            return
                        end
                        
                        currentGymEquipmentUpgraded = accessData.gymData.equipment_upgraded or 0
                        
                        local isOwned = accessData.isOwned
                        local hasAccess = accessData.hasAccess
                        local accessLevel = accessData.accessLevel
                        
                        if not isOwned then
                            SendNUIMessage({
                                action = 'setVisible',
                                data = true,
                            })
                            
                            SendNUIMessage({
                                action = 'showGymPurchase',
                                data = {
                                    id = accessData.gymData.id or 0,
                                    name = accessData.gymData.name or '',
                                    label = accessData.gymData.label or accessData.gymData.name or '',
                                    price = accessData.gymData.price or 0,
                                    owner_name = '',
                                    owner_identifier = '',
                                    avaliable = accessData.gymData.avaliable or 1,
                                    active = 0
                                }
                            })
                            
                            SetNuiFocus(true, true)
                        else
                            lib.callback('esx_gym/getPlayerStats', false, function(stats)
                                SendNUIMessage({
                                    action = 'setVisible',
                                    data = true,
                                })

                                SendNUIMessage({
                                    action = 'setData',
                                    data = {
                                        name = accessData.gymData.name or '',
                                        label = accessData.gymData.label or accessData.gymData.name or '',
                                        price = accessData.gymData.price or 0,
                                        owner_name = accessData.gymData.owner_name or '',
                                        owner_identifier = accessData.gymData.owner_identifier or '',
                                        avaliable = accessData.gymData.avaliable or 0,
                                        active = accessData.gymData.active or 0,
                                        stock = accessData.gymData.stock or '{}',
                                        supplement_prices = accessData.gymData.supplement_prices or '{}',
                                        isowner = accessLevel == 'owner',
                                        isworker = hasAccess,
                                        accessLevel = accessLevel,
                                        equipment_upgraded = accessData.gymData.equipment_upgraded
                                    }
                                })
                            
                                SendNUIMessage({
                                    action = 'setPlayerStats',
                                    data = stats or { stamina = 0, strength = 0, lung = 0 }
                                })
                                
                                lib.callback('esx_gym/getMembershipData', false, function(membershipData)
                                    if membershipData then
                                        SendNUIMessage({
                                            action = 'setMembershipData',
                                            data = membershipData
                                        })
                                    end
                                end, point.gym_name)

                                SetNuiFocus(true, true)
                            end)
                        end
                    end, point.gym_name)
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

local localPedsSpawn = {
    {coords = vec3(-1195.1005, -1577.4619, 4.6037), heading = 124.0796, anim = 'WORLD_HUMAN_MUSCLE_FLEX', gym_name = 'beach_gym'},
}

Citizen.CreateThread(function ()
    AddTargets()

	for k, v in pairs(localPedsSpawn) do
		lib.points.new({
			id = 201 + k,
			coords = v.coords,
			distance = 15,
			onEnter = onEnter,
			onExit = onExit,
			heading = v.heading,
			anim = v.anim,
            gym_name = v.gym_name,
		})
	end
end)

RegisterNetEvent('esx_gym/showSupplements', function(data)
    SendNUIMessage({
        action = 'showSupplements',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/updateSupplementShop', function(data)
    SendNUIMessage({
        action = 'updateSupplementShop',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/showPriceManagement', function(data)
    SendNUIMessage({
        action = 'showPriceManagement',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/showUpgradeManagement', function(data)
    SendNUIMessage({
        action = 'showUpgradeManagement',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/refreshGymData', function(gymName)
    lib.callback('esx_gym/company/getData', false, function(gymData)
        if gymData then
            SendNUIMessage({
                action = 'updateGymData',
                data = gymData,
            })
        end
    end, gymName)
end)

RegisterNetEvent('esx_gym/showInventory', function(data)
    SendNUIMessage({
        action = 'showInventory',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/showMembershipPriceManagement', function(data)
    SendNUIMessage({
        action = 'showMembershipPriceManagement',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/showCompanyAccount', function(data)
    SendNUIMessage({
        action = 'showCompanyAccount',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/showWorkerHire', function(data)
    SendNUIMessage({
        action = 'showWorkerHire',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/showWorkerManagement', function(data)
    SendNUIMessage({
        action = 'showWorkerManagement',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/startDeliveryMission', function(gymName)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false,
    })
    
    Mission:Start(gymName)
end)

RegisterNetEvent('esx_gym/purchaseGymSuccess', function(success)
    SendNUIMessage({
        action = 'purchaseGymSuccess',
        data = success
    })
end)

RegisterNetEvent('esx_gym/updateGymData', function(gymData)
    SendNUIMessage({
        action = 'setData',
        data = {
            name = gymData.name or '',
            label = gymData.label or gymData.name or '',
            price = gymData.price or 0,
            owner_name = gymData.owner_name or '',
            owner_identifier = gymData.owner_identifier or '',
            avaliable = gymData.avaliable or 0,
            active = gymData.active or 0,
            stock = gymData.stock or '{}',
            supplement_prices = gymData.supplement_prices or '{}',
            isowner = gymData.owner_identifier == ESX.PlayerData.identifier,
            equipment_upgraded = gymData.equipment_upgraded or 0
        }
    })
end)

RegisterNUICallback('esx_gym/purchaseGym', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false,
    })
    
    TriggerServerEvent('esx_gym/purchaseGym', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/closeNui', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false,
    })
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/gymAction', function(data, cb)
    local action = data.action
    local gymName = data.gymName
    
    if action == 'viewMembership' then
        lib.callback('esx_gym/getMembershipData', false, function(membershipData)
            if membershipData then
                SendNUIMessage({
                    action = 'setMembershipData',
                    data = membershipData
                })
            end
        end, gymName)
        
        lib.callback('esx_gym/company/getData', false, function(gymData)
            if gymData then
                currentGymEquipmentUpgraded = gymData.equipment_upgraded or 0
            end
        end, gymName)
        
    elseif action == 'getPlayerStats' then
        lib.callback('esx_gym/getPlayerStats', false, function(stats)
            if stats then
                SendNUIMessage({
                    action = 'setPlayerStats',
                    data = stats
                })
            end
        end)
        
    elseif action == 'upgradeEquipment' then
        lib.callback('esx_gym/gymAction', false, function(success)
            if success then
                ESX.ShowNotification('Ulepszenie sprzętu zostało zakupione!')
                lib.callback('esx_gym/company/getData', false, function(gymData)
                    if gymData then
                        currentGymEquipmentUpgraded = gymData.equipment_upgraded or 0
                        
                        SendNUIMessage({
                            action = 'updateGymData',
                            data = {
                                name = gymData.name or '',
                                label = gymData.label or gymData.name or '',
                                price = gymData.price or 0,
                                owner_name = gymData.owner_name or '',
                                owner_identifier = gymData.owner_identifier or '',
                                avaliable = gymData.avaliable or 0,
                                active = gymData.active or 0,
                                stock = gymData.stock or '{}',
                                supplement_prices = gymData.supplement_prices or '{}',
                                isowner = gymData.owner_identifier == ESX.PlayerData.identifier,
                                equipment_upgraded = gymData.equipment_upgraded,
                                isworker = false,
                                accessLevel = 'owner'
                            }
                        })
                    end
                end, gymName)
            else
                ESX.ShowNotification('Nie udało się zakupić ulepszenia!')
            end
        end, 'upgradeEquipment', gymName)
        
    elseif action == 'refreshGymData' then
        lib.callback('esx_gym/company/getData', false, function(gymData)
            if gymData then
                currentGymEquipmentUpgraded = gymData.equipment_upgraded or 0
                
                SendNUIMessage({
                    action = 'refreshGymData',
                    data = {
                        name = gymData.name or '',
                        label = gymData.label or gymData.name or '',
                        price = gymData.price or 0,
                        owner_name = gymData.owner_name or '',
                        owner_identifier = gymData.owner_identifier or '',
                        avaliable = gymData.avaliable or 0,
                        active = gymData.active or 0,
                        stock = gymData.stock or '{}',
                        supplement_prices = gymData.supplement_prices or '{}',
                                isowner = gymData.owner_identifier == ESX.PlayerData.identifier,
                                equipment_upgraded = gymData.equipment_upgraded
                    }
                })
            end
        end, gymName)
        
    elseif action == 'viewUpgrades' then
        TriggerServerEvent('esx_gym/gymAction', { action = 'viewUpgrades', gymName = gymName })
        
    elseif action == 'managePrices' then
        TriggerServerEvent('esx_gym/gymAction', { action = 'managePrices', gymName = gymName })
        
    elseif action == 'restock' then
        lib.callback('esx_gym/company/getData', false, function(gymData)
            if gymData then
                local stock = json.decode(gymData.stock or '{"kreatyna":0,"l_karnityna":0,"bialko":0}')
                
                SendNUIMessage({
                    action = 'showRestock',
                    data = {
                        gymName = gymName,
                        stock = stock
                    }
                })
            end
        end, gymName)
        
    elseif action == 'inventory' then
        lib.callback('esx_gym/company/getData', false, function(gymData)
            if gymData then
                local stock = json.decode(gymData.stock or '{"kreatyna":0,"l_karnityna":0,"bialko":0}')
                
                SendNUIMessage({
                    action = 'showInventory',
                    data = {
                        gymName = gymName,
                        stock = stock
                    }
                })
            end
        end, gymName)
        
    else
        TriggerServerEvent('esx_gym/gymAction', data)
    end
    
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/purchaseSupplement', function(data, cb)
    TriggerServerEvent('esx_gym/purchaseSupplement', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/updateSupplementPrices', function(data, cb)
    TriggerServerEvent('esx_gym/updateSupplementPrices', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/updatePassPrices', function(data, cb)
    TriggerServerEvent('esx_gym/updatePassPrices', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/buyAllSupplies', function(data, cb)
    TriggerServerEvent('esx_gym/buyAllSupplies', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/buySelectedSupplies', function(data, cb)
    TriggerServerEvent('esx_gym/buySelectedSupplies', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/startDelivery', function(data, cb)
    TriggerServerEvent('esx_gym/startDelivery', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/hireWorker', function(data, cb)
    TriggerServerEvent('esx_gym/hireWorker', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/fireWorker', function(data, cb)
    TriggerServerEvent('esx_gym/fireWorker', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/promoteWorker', function(data, cb)
    TriggerServerEvent('esx_gym/promoteWorker', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/demoteWorker', function(data, cb)
    TriggerServerEvent('esx_gym/demoteWorker', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/purchasePass', function(data, cb)
    TriggerServerEvent('esx_gym/purchaseMembership', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/withdrawCompanyAccount', function(data, cb)
    TriggerServerEvent('esx_gym/withdrawCompanyAccount', data)
    cb({status = 'ok'})
end)

RegisterNUICallback('esx_gym/getPlayerMoney', function(data, cb)
    lib.callback('esx_gym/getPlayerMoney', false, function(money)
        cb(money or 0)
    end)
end)

RegisterNUICallback('esx_gym/getDeliveryPrices', function(data, cb)
    lib.callback('esx_gym/getDeliveryPrices', false, function(prices)
        cb(prices or { kreatyna = 100, l_karnityna = 150, bialko = 200 })
    end, data.gymName)
end)


RegisterNetEvent('esx_gym/showBuyPass', function(data)
    SendNUIMessage({
        action = 'showBuyPass',
        data = data,
    })
end)

RegisterNetEvent('esx_gym/refreshMembership', function(gymName)
    lib.callback('esx_gym/getMembershipData', false, function(membershipData)
        if membershipData then
            SendNUIMessage({
                action = 'setMembershipData',
                data = membershipData
            })
        end
    end, gymName)
end)

local function statsExport()
    lib.callback('esx_gym/getPlayerStats', false, function(stats)
        if stats then
            playerStats = stats
            
            SendNUIMessage({
                action = 'setPlayerStats',
                data = stats
            })
            
            SendNUIMessage({
                action = 'setVisible',
                data = true,
            })
            
            SendNUIMessage({
                action = 'showStatsOnly',
                data = {
                    stats = stats,
                    playerName = ESX.PlayerData.firstName .. ' ' .. ESX.PlayerData.lastName
                }
            })
            
            SetNuiFocus(true, true)
        else
            ESX.ShowNotification('Błąd podczas ładowania statystyk!')
        end
    end)
end

exports('statsExport', statsExport)

local function membershipExport()
    local gymName = 'beach_gym'
    
    lib.callback('esx_gym/getMembershipData', false, function(membershipData)
        if membershipData then
            SendNUIMessage({
                action = 'setMembershipData',
                data = membershipData
            })
            
            SendNUIMessage({
                action = 'setVisible',
                data = true,
            })
            
            SendNUIMessage({
                action = 'showMembershipOnly',
                data = {
                    membership = membershipData,
                    playerName = ESX.PlayerData.firstName .. ' ' .. ESX.PlayerData.lastName
                }
            })
            
            SetNuiFocus(true, true)
        else
            ESX.ShowNotification('Błąd podczas ładowania danych członkostwa!')
        end
    end, gymName)
end

exports('membershipExport', membershipExport)

CreateThread(function()
    while not ESX do
        Wait(100)
    end
    
    while not ESX.PlayerData or not ESX.PlayerData.identifier do
        Wait(100)
    end
    
    Wait(2000)
    loadPlayerStats()
    loadSupplementBoosts()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        loadSupplementBoosts()
    end
end)

CreateThread(function()
    while true do
        Wait(30000)
        if playerStats and (playerStats.stamina > 0 or playerStats.strength > 0 or playerStats.lung > 0) then
            applyPlayerStats()
        end
    end
end)