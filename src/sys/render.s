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
.include "man/oponent.h.s"
.include "man/foe.h.s"
.include "man/fight.h.s"
.include "sys/text.h.s"
.include "sys/util.h.s"
.include "sys/messages.h.s"
.include "sys/behaviour.h.s"
.include "cpctelera.h.s"
.include "common.h.s"
.include "comp/component.h.s"


;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA

FONT_NUMBERS: .dw #0000
_show_deck_string: .asciz "PLAYERS DECK"            ;;12 chars, 24 bytes
_press_any_key_string: .asciz "PRESS ANY KEY"       ;;14 chars, 28 bytes

sys_render_front_buffer: .db 0xc0
sys_render_back_buffer: .db 0x80
sys_render_touched_zones: .db 0x00

sys_render_blank_sprite4x5::
    .db 0x00, 0x00, 0x00, 0x00
	.db 0x00, 0x00, 0x00, 0x00
	.db 0x00, 0x00, 0x00, 0x00
	.db 0x00, 0x00, 0x00, 0x00
	.db 0x00, 0x00, 0x00, 0x00

;;
;; Start of _CODE area
;; 
.area _CODE

;;====================================================
;; sys_render_init_back_buffer
;;  Initialize screen buffers
;;  Entrada: hl : buffer
;;  Salida:
;;  Destruye: BC, DE, HL
;;
;; Code taken form Miss Input 
;;====================================================
sys_render_clear_buffer::
    ld (hl), #0
    ld d, h
    ld e, l
    inc de
    ld bc, #0x4000-1

    ldir
ret

;;====================================================
;; sys_render_init_back_buffer
;;  Initialize screen buffers
;;  Entrada:
;;  Salida:
;;  Destruye: BC, DE, HL
;;
;; Code taken form Miss Input 
;;====================================================
sys_render_clear_back_buffer::
    ld a, (sys_render_back_buffer)
    ld h, a
    ld l, #0
    call sys_render_clear_buffer
    ret

;;====================================================
;; sys_render_init_back_buffer
;;  Initialize screen buffers
;;  Entrada:
;;  Salida:
;;  Destruye: BC, DE, HL
;;
;; Code taken form Miss Input 
;;====================================================
sys_render_clear_front_buffer::
    ld a, (sys_render_front_buffer)
    ld h, a
    ld l, #0
    call sys_render_clear_buffer
    ret



;;====================================================
;;  sys_render_switch_buffers
;;  
;;  Switches screen buffers
;;  Entrada:
;;  Salida:
;;  Destruye: AF, HL
;;
;; Code taken form Miss Input 
;;====================================================
sys_render_switch_buffers::
    ld hl, (sys_render_front_buffer)    ;; Inicialmente (80C0)
    ld a, l                             ;; Carga el front buffer en el back buffer
    ld (sys_render_back_buffer) , a
    ld a, h                             ;; Carga el back buffer en el front buffer
    ld (sys_render_front_buffer), a
    srl a
    srl a
    ld l, a
    call cpct_waitVSYNC_asm
    jp cpct_setVideoMemoryPage_asm

;;====================================================
;;  sys_render_switch_crtc_start
;;  
;;  Switches screen buffers
;;  Entrada:
;;  Salida:
;;  Destruye: AF, HL
;;
;; Code taken form Miss Input 
;;====================================================
sys_render_switch_crtc_start::
    call cpct_waitVSYNC_asm

    ld a, (sys_render_front_buffer)   ;; Inicialmente (80C0)
    srl a
    srl a
    ld l, a
    call cpct_setVideoMemoryPage_asm
    ret



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
    ;;cpctm_setBorder_asm HW_WHITE            ;; Set Border

    call sys_render_clear_back_buffer
    call sys_render_clear_front_buffer

    ;;cpctm_clearScreen_asm 0                 ;; Clear screen

    ret


