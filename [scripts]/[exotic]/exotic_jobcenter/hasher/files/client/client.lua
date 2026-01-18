local ox_target = exports.ox_target

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`s_m_m_highsec_01`)

		Citizen.Wait(1000)

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)
	
		TaskStartScenarioInPlace(entity, point.anim, 0, true)
	
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

		ox_target:addLocalEntity(entity, {
            {
                icon = 'fa-solid fa-chalkboard-user',
                label = point.label,
                canInteract = function ()
                    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead or cache.vehicle then return false end

                    return true
                end,
                onSelect = function()
                    exports.esx_hud:toggleJobCenterVisibility(true, GetJobsWithUpdatedAvailability())
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

Citizen.CreateThread(function ()
	for k, v in pairs(Config.Peds) do
		-- Create blip for Job Center
		-- local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
		-- SetBlipSprite(blip, Config.Blip.sprite)
		-- SetBlipDisplay(blip, Config.Blip.display)
		-- SetBlipScale(blip, Config.Blip.scale)
		-- SetBlipColour(blip, Config.Blip.color)
		-- SetBlipAsShortRange(blip, Config.Blip.shortRange)
		-- BeginTextCommandSetBlipName("STRING")
		-- AddTextComponentString(Config.Blip.name)
		-- EndTextCommandSetBlipName(blip)

		-- Create interaction point
		lib.points.new({
			id = 145 + k,
			coords = v.coords,
			distance = 15,
			onEnter = onEnter,
			onExit = onExit,
			label = v.label,
			heading = v.heading,
			anim = v.anim
		})
	end
end)

local function workApply(data)
	lib.callback('exotic_jobcenter/workApply', false, function(result)
		exports.esx_hud:toggleJobCenterVisibility(false)
    end, data.id)
end

exports('workApply', workApply)

local function setWaypoint(data)
	ESX.ShowNotification('Zaznaczono lokalizacje na GPS!')
	SetNewWaypoint(Config.Waypoints[data.id].x, Config.Waypoints[data.id].y)
end

exports('setWaypoint', setWaypoint)