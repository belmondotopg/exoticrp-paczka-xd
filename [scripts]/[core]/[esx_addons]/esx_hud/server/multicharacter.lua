lib.callback.register('esx_hud/getPlayerInit', function(source, identifiers)
	if not identifiers or #identifiers == 0 then 
		return {} 
	end

	local results = {}

	for _, identifier in ipairs(identifiers) do
		if not identifier or identifier == "" then
			goto continue
		end

		local coords = {x = 0, y = 0, z = 0}
		local jobName = 'Bezrobotny'

		-- Pobierz pozycję z bazy danych
		local success, result = pcall(function()
			return MySQL.single.await('SELECT position, job FROM users WHERE identifier = ?', {identifier})
		end)

		if success and result then
			-- Parsuj pozycję
			if result.position then
				if type(result.position) == "string" then
					local parseSuccess, parsed = pcall(function()
						return json.decode(result.position)
					end)
					
					if parseSuccess and parsed and type(parsed) == "table" then
						if parsed.x and parsed.y and parsed.z then
							coords = {x = parsed.x, y = parsed.y, z = parsed.z}
						elseif #parsed >= 3 then
							coords = {x = parsed[1] or 0, y = parsed[2] or 0, z = parsed[3] or 0}
						end
					end
				elseif type(result.position) == "table" then
					if result.position.x and result.position.y and result.position.z then
						coords = {x = result.position.x, y = result.position.y, z = result.position.z}
					elseif #result.position >= 3 then
						coords = {x = result.position[1] or 0, y = result.position[2] or 0, z = result.position[3] or 0}
					end
				end
			end

			-- Parsuj pracę
			if result.job then
				if type(result.job) == "string" then
					local parseJobSuccess, parsedJob = pcall(function()
						return json.decode(result.job)
					end)
					
					if parseJobSuccess and parsedJob and type(parsedJob) == "table" then
						jobName = parsedJob.label or parsedJob.name or 'Bezrobotny'
					else
						jobName = result.job
					end
				elseif type(result.job) == "table" then
					jobName = result.job.label or result.job.name or 'Bezrobotny'
				end
			end
		end

		-- Sprawdź czy gracz jest online i ma aktualną pracę
		local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
		if xPlayer and xPlayer.job then
			if xPlayer.job.label then
				jobName = xPlayer.job.label
			elseif xPlayer.job.name then
				jobName = xPlayer.job.name
			end
		end

		results[identifier] = {
			coords = coords,
			job = jobName
		}

		::continue::
	end

	return results
end)
