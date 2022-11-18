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
.include "man/oponent.h.s"
.include "sys/render.h.s"


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


;;
;; Start of _CODE area
;; 
.area _CODE

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

;;-----------------------------------------------------------------
;;
;; man_effects_animate
;;
;;  creates an element in the array of effects
;;  Input:  hl: animation
;;          ix: oponent
;;  Output:
;;
;;  Modified: af, bc, hl
;;
man_effects_animate::

    ld (effect_animation), hl

    ld a, o_sprite_h(ix)
    sra a
    ld b, o_sprite_y(ix)
    add a, b
    sub a, #S_EFFECT_HEIGHT/2
    ld b, a 

    ld a, o_sprite_w(ix)
    sra a
    ld c, o_sprite_x(ix)
    add a, c
    sub a, #S_EFFECT_WIDTH/2
    ld c, a 

    ld_de_frontbuffer               ;; not necessary to use double buffer

    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL  

    ld (#effect_address), hl          ;; save screen address for later use
    
    ;; save background
    ;; hl already loaded
    ld de, #effect_buffer
    ld c, #S_EFFECT_WIDTH
    ld b, #S_EFFECT_HEIGHT
    call cpct_getScreenToSprite_asm

    ld b, #0                                    ;; initialize animation step
mea_anim_loop:
    push bc                                     ;; store animation step in the stack

    ;; Draw sprite
    ;; calculate sprite address                 ;;
    ld hl, (effect_animation)                   ;; load in hl the animation to show
    ld a, b                                     ;; load in a the step of the animation
    sla a                                       ;; multiply by two step (address is 2 bytes)
    add_hl_a                                    ;; add it to starting animation
    ld__hl__hl_with_a                           ;; retrieve the address of the sprite in hl

                                                ;; (2B BC) psprite	Source Sprite Pointer
                                                ;; (2B DE) pvideomem	Destination video memory pointer
                                                ;; (1B IXL) width	Sprite Width in bytes (>0) (Beware, not in pixels!)
                                                ;; (1B IXH) height	Sprite Height in bytes (>0)
                                                ;; (2B HL) pmasktable0	Pointer to an Aligned Mask Table for transparencies with palette index 0

    push hl                                     ;; move sprite pointer to bc
    pop bc                                      ;;
    ld hl, (#effect_address)                    ;; move screen address to de
    ex de, hl                                   ;;
    ld__ixl S_EFFECT_WIDTH
    ld__ixh S_EFFECT_HEIGHT                         
    ld hl, #transparency_table

    call cpct_drawSpriteMaskedAlignedTable_asm


    ;; delay
    ld b, #50                    
    call cpct_waitHalts_asm

    ;; restore background
    ld hl, (#effect_address)
    ex de, hl
    ld hl, #effect_buffer
    ld c, #S_EFFECT_WIDTH
    ld b, #S_EFFECT_HEIGHT
    call cpct_drawSprite_asm
 
    ;; End of loop
    pop bc                                      ;; end of loop
    inc b                                       ;;
    ld a, b                                     ;;
    cp #4                                       ;;
    jr nz, mea_anim_loop                        ;;
    
    ret


    effect_buffer: .ds (#S_EFFECT_WIDTH*#S_EFFECT_HEIGHT)
    effect_address: .dw #0000
    effect_animation: .dw #0000
