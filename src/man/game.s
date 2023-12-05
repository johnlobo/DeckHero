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

.module game_manager
.include "common.h.s"
.include "sys/render.h.s"
.include "sys/behaviour.h.s"
.include "sys/messages.h.s"
.include "sys/text.h.s"
.include "sys/input.h.s"
.include "sys/util.h.s"
.include "man/fight.h.s"
.include "man/player.h.s"
.include "man/oponent.h.s"
.include "man/deck.h.s"
.include "man/array.h.s"
.include "man/map.h.s"
.include "cpctelera.h.s"



;;
;; Start of _DATA area 
;;  SDCC requires at least _DATA and _CODE areas to be declared, but you may use
;;  any one of them for any purpose. Usually, compiler puts _DATA area contents
;;  right after _CODE area contents.
;;
.area _DATA
_add_card_string: .asciz "ADD A CARD TO YOUR DECK"      ;;
_space_string: .asciz "SPACE - ADD CARD"      ;;
_esc_string: .asciz "ESC - SKIP"      ;;
card01:: .dw #0000
card02:: .dw #0000
card03:: .dw #0000

add_card_moved:: .db #00
add_card_max:: .db #03
add_card_action:: .db #00
add_card_selected:: .db #00
add_card_previous:: .db #00

blob_template::
DefineOponent 1, ^/BLOB           /, _s_blob_0, 60, 60, S_BLOB_WIDTH, S_BLOB_HEIGHT, 20, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0

foe::
DefineOponent 1, ^/FOE   1        /, _s_blob_0, 60, 60, S_BLOB_WIDTH, S_BLOB_HEIGHT, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, #sys_behaviour_blob, 0

;;
;; Start of _CODE area
;; 
.area _CODE

;;-----------------------------------------------------------------
;;
;; man_game_init
;;
;;  
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_init::
    call man_player_init    ;; Initialize player
    call man_deck_init      ;; Initialize deck

    call man_map_init
    call man_map_render2    ;; New map Render routine
    
    call man_game_add_new_card
    call man_fight_init     ;; Initialize fight
    ret

;;-----------------------------------------------------------------
;;
;; man_game_get_selected_card
;;
;;   
;;  Input: 
;;  Output: hl contains the address of the selected card
;;  Modified: AF, hl, DE
;;
man_game_get_selected_card::
    ld hl, #card01                                              ;; move hl to the selected card variable
    ld a, (add_card_selected)                                   ;;
    sla a                                                       ;;
    add_hl_a                                                    ;;

    ld a, (hl)                                                  ;; move (hl) to hl
    ld d, a                                                     ;;
    inc hl                                                      ;;
    ld a, (hl)                                                  ;;
    ld h, a                                                     ;;
    ld l, d                                                     ;;
    ret

;;-----------------------------------------------------------------
;;
;; man_game_card_text
;;
;;  
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_card_text::
    cpctm_push AF, BC, DE, HL                                   ;; Save values

    m_screenPtr_frontbuffer 12, 110                             ;; Calculates backbuffer address
    ld c, #50
    ld b, #20
    ld a, #0
    call cpct_drawSolidBox_asm

    call man_game_get_selected_card                             ;; gets the address of the selected card in hl
    
    push hl                                                     ;; save address of card for later
    ;; Render Card Name
    ld de, #c_name                                              ;; load name address in hl
    add hl, de                                                  ;; add name offset to hl
    m_screenPtr_frontbuffer 12, 110                             ;; Calculates backbuffer address

    ld c, #1                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name

    ;; Render Card Description
    pop hl
    ld de, #c_description                                       ;; load description address in hl
    add hl, de                                                  ;; add name offset to hl
    m_screenPtr_frontbuffer 12, 120                             ;; Calculates backbuffer address
    ld c, #0                                                    ;; first color
    call sys_text_draw_string                                   ;; draw card name
    cpctm_pop HL, DE, BC, AF                                    ;; Restore values
    ret  


;;-----------------------------------------------------------------
;;
;; man_game_anc_drawbox
;;
;;  Input: a: pintar(1) o borrar (0)
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_anc_drawbox::
    or a
    jr nz, mgad_draw
mgad_erase:
    xor a
    ld (MGAD_BORDER_COLOR), a
    ld a, (add_card_previous)       ;;
    jr mgad_continue
mgad_draw:
    ld a, #0x3c
    ld (MGAD_BORDER_COLOR), a
    ld a, (add_card_selected)       ;;
