##
# Makefile for awk
##

# Project info
Project           = awk
UserType          = Developer
ToolType          = Commands

Patches = main.c.diff makefile.diff awk.h.diff awkgram.y.diff \
          b.c.diff lib.c.diff main.c.diff2 run.c.diff tran.c.diff \
          run-makefile-gcc4.diff awk.1.diff

include $(MAKEFILEPATH)/CoreOS/ReleaseControl/Common.make

SDKROOT ?= /

Extra_CC_Flags    = -mdynamic-no-pic -isysroot $(SDKROOT)
Sources           = $(SRCROOT)/$(Project)

install_source::
	$(MKDIR) $(Sources)
	$(TAR) -C $(Sources) -xzf $(SRCROOT)/awk.tar.gz
	@for patch in $(Patches); do \
		(cd $(Sources) && patch -p0 -F0 < $(SRCROOT)/patches/$${patch}) || exit 1; \
	done

build:: shadow_source
	$(MAKE) -C $(BuildDirectory) $(Environment)

OSV = $(DSTROOT)/usr/local/OpenSourceVersions
OSL = $(DSTROOT)/usr/local/OpenSourceLicenses

install::
	$(INSTALL_DIRECTORY) $(DSTROOT)/usr/bin
	$(INSTALL_PROGRAM) $(BuildDirectory)/a.out $(DSTROOT)/usr/bin/awk
	$(INSTALL_DIRECTORY) $(DSTROOT)/usr/share/man/man1
	$(INSTALL_FILE) $(Sources)/awk.1 $(DSTROOT)/usr/share/man/man1/awk.1
	$(INSTALL_DIRECTORY) $(OSV)
	$(INSTALL_FILE) $(SRCROOT)/awk.plist $(OSV)
	$(INSTALL_DIRECTORY) $(OSL)
	$(HEAD) -n 23 $(Sources)/README > $(OSL)/awk.txt
