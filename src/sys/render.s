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
.include "sys/text.h.s"
.include "sys/util.h.s"
.include "cpctelera.h.s"
.include "common.h.s"

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

FONT_NUMBERS: .dw #0000

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

    cpctm_setBorder_asm HW_BRIGHT_WHITE     ;; Set Border

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
;; sys_render_erase_deck
;;
;;  Erase the deck render area
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_erase_deck::
    ld b, #0                        ;; move num cards in deck to b (index)
    ld a,(#deck_X_start)            ;; retrieve X start position of the deck
    ld c, a                         ;; c = x coordinate  
_e_d_loop01:    
    push bc                       
    ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld a, (deck_selected)           ;; compare card selected with current card
    cp b                            ;;
    ld b, #DECK_Y                   ;; c = y coordinate by default
    jr nz, _erase_not_selected      ;; jump if current card not selected
    ld b, #DECK_Y - 5

_erase_not_selected:
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    
    ex de, hl                       ;; move screen address to de
    ld c, #S_CARD_WIDTH
    ld b, #S_CARD_HEIGHT
    ld a,#0                         ;; Patern of solid box
    call cpct_drawSolidBox_asm

    pop bc                          ;; retrieve bc index of loop, and x coord
    
    ld a, #(S_CARD_WIDTH-2)             ;; add CARD WITH to x coord
    add c                           ;;
    ld c, a                         ;;

    inc b                           ;; increment current card

    ld a, (deck_num)                ;; compare with num of cards in deck
    cp b                            ;;
    jr nz, _e_d_loop01              ;; return to loop if not lasta card reached

    ;; Erase description
    ld c, #64
    ld b, #20    
    cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_X, DESC_Y_1  ;; screen address in de
    ld a, #0
    call cpct_drawSolidBox_asm

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_card
;;
;;  Renders a specific card
;;  Input:  b: y coord
;;          c: x coord
;;          ix: points to card
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_card:
    ;; Get screen address of the card
    ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL

    ex de, hl

    push de

    ld l, c_sprite(ix)
    ld h, c_sprite+1(ix)
    ld c, #S_CARD_WIDTH
    ld b, #S_CARD_HEIGHT
    call cpct_drawSprite_asm

    ld h, #(S_CARD_ENERGY_WIDTH * S_CARD_ENERGY_HEIGHT)
    ld e, c_energy(ix)
    call sys_util_h_times_e
    ld a, l
    ld hl,#_s_cards_energy_0
    add_hl_a
    pop de
    ld c, #S_CARD_ENERGY_WIDTH
    ld b, #S_CARD_ENERGY_HEIGHT
    call cpct_drawSprite_asm

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
    ld a,(deck_num)            ;; retrieve num cards in deck
    or a                        ;; If no cards ret
    ret z                       ;;

    ld ix, #deck_array
    ld a,(#deck_X_start)        ;; retrieve X start position of the deck
    ld c, a                     ;; c = x coordinate 
    ld b, #0
_s_r_d_loop0:
    push bc     
    push ix                                                 ;; Save b and c values 

    ld a, (deck_selected)                                   ;; compare card selected with current card
    cp b                                                    ;;
    ld b, #DECK_Y                                           ;; c = y coordinate by default
    jr nz, _render_not_selected                             ;; jump if current card not selected
    ld b, #DECK_Y - 5

    cpctm_push AF, BC, DE, HL                               ;; Save values              
    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_X, DESC_Y_1    ;; screen address in de
    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    ;; Render Card Description
    ld de, #c_description                                       ;; load description address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_X, DESC_Y_2    ;; screen address in de
    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    cpctm_pop HL, DE, BC, AF                                    ;; Restore values    

_render_not_selected:
    call  sys_render_card

    pop ix                      ;; Move ix to the next card
    ld de, #sizeof_c            ;;
    add ix, de                  ;;

    pop bc                      ;; retrive b value for the loop

    ld a, #(S_CARD_WIDTH-2)         ;; Calculate x coord in C
    add c                       ;;
    ld c, a                     ;;

    inc b                       ;; increment current card

    ld a, (deck_num)            ;; compare with num of cards in deck
    cp b                        ;;
    jr nz, _s_r_d_loop0         ;; return to loop if not lasta card reached

    ret