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
.include "man/fight.h.s"
.include "man/player.h.s"
.include "man/oponent.h.s"
.include "man/deck.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA
_add_card_string: .asciz "ADD A CARD TO YOUR DECK"      ;;

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
man_fight_add_new_card::
    m_screenPtr_backbuffer 8, 10           ;; Calculates backbuffer address
    ld c, #64
    ld b, #180
    ld a, #0x33
    call sys_messages_draw_box

    ld hl, #_add_card_string
    m_screenPtr_backbuffer 18, 14                           ;; Calculates backbuffer address
    ld c, #0
    call sys_text_draw_string

    call sys_render_switch_buffers
    call sys_input_wait4anykey

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
    call man_fight_add_new_card

    call man_fight_update

    call man_fight_add_new_card
    
    call man_fight_init
    ret