

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'Interactions'

shared_scripts {
    '@es_extended/imports.lua',
}

client_scripts{
	"client/*.lua"
}

ui_page 'web/build/index.html'

files {
	'web/build/index.html',
	'web/build/**/*',
}