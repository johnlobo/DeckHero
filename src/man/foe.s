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
;;          _status, _name,           _sprite, _sprite_x, _sprite_y, _sprite_w, _sprite_h, _life, _max_life, _money, _effects_count, _shield, _force, _dexterity, _buffer, _blessing, _thorns, _regen, _draw_card, _confuse, _poison
DefineOponent 1, ^/BLOB           /, _s_blob_0,50, 75, S_BLOB_WIDTH, S_BLOB_HEIGHT, 20, 20, 99, 1, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0
;;DefineOponent 1, ^/BLOB           /, _s_blob_0,50, 75, S_BLOB_WIDTH, S_BLOB_HEIGHT, 20, 20, 99, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, #sys_behaviour_blob, 0
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
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_foe_init::
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
    ret

;;-----------------------------------------------------------------
;;
;; man_foe_create
;;
;;  Initializes a fight
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_foe_create::
    ld hl, #foe_blob
    ld ix, #foes
    call man_array_create_element
    ld a, #o_type_alive             ;; Update the status of the new foe
    ld (hl), a                      ;;
    ret

;;-----------------------------------------------------------------
;;
;; man_foe_remove
;;
;;  Initializes a fight
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
    ld a, #0                                ;; TODO: erase any foe
    call man_array_remove_element

    m_updated_foe_sprite

    pop ix
    ret





