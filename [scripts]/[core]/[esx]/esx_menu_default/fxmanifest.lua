

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'esx_menu_default'
shared_scripts {
	'@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
	'@ox_lib/init.lua'
}
client_scripts {
	'@es_extended/client/modules/wrapper.lua',
}
ui_page {
	'html/ui.html'
}
files {
	'html/ui.html',
	'html/css/app.css',
	'html/js/mustache.min.js',
	'html/js/app.js',
	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',
}