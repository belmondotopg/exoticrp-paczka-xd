local function getHandlingValue(vehicle, handlingClass, key)
  local keyPrefix = string.sub(key, 1, 3)
  
  if keyPrefix == "vec" then
    return GetVehicleHandlingVector(vehicle, handlingClass or "CHandlingData", key)
  elseif string.sub(key, 1, 1) == "f" then
    local value = GetVehicleHandlingFloat(vehicle, handlingClass or "CHandlingData", key)
    return tonumber(string.format("%.6f", value))
  else
    return GetVehicleHandlingInt(vehicle, handlingClass or "CHandlingData", key)
  end
end

local function setHandlingValue(vehicle, handlingClass, key, value)
  if key == "audioNameHash" then
    return
  end
  
  local previousValue
  if key == "nInitialDriveGears" then
    previousValue = getHandlingValue(vehicle, handlingClass, key)
  end
  
  -- Special handling for drive bias front to set wheel power
  if key == "fDriveBiasFront" then
    local wheelCount = GetVehicleNumberOfWheels(vehicle)
    if wheelCount >= 4 then
      SetVehicleWheelIsPowered(vehicle, 0, value > 0)  -- Front left
      SetVehicleWheelIsPowered(vehicle, 1, value > 0)  -- Front right
      SetVehicleWheelIsPowered(vehicle, 2, value < 1)  -- Rear left
      SetVehicleWheelIsPowered(vehicle, 3, value < 1)  -- Rear right
      SetVehicleWheelIsPowered(vehicle, 4, value < 1)  -- Additional rear wheel
    end
  end
  
  local keyPrefix = string.sub(key, 1, 3)
  
  if keyPrefix == "vec" then
    SetVehicleHandlingVector(
      vehicle, 
      handlingClass or "CHandlingData", 
      key, 
      vector3(value.x or 0, value.y or 0, value.z or 0)
    )
  elseif string.sub(key, 1, 1) == "f" then
    SetVehicleHandlingFloat(vehicle, handlingClass or "CHandlingData", key, value + 0.0)
  else
    SetVehicleHandlingInt(vehicle, handlingClass or "CHandlingData", key, value)
  end
  
  -- Special handling for gear changes
  if key == "nInitialDriveGears" and previousValue ~= value then
    SetVehicleHighGear(vehicle, value)
    Citizen.InvokeNative(2300828994, vehicle, value)  -- SET_VEHICLE_MAX_GEAR
    Citizen.InvokeNative(977626868, vehicle, value)   -- SET_VEHICLE_HIGH_GEAR
    
    SetTimeout(11, function()
      Citizen.InvokeNative(2300828994, vehicle, 1)  -- Reset to gear 1
    end)
  end
  
  -- Reset top speed modifier if needed
  local topSpeedModifier = GetVehicleTopSpeedModifier(vehicle)
  ModifyVehicleTopSpeed(vehicle, topSpeedModifier == -1.0 and 1.0 or topSpeedModifier)
end

function getVehicleHandling(vehicle, handlingClass)
  local handling = {}
  
  for key, class in pairs(HANDLING_KEY_CLASS_MAP) do
    if class == "CHandlingData" or class == handlingClass then
      local value = getHandlingValue(vehicle, class, key)
      
      if key == "AIHandling" then
        handling.AIHandling = AI_HANDLING_HASH_MAP[value]
      elseif key == "handlingName" then
        handling.handlingName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
      else
        handling[key] = value
      end
    end
  end
  
  handling.audioNameHash = GetEntityArchetypeName(vehicle)
  return handling
end

function applyVehicleHandling(vehicle, handlingData)
  if not vehicle or vehicle == 0 then
    return
  end
  
  if not handlingData or type(handlingData) ~= "table" then
    return
  end
  
  for key, value in pairs(handlingData) do
    setHandlingValue(vehicle, HANDLING_KEY_CLASS_MAP[key], key, value)
  end
end

RegisterNUICallback("close", function(data, cb)
  exitTimingTool()
  SetNuiFocus(false, false)
  TriggerScreenblurFadeOut(200)
  LocalPlayer.state:set("isBusy", false, true)
  cb(true)
end)