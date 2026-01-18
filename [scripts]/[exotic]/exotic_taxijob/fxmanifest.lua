

fx_version "cerulean"

description "Basic React (TypeScript) & Lua Game Scripts Boilerplate"
author "Project Error"
version '1.0.0'
repository 'https://github.com/project-error/fivem-react-boilerplate-lua'

lua54 'yes'

games {"gta5"}

shared_scripts {
    '@es_extended/imports.lua', 
    '@es_extended/locale.lua', 
    '@ox_lib/init.lua',
    '@esx_hash/hasher.lua',
    "config.lua"
}

server_scripts {'@oxmysql/lib/MySQL.lua', 'server/main.lua'}

ui_page 'web/build/index.html'

files {'web/build/index.html', 'web/build/**/*'}