mgad_continue:
    
    ld e, a                         ;;
    ld h, #0x10                       ;;
    call sys_util_h_times_e         ;;
    ld a, #0x12                       ;;
    add l                           ;;
    ld c, a                         ;;
    ld b, #0x28                       ;;
    ld_de_frontbuffer                ;;
    call cpct_getScreenPtr_asm      ;; Calculate video memory location and return it in HL
    ex de, hl                       ;; move screen address to de

    ld c, #(S_CARD_WIDTH + 4)
    ld b, #(S_CARD_HEIGHT + 14)
    ld l, #0x00                     ;; Empty box
MGAD_BORDER_COLOR = . +1
    ld a, #0x33                     ;; Border color
    call sys_messages_draw_box
    ret


;;-----------------------------------------------------------------
;;
;; man_fight_add_new_card
;;
;;   
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_add_new_card::
    m_screenPtr_frontbuffer 8, 15           ;; Calculates backbuffer address
    ld c, #64
    ld b, #180
    ld a, #0x33
    ld l, #0x01                             ;; Filled box
    call sys_messages_draw_box
    ;; title
    ld hl, #_add_card_string
    m_screenPtr_frontbuffer 18, 20          ;; Calculates frontbuffer address
    ld c, #0
    call sys_text_draw_string
    ;; footer
    ld hl, #_space_string
    m_screenPtr_frontbuffer 12, 160          ;; Calculates frontbuffer address
    ld c, #0
    call sys_text_draw_string

    ld hl, #_esc_string
    m_screenPtr_frontbuffer 12, 170          ;; Calculates frontbuffer address
    ld c, #0
    call sys_text_draw_string


    ld a, (add_card_max)                    ;; check if max card is 0
    or a                                    ;;
    ret z                                   ;;

    ld b, #0
mganc_render_loop:
    push bc                                 ;; get a random card from model_deck
    ld ix, #model_deck                      ;;
    ld a, #2                                ;;
    call man_array_get_random_element       ;;
    pop bc
    push bc
    push hl
    ld a,b                                  ;; index loaded in a
    sla a                                   ;; multiply index by 2
    ex de, hl                               ;; mov+e card pointer to de
    ld hl, #card01                          ;; load card01 pointer in hl
    add_hl_a                                ;; hl points to the correct card
    ld a, e                                 ;; move de to (hl)
    ld (hl), a                              ;;
    inc hl                                  ;;
    ld a, d                                 ;;
    ld (hl), a                              ;;

    pop ix
    pop bc                                  ;; retrieve index
    push bc                                 ;; re-store index

    ld c, #0x14                             ;; initial hor coord
    ld e, #0x10                             ;; offset between cards
    ld h, b 
    call sys_util_h_times_e                 ;; multiply idex by offset
    ld a, c                                 ;; 
    add l                                   ;; add offset 
    ld c, a 
    ld b, #0x30                             ;; y coord
    ld_de_frontbuffer   
    call sys_render_card                    ;; render card

    pop bc                                  ;; retrieve main loop index
    inc b                                   ;; inc index
    ld a, (add_card_max)                    ;;
    cp b                                    ;; Compare with max card
    jr nz, mganc_render_loop                ;; loop if not reached
    
    xor a
    ld (add_card_action), a
    ld (add_card_selected), a
    ld (add_card_previous), a

    ld a, #1                            ;; pintar
    call man_game_anc_drawbox   
    call man_game_card_text 

ac_input_loop:
    call sys_input_add_card_update          ;; Check players actions
    ld a, (add_card_action)                 ;; read action from input
    cp #255                                 ;; check if esc has been clicked
    jr z, ac_cancel                         ;;
    cp #1                                   ;; check if space has been clicked
    jr z, ac_action                         ;;

    ld a, (add_card_moved)
    or a
    jr z, ac_input_loop

    xor a                                   ;; borrar
    call man_game_anc_drawbox
    ld a, #1                                ;; pintar
    call man_game_anc_drawbox
    call man_game_card_text
    ld b, #2                              ;; Delay
    call sys_util_delay                   ;;
    xor a
    ld (add_card_moved),a 
    jr ac_input_loop                        ;; No action -> loop

ac_action:
    call man_game_get_selected_card
    ld ix, #deck
    call man_array_create_element

ac_cancel:
    ;;call sys_render_switch_buffers
    ;;call sys_render_full_fight_screen   ;; renders the fight screen

    ret

;;-----------------------------------------------------------------
;;
;; man_game_update
;;
;;   
;;  Input: 
;;  Output: 
;;  Modified: AF, BC, DE, HL
;;
man_game_update::
    call man_fight_update

    call man_game_add_new_card
    
    call man_fight_init
    ret