

fx_version 'cerulean'
game 'gta5'
description 'ESX DMV School'
version '1.0'
legacyversion '1.9.1'
lua54 'yes'
shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'@ox_lib/init.lua',
	'config.lua'
}

client_scripts{
	"hasher/files/client/main.lua"
}

server_scripts {
	'server/main.lua',
}