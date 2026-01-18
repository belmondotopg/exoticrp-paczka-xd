

fx_version 'cerulean'
game 'gta5'
author 'meow meow meow?'
description 'Drugs'
lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/config.weed.lua'
}