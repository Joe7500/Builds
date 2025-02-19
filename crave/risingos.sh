#!/bin/bash

source /home/admin/.profile
source /home/admin/.bashrc
source /tmp/crave_bashrc

cd /tmp/src/android/

PACKAGE_NAME=RisingOS
VARIANT_NAME=user
DEVICE_BRANCH=lineage-22.1
VENDOR_BRANCH=lineage-22
XIAOMI_BRANCH=lineage-22.1
REPO_URL="-u https://github.com/RisingOS-Revived/android -b fifteen --git-lfs"
export RISING_MAINTAINER="Joe"
export BUILD_USERNAME=user
export BUILD_HOSTNAME=localhost 
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=localhost
if echo $@ | grep "JJ_SPEC:" ; then export JJ_SPEC=`echo $@ | cut -d ":" -f 2` ; fi
TG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io started. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1 

cleanup_self () {
   cd /tmp/src/android/
   rm -rf vendor/lineage-priv/keys
   rm -rf vendor/lineage-priv
   rm -rf priv-keys
   cd packages/apps/Updater/ && git reset --hard && cd ../../../
   cd packages/modules/Connectivity/ && git reset --hard && cd ../../../
   rm -rf prebuilts/clang/kernel/linux-x86/clang-stablekern/
   rm -rf hardware/xiaomi/
   rm -rf device/xiaomi/chime/
   rm -rf vendor/xiaomi/chime/
   rm -rf kernel/xiaomi/chime/
   rm -f InterfaceController.java.patch
   rm -f wfdservice.rc.patch
   rm -f strings.xml.*
   rm -f builder.sh
   rm -rf /tmp/android-certs*
   rm -rf /home/admin/venv/
   rm -rf custom_scripts/
   rm -f goupload.sh GOFILE.txt
}

check_fail () {
   if [ $? -ne 0 ]; then 
       if ls out/target/product/chime/$PACKAGE_NAME*.zip; then
          echo weird. build failed but OTA package exists.
          echo softfail > result.txt
	  curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io softfailed. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1
	  cleanup_self
          exit 1
       else
          echo fail > result.txt
	  curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io failed. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1 
          cleanup_self
          exit 1 
       fi
   fi
}

if echo "$@" | grep resume; then
   echo "resuming"
else
   echo "==========================="
   echo "         SYNCING"
   echo "==========================="
   repo init $REPO_URL  ; check_fail
   cleanup_self
   /opt/crave/resync.sh ; check_fail
fi

echo "==========================="
echo "         SETUP ENV"
echo "==========================="

rm -rf kernel/xiaomi/chime/
rm -rf vendor/xiaomi/chime/
rm -rf device/xiaomi/chime/
rm -rf hardware/xiaomi/
rm -rf prebuilts/clang/kernel/linux-x86/clang-stablekern/
curl -o kernel.tar.xz -L "https://github.com/Joe7500/Builds/releases/download/Stuff/kernel.tar.xz" ; check_fail
tar xf kernel.tar.xz ; check_fail
rm -f kernel.tar.xz
curl -o lineage-22.1.tar.xz -L "https://github.com/Joe7500/Builds/releases/download/Stuff/lineage-22.1.tar.xz" ; check_fail
tar xf lineage-22.1.tar.xz ; check_fail
rm -f lineage-22.1.tar.xz
curl -o toolchain.tar.xz -L "https://github.com/Joe7500/Builds/releases/download/Stuff/toolchain.tar.xz" ; check_fail
tar xf toolchain.tar.xz ; check_fail
rm -f toolchain.tar.xz
git clone https://github.com/Joe7500/device_xiaomi_chime.git -b $DEVICE_BRANCH device/xiaomi/chime ; check_fail
git clone https://github.com/Joe7500/vendor_xiaomi_chime.git -b $VENDOR_BRANCH vendor/xiaomi/chime ; check_fail
git clone https://github.com/LineageOS/android_hardware_xiaomi -b $XIAOMI_BRANCH hardware/xiaomi ; check_fail

