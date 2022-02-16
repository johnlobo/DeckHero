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
.include "man/deck.h.s"
.include "sys/input.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_game_init
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_game_init::
    call man_deck_init              ;; Initialize deck
    
    ;;ld hl, #model_deck_01           ;; load in hl the first card of the model deck
    ;;call man_deck_create_card       ;; create a card in the deck
    ;;ld hl, #model_deck_02           ;; load in hl the first card of the model deck
    ;;call man_deck_create_card       ;; create a card in the deck
    ;;ld hl, #model_deck_01           ;; load in hl the first card of the model deck
    ;;call man_deck_create_card       ;; create a card in the deck

    call man_deck_get_random_card   ;; get hl pointing to a random card
    call man_deck_create_card       ;; create a card in the deck
    call man_deck_get_random_card   ;; get hl pointing to a random card
    call man_deck_create_card       ;; create a card in the deck
    call man_deck_get_random_card   ;; get hl pointing to a random card
    call man_deck_create_card       ;; create a card in the deck

    call sys_render_deck            ;; render the deck

    ret

;;-----------------------------------------------------------------
;;
;; man_game_update
;;
;;   gets a random number between 0 and 18
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
man_game_update::

    call sys_input_debug_update
    ld b, #20
    call cpct_waitHalts_asm
;;
;; Turn structure
;; 1) Show foes intentions
;; 2) hero play cards
;; 3) Foes execute intention
;; 4) Upate effects
;; 5) Check end of combat
;;
    ret