local isInPreviewMode = false

local function applyBaseHandling(vehicle)
  local entity = Entity(vehicle)
  local baseHandling = entity and entity.state and entity.state.baseHandling
  
  if not baseHandling then
    return
  end
  
  applyVehicleHandling(vehicle, baseHandling)
end

local function exitPreviewMode(vehicle)
  isInPreviewMode = false
  resetTimingTool()
  applyBaseHandling(vehicle)
  SetNuiFocus(true, true)
  SendNUIMessage({
    exitPreviewMode = GetGameTimer()
  })
end

local function openHandlingEditor(mode)
  if isInPreviewMode then
    return
  end
  
  local vehicle = cache.vehicle
  if not vehicle or vehicle == 0 then
    Framework.Client.Notify(Locale.notInVehicle, "error")
    return
  end
  
  local vehicleModel = GetEntityModel(vehicle)
  local vehicleArchetype = GetEntityArchetypeName(vehicle)
  local vehicleLabel = Framework.Client.GetVehicleLabel(vehicleArchetype)
  
  local handlingClass
  if IsThisModelACar(vehicleModel) then
    handlingClass = "CCarHandlingData"
  elseif IsThisModelABike(vehicleModel) or IsThisModelAQuadbike(vehicleModel) then
    handlingClass = "CBikeHandlingData"
  elseif IsThisModelABoat(vehicleModel) or IsThisModelAJetski(vehicleModel) then
    handlingClass = "CBoatHandlingData"
  elseif IsThisModelAHeli(vehicleModel) or IsThisModelAPlane(vehicleModel) then
    handlingClass = "CFlyingHandlingData"
  else
    handlingClass = false
  end
  
  local entityState = Entity(vehicle).state
  
  if not handlingClass then
    Framework.Client.Notify(Locale.notCompatibleWithHandlingEditor, "error")
    return
  end
  
  local currentHandling = getVehicleHandling(vehicle, handlingClass)
  local baseHandling = entityState.baseHandling
  local tuningConfig = entityState.tuningConfig
  local servicingData = entityState.servicingData
  local editorHandlingApplied = entityState.editorHandlingApplied
  
  if not baseHandling then
    baseHandling = currentHandling
    entityState:set("baseHandling", currentHandling, true)
  end
  
  if not editorHandlingApplied then
    local mechanicState = GetResourceState("jg-mechanic")
    if mechanicState == "started" then
      if not mode and (tuningConfig or servicingData) then
        SetNuiFocus(true, true)
        SendNUIMessage({
          type = "show-select-mechanic-data",
          locale = Locale
        })
        return
      end
      
      local success = pcall(function()
        if mode == "WITHOUT_SERVICING" then
          if tuningConfig then
            currentHandling = exports["jg-mechanic"]:calculateTuningHandling(baseHandling, tuningConfig)
          else
            currentHandling = baseHandling
          end
        elseif mode == "BASE_HANDLING" then
          currentHandling = baseHandling
        end
      end)
      
      if not success then
        print("^1[ERROR] You must be using JG Mechanic v1.4 or newer.^0")
      end
    end
  end
  
  TriggerScreenblurFadeIn(200)
  SetNuiFocus(true, true)
  SendNUIMessage({
    type = "show-handling-editor",
    config = Config,
    locale = Locale,
    vehicleHandling = currentHandling,
    baseVehicleHandling = baseHandling,
    editorHandlingApplied = editorHandlingApplied,
    vehicleArchetypeName = vehicleArchetype,
    vehicleLabel = vehicleLabel,
    vehicleSubHandlingClass = handlingClass
  })
end

RegisterNUICallback("select-mechanic-data-mode", function(data, cb)
  openHandlingEditor(data.mode)
  cb(true)
end)

