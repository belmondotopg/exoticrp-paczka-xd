Config = {}

Config.Token = "drez_antigiveweapon_token" -- security token, leave this alone


Config.Log = true -- Enable debug logs, set to false to disable
Config.LoopTime = 2000 -- Detection tick in milliseconds, recommended to keep it less than 5000ms and greater than 300ms. Default is ok

Config.AntiCitizenWeapon = true -- Detects when weapon is spawned by Citizen Mods (Only run once in initial thread, BEFORE Config.SyncHandle, use Config.CitizenSpawnSyncHandle instead), recommended to leave on true
Config.AntiSpoofedSpawn = true -- Detects when spoofed weapon is spawned (like a lot of execs does), recommended to leave on true
Config.AntiWeaponSpawn = true -- Detects normal weapon spawn (most lua menus, very primitive way), recommended to leave on true
Config.AntiSafeSpawn = false -- Detects when weapon is spawned in Safe way (similiar to Config.AntiSpoofedSpawn, eulen does that way - this method works on all *INVISIBLE* spawns), recommended to leave on true
Config.WeaponBlacklist = true -- Detects any weapon if blacklisted (defined in Config.WeaponList), recommended to leave on true and configure Config.WeaponList for your own or set to false if you already have blacklist
Config.AntiPickupSpawn = true -- Detects when weapon is spawned using pickups, recommended to leave on true if your server is not using pickup system (detectable pickups can be configured with Config.PickupList)
Config.AntiNetworkedSpawn = true -- Detects when weapon is spawned or removed in networked way (to another player), recommended to leave on true, if you encouter any issues use expection or contact me on discord


Config.ESXCheck = true -- Detects weapon spawning based on esx inventory, recommended to leave on true if you using ESX (DISABLE IF YOU USING QB)
Config.OldESX = false -- if Config.ESXCheck, this is old ESX method to get global Object - if you using event/export instead of manifest import set this to true
Config.OldESXSharedEvent = "esx:getSharedObject" -- Event name for Config.OldESX (this is default for ESX)

Config.QBCheck = false -- Detects weapon spawning based on qb inventory, recommended to leave on true if you using QB-Core (DISABLE IF YOU USING ESX)
Config.CustomFrameworkCheck = false -- Detects weapon spawning based on your CUSTOM/OTHER framework, needs to be configured with Config.HasWeaponInInventory, recommended to leave on false if you not using custom framework


---ONLY TRIGGERED WITH Config.CustomFrameworkCheck
---@param weaponName string -- weaponName is always one of Config.WeaponList keys
---@return boolean
Config.HasWeaponInInventory = function(weaponName)
    --[[ Example check with export (REMEMBER: this function can be expensive because its looped, recommended to not use any form of server callbacks in your check function)
        local hasWeapon <const> = exports["my_inventory"]:HasWeapon(weaponName)
        return hasWeapon
    ]]
    return true
end

Config.SyncHandle = function() -- Sync function for your own compatibility, this function is triggered on resource init (before detection tick), you can put your Wait or export code to make sure player is fully loaded. Not needed script to work, doesnt matter what you return here
    while not (exports['es_extended']:IsPlayerLoaded()) do
        Wait(500)
    end

    return true
end


Config.CitizenSpawnSyncHandle = function() -- Same as Config.SyncHandle, but this is for Config.AntiCitizenWeapon ONLY!
    while not (exports['es_extended']:IsPlayerLoaded()) do
        Wait(500)
    end

    return true
end

---@diagnostic disable-next-line: duplicate-set-field
Config.BypassException = function(weapon, spawnMethod) -- Bypass function for your own compatibility, not needed for the script to work. If you return false here, detection will be disabled until next loop tick
    return true
end

Config.BanEvent = function() -- Function triggered when weapon spawn detected, you can insert here screenshot/record code or whatever you want (but do not delay too much)
    -- example of screenshot-basic
    --[[
        local p = promise.new()
        exports['screenshot-basic']:requestScreenshotUpload(GetConvar('screenshot_url', 'https://wew.wtf/upload.php'), GetConvar("screenshotfield", 'files[]'), function(data)
            local resp = json.decode(data)
            local url = resp.attachments[1].proxy_url
            TriggerServerEvent('MyOwnScreenLog', url)
            
            p:resolve()
        end)
    
        Citizen.Await(p)
    ]]
end


