
fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'exotic_flyrent'

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    '@ox_lib/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*',
}