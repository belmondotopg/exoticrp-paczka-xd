

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'kariee'
this_is_a_map 'yes'
shared_scripts {
	'@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
    'config/config.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua', --// Use this SQL system for better optimization and functions
    'server/main.lua'
}
ui_page 'web/build/index.html'
files {
    'web/build/index.html',
	'web/build/**/*',
    'web/images/*.png'
}
dependencies {
    'oxmysql', -- Required for proper operation of tablet queries. Also supported "oxmysql".
    '/server:4752', -- ⚠️PLEASE READ⚠️ This requires at least server build 4700 or higher
}
escrow_ignore {
    'config/config.lua',
    "client/main.lua",
    'server/main.lua'
}