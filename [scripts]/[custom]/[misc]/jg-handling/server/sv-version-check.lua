local resourceName = "jg-handling"
local versionUrl = "https://raw.githubusercontent.com/jgscripts/versions/main/" .. resourceName .. ".txt"

local function compareVersions(currentVersion, latestVersion)
  local current = {}
  for part in string.gmatch(currentVersion, "[^.]+") do
    table.insert(current, tonumber(part))
  end
  
  local latest = {}
  for part in string.gmatch(latestVersion, "[^.]+") do
    table.insert(latest, tonumber(part))
  end
  
  local maxLength = math.max(#current, #latest)
  for i = 1, maxLength do
    local currentPart = current[i] or 0
    local latestPart = latest[i] or 0
    if currentPart < latestPart then
      return true
    end
  end
  
  return false
end

local function checkForUpdates()
  PerformHttpRequest(versionUrl, function(statusCode, responseBody, responseHeaders)
    if statusCode ~= 200 then
      print("^1Unable to perform update check")
      return
    end
    
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    if not currentVersion then
      return
    end
    
    if currentVersion == "dev" then
      print("^3Using dev version")
      return
    end
    
    local latestVersion = responseBody:match("^[^\n]+")
    if not latestVersion then
      return
    end
    
    local needsUpdate = compareVersions(currentVersion:sub(2), latestVersion:sub(2))
    if needsUpdate then
      print("^3Update available for " .. resourceName .. "! (current: ^1" .. currentVersion .. "^3, latest: ^2" .. latestVersion .. "^3)")
      print("^3Release notes: discord.gg/jgscripts")
    end
  end, "GET")
end

local function checkArtifactVersion()
  local serverVersion = GetConvar("version", "unknown")
  local artifactVersion = string.match(serverVersion, "v%d+%.%d+%.%d+%.(%d+)")
  
  PerformHttpRequest("https://artifacts.jgscripts.com/check?artifact=" .. artifactVersion, function(statusCode, responseBody, responseHeaders, errorData)
    if statusCode ~= 200 or errorData then
      print("^1Could not check artifact version^0")
      return
    end
    
    if not responseBody then
      return
    end
    
    local data = json.decode(responseBody)
    if data.status == "BROKEN" then
      print("^1WARNING: The current FXServer version you are using (artifacts version) has known issues. Please update to the latest stable artifacts: https://artifacts.jgscripts.com^0")
      print("^0Artifact version:^3", artifactVersion, "\n\n^0Known issues:^3", data.reason, "^0")
      return
    end
  end)
end

CreateThread(function()
  checkForUpdates()
  checkArtifactVersion()
end)