;;-----------------------------------------------------------------
;;
;; sys_render_erase_zone_player_sprite
;;
;;  Erases the player sprite
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_erase_zone_player_sprite::
    ld ix, #player
    call sys_render_erase_oponent
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_erase_zone_enemy_sprite
;;
;;  Erases the player sprite
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_erase_zone_enemy_sprite::
    ld ix, #foes_array
    call sys_render_erase_oponent
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_foe_effects
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_foe_effects::
    ld a, (player_updates)
    and #updated_foe_effect                 ;; check if player effects have been updated
    ret z                                   ;; return if no update is necessary
    push ix                                 ;; save ix
    ld ix, #foes_array
    call sys_render_effects
    pop ix                                  ;; restore ix
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_foe_sprite
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_foe_sprite::
    ld a, (player_updates)
    and #updated_foe_sprite                 ;; check if player effects have been updated
    ret z                                   ;; return if no update is necessary
    push ix                                 ;; save ix
    ld ix, #foes_array
    call sys_render_erase_oponent
    call man_foe_number_of_foes             ;; Check if thera are enemies left
    or a                                    ;;
    call nz, sys_render_oponent             ;; if so, render
    pop ix                                  ;; restore ix
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_player_effects
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_player_effects::
    ld a, (player_updates)
    and #updated_player_effect              ;; check if player effects have been updated
    ret z                                   ;; return if no update is necessary
    push ix                                 ;; save ix
    ld ix, #player                          ;; point ix to player struct
    call sys_render_effects
    pop ix                                  ;; restore ix
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_icon_numbers
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_icon_numbers::
    ld a, (player_updates)
    and #updated_icon_numbers           ;; check if icons have been updated
    ret z                               ;; return if no update is necessary
    call sys_render_energy              ;; Energy number
    call sys_render_sacrifice           ;; Sacrifice number
    call sys_render_deck                ;; Deck number
    call sys_render_cemetery            ;; Cemetery number
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_hand
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_hand::
    ld a, (player_updates)
    and #updated_hand                     ;; check if hand has been updated
    ret z                                 ;; return if no update is necessary
    call sys_render_erase_hand
    call sys_render_hand
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_fight
;;
;;  Updates the render system
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_fight::
    ld a, (player_updates)                      ;; check screen areas
    or a                                        ;;
    ret z                                       ;; return if no update is necessary

    
    call sys_render_update_hand                 ;;
    call sys_render_update_foe_effects          ;;  render zones back buffer
    call sys_render_update_player_effects       ;;
    call sys_render_update_icon_numbers         ;;
    call sys_render_current_behaviour
    
    call sys_render_switch_buffers              ;; switch buffers
    ;call sys_render_switch_crtc_start           ;;
    
    call sys_render_update_hand                 ;;
    call sys_render_update_foe_effects          ;;  render zones front buffer
    call sys_render_update_player_effects       ;;
    call sys_render_update_icon_numbers         ;;
    call sys_render_current_behaviour

    xor a                                       ;; initilizes player updates
    ld (player_updates), a                      ;;

    ret


