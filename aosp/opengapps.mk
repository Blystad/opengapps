# OpenGapps AOSP based makefile.

# Default variant
OPENGAPPS_VARIANT ?= stock

OPENGAPPS_VENDOR_DIR := $(ANDROID_BUILD_TOP)/vendor/opengapps
OPENGAPPS_MAKEFILE_DIR := $(OPENGAPPS_VENDOR_DIR)/out
OPENGAPPS_TOOLS_DIR := $(OPENGAPPS_VENDOR_DIR)/tools
OPENGAPPS_SOURCES_DIR := $(OPENGAPPS_VENDOR_DIR)/sources

define git-sha
$(shell git --git-dir $1/.git --work-tree $1 rev-parse --short HEAD)
endef
OPENGAPPS_COMMIT_IDS := $(strip $(foreach dir, \
	$(shell ls $(OPENGAPPS_SOURCES_DIR) | sort), \
	$(call git-sha, $(OPENGAPPS_SOURCES_DIR)/$(dir))))
OPENGAPPS_ALL_COMMIT_IDS := $(call subst, ,-,$(OPENGAPPS_COMMIT_IDS))

OPENGAPPS_CHECK_FILE := $(OPENGAPPS_MAKEFILE_DIR)/.$(TARGET_PRODUCT)-$(OPENGAPPS_VARIANT)-$(OPENGAPPS_ALL_COMMIT_IDS)
$(OPENGAPPS_CHECK_FILE):
	rm -R $(OPENGAPPS_MAKEFILE_DIR)/* 2>/dev/null || true
	mkdir -p $(OPENGAPPS_MAKEFILE_DIR)
	@echo "----- Generating OpenGapps Makefiles... -----"
	@echo "TARGET_ARCH: $(TARGET_ARCH)"
	@echo "PLATFORM_SDK_VERSION: $(PLATFORM_SDK_VERSION)"
	@echo "PRODUCT: $(TARGET_PRODUCT)"
	$(OPENGAPPS_TOOLS_DIR)/scripts/generate_aosp_makefiles.sh $(TARGET_ARCH) $(PLATFORM_SDK_VERSION) $(OPENGAPPS_VARIANT)
	@echo "----- Generated OpenGapps Makefiles -----"
	$(hide) touch $(OPENGAPPS_CHECK_FILE)

opengapps: $(OPENGAPPS_CHECK_FILE)
