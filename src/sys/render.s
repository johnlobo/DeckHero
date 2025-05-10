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
.include "man/array.h.s"

.module render_system

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

_x_coord_base: .db #0
_y_coord_base: .db #0


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

;;-----------------------------------------------------------------
;;
;; sys_render_init
;;
;;  Initilizes render system
;;  Input: 
;;  Output: 
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

    ;;call sys_render_clear_back_buffer
    call sys_render_clear_front_buffer

    ;;cpctm_clearScreen_asm 0                 ;; Clear screen

    ret



;;-----------------------------------------------------------------
;;
;; sys_render_update_foe_effects
;;
;;  Updates the render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_foe_effects::
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
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_foe_sprite::                                 
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
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_player_effects::
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
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_icon_numbers::
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
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_hand::
    call sys_render_erase_hand
    call sys_render_hand
    ;;call sys_render_selected_card
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_animations
;;
;;  Updates the render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_animations::
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_update_fight
;;
;;  Updates the render system
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_update_fight::
    ld a, (player_updates)                      ;; check screen areas
    or a                                        ;;
    ret z                                       ;; return if no update is necessary

    call cpct_waitVSYNC_asm

    ld a, (player_updates)                      ;;
    and #updated_foe_effects                    ;; check if foe effects need update  
    call nz, sys_render_update_foe_effects      ;;  
    
    ld a, (player_updates)                      ;;
    and #updated_hand                           ;; check if hand needs update  
    call nz, sys_render_update_hand             ;;  
    
    ld a, (player_updates)                      ;;
    and #updated_player_effects                 ;; check if hand needs update  
    call nz, sys_render_update_player_effects   ;;

    ld a, (player_updates)                      ;;
    and #updated_icon_numbers                   ;; check if icon numbersd needs update  
    call nz, sys_render_update_icon_numbers     ;;
    
    call sys_render_current_behaviour

    call sys_render_update_animations           ;; update animations
    
    xor a                                       ;; initilizes player updates
    ld (player_updates), a                      ;;

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
    ;;ld_de_backbuffer
    ld_de_frontbuffer
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
    ld b, #15                           ;; small number color = 15 
    call sys_text_draw_small_number     ;; draws number

    pop ix
    ret

;;-----------------------------------------------------------------
;;
;; sys_render_effects_base_coords
;;
;;  Calculate the base coords for the effects 
;;  Input: IX: player structure
;;  Output: 
;;  Modified: AF, BC
;;
sys_render_effects_base_coords::
    ;; Calc the screen address to draw the effect
    ;; xcoord base
    ld a, o_sprite_w(ix)        ;; a=sprite width 
    sra a                       ;; a = sprite_width/2
    add a, o_sprite_x(ix)       ;; a = sprite_x + (sprite_width/2)

    ld b, o_effects_count(ix)   ;; b = num effects
    inc b                       ;; b = (num effects + 1)
    inc b                       ;; b = (num effects + 1)
    sla b                       ;; b = (num effects + 1) * 2
    sub b                       ;; a = sprite_x + (sprite_width/2) - ((num effects + 1) * 2)    
    ld (_x_coord_base), a

    ;; ycoord base
    ld a, o_sprite_y(ix)
    add a, o_sprite_h(ix)
    add a, #2                   ;; offset to the sprite pos
    ld (_y_coord_base), a

    ret

;;-----------------------------------------------------------------
;;
;; sys_render_effects_clear_icons
;;
;;  Clear the icons of the effects
;;  Input: IX: player structure
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;  pre-requirement : execute sys_render_effects_base_coords
;;
sys_render_effects_clear_icons::
    ;; Erase previous effects
    ld_de_frontbuffer    
    ld a, (_y_coord_base)
    ld b, a
    ld a, (_x_coord_base)
    ld c, a
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de
    
    ld c, #20
    ld b, #16    
    ld a, #0
    call cpct_drawSolidBox_asm

    ret


;;-----------------------------------------------------------------
;;
;; sys_render_effects
;;
;;  Shows the efects 
;;  Input: IX: player structure
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
sys_render_effects::
    ;; Calc the screen address to draw the effect
    call sys_render_effects_base_coords 
    ;; Erase effects icon
    call sys_render_effects_clear_icons

;; Check if effects > 0
    ld a, o_effects_count(ix)   ;; Check if effects count > 0
    or a                        ;;
    ret z                       ;; return otherwise

    ld__hl_ix                   ;; charge hl with ix
    ld a, #o_life               ;; position hl at the first effect
    add_hl_a                    ;;            

 ;;cpctm_WINAPE_BRK

    ld b, #0                    ;; reset index of the loop