;;-----------------------------------------------------------------
;;
;; sys_render_get_X_start
;;
;;  Updates the starting x coord for rendering the array
;;  Input: ix: array of cards
;;  Output: a: x cord to start rendering the array of cards
;;  Modified: AF, C
;;
sys_render_get_X_start::
    ;; Calculate x start coord
    ld a, (hand_count)
    ld c, a                     ;; Multiply num cards by 6
    sla a                       ;;
    sla a                       ;; Multyply by 4
    add c                       ;;
    add c                       ;; Multiplies by 6

    srl a                       ;; Divide (num cards*8) by 2
    ld c,a                      ;; move ((num cards*8)/2) to c
    ld a, #39                   ;; a = 40
    sub c                       ;; a = 40 - ((num cards*8)/2)
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_erase_hand
;;
;;  Erase the deck render area
;;  Input: 
;;  Output: a random piece
;;  Modified: AF, BC, DE, HL
;;
sys_render_erase_hand::
;;    ld ix, #hand
;;    call sys_render_get_X_start     ;; get x coord to start rendering the deck
;;    ld c, a                         ;; c = x coordinate  
;;    ld b, #0                        ;; move num cards in deck to b (index)
;;_e_d_loop01:    
;;    push bc                       
;;    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
;;
;;    ld_de_backbuffer
;;    
;;    ld a, a_selected(ix)            ;; compare card selected with current card
;;    cp b                            ;;
;;    ld b, #HAND_Y                   ;; b = y coordinate by default
;;    jr nz, _erase_not_selected      ;; jump if current card not selected
;;    ld b, #HAND_Y - 5
;;
;;_erase_not_selected:
;;    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
;;    
;;    ex de, hl                       ;; move screen address to de
;;    ld c, #S_CARD_WIDTH
;;    ld b, #S_CARD_HEIGHT
;;    ld a,#0                         ;; Patern of solid box
;;    call cpct_drawSolidBox_asm
;;
;;    pop bc                          ;; retrieve bc index of loop, and x coord
;;    
;;    ld a, #(S_CARD_WIDTH-2)             ;; add CARD WITH to x coord
;;    add c                           ;;
;;    ld c, a                         ;;
;;
;;    inc b                           ;; increment current card
;;
;;    ld a, a_count(ix)                ;; compare with num of cards in deck
;;    cp b                            ;;
;;    jr nz, _e_d_loop01              ;; return to loop if not lasta card reached
;;
    
    m_screenPtr_backbuffer HAND_X, HAND_Y_2      ;; Calculates backbuffer address
    ld c, #64
    ld b, #(S_CARD_HEIGHT + 5)
    ld a, #0
    call cpct_drawSolidBox_asm

    ;; Erase description
    ;;ld_de_backbuffer    
    ;;ld b, #DESC_Y_1
    ;;ld c, #DESC_X
    ;;call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ;;ex de, hl                       ;; move screen address to de
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_X, DESC_Y_1  ;; screen address in de
    m_screenPtr_backbuffer DESC_X,DESC_Y_1      ;; Calculates backbuffer address
    ld c, #64
    ld b, #20    
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
sys_render_card::
    ;; Get screen address of the card
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld_de_backbuffer
    
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
;; sys_render_show_deck
;;
;;  Shows the current deck on screen
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_show_deck::

    cpctm_clearScreen_asm 0

    ;;ld_de_backbuffer    
    ;;ld b, #10
    ;;ld c, #5
    ;;call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ;;ex de, hl                       ;; move screen address to de
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 5, 10  ;; screen address in de
    m_screenPtr_backbuffer 5,10      ;; Calculates backbuffer address
    
    ld b, #70
    ld c, #180
    ld a, #0xff
    call sys_messages_draw_box

    ;;ld_de_backbuffer    
    ;;ld b, #14
    ;;ld c, #27
    ;;call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ;;ex de, hl                       ;; move screen address to de    
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 27, 14  ;; screen address in de
    m_screenPtr_backbuffer 27,14      ;; Calculates backbuffer address

    ld hl, #_show_deck_string
    ld c, #0
    call sys_text_draw_string

    ld ix, #deck_array
    ld c, #DECK_X                     ;; c = x coordinate 
    ld b, #0
_s_r_s_d_loop0:
    push bc     
    push ix                                                 ;; Save b and c values 

    ld a, (deck_selected)                                   ;; compare card selected with current card
    cp b                                                    ;;
    ld b, #DECK_Y                                           ;; c = y coordinate by default
    jr nz, _render_not_selected_show                             ;; jump if current card not selected
    ld b, #DECK_Y - 5

    cpctm_push AF, BC, DE, HL , IX                                  ;; Save values              
    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_SHOW_X, DESC_SHOW_Y_1    ;; screen address in de
    m_screenPtr_backbuffer DESC_SHOW_X, DESC_SHOW_Y_1           ;; Calculates backbuffer address

    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    ;; Render Card Description
    ld de, #c_description                                       ;; load description address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_SHOW_X, DESC_SHOW_Y_2    ;; screen address in de
    m_screenPtr_backbuffer DESC_SHOW_X, DESC_SHOW_Y_2           ;; Calculates backbuffer address

    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    cpctm_pop IX, HL, DE, BC, AF                                    ;; Restore values    

