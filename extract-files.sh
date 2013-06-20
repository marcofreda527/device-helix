#!/bin/bash

# Copyright (C) 2010 The Android Open Source Project
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

DEVICE=helix
COMMON=common
MANUFACTURER=qcom

if [[ -z "${ANDROIDFS_DIR}" && -d ../../../backup-${DEVICE}/system ]]; then
    ANDROIDFS_DIR=../../../backup-${DEVICE}
fi

if [[ -z "${ANDROIDFS_DIR}" ]]; then
    echo Pulling files from device
    DEVICE_BUILD_ID=`adb shell cat /system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
else
    echo Pulling files from ${ANDROIDFS_DIR}
    DEVICE_BUILD_ID=`cat ${ANDROIDFS_DIR}/system/build.prop | grep ro.build.display.id | sed -e 's/ro.build.display.id=//' | tr -d '\n\r'`
fi

case "$DEVICE_BUILD_ID" in
msm7627a*)
  FIRMWARE=ICS
  echo Found ICS firmware with build ID $DEVICE_BUILD_ID >&2
  ;;
*)
  FIRMWARE=unknown
  echo Found unknown firmware with build ID $DEVICE_BUILD_ID >&2
  echo Please download a compatible backup-${DEVICE} directory.
  echo Check the ${DEVICE} intranet page for information on how to get one.
  exit -1
  ;;
esac

if [[ ! -d ../../../backup-${DEVICE}/system  && -z "${ANDROIDFS_DIR}" ]]; then
    echo Backing up system partition to backup-${DEVICE}
    mkdir -p ../../../backup-${DEVICE} &&
    adb pull /system ../../../backup-${DEVICE}/system
fi

BASE_PROPRIETARY_COMMON_DIR=vendor/$MANUFACTURER/$COMMON/proprietary
PROPRIETARY_DEVICE_DIR=../../../vendor/$MANUFACTURER/$DEVICE/proprietary
PROPRIETARY_COMMON_DIR=../../../$BASE_PROPRIETARY_COMMON_DIR

mkdir -p $PROPRIETARY_DEVICE_DIR

for NAME in audio hw wifi etc egl etc/firmware
do
    mkdir -p $PROPRIETARY_COMMON_DIR/$NAME
done


COMMON_BLOBS_LIST=../../../vendor/$MANUFACTURER/$COMMON/vendor-blobs.mk

(cat << EOF) | sed s/__COMMON__/$COMMON/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > $COMMON_BLOBS_LIST
# Copyright (C) 2010 The Android Open Source Project
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

# Prebuilt libraries that are needed to build open-source libraries
PRODUCT_COPY_FILES := device/sample/etc/apns-full-conf.xml:system/etc/apns-conf.xml

# All the blobs
PRODUCT_COPY_FILES += \\
EOF

# copy_file
# pull file from the device and adds the file to the list of blobs
#
# $1 = src name
# $2 = dst name
# $3 = directory path on device
# $4 = directory name in $PROPRIETARY_COMMON_DIR
copy_file()
{
    echo Pulling \"$1\"
    if [[ -z "${ANDROIDFS_DIR}" ]]; then
        adb pull /$3/$1 $PROPRIETARY_COMMON_DIR/$4/$2
    else
           # Hint: Uncomment the next line to populate a fresh ANDROIDFS_DIR
           #       (TODO: Make this a command-line option or something.)
           # adb pull /$3/$1 ${ANDROIDFS_DIR}/$3/$1
        cp ${ANDROIDFS_DIR}/$3/$1 $PROPRIETARY_COMMON_DIR/$4/$2
    fi

    if [[ -f $PROPRIETARY_COMMON_DIR/$4/$2 ]]; then
        echo   $BASE_PROPRIETARY_COMMON_DIR/$4/$2:$3/$2 \\ >> $COMMON_BLOBS_LIST
    else
        echo Failed to pull $1. Giving up.
        exit -1
    fi
}

# copy_files
# pulls a list of files from the device and adds the files to the list of blobs
#
# $1 = list of files
# $2 = directory path on device
# $3 = directory name in $PROPRIETARY_COMMON_DIR
copy_files()
{
    for NAME in $1
    do
        copy_file "$NAME" "$NAME" "$2" "$3"
    done
}

# copy_local_files
# puts files in this directory on the list of blobs to install
#
# $1 = list of files
# $2 = directory path on device
# $3 = local directory path
copy_local_files()
{
    for NAME in $1
    do
        echo Adding \"$NAME\"
        echo device/$MANUFACTURER/$DEVICE/$3/$NAME:$2/$NAME \\ >> $COMMON_BLOBS_LIST
    done
}

COMMON_LIBS="
	libauth.so
	libcm.so
	libcameraservice.so
	libcamera_client.so
	libhwdevctl_client.so
	libhwdevctlservice.so
	libCommandSvc.so
	libdiag.so
	libdivxdrmdecrypt.so
	libdsi_netctrl.so
	libdsm.so
	libdss.so
	libdsutils.so
	libhardware.so
	libhardware_legacy.so
	libhwrpc.so
	libidl.so
	libimage-jpeg-enc-omx-comp.so
	libimage-omx-common.so
	libmm-adspsvc.so
	libmmcamera_interface2.so
	libmmstillomx.so
	libnetmgr.so
	libnv.so
	libOmxAacDec.so
	libOmxH264Dec.so
	libOmxMpeg4Dec.so
	libOmxMp3Dec.so
	libOmxVidEnc.so
	libOmxVp8Dec.so
	liboncrpc.so
	libpbmlib.so
	libqcci_legacy.so
	libqdp.so
	libqmi_client_qmux.so
	libqmi.so
	libqmiservices.so
	libqueue.so
	libril-qc-1.so
	libril-qc-qmi-1.so
	libril-qcril-hook-oem.so
	libwms.so
	libwmsts.so
	libcommondefs.so
	libgenlock.so
	libgemini.so
	libgps.utils.so
	libril.so
	libmmcamera_statsproc31.so
	libmmcamera_image_stab.so
	libmmcamera_frameproc.so
	libmmcamera_faceproc.so
	libmmcamera_wavelet_lib.so
	libmmcamera_hdr_lib.so
	libchromatix_mt9p017_preview.so
	libchromatix_mt9p017_default_video.so
	libchromatix_s5k4e1_3_default_video.so
	libchromatix_s5k4e1_3_preview.so
	libcontrast.so
	libmmjpeg.so
	libmmipl.so
	libnl_2.so
	liboemcamera.so
	libloc_adapter.so
	libloc_api-rpc-qc.so
	libloc_eng.so
	libqdi.so
	librpc.so
	libsc-a2xx.so
	libgsl.so
	libOpenVG.so
	libzy_imgdenoise.so
	libcnefeatureconfig.so
	libbluetooth.so
	libbluetoothd.so
	"

copy_files "$COMMON_LIBS" "system/lib" ""

COMMON_BINS="
	akmd8963
	akmd8975
	atserver
	bridgemgrd
	fm_qsoc_patches
	fmconfig
	hci_qcomm_init
	iw
	log
	mm-qcamera-daemon
	netmgrd
	port-bridge
	qmiproxy
	qmuxd
	rild
	radish
	rmt_storage
	wlan_detect
	hwdevctlservice
	gpu_dcvsd
	wiperiface
	callife
	ath_supplicant
	wpa_cli
	"
copy_files "$COMMON_BINS" "system/bin" ""

COMMON_HW="
	libqcomfm_if.so
	camera.msm7627a.so
	lights.msm7627a.so
	copybit.msm7627a.so
	hwcomposer.msm7627a.so
	gralloc.msm7627a.so
	sensors.default.so
	gps.default.so
	"
copy_files "$COMMON_HW" "system/lib/hw" "hw"

COMMON_WIFI="
	ath6kl_sdio.ko
	cfg80211.ko
	"

#copy_files "$COMMON_WIFI" "system/wifi" "wifi"

COMMON_ATH6K="
	athtcmd_ram.bin
	caldata.bin
	caldata_MSM8X25_C8825D.bin
	fw-3.bin
	nullTestFlow.bin
	softmac
	utf.bin
	"
copy_files "$COMMON_ATH6K" "system/wifi/ath6k" "wifi"

COMMON_ETC="init.qcom.bt.sh gps.conf"
copy_files "$COMMON_ETC" "system/etc" "etc"

COMMON_AUDIO="
	"
#copy_files "$COMMON_AUDIO" "system/lib" "audio"

COMMON_EGL="
	egl.cfg
	eglsubAndroid.so
	libEGL_adreno200.so
	libGLES_android.so
	libGLESv1_CM_adreno200.so
	libGLESv2_adreno200.so
	libq3dtools_adreno200.so
	"
copy_files "$COMMON_EGL" "system/lib/egl" "egl"

COMMON_FIRMWARE="
	yamato_pfp.fw
	yamato_pm4.fw
	"
copy_files "$COMMON_FIRMWARE" "system/etc/firmware" "etc/firmware"

cp "$PROPRIETARY_COMMON_DIR/$2/libcnefeatureconfig.so" "$PROPRIETARY_COMMON_DIR/$2/objlibcnefeatureconfig.so"
echo $BASE_PROPRIETARY_COMMON_DIR/$2/objlibcnefeatureconfig.so:obj/lib/libcnefeatureconfig.so \\ >> $COMMON_BLOBS_LIST

#use the blobs related to Adreno from device since ICS version in hamachi is strawberry not chocolate
(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/$DEVICE-vendor-blobs.mk
# Copyright (C) 2010 The Android Open Source Project
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

EOF

BOOTIMG=boot-helix.img
if [ -f ../../../${BOOTIMG} ]; then
    (cd ../../.. && ./build.sh unbootimg)
    . ../../../build/envsetup.sh
    HOST_OUT=$(get_build_var HOST_OUT_$(get_build_var HOST_BUILD_TYPE))
    KERNEL_DIR=../../../vendor/${MANUFACTURER}/${DEVICE}
    cp ../../../${BOOTIMG} ${KERNEL_DIR}
    ../../../${HOST_OUT}/bin/unbootimg ${KERNEL_DIR}/${BOOTIMG}
    mv ${KERNEL_DIR}/${BOOTIMG}-kernel ${KERNEL_DIR}/kernel
    rm -f ${KERNEL_DIR}/${BOOTIMG}-ramdisk.cpio.gz ${KERNEL_DIR}/${BOOTIMG}-second ${KERNEL_DIR}/${BOOTIMG}-mk ${KERNEL_DIR}/${BOOTIMG}
fi