patch -f -p 1 < wfdservice.rc.patch ; check_fail
cd packages/modules/Connectivity/ && git reset --hard && cd ../../../
patch -f -p 1 < InterfaceController.java.patch ; check_fail
rm -f InterfaceController.java.patch wfdservice.rc.patch strings.xml.*
rm -f vendor/xiaomi/chime/proprietary/system_ext/etc/init/wfdservice.rc.rej
rm -f packages/modules/Connectivity/staticlibs/device/com/android/net/module/util/ip/InterfaceController.java.rej

cd packages/apps/Updater/ && git reset --hard && cd ../../../
cp packages/apps/Updater/app/src/main/res/values/strings.xml strings.xml.backup.orig.txt
cat strings.xml.backup.orig.txt | sed -e 's#RisingOS-Revived/official_devices/fifteen/OTA/device/GAPPS/{device}.json#Joe7500/Builds/main/rising-rev-gapps-chime.json#g' > strings.xml.new.txt
mv strings.xml.new.txt strings.xml.backup.orig.txt
cat strings.xml.backup.orig.txt | sed -e 's#RisingOS-Revived/official_devices/fifteen/OTA/device/VANILLA/{device}.json#Joe7500/Builds/main/rising-rev-vanilla-chime.json#g' > strings.xml.new.txt
mv strings.xml.new.txt strings.xml.backup.orig.txt
cat strings.xml.backup.orig.txt | sed -e 's#RisingOS-Revived/official_devices/fifteen/OTA/device/CORE/{device}.json#Joe7500/Builds/main/rising-rev-core-chime.json#g' > strings.xml.new.txt
mv strings.xml.new.txt strings.xml.backup.orig.txt
cp strings.xml.backup.orig.txt strings.xml
cp -f strings.xml packages/apps/Updater/app/src/main/res/values/strings.xml
rm -f strings.xml.*
check_fail

cat device/xiaomi/chime/BoardConfig.mk | grep -v TARGET_KERNEL_CLANG_VERSION > device/xiaomi/chime/BoardConfig.mk.1
mv device/xiaomi/chime/BoardConfig.mk.1 device/xiaomi/chime/BoardConfig.mk
echo 'TARGET_KERNEL_CLANG_VERSION := stablekern' >> device/xiaomi/chime/BoardConfig.mk