_render_not_selected_show:
    call  sys_render_card

    pop ix                      ;; Move ix to the next card
    ld de, #sizeof_c            ;;
    add ix, de                  ;;

    pop bc                      ;; retrive b value for the loop

    ld a, #(S_CARD_WIDTH)         ;; Calculate x coord in C
    add c                       ;;
    ld c, a                     ;;

    inc b                       ;; increment current card

    ld a, (deck_count)            ;; compare with num of cards in deck
    cp b                        ;;
    jr nz, _s_r_s_d_loop0         ;; return to loop if not lasta card reached

    ret


;;-----------------------------------------------------------------
;;
;; sys_render_hand
;;
;;  Renders a hand of cards 
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL, IX, IY
;;
sys_render_hand::
    ld ix, #hand
    ld a,(hand_count)                       ;; retrieve num cards in deck
    or a                                    ;; If no cards ret
    ret z                                   ;;

    push iy                                 ;; save iy in the pile
    ld ix, #hand_array          
    call sys_render_get_X_start             ;; retrieve X start position of the deck in a
    ld c, a                                 ;; c = x coordinate 
    ld b, #0
_s_r_h_loop0:
    push bc                                 ;; Save b 
    push ix                                 

    ld l, e_p(ix)                           ;; Load card pointer in hl
    ld h, e_p+1(ix)                         ;;

    ld__iy_hl

    ld a, (hand_selected)                                   ;; compare card selected with current card
    cp b                                                    ;;
    ld b, #HAND_Y                                           ;; c = y coordinate by default
    jr nz, _hand_render_not_selected                             ;; jump if current card not selected
    ld b, #HAND_Y - 5

    cpctm_push AF, BC, DE, HL                               ;; Save values              
    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    ld__hl_iy                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_X, DESC_Y_1    ;; screen address in de
    m_screenPtr_backbuffer DESC_X, DESC_Y_1                     ;; Calculates backbuffer address

    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    ;; Render Card Description
    ld de, #c_description                                       ;; load description address in hl
    ld__hl_iy                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_X, DESC_Y_2    ;; screen address in de
    m_screenPtr_backbuffer DESC_X, DESC_Y_2           ;; Calculates backbuffer address

    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    cpctm_pop HL, DE, BC, AF                                    ;; Restore values    

_hand_render_not_selected:
    push iy                                                     ;; move iy to ix for render card
    pop ix                                                      ;;
    
    call  sys_render_card                                       ;; render card

    pop ix                      ;; Move ix to the next card
    ld de, #sizeof_e          ;;
    add ix, de                  ;;

    pop bc                      ;; retrive b value for the loop

    ld a, #(S_CARD_WIDTH-2)         ;; Calculate x coord in C
    add c                       ;;
    ld c, a                     ;;

    inc b                       ;; increment current card

    ld a, (hand_count)            ;; compare with num of cards in deck
    cp b                        ;;
    jr nz, _s_r_h_loop0         ;; return to loop if not lasta card reached

    pop iy

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_show_array
;;
;;  Shows the current deck on screen
;;  Input: ix: points to the array to show
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_show_array::

    cpctm_clearScreen_asm 0

    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 5, 10      ;; screen address in de
    m_screenPtr_backbuffer 5, 10           ;; Calculates backbuffer address
    ld b, #70
    ld c, #180
    ld a, #0xff
    call sys_messages_draw_box

    ld hl, #_show_deck_string
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 27, 14     ;; screen address in de
    m_screenPtr_backbuffer 27, 14                           ;; Calculates backbuffer address

    ld c, #0
    call sys_text_draw_string

    ld c, #DECK_X                                           ;; c = x coordinate 
    ld b, #0

    ld a, a_selected(ix)                                    ;; store selected card for later comparing
    ld (SELECTED_CARD), a                                   ;;

    ld a, a_count(ix)                                       ;; store number of elements in the array in array_count
    ld (ARRAY_COUNT), a                                     ;; store array count in array_count         

    push ix                                                 ;; hl points to the first element of the array
    pop hl                                                  ;;
    ld de, #a_array                                         ;; 
    add hl, de                                              ;; 

    inc hl                                                  ;; skip status, hl points to the first pointer to card

