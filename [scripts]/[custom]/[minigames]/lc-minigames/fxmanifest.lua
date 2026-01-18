

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Zackaery'
description 'Minigame System w/Admin Panel'
version '1.0.7'

-- ui_page 'http://localhost:5173/'
ui_page 'web/build/index.html'

shared_scripts {
    "@ox_lib/init.lua",
	'config.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}

files {
	'web/assets/**/*',
	'web/build/**/*',
}

escrow_ignore {
	'**/*'
}

dependency 'lc-settings'
dependency '/assetpacks'