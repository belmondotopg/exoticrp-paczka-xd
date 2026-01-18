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