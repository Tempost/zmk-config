#!/bin/sh
set -e

west build -s zmk/app -d build/left -b xiao_ble --pristine -- -DZMK_CONFIG=/home/cody/src/zmk-config/config -DSHIELD=cygnus_left
west build -s zmk/app -d build/right -b xiao_ble --pristine -- -DZMK_CONFIG=/home/cody/src/zmk-config/config -DSHIELD=cygnus_right

cp build/left/zephyr/zmk.uf2 cygnus_left.u2f
cp build/right/zephyr/zmk.uf2 cygnus_right.u2f
