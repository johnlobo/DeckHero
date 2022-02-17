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
;;.include "man/entity.h.s"
.include "man/game.h.s"
.include "sys/util.h.s"
.include "sys/render.h.s"
;;.include "sys/score.h.s"
.include "man/deck.h.s"
.include "man/hand.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

;;sys_input_key_actions::
;;    .dw Key_O,      _move_left
;;    .dw Key_P,      _move_right
;;    .dw Key_Q,      _move_up
;;    .dw Key_A,      _move_down
;;    .dw Key_Space,  _set_piece
;;    .dw Key_I,      _change_piece
;;    .dw Key_Esc,    _cancel_game
;;    .dw Joy0_Left,  _move_left
;;    .dw Joy0_Right, _move_right
;;    .dw Joy0_Up,    _move_up
;;    .dw Joy0_Down,  _move_down
;;    .dw Joy0_Fire1, _set_piece
;;    .dw Joy0_Fire2, _change_piece
;;    .dw 0

;;sys_input_score_key_actions::
;;    .dw Key_O,      _score_move_left
;;    .dw Key_P,      _score_move_right
;;    .dw Key_Q,      _score_move_up
;;    .dw Key_A,      _score_move_down
;;    .dw Key_Space,  _score_fire
;;    .dw Key_Esc,    _score_cancel_entry
;;    .dw Joy0_Left,  _score_move_left
;;    .dw Joy0_Right, _score_move_right
;;    .dw Joy0_Up,    _score_move_up
;;    .dw Joy0_Down,  _score_move_down
;;    .dw Joy0_Fire1, _score_fire
;;    .dw 0

sys_input_debug_key_actions::
    .dw Key_O,      _selected_left
    .dw Key_P,      _selected_right
    .dw Key_Q,      _add_card
    .dw Key_A,      _remove_card
    ;;.dw Key_Space,  _score_fire
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

_key_released::
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
;; _score_move_down
;;
;;  Process fire key press
;;  Input: 
;;  Output:
;;  Modified: 
;;
;;_score_move_down:
;;    ld a, m_y(ix)
;;    cp #max_score_y
;;    ret z
;;    ;; check if in 8,1
;;    cp #1
;;    jr nz, not_anomaly_down
;;    ld a, m_x(ix)
;;    cp #8
;;    ret z                       ;; return if I'm in 8,1 -> can't go down
;;not_anomaly_down:
;;    ld a, m_y(ix)
;;    ld m_py(ix), a
;;    inc a
;;    ld m_y(ix), a
;;    cp #entry_letter_lines
;;    jr c, _score_move_down_exit
;;    ld m_x(ix), #0
;;_score_move_down_exit:
;;    ld m_moved(ix), #1
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _score_move_up
;;;;
;;;;  Process fire key press
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_score_move_up:
;;    ld a, m_y(ix)
;;    or a
;;    ret z
;;    ld m_py(ix), a
;;    dec a
;;    ld m_y(ix), a
;;    ld m_moved(ix), #1
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _score_move_right
;;;;
;;;;  Process fire key press
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_score_move_right:
;;    ld a, m_y(ix)
;;    cp #entry_letter_lines
;;    ret nc
;;    ;; check if in 7,2
;;    cp #2
;;    jr nz, not_anomaly_right
;;    ld a, m_x(ix)
;;    cp #7
;;    ret z                       ;; return if I'm in 7,2
;;not_anomaly_right:
;;    ld a, m_x(ix)
;;    cp #max_score_x
;;    ret z
;;    ld m_px(ix), a
;;    inc a
;;    ld m_x(ix), a
;;    ld m_moved(ix), #1
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _score_move_left
;;;;
;;;;  Process fire key press
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_score_move_left:
;;    ld a, m_y(ix)
;;    cp #entry_letter_lines
;;    ret nc
;;    ld a, m_x(ix)
;;    or a
;;    ret z
;;    ld m_px(ix), a
;;    dec a
;;    ld m_x(ix), a
;;    ld m_moved(ix), #1
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _score_cancel_entry
;;;;
;;;;  Process fire key press
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_score_cancel_entry:
;;    ld m_ended(ix), #1
;;    ret
;;
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _get_letter
;;;;
;;;;  Obtain the leter selected by the marker
;;;;  Input: 
;;;;  Output: a: letter
;;;;  Modified: 
;;;;
;;_get_letter:
;;    cpctm_push hl, de
;;    ld h, m_y(ix)
;;    ld e, #9
;;    call sys_util_h_times_e
;;    ld a, m_x(ix)                           ;; add x    
;;    add l                                   ;; add row by 9
;;    add #65                                 ;; add starting capital letters
;;    cpctm_pop de, hl
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _score_fire
;;;;
;;;;  Process fire key press
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_score_fire:
;;    ld a, m_y(ix)
;;    cp #entry_letter_lines
;;    jr c, _letter_lines
;;    cp #3
;;    jr z, _space
;;    cp #4
;;    jr z, _delete
;;done:
;;    ld m_ended(ix), #2
;;    ret
;;_letter_lines:
;;    ld a, (score_name_length)
;;    cp #10
;;    ret z                                   ;; resturn if we already have 10 chars in the string
;;    ld hl, #score_name_string
;;    add_hl_a
;;    call _get_letter
;;    ld (hl), a                              ;; insert the selected character
;;    inc hl              
;;    ld (hl), #0                             ;; insert 0 to terminate de string
;;    ld hl, #score_name_length
;;    inc (hl)
;;    call sys_score_hiscore_name_print
;;    ret
;;_space:
;;    ld a, (score_name_length)               ;;
;;    cp #10                                  ;;
;;    ret z                                   ;; return if we already have 10 chars in the string
;;    ld hl, #score_name_string
;;    add_hl_a
;;    ld (hl), #32                            ;; insert the space character
;;    inc hl              
;;    ld (hl), #0                             ;; insert 0 to terminate de string
;;    ld hl, #score_name_length
;;    inc (hl)
;;    call sys_score_hiscore_name_print
;;    ret
;;_delete:
;;    ld a, (score_name_length)               ;;
;;    or a                                    ;;
;;    ret z                                   ;; Return if lenght of string is 0
;;    dec a                                   ;; Decrement length
;;    ld hl, #score_name_string               ;;
;;    add_hl_a                                ;; Position hl on last char of string
;;    ld (hl), #0                             ;; Set char to #0 (end of string)
;;    ld hl, #score_name_length               ;;
;;    dec (hl)                                ;; Decrement string length
;;    call sys_score_hiscore_name_print       ;; Print name to check changes
;;    ret

