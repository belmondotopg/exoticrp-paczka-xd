

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'niemiecki216 // discord.gg/placzkiniemca'

shared_scripts {
    '@es_extended/imports.lua',
    '@esx_hash/hasher.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*'
}

dependencies {
    'es_extended',
    'oxmysql'
}