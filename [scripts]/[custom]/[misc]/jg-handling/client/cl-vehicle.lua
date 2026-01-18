local function loadVehicleHandling(vehicle, plate)
  local entityState = Entity(vehicle).state
  
  -- If editor handling is already applied, use that
  if entityState.editorHandlingApplied and entityState.editorHandling then
    applyVehicleHandling(vehicle, entityState.editorHandling)
    return
  end
  
  local vehicleModel = GetEntityModel(vehicle)
  
  -- Look up handling data from database
  local handlingData = lib.callback.await("jg-handling:server:lookup-vehicle-handling", false, plate, vehicleModel)
  
  if not handlingData then
    return
  end
  
  -- Decode JSON data
  local baseHandlingData = json.decode(handlingData.base_handling_data or "{}")
  local modifiedHandlingData = json.decode(handlingData.handling_data or "{}")
  
  -- Apply the modified handling
  applyVehicleHandling(vehicle, modifiedHandlingData)
  
  -- Set state bags
  entityState:set("baseHandling", baseHandlingData, true)
  entityState:set("editorHandlingApplied", true, true)
  entityState:set("editorHandling", modifiedHandlingData, true)
end

local function onVehicleEnter(vehicle)
  if not vehicle or vehicle == 0 then
    return
  end
  
  local plate = Framework.Client.GetPlate(vehicle)
  if plate then
    loadVehicleHandling(vehicle, plate)
  end
end

-- Set up vehicle change detection with delay
lib.onCache("vehicle", function()
  SetTimeout(1000, function()
    onVehicleEnter(cache.vehicle)
  end)
end)

-- Load handling for current vehicle on script start
if cache.vehicle then
  onVehicleEnter(cache.vehicle)
end