local ox_target = exports.ox_target
local ox_inventory = exports.ox_inventory

local function openStash()
    lib.hideContext('takeItemsMenu')

    local stash = lib.inputDialog("Numer SSN", {
        {type = 'number', label = 'SSN', description = 'Wpisz numer SSN', required = true}
    })

    if stash[1] and stash[1] > 0 then
        if ox_inventory:openInventory("stash", "schowekwiezienny_"..stash[1]) == false then
            lib.callback('esx_police/registerStashBySSN', false, function (isRegistered)
                if isRegistered then
                    ox_inventory:openInventory("stash", "schowekwiezienny_"..stash[1])
                end
            end, stash[1])
        end
    end
end

local function getStashItems()
    lib.callback('esx_police/getItemsStashBySSN', false, function (isReceived)
        if isReceived then 
            ESX.ShowNotification('Odebrano przedmioty!')
        else
            ESX.ShowNotification('Nie masz nic do odebrania!')
        end
    end)
end

local function openTakeItemsMenu()
    if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "sheriff" then return end

    lib.registerContext({
        id = "takeItemsMenu",
        title = "Schowek więzienny",
        options = {
            {
                title = "Schowaj / wyjmij",
                description = "Schowaj / wyjmij przedmioty więźnia",
                icon = 'fa-solid fa-gun',
                onSelect = function ()
                    openStash()
                end
            },
        }
    })

    lib.showContext('takeItemsMenu')
end

local function openGetItemsMenu()
    lib.registerContext({
        id = "getItemsMenu",
        title = "Schowek więzienny",
        options = {
            {
                title = "Skonfiskowane przedmioty",
                description = "Odbierz przedmioty z więzienia",
                icon = 'fa-solid fa-gun',
                onSelect = function ()
                    getStashItems()
                end
            },
        }
    })

    lib.showContext('getItemsMenu')
end

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`s_m_y_cop_01`)
		Citizen.Wait(1000)
		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 0.95, point.heading, false, true)
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
					if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then return false end
					if point.takeItems then
						if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "sheriff" then return false end
					end
					return true
				end,
				onSelect = function()
					if point.takeItems then
						openTakeItemsMenu()
					else
						openGetItemsMenu()
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

local Confiscate = {
	{
		id = 10 + math.random(111, 999),
		distance = 50,
		coords = vec3(-1063.71484375, -798.76495361328, 10.951615333557),
		heading = 131.43,
		label = "Rozmawiaj",
		takeItems = true
	},
	{
		id = 10 + math.random(111, 999),
		distance = 50,
		coords = vec3(-1102.8962402344, -827.33471679688, 19.313316345215),
		heading = 52.9566,
		label = "Rozmawiaj",
		getItems = true
	},
	{
		id = 10 + math.random(111, 999),
		distance = 50,
		coords = vec3(381.45062255859, -1615.2436523438, 24.7027759552),
		heading = 142.43,
		label = "Rozmawiaj",
		takeItems = true
	},
	{
		id = 10 + math.random(111, 999),
		distance = 50,
		coords = vec3(386.67895507812, -1605.5366210938, 29.759468078613),
		heading = 320.9566,
		label = "Rozmawiaj",
		getItems = true
	},
	{
		id = 10 + math.random(111, 999),
		distance = 50,
		coords = vec3(1840.4515380859, 2577.77734375, 46.014392852783),
		heading = 357.9566,
		label = "Rozmawiaj",
		getItems = true
	}
}

Citizen.CreateThread(function()
	for k, v in pairs(Confiscate) do
		lib.points.new({
			id = v.id,
			distance = v.distance,
			coords = v.coords,
			heading = v.heading,
			label = v.label,
			takeItems = v.takeItems or false,
			getItems = v.getItems or false,
			onEnter = onEnter,
			onExit = onExit
		})
	end
end)