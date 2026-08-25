### 🔴 1. TAP layer is a one-way trap

→TAP double-tap exists on NAV/MOUSE/MEDIA (K01), but TAP itself contains zero &to/layer/bootloader bindings. Once entered, exit requires a physical reset/power cycle.
Bites when: accidental double-tap on K01 → keyboard types but loses all layers/thumb keys; looks dead. Dongle in a case = button hunt.
Fix: either accept as deliberate (miryoku's game layer) and document, or override MIRYOKU_LAYER_TAP to put U_BOOT/→BASE on a corner, or drop TAP from MIRYOKU_LAYER_LIST if unused.
Reflash: dongle.

### 🔴 2. Mouse keys: root cause found, verify it's actually resolved

At 2e05459 ("need to figure out why mouse keys aren't working") no ZMK_POINTING config existed anywhere — mouse-key behaviors weren't compiled. HEAD adds config ZMK_POINTING
default y (defconfig) and CONFIG_ZMK_POINTING=y (cygnus.conf). The fix is in the tree; the open question is whether you've rebuilt+flashed since. Bites when: fix committed but
halves/dongle still run 2e05459 firmware.
Fix: rebuild all three from HEAD, flash, test MOUSE layer. If still dead, check build/dongle/zephyr/.config for CONFIG_ZMK_POINTING=y. Reflash: all three (conf change).

### 🔴 3. if SHIELD_DONGLE in cygnus/Kconfig.defconfig never fires

Your shield is cygnus_dongle → sets SHIELD_CYGNUS_DONGLE. SHIELD_DONGLE belongs to the dead, unused config/boards/shields/dongle/ directory (no build target uses shield dongle).
Result: keyboard name, ZMK_SLEEP, and BT_MAX_CONN=7 never apply; only central=y/peripherals=2 survive (rescued by cygnus_dongle.conf). The duplicated config BT_MAX_CONN lines
confirm this was never exercised.
Bites when: 2 halves + several BT hosts paired → dongle hits the default connection limit and a host won't connect/pair; BLE name is a generic default.
Fix: change guard to if SHIELD_CYGNUS_DONGLE, dedupe BT_MAX_CONN, delete or repurpose the dead dongle/ dir. Verify in build/dongle/zephyr/.config. Reflash: dongle.

### 🟠 4. Clipboard keys are the Insert-chord fallback — dead on macOS

No MIRYOKU_CLIPBOARD_* defined → U_CPY=Ctrl+Ins, U_PST=Shift+Ins, U_CUT=Shift+Del, U_UND=K_UNDO. Fine on Linux/Windows; on macOS all clipboard keys on NAV/MOUSE/BUTTON do nothing
(needs MIRYOKU_CLIPBOARD_MAC → Cmd-based).
Fix: one #define in custom_config.h, per your host OS. Reflash: dongle. ← Need your platform(s) to resolve this and Finding 6.

### 🟠 5. Prospector module is tracked two ways, one broken

It's a git submodule (gitlink f920b56) with no .gitmodules — fresh clones get an empty dir (which is its current on-disk state), so build.sh's dongle build (prospector_adapter
shield + ZMK_EXTRA_MODULES=…) fails until west update populates the same path. west.yml also declares it (branch core/zephyr-4-1, unpinned). Two managers, one path.
Fix: keep the west project (ZMK auto-loads west modules; drop the ZMK_EXTRA_MODULES line) and git rm --cached the gitlink — or vice versa. Pin both zmk and the prospector module to
commits. No firmware impact.

### 🟠 6. Hold-taps on bare defaults

tap-preferred, 200 ms, nothing else. Two concrete gaps:

- No hold-to-repeat anywhere. Tap-then-hold a letter → modifier, not aaaa; tap-then-hold BSPC-thumb → NUM layer, not repeated delete. Fix: quick-tap-ms = <150> on u_mt/u_lt.
- Dwell misfires. Resting a finger past 200 ms fires GUI/ALT/CTL and swallows the next key (mystery capitals/shortcuts). Fix: require-prior-idle-ms = <150> ("timeless HRM"). Stock
  miryoku ships these defaults deliberately, so treat as tuning, not a bug. Reflash: dongle.

### 🟠 7. Three build paths, three different firmwares

- CI (build.yaml + workflow @v0.3 vs west.yml main): version-line mismatch → toolchain/source skew; also CI dongle lacks prospector_adapter, so CI artifacts ≠ local artifacts;
  left-only -DCONFIG_ZMK_SPLIT=y is redundant noise; no settings_reset target (recovery UF2 only buildable locally via reset.sh).
- Makefile is stale: board seeeduino_xiao_ble was renamed xiao_ble (current ZMK) → its targets fail; no prospector; superseded by build.sh.
- Cosmetic: build.sh/reset.sh write *.u2f (typo for .uf2); compile_commands.json symlink dangles (no build/ here).
  Fix: one source of truth (recommend build.sh + build.yaml), delete the Makefile, align CI workflow ref with the ZMK version you pin, add settings_reset to build.yaml. No firmware
  impact.

### 🟡 8. Dead keys on MEDIA

No RGB LEDs and no ext_power device exist in any overlay → RGB_* (K05–K09) and EP_TOG (K19) are inert. Harmless stock miryoku; option to rebind (BT_NXT/PRV, &soft_off, …). Dongle.

### 🟡 9. System-layer gaps

&bootloader coverage is good (both halves, guarded corners). Missing: &sys_reset anywhere; &soft_off (needs CONFIG_ZMK_PM_SOFT_OFF=y; miryoku's
MIRYOKU_KLUDGE_SOFT_OFF+DOUBLETAPBOOT turns U_BOOT into a guarded soft-off — nice for travel); BT_SEL 4 macro exists but is unbound (4 profiles max reachable). All optional.
Dongle; soft_off also needs conf → all three.

### 🟡 10. Housekeeping (all optional)

cygnus_dongle.overlay duplicates the transform/layout instead of including cygnus.dtsi; cygnus.zmk.yml siblings: omits cygnus_dongle; EXTRA layer duplicates BASE (give it
MIRYOKU_EXTRA_COLEMAKDH if you ever want to trial an alt layout); CONFIG_BT_CTLR_TX_PWR_PLUS_8 + PHY_2M=n on all three radios is a deliberate battery-for-range trade — noted, keep.

1. Suggested order of work (each step independently flashable)

1. Rebuild HEAD, flash all three → verify mouse keys. (Findings 2; zero code change)
1. Fix SHIELD_DONGLE guard → SHIELD_CYGNUS_DONGLE, dedupe, delete dead dongle/ dir. Flash dongle; check .config. (3)
1. Un-break prospector tracking + pin zmk/module revisions. Build-only. (5)
1. Consolidate build paths: fix CI alignment, add settings_reset, delete Makefile. Build-only. (7)
1. HRM tuning in miryoku_behaviors.dtsi (quick-tap-ms, require-prior-idle-ms). Flash dongle; test rolls + repeat. (6)
1. Platform decisions: clipboard mode + GACS vs Cmd-placement. (4, and mod order — pending your answer)
1. TAP escape hatch, then cosmetic cleanups. (1, 8–10)