_s_r_s_a_loop0:

    ld a, (hl)                                              ;; move the contents of hl (card pointed) to ix
    ld__ixl_a                                               ;;
    inc hl                                                  ;;
    ld a, (hl)                                              ;;
    ld__ixh_a                                               ;; ix = first card in deck

    push bc                                                 ;; Save b and c values
    push hl                                                 ;; Save hl value

SELECTED_CARD = . +1
    ld a, #0
    cp b                                                        ;;
    ld b, #DECK_Y                                               ;; c = y coordinate by default
    jr nz, _a_render_not_selected_show                             ;; jump if current card not selected
    ld b, #DECK_Y - 5
    
    push HL                                           ;; Save values              
    push bc

    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_SHOW_X, DESC_SHOW_Y_1    ;; screen address in de
    m_screenPtr_backbuffer DESC_SHOW_X, DESC_SHOW_Y_1           ;; Calculates backbuffer address
    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    ;; Render Card Description
    ld de, #c_description                                       ;; load description address in hl
    ld__hl_ix                                                   ;; load card index in hl
    add hl, de                                                  ;; add name offset to hl
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, DESC_SHOW_X, DESC_SHOW_Y_2    ;; screen address in de
    m_screenPtr_backbuffer DESC_SHOW_X, DESC_SHOW_Y_2           ;; Calculates backbuffer address
    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    pop bc
    pop HL                                                      ;; Restore values    

    
_a_render_not_selected_show:
    call  sys_render_card
    pop hl                      ;; retrive hl value for the loop
    pop bc                      ;; retrive b value for the loop


    ld a, #(S_CARD_WIDTH)       ;; Calculate x coord in C
    add c                       ;;
    ld c, a                     ;;

    inc b                       ;; increment current card

    inc hl                      ;; move to next card
    inc hl                      ;; skip status byte of next element

ARRAY_COUNT = .+1
    ld a, #00                       ;; compare with num of cards in deck
    cp b                            ;;
    jr nz, _s_r_s_a_loop0           ;; return to loop if not lasta card reached

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_current_behaviour
;;
;;  Shows the the entire fight screen
;;  Input: IX: foe structure
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_current_behaviour::
    push ix
    ld ix, #foes_array
    ld c, o_sprite_x(ix)                ;; read x position of foe sprite
    inc c                               ;; inc x
    inc c                               ;; inc x
    ld a, o_sprite_y(ix)                ;; read y position of foe sprite
    ld b, #(S_SMALL_ICONS_HEIGHT+3)     ;; substract vertical offset
    sub b                               ;;
    ld b, a                             ;;
    ld_de_backbuffer
    call cpct_getScreenPtr_asm          ;; Calculate video memory location and return it in HL
    ex de, hl                           ;; Move video address location to de
    
    
    ;; Draw behaviour sprite
    ld l, o_behaviour_func(ix)          ;; obtain current behaviour
    ld h, o_behaviour_func + 1(ix)      ;;
    ld a, o_behaviour_step(ix)          ;;
    call sys_behaviour_get_behaviour    ;;
    
    push bc                             ;; save behaviuour and amount in stack
    push de                             ;; save screen address to draw the number

    ld hl, #0                           ;; initializes hl
    ld a, b                             ;; move behaviour to a
    ld b, #0
    ld c, #S_SMALL_ICONS_SIZE           ;; load in bc the width of the icons
