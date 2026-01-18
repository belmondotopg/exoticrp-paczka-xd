

game 'gta5'
fx_version 'cerulean'
lua54 'yes'

dependency 'esx_hud'

shared_script 'config.lua'

server_scripts { 
	'@oxmysql/lib/MySQL.lua', 

	'server/main.lua',
	'server/commands.lua',
	'server/classes/**/*.lua',
}

client_scripts {  
	'client/main.lua'
}

export 'IsInArena'