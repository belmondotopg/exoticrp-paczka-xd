fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'esx_menu'
shared_scripts {
	'@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
	'@ox_lib/init.lua'
}
client_scripts {
	'hasher/files/client/*.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}
ui_page 'web/index.html'
files {
	"web/js/*",
	"web/js/models/*",
	"web/img/*",
	"web/index.html",
}