;;;;-----------------------------------------------------------------
;;;;
;;;; _input_update_moved
;;;;
;;;;   Initializes input
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_input_update_moved:
;;    ld a, #1                                ;;
;;    ld e_moved(ix), a                       ;; Set moved flag to 1
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _cancel_game
;;;;
;;;;   Initializes input
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_cancel_game:
;;    ld a, #1                                ;;
;;    ld (man_game_cancelled_game), a         ;; Set cancelled game flag to 1
;;    call sys_input_clean_buffer             ;; Clean input buffer
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _move_left
;;;;
;;;;   Move left
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_move_left:
;;    ld a, e_x(ix)
;;    or a
;;    ;;jp z, sys_input_vertical_check
;;    ret z
;;    dec a
;;    ld e_x(ix), a
;;    call #_input_update_moved             ;; jump to return moved
;;    ;;jp sys_input_vertical_check
;;    ret
;;
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _move_right
;;;;
;;;;   Move right
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_move_right:
;;    ld b, e_w(ix)                       ;; load b with the width of th piece
;;    ld a, #BOARD_COLS                   ;; load a with the width of the board
;;    sub b                               ;; substract w of piece from width of board
;;    ld b, a                             ;; store that calculus in b
;;    ld a, e_x(ix)                       ;; load a with the x position
;;    cp b                                ;; compare with b
;;    ret z                               ;; if zero return
;;    inc a                               ;; inc x position stored in a
;;    ld e_x(ix), a                       ;; store it in player1 struct
;;    call _input_update_moved            ;; jump to return moved
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _move_up
;;;;
;;;;   Move up
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_move_up:
;;    ld a, e_y(ix)
;;    or a
;;    ;;jp z, sys_input_actions_check
;;    ret z
;;    dec a
;;    ld e_y(ix), a
;;    call _input_update_moved             ;; jump to return moved
;;    ;;jp sys_input_actions_check
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _move_down
;;;;
;;;;   Move down
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_move_down:     
;;    ld b, e_h(ix)                       ;; load b with the width of th piece
;;    ld a, #BOARD_ROWS                   ;; load a with the width of the board
;;    sub b                               ;; substract w of piece from width of board
;;    ld b, a                             ;; store that calculus in b
;;    ld a, e_y(ix)                       ;; load a with the x position
;;    cp b                                ;; compare with b
;;    ret z                               ;; if zero return
;;    inc a                               ;; inc x position stored in a
;;    ld e_y(ix), a                       ;; store it in player1 struct
;;    call _input_update_moved            ;; jump to return moved
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _change_piece
;;;;
;;;;   Change piece
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_change_piece:     
;;    ld a, (selected_piece)              ;; read selected piece
;;    ld (_erase_previous_piece+1), a     ;; keep current selected piece frame for erase later
;;_renew_piece:
;;    ld a, (selected_piece)              ;; read selected piece
;;    inc a                               ;; increment piece type
;;    cp #3       
;;    jr nz, _valid_piece_0     
;;    xor a       
;;_valid_piece_0:
;;    ld (selected_piece), a
;;    ld hl, #next_pieces
;;    add_hl_a
;;    ld a, (hl)
;;    cp #0xff
;;    jr z, _renew_piece
;;    ;; New piece ok       
;;    ld e_type(ix), a                    ;; Update piece in Player1 struct
;;_erase_previous_piece:
;;    ld a, #00
;;    call sys_render_draw_next_frame     ;; erase previous selected piece frame
;;    ld a, (selected_piece)              ;; select current selected piece
;;    call sys_render_draw_next_frame     ;; draw current selected piece frame
;;   
;;    ld a, e_type(ix)
;;    call man_entity_get_hl_from_piece   ;; get address of the piece type in hl
;;_check_width:
;;    ld a, (hl)                          ;; read width of piece
;;    ld e_w(ix), a                       ;; store width of piece in player1 struct
;;    dec a                               ;; width minus 1 to add it to the x coord
;;    ld b, e_x(ix)                       ;; read x position in b
;;    add b                               ;; add x position and width
;;    cp #BOARD_COLS - 1                  ;; Compare with number of cols in board
;;    jp m, _check_height                 ;; If overflow check height because it's correct
;;    ld b, e_w(ix)       
;;    ld a, #BOARD_COLS                   ;; load in a the width of the board
;;    sub b                               ;; substract the width of the piece as new coord
;;    ld e_x(ix), a                       ;; load in player struct the new x coord
;;_check_height:      
;;    inc hl                              ;; read next byte of piece
;;    ld a, (hl)                          ;; read height of piece
;;    ld e_h(ix), a                       ;; store height of piece in player1 struct
;;    dec a                               ;; height minus 1 to add it to the y coord
;;    ld b, e_y(ix)                       ;; read y position in b
;;    add b                               ;; add y position and width
;;    cp #BOARD_ROWS - 1                  ;; Compare with number of cols in board
;;    jp m, _end_check                    ;; If no overflow check height
;;    ld a, #BOARD_ROWS                   ;; load in a the width of the board
;;    ld b, e_h(ix)       
;;    sub b                               ;; substract the width of the piece as new coord
;;    ld e_y(ix), a                       ;; load in player struct the new x coord
;;_end_check:
;;;; Get the sprite pointer to render the piece
;;    ld a, e_type(ix)
;;    call man_entity_get_piece_sprite_player
;;    ld e_sprite_player_ptr(ix), l
;;    ld e_sprite_player_ptr+1(ix), h
;;
;;;; Get the sprite pointer to render the piece
;;    ld a, e_type(ix)
;;    call man_entity_get_piece_sprite_big
;;    ld e_sprite_big_ptr(ix), l
;;    ld e_sprite_big_ptr+1(ix), h
;;
;;    call _input_update_moved
;;    
;;    call sys_input_clean_buffer         ;; wait until keyboard buffer is empty
;;    
;;    ;;jp _end_input_update
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; _set_piece
;;;;
;;;;   Move left
;;;;  Input: 
;;;;  Output:
;;;;  Modified: 
;;;;
;;_set_piece:
;;    ;; loop to wait until keyup
;;    call cpct_scanKeyboard_asm
;;    ld hl, #Key_Space                   ;; check key Space
;;    call cpct_isKeyPressed_asm          ;; 
;;    jp nz, _set_piece                   ;; if press Space loop
;;
;;    ld e_set(ix), #1
;;    call _input_update_moved
;;    ret

