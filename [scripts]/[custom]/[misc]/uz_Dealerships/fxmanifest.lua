

fx_version "cerulean"
game "gta5"
lua54 "yes"

name 'UZ Scripts - Vehicle Shop'
description "Need help or have questions? Reach out to us on Discord: discord.uz-scripts.com"
repository 'https://uz-scripts.com/scripts/vehicle-shop'
version '1.1.3'
author "UZ Scripts"

ui_page "resources/build/index.html"

shared_scripts { "customize/*.lua", "locales/*.lua", "shared/*.lua" }

client_script "client/**/*.lua"

server_scripts {"server/*.lua", "@oxmysql/lib/MySQL.lua"}

files {
  "resources/build/**/*",
  "resources/images/**/*",
  "background/*.*",
  "vehicle_images/*.*"
}

escrow_ignore { "customize/*.lua", "locales/*.lua" }



-- v1.0.1
-- Fixed an issue where interactions were not visible during finance and purchase processes.
-- 25/06/2025

-- v1.0.2
-- new version control system - server/version.lua
-- part interaction fixed/edited - client/modules/part-interaction.lua, client/utils/camera.lua, resources/*
-- player dummy minor fix - client/modules/showroom.lua
-- 26/06/2025

-- v1.0.3
-- 🔧 Fixed an issue where vehicles in the showroom were visible to other players. - client/modules/showroom.lua
-- 30/06/2025

-- v1.0.4
-- new translations (de, bg, es, fr, it, pt) - locales/*
-- 03/07/2025

-- v1.0.5
-- custom plate format added - customize/Customize.lua, client/modules/purchase.lua
-- job check added - client/modules/showroom.lua, customize/vehicles-Customize.lua, customize/dealerships-Customize.lua
-- new translations - locales/*
-- 08/07/2025 -- fxmanifest.lua

-- v1.0.6
-- 🔧 Fixed an issue caused by a control that occurs when the player is not active on the server. - server/main.lua
-- 📝 Added and edited some language files - locales/*
-- 13/07/2025

-- v1.0.7
-- Added CameraAnimation (AutoCamDistVehicleAnim = false in customize.lua) - customize/Customize.lua
-- Added uiColor customized for each gallery (uiColor = { r = 255, g = 255, b = 195 } value in dealerships-Customize.lua) - customize/dealerships-Customize.lua
-- Improved ped position - client/modules/showroom.lua
-- Improved showroom car spawn - client/modules/showroom.lua, client/utils/camera.lua
-- 27/07/2025 -- fxmanifest.lua, resources/*

-- v1.0.8
-- Move vehicle database insert to server-Customize.lua
-- vehicle_images
-- 12/08/2025 -- fxmanifest.lua, server/purchase.lua, customize/server-Customize.lua

-- v1.1.0
--  feat: showroom improvements - search, performance & stability

--  Search:
--  - Real-time filtering by name/brand/model/category
--  - Dynamic category counts based on results
--  - Auto-clear on UI close

--  Performance:
--  - Optimize vehicle loading (50ms checks, 3 retries)
--  - Add collision/streaming priorities
--  - Fix hanging on slow connections

--  Stability:
--  - Disable empty category selection
--  - Fix NUI callback errors on right-click
--  - Add proper error handling

--  Significantly improves showroom user experience and reliability
-- 22/08/2025 -- fxmanifest.lua, resources/*, client/modules/showroom.lua, client/modules/part-interaction.lua

-- v1.1.1
-- vehicleSelected fix
-- 22/08/2025 -- fxmanifest.lua, client/core/events.lua

-- v1.1.2
-- SpeedFormat: mph/kmh
-- 2/10/2025 -- fxmanifest.lua, customize/Customize.lua, client/modules/showroom.lua, build/*

-- v1.1.3
-- SpeedValue: Fixed an issue where the vehicle speed display showed incorrect values
-- export: open finance & showroom
-- exports['uz_Dealerships']:openFinanceList() - exports['uz_Dealerships']:openShowroom(number)
-- 9/10/2025 -- fxmanifest.lua, client/modules/showroom.lua, client/modules/financing.lua
dependency '/assetpacks'