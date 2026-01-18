

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Chciałem to se zajebałem'
description 'Exotic additional AC'

shared_scripts {
    '@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua',
}