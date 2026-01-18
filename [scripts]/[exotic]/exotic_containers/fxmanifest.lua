

fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
author 'zykem'
game 'gta5'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/init.lua'
}

server_scripts {
    'server/init.lua'
}

files {
    'client/modules/**/**',
    'config/*.lua'
}