;;-----------------------------------------------------------------
;;
;;  _add_card
;;
;;  Add card to deck
;;  Output:
;;  Modified: iy, bc
;;
_add_card::
    ld a, (hand_num)                ;; Check if we already have 10 cards in the deck
    cp #10                          ;;
    ret z                           ;; if 10 return

    call cpct_waitVSYNC_asm
    call sys_render_erase_hand      ;; erase deck area
    call man_deck_get_random_card   ;; get hl pointing to a random card
    call man_hand_create_card       ;; create a card in the deck
    call sys_render_hand
    ret

;;-----------------------------------------------------------------
;;
;;  _remove_card
;;
;;  Add card to deck
;;  Output:
;;  Modified: iy, bc
;;
_remove_card::
    ld a, (hand_num)                ;; Check if we dont have any card in the deck
    or a                            ;;
    ret z                           ;; if 0 return

    call cpct_waitVSYNC_asm
    call sys_render_erase_hand      ;; erase deck area
    ld a, (deck_selected)
    call man_hand_remove_card
    call sys_render_hand
    ret

;;-----------------------------------------------------------------
;;
;;  _selected_left
;;
;;  move selected card to the left
;;  Output:
;;  Modified: 
;;
_selected_left::
    ld a, (hand_selected)
    or a
    ret z

    call cpct_waitVSYNC_asm
    call sys_render_erase_hand      ;; erase deck area
    ld hl, #hand_selected
    dec (hl)
    call sys_render_hand

    ret

