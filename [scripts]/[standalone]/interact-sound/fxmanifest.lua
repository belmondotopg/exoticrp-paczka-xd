

fx_version 'cerulean'
games {"rdr3","gta5"}
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua'
}

client_scripts{
  "client/main.lua"
}

server_script 'server/main.lua'
ui_page "html/index.html"
files {
  'html/index.html',
  'html/sounds/*.ogg',
}
