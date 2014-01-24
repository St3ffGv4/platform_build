# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

# Add the ARM toolchain bin dir if it actually exists
ifeq ($(TARGET_ARCH),arm)
    ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_GCC_VERSION)/bin),)
        # this should be copied to HOST_OUT_EXECUTABLES instead
        ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-linux-androideabi-$(TARGET_GCC_VERSION)/bin
    endif
    ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-$(TARGET_GCC_VERSION)/bin),)
        # this should be copied to HOST_OUT_EXECUTABLES instead
        ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-eabi-$(TARGET_GCC_VERSION)/bin
    endif
else ifeq ($(TARGET_ARCH),x86)

# Add the x86 toolchain bin dir if it actually exists
    ifneq ($(wildcard $(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/x86/i686-linux-android-$(TARGET_GCC_VERSION)/bin),)
        # this should be copied to HOST_OUT_EXECUTABLES instead
        ABP:=$(ABP):$(PWD)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/x86/i686-linux-android-$(TARGET_GCC_VERSION)/bin
    endif
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

endif # CALLED_FROM_SETUP


ifneq ($(PRINT_BUILD_CONFIG),)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")
$(info =====================================================================)
$(info |              THE FREAX PROJECT ~ MoltenMotherBoard                |)
$(info ---------------------------------------------------------------------)
$(info -> VERSION = $(PLATFORM_VERSION))
$(info -> BUILD VARIANT = $(TARGET_BUILD_VARIANT))
$(info -> PRODUCT = $(TARGET_PRODUCT))
$(info -> PRODUCT ARCH = $(TARGET_ARCH))
$(info -> PRODUCT ARCH VARIANT = $(TARGET_ARCH_VARIANT))
$(info -> PRODUCT CPU VARIANT = $(TARGET_CPU_VARIANT))
$(info -> ENVIRONMENT ARCH = $(HOST_ARCH))
$(info -> ENVIRONMENT OS = $(HOST_OS))
$(info -> ENVIRONMENT OS EXTRA = $(HOST_OS_EXTRA))
$(info -> BUILD ID = $(BUILD_ID))
$(info -> OUT PATH = $(OUT_DIR))
$(info =====================================================================)
endif
