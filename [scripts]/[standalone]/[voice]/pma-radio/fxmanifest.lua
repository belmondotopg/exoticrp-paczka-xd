
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'pma-radio'
shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua'
}

client_scripts{
	"hasher/files/client/config.lua",
	"hasher/files/client/main.lua"
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	"server/*.lua",
}