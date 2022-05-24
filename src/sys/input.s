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

.module input_system

.include "cpctelera.h.s"
.include "../common.h.s"
.include "man/game.h.s"
.include "sys/util.h.s"
.include "sys/render.h.s"
.include "man/fight.h.s"
.include "man/deck.h.s"
.include "man/array.h.s"
.include "comp/component.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA



sys_input_debug_key_actions::
    .dw Key_O,      sys_input_selected_left
    .dw Key_P,      sys_input_selected_right
    .dw Key_Q,      sys_input_add_card
    .dw Key_A,      sys_input_remove_card
    .dw Key_D,      sys_input_show_deck
    .dw Key_Space,  sys_input_action
    ;;.dw Key_Esc,    _score_cancel_entry
    ;;.dw Joy0_Left,  _score_move_left
    ;;.dw Joy0_Right, _score_move_right
    ;;.dw Joy0_Up,    _score_move_up
    ;;.dw Joy0_Down,  _score_move_down
    ;;.dw Joy0_Fire1, _score_fire
    .dw 0

;;
;; Start of _CODE area
;; 
.area _CODE


;;-----------------------------------------------------------------
;;
;; sys_input_clean_buffer
;;
;;  Waits until de key buffer is clean
;;  Input: 
;;  Output:
;;  Modified: 
;;
sys_input_clean_buffer::
    call cpct_isAnyKeyPressed_asm
    jr nz, sys_input_clean_buffer
    ret

;;-----------------------------------------------------------------
;;
;; sys_input_wait4anykey
;;
;;   Reads input and wait for any key press
;;  Input: 
;;  Output:
;;  Modified: 
;;
sys_input_wait4anykey::
    call cpct_isAnyKeyPressed_asm
    or a
    jr z, sys_input_wait4anykey
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DESCRIPTION
;; Gets the ID of the FIRST key pressed found on the key
;; buffer
;; ----------------------------------------------------
;; PARAMS
;; ----------------------------------------------------
;; RETURNS
;; HL: Key pressed if anyone pressed. If not returns 0
;; ----------------------------------------------------
;; DESTROYS
;; AF, HL
;; ----------------------------------------------------
;;
;; Routine taken from Promotion from Bite Studios
;;
sys_input_getKeyPressed::
    ld hl, #_cpct_keyboardStatusBuffer
    xor a                           ;; A = 0

_kp_loop:
    cp #BUFFER_SIZE
    jr z, _kp_endLoop               ;; Check counter value. End if its 0
    ld (_size_counter), a

    ld a, (hl)                      ;; Load byte from the buffer
    xor #ZERO_KEYS_ACTIVATED        ;; Inverts bytes
    jr z, _no_key_detected
        ld h, a                     ;; H is the mask
        ld a, (_size_counter)
        ld l, a                     ;; L is the offset
        ; ld (_current_key_pressed), hl
        ret
_no_key_detected:
    inc hl
_size_counter = .+1
    ld a, #0x00                     ;; AUTOMODIFIABLE, A = counter
    inc a
    jr _kp_loop
_kp_endLoop:
    ld hl, #0x00                    ;; Return 0 if no key is pressed
    ld a, #0
    ld (_key_released), a
    ret

_key_released:
    .db #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DESCRIPTION
;; Does not return the key pressed until one is pressed.
;; WARNING: This blocks the execution until done
;; ----------------------------------------------------
;; PARAMS
;; ----------------------------------------------------
;; RETURNS
;; HL: Key pressed
;; ----------------------------------------------------
;; DESTROYS
;; AF, HL
;; ----------------------------------------------------
;;
;; Routine taken from Promotion from Bite Studios
;;
sys_input_waitKeyPressed::
    call sys_input_getKeyPressed
    ld a, (_key_released)
    or a
    jr nz, sys_input_waitKeyPressed
    xor a
    or h
    or l
    jr z, sys_input_waitKeyPressed
    ld a, #1
    ld (_key_released), a
    ret


;;-----------------------------------------------------------------
;;
;; sys_input_init
;;
;;   Initializes input
;;  Input: 
;;  Output:
;;  Modified: 
;;
sys_input_init::
    ret 

;;-----------------------------------------------------------------
;;
;;  sys_input_action
;;
;;  Shows deck on scree
;;  Output:
;;  Modified: 
;;
sys_input_action:
    call man_fight_execute_card
    ret

;;-----------------------------------------------------------------
;;
;;  sys_input_show_deck
;;
;;  Shows deck on scree
;;  Output:
;;  Modified: 
;;
sys_input_show_deck:
    ld ix, #fight_deck
    call sys_render_show_array

    call sys_input_wait4anykey
    
    call sys_render_clear_front_buffer
    
    call sys_render_full_fight_screen
    ret

