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

.include "sys/messages.h.s"
.include "cpctelera.h.s"
.include "../common.h.s"
.include "sys/util.h.s"
.include "sys/text.h.s"
.include "sys/input.h.s"

.module messages_system

;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

_window_data::
_window_x: .db #00
_window_y: .db #00
_window_w: .db #00
_window_h: .db #00
_window_message: .dw #0000
_window_wait_for_key: .db #01
_press_any_key_string: .asciz "PRESS ANY KEY"

;; Constants to reach window data
w_x = 0
w_y = 1
w_w = 2
w_h = 3
w_message = 4
w_wait_for_key = 6


;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; sys_messages_load_window_data
;;
;;  Loads the window structure with the data in registers
;;  Input:  a : wait for key flag
;;          de: x and y coord
;;          bc: h and w of the window
;;          hl: message to show 
;;  Output:
;;  Modified: af, hl, de, bc
;;

sys_messages_load_window_data::
    ld iy, #_window_data
    ld w_w(iy), c
    ld w_h(iy), b
    ld w_x(iy), e
    ld w_y(iy), d
    ld w_message(iy), l
    ld w_message+1(iy), h
    ld w_wait_for_key(iy), a
    ret

;;-----------------------------------------------------------------
;;
;; sys_messages_draw_window
;;
;;  shows a message
;;  Input: 
;;  Output:
;;  Modified: af, hl, de, bc
;;

sys_messages_draw_window::

    call sys_messages_load_window_data

    ;; Draw Back window
    ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    ld b, w_y(iy)                   ;; B = y coordinate 
    ld c, w_x(iy)                   ;; C = x coordinate 
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de
    ld c, w_w(iy)
    ld b, w_h(iy)
    ld a,#0xff                      ;; Patern of solid box
    call cpct_drawSolidBox_asm

    ;; Draw Front Window
    ld de, #CPCT_VMEM_START_ASM     ;; 
    ld c, w_x(iy)                   ;;
    inc c                           ;; C = y coordinate + 1
    ld b, w_y(iy)                   ;;
    inc b                           ;; B = y coordinate + 2
    inc b                           ;;
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de
    
    ld c, w_w(iy)                   ;;
    dec c                           ;; C = w - 2
    dec c                           ;;   
    
    ld b, w_h(iy)                   ;;
    dec b                           ;; B = h - 4
    dec b                           ;;
    dec b                           ;;
    dec b                           ;;
    
    ld a,#0x00                     ;; Patern of solid box
    call cpct_drawSolidBox_asm

    ret


;;-----------------------------------------------------------------
;;
;; sys_messages_show
;;
;;  shows a message
;;  Input:  a : wait for key flag
;;          de: x and y coord
;;          bc: h and w of the window
;;          hl: message to show 
;;  Output:
;;  Modified: af, hl, de, bc
;;

sys_messages_show::

    call sys_messages_load_window_data

    call sys_messages_draw_window

    ;; Draw message
    ld de, #CPCT_VMEM_START_ASM     ;; 
    ld c, w_x(iy)                   ;;
    inc c                           ;; 
    inc c                           ;; C = x + 1
    inc c                           ;; 
    
    ld b, w_y(iy)                   ;;

    ld a, w_wait_for_key(iy)        ;; check if we have to wait for a key
    or a                            ;;
    jr z, no_wait4key               ;; return if not
    ld a, #10                       ;; B = y + 10
    jr y_coord
no_wait4key:
    ld a, #15
y_coord:
    add b                           ;;
    ld b, a                         ;;
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de

    ld c, #0
    ld h, w_message+1(iy)
    ld l, w_message(iy)
    call sys_text_draw_string

    ;; Draw Press Any Key

    ld a, w_wait_for_key(iy)  ;; check if we have to wait for a key
    or a                            ;;
    ret z                           ;; return if not

    ld de, #CPCT_VMEM_START_ASM     ;; 
    
    ld a, w_w(iy)                   ;;
    ld c, #26                       ;;
    sub c                           ;;
    sra a                           ;; c = x + ((w- length(str))/2)
    ld c, w_x(iy)                   ;;
    add c                           ;;
    ld c, a                         ;;

    ld b, w_y(iy)                   ;;
    ld a, #26                       ;; B = y + 10
    add b                           ;;
    ld b, a                         ;;
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de
    ld c, #0
    ld hl, #_press_any_key_string
    call sys_text_draw_string

    call sys_input_wait4anykey

    ret

;;-----------------------------------------------------------------
;;
;; draw_box
;;
;;  draws an empty box
;;  Input:  (2B DE) memory	Video memory pointer to the upper left box corner byte
;;          (1B A ) colour_pattern	1-byte colour pattern (in screen pixel format) to fill the box with
;;          (1B C ) HEIGHT	Box width in bytes [1-64] (Beware!  not in pixels!)
;;          (1B B ) WIDTH	Box height in bytes (>0)
;;  Output:
;;  Modified: af, hl, de, bc
;;
;; Implementation partly copied form cpctelera drawSolidBox
;;
sys_messages_draw_box::
    ld (#draw_border+1), a
    ld (#draw_border2+1), a
    ld (#draw_line+1), a
    ld a, b
    ld (width), a
 	ld h, d
	ld l, e	
    inc c                   ;; increment height in one 
	jr draw_line

next_line:
	ld a, c
	dec a
	or a
	ret z

	ld c, a
	ld a, (width)
	ld b,a

	ld a, c
	cp #1
	jr z, draw_line		;; Si estoy en la ultima linea salto a line
draw_border:
	ld (hl), #0xff
    ld a, b
    dec a
    add_hl_a
draw_border2:
	ld (hl), #0xff
	jr down_line

draw_line:
	ld (hl), #0xff
	inc hl
	djnz draw_line

down_line:
	ld a, #8          	    ;; [2] / HL = DE = DE + 0x800
	add d
    ld h, a           	    ;; [1] | Adding 0x800 makes HL point to the start of
	ld d, a
	ld l, e
	
	and   #0x38        	    ;; [2] leave out only bits 13,12 and 11 from new memory address (00xxx000 00000000)
    jp    nz, next_line    	;; [3] If any bit from {13,12,11} is not 0, we are still inside 
                        	;; ... video memory boundaries, so proceed with next line
                            ;; Every 8 lines, we cross the 16K video memory boundaries and have to
                            ;; reposition destination pointer. That means our next line is 16K-0x50 bytes back
                            ;; which is the same as advancing 48K+0x50 = 0xC050 bytes, as memory is 64K 
                            ;; and our 16bit pointers cycle over it
    ld    hl, #0xC050       ;; [3] We advance destination pointer to next line
    add   hl, de            ;; [3] HL = DE + 0xC050
    ld     d, h             ;; [1] / DE = HL
    ld     e, l             ;; [1] \
    jp   next_line         	;; [3] Continue copying

    ret
width: .db #0
height: .db #0