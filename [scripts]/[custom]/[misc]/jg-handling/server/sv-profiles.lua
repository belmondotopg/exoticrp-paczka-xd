function hasEditorAccess(playerId)
  if Config.EditorAdminOnly then
    if not Framework.Server.IsAdmin(playerId) then
      Framework.Server.Notify(playerId, Locale.requiresAdmin, "error")
      return false
    end
  else
    if type(Config.EditorJobRestriction) == "table" then
      if #Config.EditorJobRestriction > 0 then
        local playerJob = Framework.Server.GetPlayerJob(playerId)
        if not playerJob then
          Framework.Server.Notify(playerId, "Could not get job - you need to have set a framework if you are trying to use this functionality!", "error")
          return false
        end
        if not lib.table.contains(Config.EditorJobRestriction, playerJob and playerJob.name) then
          if not Framework.Server.IsAdmin(playerId) then
            Framework.Server.Notify(playerId, Locale.noPermission, "error")
            return false
          end
        end
      end
    end
  end
  return true
end

function hasTimingToolAccess(playerId)
  if Config.TimingToolAdminOnly then
    if not Framework.Server.IsAdmin(playerId) then
      Framework.Server.Notify(playerId, Locale.requiresAdmin, "error")
      return false
    end
  else
    if type(Config.TimingToolJobRestriction) == "table" then
      if #Config.TimingToolJobRestriction > 0 then
        local playerJob = Framework.Server.GetPlayerJob(playerId)
        if not playerJob then
          Framework.Server.Notify(playerId, "Could not get job - you need to have set a framework if you are trying to use this functionality!", "error")
          return false
        end
        if not lib.table.contains(Config.TimingToolJobRestriction, playerJob and playerJob.name) then
          if not Framework.Server.IsAdmin(playerId) then
            Framework.Server.Notify(playerId, Locale.noPermission, "error")
            return false
          end
        end
      end
    end
  end
  return true
end

lib.callback.register("jg-handling:server:has-editor-access", hasEditorAccess)
lib.callback.register("jg-handling:server:has-timing-tool-access", hasTimingToolAccess)

lib.callback.register("jg-handling:server:create-profile", function(playerId, profileName, vehicleName, handlingData)
  if not hasEditorAccess(playerId) then
    return false
  end
  
  local playerInfo = Framework.Server.GetPlayerInfo(playerId)
  if not playerInfo then
    return
  end
  
  local editorName = playerInfo and playerInfo.name or "Admin"
  local encodedHandlingData = json.encode(handlingData)
  
  local insertId = MySQL.insert.await(
    "INSERT INTO handling_profiles (name, vehicle, edited_at, edited_by, handling_data) VALUES(?, ?, CURRENT_TIMESTAMP(), ?, ?)",
    {profileName, vehicleName, editorName, encodedHandlingData}
  )
  
  return insertId
end)

lib.callback.register("jg-handling:server:delete-profile", function(playerId, profileId)
  if not hasEditorAccess(playerId) then
    return false
  end
  
  MySQL.update.await("DELETE FROM handling_profiles WHERE id = ?", {profileId})
  return true
end)

lib.callback.register("jg-handling:server:get-profiles", function(playerId, searchTerm, limit, offset)
  if not hasEditorAccess(playerId) then
    return false
  end
  
  local searchPattern = "%" .. searchTerm:lower() .. "%"
  
  local profiles = MySQL.query.await(
    "SELECT * FROM handling_profiles WHERE name LIKE ? OR edited_by LIKE ? OR vehicle LIKE ? ORDER BY edited_at DESC LIMIT ? OFFSET ?",
    {searchPattern, searchPattern, searchPattern, limit, offset}
  )
  
  local totalCount = MySQL.scalar.await(
    "SELECT COUNT(*) FROM handling_profiles WHERE name LIKE ? OR edited_by LIKE ? OR vehicle LIKE ?",
    {searchPattern, searchPattern, searchPattern}
  )
  
  return profiles, totalCount
end)