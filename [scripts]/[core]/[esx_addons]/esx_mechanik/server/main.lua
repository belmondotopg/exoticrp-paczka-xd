local ox_inventory = exports.ox_inventory

local stashes = {
	{
		id = 'mechanik',
		label = 'LSC Mechanik #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = { ["mechanik"] = 1 }
	},
	{
		id = 'ec',
		label = 'Exotic Customs #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = { ["ec"] = 1 }
	}
}

AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
		for i = 1, #stashes do
			local stash = stashes[i]
			ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.groups)
		end
	end
end)

RegisterServerEvent('esx_mechanik:sync:addTargets', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	TriggerClientEvent('esx_mechanik:sync:removeTargets', src)
	if xPlayer.job.name == "mechanik" or xPlayer.job.name == "ec" then
		TriggerClientEvent('esx_mechanik:sync:addTargetsCL', src)
	end
end)

ESX.RegisterServerCallback('vwk/mechanik/getUniforms', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({})
        return
    end
    
    if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "ec" then
        cb({})
        return
    end
    
    local jobName = xPlayer.job.name
    
    MySQL.query('SELECT * FROM fractions_uniforms WHERE job = ?', {jobName}, function(result)
        local uniforms = {}
        
        if not result then
            cb({})
            return
        end
        
        if result and #result > 0 then
            for i=1, #result, 1 do
                if result[i].category and result[i].name then
                    local minGrade = result[i].min_grade or 0
                    if xPlayer.job.grade < minGrade then
                        goto continue
                    end
                    
                    if not uniforms[result[i].category] then
                        uniforms[result[i].category] = {}
                    end
                    
                    local maleData = {}
                    local femaleData = {}
                    
                    if result[i].male and result[i].male ~= '' then
                        local success, decoded = pcall(json.decode, result[i].male)
                        if success and decoded then
                            maleData = decoded
                        end
                    end
                    
                    if result[i].female and result[i].female ~= '' then
                        local success, decoded = pcall(json.decode, result[i].female)
                        if success and decoded then
                            femaleData = decoded
                        end
                    end
                    
                    uniforms[result[i].category][result[i].name] = {
                        male = maleData,
                        female = femaleData,
                        min_grade = minGrade
                    }
                    ::continue::
                end
            end
        end
        
        cb(uniforms)
    end)
end)

ESX.RegisterServerCallback('vwk/mechanik/addUniform', function(source, cb, uniformData)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "offmechanik" and xPlayer.job.name ~= "ec" and xPlayer.job.name ~= "offec" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 7 then
		cb(false)
		return
	end
	
	if not uniformData or not uniformData.name or not uniformData.category then
		cb(false)
		return
	end
	local maleJson = json.encode(uniformData.male or {})
	local femaleJson = json.encode(uniformData.female or {})
	local minGrade = uniformData.min_grade or 0
	
	MySQL.query([[
		CREATE TABLE IF NOT EXISTS fractions_uniforms (
			id INT AUTO_INCREMENT PRIMARY KEY,
			job VARCHAR(50) NOT NULL,
			name VARCHAR(100) NOT NULL,
			category VARCHAR(100) NOT NULL,
			male TEXT,
			female TEXT,
			min_grade INT DEFAULT 0,
			UNIQUE KEY unique_job_name (job, name)
		)
	]], {}, function()
		MySQL.insert('INSERT INTO fractions_uniforms (job, name, category, male, female, min_grade) VALUES (?, ?, ?, ?, ?, ?)',
			{xPlayer.job.name, uniformData.name, uniformData.category, maleJson, femaleJson, minGrade},
			function(id)
				cb(id ~= nil)
			end)
	end)
end)

ESX.RegisterServerCallback('vwk/mechanik/removeUniform', function(source, cb, uniformName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "offmechanik" and xPlayer.job.name ~= "ec" and xPlayer.job.name ~= "offec" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 7 then
		cb(false)
		return
	end
	
	MySQL.query('DELETE FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, uniformName}, function(affected)
		cb(affected.affectedRows > 0)
	end)
end)

ESX.RegisterServerCallback('vwk/mechanik/copyUniform', function(source, cb, sourceName, newName, newCategory)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "offmechanik" and xPlayer.job.name ~= "ec" and xPlayer.job.name ~= "offec" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 7 then
		cb(false)
		return
	end
	
	MySQL.query('SELECT * FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, sourceName}, function(result)
		if result and #result > 0 then
			local uniform = result[1]
			MySQL.query('SELECT id FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, newName}, function(checkResult)
				if checkResult and #checkResult > 0 then
					cb(false)
					return
				end
				
				MySQL.insert('INSERT INTO fractions_uniforms (job, name, category, male, female, min_grade) VALUES (?, ?, ?, ?, ?, ?)',
					{xPlayer.job.name, newName, newCategory or uniform.category, uniform.male, uniform.female, uniform.min_grade or 0},
					function(id)
						cb(id ~= nil)
					end)
			end)
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('vwk/mechanik/setUniformMinGrade', function(source, cb, uniformName, minGrade)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "offmechanik" and xPlayer.job.name ~= "ec" and xPlayer.job.name ~= "offec" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 7 then
		cb(false)
		return
	end
	
	MySQL.update('UPDATE fractions_uniforms SET min_grade = ? WHERE job = ? AND name = ?',
		{minGrade, xPlayer.job.name, uniformName},
		function(affected)
			cb(affected and affected > 0)
		end)
end)

ESX.RegisterServerCallback('vwk/mechanik/renameUniform', function(source, cb, oldName, newName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "offmechanik" and xPlayer.job.name ~= "ec" and xPlayer.job.name ~= "offec" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade <= 7 then
		cb(false)
		return
	end
	
	if not oldName or not newName or newName == '' then
		cb(false)
		return
	end
	
	MySQL.query('SELECT id FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, newName}, function(result)
		if result and #result > 0 then
			cb(false)
			return
		end
		
		MySQL.update('UPDATE fractions_uniforms SET name = ? WHERE job = ? AND name = ?', 
			{newName, xPlayer.job.name, oldName}, 
			function(affected)
				cb(affected and affected > 0)
			end)
	end)
end)

RegisterServerEvent("esx_mechanik:UpdateTaskProgress", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if xPlayer.job.name ~= "mechanik" and xPlayer.job.name ~= "offmechanik" and xPlayer.job.name ~= "ec" and xPlayer.job.name ~= "offec" then return end
    exports["esx_hud"]:UpdateTaskProgress(src, "Mechanic")
end)