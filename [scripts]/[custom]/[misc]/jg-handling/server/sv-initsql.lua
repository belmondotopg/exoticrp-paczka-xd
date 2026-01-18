local function splitString(str, delimiter)
  local result = {}
  local pattern = "([^" .. delimiter .. "]+)"
  
  for match in string.gmatch(str, pattern) do
    local trimmed = string.gsub(match, "^%s*(.-)%s*$", "%1")
    table.insert(result, trimmed)
  end
  
  return result
end

function initSQL(callback)
  if Config.AutoRunSQL then
    local success = pcall(function()
      local file = assert(io.open(GetResourcePath(GetCurrentResourceName()) .. "/install/database.sql", "rb"))
      local sqlContent = file:read("*all")
      file:close()
      
      local sqlCommands = splitString(sqlContent, ";")
      MySQL.transaction.await(sqlCommands)
      
      callback()
    end)
    
    if not success then
      print("^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file manually, found at 'install/database.sql'. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0")
    end
  end
end