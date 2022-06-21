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

.module map_manager

.include "man/map.h.s"
.include "sys/util.h.s"
.include "sys/render.h.s"
.include "sys/input.h.s"
.include "common.h.s"
.include "cpctelera.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

;; Character templates
map::
;;.ds (8*8)
;; Each node has 1 bit unused, 2 bits for upper connectios, 2 bits for lower connections, and 3 bits for node id
.db #0b00000001, #0b00000001, #0b00000001, #0b00000001
.db #0b01111100, #0b01111011, #0b01111010, #0b01111000
.db #0b00000000, #0b01111101, #0b00010011, #0b00001100
.db #0b01110001, #0b01110010, #0b00010011, #0b01000100
.db #0b01111001, #0b01111101, #0b00000000, #0b00001100
.db #0b01011001, #0b01011010, #0b00010011, #0b00001100
.db #0b01111001, #0b01111010, #0b00010011, #0b00001100
.db #0b01111001, #0b01111010, #0b00010011, #0b00001100

line_buffer:: .db #0x00, #0x02, #0x01, #0x04, #0x06, #0x02, #0x01, #0xff
indent:: .db #0x00



;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_map_init
;;
;;  Initializes the map
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_map_init::
    call sys_render_clear_front_buffer
    cpctm_setBorder_asm HW_WHITE            ;; Set Border
    ret

;;-----------------------------------------------------------------
;;
;; man_map_init
;;
;;  Initializes the line_buffer
;;  Input: 
;;  Output: 
;;  Modified: 
map_line_buffer_init::
    ld hl, #line_buffer
    ld (hl), #0xff
    ld d, h
    ld e, l
    inc de
    ld bc, #8
    ldir
    ret

;;-----------------------------------------------------------------
;;
;; man_map_render_pipeline
;;
;;  Initializes the map
;;  Input:  b: row
;;  Output: 
;;  Modified: 
;;
man_map_build_buffer_line::
    push ix
    ld ix,#line_buffer
    push bc                                             ;; save row
    call map_line_buffer_init                           ;; Initialize buffer line
    pop bc                                              ;; restore row

    xor a                                               ;;    
    bit 0,b                                             ;; set indent
    jr z, mmbbl_indent_exit                             ;;
    ld a, #1                                            ;;
mmbbl_indent_exit:                                      ;;
    ld (indent), a                                      ;;

    ;; hl point to the specific row
    ld hl, #map
    ld de, #04
    ld a, b
mmbbl_row:
    or a
    jr z, mmbbl_row_exit
    add hl,de
    dec a
    jr mmbbl_row

mmbbl_row_exit:
    ;; main loop
    ld b, #4
mmbbl_loop:
    push bc
    push hl 
    ld a, (hl)
    ld (ORIGINAL_NODE3), a
    and #0b00000111
    or a
    jr z, mmbbl_loop_skip           ;; skip if no node
ORIGINAL_NODE3 = . +1
    ld a, #0x00                     ;; retrieve node
    ld (ORIGINAL_NODE4), a          ;; save node for bit 4
    bit 3, a
    jr z, mmbbl_bit4
    ld a, (indent)                  ;; check if indent bit 3
    or a                            ;;
    jr nz, mmbbl_bit3_indent        ;;
    ld 0(ix), #4
    ld 1(ix), #1
    jr mmbbl_bit4
mmbbl_bit3_indent:
    ld 0(ix), #0
    ld 1(ix), #5
mmbbl_bit4:
ORIGINAL_NODE4 = . +1
    ld a, #0x00                     ;; retrieve node
    ld (ORIGINAL_NODE5), a          ;; save node for bit 4
    bit 4, a
    jr z, mmbbl_bit5
    ld a, (indent)                  ;; check if indent bit 3
    or a                            ;;
    jr nz, mmbbl_bit4_indent        ;;
    ld 0(ix), #4
    ld 1(ix), #1
    jr mmbbl_bit5
mmbbl_bit4_indent:
    ld 0(ix), #0
    ld 1(ix), #5
mmbbl_bit5:
ORIGINAL_NODE5 = . +1
    ld a, #0x00                     ;; retrieve node
    ld (ORIGINAL_NODE6), a          ;; save node for bit 4
    bit 5, a
    jr z, mmbbl_bit6
    ld 4(ix), #4
    ld 5(ix), #1
mmbbl_bit6:
ORIGINAL_NODE6 = . +1
    ld a, #0x00                     ;; retrieve node
    bit 6, a
    jr z, mmbbl_loop_skip
    ld 6(ix), #4
    ld 7(ix), #1

mmbbl_loop_skip:
    pop hl                          ;; restore pointer to the node 
    inc hl                          ;; increase pointer
    pop bc                          ;; restore loop index
    djnz mmbbl_loop                 ;; loop
    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; man_map_render_pipeline
;;
;;  Initializes the map
;;  Input:  b: row
;;  Output: 
;;  Modified: 
;;
man_map_render_pipeline::
    
    ld a, b                                     ;; build buffer line 
    ld (MMRP_SAVE_ROW),a                        ;; Save b with self modifying code
    call man_map_build_buffer_line              ;;