_effects_loop:
    push hl                     ;; Keep the pointer to the effect in the stack
    push bc                     ;; keep index loop in the stack

    ld a, (hl)                  ;; check if the effect is active
    or a                        ;;
    jr z, _next_effect          ;; otherwise jump to the next effect

    ;; x_coord
    ld a, (_x_coord_base)
    ld c, b                         ;; c = current effect
    inc c                           ;; c = current effect + 1
    sla c                           ;; c = (current effect + 1) * 2
    sla c                           ;; c = (current effect + 1) * 4
    add c                           ;; a = _x_coord_base + ((current effect + 1) * 4)
    ld c,a
    ld (_X_COORD_EFFECT), a         ;; store in a memory spot for later use

    ;; y_coord
    ld a, (_y_coord_base)
    ld b, a
    ld (_Y_COORD_EFFECT), a     ;; store in a memory spot for later use

    ;; Get screen address of the oponent
    ld_de_frontbuffer
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move the screen address to de
 
    pop bc
    push bc
    ld hl, #0

add_effect_loop:
    ld a, #S_SMALL_ICONS_SIZE
    dec b
    jp m, _exit_effect_loop
    add_hl_a
    jr add_effect_loop

_exit_effect_loop:

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
    ld_de_frontbuffer
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
    ld b, #15                       ;; small number color = 15 
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
    
    ;;ld_de_backbuffer    
    ld_de_frontbuffer    
    
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
    
    ;;ld_de_backbuffer
    ld_de_frontbuffer

    ;; Calc the screen address to draw the effect
    call sys_render_effects_base_coords 
    ;; Erase effects icon
    call sys_render_effects_clear_icons

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
    m_screenPtr_frontbuffer 1,3      ;; Calculates backbuffer address

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
    ;;m_screenPtr_backbuffer 5,1      ;; Calculates backbuffer address
    m_screenPtr_frontbuffer 5,4      ;; Calculates backbuffer address

    ld c, #0
    call sys_text_draw_string

    ;;draw money
    ;;m_screenPtr_backbuffer 20,0      ;; Calculates backbuffer address
    m_screenPtr_frontbuffer 22,2      ;; Calculates backbuffer address

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
    ;;m_screenPtr_backbuffer 25,1      ;; Calculates backbuffer address
    m_screenPtr_frontbuffer 27,4      ;; Calculates backbuffer address

    ld c, #0
    call sys_text_draw_string

    ;;m_screenPtr_backbuffer 45,1      ;; Calculates backbuffer address
    m_screenPtr_frontbuffer 47,4        ;; Calculates backbuffer address

    m_draw_blank_small_number           ;; erases previous number

    ld h, #0
    ld l, o_force(ix)
    ld b, #15                           ;; small number color
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

    m_screenPtr_frontbuffer 4, 137           ;; Calculates backbuffer address
    
    m_draw_blank_small_number       ;; erases previous number

    ld a, (player_energy)
    ld h, #0
    ld l, a
    ld b, #15                           ;; small number color
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
    m_screenPtr_frontbuffer 74, 137           ;; Calculates backbuffer address
    
    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, a_count(ix)
    ld b, #15                           ;; small number color
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
    m_screenPtr_frontbuffer 4, 166           ;; Calculates backbuffer address
    
    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, a_count(ix)
    ld b, #15                           ;; small number color
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
    m_screenPtr_frontbuffer 74, 166  ;; Calculates backbuffer address

    m_draw_blank_small_number       ;; erases previous number

    ld h, #0
    ld l, a_count(ix)
    ld b, #15                           ;; small number color
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
    m_screenPtr_frontbuffer 2, 120         ;; Calculates address
    ld hl, #_s_icons_2
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm
    call sys_render_energy                 ;; Energy number

    ;; sacrifice icon
    m_screenPtr_frontbuffer 72, 120        ;; Calculates address
    ld hl, #_s_icons_0
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm
    call sys_render_sacrifice               ;; Sacrifice number
    
    ;; deck
    m_screenPtr_frontbuffer 2, 149          ;; Calculates  address
    ld hl, #_s_icons_3
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm
    call sys_render_deck                    ;; Deck number

    ;; cemetery
    m_screenPtr_frontbuffer 72, 149         ;; Calculates address
    ld hl, #_s_icons_1
    ld c, #S_ICONS_WIDTH
    ld b, #S_ICONS_HEIGHT
    call cpct_drawSprite_asm
    call sys_render_cemetery                ;; Cemetery number

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

    call sys_render_draw_frame

    call sys_render_topbar
      
    call sys_render_icons

    ;; render player
    ld ix, #player
    call sys_render_oponent
    ;; render oponent
    ld ix, #foes_array
    call sys_render_oponent
    
    call sys_render_hand

    ret