_srcb_add_effect_loop:
    or a 
    jr z, _srcb_add_effect_endloop      ;; check if we are finished
    add hl, bc                          ;; add width of icons to hl
    dec a                               ;; decrement index
    jr _srcb_add_effect_loop            ;; jump back to the loop 
_srcb_add_effect_endloop:

    ld bc, #_s_small_icons_00           ;; set bc to point to the first icon
    add hl, bc                          ;; and move hl to the specific icon

    ld c, #S_SMALL_ICONS_WIDTH
    ld b, #S_SMALL_ICONS_HEIGHT
    call cpct_drawSprite_asm
    
    pop de                              ;; retrieve the screen address
    ld hl, #(S_SMALL_ICONS_WIDTH + 1)   ;; calcualte offset
    add hl, de                          ;; sum address + offset
    ex de, hl                           ;; Move video adress location to de
    m_draw_blank_small_number           ;; erases previous number

    pop bc                              ;; retrieve behaviour and amount from stack
    ld h, #0
    ld l, c
    
    call sys_text_draw_small_number ;; draws number

    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_effects
;;
;;  Shows the the entire fight screen
;;  Input: IX: player structure
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_effects::

    ;; Calc the screen address to draw the effect

    ;; xcoord base
    ld a, o_sprite_w(ix)        ;; a=sprite width 
    sra a                       ;; a = sprite_width/2
    add a, o_sprite_x(ix)       ;; a = sprite_x + (sprite_width/2)

    ld b, o_effects_count(ix)   ;; b = num effects
    inc b                       ;; b = (num effects + 1)
    sla b                       ;; b = (num effects + 1) * 2
    sub b                       ;; a = sprite_x + (sprite_width/2) - ((num effects + 1) * 2)
    
    ld (_x_coord_base), a
    ld c, a
    ld (_X_COORD_HEART_EFFECT), a         ;; store in a memory spot for later use


    ;; ycoord base
    ld a, o_sprite_y(ix)
    add a, o_sprite_h(ix)
    add a, #2                   ;; offset to the sprite pos
    ld (_y_coord_base), a
    ld b, a
    ld (_Y_COORD_HEART_EFFECT), a     ;; store in a memory spot for later use


    ;; Get screen address of the oponent
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld_de_backbuffer
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl
    ;; Draw heart sprite
    ld hl, #_s_small_icons_00
    ld c, #S_SMALL_ICONS_WIDTH
    ld b, #S_SMALL_ICONS_HEIGHT
    call cpct_drawSprite_asm

 ;; Draw effect amount

    ;; Get screen address of the text
_X_COORD_HEART_EFFECT = .+1
    ld c, #0
    ld a, #10
_Y_COORD_HEART_EFFECT = .+1
    add a, #0
    ld b, a
    inc b
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld_de_backbuffer
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    
    ex de, hl

    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, o_life(ix)
    
    call sys_text_draw_small_number ;; draws number



    ;; Check if effects > 0
    ld a, o_effects_count(ix)   ;; Check if effects count > 0
    or a                        ;;
    ret z                       ;;

    ld__hl_ix                   ;; charge hl with ix

    ld a, #o_shield             ;; position hl at the first effect
    add_hl_a                    ;;            

    ld b, #0                     ;;
_effects_loop:
    push hl                     ;; Keep the pointer to the effect in the stack
    push bc                     ;; keep index loop in the stack

    ld a, (hl)
    or a 
    jr z, _next_effect

    ld a, (_x_coord_base)
    ld c, b                         ;; c = current effect
    inc c                           ;; c = current effect + 1
    sla c                           ;; c = (current effect + 1) * 2
    sla c                           ;; c = (current effect + 1) * 4
    add c                           ;; a = _x_coord_base + ((current effect + 1) * 4)
    ld c,a
    ld (_X_COORD_EFFECT), a         ;; store in a memory spot for later use

    ;; ycoord
    
    ld a, (_y_coord_base)
    ld b, a
    ld (_Y_COORD_EFFECT), a     ;; store in a memory spot for later use

    ;; Get screen address of the oponent
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld_de_backbuffer
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl
    
    pop bc
    push bc
    ld hl, #0
