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
.module effects_manager

.include "man/effects.h.s"
.include "cpctelera.h.s"
.include "common.h.s"
.include "man/array.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

effects::
DefineComponentArrayStructure_Size effects, MAX_EFFECTS, sizeof_eff     
.db 0   ;;ponemos este aqui como trampita para que siempre haya un tipo invalido al final

effect_template: 
;;          status, animation, sprote, x, y 
DefineEffect 01, null_ptr, null_ptr, 0, 0 

;;-----------------------------------------------------------------
;;
;; man_effects_create
;;
;;  creates an element in the array of effects
;;  Input: hl: animation address
;;          b: y pos
;;          c: x pos
;;  Output: 
;;
;;  Modified: af, bc, hl, de
;;
man_effects_create::
    push ix
    ;; update template values 
    ld ix, #effect_template
    ld eff_x(ix), c
    ld eff_y(ix), b
    ld eff_animation(ix), l
    ld eff_animation+1(ix), h
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld eff_sprite(ix), c
    ld eff_sprite+1(ix), b
    ;; create effect element
    ld ix, #effects
    ld hl, #effect_template
    call man_array_create_element
    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_effects_update
;;
;;  creates an element in the array of effects
;;  Input:
;;  Output: a: updated elements
;;
;;  Modified: af, bc, hl
;;
man_effects_update::
    xor a
    ld (updated_elements), a        ;; reset the number of updated elements
    ld b, a                         ;; reset the index of the loop
    ld ix, #effects
    
    ld a, (updated_elements)        ;; return the number of updated elements
    ret
updated_elements: .db #00

;;-----------------------------------------------------------------
;;
;; man_effects_update_one
;;
;;  creates an element in the array of effects
;;  Input:
;;  Output: a: updated elements
;;
;;  Modified: af, bc, hl
;;
man_effects_update_one::
    ret