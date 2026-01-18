fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'esx_hud'

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

ui_page 'web/dist/index.html'

files {
	'web/dist/index.html',
	'web/dist/**/*'
}