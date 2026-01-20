#!/bin/sh

set -e

west build -s zmk/app -d build/reset -b xiao_ble --pristine -- \
	-DZMK_CONFIG=/home/cody/src/zmk-config/config \
	-DSHIELD="settings_reset"

cp build/reset/zephyr/zmk.uf2 reset.u2f
