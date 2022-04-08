;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2018 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU Lesser General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU Lesser General Public License for more details.
;;
;;  You should have received a copy of the GNU Lesser General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------

.module main


;;===============================================================================
;; SPRITES
;;===============================================================================
.globl _g_palette0
.globl _g_palette1
.globl _s_font_0
.globl _s_font_1
.globl _s_cards_0
.globl _s_cards_1
.globl _s_cards_2
.globl _s_cards_3
.globl _s_cards_4
.globl _s_cards_energy_0
.globl _s_cards_energy_1
.globl _s_cards_energy_2
.globl _s_cards_energy_3
.globl _s_cards_energy_4
.globl _s_cards_energy_5
.globl _s_player_0
.globl _s_player_1
.globl _s_blob_0
.globl _s_blob_1
.globl _s_small_icons_00
.globl _s_small_icons_01
.globl _s_small_icons_02
.globl _s_small_icons_03
.globl _s_small_icons_04
.globl _s_small_icons_05
.globl _s_small_icons_06
.globl _s_small_icons_07
.globl _s_small_icons_08
.globl _s_small_icons_09
.globl _s_coin
.globl _s_small_numbers_00
.globl _s_small_numbers_01
.globl _s_small_numbers_02
.globl _s_small_numbers_03
.globl _s_small_numbers_04
.globl _s_small_numbers_05
.globl _s_small_numbers_06
.globl _s_small_numbers_07
.globl _s_small_numbers_08
.globl _s_small_numbers_09
.globl _s_icons_0
.globl _s_icons_1
.globl _s_icons_2
.globl _s_icons_3
.globl _s_status_0
.globl _s_status_1
.globl _s_explotion_0
.globl _s_explotion_1
.globl _s_explotion_2
.globl _s_explotion_3

;;===============================================================================
;; PUBLIC VARIBLES
;;===============================================================================
.globl player


;;===============================================================================
;; CPCTELERA FUNCTIONS
;;===============================================================================
.globl cpct_disableFirmware_asm
.globl cpct_getScreenPtr_asm
.globl cpct_drawSprite_asm
.globl cpct_setVideoMode_asm
.globl cpct_setPalette_asm
.globl cpct_scanKeyboard_if_asm
.globl cpct_isKeyPressed_asm
.globl cpct_waitHalts_asm
.globl cpct_drawSolidBox_asm
.globl cpct_setSeed_xsp40_u8_asm
.globl cpct_isAnyKeyPressed_asm
.globl cpct_setInterruptHandler_asm
.globl cpct_waitVSYNC_asm
.globl _cpct_keyboardStatusBuffer
.globl cpct_getRandom_mxor_u8_asm
.globl cpct_drawSpriteBlended_asm
.globl cpct_px2byteM0_asm
.globl cpct_getScreenToSprite_asm

;;===============================================================================
;; DEFINED CONSTANTS
;;===============================================================================

;;tipos de cartas
e_type_invalid              = 0x00
e_type_card_in_hand         = 0x01
e_type_card_in_cemetery     = 0x02
e_type_card_in_sacrifice    = 0x04

;;tipos de componentes
e_cmp_render = 0x01     ;;entidad renderizable
e_cmp_movable = 0x02    ;;entidad que se puede mover
e_cmp_input = 0x04      ;;entidad controlable por input  
e_cmp_ia = 0x08         ;;entidad controlable con ia
e_cmp_animated = 0x10   ;;entidad animada
e_cmp_collider = 0x20   ;;entidad que puede colisionar
e_cmp_default = e_cmp_render | e_cmp_movable | e_cmp_collider  ;;componente por defecto

;; Keyboard constants
BUFFER_SIZE = 10
ZERO_KEYS_ACTIVATED = #0xFF

;; Score constants
SCORE_NUM_BYTES = 4

;; Sprites sizes
S_CARD_WIDTH = 8
S_CARD_HEIGHT = 41
S_CARD_ENERGY_WIDTH = 3
S_CARD_ENERGY_HEIGHT = 8
S_PLAYER_WIDTH = 8
S_PLAYER_HEIGHT = 40
S_BLOB_WIDTH = 16
S_BLOB_HEIGHT = 25

S_SMALL_ICONS_WIDTH = 4
S_SMALL_ICONS_HEIGHT = 10
S_SMALL_ICONS_SIZE = S_SMALL_ICONS_WIDTH * S_SMALL_ICONS_HEIGHT

S_COIN_WIDTH = 4
S_COIN_HEIGHT = 10
S_SMALL_NUMBERS_WIDTH = 2
S_SMALL_NUMBERS_HEIGHT = 5
S_ICONS_WIDTH = 6
S_ICONS_HEIGHT = 17
S_STATUS_WIDTH = 5
S_STATUS_HEIGHT = 12

;; GAME CONSTANTS
MAX_FOES = 4

;; Font constants
FONT_WIDTH = 2
FONT_HEIGHT = 9

;; DECK CONSTANTS
CARD_SIZE = 22
MAX_HAND_CARDS = 10
MAX_DECK_CARDS = 30
MAX_MODEL_CARD = 4

;; MAIN SCREEN
PLAYER_SPRITE_X = 20
PLAYER_SPRITE_Y = 60
PLAYER_SPRITE_WIDTH = 8
PLAYER_SPRITE_HEIGHT = 40

PLAYER_STATUS_X = 21
PLAYER_STATUS_Y = 102
PLAYER_STATUS_NUMBER_Y = 104



;; Deck Position
DECK_X = 7
DECK_Y = 25
DESC_SHOW_X = 7
DESC_SHOW_Y_1 = 160
DESC_SHOW_Y_2 = 170

HAND_X = 0
HAND_Y = 130

DESC_X = 1
DESC_Y_1 = 180
DESC_Y_2 = 190


;;===============================================================================
;; DEFINED MACROS
;;===============================================================================
.mdelete BeginStruct
.macro BeginStruct struct
    struct'_offset = 0
.endm

.mdelete Field
.macro Field struct, field, size
    struct'_'field = struct'_offset
    struct'_offset = struct'_offset + size
.endm

.mdelete EndStruct
.macro EndStruct struct
    sizeof_'struct = struct'_offset
.endm

