shared_script '@ox_lib/init.lua'

fx_version "cerulean"
game "gta5"
lua54 "yes"

author "yankes"
version "1.0.0"

ui_page "web/build/index.html"

files {
    "web/build/**"
}

client_script "client/main.lua"