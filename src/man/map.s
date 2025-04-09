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

.include "cpctelera.h.s"
.include "man/map.h.s"
.include "sys/util.h.s"
.include "sys/render.h.s"
.include "sys/input.h.s"
.include "common.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

game_map_0::
    .db  #0xff,    #0xff, #0xff, #0xff, #0xff
    .db  #0xff,    #0   , #0xff, #0xff, #0  
    .db  #0xff,    #0xff, #0xff, #0xff, #0xff
    .db  #0xff,    #0xff, #0xff, #0   , #0xff
    .db  #0xff,    #0   , #0xff, #0xff, #0xff
    .db  #0xff,    #0xff, #0xff, #0xff, #0xff
    .db  #0   ,    #1   , #1   , #1   , #0   

map_nodes_address::
    .dw #0xDEED,	#0xDEF9, 	#0xDF05,	#0xDF11,	#0xDF1D
    .dw #0xDDFD,	#0xDE09,	#0xDE15,	#0xDE21,	#0xDE2D
    .dw #0xDD0D,	#0xDD19,	#0xDD25,	#0xDD31,	#0xDD3D
    .dw #0xDC1D,	#0xDC29,	#0xDC35,	#0xDC41,	#0xDC4D
    .dw #0xDB2D,	#0xDB39,	#0xDB45,	#0xDB51,	#0xDB5D
    .dw #0xDA3D,	#0xDA49,	#0xDA55,	#0xDA61,	#0xDA6D
    .dw #0xD94D,	#0xD959,	#0xD965,	#0xD971,	#0xD97D
    
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
;; man_map_generate_cell
;;
;;
;;  renders the map based on tilemaps
;;  Input: 
;;  Output: 
;;  Modified: AF, BC
;;
man_map_generate_cell::
    ld a, #4                             ;; load max number in a
    call sys_util_get_random_number      ;;
    inc a                                ;; increment a to get a number between 1 and 5
    ret

;;-----------------------------------------------------------------
;;
;; man_map_generate
;;
;;
;;  renders the map based on tilemaps
;;  Input: 
;;  Output: 
;;  Modified: AF, BC
;;
man_map_generate::
;;    cpctm_WINAPE_BRK        ;; debug
    ld b, #7
    ld hl, #game_map_0
_m_m_g_looph:
    PUSH BC             ; Guardar el contador de filas en la pila
    LD c, #5             ; Contador del bucle interior (columnas)

_m_m_g_loopv:
                        ; Aquí va el código para procesar el elemento actual de la matriz
                        ; El elemento actual está apuntado por HL
                        ; Ejemplo de "procesamiento": cargar el valor en A (opcional)
    LD A, (HL)
    cp #0xff
    jr nz, _m_m_g_process_exit
    push hl
    call man_map_generate_cell
    pop hl
    ld (hl), a
_m_m_g_process_exit:
    INC HL              ; Mover al siguiente elemento (siguiente columna)
    DEC C               ; Decrementar el contador de columnas
    JR NZ, _m_m_g_loopv ; Si no es cero, volver al inicio del bucle de columnas

    POP BC            ; Restaurar el contador de filas
    DEC B             ; Decrementar el contador de filas
    JR NZ, _m_m_g_looph  ; Si no es cero, volver al inicio del bucle de filas
    ret


;;-----------------------------------------------------------------
;;
;; man_map_get_cell_address
;;
;;  renders the map based on tilemaps
;;  Input: bc: coordinate for the node (c: x, b:y)
;;  Output: hl: screen address
;;  Modified: AF, DE, HL
;;
man_map_get_cell_address::
;;cpctm_WINAPE_BRK                      ;; debug
    push bc                             ;; save bc
    ld hl, #map_nodes_address           ;; point hl to the LUT table
_m_m_r_s_c_loop:
    ld a, b                             ;; get y coord value
    or A                                ;; check if y coord is 0
    jr z, _m_m_r_s_c_exit               ;; if so exit
    ld de, #(5*2)                       ;; set de to 5 addresses (2 bytes) line size
    add hl, de                          ;; add 5 bytes to hl to point to the correct node
    dec b
    jr _m_m_r_s_c_loop                   ;; y coord loop
_m_m_r_s_c_exit:
    ld a, C                             ;; get x coord value
    sla a                               ;; multiply by 2 to adjust to word size
    add_hl_a                            ;; point hl to the x coord value
    ld e, (hl)                          ;; get x coord value
    inc hl                              ;; increase hl to point to the next node
    ld d, (hl)                           ;; store x coord value in c
    ex de, hl                           ;; exchange hl and de to get the screen address
    pop bc                              ;; restore bc
    ret

;;-----------------------------------------------------------------
;;
;; man_map_render_single_cell
;;
;;  renders the map based on tilemaps
;;  Input:  a: cell data
;;          bc: coordinate for the node (c: x, b:y)
;;  Output: 
;;  Modified: AF, DE, HL
;;
man_map_render_single_cell::
    push ix
    push bc
    push af                             ;; keep af
    call man_map_get_cell_address
    pop af                              ;; restore af
    push hl                             ;; save screen address in stack
    ld hl, #_s_nodes_0
    ld bc, #(S_NODES_WIDTH*S_NODES_HEIGHT)
mmrsc_loop:
    or a
    jr z, mmrsc_loop_exit
    add hl, bc
    dec a
    jr mmrsc_loop
mmrsc_loop_exit:
    pop de                              ;; retrieve screen address from stack
    ld c, #S_NODES_WIDTH
    ld b, #S_NODES_HEIGHT 
    
    call cpct_drawSprite_asm
    pop bc
    pop ix

    ret

;;-----------------------------------------------------------------
;;
;; man_map_render_cells
;;
;;  renders the map based on tilemaps
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_map_render_cells::

;;cpctm_WINAPE_BRK                      ;; debug

    ld b, #6
    ld hl, #game_map_0
_m_m_r_c_looph:
    PUSH BC             ; Guardar el contador de filas en la pila
    LD c, #4             ; Contador del bucle interior (columnas)

_m_m_r_c_loopv:
                        ; Aquí va el código para procesar el elemento actual de la matriz
                        ; El elemento actual está apuntado por HL
                        ; Ejemplo de "procesamiento": cargar el valor en A (opcional)
    LD A, (HL)
    or a
    jr z, _m_m_r_c_process_exit
    push hl
    
    dec a

    call man_map_render_single_cell

    pop hl
    ld (hl), a
_m_m_r_c_process_exit:
    INC HL                ; Mover al siguiente elemento (siguiente columna)
    DEC C                 ; Decrementar el contador de columnas
    Jp p, _m_m_r_c_loopv ; Si no es cero, volver al inicio del bucle de columnas

    POP BC            ; Restaurar el contador de filas
    DEC B             ; Decrementar el contador de filas
    Jp p, _m_m_r_c_looph  ; Si no es cero, volver al inicio del bucle de filas
    ret

;;-----------------------------------------------------------------
;;
;; man_map_render::
;;
;;  renders the map based on tilemaps
;;  Input: 
;;  Output: 
;;  Modified: 
;;
man_map_render::

    call man_map_generate

    ld c, #14
    ld b, #23
    ld de, #_m_map_W
    ld hl, #_g_map_tileset_00
    call cpct_etm_setDrawTilemap4x8_ag_asm
 
    m_screenPtr_frontbuffer 12, 8
    ex de,hl 
    ld de, #_m_map
    call cpct_etm_drawTilemap4x8_ag_asm

    call man_map_render_cells

    call sys_input_wait4anykey          ;; wait for any key

    ret