RegisterNUICallback("preview-handling", function(handlingData, cb)
  TriggerScreenblurFadeOut(200)
  
  if not handlingData or type(handlingData) ~= "table" then
    return
  end
  
  local vehicle = cache.vehicle
  if not vehicle or vehicle == 0 then
    cb({error = true})
    return
  end
  
  applyVehicleHandling(vehicle, handlingData)
  SetNuiFocus(false, false)
  initTimingTool()
  isInPreviewMode = true
  
  Citizen.CreateThreadNow(function()
    while isInPreviewMode do
      Wait(0)
      DisableControlAction(0, 75, true) -- Disable exit vehicle
      
      if IsControlJustPressed(0, 194) then -- BACKSPACE
        exitPreviewMode(vehicle)
        TriggerScreenblurFadeIn(200)
      end
    end
  end)
  
  cb(true)
end)

RegisterNUICallback("apply-handling", function(data, cb)
  local handlingData = data.handlingData
  local applyType = data.applyType
  local vehicle = cache.vehicle
  
  if not handlingData or type(handlingData) ~= "table" then
    cb({error = true})
    return
  end
  
  if not vehicle or vehicle == 0 then
    cb({error = true})
    return
  end
  
  applyVehicleHandling(vehicle, handlingData)
  
  local entityState = Entity(vehicle).state
  entityState:set("editorHandlingApplied", true, true)
  entityState:set("editorHandling", handlingData, true)
  
  if applyType ~= "applyTemporarily" then
    local vehicleModel = GetEntityModel(vehicle)
    local vehiclePlate = Framework.Client.GetPlate(vehicle)
    
    if not vehiclePlate then
      return
    end
    
    local baseHandling = Entity(vehicle) and Entity(vehicle).state and Entity(vehicle).state.baseHandling
    
    if not baseHandling then
      print("^1Could not save handling data to DB. Vehicle does not have baseHandling statebag set.")
      cb({error = true})
      return
    end
    
    lib.callback.await("jg-handling:server:save-vehicle-handling", false, applyType, vehiclePlate, vehicleModel, baseHandling, handlingData)
  end
  
  Framework.Client.Notify(Locale.handlingApplied, "success")
  cb(true)
end)

RegisterNUICallback("reset-handling", function(data, cb)
  local vehicle = cache.vehicle
  if not vehicle then
    cb({error = true})
  end
  
  applyBaseHandling(vehicle)
  
  local entityState = Entity(vehicle).state
  entityState:set("editorHandlingApplied", false, true)
  entityState:set("editorHandling", nil, true)
  
  local vehicleModel = GetEntityModel(vehicle)
  local vehiclePlate = Framework.Client.GetPlate(vehicle)
  
  if not vehiclePlate then
    return
  end
  
  lib.callback.await("jg-handling:server:delete-vehicle-handling", false, vehiclePlate, vehicleModel)
  
  local mechanicState = GetResourceState("jg-mechanic")
  if mechanicState == "started" then
    local success = pcall(function()
      local tuningConfig = Entity(vehicle).state.tuningConfig
      exports["jg-mechanic"]:applyVehicleTuningHandling(vehicle, tuningConfig or {})
    end)
    
    if not success then
      print("^1[ERROR] Can't re-apply servicing & tuning; you must be using JG Mechanic v1.4 or newer.^0")
    end
  end
  
  cb(true)
end)

RegisterNetEvent("jg-handling:client:open-editor", function()
  local hasAccess = lib.callback.await("jg-handling:server:has-editor-access")
  if not hasAccess then
    return
  end
  
  openHandlingEditor()
end)

if Config.EditorCommand then
  RegisterCommand(Config.EditorCommand, function()
    TriggerEvent("jg-handling:client:open-editor")
  end)
end

lib.onCache("vehicle", function(vehicle)
  local currentVehicle = cache.vehicle
  
  if not vehicle or vehicle == 0 or isInPreviewMode then
    exitPreviewMode(currentVehicle)
    SendNUIMessage({type = "none"})
    SetNuiFocus(false, false)
  end
end)