# OpenGapps AOSP based makefile.

OPENGAPPS_VARIANT ?= stock

OPENGAPPS_VENDOR_DIR := $(ANDROID_BUILD_TOP)/vendor/opengapps
OPENGAPPS_MAKEFILE_DIR := $(OPENGAPPS_VENDOR_DIR)/out
OPENGAPPS_BUILD_DIR := $(OPENGAPPS_VENDOR_DIR)/build
OPENGAPPS_SOURCES_DIR := $(OPENGAPPS_VENDOR_DIR)/sources
OPENGAPPS_PRODUCT_MK := $(OPENGAPPS_MAKEFILE_DIR)/product.mk
OPENGAPPS_GENERATE_SCRIPT := $(OPENGAPPS_BUILD_DIR)/scripts/generate_aosp_makefiles.sh

define git-sha
$(shell git --git-dir $1/.git --work-tree $1 rev-parse --short HEAD)
endef
OPENGAPPS_COMMIT_IDS := $(strip $(foreach dir, \
	$(shell ls $(OPENGAPPS_SOURCES_DIR) | sort), \
	$(call git-sha, $(OPENGAPPS_SOURCES_DIR)/$(dir))))
OPENGAPPS_ALL_COMMIT_IDS := $(call subst, ,-,$(OPENGAPPS_COMMIT_IDS))

OPENGAPPS_CHECK_FILE := $(OPENGAPPS_MAKEFILE_DIR)/.$(TARGET_PRODUCT)-$(OPENGAPPS_VARIANT)-$(OPENGAPPS_ALL_COMMIT_IDS)
$(OPENGAPPS_CHECK_FILE): $(OPENGAPPS_GENERATE_SCRIPT)
	rm -R $(OPENGAPPS_MAKEFILE_DIR)/* 2>/dev/null || true
	mkdir -p $(OPENGAPPS_MAKEFILE_DIR)
	@echo "----- Generating OpenGapps Makefiles... -----"
	@echo "TARGET_ARCH: $(TARGET_ARCH)"
	@echo "PLATFORM_SDK_VERSION: $(PLATFORM_SDK_VERSION)"
	@echo "PRODUCT: $(TARGET_PRODUCT)"
	$(OPENGAPPS_GENERATE_SCRIPT) $(TARGET_ARCH) $(PLATFORM_SDK_VERSION) $(OPENGAPPS_VARIANT)
	@echo "----- Generated OpenGapps Makefiles -----"
	$(hide) touch $(OPENGAPPS_CHECK_FILE)

.PHONY: opengapps
opengapps: $(OPENGAPPS_CHECK_FILE)

droidcore: $(OPENGAPPS_CHECK_FILE)
