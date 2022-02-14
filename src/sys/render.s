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

.module render_system

.include "sys/render.h.s"
.include "man/deck.h.s"
.include "man/card.h.s"
.include "cpctelera.h.s"
.include "common.h.s"

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
;; sys_render_init
;;
;;  Initilizes render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_init::
    
    ld c,#0                                 ;; Set video mode
    call cpct_setVideoMode_asm              ;;
    
    ld hl, #_g_palette0                     ;; Set palette
    ld de, #16                              ;;
    call cpct_setPalette_asm                ;;

    cpctm_setBorder_asm HW_BLACK            ;; Set Border

    cpctm_clearScreen_asm 0                 ;; Clear screen

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update::
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_deck
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_deck::
    ld ix, #deck_array

    ld b, #deck_num
    ld c, #DECK_X                    ;; C = x coordinate 

s_r_d_loop:
    push bc     
    push ix                      ;; Save b and c values 
    ;; Get screen address of the card
    ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    ld b, #DECK_Y                    ;; B = y coordinate
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL

    ex de, hl

    ld l, c_sprite(ix)
    ld h, c_sprite+1(ix)
    ld c, #S_CARD_WIDTH
    ld b, #S_CARD_HEIGHT
    call cpct_drawSprite_asm

    pop ix
    ld de, #sizeof_c
    add ix, de

    pop bc                  ;; retrive b value for the loop

    ld a, #S_CARD_WIDTH     ;; Calculate x coord in C
    add c
    ld c, a 

    djnz s_r_d_loop
    
    ret