;;-----------------------------------------------------------------
;;
;;  sys_render_getNextLine
;;
;;  Shows the the entire fight screen
;;  Input: hl : screen address 
;;  Output: hl : screen address below
;;  Modified: AF, DE, HL
;;
sys_render_getNextLine::
    ld     a, #0x8          ;; [2] / HL = DE = DE + 0x800
    add    h                ;; 
    ld     h, a             ;; [1] | Adding 0x800 makes HL point to the start of the next line
    ;; We check if we have crossed video memory boundaries (which will happen every 8 lines). 
    ;; ... If that happens, bits 13,12 and 11 of destination pointer will be 0
    and   #0x38             ;; [2] leave out only bits 13,12 and 11 from new memory address (00xxx000 00000000)
    jp    nz, srg_exit          ;; [3] If any bit from {13,12,11} is not 0, we are still inside 
                            ;; ... video memory boundaries, so proceed with next line
    ;; Every 8 lines, we cross the 16K video memory boundaries and have to
    ;; reposition destination pointer. That means our next line is 16K-0x50 bytes back
    ;; which is the same as advancing 48K+0x50 = 0xC050 bytes, as memory is 64K 
    ;; and our 16bit pointers cycle over it
    ld    de, #0xC050       ;; [3] We advance destination pointer to next line
    add   hl, de            ;; [3] HL = DE + 0xC050
srg_exit:
    ret

;;-----------------------------------------------------------------
;;
;;  sys_render_getPreviousLine
;;
;;  Shows the the entire fight screen
;;  Input: hl : screen address 
;;  Output: hl : screen address below
;;  Modified: AF, DE, HL
;;
sys_render_getPreviousLine::
    ld a, h
    ld h, #0x8
    sub    h                ;; 
    ld     h, a             ;; [1] | Adding 0x800 makes HL point to the start of the next line
    ;; We check if we have crossed video memory boundaries (which will happen every 8 lines). 
    ;; ... If that happens, bits 13,12 and 11 of destination pointer will be 0
    or   #0x3F             ;; [2] leave out only bits 13,12 and 11 from new memory address (00xxx000 00000000)
    cp #0xff
    jp z, srp_exit          ;; [3] If any bit from {13,12,11} is not 0, we are still inside 
                            ;; ... video memory boundaries, so proceed with next line
    ;; Every 8 lines, we cross the 16K video memory boundaries and have to
    ;; reposition destination pointer. That means our next line is 16K-0x50 bytes back
    ;; which is the same as advancing 48K+0x50 = 0xC050 bytes, as memory is 64K 
    ;; and our 16bit pointers cycle over it
    ld    de, #0xC050       ;; [3] We advance destination pointer to next line
    or a				;; reset carry flag
    sbc   hl, de            ;; [3] HL = DE + 0xC050
srp_exit:
    ret

;;----------------------------------------------------------------
;; sys_render_draw_line
;;
;; Input:   stack: x1, y1, x2, y2
;;
;;
;; faster version 27.9.2016
;;----------------------------------------------------------------
sys_render_draw_line::
 
CMASK = #0xB6A3 ;EQU &B338  change address for colormask in 464
 
    di
    pop bc              ;; save return address for later

     
    pop hl
    add hl, hl      ;; x coord multiplied by two
    ld (x1+1),hl  ;x1
 
    pop de
    ld (y1+1),de  ;y1
 
    pop hl
    add hl, hl      ;; x coord multiplied by two
    ld (x2+1),hl  ;x2
 
    pop hl

    push bc             ;; Insert thhe return address again
    ld (exith+1), sp  ; save SP to restore at exit..

    ld (y2+1),hl  ;y2
    ;   x1, y1 start point   0<x<159
    ;   x2, y2  end point    0<y<199
 
 
    or a
    sbc hl,de    ;  hl=y2-y1  
 
    bit 7,h
    jr z,gnp0
    xor a
    sub l
    ld l,a
    sbc a,a
    sub h
    ld h,a     ;  ABS hl
 
gnp0:
    ld (dy+1),hl      ; =ABS(DY)
    LD A,H
    CPL
    LD H,A
    LD A,L
    CPL
    LD L,A
    INC HL ; neg hl = -DY
 
    srl h
    rr l
    set 7,h ; keep negative HL
 
    ld(er+1),hl    ;  ER = -DY/2
 
    ex de,hl
    ld de,(y2+1)
    or a
    sbc hl,de   ; hl=y1-y2
 
    ld a,#0x34
    jr c,.+4
    ld a,#0x35  ; sy= DEC (HL) / if y1 - y2 <0  sy= INC (HL)
    ld (sy),a
 
    ld de,(x1+1)
    ld hl,(x2+1)
    or a
    sbc hl,de     ; hl=x2-x1
 
    bit 7,h
    jr z,gnp1
    xor a
    sub l
    ld l,a
    sbc a,a
    sub h
    ld h,a     ;  ABS hl
 
