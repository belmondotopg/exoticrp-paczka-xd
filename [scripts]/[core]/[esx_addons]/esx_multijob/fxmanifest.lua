

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'

shared_scripts {
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
	'web/build/**/*',
}