;;-----------------------------------------------------------------
;;
;;  sys_input_add_card
;;
;;  Add card to deck
;;  Output:
;;  Modified: iy, bc
;;
sys_input_add_card::
    ld ix, #hand
    ld a, a_count(ix)                   ;; Check if we already have 10 cards in the deck
    cp #10                              ;;
    ret z                               ;; if 10 return

    call cpct_waitVSYNC_asm
    call sys_render_erase_current_hand          ;; erase deck area

    ld ix, #fight_deck
    call man_array_get_random_element   ;; get hl pointing to a random card, and a to the element in the array
    push af
    ld ix, #hand
    call man_array_create_element       ;; create a card in the deck
    inc a_delta(ix)                     ;; increase delta flag
    pop af
    ld ix, #fight_deck
    call man_array_remove_element       ;; erase card form hand
    
    call sys_render_deck                ;; Update number in deck
    
    call sys_render_hand                ;; update hand

    ld ix, #fight_deck
    ld a, a_count(ix)                   ;; Check if we have any card left in the deck
    or a
    ret nz                              ;; return if we have more cards in the deck
    
    ld hl, #cemetery                    ;; if no more cards in the deck, move them from the cemetery
    ld de, #fight_deck                  ;; to the deck     
    call man_array_move_all_elements    ;;

    call sys_render_deck                ;; Update number in deck
    call sys_render_cemetery            ;; Update number in cemetery

    ret

;;-----------------------------------------------------------------
;;
;;  sys_input_remove_card
;;
;;  Remove card from deck
;;  Input: a: number of card to remove
;;  Output:
;;  Modified: iy, bc
;;
sys_input_remove_card::
    ld ix, #hand
    ld a, a_count(ix)               ;; Check if we dont have any card in the deck
    or a                            ;;
    ret z                           ;; if 0 return

    call cpct_waitVSYNC_asm
    call sys_render_erase_current_hand      ;; erase deck area
    ;;ld a, (hand_selected)
    ld a, a_selected(ix)
    push af                         ;; save a (card to move)
    call man_array_get_element      ;; obtain content of a
    ld ix, #cemetery                ;; operate on cemetery
    call man_array_create_element   ;; create card in cemetery
    pop af                          ;; retrieve card to erase
    ld ix, #hand
    call man_array_remove_element   ;; erase card from hand
    dec a_delta(ix)                 ;; decrease delta flag
    call sys_render_deck
    call sys_render_cemetery
    call sys_render_hand            ;; update hand
    ret

;;-----------------------------------------------------------------
;;
;;  sys_input_selected_left
;;
;;  move selected card to the left
;;  Output:
;;  Modified: AF, HL, IX
;;
sys_input_selected_left::
    ld ix, #hand
    ;;ld a, (hand_selected)
    ld a, a_selected(ix)
    or a
    ret z

    ;;call cpct_waitVSYNC_asm
    ;;call sys_render_erase_current_hand      ;; erase deck area
    ;;ld hl, #hand_selected
    dec a_selected(ix)              ;; decrement selected card
    ;;call sys_render_hand
   
    m_updated_hand                  ;; marks that the hand has been updated
    
    ret

;;-----------------------------------------------------------------
;;
;;  sys_input_selected_right
;;
;;  move selected card to the right
;;  Output:
;;  Modified: 
;;
sys_input_selected_right::
    ld ix, #hand
    ld b, a_count(ix)
    ld a, a_selected(ix)
    inc a
    cp b
    ret z

    ;;call cpct_waitVSYNC_asm
    ;;call sys_render_erase_current_hand      ;; erase deck area
    inc a_selected(ix)              ;; increment selected card
    ;;call sys_render_hand
    
    m_updated_hand                  ;; marks that the hand has been updated

    ret

;;-----------------------------------------------------------------
;;
;;  sys_input_generic_update
;;
;;  Initializes input
;;  Input:  iy: array of key, actions to check
;;          ix: pointer to the strcut to be used in the actions
;;  Output:
;;  Modified: iy, bc
;;
sys_input_generic_update:
    jr first_key
keys_loop:
    ld bc, #4
    add iy, bc
first_key:
    ld l, 0(iy)                     ;; Lower part of the key pointer
    ld h, 1(iy)                     ;; Lower part of the key pointer
    ;; Check if key is null
    ld a, l
    or h
    ret z                           ;; Return if key is null
    ;; Check if key is pressed
    call cpct_isKeyPressed_asm      ;;
    jr z, keys_loop
    ;; Key pressed execute action
    ld hl, #keys_loop               ;;
    push hl                         ;; return addres from executed function
    ld l, 2(iy)                     ;;
    ld h, 3(iy)                     ;; retrieve function address    
    jp (hl)                         ;; jump to function



;;-----------------------------------------------------------------
;;
;; sys_input_score_entry_update
;;
;;   Initializes input
;;  Input: 
;;  Output:
;;  Modified: iy, bc
;;
sys_input_debug_update::
	;;call cpct_scanKeyboard_if_asm
    ;;ld ix, #score_marker                     ;; get player1 struct
    ld iy, #sys_input_debug_key_actions
    call sys_input_generic_update
    ret




