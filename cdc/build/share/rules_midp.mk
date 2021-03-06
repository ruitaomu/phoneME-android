#
# Copyright  1990-2008 Sun Microsystems, Inc. All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version
# 2 only, as published by the Free Software Foundation. 
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License version 2 for more details (a copy is
# included at /legal/license.txt). 
# 
# You should have received a copy of the GNU General Public License
# version 2 along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA 
# 
# Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa
# Clara, CA 95054 or visit www.sun.com if you need additional
# information or have any questions. 
#

ifeq ($(USE_MIDP),true)

# print our configuration
printconfig::
	@echo "MIDP_DIR           = $(MIDP_DIR)"
	@echo "PROJECT_MIDP_DIR   = $(PROJECT_MIDP_DIR)"
	@echo "PCSL_DIR           = $(PCSL_DIR)"

# Build PCSL before MIDP.
initbuild_profile:: $(PCSL_DEPENDENCIES)
	@echo "====> start pcsl build"
	$(AT)$(MAKE) $(MAKE_NO_PRINT_DIRECTORY) \
		     PCSL_PLATFORM=$(PCSL_PLATFORM) \
	             NETWORK_MODULE=$(NETWORK_MODULE) \
		     MEMORY_MODULE=$(MEMORY_MODULE) \
		     MEMORY_PORT_MODULE=$(MEMORY_PORT_MODULE) \
	             PCSL_OUTPUT_DIR=$(PCSL_OUTPUT_DIR) \
	             GNU_TOOLS_BINDIR=$(GNU_TOOLS_BINDIR) \
                     USE_DEBUG=$(USE_DEBUG) \
	             -C $(PCSL_DIR) $(PCSL_MAKE_OPTIONS)
	@echo "<==== end pcsl build"

#
# Invoke MIDP build process. Build MIDP classes first. If 
# CVM_PRELOAD_LIB is true, MIDP classes are added to  JCC 
# input list so the we can romize MIDP classes.
#
# We can't build MIDP natives together with classes, because
# MIDP natives requires generated header files, such as
# generated/cni/sun_misc_CVM.h and
# generated/offsets/java_lang_ref_Reference.h. The header files 
# are generated by the ROMizer. MIDP natives are compiled
# after ROMization is done.
#
$(CVM_ROMJAVA_LIST): $(MIDP_PUB_CLASSES_ZIP) $(MIDP_PRIV_CLASSES_ZIP)

$(MIDP_PUB_CLASSES_ZIP) $(MIDP_PRIV_CLASSES_ZIP): $(MIDP_CLASSES_ZIP)

$(MIDP_CLASSES_ZIP): $(MIDP_CLASSESZIP_DEPS) force_midp_build
	@echo "====> start building MIDP classes"
	$(AT)$(MAKE) $(MAKE_NO_PRINT_DIRECTORY) \
		     JDK_DIR=$(JDK_DIR) TARGET_VM=$(TARGET_VM) \
	             TARGET_CPU=$(TARGET_CPU) TARGET_OS=$(MIDP_TARGET_OS) \
	             USE_DEBUG=$(USE_DEBUG) \
	             USE_RESTRICTED_CRYPTO=$(USE_RESTRICTED_CRYPTO) \
	             USE_MIDP_MALLOC=$(USE_MIDP_MALLOC) \
                 MIDP_OBJ_FILE_LIST=$(MIDP_OBJ_FILE_LIST) MIDP_SHARED_LIB=$(MIDP_SHARED_LIB) \
                 CVM_STATICLINK_LIBS=$(CVM_STATICLINK_LIBS) \
	             VERIFY_BUILD_ENV= \
	             CONFIGURATION_OVERRIDE=$(CONFIGURATION_OVERRIDE) \
	             USE_QT_FB=$(USE_QT_FB) USE_DIRECTFB=$(USE_DIRECTFB) \
	             USE_DIRECTDRAW=$(USE_DIRECTDRAW) USE_OPENGL=$(USE_OPENGL)\
	             USE_SSL=$(USE_SSL) USE_CONFIGURATOR=$(USE_CONFIGURATOR) \
	             USE_VERBOSE_MAKE=$(USE_VERBOSE_MAKE) \
	             PCSL_TARGET_DIR=$(PCSL_OUTPUT_DIR)/$(PCSL_TARGET) \
	             GNU_TOOLS_BINDIR=$(GNU_TOOLS_BINDIR) \
	             MIDP_CLASSES_ZIP=$(MIDP_CLASSES_ZIP) \
                     MIDP_PRIV_CLASSES_ZIP=$(MIDP_PRIV_CLASSES_ZIP) \
                     MIDP_PUB_CLASSES_ZIP=$(MIDP_PUB_CLASSES_ZIP) \
		     VM_BOOTCLASSPATH=$(VM_BOOTCLASSPATH) \
		     CVM_BUILDTIME_CLASSESZIP=$(CVM_BUILDTIME_CLASSESZIP) \
	             $(MIDP_JSROP_USE_FLAGS) \
	             USE_OEM_AMS=$(USE_OEM_AMS) \
	             OEM_AMS_DIR=$(OEM_AMS_DIR) \
	             USE_OEM_PUSH=$(USE_OEM_PUSH) \
	             OEM_PUSH_DIR=$(OEM_PUSH_DIR) \
	             PERMISSION_EXTENSIONS_LIST="$(PERMISSION_EXTENSIONS_LIST)" \
	             COMPONENTS_DIR=$(COMPONENTS_DIR) \
	             PROJECT_MIDP_DIR=$(PROJECT_MIDP_DIR) \
	             JSR_CONFIGURATION_INPUT_FILES="$(JSR_CONFIGURATION_INPUT_FILES)" \
	             rom -C $(MIDP_MAKEFILE_DIR)
	@echo "<==== end building MIDP classes"

#
# Generate a list of MIDP classes. This list is added to
# the $(CVM_MIDPCLASSLIST) to allow accessing from midlets.
#
$(MIDP_CLASSLIST): $(MIDP_PUB_CLASSES_ZIP)
	$(AT)$(CVM_JAVA) -cp  $(CVM_BUILD_TOP)/classes.jcc JavaAPILister \
	    -listapi:include=java/*,include=javax/*,input=$(MIDP_PUB_CLASSES_ZIP),cout=$(MIDP_CLASSLIST)


#
# Build the source bundle
#
source_bundle:: $(CVM_BUILD_DEFS_MK) 
	$(AT)$(MAKE) $(MAKE_NO_PRINT_DIRECTORY) \
		     JDK_DIR=$(JDK_DIR) TARGET_VM=$(TARGET_VM) \
	             TARGET_CPU=$(TARGET_CPU) TARGET_OS=$(MIDP_TARGET_OS) \
	             USE_DEBUG=$(USE_DEBUG) \
	             USE_RESTRICTED_CRYPTO=$(USE_RESTRICTED_CRYPTO) \
	             USE_MIDP_MALLOC=$(USE_MIDP_MALLOC) \
                 MIDP_OBJ_FILE_LIST=$(MIDP_OBJ_FILE_LIST) MIDP_SHARED_LIB=$(MIDP_SHARED_LIB) \
                 CVM_STATICLINK_LIBS=$(CVM_STATICLINK_LIBS) \
	             VERIFY_BUILD_ENV= \
	             CONFIGURATION_OVERRIDE=$(CONFIGURATION_OVERRIDE) \
	             USE_QT_FB=$(USE_QT_FB) USE_DIRECTFB=$(USE_DIRECTFB) \
	             USE_DIRECTDRAW=$(USE_DIRECTDRAW) USE_OPENGL=$(USE_OPENGL)\
	             USE_SSL=$(USE_SSL) USE_CONFIGURATOR=$(USE_CONFIGURATOR) \
	             USE_VERBOSE_MAKE=$(USE_VERBOSE_MAKE) \
	             PCSL_PLATFORM=$(PCSL_PLATFORM) \
	             GNU_TOOLS_BINDIR=$(GNU_TOOLS_BINDIR) \
		     SOURCE_OUTPUT_DIR=$(SOURCE_OUTPUT_DIR) \
	             $(MIDP_JSROP_USE_FLAGS) \
	             MIDP_CLASSES_ZIP=$(MIDP_CLASSES_ZIP) \
                     MIDP_PRIV_CLASSES_ZIP=$(MIDP_PRIV_CLASSES_ZIP) \
                     MIDP_PUB_CLASSES_ZIP=$(MIDP_PUB_CLASSES_ZIP) \
	             COMPONENTS_DIR=$(COMPONENTS_DIR) \
	             PROJECT_MIDP_DIR=$(PROJECT_MIDP_DIR) \
	             source_bundle -C $(MIDP_MAKEFILE_DIR) 
	$(AT)$(MAKE) $(MAKE_NO_PRINT_DIRECTORY) \
		     PCSL_PLATFORM=$(PCSL_PLATFORM) \
	             NETWORK_MODULE=$(NETWORK_MODULE) \
	             PCSL_OUTPUT_DIR=$(PCSL_OUTPUT_DIR) \
	             GNU_TOOLS_BINDIR=$(GNU_TOOLS_BINDIR) \
		     SOURCE_OUTPUT_DIR=$(SOURCE_OUTPUT_DIR) \
		     COMPONENTS_DIR=$(COMPONENTS_DIR) \
	             source_bundle -C $(PCSL_DIR) $(PCSL_MAKE_OPTIONS)

#
# Now build MIDP natives. MIDP natives are linked into CVM binary.
#
# Only one of MIDP_STATIC_LIB and MIDP_SHARED_LIB variables should be defined!
#

# Ensure MIDP natives is build after MIDP classes get compiled and 
# JNI headers get generated
$(MIDP_NATIVES): $(CVM_ROMJAVA_LIST) $(MIDP_CLASSLIST)

$(MIDP_NATIVES): force_midp_build
	@echo "====> start building MIDP natives"
	$(AT)$(MAKE) $(MAKE_NO_PRINT_DIRECTORY) \
		     JDK_DIR=$(JDK_DIR) TARGET_VM=$(TARGET_VM) \
	             TARGET_CPU=$(TARGET_CPU) TARGET_OS=$(MIDP_TARGET_OS) \
	             USE_DEBUG=$(USE_DEBUG) \
	             USE_RESTRICTED_CRYPTO=$(USE_RESTRICTED_CRYPTO) \
	             USE_MIDP_MALLOC=$(USE_MIDP_MALLOC) \
                 MIDP_OBJ_FILE_LIST=$(MIDP_OBJ_FILE_LIST) MIDP_SHARED_LIB=$(MIDP_SHARED_LIB) \
                 CVM_STATICLINK_LIBS=$(CVM_STATICLINK_LIBS) \
	             VERIFY_BUILD_ENV= \
	             CONFIGURATION_OVERRIDE=$(CONFIGURATION_OVERRIDE) \
	             USE_QT_FB=$(USE_QT_FB) USE_DIRECTFB=$(USE_DIRECTFB) \
	             USE_DIRECTDRAW=$(USE_DIRECTDRAW) USE_OPENGL=$(USE_OPENGL)\
	             USE_SSL=$(USE_SSL) USE_CONFIGURATOR=$(USE_CONFIGURATOR) \
	             USE_VERBOSE_MAKE=$(USE_VERBOSE_MAKE) \
	             PCSL_TARGET_DIR=$(PCSL_OUTPUT_DIR)/$(PCSL_TARGET) \
	             GNU_TOOLS_BINDIR=$(GNU_TOOLS_BINDIR) \
	             MIDP_CLASSES_ZIP=$(MIDP_CLASSES_ZIP) \
                     MIDP_PRIV_CLASSES_ZIP=$(MIDP_PRIV_CLASSES_ZIP) \
                     MIDP_PUB_CLASSES_ZIP=$(MIDP_PUB_CLASSES_ZIP) \
		     VM_BOOTCLASSPATH=$(VM_BOOTCLASSPATH) \
	             COMPONENTS_DIR=$(COMPONENTS_DIR) \
	             PROJECT_MIDP_DIR=$(PROJECT_MIDP_DIR) \
	             $(MIDP_JSROP_USE_FLAGS) \
	             -C $(MIDP_MAKEFILE_DIR) \
                 midp
	$(AT)if [ ! -f $@ ]; then exit 1; fi
ifneq ($(USE_JUMP), true)
  ifeq ($(INCLUDE_SHELL_SCRIPTS), true)
	$(AT)cp $@ $(CVM_BINDIR)
  endif
endif
	@echo "<==== end building MIDP natives"

force_midp_build:

clean::
	rm -rf $(CVM_MIDP_BUILDDIR) $(MIDP_CLASSLIST)

endif