-- Weapon list presents all known weapons for script, you can insert your custom weapons. 
---@type table<string, table<hash, boolean>>
Config.WeaponList = {
    ["WEAPON_SMG_MK2"] = {model = `w_sb_smgmk2`, blacklisted = false},
    ["WEAPON_SMG"] = {model = `w_sb_smg`, blacklisted = false},
    ["WEAPON_CERAMICPISTOL"] = {model = `w_pi_ceramic_pistol`, blacklisted = false},
    ["WEAPON_SWITCHBLADE"] = {model = `w_me_switchblade`, blacklisted = false},
    ["WEAPON_VINTAGEPISTOL"] = {model = `w_pi_vintage_pistol`, blacklisted = false},
    ["WEAPON_PDG19"] = {model = `w_pi_kyrospdg19g4`, blacklisted = false},
    ["WEAPON_BAT"] = {model = `W_ME_Bat`, blacklisted = false},
    ["WEAPON_DAGGER"] = {model = `w_me_dagger`, blacklisted = false},
    ["WEAPON_MARKSMANPISTOL"] = {model = `W_PI_SingleShot`, blacklisted = false},
    ["WEAPON_FLAREGUN"] = {model = `w_pi_flaregun`, blacklisted = false},
    ["WEAPON_GUSENBERG"] = {model = `w_sb_gusenberg`, blacklisted = false},
    ["WEAPON_BOTTLE"] = {model = `prop_w_me_bottle`, blacklisted = false},
    ["WEAPON_PUMPSHOTGUN"] = {model = `w_sg_pumpshotgun`, blacklisted = false},
    ["WEAPON_MINISMG"] = {model = `w_sb_minismg`, blacklisted = false},
    ["WEAPON_ASSAULTRIFLE"] = {model = `w_ar_assaultrifle`, blacklisted = false},
    ["WEAPON_RAYMINIGUN"] = {model = `W_MG_SMINIGUN`, blacklisted = false},
    ["WEAPON_PISTOL50"] = {model = `w_pi_pistol50`, blacklisted = false},
    ["WEAPON_DBSHOTGUN"] = {model = `w_sg_doublebarrel`, blacklisted = false},
    ["WEAPON_COMBATPISTOL"] = {model = `w_pi_combatpistol`, blacklisted = false},
    ["WEAPON_CARBINERIFLE_MK2"] = {model = `w_ar_carbineriflemk2`, blacklisted = false},
    ["WEAPON_CROWBAR"] = {model = `prop_ing_crowbar`, blacklisted = false},
    ["WEAPON_RPG"] = {model = `w_lr_rpg`, blacklisted = false},
    ["WEAPON_RAILGUN"] = {model = `w_ar_railgun`, blacklisted = false},
    ["WEAPON_PISTOL_MK2"] = {model = `w_pi_pistolmk2`, blacklisted = false},
    ["WEAPON_HEAVYSNIPER_MK2"] = {model = `w_sr_heavysnipermk2`, blacklisted = false},
    ["WEAPON_FLASHLIGHT"] = {model = `w_me_flashlight`, blacklisted = false},
    ["WEAPON_KNIFE"] = {model = `prop_w_me_knife_01`, blacklisted = false},
    ["WEAPON_RAYCARBINE"] = {model = `w_ar_srifle`, blacklisted = false},
    ["WEAPON_MARKSMANRIFLE_MK2"] = {model = `w_sr_marksmanriflemk2`, blacklisted = false},
    ["WEAPON_FIREWORK"] = {model = `w_lr_firework`, blacklisted = false},
    ["WEAPON_GRENADELAUNCHER_SMOKE"] = {model = `w_lr_grenadelauncher`, blacklisted = false},
    ["WEAPON_BALL"] = {model = `w_am_baseball`, blacklisted = false},
    ["WEAPON_HEAVYPISTOL"] = {model = `w_pi_heavypistol`, blacklisted = false},
    ["WEAPON_HEAVYSHOTGUN"] = {model = `w_sg_heavyshotgun`, blacklisted = false},
    ["WEAPON_ASSAULTRIFLE_MK2"] = {model = `w_ar_assaultriflemk2`, blacklisted = false},
    ["WEAPON_POOLCUE"] = {model = `w_me_poolcue`, blacklisted = false},
    ["WEAPON_BULLPUPRIFLE_MK2"] = {model = `w_ar_bullpupriflemk2`, blacklisted = false},
    ["WEAPON_MINIGUN"] = {model = `prop_minigun_01`, blacklisted = false},
    ["WEAPON_NIGHTSTICK"] = {model = `w_me_nightstick`, blacklisted = false},
    ["WEAPON_REVOLVER"] = {model = `w_pi_revolver`, blacklisted = false},
    ["WEAPON_BULLPUPRIFLE"] = {model = `w_ar_bullpuprifle`, blacklisted = false},
    ["WEAPON_STONE_HATCHET"] = {model = `w_me_stonehatchet`, blacklisted = false},
    ["WEAPON_ADVANCEDRIFLE"] = {model = `w_ar_advancedrifle`, blacklisted = false},
    ["WEAPON_PETROLCAN"] = {model = `prop_jerrycan_01a`, blacklisted = false},
    ["WEAPON_GOLFCLUB"] = {model = `prop_golf_iron_01`, blacklisted = false},
    ["WEAPON_COMBATMG"] = {model = `w_mg_combatmg`, blacklisted = false},
    ["WEAPON_DOUBLEACTION"] = {model = `w_pi_wep1_gun`, blacklisted = false},
    ["WEAPON_PIPEBOMB"] = {model = `w_ex_pipebomb`, blacklisted = false},
    ["WEAPON_SPECIALCARBINE_MK2"] = {model = `w_ar_specialcarbinemk2`, blacklisted = false},
    ["WEAPON_SMOKEGRENADE"] = {model = `w_ex_grenadesmoke`, blacklisted = false},
    ["WEAPON_SNSPISTOL_MK2"] = {model = `w_pi_sns_pistolmk2`, blacklisted = false},
    ["WEAPON_SNOWBALL"] = {model = `w_ex_snowball`, blacklisted = false},
    ["WEAPON_HAMMER"] = {model = `w_me_hammer`, blacklisted = false},
    ["WEAPON_SAWNOFFSHOTGUN"] = {model = `w_sg_sawnoff`, blacklisted = false},
    ["WEAPON_CARBINERIFLE"] = {model = `w_ar_carbinerifle`, blacklisted = false},
    ["WEAPON_COMBATPDW"] = {model = `w_sb_pdw`, blacklisted = false},
    ["WEAPON_MOLOTOV"] = {model = `w_ex_molotov`, blacklisted = false},
    ["WEAPON_STICKYBOMB"] = {model = `W_EX_PE`, blacklisted = false},
    ["WEAPON_PROXMINE"] = {model = `gr_prop_gr_pmine_01a`, blacklisted = false},
    ["WEAPON_ASSAULTSHOTGUN"] = {model = `w_sg_assaultshotgun`, blacklisted = false},
    ["WEAPON_BZGAS"] = {model = `prop_gas_grenade`, blacklisted = false},
    ["WEAPON_GRENADE"] = {model = `w_ex_grenadefrag`, blacklisted = false},
    ["WEAPON_SNIPERRIFLE"] = {model = `w_sr_sniperrifle`, blacklisted = false},
    ["WEAPON_COMBATMG_MK2"] = {model = `w_mg_combatmgmk2`, blacklisted = false},
    ["WEAPON_HOMINGLAUNCHER"] = {model = `w_lr_homing`, blacklisted = false},
    ["WEAPON_KNUCKLE"] = {model = `w_me_knuckle`, blacklisted = false},
    ["WEAPON_GRENADELAUNCHER"] = {model = `w_lr_grenadelauncher`, blacklisted = false},
    ["WEAPON_MARKSMANRIFLE"] = {model = `w_sr_marksmanrifle`, blacklisted = false},
    ["WEAPON_HEAVYSNIPER"] = {model = `w_sr_heavysniper`, blacklisted = false},
    ["WEAPON_MICROSMG"] = {model = `w_sb_microsmg`, blacklisted = false},
    ["WEAPON_COMPACTLAUNCHER"] = {model = `w_lr_compactgl`, blacklisted = false},
    ["WEAPON_MG"] = {model = `w_mg_mg`, blacklisted = false},
    ["WEAPON_PISTOL"] = {model = `w_pi_pistol`, blacklisted = false},
    ["WEAPON_REVOLVER_MK2"] = {model = `w_pi_revolvermk2`, blacklisted = false},
    ["WEAPON_APPISTOL"] = {model = `w_pi_appistol`, blacklisted = false},
    ["WEAPON_PUMPSHOTGUN_MK2"] = {model = `w_sg_pumpshotgunmk2`, blacklisted = false},
    ["WEAPON_MUSKET"] = {model = `w_ar_musket`, blacklisted = false},
    ["WEAPON_HATCHET"] = {model = `w_me_hatchet`, blacklisted = false},
    ["WEAPON_NAVYREVOLVER"] = {model = `w_pi_wep2_gun`, blacklisted = false},
    ["WEAPON_RAYPISTOL"] = {model = `W_PI_RAYGUN`, blacklisted = false},
    ["WEAPON_SPECIALCARBINE"] = {model = `w_ar_specialcarbine`, blacklisted = false},
    ["WEAPON_SNSPISTOL"] = {model = `w_pi_sns_pistol`, blacklisted = false},
    ["WEAPON_ASSAULTSMG"] = {model = `w_sb_assaultsmg`, blacklisted = false}
}


