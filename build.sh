#! /bin/bash

 # Auto Build GSIs for ErfanGSIs (kmou424 fork)
 #
 # Copyright (c) 2018-2021 kmou424 <me@kmou424.moe>
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 #      http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 #


# Function to show an informational message
msg() {
	echo
	echo -e "\e[1;32m$*\e[0m"
	echo
}

err() {
	echo -e "\e[1;41m$*\e[0m"
	exit 1
}

cdir() {
	cd "$1" 2>/dev/null || \
		err "The directory $1 doesn't exists !"
}

##------------------------------------------------------##
##---------Prepare For Environment Variables------------##

# Push ZIP to Telegram. 1 is YES | 0 is NO(default)
PTTG=1
	if [ $PTTG = 1 ]
	then
		# Set Telegram Chat ID
		CHATID="-517381703"
	fi

DISTRO=$(cat /etc/issue)
KBUILD_BUILD_HOST=$(uname -a | awk '{print $2}')
TERM=xterm
BOT_MSG_URL="https://api.telegram.org/bot$token/sendMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$token/sendDocument"
export KBUILD_BUILD_HOST CI_BRANCH TERM BOT_MSG_URL BOT_BUILD_URL

## Check for CI
if [ -n "$CI" ]
then
	if [ -n "$CIRCLECI" ]
	then
		export KBUILD_BUILD_VERSION=$CIRCLE_BUILD_NUM
		export KBUILD_BUILD_HOST="CircleCI"
	fi
fi

# Set Date
DATE=$(export TZ=UTC-8; date +"%Y%m%d-%H%M%S")

# Function for telegram bot
tg_post_msg() {
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$CHATID" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}

tg_post_build() {
	#Post MD5Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$CHATID"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$2 | <b>MD5 Checksum : </b><code>$MD5CHECK</code>"
}
#--------------------------#

prepare_env() {
	echo " "
	msg "|| Preparing Environment ||"
	bash setup.sh
	bash build_scripts/firmware_info
}

build_gsi() {
	if [ "$PTTG" = 1 ]
 	then
		tg_post_msg "<b>第$KBUILD_BUILD_VERSION次任务开始了哦</b>%0A<b>操作系统 : </b><code>$DISTRO</code>%0A<b>内核-版本 : </b><code>$KERNEL_NAME</code>%0A<b>Linux 版本 : </b><code>$KERVER</code>%0A<b>日期 : </b><code>$(export TZ=UTC-8; date)</code>%0A<b>CI 服务商 : </b><code>$KBUILD_BUILD_HOST</code>%0A<b>核心数 : </b><code>$PROCS</code>%0A"
	fi

	msg "|| Started Build ||"
	./url2GSI.sh $FIRMWARE_LINK $FIRMWARE_OS 2>&1 | tee build.log
}

gen_output() {
	msg "|| Compressing Output Files ||"

	mkdir /tmp/output
	mv output/* /tmp/output/
	#if [ "$PTTG" = 1 ]
 	#then
	#	tg_post_build "$ZIP_FINAL.zip" "好耶! 构建成功了"
	#fi
}

upload_log() {
	if [ $LOG_DEBUG = "1" ]
	then
		tg_post_build "build.log" "好耶! 来康康log吧" "Debug Mode Logs"
	fi
}

prepare_env
build_gsi
gen_output
upload_log