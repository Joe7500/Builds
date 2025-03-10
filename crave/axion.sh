#!/bin/bash

source /home/admin/.profile
source /home/admin/.bashrc
source /tmp/crave_bashrc

cd /tmp/src/android/

set -v

PACKAGE_NAME=axion
VARIANT_NAME=user
DEVICE_BRANCH=lineage-22.1
VENDOR_BRANCH=lineage-22
XIAOMI_BRANCH=lineage-22.1
REPO_URL="-u https://github.com/AxionAOSP/android.git -b lineage-22.1 --git-lfs"
OTA_SED_STRING="AxionAOSP/official_devices/refs/heads/main/OTA/{variant}/{device}.json"
export BUILD_USERNAME=user
export BUILD_HOSTNAME=localhost 
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=localhost
SECONDS=0
if echo $@ | grep "JJ_SPEC:" ; then export JJ_SPEC=`echo $@ | cut -d ":" -f 2` ; fi
TG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io started. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1
curl -s -d "Build $PACKAGE_NAME on crave.io started. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1

cleanup_self () {
   cd /tmp/src/android/
   rm -rf vendor/lineage-priv/keys
   rm -rf vendor/lineage-priv
   rm -rf priv-keys
   rm -rf .config/b2/account_info
   cd packages/apps/Updater/ && git reset --hard && cd ../../../
   cd packages/modules/Connectivity/ && git reset --hard && cd ../../../
   cd android/vendor/lineage && git reset --hard && cd ../../..
   rm -f backuptool*
   rm -rf prebuilts/clang/kernel/linux-x86/clang-stablekern/
   rm -rf hardware/xiaomi/
   rm -rf device/xiaomi/chime/
   rm -rf vendor/xiaomi/chime/
   rm -rf kernel/xiaomi/chime/
   rm -f InterfaceController.java.patch wfdservice.rc.patch strings.xml* builder.sh goupload.sh GOFILE.txt
   rm -rf /tmp/android-certs*
   rm -rf /home/admin/venv/
   rm -rf custom_scripts/
}

check_fail () {
   if [ $? -ne 0 ]; then 
       if ls out/target/product/chime/$PACKAGE_NAME*.zip; then
	  curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io softfailed. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1
   	  curl -s -d "Build $PACKAGE_NAME on crave.io softfailed. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1
          echo weird. build failed but OTA package exists.
          echo softfail > result.txt
	  cleanup_self
          exit 1
       else
	  curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io failed. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1
          curl -s -d "Build $PACKAGE_NAME on crave.io failed. `env TZ=Africa/Harare date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1
	  echo "oh no. script failed"
          cleanup_self
	  echo fail > result.txt
          exit 1 
       fi
   fi
}

if echo "$@" | grep resume; then
   echo "resuming"
else
   repo init $REPO_URL  ; check_fail
   cleanup_self
   /opt/crave/resync.sh ; check_fail
fi

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
cp packages/apps/Updater/app/src/main/res/values/strings.xml strings.xml
cat strings.xml | sed -e "s#$OTA_SED_STRING#Joe7500/Builds/main/$PACKAGE_NAME.VANILLA.chime.json#g" > strings.xml.1
cp strings.xml.1 packages/apps/Updater/app/src/main/res/values/strings.xml
check_fail

cd android/vendor/lineage && git reset --hard && cd ../../..
cp android/vendor/lineage/prebuilt/common/bin/backuptool.sh backuptool.sh
cat backuptool.sh | sed -e 's#export V=22#export V=1# g' > backuptool.sh.1
mv backuptool.sh.1 android/vendor/lineage/prebuilt/common/bin/backuptool.sh
rm backuptool.sh

cd device/xiaomi/chime && git reset --hard ; check_fail
cat BoardConfig.mk | grep -v TARGET_KERNEL_CLANG_VERSION > BoardConfig.mk.1
mv BoardConfig.mk.1 BoardConfig.mk
echo 'AXION_MAINTAINER := Joe' >> lineage_chime.mk
echo 'AXION_PROCESSOR := Snapdragon_662' >> lineage_chime.mk
echo 'AXION_CPU_SMALL_CORES := 0,1,2,3' >> lineage_chime.mk
echo 'AXION_CPU_BIG_CORES := 4,5,6,7' >> lineage_chime.mk
echo 'AXION_CAMERA_REAR_INFO := 48' >> lineage_chime.mk
echo 'AXION_CAMERA_FRONT_INFO := 8' >> lineage_chime.mk 
echo 'genfscon proc /sys/vm/dirty_writeback_centisecs     u:object_r:proc_dirty:s0' >> sepolicy/vendor/genfs_contexts
echo 'genfscon proc /sys/vm/vfs_cache_pressure            u:object_r:proc_drop_caches:s0' >> sepolicy/vendor/genfs_contexts
echo 'genfscon proc /sys/vm/dirty_ratio u:object_r:proc_dirty:s0' >> sepolicy/vendor/genfs_contexts
echo 'genfscon proc /sys/kernel/sched_migration_cost_ns u:object_r:proc_sched:s0' >> sepolicy/vendor/genfs_contexts
cd ../../../
echo 'CONFIG_SCHED_DEBUG=y' >> kernel/xiaomi/chime/arch/arm64/configs/vendor/chime_defconfig

cat device/xiaomi/chime/BoardConfig.mk | grep -v TARGET_KERNEL_CLANG_VERSION > device/xiaomi/chime/BoardConfig.mk.1
mv device/xiaomi/chime/BoardConfig.mk.1 device/xiaomi/chime/BoardConfig.mk
echo 'TARGET_KERNEL_CLANG_VERSION := stablekern' >> device/xiaomi/chime/BoardConfig.mk

