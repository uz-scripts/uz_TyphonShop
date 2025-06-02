fx_version "cerulean"
game "gta5"
lua54 "yes"

name 'UZ Scripts - Typhon Shop'
description "Need help or have questions? Reach out to us on Discord: https://github.com/uz-scripts/Typhon-Shop"
repository 'https://uzscripts.com/scripts/typhon-shop'
version '1.0.0'
author "UZ Scripts"


ui_page "ui/index.html"

shared_scripts { "@ox_lib/init.lua", "customize/*.lua", "locales/*.lua" }

client_scripts { "client/*.lua", "services/client.lua" }

server_scripts { "server/*.lua", "services/server.lua", "@oxmysql/lib/MySQL.lua" }

files { "ui/**/*" }

escrow_ignore { "**/*" }