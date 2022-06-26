version '1.0.0'
author 'Hoang Phan <hoangpn@live.com>'
description 'Betting'
fx_version 'cerulean'
game 'gta5'

shared_script 'shared/config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

files {
    '**.html', '**.css', '**.js', '**.jpg', '**.png', '**.eot', '**.svg', '**.ttf', '**.woff', '**.woff2'
}

ui_page 'html/index.html'