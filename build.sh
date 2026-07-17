#!/bin/sh
set -e

. .venv/bin/activate

CMAKE_ARGS="-DZMK_CONFIG=$HOME/src/zmk-config/config"
WEST_OPTS="build -s zmk/app -b xiao_ble --pristine"

west ${WEST_OPTS} -d build/dongle -S zmk-usb-logging -- \
	"${CMAKE_ARGS}" -DZMK_EXTRA_MODULES=/home/cody/src/zmk-config/prospector-zmk-module \
	-DSHIELD="cygnus_dongle prospector_adapter"

west ${WEST_OPTS} -d build/left -- \
	"${CMAKE_ARGS}" \
	-DSHIELD=cygnus_left

west ${WEST_OPTS} -d build/right -- \
	"${CMAKE_ARGS}" \
	-DSHIELD=cygnus_right

cp build/dongle/zephyr/zmk.uf2 cygnus_dongle.u2f
cp build/left/zephyr/zmk.uf2 cygnus_left.u2f
cp build/right/zephyr/zmk.uf2 cygnus_right.u2f
