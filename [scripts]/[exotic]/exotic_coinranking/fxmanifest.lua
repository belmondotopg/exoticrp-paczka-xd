

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author "vowki@MakeIT for ExoticRP"
description "Time Shop and Ranking"

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/functions.lua',
    'server/artifacts.lua',
    'server/events.lua',
    'server/leaderboard.lua',
    'server/coinAdding.lua'
}

ui_page 'ui/index.html'

files {
    'ui/**',
}