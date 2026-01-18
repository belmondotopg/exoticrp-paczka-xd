if Config.dispatchScript == "qf_mdt" then

    function sendDispatchAlert(title, message, blipData)
        local currentPos = GetEntityCoords(PlayerPedId())
        
        local gps = vector3(currentPos.x, currentPos.y, currentPos.z)
        local code = "10-90"
        local color = "rgb(255, 0, 0)" -- Red color for drug dealing alert
        local response = 0 -- 0 = no limit, set to number to limit responders
        local spriteid = blipData and blipData.sprite or 51
        local blipcolourJob = blipData and blipData.color or 1
        local blipcolourOther = blipData and blipData.color or 1

        -- qf_mdt/addDispatchAlertSV event parameters: gps, title, subtitle, code, color, response, spriteid, blipcolourJob, blipcolourOther
        TriggerServerEvent('qf_mdt/addDispatchAlertSV', gps, title, message, code, color, response, spriteid, blipcolourJob, blipcolourOther)
    end
end

