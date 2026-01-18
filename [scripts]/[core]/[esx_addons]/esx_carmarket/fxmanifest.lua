

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'ESX Car Market - Giełda pojazdów'

shared_scripts {
    '@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts{
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/sql.lua',
	'server/testdrive.lua',
	'server/main.lua'
}

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**/*',
}