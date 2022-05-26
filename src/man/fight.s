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

.include "fight.h.s"
.include "common.h.s"
.include "man/deck.h.s"
.include "man/array.h.s"
.include "man/player.h.s"
.include "man/foe.h.s"
.include "man/oponent.h.s"
.include "sys/input.h.s"
.include "sys/render.h.s"
.include "comp/component.h.s"
.include "cpctelera.h.s"
.include "sys/messages.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

_fight_end_of_turn_string: .asciz " END OF TURN "      ;;
_fight_init_string: .asciz " START OF COMBAT "      ;;
_fight_end_string: .asciz " END OF COMBAT "      ;;
_fight_player_turn_string: .asciz " PLAYER TURN "      ;;
_fight_enemy_turn_string: .asciz " ENEMY TURN "      ;;


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
player_updates:: .db 0
ended_fight:: .db 0

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

    call sys_render_clear_front_buffer
    call sys_render_clear_back_buffer

    ld e, #10                           ;; x
    ld d, #78                           ;; y
    ld b, #44                           ;; h
    ld c, #60                           ;; w
    ld hl, #_fight_init_string          ;; message
    ld a, #2                            ;; don't wait for a key
    call sys_messages_show
    
    ld b, #200                          ;; delay 1 sec.
_mfi_delay:
    push bc
    call cpct_waitVSYNC_asm
    pop bc
    djnz _mfi_delay

    ld ix, #fight_deck                  ;; initialize fight_deck
    call man_array_init                 ;;

    call man_deck_load_array_from_deck  ;; loads all the cards in deck in the pointer array

    ld ix, #hand                        ;; initialize hand
    call man_array_init                 ;;

    ld ix, #cemetery                    ;; initialize cemetery
    call man_array_init                 ;;

    ld ix, #sacrifice                   ;; initialize scrifice
    call man_array_init                 ;;

    ld a, (player_max_energy)           ;; Load the max of energy of this fight to the player energy
    ld (player_energy), a               ;;

    call man_foe_init
    call man_foe_create

    call sys_render_full_fight_screen   ;; renders the fight screen
    call sys_render_switch_buffers
    ;call sys_render_switch_crtc_start
    call sys_render_full_fight_screen   ;; renders the fight screen

    ld a, (hand_max)
    ld b, a
    call man_fight_deal_hand

    xor a                               ;; Set the end of fight flag 
    ld (ended_fight), a                 ;;

    ret


;;-----------------------------------------------------------------
;;
;; man_fight_deal_hand 
;;
;;  Deals a new set of cards to the player
;;  Input: b: amount of cards to deal
;;  Output: 
;;  Modified: 
;;
man_fight_deal_hand::
    push ix
    ld ix, #hand
    xor a                               ;; Selected card=0
    ld a_selected(ix), a                ;;

_initial_set_of_cards:
    push bc                             ;; store loop index

    ;;ld b, #20                         ;; delay 
    ;;call cpct_waitHalts_asm

;;    ld a, (hand_count)                  ;; still cards in hand??
;;    or a                                ;;
;;    jr nz, _mfdl_cards_in_hand          ;;
;;
;;    
;;    
;;    jr _mfdl_continue
;;_mfdl_cards_in_hand:
;;    ;;call nz, sys_render_erase_current_hand      ;; erase hand if there are any cards in hand
;;_mfdl_continue:
    
    ld a, (fight_deck_count)            ;; check if there are cards in the fight deck
    or a                                ;;
    jr nz, _mfdc_get_card               ;; if so jump to get one

    call man_fight_shuffle              ;; otherwise dump cemetery in the fight deck

_mfdc_get_card:
    ld ix, #fight_deck                  ;; working with fight_deck
    call man_array_get_random_element   ;; gen a random element form fight_deck
    ld (mfdc_ELEMENT_TO_ERASE),a        ;; store the element to be erased later
    ld ix, #hand                        ;; working with hand
    call man_array_create_element       ;; create the element in hand
    inc a_delta(ix)                     ;; increase delta flag
    ld ix, #fight_deck                  ;; working with fight_deck
mfdc_ELEMENT_TO_ERASE = . +1                 
    ld a, #00                           ;; set the element to be erased
    call man_array_remove_element       ;; Remove element from fight_deck
    
    ;;call sys_render_deck                ;; Update number in deck
    ;;call sys_render_hand                ;; update hand

    m_updated_hand
    m_updated_icon_numbers

    call sys_render_update_fight

    pop bc                              ;; restore loop index
    djnz _initial_set_of_cards
    
    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_fight_discard_hand 
;;
;;  Discards the cards that are still in hand
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_fight_discard_hand::
    push ix
    
    ld a, (hand_count)                    ;; return if no cards in hand
    or a
    ret z
