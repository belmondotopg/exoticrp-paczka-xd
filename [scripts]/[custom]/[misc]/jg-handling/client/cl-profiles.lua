RegisterNUICallback("create-profile", function(data, cb)
  local profileName = data.profileName
  local handlingData = data.handlingData
  
  if not profileName or not handlingData or type(handlingData) ~= "table" then
    cb({error = true})
    return
  end
  
  local vehicle = cache.vehicle
  if not vehicle then
    cb({error = true})
    return
  end
  
  local vehicleArchetype = GetEntityArchetypeName(vehicle)
  
  local insertId = lib.callback.await("jg-handling:server:create-profile", false, profileName, vehicleArchetype, handlingData)
  
  if not insertId then
    cb({error = true})
    return
  end
  
  cb({insertId = insertId})
end)

RegisterNUICallback("delete-profile", function(data, cb)
  local profileId = data.id
  
  local success = lib.callback.await("jg-handling:server:delete-profile", false, profileId)
  
  if not success then
    cb({error = true})
    return
  end
  
  cb(true)
end)

RegisterNUICallback("get-profiles", function(data, cb)
  local query = data.query
  local pageIndex = data.pageIndex
  local pageSize = data.pageSize
  
  local profiles, totalCount = lib.callback.await("jg-handling:server:get-profiles", false, query, pageSize, pageIndex * pageSize)
  
  if not profiles then
    cb({error = true})
    return
  end
  
  -- Add vehicle labels to profiles
  for i, profile in ipairs(profiles) do
    profiles[i].vehicle_label = Framework.Client.GetVehicleLabel(profile.vehicle)
  end
  
  cb({
    profiles = profiles,
    pageCount = math.ceil(totalCount / pageSize)
  })
end)