_add_effect_loop:
    ld a, #S_SMALL_ICONS_SIZE
    add_hl_a
    dec b
    jp p, _add_effect_loop      ;; jump back to the loop if b > 0

    ld bc, #_s_small_icons_00
    add hl, bc
    
    ld c, #S_SMALL_ICONS_WIDTH
    ld b, #S_SMALL_ICONS_HEIGHT
    call cpct_drawSprite_asm

    ;; Draw effect amount

    ;; Get screen address of the text
_X_COORD_EFFECT = .+1
    ld c, #0
    ld a, #10
_Y_COORD_EFFECT = .+1
    add a, #0
    ld b, a
    inc b
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
        
    ld_de_backbuffer
    
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    
    ex de, hl

    m_draw_blank_small_number       ;; erases previous number
    
    pop bc
    pop hl
    push hl
    push bc
    ld a, (hl)
    cp #10
    jr nc, _draw_effect_number
    inc de
_draw_effect_number:
    ld h, #0
    ld l, a    
    call sys_text_draw_small_number



_next_effect:
    pop bc                      ;; retrieve index loop form the stack
    pop hl                      ;; retrieve index effect from the stack
    inc hl
    inc b
    ld a, #NUM_EFFECTS
    cp b
    jr nz, _effects_loop
    ret
_x_coord_base: .db #0
_y_coord_base: .db #0

;;-----------------------------------------------------------------
;;
;; sys_render_oponent
;;
;;  Shows an oponent on the screen
;;  Input: IX struct of the oponent
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_oponent::
    
    ;; Get screen address of the oponent
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld_de_backbuffer    
    
    ld c, o_sprite_x(ix)
    ld b, o_sprite_y(ix)
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL

    ex de, hl

    ld l, o_sprite(ix)
    ld h, o_sprite+1(ix)
    ld c, o_sprite_w(ix)
    ld b, o_sprite_h(ix)
    call cpct_drawSprite_asm
      
    call sys_render_effects
    
    ret


;;-----------------------------------------------------------------
;;
;; sys_render_erase_oponent
;;
;;  Erases an oponent form the screen
;;  Input: ix: pointer to the oponent
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_erase_oponent::
    
    ;; Get screen address of the oponent
    ;;ld de, #CPCT_VMEM_START_ASM     ;; DE = Pointer to start of the screen
    
    ld_de_backbuffer

    ld c, o_sprite_x(ix)
    ld b, o_sprite_y(ix)
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL

    ex de, hl

    ld c, o_sprite_w(ix)
    ld b, o_sprite_h(ix)            
    ld a, #S_SMALL_ICONS_HEIGHT     ;; Increase height to erase effects too
    sla a                           ;;
    add b                           ;;
    ld b, a                         ;;
    ld a, #0                        ;; Black color
    call cpct_drawSolidBox_asm
    
    ret


;;-----------------------------------------------------------------
;;
;; sys_render_topbar
;;
;;  Shows the the entire fight screen
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_topbar::
    ;; draw life
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 0, 0  ;; screen address in de
    m_screenPtr_backbuffer 0,0      ;; Calculates backbuffer address

    ld hl, #_s_small_icons_00
    ld c, #S_SMALL_ICONS_WIDTH
    ld b, #S_SMALL_ICONS_HEIGHT
    call cpct_drawSprite_asm

    call sys_text_reset_aux_txt


    ld ix, #player
    ld h, #0
    ld l, o_life(ix)
    ld de, #aux_txt
    call sys_text_num2str8

    ex de, hl
    
    ld (hl), #'/'
    inc hl
    ld (hl), #'1'
    inc hl
    ld (hl), #'0'
    inc hl
    ld (hl), #'0'
    ld hl, #aux_txt
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 5, 1  ;; screen address in de
    m_screenPtr_backbuffer 5,1      ;; Calculates backbuffer address

    ld c, #0
    call sys_text_draw_string

    ;;draw money
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 20, 0  ;; screen address in de
    m_screenPtr_backbuffer 20,0      ;; Calculates backbuffer address

    ld hl, #_s_coin
    ld c, #S_COIN_WIDTH
    ld b, #S_COIN_HEIGHT
    call cpct_drawSprite_asm

    call sys_text_reset_aux_txt

    ld h, #0
    ld l, o_money(ix)
    ld de, #aux_txt
    call sys_text_num2str8

    ld hl, #aux_txt
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 25, 1  ;; screen address in de
    m_screenPtr_backbuffer 25,1      ;; Calculates backbuffer address

    ld c, #0
    call sys_text_draw_string


    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 45, 1  ;; screen address in de
    m_screenPtr_backbuffer 45,1      ;; Calculates backbuffer address

    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, o_force(ix)
    call sys_text_draw_small_number

    ret


