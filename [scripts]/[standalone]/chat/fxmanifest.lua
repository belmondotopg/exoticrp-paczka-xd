

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'QF Developers'
description 'Chat system for FiveM'
version '1.0.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@esx_hash/hasher.lua',
	'@ox_lib/init.lua',
	'config.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}
ui_page 'html/index.html'
files {
  'html/index.html',
  'html/index.css',
  'html/config.default.js',
  'html/App.js',
  'html/Message.js',
  'html/Suggestions.js',
  'html/vendor/vue.2.3.3.min.js',
  'html/vendor/flexboxgrid.6.3.1.min.css',
  'html/vendor/animate.3.5.2.min.css'
}