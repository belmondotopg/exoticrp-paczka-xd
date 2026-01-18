Config = {}

Config.Peds = {
    {
        coords = vec3(-554.73645019531, -185.16348266602, 38.221153259277), heading = 210.5990, anim = 'WORLD_HUMAN_GUARD_STAND_CASINO', label = 'Przeglądaj oferty'
    },
}

Config.Blip = {
    sprite = 408,
    color = 43,
    scale = 0.7,
    display = 4,
    shortRange = true,
    name = "Urząd Pracy"
}

Config.Waypoints = {
    ['lumberjack'] = vec3(-565.5791, 5325.7207, 73.5929),
    ['weazelnews'] = vec3(-598.1968, -929.8624, 36.8336),
    ['postman'] = vec3(-232.16, -915.15, 32.31),
    ['garbage'] = vec3(-329.47, -1538.23, 31.43),
}

function IsJobAvailable(jobName)
    -- local ESX = exports.es_extended:getSharedObject()
    
    -- if not ESX then return true end
    
    -- local playerData = ESX.GetPlayerData()
    -- if not playerData or not playerData.job then 
    --     return true 
    -- end
    
    -- return playerData.job.name == 'unemployed'
    return true -- Na serwerze jest multijob więc zawsze będzie możliwość zatrudnienia się
end

function GetJobsWithUpdatedAvailability()
    local jobs = {}
    for i, job in ipairs(Config.Jobs) do
        local updatedJob = {}
        for k, v in pairs(job) do
            if k == "isAvailable" then
                updatedJob[k] = job.isAvailable()
            else
                updatedJob[k] = v
            end
        end
        jobs[i] = updatedJob
    end
    return jobs
end

Config.Jobs = {
    {
        id = "lumberjack",
        title = "Drwal",
        category = {
            name = "physical",
            label = "Praca Fizyczna"
        },
        description = "Ścinanie drzew i przygotowywanie drewna. Praca na świeżym powietrzu.",
        image = "https://forum-cfx-re.akamaized.net/original/5X/4/0/7/6/4076173c593099975854503e931371dd952580b0.gif",
        address = "1082 Paleto Forest",
        salary = "$9000/kurs",
        isAvailable = function() return IsJobAvailable('lumberjack') end
    },
    {
        id = "weazelnews",
        title = "Weazel News",
        category = {
            name = "reporters",
            label = "Informacyjna"
        },
        description = "Zbieranie informacji i relacjonowanie wydarzeń. Praca w mediach.",
        image = "https://static.wikia.nocookie.net/gtawiki/images/5/5f/WeazelNewsBuilding-GTAV.png/revision/latest?cb=20181010154009",
        address = "8144 Palomino Ave",
        salary = "$7000/kurs",
        isAvailable = function() return IsJobAvailable('weazelnews') end
    },
    {
        id = "postman",
        title = "Listonosz",
        category = {
            name = "physical",
            label = "Praca Fizyczna"
        },
        description = "Zbieranie listów z wyznaczonych miejsc. Praca w terenie.",
        image = "https://i.ibb.co/Zz2WWCJX/postman3.png",
        address = "8156 Vespucci Blvd",
        salary = "$10000/kurs",
        isAvailable = function() return IsJobAvailable('postman') end
    },
    {
        id = "garbage",
        title = "Śmieciarz",
        category = {
            name = "physical",
            label = "Praca Fizyczna"
        },
        description = "Zbieranie śmieci z miasta i dostarczanie ich do punktu utylizacji.",
        image = "https://i.ibb.co/8DfNLSRQ/garbage4.webp",
        address = "9030 Alta Street",
        salary = "$10000/kurs",
        isAvailable = function() return IsJobAvailable('garbage') end
    },
}