MMRP_SAVE_ROW = . +1                            ;;
    ld b, #00                                   ;;

    ;;inc b                                     ;; Calc YCoord form row
    ld h, b                                     ;;
    ld e, #(S_NODES_HEIGHT*2)                   ;;
    call sys_util_h_times_e                     ;;
    ld a, #MAP_Y_START                          ;;
    sub l                                       ;;
    add #S_NODES_HEIGHT                         ;;
    ld b, a                                     ;;

    ld c, #MAP_X_START                          ;; Set col

    ;; Calc address screen          
    ld_de_frontbuffer               
    call cpct_getScreenPtr_asm                  ;; Calculate video memory location and return it in HL
    ex de, hl

    ld bc, #00
mmrp_loop:
    push bc
    push de
    ld a, c                                     ;; check if we have processed all the line buffer
    cp #8                                       ;;
    jr z, mmrp_loop_exit                        ;;

    ld hl, #line_buffer                         ;; move hl to the current value
    add hl, bc                                  ;;
    
    ld a, (hl)                                  ;; get value form buffer line
    
    cp #0xff                                    ;; skip??
    jr z, mmrp_skip                             ;;

    ld de, #(S_NODES_WIDTH*S_NODES_HEIGHT)      ;; load the size of the pipe in de
    ld hl, #_s_pipes_0                          ;; point hl to the first pipe
mmrp_pipe_loop:
    or a                                        ;; if we have finished exit loop 
    jr z, mmrp_pipe_loop_exit                      ;;
    add hl, de                                  ;; otherwise add fofset to hl
    dec a                                       ;; decrement a
    jr mmrp_pipe_loop                           ;; loop

mmrp_pipe_loop_exit:
    pop de
    push de
    ld c, #S_NODES_WIDTH
    ld b, #S_NODES_HEIGHT
    call cpct_drawSprite_asm
mmrp_skip:
    pop de                                      ;; retrive the screen address 
    ld hl, #S_NODES_WIDTH                       ;; loda the width of the pipe in hl, to render next pipe
    add hl, de                                  ;; add current screen address and offset to hl
    ex de, hl                                   ;; exchange xl

    pop bc
    inc c
    jr mmrp_loop

mmrp_loop_exit:
    pop de
    pop bc
    ret

;;-----------------------------------------------------------------
;;
;; man_map_render_node
;;
;;  Initializes the map
;;  Input:  a: node data
;;          c: x coord
;;          b: y coord
;;  Output: 
;;  Modified: 
;;
man_map_render_node::
    push af
    ;; Calc x coord
    sla c                       ;; node positon * 2
    bit 0, b                    ;;
    jr z, mmrn_skip_indent      ;; if line is odd indent node
    inc c                       ;;
mmrn_skip_indent:
    ld h, c                     ;;
    ld e, #S_NODES_WIDTH        ;;
    call sys_util_h_times_e     ;; calc (x*NODE_WIDTH) + MAP_X_START
    ld a, #MAP_X_START          ;;
    add l                       ;;
    ld c, a                     ;;
    
    ;; calc y coord
    ld h, b                     ;;
    ld e, #(S_NODES_HEIGHT*2)   ;;
    call sys_util_h_times_e     ;; calc (y*NODE_HEIGTH) + MAP_Y_START
    ld a, #MAP_Y_START          ;;
    sub l                       ;;
    ld b, a                     ;;

    ;; Calc address screen
    ld_de_frontbuffer    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de
    
    ;; draw node sprite
    pop af
    ld c, #0b00000111
    and c
    dec a                           ;; adjust 1 = 0
    ld hl, #_s_nodes_0
    ld bc, #(S_NODES_WIDTH*S_NODES_HEIGHT)
mmrn_loop:
    or a
    jr z, mmrn_loop_exit
    add hl, bc
    dec a
    jr mmrn_loop
mmrn_loop_exit:
    ld c, #S_NODES_WIDTH
    ld b, #S_NODES_HEIGHT
    call cpct_drawSprite_asm

    ret




;;-----------------------------------------------------------------
;;
;; man_map_render::
;;
;;  Initializes the map
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_map_render::
    ld c, #0                            ;; Initialize bc
    ld b, #0                            ;;
    ld hl, #map                         ;; initialize hl
mmr_main_loop:
    ld a, c                             ;; check if col = MAP_WIDTH
    cp #MAP_WIDTH                       ;;
    jr z, mmr_next_line                 ;; if so -> next line
    ld a, (hl)                          ;; get node value
    or a                                ;;
    cpctm_push bc, hl                   ;; save bc and hl
    call nz, man_map_render_node        ;; if node value is not zero -> render node
    cpctm_pop hl, bc                    ;; restore bc and hl
    inc c                               ;; inc col
    inc hl                              ;; inc map pointer
    jr mmr_main_loop                    ;; loop
mmr_next_line:
    push bc                             ;; save bc
    push hl                             ;; save hl
    ld a, b                             ;; check if row != 0
    or a                                ;;
    call nz, man_map_render_pipeline    ;; render pipeline if row != 0
    pop hl                              ;; restore hl
    pop bc                              ;; restore bc
    ld c, #0                            ;; init col
    inc b                               ;; inc row
    ld a, b                             ;; check if row = MAP_HEIGHT
    cp #MAP_HEIGHT                      ;;
    jr nz, mmr_main_loop                ;; if not -> loop
    ;; new line

    call sys_input_wait4anykey          ;; wait for any key

    ret

