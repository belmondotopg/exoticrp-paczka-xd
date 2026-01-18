

fx_version 'cerulean'
game 'gta5'
author 'Streat Team'
description 'discord.gg/piotreqscripts'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/app.js',
    'web/style.css'
}