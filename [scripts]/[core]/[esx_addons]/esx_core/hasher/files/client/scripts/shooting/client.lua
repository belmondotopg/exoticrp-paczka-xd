LocalPlayer.state:set('Crosshair', false, true)

local GetFollowVehicleCamViewMode = GetFollowVehicleCamViewMode
local IsControlPressed = IsControlPressed
local SetFollowVehicleCamViewMode = SetFollowVehicleCamViewMode
local SetCamViewModeForContext = SetCamViewModeForContext
local GetSelectedPedWeapon = GetSelectedPedWeapon
local DisableFirstPersonCamThisFrame = DisableFirstPersonCamThisFrame
local IsAimCamActive = IsAimCamActive
local DoesEntityExist = DoesEntityExist
local IsPedShooting = IsPedShooting
local GetFollowPedCamViewMode = GetFollowPedCamViewMode
local GetRandomFloatInRange = GetRandomFloatInRange
local SetGameplayCamRelativePitch = SetGameplayCamRelativePitch
local GetGameplayCamRelativePitch = GetGameplayCamRelativePitch
local ShakeGameplayCam = ShakeGameplayCam

local lastVehAimMode = nil
local lastCamMode = nil
local drugged = false

local libCache = lib.onCache

local cachePed = cache.ped
local cacheWeapon = cache.weapon
local cacheVehicle = cache.vehicle
local cacheCoords = cache.coords

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('weapon', function(weapon)
    cacheWeapon = weapon
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

libCache('coords', function(coords)
    cacheCoords = coords
end)

local function DisableEffects()
	drugged = true
end

local function EnableEffects()
	drugged = false
end

local FirstPersonZones = {
	vec3(-880.6823, 7624.5420, 41.8813),
}

local function IsFirstPersonZone(coords)
	if not coords then return false end
	
	local checkCoords = type(coords) == 'vector3' and coords or vector3(coords.x, coords.y, coords.z)
	
	for i = 1, #FirstPersonZones do
		if #(FirstPersonZones[i] - checkCoords) <= 200.0 then
			return true
		end
	end
	return false
end

CreateThread(function()
	while true do
		local waitTime = 100
		
		if IsAimCamActive() and DoesEntityExist(cachePed) and cacheWeapon then
			waitTime = 0
			
			if cacheWeapon == `WEAPON_FIREEXTINGUISHER` then
				SetPedInfiniteAmmo(cachePed, true, `WEAPON_FIREEXTINGUISHER`)
			elseif IsPedShooting(cachePed) then
				local recoil = Config.Recoils[cacheWeapon]
				if recoil and #recoil > 0 and not drugged then
					local recoilIndex = cacheVehicle and 2 or 1
					local camViewMode = GetFollowPedCamViewMode()
					
					if camViewMode == 4 then
						local totalRecoil = 0
						repeat
							local recoilAmount = GetRandomFloatInRange(0.1, recoil[recoilIndex])
							local currentPitch = GetGameplayCamRelativePitch()
							local speed = recoil[recoilIndex] > 0.1 and 1.2 or 0.333
							SetGameplayCamRelativePitch(currentPitch + recoilAmount, speed)
							totalRecoil = totalRecoil + recoilAmount
							Wait(0)
						until totalRecoil >= recoil[recoilIndex]
					end
				end
				
				if not drugged then
					local effect = Config.Effects[cacheWeapon]
					if effect and #effect > 0 then
						local camViewMode = GetFollowPedCamViewMode()
						local shakeIntensity
						
						if camViewMode == 4 then
							shakeIntensity = cacheVehicle and effect[1] or effect[2]
						else
							shakeIntensity = cacheVehicle and effect[3] or effect[4]
						end
						
						ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', shakeIntensity)
					end
				end
			end
		end
		
		Wait(waitTime)
	end
end)

lib.addKeybind({
    name = 'aiming',
    description = 'Celowanie',
    defaultMapper = 'MOUSE_BUTTON',
    defaultKey = 'MOUSE_RIGHT',
    onPressed = function()
        if LocalPlayer.state.IsDead then
            return
        end

        lastVehAimMode = GetFollowVehicleCamViewMode()
        lastCamMode = GetFollowPedCamViewMode()
        ClearPedTasks(cachePed)

        local lastCrosshairState = nil
        local function toggleCrosshair(state)
            if lastCrosshairState ~= state then
                lastCrosshairState = state
                TriggerEvent('esx_hud:showCrosshair', state)
                LocalPlayer.state:set('Crosshair', state, true)
            end
        end

        while IsPedShooting(cachePed) or IsControlPressed(0, 25) do
            Wait(0)

            if LocalPlayer.state.IsDead then
                return
            end

            if cacheVehicle then
                local speed = GetEntitySpeed(cacheVehicle) * 3.6
                if Config.DriveBySpeedLimit and speed > Config.DriveBySpeedLimit then
                    DisablePlayerFiring(PlayerId(), true)
                end

                SetFollowVehicleCamViewMode(4)
                SetCamViewModeForContext(2, 4)
                SetCamViewModeForContext(3, 4)
            end

            local weapon = GetSelectedPedWeapon(cachePed)
            local weaponGroup = GetWeapontypeGroup(weapon)
            local isAiming = IsControlPressed(0, 25) or IsControlPressed(0, 24) or IsPedShooting(cachePed)
            local hasWeapon = weapon ~= `WEAPON_UNARMED`
            local isNotMelee = weaponGroup ~= `GROUP_MELEE`

            if IsFirstPersonZone(cacheCoords) then
                SetFollowPedCamViewMode(4)
                toggleCrosshair(false)
            elseif cacheVehicle then
                if isAiming and hasWeapon and isNotMelee then
                    toggleCrosshair(true)
                else
                    toggleCrosshair(false)
                end
            else
                if isAiming and weapon == `WEAPON_UNARMED` then
                    SetFollowPedCamViewMode(4)
                    toggleCrosshair(false)
                elseif isAiming and hasWeapon and isNotMelee then
                    DisableFirstPersonCamThisFrame()
                    toggleCrosshair(true)
                else
                    SetFollowPedCamViewMode(lastCamMode)
                    toggleCrosshair(false)
                end
            end
        end

        if IsFirstPersonZone(cacheCoords) then
            if lastCamMode >= 0 and lastCamMode <= 3 then
                SetFollowPedCamViewMode(lastCamMode)
            else
                SetFollowPedCamViewMode(2)
            end
        end

        if lastVehAimMode >= 0 and lastVehAimMode <= 3 then
            SetFollowVehicleCamViewMode(lastVehAimMode)
            SetCamViewModeForContext(2, lastVehAimMode)
            SetCamViewModeForContext(3, lastVehAimMode)
        else
            SetFollowVehicleCamViewMode(2)
            SetCamViewModeForContext(2, 2)
            SetCamViewModeForContext(3, 2)
        end

        toggleCrosshair(false)
    end
})

exports('IsFirstPersonZone', IsFirstPersonZone)
exports('DisableEffectsRecoil', DisableEffects)
exports('EnableEffectsRecoil', EnableEffects)
