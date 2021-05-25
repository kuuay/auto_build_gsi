#! /bin/bash

tg_post_msg_html() {
	BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="-517381703" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}

urlencode() {
    echo "$*" | sed 's:%:%25:g;s: :%20:g;s:<:%3C:g;s:>:%3E:g;s:#:%23:g;s:{:%7B:g;s:}:%7D:g;s:|:%7C:g;s:\\:%5C:g;s:\^:%5E:g;s:~:%7E:g;s:\[:%5B:g;s:\]:%5D:g;s:`:%60:g;s:;:%3B:g;s:/:%2F:g;s:?:%3F:g;s^:^%3A^g;s:@:%40:g;s:=:%3D:g;s:&:%26:g;s:\$:%24:g;s:\!:%21:g;s:\*:%2A:g'
}

tg_post_msg_md() {
        BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
	TEXT="$1"
	until [ $(echo -n "$TEXT" | wc -m) -eq 0 ]; do
	res=$(curl -s "$BOT_MSG_URL" -d "chat_id=-517381703" -d "text=$(urlencode "${TEXT:0:4096}")" -d "parse_mode=markdown" -d "disable_web_page_preview=true")
	TEXT="${TEXT:4096}"
	done
}

upload_notice() {
	tg_post_msg_html "<b>第$KBUILD_BUILD_VERSION次任务已完成($1)</b>%0A<b>操作系统 : </b><code>$DISTRO</code>%0A<b>CI 服务商 : </b><code>$KBUILD_BUILD_HOST</code>%0A<b>日期 : </b><code>$(export TZ=UTC-8; date)</code>%0A%0A<b>固件信息:</b>%0A<b>机型 : </b><code>$FIRMWARE_MODEL [$FIRMWARE_DEVICE]</code>%0A<b>OS : </b><code>$FIRMWARE_OS</code>%0A<b>来源 : </b><code>$FIRMWARE_LINK</code>"
}
upload_link() {
        tg_post_msg_md "**GSI $RELEASE_TAG_NAME 制作完成:** [下载](https://github.com/kmou424/auto_build_gsi/releases/tag/$RELEASE_TAG_NAME-$1)"
}

upload_notice $1
upload_link $1
