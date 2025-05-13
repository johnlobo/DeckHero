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

.module foe_manager

.include "man/foe.h.s"
.include "common.h.s"
.include "man/deck.h.s"
.include "man/oponent.h.s"
.include "man/array.h.s"
.include "man/fight.h.s"
.include "sys/input.h.s"
.include "sys/render.h.s"
.include "sys/behaviour.h.s"
.include "cpctelera.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

;; Character templates
foe_blob::
;;          _status, _name,           _sprite, _sprite_x, _sprite_y, _sprite_w, _sprite_h,  _max_life, _money, _effects_count, _life, _shield, _force, _dexterity, _buffer, _blessing, _thorns, _regen, _draw_card, _confuse, _poison
DefineOponent 1, ^/BLOB           /, _s_blob_0,50, 65, S_BLOB_WIDTH, S_BLOB_HEIGHT, 20, 50, 2, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0
foe_mini_blob::
DefineOponent 1, ^/MINI-BLOB      /, _s_mini_blob_0,80, 65, S_MINI_BLOB_WIDTH, S_MINI_BLOB_HEIGHT, 25, 50, 2, 20, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0

;; Characters
foes::
DefineComponentArrayStructure_Size foes, MAX_FOES, sizeof_o     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_foe_init
;;
;;  Initializes a fight
;;  Input: b : level reached
;;         c : enemy type
;;  Output: 
;;  Modified: 
;;
man_foe_init::
    push bc                 ;; save level and enemy type
    ld ix, #foes
    xor a
    ld a_count(ix), a

    ld__hl_ix                  ;; point hl to the start of the array 
    ld a, #a_array
    add_hl_a
    ;;ld  (hand_pend), hl
    ld a_pend(ix), l
    ld a_pend+1(ix), h

    ld  (hl), #o_type_invalid   ;;ponemos el primer elemento del array con tipo invalido

    pop bc                  ;; retrieve level and enemy type
    call man_foe_create

    ret

;;-----------------------------------------------------------------
;;
;; man_foe_create
;;
;;  Initializes a fight
;;  Input: b : level reached
;;         c : enemy type
;;  Output: 
;;  Modified: 
;;
man_foe_create::
    ld de, #sizeof_o
    ld hl, #foe_blob
mfc_loop:
    ld c, a
    or a
    jr z, mfc_loop_exit
    adc hl, de
    jr mfc_loop
mfc_loop_exit:
    ld ix, #foes
    call man_array_create_element
    ld a, #o_type_alive             ;; Update the status of the new foe
    ld (hl), a                      ;;
    ret

;;-----------------------------------------------------------------
;;
;; man_foe_remove
;;
;;  removes a foe from the array
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_foe_remove::
    ret
    
;;-----------------------------------------------------------------
;;
;; man_foe_number_of_foes
;;
;;  return the number of remaining foes
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_foe_number_of_foes::
    ld a, (foes_count)
    ret

;;-----------------------------------------------------------------
;;
;; man_foe_kill_foe
;;
;;  Kills the corresponding foe
;;  Input: a number of foe to kill
;;  Output:
;;  Modified: 
;;
man_foe_kill_foe::
    push ix
    
    ld ix, #foes
    push af
    call man_array_get_element
    ld__ix_hl                       ;; move the foe to ix
    call sys_render_erase_oponent
    ld ix, #foes                    ;; set ix to the start of the foes array    
    pop af                          ;; retrieve the index of the foe to kill
    call man_array_remove_element

    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_foe_clean_dead_foes
;;
;;  Kills the corresponding foe
;;  Input: a number of foe to kill
;;  Output:
;;  Modified: 
;;
man_foe_clean_dead_foes::
    push ix                                 ;;  
    ld ix, #foes
    ld a, a_count(ix)                       ;; load the number of foes in a
    or a                                    ;;
    ret z                                   ;; return if no foes
    ld b, a                                 ;; save foes count in b   
foe_check_alive_loop:
    push bc
    ld ix, #foes
    ld a, b                                 ;; load the index of foes in a
    dec a                                   ;; foes are indexed from 0
    ld (foe_kill_foe+1), a                  ;; store the index of foes to kill
    call man_array_get_element              ;; call the function to get in hl the element "a"
    ld__ix_hl
    ld a, o_life(ix)                        ;; load the life of the foe in a
    or a                                    ;; check if the foe is dead
    jr nz, foe_next_foe                     ;; if not dead, go to the next foe
foe_kill_foe:
    ld a, #0                                ;; load the number of foe to kill
    call man_foe_kill_foe                   ;; kill the foe if dead
foe_next_foe:
    pop bc
    djnz foe_check_alive_loop
    pop ix
    ret




