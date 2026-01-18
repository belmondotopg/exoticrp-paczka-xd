local fractions = {
    ['police'] = true,
    ['ambulance'] = true,
    ['sheriff'] = true,
}

RegisterNetEvent('esx_hud:updateBodycam', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if fractions[xPlayer.job.name] and (xPlayer.job.onDuty == true) then
            -- Sprawdź, czy gracz ma item bodycam w ekwipunku
            local bodycamCount = exports.ox_inventory:Search(src, 'count', 'bodycam') or 0
            
            if bodycamCount > 0 then
                local data = {
                    job = xPlayer.job.label,
                    jobGrade = xPlayer.job.grade_label,
                    fullName = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'),
                    badge = xPlayer.badge,
                    gopro = false,
                }

                TriggerClientEvent('esx_hud:showBodycam', src, data)
            else
                -- Ukryj bodycam, jeśli gracz nie ma itemu
                TriggerClientEvent('esx_hud:hideBodycam', src)
            end
        else
            TriggerClientEvent('esx_hud:hideBodycam', src)
        end
    end
end)

RegisterNetEvent('esx_hud:updateGoPro', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        local data = {
            job = '',
            jobGrade = '',
            fullName = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'),
            badge = '',
            gopro = true
        }

        TriggerClientEvent('esx_hud:showBodycam', src, data)
    end
end)

RegisterNetEvent('esx_hud:bodycam:start', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if fractions[xPlayer.job.name] and (xPlayer.job.onDuty == true) then
            -- Sprawdź, czy gracz ma item bodycam w ekwipunku
            local bodycamCount = exports.ox_inventory:Search(src, 'count', 'bodycam') or 0
            
            if bodycamCount > 0 then
                local data = {
                    job = xPlayer.job.label,
                    jobGrade = xPlayer.job.grade_label,
                    fullName = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'),
                    badge = xPlayer.badge,
                    gopro = false,
                }

                TriggerClientEvent('esx_hud:showBodycam', src, data)
            else
                -- Ukryj bodycam, jeśli gracz nie ma itemu
                TriggerClientEvent('esx_hud:hideBodycam', src)
            end
        else
            TriggerClientEvent('esx_hud:hideBodycam', src)
        end
    end
end)

RegisterServerEvent('esx:onAddInventoryItem')
AddEventHandler('esx:onAddInventoryItem', function(playerId, item, count)
	if item == 'bodycam' then
		local xPlayer = ESX.GetPlayerFromId(playerId)
		if xPlayer then
			if fractions[xPlayer.job.name] and (xPlayer.job.onDuty == true) then
				local bodycamCount = exports.ox_inventory:Search(playerId, 'count', 'bodycam') or 0
				if bodycamCount > 0 then
					local data = {
						job = xPlayer.job.label,
						jobGrade = xPlayer.job.grade_label,
						fullName = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'),
						badge = xPlayer.badge,
						gopro = false,
					}
					TriggerClientEvent('esx_hud:showBodycam', playerId, data)
				end
			end
		end
	end
end)

RegisterServerEvent('esx:onRemoveInventoryItem')
AddEventHandler('esx:onRemoveInventoryItem', function(playerId, item, count)
	if item == 'gopro' or item == 'bodycam' then
        TriggerClientEvent('esx_hud:hideBodycam', playerId)
	end
end)

-- Automatycznie aktualizuj bodycam przy zmianie pracy lub statusu duty
AddEventHandler('esx:setJob', function(source, job, lastJob)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end
	
	-- Sprawdź, czy gracz ma uprawnioną pracę i jest na duty
	if fractions[job.name] and (job.onDuty == true) then
		local bodycamCount = exports.ox_inventory:Search(source, 'count', 'bodycam') or 0
		if bodycamCount > 0 then
			local data = {
				job = job.label,
				jobGrade = job.grade_label,
				fullName = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'),
				badge = xPlayer.badge,
				gopro = false,
			}
			TriggerClientEvent('esx_hud:showBodycam', source, data)
		else
			TriggerClientEvent('esx_hud:hideBodycam', source)
		end
	else
		-- Ukryj bodycam, jeśli gracz nie ma uprawnionej pracy lub nie jest na duty
		TriggerClientEvent('esx_hud:hideBodycam', source)
	end
end)