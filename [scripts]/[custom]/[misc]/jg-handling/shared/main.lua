local localeKey = Config.Locale or "en"
Locale = Locales[localeKey]

function getTrimmedVehiclePlate(vehicle)
  if not vehicle or not DoesEntityExist(vehicle) then
    return false
  end
  
  local plateText = GetVehicleNumberPlateText(vehicle)
  if not plateText then
    return false
  end
  
  local trimmedPlate = string.gsub(plateText, "^%s*(.-)%s*$", "%1")
  return trimmedPlate
end

function round(number, decimals)
  if decimals and decimals > 0 then
    local multiplier = 10 ^ decimals
    return math.floor(number * multiplier + 0.5) / multiplier
  end
  
  return math.floor(number + 0.5)
end