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
.db #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001
.db #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000011, #0b00000000, #0b00000001, #0b00000000
.db #0b00000000, #0b00000101, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001
.db #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000011, #0b00000000
.db #0b00000000, #0b00000001, #0b00000000, #0b00000100, #0b00000000, #0b00000101, #0b00000000, #0b00000001
.db #0b00000100, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000
.db #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000010
.db #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000
.db #0b00000000, #0b00000001, #0b00000000, #0b00000010, #0b00000000, #0b00000001, #0b00000000, #0b00000001
.db #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000011, #0b00000000, #0b00000001, #0b00000000
.db #0b00000000, #0b00000101, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001
.db #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000001, #0b00000000, #0b00000011, #0b00000000
.db #0b00000000, #0b00000001, #0b00000000, #0b00000100, #0b00000000, #0b00000101, #0b00000000, #0b00000001
.db #0b00000000, #0b00000000, #0b00000000, #0b00000101, #0b00000000, #0b00000000, #0b00000000, #0b00000000

new_map::
.db #0b00000001, #0b00000001, #0b00000001, #0b00000001
.db #0b01000100, #0b01100011, #0b00010010, #0b00001000
.db #0b01000000, #0b00110010, #0b00010011, #0b00001100
.db #0b01000001, #0b00100010, #0b00010011, #0b00001100
.db #0b01000001, #0b00100010, #0b00010000, #0b00001100
.db #0b01000001, #0b00100010, #0b00010011, #0b00001100
.db #0b01000001, #0b00100010, #0b00010011, #0b00001100
.db #0b01000001, #0b00100010, #0b00010011, #0b00001100

line_buffer: .db #0x00, #0x02, #0x01, #0x04, #0x06, #0x02, #0x01, #0xff



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
    ld (hl), #0
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
    push bc
    call map_line_buffer_init
    pop bc
    ;; hl point to the specific row
    ld hl, #new_map
    ld de, #04
    ld a, b
mmbbl_row:
    or a
    jr z, mmbbl_row_exit
    add hl,bc
    dec a
    jr mmbbl_row

mmbbl_row_exit:
    ;; main loop
    ld b, #4
mmbbl_loop:
    push bc
    push hl 
    ld a, (hl)
    or a
    jr z, mmbbl_loop_skip           ;; skip if no node

;;
;;
;;
;;
;;
;;
;;




mmbbl_loop_skip:
    pop hl                          ;; restore pointer to the node 
    inc hl                          ;; increase pointer
    pop bc                          ;; restore loop index
    djnz mmbbl_loop                 ;; loop
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
    ;;inc b                                     ;; Calc row
    ld h, b                                     ;;
    ld e, #(S_NODES_HEIGHT*2)                   ;;
    call sys_util_h_times_e                     ;;
    ld a, #MAP_Y_START                          ;;
    sub l                                       ;;
    sra e                                       ;;
    sub e                                       ;; just one line upper
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
;; man_map_render_node
;;
;;  Initializes the map
;;  Input:  a: node data
;;          c: x coord
;;          b: y coord
;;  Output: 
;;  Modified: 
;;
man_new_map_render_node::
    push af
    ;; Calc x coord
    sla c                       ;; node positon * 2
    bit 0, b                    ;;
    jr z, mnmrn_skip_indent     ;; if line is odd indent node
    inc c                       ;;
mnmrn_skip_indent:
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
mnmrn_loop:
    or a
    jr z, mnmrn_loop_exit
    add hl, bc
    dec a
    jr mnmrn_loop
mnmrn_loop_exit:
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
    ld c, #0
    ld b, #0
    ld hl, #map
mmr_main_loop:
    ld a, c
    cp #MAP_WIDTH
    jr z, mmr_next_line
    ld a, (hl)
    or a
    cpctm_push bc, hl
    call nz, man_new_map_render_node
    cpctm_pop hl, bc
    inc c
    inc hl
    jr mmr_main_loop
mmr_next_line:
    ld c, #0
    inc b
    ld a, b
    cp #MAP_HEIGHT
    jr nz, mmr_main_loop
    ;; new line

    call sys_input_wait4anykey

    ret


;;-----------------------------------------------------------------
;;
;; man_map_new_render::
;;
;;  Initializes the map
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_new_map_render::
    ld c, #0
    ld b, #0
    ld hl, #new_map
mnmr_main_loop:
    ld a, c
    cp #MAP_WIDTH
    jr z, mnmr_next_line
    ld a, (hl)
    or a
    cpctm_push bc, hl
    call nz, man_new_map_render_node
    cpctm_pop hl, bc
    inc c
    inc hl
    jr mnmr_main_loop
mnmr_next_line:
    push bc
    push hl
    call man_map_render_pipeline
    pop hl
    pop bc
    ld c, #0
    inc b
    ld a, b
    cp #MAP_HEIGHT
    jr nz, mnmr_main_loop
    ;; new line

    call sys_input_wait4anykey

    ret

