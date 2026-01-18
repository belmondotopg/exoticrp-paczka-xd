while Framework == nil do Wait(5) end

Fr.RegisterServerCallback('op-crime:startMission', function(source, cb, missionIndex)
    local playerObject = playersJobs[Fr.GetIndentifier(source)]
    local playerOrg = organisations[tostring(playerObject.jobId)]

    if playerObject then
        if organisations and playerOrg then
            if playerOrg.missions[missionIndex] then
                local drugMissions = {
                    ["sell_drugs"] = true,
                    ["drug_sell_npc"] = true,
                    ["steal_van"] = true
                }
                
                if Player(source).state.ProtectionTime and Player(source).state.ProtectionTime > 0 then
                    if drugMissions[missionIndex] then
                        TriggerClientEvent('esx:showNotification', source, 'Nie możesz rozpoczynać misji związanych z narkotykami będąc na antytrollu!')
                        return cb(false)
                    end
                end
                
                if playerOrg.missions[missionIndex].startedBy == "" then
                    playerOrg.missions[missionIndex].startedBy = Fr.GetPlayerName(source)
                    playerOrg.missions[missionIndex].status = "started"

                    organisations[tostring(playerObject.jobId)] = playerOrg
                    cb(true)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

Fr.RegisterServerCallback('op-crime:sellDrugs', function(source, cb)
    -- Sprawdź czy gracz jest na antytrollu
    if Player(source).state.ProtectionTime and Player(source).state.ProtectionTime > 0 then
        TriggerClientEvent('esx:showNotification', source, 'Nie możesz sprzedawać narkotyków w misjach będąc na antytrollu!')
        return cb(false)
    end
    
    local playerObject = playersJobs[Fr.GetIndentifier(source)]
    local playerOrg = organisations[tostring(playerObject.jobId)]

    if playerObject and playerOrg then 
        local xPlayer = Fr.getPlayerFromId(source)
        if xPlayer then 
            local inventory = Fr.getInventory(xPlayer)
            
            local canProceed = false
            for k, v in pairs(inventory) do
                if v.name == 'weed' then
                    local count = v.amount or v.count
                    if count >= 50 then
                        canProceed = true
                        Fr.removeItem(xPlayer, "weed", 50)
                        break;
                    end
                end
            end

            cb(canProceed)
        end
    end
end)

RegisterServerEvent('op-crime:endMission')
AddEventHandler('op-crime:endMission', function(missionIndex)
    local playerObject = playersJobs[Fr.GetIndentifier(source)]
    local playerOrg = organisations[tostring(playerObject.jobId)]

    if playerObject then
        if organisations and playerOrg then
            if playerOrg.missions[missionIndex] then
                if playerOrg.missions[missionIndex].status == "started" then
                    playerOrg.missions[missionIndex].status = "done"
                    organisations[tostring(playerObject.jobId)] = playerOrg

                    assignReward(playerOrg.missions[missionIndex].UI.missionReward, playerObject.jobId, source)
                    addOrgExp(playerObject.jobId, playerOrg.missions[missionIndex].UI.missionExp)
                    addOrgDoneMissions(playerObject.jobId)
                end
            end
        end
    end
end)