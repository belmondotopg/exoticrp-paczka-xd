

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'exotic_cashregister'
shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server_cooldown.lua',
    'server.lua'
}