;;-----------------------------------------------------------------
;;
;;  _selected_right
;;
;;  move selected card to the right
;;  Output:
;;  Modified: 
;;
_selected_right::
    ld a, (hand_num)
    ld b, a
    ld a, (hand_selected)
    inc a
    cp b
    ret z

    call cpct_waitVSYNC_asm
    call sys_render_erase_hand      ;; erase deck area
    ld hl, #hand_selected
    inc (hl)
    call sys_render_hand

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

;;;;-----------------------------------------------------------------
;;;;
;;;; sys_input_update
;;;;
;;;;   Initializes input
;;;;  Input: 
;;;;  Output:
;;;;  Modified: iy, bc
;;;;
;;sys_input_update::
;;    ld ix, #player1                     ;; get player1 struct
;;    ld iy, #sys_input_key_actions
;;    call sys_input_generic_update
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; sys_input_score_entry_update
;;;;
;;;;   Initializes input
;;;;  Input: 
;;;;  Output:
;;;;  Modified: iy, bc
;;;;
;;sys_input_score_entry_update::
;;    ld ix, #score_marker                     ;; get player1 struct
;;    ld iy, #sys_input_score_key_actions
;;    call sys_input_generic_update
;;    ret
;;
;;;;-----------------------------------------------------------------
;;;;
;;;; sys_input_main_screen_keys
;;;;
;;;;   Process keyboard in main screen
;;;;  Input: 
;;;;  Output: a=1->play; a=2->redefine keys
;;;;  Modified: iy, bc
;;;;
;;sys_input_main_screen_keys::
;;    
;;    ld hl, #Key_R
;;    call cpct_isKeyPressed_asm          ;;
;;    jr nz, _redefine_exit               ;; if press R set redefine flag
;;    ;;call cpct_isAnyKeyPressed_asm
;;    ;;or a
;;    ld hl, #Key_S
;;    call cpct_isKeyPressed_asm          ;;
;;    jr nz, _play_exit               ;; if press R set redefine flag
;;    jr sys_input_main_screen_keys
;;_play_exit:
;;    call sys_input_clean_buffer
;;    xor a
;;    jr _exit
;;_redefine_exit:
;;    call sys_input_clean_buffer
;;    ld a, #1
;;_exit:
;;    ret


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
    ;;ld ix, #score_marker                     ;; get player1 struct
    ld iy, #sys_input_debug_key_actions
    call sys_input_generic_update
    ret




