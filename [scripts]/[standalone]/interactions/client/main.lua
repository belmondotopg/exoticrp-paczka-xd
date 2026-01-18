local function showInteraction(coords, icon, key, title, description, JobBlacklist, JobWhitelist)

    if (JobWhitelist == nil) then 
        JobWhitelist = false
    end

    if (JobBlacklist == nil) then 
        JobBlacklist = false
    end

    if not coords or not coords.x or not coords.y or not coords.z then
        print("^1[ERROR]^7 showInteraction: Nieprawidłowe współrzędne")
        return false
    end
    
    local dataInteraction = {
        icon = icon or "fa-solid fa-house",
        key = key or "E",
        title = title or "Interakcja",
        description = description or "Naciśnij klawisz aby wejść",
        jobBlacklist = JobBlacklist,
        jobWhitelist = JobWhitelist
    }
    
    -- Usunięcie niepotrzebnego wątku - createDUI jest synchroniczne
    local success = createDUI(coords, dataInteraction)
    return success
end

local function removeInteraction(coords)
    if not coords or not coords.x or not coords.y or not coords.z then
        print("^1[ERROR]^7 removeInteraction: Nieprawidłowe współrzędne")
        return false
    end
    
    local success = removeDui(coords)
    if not success then
        print("^3[WARNING]^7 removeInteraction: Nie znaleziono notyfikacji na podanych współrzędnych")
    end
    return success
end

local function isInteractionExists(coords)
    if not coords or not coords.x or not coords.y or not coords.z then
        return false
    end
    return isDuiExists(coords)
end

local function getInteractionCount()
    return getDuiCount()
end

local function isInteractionExistsWithData(coords, icon, key, title, description)
    if not coords or not coords.x or not coords.y or not coords.z then
        return false
    end
    
    local dataInteraction = {
        icon = icon or "fa-solid fa-house",
        key = key or "E",
        title = title or "Interakcja",
        description = description or "Naciśnij klawisz aby wejść",
    }
    
    return isDuiExistsWithData(coords, dataInteraction)
end

exports("showInteraction", showInteraction)
exports("removeInteraction", removeInteraction)
exports("isInteractionExists", isInteractionExists)
exports("isInteractionExistsWithData", isInteractionExistsWithData)
exports("getInteractionCount", getInteractionCount)

-- GDY CHCESZ ABY BYŁA IKONKA ZAMIAST "E"
-- showInteraction(
--     vec3(-768.1933, -1219.1123, 51.1480), 
--     "fa-solid fa-house", 
--     "E", 
--     "Wejdź do mieszkania", 
--     "Naciśnij ALT aby wejść"
-- )

-- GDY CHCESZ ABY BYŁ GUZIK "E" ZAMIAST IKONKI
-- showInteraction(
--     vec3(-765.1933, -1219.1123, 51.1480), 
--     nil, 
--     "E", 
--     "Wejdź do mieszkania", 
--     "Naciśnij ALT aby wejść"
-- )

-- removeInteraction(vec3(-765.1933, -1219.1123, 51.1480))