-- Pickup names for Config.AntiPickupSpawn
---@type table<hash>
Config.PickupList = {
    'PICKUP_WEAPON_ADVANCEDRIFLE','PICKUP_WEAPON_APPISTOL','PICKUP_WEAPON_ASSAULTRIFLE',
    'PICKUP_WEAPON_ASSAULTRIFLE_MK2','PICKUP_WEAPON_ASSAULTSHOTGUN','PICKUP_WEAPON_ASSAULTSMG',
    'PICKUP_WEAPON_AUTOSHOTGUN','PICKUP_WEAPON_BAT','PICKUP_WEAPON_BATTLEAXE',
    'PICKUP_WEAPON_BOTTLE','PICKUP_WEAPON_BULLPUPRIFLE','PICKUP_WEAPON_BULLPUPRIFLE_MK2',
    'PICKUP_WEAPON_BULLPUPSHOTGUN','PICKUP_WEAPON_CARBINERIFLE','PICKUP_WEAPON_CARBINERIFLE_MK2',
    'PICKUP_WEAPON_COMBATMG','PICKUP_WEAPON_COMBATMG_MK2','PICKUP_WEAPON_COMBATPDW',
    'PICKUP_WEAPON_COMBATPISTOL','PICKUP_WEAPON_COMPACTLAUNCHER','PICKUP_WEAPON_COMPACTRIFLE',
    'PICKUP_WEAPON_CROWBAR','PICKUP_WEAPON_DAGGER','PICKUP_WEAPON_DBSHOTGUN',
    'PICKUP_WEAPON_DOUBLEACTION','PICKUP_WEAPON_FIREWORK','PICKUP_WEAPON_FLAREGUN',
    'PICKUP_WEAPON_FLASHLIGHT','PICKUP_WEAPON_GRENADE','PICKUP_WEAPON_GRENADELAUNCHER',
    'PICKUP_WEAPON_GUSENBERG','PICKUP_WEAPON_GolfClub','PICKUP_WEAPON_HAMMER',
    'PICKUP_WEAPON_HATCHET','PICKUP_WEAPON_HEAVYPISTOL','PICKUP_WEAPON_HEAVYSHOTGUN',
    'PICKUP_WEAPON_HEAVYSNIPER','PICKUP_WEAPON_HEAVYSNIPER_MK2','PICKUP_WEAPON_HOMINGLAUNCHER',
    'PICKUP_WEAPON_KNIFE','PICKUP_WEAPON_KNUCKLE','PICKUP_WEAPON_MACHETE',
    'PICKUP_WEAPON_MACHINEPISTOL','PICKUP_WEAPON_MARKSMANPISTOL','PICKUP_WEAPON_MARKSMANRIFLE',
    'PICKUP_WEAPON_MARKSMANRIFLE_MK2','PICKUP_WEAPON_MG', 'PICKUP_WEAPON_MICROSMG',
    'PICKUP_WEAPON_MINIGUN','PICKUP_WEAPON_MINISMG','PICKUP_WEAPON_MOLOTOV',
    'PICKUP_WEAPON_MUSKET','PICKUP_WEAPON_NIGHTSTICK','PICKUP_WEAPON_PETROLCAN',
    'PICKUP_WEAPON_PIPEBOMB','PICKUP_WEAPON_PISTOL', 'PICKUP_WEAPON_PISTOL50',
    'PICKUP_WEAPON_PISTOL_MK2','PICKUP_WEAPON_POOLCUE','PICKUP_WEAPON_PROXMINE',
    'PICKUP_WEAPON_PUMPSHOTGUN','PICKUP_WEAPON_PUMPSHOTGUN_MK2','PICKUP_WEAPON_RAILGUN',
    'PICKUP_WEAPON_RAYCARBINE','PICKUP_WEAPON_RAYMINIGUN','PICKUP_WEAPON_RAYPISTOL',
    'PICKUP_WEAPON_REVOLVER','PICKUP_WEAPON_REVOLVER_MK2','PICKUP_WEAPON_RPG',
    'PICKUP_WEAPON_SAWNOFFSHOTGUN','PICKUP_WEAPON_SMG','PICKUP_WEAPON_SMG_MK2',
    'PICKUP_WEAPON_SMOKEGRENADE', 'PICKUP_WEAPON_BZGAS', 'PICKUP_WEAPON_SNIPERRIFLE','PICKUP_WEAPON_SNSPISTOL',
    'PICKUP_WEAPON_SNSPISTOL_MK2','PICKUP_WEAPON_SPECIALCARBINE','PICKUP_WEAPON_SPECIALCARBINE_MK2',
    'PICKUP_WEAPON_STICKYBOMB','PICKUP_WEAPON_STONE_HATCHET','PICKUP_WEAPON_STUNGUN',
    'PICKUP_WEAPON_SWITCHBLADE','PICKUP_WEAPON_VINTAGEPISTOL','PICKUP_WEAPON_WRENCH'
}

