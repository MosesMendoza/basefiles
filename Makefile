#-------------------------------------------------------------------------------
#
# Copyright 2013 Cumulus Networks Inc. all rights reserved
#

# Default target gets called by dh_build

# Make the lsb release file and os release file
#

# 
LSB_RELEASE_FILE = ./etc/cumulus/etc.replace/lsb-release
OS_RELEASE_FILE  = ./etc/cumulus/etc.replace/os-release

all:
	@ echo "Creating /etc/lsb-release with tag $(LSB_RELEASE_TAG)"
	@ rm -f $(LSB_RELEASE_FILE)
	@ echo "DISTRIB_ID=\"Cumulus Networks\"" >> $(LSB_RELEASE_FILE)
	@ echo "DISTRIB_RELEASE=$(RELEASE_VERSION)" >> $(LSB_RELEASE_FILE)
	@ echo "DISTRIB_DESCRIPTION=$(LSB_RELEASE_TAG)" >> $(LSB_RELEASE_FILE)

	@ echo "Creating /etc/os-release with tag $(LSB_RELEASE_TAG)"
	@ rm -f $(OS_RELEASE_FILE)
	@ echo "NAME=\"Cumulus Linux\"" >> $(OS_RELEASE_FILE)
	@ echo "VERSION_ID=$(RELEASE_VERSION)" >> $(OS_RELEASE_FILE)
	@ echo "VERSION=\"$(LSB_RELEASE_TAG)\"" >> $(OS_RELEASE_FILE)
	@ echo "PRETTY_NAME=\"Cumulus Linux\"" >> $(OS_RELEASE_FILE)
	@ echo "ID=cumulus-linux" >> $(OS_RELEASE_FILE)
	@ echo "ID_LIKE=debian" >> $(OS_RELEASE_FILE)
	@ echo "CPE_NAME=cpe:/o:cumulusnetworks:cumulus_linux:$(LSB_RELEASE_TAG)" >> $(OS_RELEASE_FILE)
	@ echo "HOME_URL=\"http://www.cumulusnetworks.com/\"" >> $(OS_RELEASE_FILE)

.PHONY: install
install:
	@ echo "Installing base files into pkg directory"
	@ cp -r etc $(DESTDIR)/
	@ cp -r usr $(DESTDIR)/
	@ cp -r sbin $(DESTDIR)/
	@ mkdir -p $(DESTDIR)/var/support/core


