fx_version "cerulean"
game "gta5"
lua54 "yes"

name 'UZ Scripts - Typhon Shop'
description "Need help or have questions? Reach out to us on Discord: https://github.com/uz-scripts/Typhon-Shop"
repository 'https://uzscripts.com/scripts/typhon-shop'
version '1.1.0'
author "UZ Scripts, Lenix (Trippler Hub Organization)"


ui_page "ui/index.html"

shared_scripts { "@ox_lib/init.lua", "config/*.lua", "locales/*.lua" }

client_scripts { "client/*.lua", "client/imports.lua" }

server_scripts { "server/*.lua", "server/imports.lua", "@oxmysql/lib/MySQL.lua" }

files { "ui/**/*" }

dependency '/assetpacks'