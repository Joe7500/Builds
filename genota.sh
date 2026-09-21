#!/bin/bash

if ! echo "$@" | grep -E "crdroid|lineage|axion|infinity|voltage|rising|pixelos" ; then
   echo "usage: crdroid|lineage|axion|infinity|voltage|rising|pixelos major_version file"
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
echo '"'download'"': '"'https://sourceforge.net/projects/joes-android-builds/files/crDroid/$VERSION/$FILE_NAME/download?use_mirror=onboardcloud'"', >> $FILE_NAME.json.txt
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
echo '"'url'"': '"'https://sourceforge.net/projects/joes-android-builds/files/LineageOS/$VERSION/$FILE_NAME/download?use_mirror=onboardcloud'"',  >> $FILE_NAME.json.txt
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
echo '"romtype": "UNOFFICIAL",' >> $FILE_NAME.json.txt
echo '"'size'"': '"'$SIZE'"', >> $FILE_NAME.json.txt
echo '"'url'"': '"'https://sourceforge.net/projects/joes-android-builds/files/axion/$FILE_NAME/download?use_mirror=onboardcloud'"',  >> $FILE_NAME.json.txt
echo '"'version'"': '"'$VERSION.$MINOR_VERSION'"'  >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

exit 0
fi

if echo $PACKAGE | grep -i infinity; then

MINOR_VERSION=`echo $FILE_NAME | cut -d "-" -f 3 | cut -d . -f 2`
MD5=`md5sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 5`
FILE_DAY=`echo $FILE_DATE | cut -d "." -f 1`
FILE_MONTH=`echo $FILE_DATE | cut -d "." -f 2`
FILE_YEAR=`echo $FILE_DATE | cut -d "." -f 3`
TIMESTAMP=`date -d "$FILE_YEAR$FILE_MONTH$FILE_DAY 00:00:00" +%s`

echo '{ "response": [{' > $FILE_NAME.json.txt
echo '"'filename'"': '"'$FILE_NAME'"', >> $FILE_NAME.json.txt
echo '"'download'"': '"'https://sourceforge.net/projects/joes-android-builds/files/Infinity-X/$VERSION/$FILE_NAME/download?use_mirror=onboardcloud'"',  >> $FILE_NAME.json.txt
echo '"'timestamp'"': '"'$TIMESTAMP'"', >> $FILE_NAME.json.txt
echo '"'md5'"': '"'$MD5'"', >> $FILE_NAME.json.txt
echo '"'size'"': '"'$SIZE'"', >> $FILE_NAME.json.txt
echo '"'version'"': '"'$VERSION.$MINOR_VERSION'"'  >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

exit 0
fi

if echo $PACKAGE | grep -i voltage; then

MINOR_VERSION=`echo $FILE_NAME | cut -d "-" -f 2 | cut -d . -f 2`
MD5=`md5sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 4`
TIMESTAMP=`date -d "$FILE_DATE 00:00:00" +%s`

echo '{ "response": [{' > $FILE_NAME.json.txt
echo '"'timestamp'"': '"'$TIMESTAMP'"', >> $FILE_NAME.json.txt
echo '"'filename'"': '"'$FILE_NAME'"', >> $FILE_NAME.json.txt
echo '"'md5'"': '"'$MD5'"', >> $FILE_NAME.json.txt
echo '"maintainer": "Joe",' >> $FILE_NAME.json.txt
echo '"'size'"': '"'$SIZE'"', >> $FILE_NAME.json.txt
echo '"'download'"': '"'https://sourceforge.net/projects/joes-android-builds/files/voltage/$FILE_NAME/download?use_mirror=onboardcloud'"',  >> $FILE_NAME.json.txt
echo '"'version'"': '"'$VERSION.$MINOR_VERSION'"',  >> $FILE_NAME.json.txt
echo '"oem": "xiaomi",' >> $FILE_NAME.json.txt
echo '"device": "chime"' >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

exit 0
fi

if echo $PACKAGE | grep -i rising; then

MINOR_VERSION=`echo $FILE_NAME | cut -d . -f 3`
MD5=`md5sum $INPUT_NAME | cut -d " " -f 1`
SHA=`sha256sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 3`
TIMESTAMP=`date -d "$FILE_DATE 00:00:00" +%s`
RISING_VERSION=`echo $FILE_NAME | cut -d '-' -f 2`

