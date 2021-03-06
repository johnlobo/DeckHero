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

.module oponent_manager

.include "man/oponent.h.s"
.include "man/foe.h.s"
;;.include "common.h.s"
;;.include "man/deck.h.s"
.include "man/array.h.s"
;;.include "sys/input.h.s"
;;.include "sys/render.h.s"
.include "comp/component.h.s"
.include "cpctelera.h.s"

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
;; man_oponent_init
;;
;;  Initializes a oponent
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
man_oponent_update::
    ret
;;-----------------------------------------------------------------
;;
;; man_oponent_update
;;
;;  main loop of a oponent
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
man_oponent_init::
    ret
;;-----------------------------------------------------------------
;;
;; man_oponent_create
;;
;;  creates an oponent
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
man_oponent_create::
    ret

;;-----------------------------------------------------------------
;;
;; man_oponent_one_damage
;;
;;  damages a foe
;;  Input: a: damage to apply 
;;  Output: 
;;  Modified: 
;;
;; TODO: implment foe selector
;;
man_oponent_one_damage::
    ld (m_o_o_d_damage), a

    push ix
    ld hl, #foes
    ld a, #a_array
    add_hl_a
    ld__ix_hl

m_o_o_d_damage = .+1    ;; Substract the damage done to the life
    ld b, #0            ;;
    ld a, o_life(ix)    ;;
    sub b               ;;
    ld o_life(ix), a    ;;
    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_oponent_all_damage
;;
;;  damages a foe
;;  Input: 
;;  Output: a random piece
;;  Modified: 
;;
man_oponent_all_damage::
    ret


;;-----------------------------------------------------------------
;;
;; man_oponent_add_block
;;
;;  adds block to a oponent
;;  Input: ix: oponent to add block
;;  Output: b: amount of block to add
;;  Modified: 
;;
man_oponent_add_block::
    ld a, o_shield(ix)    ;;
    add b               ;;
    ld o_shield(ix), a    ;;
    ret