sudo apt --yes install python3-virtualenv virtualenv python3-pip-whl
rm -rf /home/admin/venv
virtualenv /home/admin/venv ; check_fail
set +v
source /home/admin/venv/bin/activate
set -v
pip install --upgrade b2 ; check_fail
b2 account authorize "$BKEY_ID" "$BAPP_KEY" > /dev/null 2>&1 ; check_fail
mkdir priv-keys
b2 sync "b2://$BUCKET_NAME/inline" "priv-keys" > /dev/null 2>&1 ; check_fail
mkdir --parents vendor/lineage-priv/keys
mv priv-keys/* vendor/lineage-priv/keys
rm -rf priv-keys
rm -rf .config/b2/account_info
deactivate
unset BUCKET_NAME
unset KEY_ENCRYPTION_PASSWORD
unset BKEY_ID
unset BAPP_KEY
unset KEY_PASSWORD
cat /tmp/crave_bashrc | grep -vE "BKEY_ID|BUCKET_NAME|KEY_ENCRYPTION_PASSWORD|BAPP_KEY|TG_CID|TG_TOKEN" > /tmp/crave_bashrc.1
mv /tmp/crave_bashrc.1 /tmp/crave_bashrc

sleep 15

set +v

source build/envsetup.sh          ; check_fail
lunch lineage_chime-ap4a-user     ; check_fail
mka installclean
axion chime va                    ; check_fail
m bacon -j $(nproc --all)         ; check_fail

set -v

echo success > result.txt
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io succeeded. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1 
curl -s -d "Build $PACKAGE_NAME on crave.io succeeded. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1

cp out/target/product/chime/$PACKAGE_NAME*VANILLA*.zip .
GO_FILE=`ls --color=never -1tr $PACKAGE_NAME*VANILLA*.zip | tail -1`
GO_FILE_MD5=`md5sum "$GO_FILE"`
GO_FILE=`pwd`/$GO_FILE
curl -o goupload.sh -L https://raw.githubusercontent.com/Joe7500/Builds/refs/heads/main/crave/gofile.sh
bash goupload.sh $GO_FILE
GO_LINK=`cat GOFILE.txt`
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="MD5:$GO_FILE_MD5 JJ_SPEC:$JJ_SPEC `basename $GO_FILE` $GO_LINK" > /dev/null 2>&1
curl -s -d "$PACKAGE_NAME JJ_SPEC:$JJ_SPEC MD5:$GO_FILE_MD5 $GO_LINK" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1
rm -f goupload.sh GOFILE.txt

cat lineage_chime.mk | grep -v "RESERVE_SPACE_FOR_GAPPS" > lineage_chime.mk.1
mv lineage_chime.mk.1 lineage_chime.mk
echo "RESERVE_SPACE_FOR_GAPPS := false" >> lineage_chime.mk
cd ../../../

cd packages/apps/Updater/ && git reset --hard && cd ../../../
cp packages/apps/Updater/app/src/main/res/values/strings.xml strings.xml
cat strings.xml | sed -e "s#$OTA_SED_STRING#Joe7500/Builds/main/$PACKAGE_NAME.GMS.chime.json#g" > strings.xml.1
cp strings.xml.1 packages/apps/Updater/app/src/main/res/values/strings.xml
check_fail

cd android/vendor/lineage && git reset --hard && cd ../../..

set +v

source build/envsetup.sh          ; check_fail
lunch lineage_chime-ap4a-user     ; check_fail
mka installclean
axion chime gms core              ; check_fail
m bacon -j $(nproc --all)         ; check_fail

set -v

echo success > result.txt
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io succeeded. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1 
curl -s -d "Build $PACKAGE_NAME on crave.io succeeded. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1

cp out/target/product/chime/$PACKAGE_NAME*GMS*.zip .
GO_FILE=`ls --color=never -1tr $PACKAGE_NAME*GMS*.zip | tail -1`
GO_FILE_MD5=`md5sum "$GO_FILE"`
GO_FILE=`pwd`/$GO_FILE
curl -o goupload.sh -L https://raw.githubusercontent.com/Joe7500/Builds/refs/heads/main/crave/gofile.sh
bash goupload.sh $GO_FILE
GO_LINK=`cat GOFILE.txt`
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="MD5:$GO_FILE_MD5 JJ_SPEC:$JJ_SPEC `basename $GO_FILE` $GO_LINK" > /dev/null 2>&1
curl -s -d "$PACKAGE_NAME JJ_SPEC:$JJ_SPEC MD5:$GO_FILE_MD5 $GO_LINK" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1
rm -f goupload.sh GOFILE.txt

TIME_TAKEN=`printf '%dh:%dm:%ds\n' $((SECONDS/3600)) $((SECONDS%3600/60)) $((SECONDS%60))`
curl -s -X POST $TG_URL -d chat_id=$TG_CID -d text="Build $PACKAGE_NAME on crave.io completed. $TIME_TAKEN. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" > /dev/null 2>&1
curl -s -d "Build $PACKAGE_NAME on crave.io completed. $TIME_TAKEN. `env LC_ALL="" TZ=Africa/Harare LC_TIME="C.UTF-8" date`. JJ_SPEC:$JJ_SPEC" "ntfy.sh/$NTFYSUB" > /dev/null 2>&1

cleanup_self

sleep 60

exit 0
