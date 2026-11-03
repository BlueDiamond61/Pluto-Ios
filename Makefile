# ─── Build config ────────────────────────────────────────────────────────────
TARGET_NAME   = Pluto
ARCH          = arm64
MIN_IOS       = 14.0
SDK           = $(shell xcrun --sdk iphoneos --show-sdk-path 2>/dev/null)

SRCS          = sources/PlutoDemo.mm
INCLUDES      = -IInclude
FRAMEWORKS    = -framework UIKit -framework Foundation -framework CoreGraphics

CLANG         = $(shell xcrun --find clang++ 2>/dev/null || echo clang++)

CXXFLAGS = \
    -arch $(ARCH) \
    -isysroot $(SDK) \
    -miphoneos-version-min=$(MIN_IOS) \
    -fobjc-arc \
    -std=c++17 \
    -O2 \
    -fvisibility=hidden \
    -fmodules \
    $(INCLUDES)

LDFLAGS = \
    -arch $(ARCH) \
    -isysroot $(SDK) \
    -miphoneos-version-min=$(MIN_IOS) \
    -dynamiclib \
    -install_name @executable_path/$(TARGET_NAME).dylib \
    $(FRAMEWORKS)

OUT = $(TARGET_NAME).dylib

# ─── Rules ────────────────────────────────────────────────────────────────────
all: $(OUT)

$(OUT): $(SRCS) include/*.h
	$(CLANG) $(CXXFLAGS) $(LDFLAGS) $(SRCS) -o $@
	@echo "[+] Built $(OUT)"

# Sign with ldid (jailbreak) or leave unsigned for KSign injection
sign:
	ldid -S $(OUT)
	@echo "[+] Signed $(OUT)"

clean:
	rm -f $(OUT)

.PHONY: all sign clean