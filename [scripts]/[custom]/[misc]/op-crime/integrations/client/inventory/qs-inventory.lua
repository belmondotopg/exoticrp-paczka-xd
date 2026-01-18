------------------------------------------------------------------------------
-- OPEN STASH FUNCTION / this is called when user press 'e' or use target ----
------------------------------------------------------------------------------

if Config.Inventory.inventoryScript ~= "quasar_inventory" then return end

function openStash(orgId)
    if playerOrganisationData.isInOrg then
        if playerOrganisationData.jobId then
            if orgId then
                if playerOrganisationData.jobId ~= orgId then
                    return print('not yours organization.')
                end
            end

            SH.CheckPermission("storage_access", function(hasPermission)
                if hasPermission then
                    TriggerServerEvent('op-crime:openQuasarStash')
                else 
                    sendNotify(TranslateIt('noPermission_stash'), "error", 5)
                end
            end)
        end
    end
end