/*
Copyright 2012,2013 Jun Wako <wakojun@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#include QMK_KEYBOARD_H

// ================== 自定义键声明（必须放在键位表之前） ==================
enum custom_keycodes {
    KC_RPTT = QK_KB_0,   // 循环宏 开/关：按一下开始循环，再按一下停止
    KC_RPTH = QK_KB_1,   // 循环宏 按住：按住循环，松开停止
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    // ========== 层 0（日常层）：按你的初始键位烘入 ==========
    [0] = LAYOUT(
        KC_DEL,         KC_PGUP,        KC_MPRV,        KC_NO,      KC_VOLD,

        LT(1,KC_NUM),   LT(2,KC_PSLS),  LT(3,KC_PAST),  LT(4,KC_PMNS),
        KC_RPTT,        KC_P8,          KC_P9,
        KC_P4,          KC_P5,          KC_P6,          KC_PPLS,
        KC_P1,          KC_P2,          KC_P3,          KC_PENT,
        KC_RPTH,                        KC_PDOT,

        KC_DEL,         KC_BSPC,        KC_PGUP,        KC_PGDN,
        KC_MPRV,        KC_MNXT,        KC_VOLD,        KC_VOLU
    ),
    [1] = LAYOUT(
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,    KC_TRNS,
        KC_TRNS,        KC_NUM,         MO(2),          KC_CALC,
        KC_TRNS,        KC_VOLU,        KC_TRNS,
        KC_MPRV,        KC_MPLY,        KC_MNXT,        KC_TRNS,
        KC_TRNS,        KC_VOLD,        KC_TRNS,        KC_TRNS,
        KC_MUTE,                        KC_TRNS,

        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS
    ),
    [2] = LAYOUT(
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,    KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        RGB_VAI,
        RGB_TOG,        RGB_SAI,        KC_TRNS,
        RGB_HUD,        EE_CLR,         RGB_HUI,        RGB_VAD,
        KC_TRNS,        RGB_SAD,        KC_TRNS,        KC_TRNS,
        RGB_MOD,                        KC_TRNS,

        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS
    ),
    [3] = LAYOUT(
        KC_RPTT,        KC_TRNS,        KC_TRNS,        KC_TRNS,    KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,
        NK_TOGG,                        KC_TRNS,

        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS
    )
};

bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    if (host_keyboard_led_state().num_lock) {
        RGB_MATRIX_INDICATOR_SET_COLOR(5, 255, 255, 255);
    }
    switch (get_highest_layer(layer_state)) {
        case 1: RGB_MATRIX_INDICATOR_SET_COLOR(16, 255, 255, 255); break;
        case 2: RGB_MATRIX_INDICATOR_SET_COLOR(17, 255, 255, 255); break;
        case 3: RGB_MATRIX_INDICATOR_SET_COLOR(18, 255, 255, 255); break;
        case 4: RGB_MATRIX_INDICATOR_SET_COLOR(13, 255, 255, 255); break;
        case 5: RGB_MATRIX_INDICATOR_SET_COLOR(14, 255, 255, 255); break;
        case 6: RGB_MATRIX_INDICATOR_SET_COLOR(15, 255, 255, 255); break;
        case 7: RGB_MATRIX_INDICATOR_SET_COLOR(9, 255, 255, 255); break;
    }
    return false;
}

// ================== 循环宏功能 ==================
// 宏序列：按下Alt → 79ms → 按下Ctrl → 56ms → 抬起Alt → 65ms → 抬起Ctrl → 775ms → 循环
static bool     rpt_on    = false;
static uint8_t  rpt_phase = 0;
static uint16_t rpt_timer = 0;

static void rpt_begin(void) {
    rpt_on    = true;
    rpt_phase = 1;
    register_code(KC_LALT);
    rpt_timer = timer_read();
}

static void rpt_stop(void) {
    rpt_on    = false;
    rpt_phase = 0;
    unregister_code(KC_LALT);
    unregister_code(KC_LCTL);
}

void matrix_scan_user(void) {
    if (rpt_phase == 0) return;
    switch (rpt_phase) {
        case 1:
            if (timer_elapsed(rpt_timer) >= 79) {
                register_code(KC_LCTL);
                rpt_timer = timer_read();
                rpt_phase = 2;
            }
            break;
        case 2:
            if (timer_elapsed(rpt_timer) >= 56) {
                unregister_code(KC_LALT);
                rpt_timer = timer_read();
                rpt_phase = 3;
            }
            break;
        case 3:
            if (timer_elapsed(rpt_timer) >= 65) {
                unregister_code(KC_LCTL);
                rpt_timer = timer_read();
                rpt_phase = 4;
            }
            break;
        case 4:
            if (timer_elapsed(rpt_timer) >= 575) {
                register_code(KC_LALT);
                rpt_timer = timer_read();
                rpt_phase = 1;
            }
            break;
    }
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case KC_RPTT:
            if (record->event.pressed) {
                if (rpt_on) rpt_stop(); else rpt_begin();
            }
            return false;
        case KC_RPTH:
            if (record->event.pressed) rpt_begin();
            else                       rpt_stop();
            return false;
        default:
            return true;
    }
}
