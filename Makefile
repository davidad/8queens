# Detect OS.
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	FORMAT := macho64
endif
ifeq ($(UNAME),Linux)
	FORMAT := elf64
endif

.PHONY: run
run: 8queens
	./8queens; echo $$?

8queens: 8queens.o
	ld -o $@ $^
	@echo '==='

ifeq ($(NOPRETTY), 1)
  FLAGS += -DNOPRETTY
endif

ifeq ($(LOOPED), 1)
  FLAGS += -DLOOPED=10000
endif

-include *.dep
%.o: ./nasm %.asm
	./nasm $*.asm $(FLAGS) -f $(FORMAT) -o $@ -MD $*.dep

.PHONY: distclean clean
clean:
	rm -f *.o 8queens

distclean: clean
	rm -rf download nasm *.dep

#-------------------------------------------------------------------------------
# Download NASM.
NASM_DL_VERSION := 2.11
download: ; mkdir download

ifeq ($(UNAME),Darwin)
    # local filename to save
    NASM_DL := nasm-osx.zip

    # intermediate component of NASM binary URL
    NASM_DL_PLATFORM := macosx

    # final component of NASM binary URL
    NASM_DL_EXT := -macosx.zip

    # git hash-object
    NASM_DL_HASH := dae69c310bedc02f07501adef71795d46e8c2a18

    # archive to extract binary from (distinct from NASM_DL in the case of RPM)
    NASM_DL_ARCHIVE := nasm-osx.zip

    # binary to extract from archive
    NASM_DL_BIN = nasm-$(NASM_DL_VERSION)/nasm
endif
ifeq ($(UNAME),Linux)
    NASM_DL := nasm-linux.rpm
    NASM_DL_PLATFORM := linux
    NASM_DL_EXT := -1.x86_64.rpm
    NASM_DL_HASH := 2bc231565485b9c41d7c217ffe0e26a9ed9e7635
    NASM_DL_ARCHIVE := nasm-linux.cpio  # generated from the RPM, see below
    NASM_DL_BIN := ./usr/bin/nasm
endif

download/$(NASM_DL): download
	curl "http://www.nasm.us/pub/nasm/releasebuilds/$(NASM_DL_VERSION)\
	/$(NASM_DL_PLATFORM)/nasm-$(NASM_DL_VERSION)$(NASM_DL_EXT)" -o $@
	test `git hash-object $@` = $(NASM_DL_HASH)

# The Linux binary version of NASM is distributed as an RPM.
# This is moderately annoying, but we can deal with it without adding any
# superfluous dependencies.
# The following code is adapted from:
# http://rpm5.org/cvs/fileview?f=rpm/scripts/rpm2cpio&v=1.6
%.cpio: %.rpm
	if test "$<" != "download/$(notdir $<)" ;\
	 then mv $< download/$(notdir $<); fi
	@echo "Generating $@ from download/$(notdir $<)..."
	@cd download; f=$(notdir $<); l=96; o=`expr $$l + 8`; set `od -j $$o -N 8 -t u1 $$f`; il=`expr 256 \* \( 256 \* \( 256 \* $$2 + $$3 \) + $$4 \) + $$5`; dl=`expr 256 \* \( 256 \* \( 256 \* $$6 + $$7 \) + $$8 \) + $$9`; z=`expr 8 + 16 \* $$il + $$dl`; o=`expr $$o + $$z + \( 8 - \( $$z \% 8 \) \) \% 8 + 8`; set `od -j $$o -N 8 -t u1 $$f`; il=`expr 256 \* \( 256 \* \( 256 \* $$2 + $$3 \) + $$4 \) + $$5`; dl=`expr 256 \* \( 256 \* \( 256 \* $$6 + $$7 \) + $$8 \) + $$9`; h=`expr 8 + 16 \* $$il + $$dl`; o=`expr $$o + $$h`; e="dd if=$$f ibs=$$o skip=1"; c=`($$e |file -) 2>/dev/null`; if echo $$c | grep -q gzip; then d=gunzip; elif echo $$c | grep -q bzip2; then d=bunzip2; elif echo $$c | grep -q xz; then d=unxz; elif echo $$c | grep -q cpio; then d=cat; else d=`which unlzma 2>/dev/null`; case "$$d" in /*) ;; *) d=`which lzmash 2>/dev/null`; case "$$d" in /*) d="lzmash -d -c" ;; *) d=cat ;; esac ;; esac; fi; $$e 2>/dev/null | $$d > $(notdir $@)

./nasm: download/$(NASM_DL_ARCHIVE)
	cd download \
	&& cpio -id --quiet $(NASM_DL_BIN) < $(NASM_DL_ARCHIVE) \
	&& mv $(NASM_DL_BIN) ../nasm \
	&& rmdir -p $(dir $(subst ./,,$(NASM_DL_BIN)))
	ls -l nasm
	./nasm -v
#-------------------------------------------------------------------------------
