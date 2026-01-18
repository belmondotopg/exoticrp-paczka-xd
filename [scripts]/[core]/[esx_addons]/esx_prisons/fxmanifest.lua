

fx_version "cerulean"
game "gta5"
author "Pickle Mods"
version "v1.1.6"
ui_page "nui/index.html"
files {
	"nui/index.html",
	"nui/assets/**/*.*",
}
shared_scripts {
	"@ox_lib/init.lua",
	'@esx_hash/hasher.lua',
	'@es_extended/imports.lua',
	"config.lua",
	"locales/locale.lua",
    "locales/translations/*.lua",
    "core/shared.lua"
}
server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"bridge/**/**/server.lua",
	"modules/**/server.lua",
}
lua54 'yes'
