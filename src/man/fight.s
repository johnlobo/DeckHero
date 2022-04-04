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

.module fight_manager

.include "common.h.s"
.include "man/deck.h.s"
.include "man/array.h.s"
.include "man/player.h.s"
.include "man/foe.h.s"
.include "sys/input.h.s"
.include "sys/render.h.s"
.include "comp/component.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

fight_deck::
DefineComponentArrayStructure_Size fight_deck, MAX_DECK_CARDS, sizeof_e     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

hand::
DefineComponentArrayStructure_Size hand, MAX_HAND_CARDS, sizeof_e     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

cemetery::
DefineComponentArrayStructure_Size cemetery, MAX_DECK_CARDS, sizeof_e     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

sacrifice::
DefineComponentArrayStructure_Size sacrifice, MAX_DECK_CARDS, sizeof_e     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

player_energy:: .db 0

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_fight_init
;;
;;  Initializes a fight
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
man_fight_init::
    
    ld ix, #fight_deck                  ;; initialize fight_deck
    call man_array_init                 ;;

    call man_array_load_array_from_deck ;; loads all the cards in deck in the pointer array

    ld ix, #hand                        ;; initialize hand
    call man_array_init                 ;;

    ld ix, #cemetery                    ;; initialize cemetery
    call man_array_init                 ;;

    ld ix, #sacrifice                   ;; initialize scrifice
    call man_array_init                 ;;

    ld b, #5
_initial_set_of_cards:
    push bc                             ;; store loop index
    ld ix, #fight_deck                  ;; working with fight_deck
    call man_array_get_random_element   ;; gen a random element form fight_deck
    ld (ELEMENT_TO_ERASE),a             ;; store the element to be erased later
    ld ix, #hand                        ;; working with hand
    call man_array_create_element       ;; create the element in hand
    ld ix, #fight_deck                  ;; working with fight_deck
ELEMENT_TO_ERASE = . +1                 
    ld a, #00                           ;; set the element to be erased
    call man_array_remove_element       ;; Remove element from fight_deck
    pop bc                              ;; restore loop index
    djnz _initial_set_of_cards

    ld hl, #player_energy
    ld (hl), #3

    call man_foe_init
    call man_foe_create

    call sys_render_fight_screen    ;; renders the fight screen
    ret

;;-----------------------------------------------------------------
;;
;; man_fight_excute_card
;;
;;  Executes the selected card
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_fight_execute_card::
    ;;ld ix, #hand
    ;;ld a, a_selected(ix)
    ret


;;-----------------------------------------------------------------
;;
;; man_fight_update
;;
;;  Updates the state of a fight
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_fight_update::
      
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
