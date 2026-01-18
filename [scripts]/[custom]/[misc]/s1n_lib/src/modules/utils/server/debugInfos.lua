Utils = Utils or {}

-- Get the debug infos need for a developer or support agent to investigate an issue
-- @return table The debug infos
function Utils:GetDebugInfos()
    return {
        gameBuild = GetGameBuildNumber(),
        artifactVersion = GetConvarInt("buildNumber"),

        framework = Framework:GetCurrentFrameworkName(),
    }
end

-- Print the debug infos in the console
function Utils:PrintDebugInfos()
	print(json.encode(self:GetDebugInfos(), { indent = true }))
end