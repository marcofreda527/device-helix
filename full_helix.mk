$(call inherit-product, device/qcom/common/common.mk)
PRODUCT_COPY_FILES := \
  device/qcom/helix/touchscreen.idc:system/usr/idc/synaptics.idc \
  device/qcom/helix/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
  device/qcom/helix/media_profiles.xml:system/etc/media_profiles.xml

$(call inherit-product-if-exists, vendor/qcom/helix/helix-vendor-blobs.mk)
$(call inherit-product-if-exists, vendor/qcom/common/vendor-blobs.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full.mk)

PRODUCT_PROPERTY_OVERRIDES += \
  rild.libpath=/system/lib/libril-qc-1.so \
  rild.libargs=-d/dev/smd0 \
  ro.moz.fm.noAnalog=true \
  ro.moz.cam.0.sensor_offset=0 \
  ro.moz.cam.1.sensor_offset=0 \
  ro.use_data_netmgrd=true \
  ro.moz.ril.emergency_by_default=true \
  ro.moz.omx.hw.max_width=800 \
  ro.moz.omx.hw.max_height=480

# Discard inherited values and use our own instead.
PRODUCT_NAME := full_helix
PRODUCT_DEVICE := helix
PRODUCT_BRAND := qcom
PRODUCT_MANUFACTURER := qcom
PRODUCT_MODEL := helix
ENABLE_LIBRECOVERY := true

PRODUCT_DEFAULT_PROPERTY_OVERRIDES := \
  persist.usb.serialno=$(PRODUCT_NAME)
