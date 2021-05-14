OS := $(shell uname)

CEXT_NAME=pixel_array
CEXT_EXTENSION=.h
CEXT_PATH=lib/
CEXT_FILES=pixel_array.c bitmap_decoder.c lines.c polygons.c
CEXT_SRC=$(addprefix $(CEXT_PATH),$(CEXT_FILES))
BINDER=../dragonruby-bind
BINDER_FFI_MODULE=CPXArray
BINDER_OUTPUT_EXTENSION=-bindings.c
CC=clang
CFLAGS=-shared -isystem include -lc -I../include -I. -fPIC
PRODUCTION_FLAGS=-O3 -Wall
DEBUG_FLAGS=-g -O0 -DDEBUG_BUILD -Wall
ifeq ($(OS),Darwin)
	DYLIB_PATH=native/macos/
	DYLIB_EXTENSION=.dylib
else
	DYLIB_PATH=native/linux-amd64/
	DYLIB_EXTENSION=.so
endif
DYLIB_DSYM=.dSYM
DYLIB_STR=$(DYLIB_PATH)$(CEXT_NAME)$(DYLIB_EXTENSION)
COMBINED_HEADER=$(CEXT_PATH)header$(CEXT_EXTENSION)

debug:
	$(BINDER) --ffi-module=$(BINDER_FFI_MODULE) --output=$(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION) $(COMBINED_HEADER)
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) -o $(DYLIB_STR) $(CEXT_SRC) $(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION)

prod:
	$(BINDER) --ffi-module=$(BINDER_FFI_MODULE) --output=$(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION) $(COMBINED_HEADER)
	$(CC) $(PRODUCTION_FLAGS) $(CFLAGS) -o $(DYLIB_STR) $(CEXT_SRC) $(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION)

clean:
	rm -f $(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION) $(DYLIB_STR)
	rm -rf $(DYLIB_STR)$(DYLIB_DSYM)

smaug:
	smaug bind --output=$(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION) $(COMBINED_HEADER) --ffi-module=$(BINDER_FFI_MODULE)
	$(CC) $(DEBUG_FLAGS) $(CFLAGS) -o $(DYLIB_STR) $(CEXT_SRC) $(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION)

smaug-prod:
	smaug bind --output=$(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION) $(COMBINED_HEADER) --ffi-module=$(BINDER_FFI_MODULE)
	$(CC) $(PRODUCTION_FLAGS) $(CFLAGS) -o $(DYLIB_STR) $(CEXT_SRC) $(CEXT_PATH)$(CEXT_NAME)$(BINDER_OUTPUT_EXTENSION)