_m_f_d_h_loop:

    ;;ld b, #20                           ;; delay 
    ;;call cpct_waitHalts_asm
    ld ix, #hand
    ld a, #00                           ;; set the element to be erased
    call man_array_get_element          ;; get the first element of the hand
    ld ix, #cemetery
    call man_array_create_element       ;; create the element in hand
    ld ix, #hand
    ld a, #00                           ;; set the element to be erased
    call man_array_remove_element       ;; Remove element from fight_deck  
    dec a_delta(ix)                     ;; decreases delta flag
    ;;call sys_render_cemetery            ;; Update number in deck
    ;;call sys_render_hand                ;; update hand

    m_updated_hand
    m_updated_icon_numbers

    call sys_render_update_fight
    
    ld a, (hand_count)
    or a
    jr nz, _m_f_d_h_loop
    
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
    ld a, (cemetery_count)                ;; if no cards in cemetery return
    or a
    ret z

    ld hl, #cemetery                    ;; move them from the cemetery to the fight_deck
    ld de, #fight_deck                  ;; to the deck     
    ;;call man_array_move_all_elements    ;;

    ld (_mfs_FIRST_ARRAY), hl
    ld (_mfs_THIRD_ARRAY), hl
    ex de, hl
    ld (_mfs_SECOND_ARRAY), hl
_mfs_move_loop:
_mfs_FIRST_ARRAY = .+2
    ld ix, #0000
    xor a
    call man_array_get_element

_mfs_SECOND_ARRAY = .+2
    ld ix, #0000
    call man_array_create_element

_mfs_THIRD_ARRAY = .+2    
    ld ix, #0000
    xor a
    call man_array_remove_element

    m_updated_hand
    m_updated_icon_numbers

    call sys_render_update_fight
    
    ld a, a_count(ix)
    or a
    jr nz, _mfs_move_loop
    
    ;;call sys_render_deck                ;; Update number in deck
    ;;call sys_render_cemetery            ;; Update number in cemetery
    
    ;;ld a, (hand_max)
    ;;ld b, a                             ;; deal a new hand of cards to the player
    ;;call man_fight_deal_hand            ;;

    ;;pop ix 
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
    m_updated_icon_numbers
    ;;call sys_render_energy                  ;;
    
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
    ;;ld ix, #foes_array
    ;;call sys_render_effects
    m_updated_foe_effects
    ;; render oponent
    ;;ld ix, #player
    ;;call sys_render_effects
    m_updated_player_effects

    call man_deck_remove_card_from_hand
    
    ld ix, #hand                            ;; if hand is empty shuffle
    ld a, a_count(ix)                       ;; 
    or a                                    ;; check if there are no cards in hand
    call z, man_fight_shuffle               ;;

    m_updated_hand                  ;; marks that the hand has been updated
    
    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_fight_enemy_turn
;;
;;  Updates the state of a fight
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_fight_enemy_turn::

    ret


;;-----------------------------------------------------------------
;;
;; man_fight_end_of_turn
;;
;;  Updates the state of a fight
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_fight_end_of_turn::
    ld e, #10                           ;; x
    ld d, #78                           ;; y
    ld b, #44                           ;; h
    ld c, #60                           ;; w
    ld hl, #_fight_end_of_turn_string   ;; message
    ld a,#1                             ;; wait for a key
    call sys_messages_show

    call man_fight_discard_hand
    
    m_updated_icon_numbers

    call sys_render_update_fight

    ld b, #100                           ;; delay 
    call cpct_waitHalts_asm

    push ix
    ld ix, #foes_array
    inc o_behaviour_step(ix)
    pop ix

    ld a, (hand_max)
    ld b, a
    call man_fight_deal_hand
    m_updated_hand

    ld a, #3
    ld (player_energy), a
    m_updated_icon_numbers

    call sys_render_update_fight
    ;;call sys_render_energy              ;;

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

_update_main_loop:
    ;; Player turn
    ld e, #10                           ;; x
    ld d, #78                           ;; y
    ld b, #44                           ;; h
    ld c, #60                           ;; w
    ld hl, #_fight_player_turn_string   ;; message
    ld a,#2                             ;; wait for a key
    call sys_messages_show              ;; End of fight message

_mfu_player_loop:

    call sys_input_debug_update         ;; Check players actions
    
    ;;ld b, #40                           ;; delay
    ;;call cpct_waitHalts_asm             ;;

    call sys_render_update_fight        ;; renders the screen

    ld ix, #player                      ;; Check players life
    call man_oponent_get_life           ;;
    or a                                ;;
    jr z, _update_end_of_fight          ;;
    jp m, _update_end_of_fight          ;;

    call man_foe_number_of_foes         ;; Check if thera are enemies left
    or a                                ;;
    jr z, _update_end_of_fight          ;;

    ld a, (player_energy)               ;; Check player's energy
    or a                                ;;
    jr nz, _mfu_player_loop

    ;; Enemy turn
    ld e, #10                           ;; x
    ld d, #78                           ;; y
    ld b, #44                           ;; h
    ld c, #60                           ;; w
    ld hl, #_fight_enemy_turn_string   ;; message
    ld a,#2                             ;; wait for a key
    call sys_messages_show              ;; End of fight message

    call man_fight_enemy_turn
    
    ;; End of turn
    call man_fight_end_of_turn          ;;

    jr _update_main_loop

_update_end_of_fight:
    ld e, #10                           ;; x
    ld d, #78                           ;; y
    ld b, #44                           ;; h
    ld c, #60                           ;; w
    ld hl, #_fight_end_string           ;; message
    ld a,#1                             ;; wait for a key
    call sys_messages_show              ;; End of fight message
    

;; Turn structure
;; 1) Show foes intentions
;; 2) hero play cards
;; 3) Foes execute intention
;; 4) Upate effects
;; 5) Check end of combat
;;
    ret
