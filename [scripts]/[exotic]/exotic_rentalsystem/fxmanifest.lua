

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'shevey'
description 'exotic rentalsystem'

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_target'
}