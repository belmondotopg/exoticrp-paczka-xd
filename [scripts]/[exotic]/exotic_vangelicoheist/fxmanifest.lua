fx_version 'cerulean'
author 'zykem'
game 'gta5'
lua54 'yes'

shared_scripts {
    "@es_extended/imports.lua",
    "@ox_lib/init.lua",
    "config/main.lua"
}

client_scripts {
    "client/utils.lua",
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

files {
    "config/*.lua",
}