gnp1:
    ld sp,hl
    ld b,h
    ld c,l ; =ABS(DX) = BC = SP stack pointer !!!!!!
   
    ex de,hl
    ld de,(x2+1)
    or a
    sbc hl,de ;  HL=x1-x2
   
    ld a, #0x34
    jr c,.+4
    ld a, #0x35  ; sx= DEC (HL) / if x1 - x2 <0  sx= INC (HL)
    ld (sx),a
   
    ld h,b
    ld l,c ;  HL=dx
   
    ld de,(dy+1)
    or a
    sbc hl,de    ; hl=dx-dy
   
    jr c,nex0    ; if dx-dy>0 (dx>dy)  [when nc]
    ld h,b
    ld l,c ; HL=dx
   
    srl h
    rr l
    ld (er+1),hl ; then er=dx/2
 
nex0:
DRLOOP:  ; main DRAWING loop
x1:
    ld de, #1
y1:
    ld hl, #1
 
; Fast Plot for MODE 0 by Executioner follows...
FPLOT:    
    LD A, L            ;A = Lowbyte Y
    AND #0b00000111        ;isolate Bit 0..2
    LD H, A            ;= y MOD 8 to H
    XOR L            ;A = Bit 3..7 of Y
    LD L, A            ;= (Y\*8 to L
    LD C, A            ;store in C
    LD B, #0x60        ;B = &C0\2 = Highbyte Screenstart\2
    ADD HL, HL        ;HL * 2
    ADD HL, HL        ;HL * 4
    ADD HL, BC        ;+ BC = Startaddress
    ADD HL, HL        ;of the raster line
    SRL E            ;calculate X\2, because 2 pixel per byte, Carry is X MOD 2
    LD C, #0b10101010            ;Bitmask for MODE 0
    JR NC, NSHIFT        ;-> = 0, no shift
SHIFT:    
    LD C, #0b01010101            ;other bitmask for right pixel
NSHIFT:    
    ADD HL, DE        ;+ HL = Screenaddress
    LD A, (CMASK)        ;get color mask
    XOR (HL)        ;XOR screenbyte
    AND C            ;AND bitmask
    XOR (HL)        ;XOR screenbyte
    LD (HL), a        ;new screenbyte
 
 
ld hl,(x1+1)
x2:
    ld de, #0
    or a
    sbc hl,de
    jr nz,nex1  ; CHECK if we reach the end???
 
    ld hl,(y1+1)
    y2:
    ld de, #0
    or a
    sbc hl,de
    jr z,exith  ; if x1=x2 and y1=y2 then exit!!
 
nex1:
 
er:
    ld hl, #0
    ld b,h
    ld c,l     ; HL=ER=E2=BC
dy:
    ld de, #0   ; DE= DY
    add hl,sp    ; SP=DX
    bit 7,h
    jr nz,nex2    ; IF  E2+DX > 0  THEN ER = ER - DY
 
    ld h,b
    ld l,c
    or a
    sbc hl,de
    ld(er+1),hl  ; er = er -dy
 
    ld hl, #(x1+1)
 
sx: .db #0        ; X1 = X1 + SX
 
nex2:
    ld h,b
    ld l,c  ; HL=E2   DE=dy
    or a
    sbc hl,de      ; IF E2 - DY < 0 THEN ER = ER + DX
    bit 7,h
    jr z,nex3
 
    ld hl,(er+1)  
    add hl,sp    ; SP=DX
    ld(er+1),hl         ; er = er+dx
    ld hl, #(y1+1)
 
sy: .db #0             ; Y1 = Y1 + SY
 
nex3:
    JP DRLOOP
 
exith:
    ld sp, #0000
    ei
    ret  ; finished OK

;;----------------------------------------------------------------
;; sys_render_draw_frame
;;
;; Input:   stack: x1, y1, x2, y2
;;
;;
;; faster version 27.9.2016
;;----------------------------------------------------------------
sys_render_draw_frame::

   ld c, #20
   ld b, #25
   ld de, #_m_frame_W
   ld hl, #_g_tileset_00
   call cpct_etm_setDrawTilemap4x8_ag_asm

   ld hl, #0xC000
   ld de, #_m_frame
   call cpct_etm_drawTilemap4x8_ag_asm

    ret
    