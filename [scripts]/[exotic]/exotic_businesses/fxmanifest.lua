

fx_version 'cerulean'
games { 'gta5' }
author 'Michaś | https://github.com/Michas223'
description 'example'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/classes/business.lua',
    'server/functions.lua',
    'server/main.lua'
}
