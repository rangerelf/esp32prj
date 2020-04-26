# Base ESP32 MicroPython Project

This base repository contains a `Makefile` and `.gitignore` files that can help you streamline a micropython project.

## `Makefile`

The `Makefile` will help you by streamlining the usual drudge work of setting up the project, gathering the tools you need, running the tools, and so on and so forth.  If you run `make` by itself you get the following:

```shell
$ make
Latest: N/A
Sources: 
Compiled: 
Uploaded: 

Usage:
  - make [help]    - Display this message
  - make clean     - Remove all temp files, virtual env, repo and fw dirs
  - make versions  - Display list of downloadable firmware versions
  - make update    - Download the latest firmware version
  - make update-stable - Download the latest stable firmware
  - make update-idf4 - Download the latest idf4-built firmware version
  - make update-stable-idf4 - Download the latest idf4-built stable firmware
  - make download  - Download a specific firmware version
  - make flash     - Flash the firmware on the chip
  - make compile   - Compile all the .py files in the project
  - make upload    - Upload all compiled modules
  - make term      - Run miniterm into the onboard repl
  - make ls        - List vfs filesystem
  - make venv      - Clean and reinstall python virtual env
  - make mpy-cross - Build the latest micropython cross compiler
```

At the top are the basic information about the project:

* `Latest:` The latest downloaded micropython firmware, or `N/A` if none yet.
* `Sources:` Your source files, which should live in the `/src` directory.
* `Compiled:` The compiled names of your source files (compiled with `mpy-cross`)
* `Uploaded:` Which files have been flagged as uploaded

Below are the recipes available to you:

* `clean` Delete all temporary, downloaded and compiled files
* `versions` Display a list of all the firmware versions available to download
* `stable-versions` Display a list of stable versions available for download
* `update` Download the latest firmware available at the download site
* `update-stable` Download the latest stable firmware available at the download site
* `update-idf4` Download the latest `IDF4` firmware available
* `update-stable-idf4` Ditto, but the latest stable `IDF4` firmware
* `download` Download any version, use with `VERSION=${FIRMWARE_NAME}`, from the list of names displayed with `versions` or `stable-versions` 
* `flash` Flash the firmware displayed as `Latest:` (above) to the device; also clears out any uploaded files
* `compile` Compile all your source files with `mpy-cross` into `%.mpy` files; clears out all the "uploaded" flags
* `upload` Transfer all your compiled modules to the device, store in the VFS storage block
* `term` Open an interactive terminal to the micropython prompt
* `ls` List all the files that have been transferred
* `venv` Re-create the python virtual environment which hosts the esp32 tools
* `mpy-cross` Build the compiler to transform the `%.py` modules to `%.mpy`; it's tightly bound to micropython, so it might need to be rebuilt whenever a new firmware is set up.

## `.gitignore`

Ignore:

* The micropython source directory
* The python virtual environment
* The downloaded firmwares directory
* All the compiled python modules and any uploaded flag files

