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
    ld e, #S_NODES_WIDTH           ;;
    call sys_util_h_times_e     ;; calc (x*NODE_WIDTH) + MAP_X_START
    ld a, #MAP_X_START          ;;
    add l                       ;;
    ld c, a                     ;;
    
    ;; calc y coord
    ld h, b                     ;;
    ld e, #(S_NODES_HEIGHT*2)          ;;
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
    call nz, man_map_render_node
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