;;-----------------------------------------------------------------
;;
;; sys_render_energy
;;
;;  Draws the energy amount
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_energy::

    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 1, 136  ;; screen address in de
    m_screenPtr_backbuffer 1, 137           ;; Calculates backbuffer address
    
    m_draw_blank_small_number       ;; erases previous number

    ld a, (player_energy)
    ld h, #0
    ld l, a
    call sys_text_draw_small_number
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_sacrifice
;;
;;  Draws the sacrifie amount of cards
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_sacrifice::
    ld ix, #sacrifice
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 75, 136  ;; screen address in de
    m_screenPtr_backbuffer 75, 137           ;; Calculates backbuffer address
    
    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, a_count(ix)
    call sys_text_draw_small_number
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_deck
;;
;;  Draws the deck amount of cards
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_deck::
    ld ix, #fight_deck

    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 1, 166  ;; screen address in de
    m_screenPtr_backbuffer 1, 166           ;; Calculates backbuffer address
    
    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, a_count(ix)
    call sys_text_draw_small_number
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_cemetery
;;
;;  Draws the cemetery amount of cards
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_cemetery::
    ld ix, #cemetery
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 75, 166  ;; screen address in de
    m_screenPtr_backbuffer 75, 166  ;; Calculates backbuffer address

    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, a_count(ix)
    call sys_text_draw_small_number
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_icons
;;
;;  Draws the game icons
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_icons::
    ;; energy icon
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 0, 118  ;; screen address in de
    m_screenPtr_backbuffer 0, 119           ;; Calculates backbuffer address
    ld hl, #_s_icons_2
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm

    ;; sacrifice icon
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 74, 118  ;; screen address in de
    m_screenPtr_backbuffer 74, 119           ;; Calculates backbuffer address
    ld hl, #_s_icons_0
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm
    
    ;; deck
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 0, 148  ;; screen address in de
    m_screenPtr_backbuffer 0, 148           ;; Calculates backbuffer address
    ld hl, #_s_icons_3
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm

    ;; cemetery
    ;;cpctm_screenPtr_asm de, CPCT_VMEM_START_ASM, 74, 148  ;; screen address in de
    m_screenPtr_backbuffer 74, 148           ;; Calculates backbuffer address
    ld hl, #_s_icons_1
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm

    ret

;;-----------------------------------------------------------------
;;
;;  sys_render_full_fight_screen
;;
;;  Shows the the entire fight screen
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_full_fight_screen::

    ;;call sys_render_clear_front_buffer
    call sys_render_clear_back_buffer
    
    call sys_render_topbar
      
    call sys_render_icons
    
    call sys_render_energy              ;; Energy number
    call sys_render_sacrifice           ;; Sacrifice number
    call sys_render_deck                ;; Deck number
    call sys_render_cemetery            ;; Cemetery number

    ;; render player
    ld ix, #player
    call sys_render_oponent
    ;; render oponent
    ld ix, #foes_array
    call sys_render_oponent
    
    call sys_render_hand

    ret