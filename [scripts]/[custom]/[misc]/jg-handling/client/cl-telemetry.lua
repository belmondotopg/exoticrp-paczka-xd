local isTimingToolActive = false
local timingData = nil
local state = "idle"
local startTime = 0
local elapsedTime = 0
local distanceTraveled = 0
local lastCoords = nil
local speedUnits = {}
speedUnits.mph = 2.236936
speedUnits.kph = 3.6

function getVehicleData(vehicle)
  local entitySpeed = GetEntitySpeed(vehicle)
  local speedMultiplier = speedUnits[Config.SpeedUnit] or speedUnits.mph
  local displaySpeed = math.floor(entitySpeed * speedMultiplier)
  local currentGear = GetVehicleCurrentGear(vehicle)
  
  return entitySpeed, displaySpeed, currentGear
end

function checkTargets(currentTime, speed, distance)
  if not timingData then
    return false
  end
  
  local newTargets = {}
  
  for targetName, targetSpeed in pairs(Config.SpeedTargets) do
    if targetSpeed <= speed then
      if not timingData.targetsReached[targetName] then
        newTargets[#newTargets + 1] = {
          name = targetName,
          time = currentTime
        }
        timingData.targetsReached[targetName] = currentTime
      end
    end
  end
  
  for targetName, targetDistance in pairs(Config.DistanceTargets) do
    if targetDistance <= distance then
      if not timingData.targetsReached[targetName] then
        newTargets[#newTargets + 1] = {
          name = targetName,
          time = currentTime
        }
        timingData.targetsReached[targetName] = currentTime
      end
    end
  end
  
  return newTargets
end

function exitTimingTool()
  if not isTimingToolActive then
    return
  end
  
  isTimingToolActive = false
  state = "idle"
  timingData = nil
  startTime = 0
  elapsedTime = 0
  distanceTraveled = 0
  lastCoords = nil
  
  SetNuiFocus(false, false)
  SendNUIMessage({
    type = false,
    showTimingTool = false
  })
end

function resetTimingTool()
  state = "idle"
  startTime = 0
  elapsedTime = 0
  distanceTraveled = 0
  lastCoords = nil
  
  if timingData then
    timingData.targetsReached = {}
  end
  
  SendNUIMessage({
    resetTimingTool = GetGameTimer()
  })
end

function initTimingTool(standalone)
  if isTimingToolActive then
    return
  end
  
  local vehicle = cache.vehicle
  if not vehicle then
    return
  end
  
  local plate = getTrimmedVehiclePlate(vehicle)
  if not plate then
    return
  end
  
  isTimingToolActive = true
  timingData = {
    vehicle = vehicle,
    plate = plate,
    targetsReached = {}
  }
  
  SetNuiFocus(false, false)
  
  if standalone then
    openedStandalone = true
    SendNUIMessage({
      type = "show-timing-tool",
      config = Config,
      locale = Locale
    })
  else
    SendNUIMessage({
      showTimingTool = true,
      config = Config,
      locale = Locale
    })
  end
  
  Citizen.CreateThreadNow(function()
    while isTimingToolActive do
      Wait(0)
      
      if IsControlJustPressed(0, Config.TimingToolResetKeyBind or 36) then
        resetTimingTool()
      end
    end
  end)
  
  Citizen.CreateThreadNow(function()
    while isTimingToolActive do
      local currentTime = GetGameTimer()
      local targets = {}
      local rawSpeed, displaySpeed, gear = getVehicleData(vehicle)
      
      if state == "recording" then
        local currentCoords = GetEntityCoords(vehicle)
        elapsedTime = round((currentTime - startTime) / 1000, 1)
        
        local distanceSinceLastCoords = #(lastCoords - currentCoords) * 3.28084
        distanceTraveled = distanceTraveled + distanceSinceLastCoords
        lastCoords = currentCoords
        
        targets = checkTargets(elapsedTime, displaySpeed, distanceTraveled) or {}
      else
        if rawSpeed >= 0.5 then
          if state == "ready" then
            state = "recording"
            startTime = currentTime - 100
            distanceTraveled = 0
            elapsedTime = 0
            lastCoords = GetEntityCoords(vehicle)
          end
        end
        
        if rawSpeed < 0.5 then
          if state == "stopVehicle" or state == "idle" then
            state = "ready"
            elapsedTime = 0
            displaySpeed = 0
          end
        end
        
        if rawSpeed >= 0.5 then
          if state == "idle" then
            state = "stopVehicle"
            elapsedTime = 0
          end
        end
      end
      
      if state ~= "idle" then
        SendNUIMessage({
          timingToolData = {
            status = state,
            time = elapsedTime,
            gear = gear,
            speed = displaySpeed,
            targets = targets
          }
        })
      end
      
      Wait(100)
    end
  end)
end

RegisterNetEvent("jg-handling:client:open-timing-tool", function()
  if not lib.callback.await("jg-handling:server:has-timing-tool-access") then
    return
  end
  
  initTimingTool(true)
end)

RegisterNetEvent("jg-handling:client:close-timing-tool", function()
  if not lib.callback.await("jg-handling:server:has-timing-tool-access") then
    return
  end
  
  exitTimingTool()
end)

if Config.EnableStandaloneTimingTool then
  if Config.TimingToolOpenCommand then
    RegisterCommand(Config.TimingToolOpenCommand, function()
      TriggerEvent("jg-handling:client:open-timing-tool")
    end)
  end
  
  if Config.TimingToolExitCommand then
    RegisterCommand(Config.TimingToolExitCommand, function()
      TriggerEvent("jg-handling:client:close-timing-tool")
    end)
  end
end

lib.onCache("vehicle", function(vehicle)
  if not vehicle then
    if isTimingToolActive then
      exitTimingTool()
    end
  end
end)