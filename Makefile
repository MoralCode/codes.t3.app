# Makefile for building the T3 Code Flatpak

# --- Variables ---
APP_ID := codes.t3.app
MANIFEST := $(APP_ID).yml
APPDATA := $(APP_ID).appdata.xml
DESKTOP := $(APP_ID).desktop
BUILD_DIR := build-dir
SQUASHFS_ROOT := squashfs-root
ARCH ?= x86_64


APPIMAGE_FILE = $(notdir $(T3_URL))

.PHONY: all build install run clean uninstall

# --- Main Targets ---

all: build

# Builds the Flatpak. Depends on the AppImage being extracted.
build: $(SQUASHFS_ROOT)
	@echo "--> Building the Flatpak..."
	# Update the version in the appdata file before building
	flatpak-builder $(BUILD_DIR) $(MANIFEST) --force-clean
	@echo "--> Build complete."

# Installs the Flatpak for the current user.
install: build
	@echo "--> Installing the Flatpak for the current user..."
	flatpak-builder --user --install --force-clean $(BUILD_DIR) $(MANIFEST)
	@echo "--> Installation complete."

# Uninstalls the application.
uninstall:
	@echo "--> Uninstalling T3 Code..."
	flatpak uninstall $(APP_ID)

# --- Helper Targets ---

# This target handles downloading and extracting the AppImage.
# It's triggered by the 'build' target.

T3-Code-$(VERSION)-$(ARCH).AppImage:
	@echo "--> Preparing AppImage..."
	@echo "    Downloading from: $(T3_URL)"
	wget -O $(APPIMAGE_FILE) "$(T3_URL)"
	@echo "    Making executable..."
	chmod +x $(APPIMAGE_FILE)

$(SQUASHFS_ROOT): T3-Code-$(VERSION)-$(ARCH).AppImage
	@echo "    Extracting AppImage..."
	./$(APPIMAGE_FILE) --appimage-extract
	@echo "    Extraction complete. Extracted to '$(SQUASHFS_ROOT)'."

# Cleans up all generated files and directories.
clean:
	@echo "--> Cleaning up..."
	rm -rf $(BUILD_DIR)
	rm -rf $(SQUASHFS_ROOT)
	rm -f *.AppImage
	@echo "--> Cleanup complete."
