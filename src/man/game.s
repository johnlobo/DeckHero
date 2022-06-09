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

.module game_manager
.include "common.h.s"
.include "sys/render.h.s"
.include "sys/behaviour.h.s"
.include "sys/messages.h.s"
.include "sys/text.h.s"
.include "sys/input.h.s"
.include "sys/util.h.s"
.include "man/fight.h.s"
.include "man/player.h.s"
.include "man/oponent.h.s"
.include "man/deck.h.s"
.include "man/array.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA
_add_card_string: .asciz "ADD A CARD TO YOUR DECK"      ;;
card01: .dw #0000
card02: .dw #0000
card03: .dw #0000

add_card_max:: .db #03
add_card_action:: .db #00
add_card_selected:: .db #00
add_card_previous:: .db #00

blob_template::
DefineOponent 1, ^/BLOB           /, _s_blob_0, 60, 60, S_BLOB_WIDTH, S_BLOB_HEIGHT, 20, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0

foe::
DefineOponent 1, ^/FOE   1        /, _s_blob_0, 60, 60, S_BLOB_WIDTH, S_BLOB_HEIGHT, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_game_init
;;
;;  
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_init::
    call man_player_init    ;; Initialize player
    call man_deck_init      ;; Initialize deck
    call man_fight_init     ;; Initialize fight
    ret

;;-----------------------------------------------------------------
;;
;; man_fight_add_new_card
;;
;;   
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_add_new_card::
    m_screenPtr_backbuffer 8, 10           ;; Calculates backbuffer address
    ld c, #64
    ld b, #180
    ld a, #0x33
    call sys_messages_draw_box

    ld hl, #_add_card_string
    m_screenPtr_backbuffer 18, 14                           ;; Calculates backbuffer address
    ld c, #0
    call sys_text_draw_string

    ld a, (add_card_max)                ;; check if max card is 0
    or a                                ;;
    ret z                               ;;



    ld b, #0
mganc_render_loop:
    push bc
    ld ix, #model_deck
    ld a, #2
    call man_array_get_random_element
    push hl
    pop ix
    pop bc                              ;; retrieve index
    push bc                             ;; re-store index

    ld c, #0x14                         ;; initial hor coord
    ld e, #0x10                         ;; offset between cards
    ld h, b
    call sys_util_h_times_e             ;; multiply idex by offset
    ld a, c                             ;; 
    add l                               ;; add offset 
    ld c, a
    ld b, #0x20                         ;; y coord
    call sys_render_card                ;; render card
    
    pop bc                              ;; retrieve main loop index
    inc b                               ;; inc index
    ld a, (add_card_max)                ;;
    cp b                                ;; Compare with max card
    jr nz, mganc_render_loop            ;; loop if not reached
    
    
    call sys_render_switch_buffers
    xor a
    ld (add_card_action), a
    ld (add_card_selected), a
    ld (add_card_previous), a
ac_input_loop:
    call sys_input_add_card_update          ;; Check players actions
    ld a, (add_card_action)                 ;; read action from input
    cp #255                                  ;; check if esc has been clicked
    jr z, ac_cancel                         ;;
    cp #1                                    ;; check if space has been clicked
    jr z, ac_action                         ;;
    jr ac_input_loop                        ;; No action -> loop
ac_action:
ac_cancel:
    call sys_render_switch_buffers
    call sys_render_full_fight_screen   ;; renders the fight screen

    ret

;;-----------------------------------------------------------------
;;
;; man_game_update
;;
;;   
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_update::
    call man_game_add_new_card

    call man_fight_update

    call man_game_add_new_card
    
    call man_fight_init
    ret