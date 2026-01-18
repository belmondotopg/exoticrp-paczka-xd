local ox_target = exports.ox_target
local libCache = lib.onCache
local cachePed = cache.ped

libCache('ped', function(ped)
	cachePed = ped
end)

ox_target:addModel({`v_med_bed1`, `v_med_bed2`}, {
	{
		icon = 'fa-solid fa-bed-pulse',
		label = 'Połóż się',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsHandcuffed then return false end
			if cache.vehicle then return false end

			return true
		end,
		onSelect = function (data)
			Citizen.Wait(1000)
			local BedCoords, BedHeading = GetEntityCoords(data.entity), GetEntityHeading(data.entity)
			lib.requestAnimDict('missfbi1')

			SetEntityCoords(cachePed, BedCoords)
			SetEntityHeading(cachePed, (BedHeading + 180))

			TaskPlayAnim(cachePed, 'missfbi1', 'cpr_pumpchest_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
		end,
		distance = 2.0
    },
})