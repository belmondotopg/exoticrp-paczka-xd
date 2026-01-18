Config = Config or {}

-- Here you can set the dependencies that you are using
Config.Dependencies = {
    -- ⚠️ If set to true, the script will try to detect all the dependencies automatically and check export names
    automaticDetection = true,

    --
    -- ⚠️ All dependencies variables below will be overwritten if automaticDetection is set to true ⚠️
    --

    bankingScripts = {
        -- If you're still using the version of qb-banking with qb-management where qb-management handles the money or not using qb-banking at all, set this to false
        qbBanking = false,

        -- If you're using Renewed-Banking (with at least v2.0.0, set this to true otherwise set it to false
        renewedBanking = false,
    },

    -- If you're using qb-management, set this to true otherwise set it to false
    qbManagement = false,

    -- Here, you can set which inventory script you're using
    inventoryScripts = {
        -- If you're using qb-inventory, set this to true otherwise set it to false
        qbInventory = false,
        -- If you're using ox-inventory, set this to true otherwise set it to false
        oxInventory = true,
        -- If you're using qs-inventory, set this to true otherwise set it to false
        qsInventory = false
    },

    -- If you're using qb-target, set this to true otherwise set it to false
    qbTarget = false,
    -- If you're using ox_target, set this to true otherwise set it to false
    oxTarget = true
}

-- ⚠️ You need to verify that the following scripts are exactly named like this or change the names here
Config.ExportNames = {
    -- QBCore scripts
    qbBanking = "qb-banking",
    qbManagement = "qb-management",

    -- Banking scripts
    renewedBanking = "Renewed-Banking",

    -- Inventory scripts
    qbInventory = "qb-inventory",
    oxInventory = "ox_inventory",
    qsInventory = "qs-inventory",

    -- Target scripts
    qbTarget = "qb-target",
    oxTarget = "ox_target"
}
