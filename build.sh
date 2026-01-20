#!/bin/sh
set -e

CMAKE_ARGS="-DZMK_CONFIG=$HOME/src/zmk-config/config"
WEST_OPTS="-s zmk/app -b xiao_ble --pristine"

west build ${WEST_OPTS} -d build/dongle -S zmk-usb-logging -- \
	"${CMAKE_ARGS}" \
	-DSHIELD="cygnus_dongle prospector_adapter"

west build ${WEST_OPTS} -s zmk/app -d build/left -- \
	"${CMAKE_ARGS}" \
	-DSHIELD=cygnus_left

west build ${WEST_OPTS} -d build/right -- \
	"${CMAKE_ARGS}" \
	-DSHIELD=cygnus_right

cp build/dongle/zephyr/zmk.uf2 cygnus_dongle.u2f
cp build/left/zephyr/zmk.uf2 cygnus_left.u2f
cp build/right/zephyr/zmk.uf2 cygnus_right.u2f
