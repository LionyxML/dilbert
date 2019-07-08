#!/bin/bash
# dilbert.sh - Downloads Dilbert.com strips 
#
# Requires     : w3m, wget, dialog, some viewer (fbi and feh)
# Author       : Rahul Martim Juliato (rahul.juliato@gmail.com)
#
# Version 1    : Initial (22.05.2017)
# Version 2    : Distinguish between X and tty, calling dif viewers (08.07.2017)
# Version 3    : Added --keep option (18.07.2017)
# Version 4    : Added --quiet_keep  (25.02.2019)
# Version 5    : Added macos support (14.06.2019)
# Version 6    : Fixed bug on macos asking for $DISPLAY variable


case "$OSTYPE" in
  linux*)   CMD_SED="sed" && VIEWER="fbi -a" ;;
  darwin*)  CMD_SED="gsed" && VIEWER="qlmanage -p" ;;
  *)        echo "Not supported OS" && exit 1 ;;
esac

BASE_URL=dilbert.com/strip/
TARGET_DATE=$( date +%Y-%m-%d )
LOCAL_FILE=dilbert_temp.gif
KEEP=0
QUIET=0
MESSAGE="

Usage: $(basename "$0") [option]
(shows the latest comic strip if option is ommited)

[option] list:
--keep		Keeps $LOCAL_FILE file after quitting
--quiet_keep	Keeps $LOCAL_FILE file and don't run viewer
--select	Selects a date
--help		Shows this message
--version	Shows current version
"

case "$1" in
    --keep)
	KEEP=1
	;;
    --select)
	TARGET_DATE=$( dialog --stdout --date-format %Y-%m-%d --calendar "Select the date:" 0 0 0 0 0 )
	;;
    --quiet_keep)
	QUIET=1 
	KEEP=1
	;;
    --help)
	echo "$MESSAGE"
	exit 0
	;;
    --version)
	echo 
	sed -n "2p" "$0" | tr -d "#"
	grep -e "^# Ver" "$0" | tail -n 1 | cut -d ":" -f 1,2 | tr -d "#"
	grep -e "^# Aut" "$0" | cut -d ":" -f 2 | tr -d "#"
	echo
	exit 0
	;;
esac
	


rm -rf $LOCAL_FILE

echo -e "\nDownloading strip from $TARGET_DATE...\n"

URL=$BASE_URL$TARGET_DATE

wget --show-progress "http:"$( w3m -dump_source "$URL" | zcat | $CMD_SED -n "/img-comic-container/,+4p" | $CMD_SED -n 's/.*src="\([^"]*\)".*/\1/p' ) -O $LOCAL_FILE

[ $DISPLAY ] && [[ $OSTYPE == "linux*" ]] && VIEWER='feh ' 

[[ $QUIET == 0  ]] && $VIEWER $LOCAL_FILE

[[ $KEEP == 0 ]] && {
    rm -rf $LOCAL_FILE
}

