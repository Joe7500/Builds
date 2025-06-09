#!/bin/bash

if ! echo "$@" | grep -iE "crdroid|lineage|axion" ; then
   echo "usage: lineage|crdroid major_version file"
   exit 1
fi 

PACKAGE="$1"
VERSION="$2"
INPUT_NAME="$3"
FILE_NAME=`basename $INPUT_NAME` || exit 1


if echo $PACKAGE | grep -i crdroid; then

MINOR_VERSION=`echo $FILE_NAME | cut -d . -f 3`
MD5=`md5sum $INPUT_NAME | cut -d " " -f 1`
SHA=`sha256sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 3`
TIMESTAMP=`date -d "$FILE_DATE 00:00:00" +%s` 

echo '{ "response": [{' > $FILE_NAME.json.txt
echo '"maintainer": "Joe",'  >> $FILE_NAME.json.txt
echo '"oem": "Xiaomi",' >> $FILE_NAME.json.txt
echo '"device": "POCO M3 & Redmi 9T",' >> $FILE_NAME.json.txt
echo '"'filename'"': '"'$FILE_NAME'"', >> $FILE_NAME.json.txt
echo '"'download'"': '"'https://sourceforge.net/projects/joes-android-builds/files/crDroid/$VERSION/$FILE_NAME/download'"', >> $FILE_NAME.json.txt
echo '"'timestamp'"': $TIMESTAMP, >> $FILE_NAME.json.txt
echo '"'md5'"': '"'$MD5'"', >> $FILE_NAME.json.txt
echo '"'sha256'"': '"'$SHA'"', >> $FILE_NAME.json.txt
echo '"'size'"': $SIZE, >> $FILE_NAME.json.txt
echo '"'version'"': '"'$VERSION.$MINOR_VERSION'"', >> $FILE_NAME.json.txt
echo '"buildtype": "Monthly",' >> $FILE_NAME.json.txt
echo '"forum": "https://sourceforge.net/projects/joes-android-builds/",' >> $FILE_NAME.json.txt
echo '"gapps": "",' >> $FILE_NAME.json.txt
echo '"firmware": "",' >> $FILE_NAME.json.txt
echo '"modem": "",' >> $FILE_NAME.json.txt
echo '"bootloader": "",' >> $FILE_NAME.json.txt
echo '"recovery": "",' >> $FILE_NAME.json.txt
echo '"paypal": "",' >> $FILE_NAME.json.txt
echo '"telegram": "https://t.me/joes_stuff",' >> $FILE_NAME.json.txt
echo '"dt": "https://github.com/Joe7500/device_xiaomi_chime",' >> $FILE_NAME.json.txt
echo '"common-dt": "",' >> $FILE_NAME.json.txt
echo '"kernel": "https://github.com/Joe7500/kernel_xiaomi_chime"' >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

exit 0
fi


if echo $PACKAGE | grep -i lineage; then

MINOR_VERSION=`echo $FILE_NAME | cut -d "-" -f 2 | cut -d . -f 2`
SHA=`sha256sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 3`
TIMESTAMP=`date -d "$FILE_DATE 00:00:00" +%s`

echo '{ "response": [{' > $FILE_NAME.json.txt
echo '"'datetime'"': '"'$TIMESTAMP'"', >> $FILE_NAME.json.txt
echo '"'filename'"': '"'$FILE_NAME'"', >> $FILE_NAME.json.txt
echo '"'id'"': '"'$SHA'"', >> $FILE_NAME.json.txt
echo '"romtype": "unofficial",' >> $FILE_NAME.json.txt
echo '"'size'"': '"'$SIZE'"', >> $FILE_NAME.json.txt
echo '"'url'"': '"'https://sourceforge.net/projects/joes-android-builds/files/LineageOS/$VERSION/$FILE_NAME/download'"',  >> $FILE_NAME.json.txt
echo '"'version'"': '"'$VERSION.$MINOR_VERSION'"'  >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

exit 0
fi

if echo $PACKAGE | grep -i axion; then

MINOR_VERSION=`echo $FILE_NAME | cut -d "-" -f 2 | cut -d . -f 2`
SHA=`sha256sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 4`
TIMESTAMP=`date -d "$FILE_DATE 00:00:00" +%s`

echo '{ "response": [{' > $FILE_NAME.json.txt
echo '"'datetime'"': '"'$TIMESTAMP'"', >> $FILE_NAME.json.txt
echo '"'filename'"': '"'$FILE_NAME'"', >> $FILE_NAME.json.txt
echo '"'id'"': '"'$SHA'"', >> $FILE_NAME.json.txt
echo '"romtype": "COMMUNITY",' >> $FILE_NAME.json.txt
echo '"'size'"': '"'$SIZE'"', >> $FILE_NAME.json.txt
echo '"'url'"': '"'https://sourceforge.net/projects/joes-android-builds/files/axion/$FILE_NAME/download'"',  >> $FILE_NAME.json.txt
echo '"'version'"': '"'$VERSION.$MINOR_VERSION'"'  >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

exit 0
fi

