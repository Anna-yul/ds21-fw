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


// Each layer gets a name for readability, which is then used in the keymap matrix below.
// The underscores don't mean anything - you can have a layer called STUFF or any other name.
// Layer names don't all need to be of the same length, obviously, and you can also skip them
// entirely and just use numbers.

// enum custom_keycodes {
//   QWERTY = SAFE_RANGE,
//   LOWER,
//   RAISE
// };

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT(
        //1      2        3        4        5        6        7        8        9        10       11       12       13       14       15       16       17       18       19       20       21

        KC_ESC,        KC_CALC,        KC_MPLY,         KC_BSPC,    KC_MUTE, 

        LT(1,KC_NUM),   LT(2,KC_PSLS),  LT(3,KC_PAST),  LT(4,KC_PMNS), 
        KC_P7,          KC_P8,          KC_P9,          
        KC_P4,          KC_P5,          KC_P6,          KC_PPLS,
        KC_P1,          KC_P2,          KC_P3,          KC_PENT,
        KC_P0,                          KC_PDOT,

        KC_DEL,         KC_BSPC,        KC_PGUP,        KC_PGDN,             
        KC_MPRV,        KC_MNXT,        KC_VOLD,        KC_VOLU   
    ),
    [1] = LAYOUT(
        //1      2        3        4        5        6        7        8        9        10       11       12       13       14       15       16       17       18       19       20       21
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
        //1      2        3        4        5        6        7        8        9        10       11       12       13       14       15       16       17       18       19       20       21
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
        //1      2        3        4        5        6        7        8        9        10       11       12       13       14       15       16       17       18       19       20       21
        KC_TRNS,        KC_TRNS,        KC_TRNS,        KC_TRNS,    KC_RPTT,
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
    // caps lock cyan

    // num lock cyan
    if (host_keyboard_led_state().num_lock) {
        RGB_MATRIX_INDICATOR_SET_COLOR(5, 255, 255, 255);
    } 



    // layer state
    switch (get_highest_layer(layer_state)) {
        case 1:
            RGB_MATRIX_INDICATOR_SET_COLOR(16, 255, 255, 255);
            break;
        case 2:
            RGB_MATRIX_INDICATOR_SET_COLOR(17, 255, 255, 255);
            break;
        case 3:
            RGB_MATRIX_INDICATOR_SET_COLOR(18, 255, 255, 255);
            break;
        case 4:
            RGB_MATRIX_INDICATOR_SET_COLOR(13, 255, 255, 255);
            break;
        case 5:
            RGB_MATRIX_INDICATOR_SET_COLOR(14, 255, 255, 255);
            break;
        case 6:
            RGB_MATRIX_INDICATOR_SET_COLOR(15, 255, 255, 255);
            break;
        case 7:
            RGB_MATRIX_INDICATOR_SET_COLOR(9, 255, 255, 255);
            break;

    }
    return false;
}
// ================== 循环宏功能 ==================
// KC_RPTT：按一下开始循环，再按一下停止（开关式）
// KC_RPTH：按住循环，松开停止（按住式）
enum custom_keycodes {
    KC_RPTT = QK_KB_0,
    KC_RPTH = QK_KB_1,
};

static bool     rpt_on    = false;
static uint8_t  rpt_phase = 0;      // 0=停止，1~4=宏的第几步
static uint16_t rpt_timer = 0;

static void rpt_begin(void) {
    rpt_on    = true;
    rpt_phase = 1;
    register_code(KC_LALT);         // 第1步：按下 Alt
    rpt_timer = timer_read();
}

static void rpt_stop(void) {
    rpt_on    = false;
    rpt_phase = 0;
    unregister_code(KC_LALT);       // 保险：全部松开，防止卡键
    unregister_code(KC_LCTL);
}

void matrix_scan_user(void) {
    if (rpt_phase == 0) return;
    switch (rpt_phase) {
        case 1:
            if (timer_elapsed(rpt_timer) >= 79) {   // Alt 按下79ms后
                register_code(KC_LCTL);             // 第2步：按下 Ctrl
                rpt_timer = timer_read();
                rpt_phase = 2;
            }
            break;
        case 2:
            if (timer_elapsed(rpt_timer) >= 56) {   // 56ms后
                unregister_code(KC_LALT);           // 第3步：抬起 Alt
                rpt_timer = timer_read();
                rpt_phase = 3;
            }
            break;
        case 3:
            if (timer_elapsed(rpt_timer) >= 65) {   // 65ms后
                unregister_code(KC_LCTL);           // 第4步：抬起 Ctrl
                rpt_timer = timer_read();
                rpt_phase = 4;
            }
            break;
        case 4:
            if (timer_elapsed(rpt_timer) >= 775) {  // 775ms后从头再来
                register_code(KC_LALT);
                rpt_timer = timer_read();
                rpt_phase = 1;
            }
            break;
    }
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case KC_RPTT:                            // 开关式
            if (record->event.pressed) {
                if (rpt_on) rpt_stop(); else rpt_begin();
            }
            return false;
        case KC_RPTH:                            // 按住式
            if (record->event.pressed) rpt_begin();
            else                       rpt_stop();
            return false;
        default:
            return true;
    }
}
