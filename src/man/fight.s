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
.include "cpctelera.h.s"



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

hand_max:: .db 5
player_energy:: .db 0
player_max_energy:: .db 3

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

    call man_deck_load_array_from_deck ;; loads all the cards in deck in the pointer array

    ld ix, #hand                        ;; initialize hand
    call man_array_init                 ;;

    ld ix, #cemetery                    ;; initialize cemetery
    call man_array_init                 ;;

    ld ix, #sacrifice                   ;; initialize scrifice
    call man_array_init                 ;;

    ld b, #5
    call man_fight_deal_cards

    ld a, #player_max_energy            ;; Load the max of energy of this fight to the player energy
    ld (player_energy), a               ;;

    call man_foe_init
    call man_foe_create

    call sys_render_fight_screen    ;; renders the fight screen
    ret

;;-----------------------------------------------------------------
;;
;; man_fight_deal_cards 
;;
;;  Deals a new set of cards to the player
;;  Input: b: amount of cards to deal
;;  Output: 
;;  Modified: 
;;
man_fight_deal_cards::
    push ix
_initial_set_of_cards:
    push bc                             ;; store loop index
    ld ix, #fight_deck                  ;; working with fight_deck
    call man_array_get_random_element   ;; gen a random element form fight_deck
    ld (m_f_d_c_ELEMENT_TO_ERASE),a             ;; store the element to be erased later
    ld ix, #hand                        ;; working with hand
    call man_array_create_element       ;; create the element in hand
    ld ix, #fight_deck                  ;; working with fight_deck
m_f_d_c_ELEMENT_TO_ERASE = . +1                 
    ld a, #00                           ;; set the element to be erased
    call man_array_remove_element       ;; Remove element from fight_deck
    
    call sys_render_deck                ;; Update number in deck
    call sys_render_erase_hand          ;; erase hand
    call sys_render_hand                ;; update hand

    pop bc                              ;; restore loop index
    djnz _initial_set_of_cards
    
    pop ix
    ret


;;-----------------------------------------------------------------
;;
;; man_fight_shuffle 
;;
;;  Move the cards of the cemetery to the deck, and deal new cards to the player
;;  Input: b: amount of energy to decrease
;;  Output: 
;;  Modified: 
;;
man_fight_shuffle::
    
    ld hl, #cemetery                    ;; move them from the cemetery to the fight_deck
    ld de, #fight_deck                  ;; to the deck     
    call man_array_move_all_elements    ;;
    
    call sys_render_deck                ;; Update number in deck
    call sys_render_cemetery            ;; Update number in cemetery
    
    ld b, #hand_max                     ;; deal a new hand of cards to the player
    call man_fight_deal_cards           ;;

    ret

;;-----------------------------------------------------------------
;;
;; man_fight_decrease_energy
;;
;;  Decrease the energy of the player
;;  Input: b: amount of energy to decrease
;;  Output: 
;;  Modified: 
;;
man_fight_decrease_energy::
    
    ld a, (player_energy)
    sub b
    ld (player_energy), a
    call sys_render_energy                  ;;
    
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
    push ix
    ld ix, #hand
    ld a, a_selected(ix)
    call man_array_get_element      ;; Get pointer to the executed card
    inc hl                          ;; skip status byte

    ld a, (hl)                      ;;
    ld__ixl_a                       ;; ix points to the card
    inc hl                          ;;
    ld a, (hl)                      ;;
    ld__ixh_a                       ;;

    ld hl, #m_f_e_c_exit            ;; load return address in hl
    push hl                         ;; push return address to 
    ld l, c_execute_routine(ix)     ;;
    ld h, c_execute_routine+1(ix)   ;; retrieve function address    
    jp (hl)                         ;; jump to function
m_f_e_c_exit:

    ld b, c_energy(ix)                      ;; decrease energy
    call man_fight_decrease_energy          ;;

    ;; render oponent
    ld ix, #foes_array
    call sys_render_effects
    ;; render oponent
    ld ix, #player
    call sys_render_effects

    call man_deck_remove_card_from_hand
    
    ld ix, #hand                            ;; if hand is empty shuffle
    ld a, a_count(ix)                       ;; 
    call z, man_fight_shuffle               ;;
    
    pop ix
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
