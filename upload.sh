#! /bin/bash

urlencode() {
    echo "$*" | sed 's:%:%25:g;s: :%20:g;s:<:%3C:g;s:>:%3E:g;s:#:%23:g;s:{:%7B:g;s:}:%7D:g;s:|:%7C:g;s:\\:%5C:g;s:\^:%5E:g;s:~:%7E:g;s:\[:%5B:g;s:\]:%5D:g;s:`:%60:g;s:;:%3B:g;s:/:%2F:g;s:?:%3F:g;s^:^%3A^g;s:@:%40:g;s:=:%3D:g;s:&:%26:g;s:\$:%24:g;s:\!:%21:g;s:\*:%2A:g'
}

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
