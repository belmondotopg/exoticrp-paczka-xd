
-- ===================== Official Information ================================================

author 'Zackaery --- Lost Code'
description 'Database Player Stored Settings'
version '1.1'

-- ====================== Code Configuration =================================================

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

-- ==================== Resource Configuration ===============================================

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server.lua',
}

escrow_ignore {
    'config.lua',
    'server.lua'
}

dependency '/assetpacks'