#
# Copyright (C) 2016 The CyanogenMod Project
#               2017-2024 The LineageOS Project
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

TARGET_GENERATED_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_GENERATED_BOOTANIMATION): INTERMEDIATES := $(call intermediates-dir-for,BOOTANIMATION,bootanimation)
$(TARGET_GENERATED_BOOTANIMATION): $(SOONG_ZIP)
	@echo "Building bootanimation.zip"
	@rm -rf $(dir $@)
	@mkdir -p $(INTERMEDIATES)
	$(hide) tar xfp vendor/lineage/bootanimation/bootanimation.tar -C $(INTERMEDIATES)
	$(hide) \
	    TGTW=$(TARGET_SCREEN_WIDTH); \
	    TGTH=$(TARGET_SCREEN_HEIGHT); \
	    if [ "$(TARGET_BOOTANIMATION_HALF_RES)" = "true" ]; then \
	        TGTW=$$(expr $$TGTW / 2); \
	        TGTH=$$(expr $$TGTH / 2); \
	    fi; \
	    FIRST=$$(ls $(INTERMEDIATES)/*/00000.png 2>/dev/null | head -1); \
	    if [ -n "$$FIRST" ]; then \
	        SRCW=$$(python3 -c "import struct; f=open('$$FIRST','rb'); f.read(16); w,h=struct.unpack('>II',f.read(8)); print(w)"); \
	        SRCH=$$(python3 -c "import struct; f=open('$$FIRST','rb'); f.read(16); w,h=struct.unpack('>II',f.read(8)); print(h)"); \
	        if [ "$$SRCW" -ne "$$TGTW" ] || [ "$$SRCH" -ne "$$TGTH" ]; then \
	            prebuilts/tools-lineage/${HOST_OS}-x86/bin/mogrify \
	                -resize "$${TGTW}x$${TGTH}^" \
	                -gravity center \
	                -extent "$${TGTW}x$${TGTH}" \
	                $(INTERMEDIATES)/*/*.png; \
	        fi; \
	    fi; \
	    echo "$$TGTW $$TGTH 60" > $(INTERMEDIATES)/desc.txt; \
	    cat vendor/lineage/bootanimation/desc.txt >> $(INTERMEDIATES)/desc.txt
	$(hide) $(SOONG_ZIP) -L 0 -o $@ -C $(INTERMEDIATES) -D $(INTERMEDIATES)

ifeq ($(TARGET_BOOTANIMATION),)
    TARGET_BOOTANIMATION := $(TARGET_GENERATED_BOOTANIMATION)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bootanimation.zip
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT)/media

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(TARGET_BOOTANIMATION)
	@cp $(TARGET_BOOTANIMATION) $@

include $(CLEAR_VARS)

BOOTANIMATION_SYMLINK := $(TARGET_OUT_PRODUCT)/media/bootanimation-dark.zip
$(BOOTANIMATION_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@mkdir -p $(dir $@)
	$(hide) ln -sf bootanimation.zip $@

ALL_DEFAULT_INSTALLED_MODULES += $(BOOTANIMATION_SYMLINK)
