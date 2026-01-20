all: left right dongle

left:
	west build -s zmk/app -d build/left -b seeeduino_xiao_ble --pristine -- \
		-DZMK_CONFIG=/home/cody/src/zmk-config/config \
		-DSHIELD=cygnus_left \
		-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
right:
	west build -s zmk/app -d build/right -b seeeduino_xiao_ble --pristine -- \
		-DZMK_CONFIG=/home/cody/src/zmk-config/config \
		-DSHIELD=cygnus_right \
		-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n
dongle:
	west build -s zmk/app -d build/dongle -b seeeduino_xiao_ble -S zmk-usb-logging --pristine -- \
		-DZMK_CONFIG=/home/cody/src/zmk-config/config \
		-DSHIELD=cygnus_dongle \
		-DCONFIG_ZMK_SPLIT_BLE_CENTRAL_PERIPHERALS=2 \
		-DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=y
