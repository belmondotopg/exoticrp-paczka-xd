

fx_version 'cerulean'
game 'gta5'
author 'pScripts - [tebex.pscripts.store]'
description 'Advanced Department of Justice Job'
version '1.0.0'
lua54 'yes'

ui_page 'web/index.html'

files {
    'locales/*.json',
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/img/*.png',
    'web/sounds/*.ogg',
    'web/tv.html',
    'web/player.html',
    'web/document.html',
    'stream/*.gfx',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

client_scripts {
    'bridge/client/*.lua',
    'target/*.lua',
    'modules/client/*.lua',
}

server_scripts {
    'bridge/server/*.lua',
    '@oxmysql/lib/MySQL.lua',
    'modules/server/*.lua',
}

escrow_ignore {
    'target/ox_target.lua',
    'target/qb-target.lua',
    'shared/config.lua',
    'shared/config.court_hearings.lua',
    'shared/config.metal_detector.lua',
    'shared/config.printers.lua',
    'modules/server/editable_functions.lua',
    'modules/client/editable_functions.lua',
    'bridge/client/esx.lua',
    'bridge/client/qb.lua',
    'bridge/client/qbox.lua',
    'bridge/server/esx.lua',
    'bridge/server/qb.lua',
    'bridge/server/qbox.lua'
}
dependency '/assetpacks'