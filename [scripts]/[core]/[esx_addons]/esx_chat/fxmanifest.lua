

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'QF Developers'
description 'ESX Chat System with Advanced Features'
version '1.0.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
	'@ox_lib/init.lua',
	's_config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}