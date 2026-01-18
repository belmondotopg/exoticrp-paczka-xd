lib.callback.register("jg-handling:server:lookup-vehicle-handling", function(playerId, plate, vehicleHash)
  return MySQL.single.await(
    "SELECT base_handling_data, handling_data FROM handling_vehicle_data WHERE (plate = ? AND vehicle_hash = ?) OR (plate = '*' AND vehicle_hash = ?) ORDER BY plate DESC LIMIT 1",
    {plate, vehicleHash, vehicleHash}
  )
end)

lib.callback.register("jg-handling:server:save-vehicle-handling", function(playerId, applyType, plate, vehicleHash, baseHandlingData, handlingData)
  if not hasEditorAccess(playerId) then
    return false
  end
  
  if applyType == "applyToPlate" then
    MySQL.update.await(
      "DELETE FROM handling_vehicle_data WHERE plate = ? AND vehicle_hash = ?",
      {plate, vehicleHash}
    )
  elseif applyType == "applyToModel" then
    MySQL.update.await(
      "DELETE FROM handling_vehicle_data WHERE (plate = ? AND vehicle_hash = ?) OR (plate = '*' AND vehicle_hash = ?)",
      {plate, vehicleHash, vehicleHash}
    )
  end
  
  local plateToUse = applyType == "applyToModel" and "*" or plate
  
  MySQL.insert.await(
    "INSERT INTO handling_vehicle_data (plate, vehicle_hash, base_handling_data, handling_data) VALUES(?, ?, ?, ?)",
    {plateToUse, vehicleHash, json.encode(baseHandlingData), json.encode(handlingData)}
  )
  
  return true
end)

lib.callback.register("jg-handling:server:delete-vehicle-handling", function(playerId, plate, vehicleHash)
  if not hasEditorAccess(playerId) then
    return false
  end
  
  MySQL.update.await(
    "DELETE FROM handling_vehicle_data WHERE (plate = ? AND vehicle_hash = ?) OR (plate = '*' AND vehicle_hash = ?) ORDER BY plate DESC LIMIT 1",
    {plate, vehicleHash, vehicleHash}
  )
  
  return true
end)