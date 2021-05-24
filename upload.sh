#! /bin/bash

tg_post_msg() {
        BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
	TEXT="$1"
	until [ $(echo -n "$TEXT" | wc -m) -eq 0 ]; do
	res=$(curl -s "$BOT_MSG_URL" -d "chat_id=-517381703" -d "text=$(urlencode "${TEXT:0:4096}")" -d "parse_mode=markdown" -d "disable_web_page_preview=true")
	TEXT="${TEXT:4096}"
	done
}

upload_link() {
        tg_post_msg "<b>GSI $RELEASE_TAG_NAME 制作完成: </b>[下载](https://github.com/kmou424/auto_build_gsi/releases/tag/$RELEASE_TAG_NAME)"
}

upload_link
