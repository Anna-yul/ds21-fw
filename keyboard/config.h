#define DYNAMIC_KEYMAP_LAYER_COUNT 8 //定义VIA层数

#ifdef ENCODER_ENABLE 
#define ENCODER_DIRECTION_FLIP
# define ENCODERS_PAD_A     { A1,A3,A5,A7 }
#define  ENCODERS_PAD_B     { A2,A4,A6,B0 }
#define ENCODER_RESOLUTIONS { 4,4,4,4 }/** 旋钮步进，QMK BUG 不要设置 ENCODER_RESOLUTION */
#define ENCODERS_MATRIX_MAP {{{0, 6}, {1, 6}},{{2, 6}, {3, 6}},{{0, 7}, {1, 7}},{{2, 7}, {3, 7}}}
// #   define ENCODERS_TYPE_EC11
#endif
