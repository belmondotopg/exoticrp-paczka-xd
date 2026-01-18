Framework = Framework or {}

-- Get the player job table depending on the framework
-- @return table|boolean The player job table or false if the framework is not found
function Framework:GetPlayerJob(options)
    if self.currentFramework == "esx" then
        local playerData = self.object.PlayerData

        if options then
            if options.lowercaseJobName then
                playerData.job.name = string.lower(playerData.job.name)
            end

            if options.lowercaseJobGradeName then
                playerData.job.grade_name = string.lower(playerData.job.grade_name)
            end

            -- Map the data if needed
            if options.mapData then
                local mappedData = {}

                for key, value in pairs(playerData.job) do
                    mappedData[key] = value
                end

                if options.mapData.grade then
                    mappedData.grade = {}

                    if options.mapData.grade.name then
                        mappedData.grade.name = playerData.job.grade_name
                    end
                end

                return mappedData
            end
        end

        return playerData.job
    elseif self.currentFramework == "qbcore" then
        local playerData = self.object.PlayerData

        if options then
            if options.lowercaseJobName then
                playerData.job.name = string.lower(playerData.job.name)
            end

            if options.lowercaseJobGradeName then
                playerData.job.grade.name = string.lower(playerData.job.grade.name)
            end

            -- Map the data if needed
            if options.mapData then
                local mappedData = {}

                for key, value in pairs(playerData.job) do
                    if options.mapData[key] then
                        mappedData[key] = value
                    end
                end

                if options.mapData.grade then
                    mappedData.grade = {}

                    if options.mapData.grade.name then
                        mappedData.grade.name = playerData.job.grade.name
                    end
                end

                return mappedData
            end
        end

        return playerData.job
    end

    Logger:error("Framework:GetPlayerJob() - Framework not found.")

    return false
end
exports("getPlayerJob", function(...)
    return Framework:GetPlayerJob(...)
end)

--- Check if the player has the job
---@param dataObject table The data object
---@return boolean Whether the player has the job
function Framework:HasJob(dataObject, options)
    local playerJob = self:GetPlayerJob({
        mapData = {
            job = {
                name = dataObject.jobName
            },
            grade = {
                name = dataObject.jobGradeName
            }
        }
    })

    if playerJob.name == dataObject.jobName then
        -- Adding the job grade is optional.
        if dataObject.jobGradeName then
            if playerJob.grade.name == dataObject.jobGradeName then
                return true
            end
        else
            return true
        end
    end

    return false
end
exports("hasJob", function(...)
    return Framework:HasJob(...)
end)

-- Get the player full name
-- @return string The player full name
function Framework:GetPlayerFullName()
    local fullName = EventManager:awaitTriggerServerEvent("getPlayerFullName")

    return fullName
end
exports("getPlayerFullName", function(...)
    return Framework:GetPlayerFullName(...)
end)