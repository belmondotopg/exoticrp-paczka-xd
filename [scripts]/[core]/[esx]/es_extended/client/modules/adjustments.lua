Adjustments = {}

function Adjustments:RemoveHudComponents()
    for i = 1, #Config.RemoveHudComponents do
        if Config.RemoveHudComponents[i] then
            SetHudComponentSize(i, 0.0, 0.0)
            SetHudComponentPosition(i, 900.0, 900.0)
        end
    end
end

function Adjustments:DisableAimAssist()
    if Config.DisableAimAssist then
        SetPlayerTargetingMode(3)
    end
end

function Adjustments:DisableNPCDrops()
    if Config.DisableNPCDrops then
        local weaponPickups = { `PICKUP_WEAPON_CARBINERIFLE`, `PICKUP_WEAPON_PISTOL`, `PICKUP_WEAPON_PUMPSHOTGUN` }
        for i = 1, #weaponPickups do
            ToggleUsePickupsForPlayer(ESX.playerId, weaponPickups[i], false)
        end
    end
end

function Adjustments:HealthRegeneration()
    if Config.DisableHealthRegeneration then
        SetPlayerHealthRechargeMultiplier(ESX.playerId, 0.0)
    end
end

function Adjustments:AmmoAndVehicleRewards()
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            if Config.DisableDisplayAmmo and IsPedArmed(ped, 4) then
                DisplayAmmoThisFrame(false)
                Wait(0)
            else
                Wait(1000)
            end
        end
    end)

    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            if Config.DisableVehicleRewards and IsPedInAnyVehicle(ped, false) then
                DisablePlayerVehicleRewards(ESX.playerId)
                Wait(0)
            else
                Wait(1000)
            end
        end
    end)
end


function Adjustments:EnablePvP()
    if Config.EnablePVP then
        SetCanAttackFriendly(ESX.PlayerData.ped, true, false)
        NetworkSetFriendlyFireOption(true)
    end
end

function Adjustments:LicensePlates()
    SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomAIPlates)
end

local placeHolders = {
    server_name = function()
        return GetConvar("sv_projectName", "ESX-Framework")
    end,
    server_endpoint = function()
        return GetCurrentServerEndpoint() or "localhost:30120"
    end,
    server_players = function()
        return GlobalState.playerCount or 0
    end,
    server_maxplayers = function()
        return GetConvarInt("sv_maxclients", 300)
    end,
    player_name = function()
        return GetPlayerName(ESX.playerId)
    end,
    player_rp_name = function()
        return ESX.PlayerData.name or "John Doe"
    end,
    player_id = function()
        return ESX.serverId
    end,
    player_street = function()
        if not ESX.PlayerData.ped then return "Unknown" end

        local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
        local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)

        return GetStreetNameFromHashKey(streetHash) or "Unknown"
    end,
}

function Adjustments:PresencePlaceholders()
    local presence = Config.DiscordActivity.presence

    for placeholder, cb in pairs(placeHolders) do
        local success, result = pcall(cb)

        if not success then
            error(("Failed to execute presence placeholder: ^5%s^7"):format(placeholder))
            error(result)
            return "Unknown"
        end

        presence = presence:gsub(("{%s}"):format(placeholder), result)
    end

    return presence
end

function Adjustments:DiscordPresence()
    if Config.DiscordActivity.appId ~= 0 then
        CreateThread(function()
            while true do
                SetDiscordAppId(Config.DiscordActivity.appId)
                SetDiscordRichPresenceAsset(Config.DiscordActivity.assetName)
                SetDiscordRichPresenceAssetText(Config.DiscordActivity.assetText)

                for i = 1, #Config.DiscordActivity.buttons do
                    local button = Config.DiscordActivity.buttons[i]
                    SetDiscordRichPresenceAction(i - 1, button.label, button.url)
                end

                SetRichPresence(self:PresencePlaceholders())
                Wait(Config.DiscordActivity.refresh)
            end
        end)
    end
end

function Adjustments:WantedLevel()
    if not Config.EnableWantedLevel then
        ClearPlayerWantedLevel(ESX.playerId)
        SetMaxWantedLevel(0)
    end
end

function Adjustments:DisableRadio()
    if Config.RemoveHudComponents[16] then
        AddEventHandler("esx:enteredVehicle", function(vehicle, plate, seat, displayName, netId)
            SetVehRadioStation(vehicle,"OFF")
            SetUserRadioControlEnabled(false)
        end)
    end
end

function Adjustments:Multipliers()
    CreateThread(function()
        while true do
            if ESX.PlayerLoaded and ESX.PlayerData.ped and DoesEntityExist(ESX.PlayerData.ped) then
                SetPedDensityMultiplierThisFrame(Config.Multipliers.pedDensity)
                SetScenarioPedDensityMultiplierThisFrame(Config.Multipliers.scenarioPedDensityInterior, Config.Multipliers.scenarioPedDensityExterior)
                SetAmbientVehicleRangeMultiplierThisFrame(Config.Multipliers.ambientVehicleRange)
                SetParkedVehicleDensityMultiplierThisFrame(Config.Multipliers.parkedVehicleDensity)
                SetRandomVehicleDensityMultiplierThisFrame(Config.Multipliers.randomVehicleDensity)
                SetVehicleDensityMultiplierThisFrame(Config.Multipliers.vehicleDensity)
                Wait(0)
            else
                Wait(1000)
            end
        end
    end)
end

function Adjustments:Load()
    self:RemoveHudComponents()
    self:DisableAimAssist()
    self:DisableNPCDrops()
    self:HealthRegeneration()
    self:AmmoAndVehicleRewards()
    self:EnablePvP()
    self:LicensePlates()
    self:DiscordPresence()
    self:WantedLevel()
    self:DisableRadio()
    self:Multipliers()
end