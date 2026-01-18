-- ──────────────────────────────────────────────────────────────────────────────
-- Turf Zones System Configuration                                             
-- (Information) ► Controls all core behavior of Turf Zones, including graffiti,
--        racketeering, rivalry conflicts and drug-selling influence.
-- ──────────────────────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────────────────────
-- Turf Zones Base                                                             
-- (Information) ► Enables or disables the entire turf zone mechanic.
-- ──────────────────────────────────────────────────────────────────────────────
Config.DisableTurfZones = false              -- Disable all Turf Zone features
Config.DisableEnterNotifications = true      -- Disable enter/leave zone notifications

-- ──────────────────────────────────────────────────────────────────────────────
-- Rivalry System                                                              
-- (Information) ► A timed gang–vs–gang conflict inside a turf zone.
-- (Information) ► EXP and costs scale with your server economy.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Rivalry = {
    Disable = false,           -- Disable/Enable rivalry system
    RivalryStartPrice = 30000,  -- Cost (dirty money). Set to 0 for free rivalry.
    RivalryDuration = 1,       -- Duration in HOURS
    RivalryWinEXP = 250,       -- EXP reward for winning rivalry
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Graffiti System                                                             
-- (Information) ► Allows gangs to paint and remove graffiti inside turf zones.
-- (Information) ► Graffiti contributes to zone loyalty and gang EXP.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Graffiti = {
    Disable = false,             -- Disable/Enable graffiti system
    RenderDistance = 70.0,       -- Distance at which graffiti becomes visible
    CooldownTime = 1,            -- Minutes between spraying graffiti
    CooldownTimeRemover = 1,     -- Minutes between removing graffiti

    Items = {                    -- Required items
        graffitiSpray = "spray_can",
        graffitiRemover = "spray_remover"
    },

    loyality = {                 -- Loyalty mechanics
        LoyalityPerGraffiti = 75,     -- Loyalty gained when gang paints graffiti
        loyalityIncreaseOnRemove = 15, -- Loyalty for removing enemy graffiti
        loyalityDecreaseOnRemove = 15, -- Loyalty lost when enemy removes your graffiti
        loyalityDecreaseOnPaint = 5,   -- Loyalty lost when enemy paints in your zone
        -- Zone ownership changes when a gang reaches ≥51% loyalty.
    },

    exp = {
        SprayingEXPgain = 50,         -- EXP for successfully spraying
        RemovingGraffitiEXPgain = 50  -- EXP for removing enemy graffiti
        -- Note: Removing your own graffiti gives no EXP.
    },

    -- Turf zone graffiti blips (only visible to gang members)
    Blip = {
        Enable = true,
        Radius = 50.0,                -- Min 25. Larger radius = bigger zone highlight.
    },

    Settings = {
        MaxSize = 9.75,               -- Optimal max graffiti size
        MinSize = 1.75,               -- Optimal min graffiti size
    },

    CleanGraffitiInterval = 24,       -- Every X hours all graffiti is auto-cleaned
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Racketeering System                                                         
-- (Information) ► “Protection” spots generating EXP and rewards for controlling gangs.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Racketeering = {
    DisableBlips = true,   -- True = disables blips on map for racketeering
    Cooldown = 30,          -- Minutes between collect attempts
    Exp = 50,               -- EXP for claiming a racketeering point
    Blip = {
        BlipId = 358,
        BlipColor = 1,
    }
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Drug Selling Integration                                                    
-- (Information) ► Influence for selling drugs inside turf zones.
-- (Information) ► Supports custom drug scripts via integrations.
-- ──────────────────────────────────────────────────────────────────────────────

local drugSellingAvailable = {
    ['drugs_creator'] = "jaksam_drugs",
    ['envi-trap-phone'] = "envi-trapphone",
}

Config.DrugSelling = {
    expOnDrugSell = 15,         -- EXP per drug transaction in zone

    loyality = {
        -- Ownership uses the ≥51% loyalty rule
        LoyalityPerTransaction = 30,  -- Loyalty gained when gang sells drugs in zone
        loyalityDecreaseOnOtherOrgs = 10 -- Loyalty lost when OTHER gang sells in your zone
    },

    -- Integration Drug Script (follow docs to integrate)
    -- (Information) ► This is regarding fetching data of sold drugs inside turf zones to add loyality etc.

    DrugScript = scriptCheck(drugSellingAvailable) or 'none',

    -- Full integration documentation:
    -- https://docs.otherplanet.dev/scripts/op-gangs/integrations
    --
    -- Fully supported (no config change needed):
    -- - op-drugselling (FREE)
    -- - nc-drugselling
    -- - visualz_selldrugs
    -- - tk_drugs
    -- - lunar_drugscreator
    -- - fs_trapphone
    -- - lation_selling
}