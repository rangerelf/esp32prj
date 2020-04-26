.PHONY: help

# Local work directories
VENV_D		= .py.d
DOWNLOADS_D	= .fw.d
MICROPYTHON_D	= .micropython.d

# System python3 interpreter.
PYTHON		= /usr/bin/python3.6m
PY_REQUIREMENTS	= adafruit-ampy esptool pyserial
VIRTUALENV	= /usr/bin/virtualenv

# Predefine full paths to some tools
MPY_CROSS	= $(MICROPYTHON_D)/mpy-cross/mpy-cross
AMPY		= $(VENV_D)/bin/ampy
ESPTOOL		= $(VENV_D)/bin/esptool.py
MINITERM	= $(VENV_D)/bin/miniterm.py

# Serial port configuration parameters.
# baud rates: 57600 115200 230400 460800 576000 921600
# They can be overridden on the command line.
PORT	?= /dev/ttyUSB0
BAUD	?= 115200
CHIP	?= esp32
YEAR	:= $(shell date +%Y)

# Definitions for automatic downloading of remote firmwares.
MICROPYTHON_REPO = https://github.com/micropython/micropython.git
MICROPYTHON_ORG  = https://micropython.org
FIRMWARES_PAGE	 = $(MICROPYTHON_ORG)/download/esp32
DOWNLOAD_URL	 = $(MICROPYTHON_ORG)/resources/firmware
VERSION		?=

# Filenames of our stuff.
SOURCES		:= $(shell ls src/*.py 2>/dev/null)
COMPILED	:= $(patsubst src/%.py,lib/%.mpy,$(SOURCES))
UPLOADED	:= $(patsubst lib/%.mpy,lib/%.mpy.ul,$(COMPILED))

##
## Set up some automatic rules for compiling and uploading.
##
$(COMPILED): $(SOURCES)
	$(MPY_CROSS) -Oemit=bytecode -o $@ $<
	@rm -f $@.ul

# Upload compiled module.
$(UPLOADED): $(COMPILED)
	$(AMPY) -p $(PORT) -b $(BAUD) put $< /$(<F)
	@touch $@

help:
	@echo "Latest: $(shell readlink latest 2>/dev/null || echo N/A)"
	@echo "Sources: $(SOURCES)"
	@echo "Compiled: $(COMPILED)"
	@echo "Uploaded: $(UPLOADED)"
	@echo ""
	@echo "Usage:"
	@echo "  - make [help]    - Display this message"
	@echo "  - make clean     - Remove all temp files, virtual env, repo and fw dirs"
	@echo "  - make versions  - Display list of downloadable firmware versions"
	@echo "  - make update    - Download the latest firmware version"
	@echo "  - make update-stable - Download the latest stable firmware"
	@echo "  - make update-idf4 - Download the latest idf4-built firmware version"
	@echo "  - make update-stable-idf4 - Download the latest idf4-built stable firmware"
	@echo "  - make download  - Download a specific firmware version"
	@echo "  - make flash     - Flash the firmware on the chip"
	@echo "  - make compile   - Compile all the .py files in the project"
	@echo "  - make upload    - Upload all compiled modules"
	@echo "  - make term      - Run miniterm into the onboard repl"
	@echo "  - make ls        - List vfs filesystem"
	@echo "  - make venv      - Clean and reinstall python virtual env"
	@echo "  - make mpy-cross - Build the latest micropython cross compiler"

clean:
	-rm -f $(COMPILED) $(UPLOADED) latest
	-rm -rf $(MICROPYTHON_D) $(VENV_D) $(DOWNLOADS_D)

flash: $(ESPTOOL) latest
	$(ESPTOOL) --port $(PORT) --chip $(CHIP) erase_flash
	$(ESPTOOL) --port $(PORT) --chip $(CHIP) write_flash 0x1000 latest

compile: $(MPY_CROSS) $(COMPILED)

upload: $(AMPY) $(UPLOADED)

ls: $(AMPY)
	$(AMPY) -p $(PORT) -b $(BAUD) ls

term: $(MINITERM)
	$(MINITERM) --raw $(PORT) $(BAUD)

download: $(DOWNLOADS_D)
	@test -n "$(VERSION)"
	@echo "Downloading: $(VERSION)"
	@test -f $(VERSION) || curl -Ls $(DOWNLOAD_URL)/$(VERSION) -o $(DOWNLOADS_D)/$(VERSION)
	-@rm -f latest
	@ln -sv $(DOWNLOADS_D)/$(VERSION) latest

update:
	@make download VERSION=$(shell make versions | head -1)

update-stable:
	@make download VERSION=$(shell make stable-versions | head -1)

update-idf4:
	@make download VERSION=$(shell make versions | grep idf4 | head -1)

update-stable-idf4:
	@make download VERSION=$(shell make stable-versions | grep idf4 | head -1)

venv:
	-@rm -rf $(VENV_D)
	@make $(VENV_D)

########################################################################
## Display a list of the most recent firmwares available
##
versions:
	@curl -Ls $(FIRMWARES_PAGE) \
	| egrep -o 'href="[^"]+esp32[^"]+"' \
	| sed -e 's|^.*/||g' -e 's|"[^"]*$$||g'

stable-versions:
	@make versions | egrep -- '-v[0-9]+(\.[0-9]+)+\.bin'

########################################################################
## Set up python virtualenv.
##
$(AMPY): $(VENV_D)

$(ESPTOOL): $(VENV_D)

$(MINITERM): $(VENV_D)

$(VENV_D):
	$(VIRTUALENV) -p $(PYTHON) $(VENV_D)
	$(VENV_D)/bin/pip install -U $(PY_REQUIREMENTS)

########################################################################
## Set up mpy-cross
##
$(MPY_CROSS): $(MICROPYTHON_D)
	cd $(MICROPYTHON_D)/mpy-cross \
	git checkout $(shell git tag -l | tail -1) \
	&& make clean \
	&& git pull --prune \
	&& make

$(MICROPYTHON_D):
	git clone $(MICROPYTHON_REPO) $(MICROPYTHON_D)

$(DOWNLOADS_D):
	@mkdir -p $(DOWNLOADS_D)

