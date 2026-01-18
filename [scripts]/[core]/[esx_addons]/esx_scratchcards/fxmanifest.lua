fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.0'
author 'QF Developers'
description 'esx_scratchcards'
shared_scripts {
	'@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
	'@ox_lib/init.lua'
}

server_scripts {
	'server/*.lua'
}

ui_page 'html/index.html'
files {
    'html/index.html',
	'html/styles.css',
	'html/scripts.js',
	'html/img/*.png',
	'html/font/Transistor.css'
}