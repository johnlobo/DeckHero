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
;;  Input:  hl: icon
;;          ix: oponent
;;  Output:
;;
;;  Modified: af, bc, hl
;;
man_effects_animate::

;;    
;;    xor a                           ;; initilizes the index
;;mea_anim_loop:
;;    push af                         ;; store index in the stack
;;    push hl                         ;; store sprite address in the stack
;;
;;    ;; Calculate screen address
;;
;;    sla a                           ;; multiply index by two and save it in b
;;    ld b, a
;;
;;    ld a, o_sprite_h(ix)
;;    sra a
;;    sub a, b
;;    ld b, o_sprite_y(ix)
;;    add a, b
;;    ld b, a
;;
;;    ;;ld c, o_sprite_w(ix)            ;; load width of sprite in c
;;    ;;sra c                           ;; divide width by 2
;;    ;;ld a, o_sprite_x(ix)            ;; load x coord of sprite in e
;;    ;;add a, c                        ;; x+(width/2)
;;    ;;ld c, a                         ;; c = xcoord
;;
;;    ld a, o_sprite_x(ix)
;;    ld c, #S_SMALL_ICONS_WIDTH+2
;;    sub a, c
;;    ld c, a
;;
;;    ld_de_backbuffer                ;;
;;
;;    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
;;    
;;    ld (mea_restore_back+1), hl     ;; store the last screen adress to restore back ground
;;
;;    ;; Draw sprite
;;    ex de, hl
;;    
;;    pop hl                          ;; retrieve sprite address form the stack
;;    push hl                         ;; store sprite address in the stack for later use
;;    ld c, #S_SMALL_ICONS_WIDTH
;;    ld b, #S_SMALL_ICONS_HEIGHT
;;    call cpct_drawSprite_asm
;;
;;    call sys_render_switch_buffers
;;    
;;    ld b, #20                       ;; delay 
;;    call cpct_waitHalts_asm
;;
;;mea_restore_back:
;;    ld de, #0000
;;    xor a
;;    ld c, #S_SMALL_ICONS_WIDTH
;;    ld b, #S_SMALL_ICONS_HEIGHT
;;    call cpct_drawSolidBox_asm
;;
;;    pop hl                          ;; retrieve sprite address form the stack
;;    pop af
;;    inc a
;;    cp #4
;;    jr nz, mea_anim_loop
;;
;;    call cpct_waitVSYNC_asm
;;
;;    ret
;;

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

    ld b, #0
mea_anim_loop:
    push bc

    ;; Draw sprite
    ;; calculate sprite address                 ;;
    ld hl, #_s_effect_0                         ;;
    ld de, #(S_EFFECT_WIDTH*S_EFFECT_HEIGHT)    ;;            
    ld a, b                                     ;;
mea_prep_de:            
    or a            
    jr z, mea_prep_de_exit          
    add hl, de          
    dec a           
    jr mea_prep_de          
mea_prep_de_exit:           
    ex de, hl                                   ;; move result to de
    ld hl, (#effect_address)
    ex de, hl                                   ;; hl stores sprite address, and de screen address
    ld c, #S_EFFECT_WIDTH
    ld b, #S_EFFECT_HEIGHT
    call cpct_drawSprite_asm

    ;; delay
    ld b, #20                    
    call cpct_waitHalts_asm

    ;; restore background
    ld hl, (#effect_address)
    ex de, hl
    ld hl, (#effect_buffer)
    ld c, #S_EFFECT_WIDTH
    ld b, #S_EFFECT_HEIGHT
    call cpct_drawSprite_asm
 
    pop bc                                      ;; endo of loop
    inc b                                       ;;
    push bc
    ld a, b                                     ;;
    cp #4                                       ;;
    jr nz, mea_anim_loop                        ;;
    pop bc 
    
    ret

    effect_buffer: .ds #144
    effect_address: .dw #0000
