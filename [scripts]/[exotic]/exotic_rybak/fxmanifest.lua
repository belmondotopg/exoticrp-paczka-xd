

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'zbychu & michal k. company'
description 'Exotic Rybak'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_target',
    'ox_lib',
    'ox_inventory'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/*.js',
    'html/assets/*.css',
    'html/assets/*.png',
    'html/*.svg'
}

client_export 'openClam'