sudo apt --yes install python3-virtualenv virtualenv python3-pip-whl
rm -rf /home/admin/venv
virtualenv /home/admin/venv ; check_fail
source /home/admin/venv/bin/activate
pip install --upgrade b2 ; check_fail
b2 account authorize "$BKEY_ID" "$BAPP_KEY" > /dev/null 2>&1 ; check_fail
mkdir priv-keys
b2 sync "b2://$BUCKET_NAME/inline" "priv-keys" > /dev/null 2>&1 ; check_fail
mkdir --parents vendor/lineage-priv/keys
mv priv-keys/* vendor/lineage-priv/keys
rm -rf priv-keys
deactivate
unset BUCKET_NAME
unset KEY_ENCRYPTION_PASSWORD
unset BKEY_ID
unset BAPP_KEY
unset KEY_PASSWORD
cat /tmp/crave_bashrc | grep -vE "BKEY_ID|BUCKET_NAME|KEY_ENCRYPTION_PASSWORD|BAPP_KEY|TG_CID|TG_TOKEN" > /tmp/crave_bashrc.1
mv /tmp/crave_bashrc.1 /tmp/crave_bashrc

cd device/xiaomi/chime && git reset --hard ; check_fail
export RISING_MAINTAINER="Joe"
cat lineage_chime.mk | grep -v "RESERVE_SPACE_FOR_GAPPS" > lineage_chime.mk.1
mv lineage_chime.mk.1 lineage_chime.mk
echo "RESERVE_SPACE_FOR_GAPPS := false" >> lineage_chime.mk
echo "TARGET_PREBUILT_LAWNCHAIR_LAUNCHER := true" >> lineage_chime.mk
echo 'RISING_MAINTAINER := Joe' >> lineage_chime.mk
echo 'RISING_MAINTAINER="Joe"' >> lineage_chime.mk
echo 'PRODUCT_BUILD_PROP_OVERRIDES += \
    RisingChipset="Chime" \
    RisingMaintainer="Joe"' >> lineage_chime.mk
echo 'WITH_GMS := true
TARGET_DEFAULT_PIXEL_LAUNCHER := true
' >> lineage_chime.mk
cat device/xiaomi/chime/BoardConfig.mk | grep -v TARGET_KERNEL_CLANG_VERSION > device/xiaomi/chime/BoardConfig.mk.1
mv device/xiaomi/chime/BoardConfig.mk.1 device/xiaomi/chime/BoardConfig.mk
echo 'TARGET_KERNEL_CLANG_VERSION := stablekern' >> device/xiaomi/chime/BoardConfig.mk
cd ../../../

sleep 15
echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";
echo "==========================="
echo "         BEGIN BUILD"
echo "==========================="
echo "";echo "";echo "";echo "";echo "";echo "";echo "";

source build/envsetup.sh          ; check_fail
breakfast chime user              ; check_fail
mka installclean
mka bacon                         ; check_fail

echo success > result.txt
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME GAPPS on crave.io succeeded. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1 

GO_FILE=`ls -1tr out/target/product/chime/$PACKAGE_NAME*.zip | tail -1`
GO_FILE=`pwd`/$GO_FILE
curl -o goupload.sh -L https://raw.githubusercontent.com/Joe7500/Builds/refs/heads/main/crave/gofile.sh
bash goupload.sh $GO_FILE
GO_LINK=`cat GOFILE.txt`
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="$PACKAGE_NAME `basename $GO_FILE` $GO_LINK  . JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1
rm -f goupload.sh GOFILE.txt

echo "==========================="
echo "$GO_LINK"
echo "==========================="

cd device/xiaomi/chime && git reset --hard ; check_fail
export RISING_MAINTAINER="Joe"
cat lineage_chime.mk | grep -v "RESERVE_SPACE_FOR_GAPPS" > lineage_chime.mk.1
mv lineage_chime.mk.1 lineage_chime.mk
echo "RESERVE_SPACE_FOR_GAPPS := true" >> lineage_chime.mk
echo 'RISING_MAINTAINER="Joe"' >> lineage_chime.mk
echo 'RISING_MAINTAINER := Joe'  >> lineage_chime.mk
echo 'PRODUCT_BUILD_PROP_OVERRIDES += \
    RisingChipset="Chime" \
    RisingMaintainer="Joe"' >> lineage_chime.mk
echo 'WITH_GMS := false' >> lineage_chime.mk
echo 'PRODUCT_PACKAGES += \
   Gallery2
' >> device.mk
cat device/xiaomi/chime/BoardConfig.mk | grep -v TARGET_KERNEL_CLANG_VERSION > device/xiaomi/chime/BoardConfig.mk.1
mv device/xiaomi/chime/BoardConfig.mk.1 device/xiaomi/chime/BoardConfig.mk
echo 'TARGET_KERNEL_CLANG_VERSION := stablekern' >> device/xiaomi/chime/BoardConfig.mk

cd ../../../

source build/envsetup.sh          ; check_fail
breakfast chime user              ; check_fail
mka bacon                         ; check_fail

echo success > result.txt
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME VANILLA on crave.io succeeded. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1

GO_FILE=`ls -1tr out/target/product/chime/$PACKAGE_NAME*.zip | tail -1`
GO_FILE=`pwd`/$GO_FILE
curl -o goupload.sh -L https://raw.githubusercontent.com/Joe7500/Builds/refs/heads/main/crave/gofile.sh
bash goupload.sh $GO_FILE
GO_LINK=`cat GOFILE.txt`
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="$PACKAGE_NAME `basename $GO_FILE` $GO_LINK" > /dev/null 2>&1
rm -f goupload.sh GOFILE.txt

echo "==========================="
echo "$GO_LINK"
echo "==========================="

cleanup_self

sleep 60
echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";echo "";
echo "==========================="
echo " DONE. THANK YOU! GOODBYE!"
echo "==========================="
echo "";echo "";echo "";echo "";echo "";echo "";echo "";

exit 0
