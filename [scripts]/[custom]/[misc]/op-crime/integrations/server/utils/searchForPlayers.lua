-- ──────────────────────────────────────────────────────────────────────────────
-- Search Player Result Callback                                               
-- (Information) ► Handles player search in admin tablet / organisation panels.
-- (Information) ► Searches database by identifier, firstname/lastname (ESX),
--                 or charinfo JSON (QB/QBOX). Returns up to 15 results.
-- (Information) ► Output format:
--                 {
--                     identificator = "identifier",
--                     name         = "Firstname Lastname",
--                     steamName    = ""
--                 }
-- ──────────────────────────────────────────────────────────────────────────────

while Framework == nil do Wait(5) end

Fr.RegisterServerCallback('op-crime:searchResult', function(source, cb, searchTerm)
    local playersList = {}

    if ESX then
        MySQL.Async.fetchAll(
            "SELECT * FROM "..Fr.usersTable.." WHERE " ..
            Fr.identificatorTable.." LIKE @search OR firstname LIKE @search OR lastname LIKE @search LIMIT 15",
            {
                ['@search'] = '%' .. searchTerm .. '%'
            },
            function(results)
                for _, v in pairs(results) do
                    local playerString = {
                        identificator = v[Fr.identificatorTable],
                        name         = v.firstname .. " " .. v.lastname,
                        steamName    = "",
                    }

                    table.insert(playersList, playerString)
                end

                cb(playersList)
            end
        )

    elseif QBCore or QBox then
        MySQL.Async.fetchAll(
            "SELECT * FROM "..Fr.usersTable.." WHERE " ..
            Fr.identificatorTable.." LIKE @search OR charinfo LIKE @search LIMIT 15",
            {
                ['@search'] = '%' .. searchTerm .. '%'
            },
            function(results)
                for _, v in pairs(results) do
                    v.charinfo = json.decode(v.charinfo)

                    local playerString = {
                        identificator = v[Fr.identificatorTable],
                        name         = v.charinfo.firstname .. " " .. v.charinfo.lastname,
                        steamName    = "",
                    }

                    table.insert(playersList, playerString)
                end

                cb(playersList)
            end
        )
    end
end)