echo '{ "response": [{' > $FILE_NAME.json.txt
echo '"maintainer": "Joe",'  >> $FILE_NAME.json.txt
echo '"oem": "Xiaomi",' >> $FILE_NAME.json.txt
echo '"device": "POCO M3 & Redmi 9T",' >> $FILE_NAME.json.txt
echo '"'filename'"': '"'$FILE_NAME'"', >> $FILE_NAME.json.txt
echo '"'download'"': '"'https://sourceforge.net/projects/joes-android-builds/files/risingOS/$VERSION/$FILE_NAME/download?use_mirror=onboardcloud'"', >> $FILE_NAME.json.txt
echo '"'timestamp'"': $TIMESTAMP, >> $FILE_NAME.json.txt
echo '"'md5'"': '"'$MD5'"', >> $FILE_NAME.json.txt
echo '"'sha256'"': '"'$SHA'"', >> $FILE_NAME.json.txt
echo '"'size'"': $SIZE, >> $FILE_NAME.json.txt
echo '"'version'"': '"'$RISING_VERSION'"', >> $FILE_NAME.json.txt
echo '"buildtype": "Monthly",' >> $FILE_NAME.json.txt
echo '"forum": "https://sourceforge.net/projects/joes-android-builds/",' >> $FILE_NAME.json.txt
echo '"recovery": "",' >> $FILE_NAME.json.txt
echo '"paypal": "",' >> $FILE_NAME.json.txt
echo '"telegram": "https://t.me/joes_stuff",' >> $FILE_NAME.json.txt
echo '}]}' >> $FILE_NAME.json.txt

#echo 'empty' > $FILE_NAME.json.txt

exit 0
fi

#{
#    "maintainer": [
#        {
#            "display_name": "InFeRnO",
#            "telegram": "inferno0230",
#            "github": "inferno0230"
#        }
#    ],
#    "model": "OnePlus 12R",
#    "vendor": "OnePlus",
#    "codename": "aston",
#    "codename_alt": "aston",
#    "active": true,
#    "version": "sixteen",
#    "release": "monthly",
#    "last_updated": "23 November 2025",
#    "download_link": "https://sourceforge.net/projects/pixelos-releases/files/sixteen/aston/PixelOS_aston-16.0-20251123-0302.zip",
#    "archive": "https://sourceforge.net/projects/pixelos-releases/files/sixteen/aston/",
#    "xda": "https://xdaforums.com/t/12r-ace3-rom-14-official-pixelos-aosp-21-08-24.4662225"
#}


if echo $PACKAGE | grep -i pixelos; then

MINOR_VERSION=`echo $FILE_NAME | cut -d "-" -f 2 | cut -d . -f 2`
SHA=`sha256sum $INPUT_NAME | cut -d " " -f 1`
SIZE=`ls -l $INPUT_NAME | awk '{print $5}'`
FILE_DATE=`echo $FILE_NAME | cut -d "-" -f 3`
LAST_UPDATED=`date +"%d %B %Y"`

echo '{' > $FILE_NAME.json.txt
echo '   "maintainer": [' >> $FILE_NAME.json.txt
echo '        {' >> $FILE_NAME.json.txt
echo '            "display_name": "Joe",' >> $FILE_NAME.json.txt
echo '            "telegram": "joes_stuff",' >> $FILE_NAME.json.txt
echo '           "github": "Joe7500"' >> $FILE_NAME.json.txt
echo '        }' >> $FILE_NAME.json.txt
echo '    ],' >> $FILE_NAME.json.txt
echo '    "model": "POCO M3 / Redmi 9T",' >> $FILE_NAME.json.txt
echo '    "vendor": "Xiaomi",' >> $FILE_NAME.json.txt
echo '    "codename": "chime",' >> $FILE_NAME.json.txt
echo '    "codename_alt": "chime",' >> $FILE_NAME.json.txt
echo '    "active": true,' >> $FILE_NAME.json.txt
echo '    "version": "seventeen",' >> $FILE_NAME.json.txt
echo '    "release": "monthly",' >> $FILE_NAME.json.txt
echo '    "last_updated":' '"'$LAST_UPDATED'"', >> $FILE_NAME.json.txt
echo '    "'download_link'"': '"'https://sourceforge.net/projects/joes-android-builds/files/pixelos/$FILE_NAME/download?use_mirror=onboardcloud'"',  >> $FILE_NAME.json.txt
echo '    "archive": "https://sourceforge.net/projects/joes-android-builds/files/pixelos/",' >> $FILE_NAME.json.txt
echo '    "xda": "https://sourceforge.net/projects/joes-android-builds/files/pixelos/"' >> $FILE_NAME.json.txt
echo '}' >> $FILE_NAME.json.txt

exit 0
fi


exit 1

