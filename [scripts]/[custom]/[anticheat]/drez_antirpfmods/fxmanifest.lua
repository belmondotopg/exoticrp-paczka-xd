

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author "Drez https://github.com/Drezx | https://drez.tebex.io/"


client_scripts {
    "config/client.config.lua",
    "client/*.lua",
}

server_scripts {
    "config/client.config.lua",
    "config/server.config.lua",
    "server/*.lua",
}

escrow_ignore {
    "config/*.lua",
    "server/log.lua",
    "server/buckets.lua",
    "client/utility.lua",
    "client/skin.lua",
}
dependency '/assetpacks'